import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/groq_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  File? selectedImage;

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
    if (_controller.text.trim().isEmpty && selectedImage == null) return;

    final userText = _controller.text;
    final image = selectedImage;

    setState(() {
      messages.add({
        "role": "user",
        "text": userText,
        "localImage": image?.path,
      });
    });

    _controller.clear();
    selectedImage = null;

    try {
      final aiText = await GroqService.sendMessage(text: userText);

      String? imageUrl;
      if (image != null) {
        imageUrl = await redesignImage(image, aiText);
      }

      setState(() {
        messages.add({"role": "ai", "text": aiText, "imageUrl": imageUrl});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "ai", "text": "Error: $e"});
      });
    }
  }

  Future<String> redesignImage(File imageFile, String prompt) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("http://10.208.19.187:8000/redesign"),
    );

    request.fields["prompt"] = prompt;
    request.files.add(
      await http.MultipartFile.fromPath("image", imageFile.path),
    );

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    final json = jsonDecode(responseData);

    if (json["image_url"] == null) {
      throw Exception(json["error"] ?? "Image generation failed");
    }

    return json["image_url"];
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
                    imageUrl: msg["imageUrl"],
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

  Widget _aiMessage(String text, {String? imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: sageLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(text),
            ),
          ],
        ),
        if (imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 8),
            child: Image.network(imageUrl),
          ),
      ],
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
