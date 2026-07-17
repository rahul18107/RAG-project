import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document.dart';

class DocumentService {
  static final _supabase = Supabase.instance.client;

  // fetch all documents from supabase
  static Future<List<Document>> fetchAll() async {
    final response = await _supabase
        .from('documents')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((row) => Document(
      id: row['id'],
      name: row['name'],
      subject: row['subject'],
      meta: '${row['page_count']} pages · ${row['file_size']}',
      uploadedAt: DateTime.parse(row['created_at']),
    )).toList();
  }

  // delete a document — chunks delete automatically (cascade)
  static Future<void> delete(String id) async {
    await _supabase
        .from('documents')
        .delete()
        .eq('id', id);
  }

  // fetch flashcards for a document
  static Future<List<Map<String, dynamic>>> fetchFlashcards(
      String documentId) async {
    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('document_id', documentId)
        .order('created_at', ascending: true);

    return (response as List)
        .cast<Map<String, dynamic>>();
  }

  // fetch chat messages for a document
  static Future<List<Map<String, dynamic>>> fetchMessages(
      String documentId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('document_id', documentId)
        .order('created_at', ascending: true);

    return (response as List)
        .cast<Map<String, dynamic>>();
  }

  // save a chat message
  static Future<void> saveMessage({
    required String documentId,
    required String text,
    required bool isUser,
    String? sourceRef,
  }) async {
    await _supabase.from('messages').insert({
      'document_id': documentId,
      'text': text,
      'is_user': isUser,
      'source_ref': sourceRef,
    });
  }

  // total flashcards count
  static Future<int> fetchFlashcardsCount() async {
    final response = await _supabase
        .from('flashcards')
        .select('id');
    return (response as List).length;
  }

// total messages count (only user messages)
  static Future<int> fetchChatsCount() async {
    final response = await _supabase
        .from('messages')
        .select('id')
        .eq('is_user', true);
    return (response as List).length;
  }
}