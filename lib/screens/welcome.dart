import 'package:fashion_ai/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
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
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          color: Color(0xFF1B130D),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Hero Image
                      SizedBox(
                        height: 420,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return ClipRect(
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 0.9, // crop left/right edges
                                  child: Image.asset(
                                    'assets/images/fashion2.png',
                                    width: constraints.maxWidth,
                                    height: 420,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
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
                          onPressed: () {
                             Navigator.push(context,MaterialPageRoute(builder: (context)=>const RegisterPage(),
                            ),
                            );

                          },
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
                          onPressed: () {
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>const LoginPage(),
                            ),
                            );
                          },
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/risk');
                        },
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
