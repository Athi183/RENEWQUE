import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.menu, size: 28),
                  Icon(Icons.shopping_bag_outlined, size: 28),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Brand Name
                      Text(
                        'RENEWQUE',
                        style: TextStyle(
                          fontSize: 32,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PlayfairDisplay',
                          color: Color(0xFF1B130D),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Hero Image
                      Container(
                        height: 420,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAxSqwuocViKQ_wW5GJnl3tMTp43XxrGV4tNk4b3Vt0OHjSEJwyzcqai35AbjmFkDx_M-m5A0V9SmOtGxCVW5OYnB-ijvb4Fkgwy8LMLRJsL5NqbZObh15hOd5-wW3WR6Ze7bu_DmeKYWv4fLSZhkzBCExwFgCzdWIWkPE76j6TzLoNC77g3ffZvHP2sL8opcSzYlLHgRNaocpcqRze_PGkvXqESlmpnuLp5dx7YkhGFSUFRP9zrPJ0JeKSA9OzocI_prznbuJzRTw',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tagline
                      const Text(
                        'Reviving Beauty, Redefining Style',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Sustainable fashion AI for ethical redesign and textile waste reduction.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),

                      const SizedBox(height: 40),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF602D08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3ECE7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B130D),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Guest Link
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
