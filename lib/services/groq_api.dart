import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  // Load API key from .env file
  static final String _apiKey = dotenv.env['GROQ_API'] ?? '';
  
  // ✅ CORRECT Groq API endpoint
  static const String _url = "https://api.groq.com/openai/v1/chat/completions";
  
  // ✅ Using openai/gpt-oss-120b model
  static const String _model = "openai/gpt-oss-120b";
  
  // Token limits to respect free tier quota
  static const int _maxTokens = 512; // Conservative limit for free tier

  /// Sends a message to Groq API and returns the AI response
  /// 
  /// Parameters:
  ///   - text: User's text input (required)
  ///   - image: Optional image file (currently not supported)
  /// 
  /// Returns: AI response string from Groq
  /// Throws: Exception if API key missing, image provided, quota exceeded, or API fails
  static Future<String> sendMessage({
    required String text,
    File? image,
  }) async {
    // Step 1: Validate API key is loaded from .env
    if (_apiKey.isEmpty) {
      print("❌ ERROR: GROQ_API key not found in .env file");
      throw Exception("GROQ_API key not found in .env");
    }
    
    print("✅ API key loaded: ${_apiKey.substring(0, 10)}...");

    // Step 2: Check if image was provided and reject it
    if (image != null) {
      print("❌ ERROR: Image processing not yet supported");
      throw Exception("Image processing is not yet supported. Please send text only.");
    }

    // Step 3: Validate user text is not empty
    if (text.trim().isEmpty) {
      print("❌ ERROR: Empty text message provided");
      throw Exception("Message cannot be empty");
    }

    print("📤 Sending message to Groq API: '$text'");
    print("🔧 Using model: $_model");
    print("💾 Max tokens (free tier limit): $_maxTokens");

    try {
      // Step 4: Build HTTP request with proper headers and body
      // Token limit is set conservatively to avoid quota issues
      final requestBody = {
        "model": _model,
        "messages": [
          {
            "role": "system",
            "content": "You are RenewQue, a sustainable fashion redesign assistant. Help users reimagine their clothing in eco-friendly ways. Keep responses concise.",
          },
          {
            "role": "user",
            "content": text,
          },
        ],
        "temperature": 0.7,
        "max_tokens": _maxTokens, // Conservative limit for free tier
      };

      print("📋 Request Body: ${jsonEncode(requestBody)}");

      // Step 5: Make HTTP POST request with timeout
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timeout: API took too long to respond");
        },
      );

      print("📨 Response Status: ${response.statusCode}");
      print("📨 Response Headers: ${response.headers}");
      print("📨 Response Body: ${response.body}");

      // Step 6: Parse response based on status code
      if (response.statusCode == 200) {
        // ✅ Success: Extract AI message from response
        final data = jsonDecode(response.body);
        final aiReply = data["choices"][0]["message"]["content"];
        print("✅ AI Response received successfully");
        print("✅ Response length: ${aiReply.length} characters");
        return aiReply;
      } 
      // Handle quota exceeded error
      else if (response.statusCode == 429) {
        print("⚠️ QUOTA EXCEEDED: Free tier limit reached");
        final errorMessage = "Free tier limit reached. Please wait until quota resets.";
        throw Exception(errorMessage);
      } 
      // Handle authentication error
      else if (response.statusCode == 401) {
        print("❌ AUTHENTICATION ERROR: Invalid API key");
        throw Exception("Invalid API key. Check your GROQ_API in .env file");
      } 
      // Handle model not found error
      else if (response.statusCode == 404) {
        print("❌ MODEL ERROR: Model '$_model' not found");
        throw Exception("Model '$_model' is not available. Check https://console.groq.com for available models");
      }
      // Handle other API errors
      else {
        print("❌ API Error - Status Code: ${response.statusCode}");
        print("❌ Response Body: ${response.body}");
        
        // Try to extract error message from response
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData["error"]["message"] ?? "Unknown error";
          throw Exception("Groq API error (${response.statusCode}): $errorMsg");
        } catch (e) {
          throw Exception("Groq API error (${response.statusCode}): ${response.body}");
        }
      }
    } on SocketException catch (e) {
      // Handle network connection errors
      print("❌ NETWORK ERROR: $e");
      throw Exception("Network error. Check your internet connection");
    } catch (e) {
      // Step 7: Handle unexpected errors (network, parsing, etc.)
      print("❌ Exception occurred: $e");
      rethrow;
    }
  }
}
