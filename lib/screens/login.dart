import 'package:flutter/material.dart';
import 'home.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool isLogin = true;
  bool obscurePassword = true;

  final Color primary = const Color(0xFF602D08);
  final Color bgLight = const Color(0xFFF8F7F6);
  final Color textDark = const Color(0xFF1B130D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            decoration: BoxDecoration(
              color: bgLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _topBar(),
                  const SizedBox(height: 20),
                  _icon(),
                  _title(),
                  _subtitle(),
                  _segmentButtons(),
                  _form(),
                  _actionButton(),
                  _divider(),
                  _socialButtons(),
                  _footerText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI PARTS ----------------

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.close),
          const Spacer(),
          Text(
            "RENEWQUE",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _icon() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.eco, color: primary, size: 40),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        isLogin ? "Welcome Back" : "Create Account",
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B130D),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _subtitle() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "Join the movement for ethical fashion redesign and textile waste reduction.",
        style: const TextStyle(fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _segmentButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _segment("Sign In", true),
            _segment("Register", false),
          ],
        ),
      ),
    );
  }

  Widget _segment(String text, bool loginValue) {
    final selected = isLogin == loginValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = loginValue),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black12, blurRadius: 5)]
                : [],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? textDark : primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _textField("Email Address", "your.email@example.com"),
          const SizedBox(height: 20),
          _passwordField(),
        ],
      ),
    );
  }

  Widget _textField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Password",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Text(
              "Forgot?",
              style: TextStyle(color: Color(0xFF602D08), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscurePassword,
          decoration: InputDecoration(
            hintText: "••••••••",
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: const Color(0xFF602D08),
              ),
              onPressed: () =>
                  setState(() => obscurePassword = !obscurePassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          minimumSize: const Size.fromHeight(56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        child: Text(
          isLogin ? "Sign In" : "Register",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text("OR CONTINUE WITH",
                style: TextStyle(fontSize: 11)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _socialButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _socialIcon(Icons.g_mobiledata),
          _socialIcon(Icons.facebook),
          _socialIcon(Icons.apple),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Expanded(
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown.shade200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }

  Widget _footerText() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        "By continuing, you agree to our Ethical Fashion Pledge and Terms of Service.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.brown.shade400),
      ),
    );
  }
}
