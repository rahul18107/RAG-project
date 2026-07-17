import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseKey => dotenv.env['SUPABASE_KEY'] ?? '';
  static String get geminiKey => dotenv.env['GEMINI_KEY'] ?? '';
  static String get cloudflareToken => dotenv.env['CLOUDFLARE_TOKEN'] ?? '';
  static String get cloudflareAccountId => dotenv.env['CLOUDFLARE_ACCOUNT_ID'] ?? '';

  static const String embeddingModel = 'gemini-embedding-001';
  static const String chatModel = '@cf/meta/llama-3.1-8b-instruct';
  static const int chunkSize = 300;
  static const int chunkOverlap = 30;
}