import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const RenewqueApp());
}

class RenewqueApp extends StatelessWidget {
  const RenewqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Using Manrope font as specified in the HTML
        textTheme: GoogleFonts.manropeTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF602D08), // Primary brand color
          primary: const Color(0xFF602D08),
          surface: const Color(0xFFF8F7F6),
        ),
      ),
      home: const RiskPage(),
    );
  }
}

class RiskPage extends StatelessWidget {
  const RiskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6), // background-light
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F6).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {},
        ),
        title: const Text(
          'Risk Analysis', // Header title
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            // Hero Risk Indicator (Replaces the SVG Arc)
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: 0.5, // Visual for "Medium" risk
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFF602D08).withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF602D08)),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'RISK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: const Color(0xFF602D08).withOpacity(0.7),
                            ),
                          ),
                          const Text(
                            'Medium', // Risk status
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CURRENT SUSTAINABILITY RISK',
                    style: TextStyle(
                      color: Color(0xFF602D08),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Narrative Insight Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD46211).withOpacity(0.1), // soft-glow
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Prediction',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current market shifts suggest a 15% decrease in demand for this silhouette by next quarter. Consider upcycling existing stock into smaller accessories to minimize waste and maximize ethical output.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Explainable AI Section Header
            const Text(
              'EXPLAINABLE AI BREAKDOWN',
              style: TextStyle(
                color: Color(0xFF9A6C4C),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            
            // Factor: Trend Sensitivity
            _buildRiskFactor(
              icon: Icons.trending_up,
              label: 'Trend Sensitivity',
              percentage: 0.65,
              insight: 'High volatility in digital fashion aesthetic',
            ),
            // Factor: Seasonal Mismatch
            _buildRiskFactor(
              icon: Icons.calendar_month,
              label: 'Seasonal Mismatch',
              percentage: 0.40,
              insight: 'Slight delay in material availability for production',
            ),
            // Factor: Resource Waste
            _buildRiskFactor(
              icon: Icons.recycling,
              label: 'Resource Waste',
              percentage: 0.22,
              insight: 'Optimized pattern cutting reduces fabric scrap',
            ),

            const SizedBox(height: 32),

            // Redesign Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF602D08),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: const Color(0xFF602D08).withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_fix_high),
                  SizedBox(width: 12),
                  Text('View Redesign Suggestions', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Analysis updated 2 minutes ago based on live market data.',
                style: TextStyle(color: Color(0xFF9A6C4C), fontSize: 11),
              ),
            ),
            const SizedBox(height: 80), 
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Helper for progress bars
  Widget _buildRiskFactor({required IconData icon, required String label, required double percentage, required String insight}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF602D08)),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                ],
              ),
              Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFE7D9CF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF602D08)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 6),
          Text(insight, style: const TextStyle(color: Color(0xFF9A6C4C), fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // iOS Style Bottom Navigation
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F6).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF602D08),
        unselectedItemColor: const Color(0xFF9A6C4C),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: 1, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), label: 'Materials'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}