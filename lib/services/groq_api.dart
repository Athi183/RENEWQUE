import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static final String _apiKey = dotenv.env['GROQ_API'] ?? '';

  static Future<String> sendMessage({required String text}) async {
    if (_apiKey.isEmpty) {
      throw Exception("GROQ_API key not loaded");
    }

    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {"role": "user", "content": text},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['choices'][0]['message']['content'];
    } else {
      throw Exception(response.body);
    }
  }
}
