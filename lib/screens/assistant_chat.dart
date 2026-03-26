import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/groq_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage({super.key});

  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage> {
  static const earthBrown = Color(0xFF221810);
  static const clay = Color(0xFF9A6C4C);
  static const sageLight = Color(0xFFE2ECE2);
  static const beigeLight = Color(0xFFF5F0E6);
  static const String _backendBaseUrl = "http://127.0.0.1:8080";

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  File? selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    selectedImage = File(image.path);
                  });
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() {
                    selectedImage = File(image.path);
                  });
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    print("DEBUG: sendMessage() triggered");
    if (_controller.text.trim().isEmpty && selectedImage == null) {
      print("DEBUG: Both text and image are empty. Returning.");
      return;
    }
    if (_isLoading) return; 

    final userText = _controller.text.trim();
    final image = selectedImage;
    print("DEBUG: User text: '$userText', Image is null: ${image == null}");

    setState(() {
      _isLoading = true;
      messages.add({
        "role": "user",
        "text": userText,
        "localImage": image?.path,
      });
    });

    _controller.clear();
    setState(() => selectedImage = null);

    // scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      if (image != null) {
        print("DEBUG: Sending to /redesign...");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✨ Redesigning outfit... please wait.")),
        );
        final result = await redesignImage(image, userText);
        setState(() {
          _isLoading = false;
          messages.add({
            "role": "ai",
            "text": result["groq_advice"] ?? "Here is your redesigned outfit!",
            "imageBase64": result["image_base64"],
            "imageUrl": result["image_url"],
            "similarImages": const <Map<String, dynamic>>[],
          });
        });
      } else {
        // ── Text only: existing Groq chat ───────────────────────────────
        final aiText = await GroqService.sendMessage(text: userText);
        setState(() {
          _isLoading = false;
          messages.add({
            "role": "ai",
            "text": aiText,
            "imageUrl": null,
            "similarImages": const <Map<String, dynamic>>[],
          });
        });
      }
    } catch (e) {
      print("DEBUG: Caught error: $e");
      setState(() {
        _isLoading = false;
        messages.add({"role": "ai", "text": "❌ Error: ${e.toString()}"}); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<Map<String, Object?>> redesignImage(File imageFile, String userPrompt) async {
    final url = "$_backendBaseUrl/redesign";
    print("📤 Sending redesign request to: $url");
    print("📁 Image path: ${imageFile.path}");
    print("💬 Prompt: $userPrompt");

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$_backendBaseUrl/redesign"),
      );

      request.files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );
      // Pass the user's redesign idea as a form field
      request.fields["prompt"] = userPrompt.isEmpty
          ? "redesign this outfit in a modern sustainable style"
          : userPrompt;

      var response = await request.send().timeout(const Duration(seconds: 120));
      print("📨 Response status: ${response.statusCode}");

      var responseData = await response.stream.bytesToString();
      print("📄 Response body: $responseData");
      final json = jsonDecode(responseData);

      if (response.statusCode != 200) {
        throw Exception(json["detail"] ?? "Redesign failed (${response.statusCode})");
      }

      return {
        "image_base64":    json["image_base64"],
        "image_url":       json["image_url"],
        "groq_advice":     json["groq_advice"],
        "gemini_analysis": json["gemini_analysis"],
        "sd_prompt":       json["sd_prompt"],
      };
    } catch (e) {
      print("❌ Error in redesignImage: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                if (msg["role"] == "user") {
                  return _userMessage(
                    msg["text"] ?? "",
                    localImage: msg["localImage"],
                  );
                } else {
                  return _aiMessage(
                    msg["text"] ?? "",
                    imageBase64: msg["imageBase64"] as String?,
                    imageUrl: msg["imageUrl"] as String?,
                    similarImages: (msg["similarImages"] as List<dynamic>?)
                        ?.whereType<Map<String, dynamic>>()
                        .toList(),
                  );
                }
              },
            ),
          ),
          if (selectedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          _composer(),
          _bottomActions(),
        ],
      ),
    );
  }

  // 🔝 Top Bar
  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: clay.withValues(alpha: 0.4))),
      ),
      child: Row(
        children: const [
          Icon(Icons.arrow_back_ios),
          Spacer(),
          Column(
            children: [
              Text(
                "RenewQue Assistant",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Online Concierge",
                style: TextStyle(fontSize: 11, color: clay),
              ),
            ],
          ),
          Spacer(),
          Icon(Icons.info_outline),
        ],
      ),
    );
  }

  Widget _aiMessage(
    String text, {
    String? imageBase64,
    String? imageUrl,
    List<Map<String, dynamic>>? similarImages,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(
                  color: sageLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(text),
              ),
            ),
          ],
        ),
        if (imageBase64 != null && imageBase64.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("✨ Redesigned Outfit",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    base64Decode(imageBase64),
                    width: 220,
                    height: 290,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  ),
                ),
              ],
            ),
          )
        else if (imageUrl != null && imageUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("✨ Redesigned Outfit",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    imageUrl,
                    width: 220,
                    height: 290,
                    fit: BoxFit.cover,
                    headers: const {
                      "User-Agent": "Mozilla/5.0 (Android 14; Mobile; rv:109.0) Gecko/124.0 Firefox/124.0",
                    },
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            width: 220,
                            height: 290,
                            color: const Color(0xFFEDE5DE),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(color: clay),
                                SizedBox(height: 8),
                                Text("Generating outfit...", style: TextStyle(fontSize: 12, color: clay)),
                              ],
                            ),
                          ),
                    errorBuilder: (_, __, ___) => GestureDetector(
                      onTap: () async {
                        try {
                          await launchUrl(Uri.parse(imageUrl), mode: LaunchMode.externalApplication);
                        } catch (e) {
                          print("❌ $e");
                        }
                      },
                      child: Container(
                        width: 220,
                        height: 80,
                        decoration: BoxDecoration(color: clay, borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.open_in_browser, color: Colors.white),
                            SizedBox(width: 8),
                            Text("👗 View Redesigned Outfit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _recommendationCard({
    required String name,
    required double score,
    String? imageUrl,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(score * 100).toStringAsFixed(1)}% match",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: clay),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFEDE5DE),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: clay),
    );
  }

  Widget _userMessage(String text, {String? localImage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (localImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(localImage),
              width: 160,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: beigeLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(text),
            ),
            const SizedBox(width: 8),
            _avatar(isUser: true),
          ],
        ),
      ],
    );
  }

  Widget _avatar({bool isUser = false}) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isUser ? clay : earthBrown,
      child: Icon(
        isUser ? Icons.person : Icons.eco,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _composer() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: clay),
            onPressed: pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type your question...",
                filled: true,
                fillColor: beigeLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: clay),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _bottomActions() {
    return const SizedBox(height: 10);
  }
}
