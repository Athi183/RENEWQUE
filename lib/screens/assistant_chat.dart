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
  static const primaryColor = Color(0xFF602D08);
  static const secondaryColor = Color(0xFF9A6C4C);
  static const accentColor = Color(0xFF388E3C);
  static const bgColor = Color(0xFFF8F7F6);
  static const aiBubbleColor = Color(0xFFFFFDFB);
  static const userBubbleColor = Color(0xFF602D08);
  static const darkText = Color(0xFF1B130D);

  // ── Correct dynamic URL for backend ──
  static const String _kLanIp = '10.52.13.34';
  final String _backendBaseUrl = (const bool.fromEnvironment('dart.library.js_util'))
      ? 'http://localhost:8000'
      : 'http://$_kLanIp:8000';
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [
    {
      "role": "ai",
      "text": "Hello! I'm your RenewQue Assistant. I can help you redesign old clothes, check fabric sustainability, or find the best eco-friendly boutiques. What's on your mind today? ✨",
    }
  ];
  File? selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Attach Reference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFF0EDEA), child: Icon(Icons.photo_library, color: primaryColor)),
                title: const Text("Gallery", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) setState(() => selectedImage = File(image.path));
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFF0EDEA), child: Icon(Icons.camera_alt, color: primaryColor)),
                title: const Text("Camera", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) setState(() => selectedImage = File(image.path));
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage({String? customText}) async {
    final textToSend = customText ?? _controller.text.trim();
    if (textToSend.isEmpty && selectedImage == null) return;
    if (_isLoading) return;

    final image = selectedImage;
    setState(() {
      _isLoading = true;
      messages.add({
        "role": "user",
        "text": textToSend,
        "localImage": image?.path,
      });
    });

    _controller.clear();
    setState(() => selectedImage = null);
    _scrollToBottom();

    try {
      if (image != null) {
        final result = await redesignImage(image, textToSend);
        setState(() {
          _isLoading = false;
          messages.add({
            "role": "ai",
            "text": result["groq_advice"] ?? "Here is your redesigned outfit concept!",
            "imageBase64": result["image_base64"],
            "imageUrl": result["image_url"],
          });
        });
      } else {
        final aiText = await GroqService.sendMessage(text: textToSend);
        setState(() {
          _isLoading = false;
          messages.add({
            "role": "ai",
            "text": aiText,
          });
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        messages.add({"role": "ai", "text": "❌ Something went wrong. Let me try again later."});
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<Map<String, Object?>> redesignImage(File imageFile, String userPrompt) async {
    final url = "$_backendBaseUrl/redesign";
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));
      request.fields["prompt"] = userPrompt.isEmpty ? "redesign this outfit sustainably" : userPrompt;
      var response = await request.send().timeout(const Duration(seconds: 120));
      var responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      if (response.statusCode != 200) throw Exception(json["detail"] ?? "Redesign failed");
      return {
        "image_base64": json["image_base64"],
        "image_url": json["image_url"],
        "groq_advice": json["groq_advice"],
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) return _typingIndicator();
                  final msg = messages[index];
                  return msg["role"] == "user" ? _userMessage(msg) : _aiMessage(msg);
                },
              ),
            ),
            _inputArea(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: primaryColor,
            radius: 20,
            child: Icon(Icons.eco_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "RenewQue Assistant",
                  style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w900, fontSize: 18, color: darkText),
                ),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("Online Concierge", style: TextStyle(fontSize: 11, color: secondaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert, color: secondaryColor), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _userMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (msg["localImage"] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(File(msg["localImage"]), width: 220, height: 220, fit: BoxFit.cover),
              ),
            ),
          if (msg["text"] != null && msg["text"].isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              decoration: const BoxDecoration(
                color: userBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(msg["text"], style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
            ),
        ],
      ),
    );
  }

  Widget _aiMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CircleAvatar(radius: 14, backgroundColor: Color(0xFFEEDCC8), child: Icon(Icons.eco_rounded, size: 14, color: primaryColor)),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: aiBubbleColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(color: const Color(0xFFF0EDEA)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Text(msg["text"], style: const TextStyle(color: darkText, fontSize: 15, height: 1.4)),
                ),
              ),
            ],
          ),
          if (msg["imageBase64"] != null || msg["imageUrl"] != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("✨ Redesigned Outfit Concept", style: TextStyle(fontWeight: FontWeight.w900, color: secondaryColor, fontSize: 13)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (msg["imageUrl"] != null) launchUrl(Uri.parse(msg["imageUrl"]), mode: LaunchMode.externalApplication);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: msg["imageBase64"] != null
                          ? Image.memory(base64Decode(msg["imageBase64"]), width: 250, height: 320, fit: BoxFit.cover)
                          : Image.network(msg["imageUrl"], width: 250, height: 320, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Color(0xFFEEDCC8), child: Icon(Icons.eco_rounded, size: 14, color: primaryColor)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: aiBubbleColor, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)),
                const SizedBox(width: 10),
                Text("RenewQue is thinking...", style: TextStyle(fontSize: 12, color: secondaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          if (selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(selectedImage!, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => selectedImage = null),
                          child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Image ready for redesign ✨", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: secondaryColor))),
                ],
              ),
            )
          else
            _quickActions(),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: primaryColor, size: 28), onPressed: pickImage),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 15),
                  onSubmitted: (_) => sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Type your query...",
                    filled: true,
                    fillColor: bgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => sendMessage(),
                child: const CircleAvatar(radius: 24, backgroundColor: primaryColor, child: Icon(Icons.send_rounded, color: Colors.white, size: 20)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _actionChip("Fabric Check 🧵", "Tell me about sustainable fabrics for summer."),
          _actionChip("Redesign ✨", "I have an old denim jacket. Ideas?"),
          _actionChip("Trends 📈", "What are current eco-fashion trends?"),
        ],
      ),
    );
  }

  Widget _actionChip(String label, String fullText) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: secondaryColor.withOpacity(0.05),
        side: BorderSide(color: secondaryColor.withOpacity(0.2)),
        onPressed: () => sendMessage(customText: fullText),
      ),
    );
  }
}
