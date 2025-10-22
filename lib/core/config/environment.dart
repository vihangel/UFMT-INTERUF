import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get supabaseUrl {
    if (kIsWeb) {
      return const String.fromEnvironment('SUPABASE_URL');
    }
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    if (kIsWeb) {
      return const String.fromEnvironment('SUPABASE_ANON_KEY');
    }
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static Future<void> init() async {
    // Para a web, as variáveis são injetadas no build, então não fazemos nada.
    // Para mobile, carregamos o arquivo .env.
    if (!kIsWeb) {
      await dotenv.load(fileName: ".env");
    }
  }
}
