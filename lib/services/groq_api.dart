import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static final String _apiKey = dotenv.env['GROQ_API'] ?? '';
  static const String _url = "https://api.groq.com/openai/v1/chat/completions";

  static Future<String> sendMessage({required String text, File? image}) async {
    if (_apiKey.isEmpty) {
      throw Exception("GROQ_API key not found");
    }

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "llama3-8b-8192",
        "messages": [
          {
            "role": "system",
            "content":
                "You are RenewQue, a sustainable fashion redesign assistant.",
          },
          {"role": "user", "content": text},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("Groq API error: ${response.body}");
    }
  }
}
