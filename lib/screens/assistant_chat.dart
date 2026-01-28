import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/groq_api.dart';

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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty && selectedImage == null) return;

    final userText = _controller.text;
    final image = selectedImage;

    setState(() {
      messages.add({"role": "user", "text": userText, "image": image});
    });

    _controller.clear();
    selectedImage = null;

    // 🔥 CALL GROQ API HERE
    try {
      final aiReply = await GroqService.sendMessage(text: userText);

      setState(() {
        messages.add({"role": "ai", "text": aiReply});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "ai", "text": "ERROR: $e"});
      });
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
                  return _userMessage(msg["text"] ?? "");
                } else {
                  return _aiMessage(msg["text"] ?? "");
                }
              },
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

  Widget _aiMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _userMessage(String text) {
    return Row(
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
