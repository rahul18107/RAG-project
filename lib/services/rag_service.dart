import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RagService {
  static final _supabase = Supabase.instance.client;

  static final _gemini = GenerativeModel(
    model: AppConstants.chatModel,
    apiKey: AppConstants.geminiKey,
  );



  static final _embeddingModel = GenerativeModel(
    model: AppConstants.embeddingModel,
    apiKey: AppConstants.geminiKey,
  );

  // ── 1. CHUNK TEXT ──────────────────────────────────────────
  static List<String> chunkText(String text) {
    final words = text.split(' ');
    final chunks = <String>[];
    int i = 0;

    while (i < words.length) {
      final end = (i + AppConstants.chunkSize)
          .clamp(0, words.length);
      chunks.add(words.sublist(i, end).join(' '));
      i += AppConstants.chunkSize - AppConstants.chunkOverlap;
    }

    return chunks;
  }

  // ── 2. GENERATE EMBEDDING ──────────────────────────────────
  static Future<List<double>> generateEmbedding(String text) async {
    final content = Content.text(text);
    final result = await _embeddingModel
        .embedContent(Content.text(text));
    return result.embedding.values;
  }

  // ── 3. STORE DOCUMENT + CHUNKS ─────────────────────────────
  static Future<String> storeDocument({
    required String name,
    required String subject,
    required String content,
    required int pageCount,
    required String fileSize,
  }) async {
    // save document row
    final docResponse = await _supabase
        .from('documents')
        .insert({
      'name': name,
      'subject': subject,
      'content': content,
      'page_count': pageCount,
      'file_size': fileSize,
    })
        .select()
        .single();

    final docId = docResponse['id'] as String;

    // chunk + embed + store
    final chunks = chunkText(content);
    for (int i = 0; i < chunks.length; i++) {
      final embedding = await generateEmbedding(chunks[i]);
      await _supabase.from('chunks').insert({
        'document_id': docId,
        'content': chunks[i],
        'embedding': embedding,
        'chunk_index': i,
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return docId;
  }

  // ── 4. RETRIEVE RELEVANT CHUNKS ────────────────────────────
  static Future<List<String>> retrieveChunks({
    required String query,
    required String documentId,
  }) async {


    debugPrint('=== RETRIEVE CHUNKS ===');
    debugPrint('Document ID passed: $documentId');
    final queryEmbedding = await generateEmbedding(query);

    final response = await _supabase.rpc('match_chunks', params: {
      'query_embedding': queryEmbedding,
      'match_document_id': documentId,
      'match_count': 3,
    });

    return (response as List)
        .map((r) => r['content'] as String)
        .toList();
  }

  // ── 5. ANSWER QUESTION ─────────────────────────────────────
  static Future<Map<String, String>> askQuestion({
    required String question,
    required String documentId,
  }) async {
    // get relevant chunks via vector search
    final chunks = await retrieveChunks(
      query: question,
      documentId: documentId,
    );

    // fallback if vector search returns nothing
    List<String> contextChunks = chunks;
    if (chunks.isEmpty) {
      final fallback = await _supabase
          .from('chunks')
          .select('content')
          .eq('document_id', documentId)
          .order('chunk_index', ascending: true)
          .limit(3);
      contextChunks = (fallback as List)
          .map((r) => r['content'] as String)
          .toList();
    }

    if (contextChunks.isEmpty) {
      return {
        'answer': 'No content found for this document.',
        'source': '',
      };
    }

    // build context from chunks
    final context = contextChunks
        .map((c) => c.length > 800 ? c.substring(0, 800) : c)
        .join('\n\n---\n\n');

    final prompt = '''
You are an intelligent study assistant helping a college student understand their notes.

Answer the student question using ONLY the notes provided below.

Instructions:
- If asked to summarize, give a well structured summary covering all key points
- If asked for main topics, list each topic with a brief explanation
- If asked a specific question, give a detailed and accurate answer
- Use simple language that a student can understand
- Format your answer with bullet points or numbered lists where helpful
- Always be encouraging and supportive
- If the answer is genuinely not in the notes say exactly: "I couldn't find this in your notes"
- Never make up or assume information not present in the notes

STUDENT NOTES:
$context

STUDENT QUESTION:
$question

YOUR ANSWER:
''';

    try {
      final answer = await _cloudflareChat(prompt);
      return {
        'answer': answer.trim(),
        'source': 'From your notes',
      };
    } catch (e) {
      debugPrint('Chat error: $e');
      return {
        'answer': 'Something went wrong. Please try again.',
        'source': '',
      };
    }
  }

  // ── 6. GENERATE FLASHCARDS ─────────────────────────────────
  static Future<List<Map<String, dynamic>>> generateFlashcards({
    required String documentId,
    required subject,

  }) async {
    // get document content
    final doc = await _supabase
        .from('documents')
        .select('content')
        .eq('id', documentId)
        .single();

    final content = doc['content'] as String;
    final trimmed = content.length > 8000
        ? content.substring(0, 4000)
        : content;

    final prompt = '''
Read the notes below and create 7-8 flashcards covering all major topics.
Return ONLY a valid JSON array, no explanation, no markdown, no backticks.

Format:
[
  {
    "topic": "Topic Name",
    "title": "Card Title",
    "points": ["point 1", "point 2", "point 3"],
    "page_ref": "pg 1-5"
  }
]

NOTES:
$trimmed
''';

    final raw = await _cloudflareChat(
      prompt,
      systemPrompt: '''
You are a JSON generator.

Return ONLY valid JSON.

All keys MUST be enclosed in double quotes.

All string values MUST be enclosed in double quotes.

Do NOT use markdown.

Do NOT explain.

Do NOT write anything before or after the JSON.

Your entire response must be parseable by jsonDecode().
''',
    );

    debugPrint("========== RAW ==========");
    debugPrint(raw);
    debugPrint("=========================");
    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    debugPrint("Cloudflare Response:");
    debugPrint(cleaned);

    try {
      final List<dynamic> cards = jsonDecode(cleaned);
      for (final card in cards) {
        await _supabase.from('flashcards').insert({
          'document_id': documentId,
          'topic': card['topic'] ?? 'General',
          'title': card['title'] ?? 'Summary',
          'points': List<String>.from(card['points'] ?? []),
          'subject': subject,
          'page_ref': card['page_ref'] ?? '',
        });
      }
      return cards.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('JSON parse error: $e');
      debugPrint('Raw response: $raw');
      return [];
    }
  }

  static Future<String> _cloudflareChat(
      String prompt,{
        String? systemPrompt,
      }) async {
    final url = 'https://api.cloudflare.com/client/v4/accounts/'
        '${AppConstants.cloudflareAccountId}/ai/run/'
        '${AppConstants.chatModel}';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${AppConstants.cloudflareToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt ??
                'You are a helpful study assistant. '
                    'Answer questions based only on the provided notes. '
                    'Be clear, structured and concise.',
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 1500,
      }),
    );

    debugPrint('Cloudflare status: ${response.statusCode}');
    debugPrint('Cloudflare body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content =
      data['result']['choices'][0]['message']['content'];
      if (content == null) throw Exception('Empty response');
      return content.toString();
    } else {
      throw Exception('Cloudflare error: ${response.statusCode} ${response.body}');
    }
  }
}