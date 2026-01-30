import 'package:flutter/material.dart';
import 'risk.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),

      // -------------------- APP BAR --------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F7F6),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuCvN50vd08Q8JJlsJOVzKXpX_uLwOMUph1xmnPWxTmj0aqU2rmvtO6zuKF39u89yqJnt03i3Nw-HIxkyp1dMwHGa2dsckEV7Vi1u-JblRBq7QGJwMWG6wya55s-qqkBOLGWjUp9eHSUsjJTZheL02w-1R9_HFIA0ZhmC7-Uu9HI6SDM-EyVZvlOGy3IRq6u7Yi7d3nTK5Lp7RfYzxSekbtg7g7vMle7ojqlmw8dur1tFq-6DYT8DkC-cU_PXapUhUkbafzAkNnQNpc",
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Welcome, Alex",
              style: TextStyle(
                color: Color(0xFF1B130D),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF1B130D)),
            onPressed: () {},
          ),
        ],
      ),

      // -------------------- BODY --------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ready to renew?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B130D),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Reduce waste through AI innovation.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9A6C4C),
                    ),
                  ),
                ],
              ),
            ),

            // Risk Analysis Card
            _FeatureCard(
              title: "Risk Analysis",
              description:
                  "Upload a photo to see the environmental impact and durability of your garment using our proprietary waste-risk AI.",
              imageUrl:
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuDssowVelviqD8JE_EgbYNOSqzKIWzgfaW_9odOo-lk9XddzwUiDTDGYCYQl-6obvynwYvInnAR0f-ZsFDmUUQtXHwFVrKXEw6EqaUydOcHTktXaPQoq_BpldQ1cY78QIIVUeK4IpB1e1Ie1yGBgMG_T6yMYV7gGF0ogiN8F28Mb9O9zCEjE6eGHMxX8GBPid8GVN_28ByXAubwSK7oU8L0kefJu20A8U_XfDjpXM7s09qu_0Kp1hJG-Dhj4JsYnJDiinwxiTxGv4A",
              tag: "AI POWERED",
              buttonText: "Analyze Now",
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RiskPage()));
              },
            ),

            // Redesign Card
            _FeatureCard(
              title: "Redesign My Clothing",
              description:
                  "Transform your old textiles into something new and ethical. Generate patterns and styles based on your existing wardrobe.",
              imageUrl:
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuAA1hxBujIVD3B62kOf0SgmqQbIwlcGXJpJBqbohxo_z-dR5q3I_fthjQvW6Qr7_B7-LK8QzS59Fu2FkzP9h2vRdqXuw5R2P7Mrz3i_EKsJSa-Cozg62ab5n7z0hRdIv26LwaFPxozMC50B27PpSGv3z--gtYHP6ea9wOWYQERDtY_BRAZfeqDrvLNSoBbP9daOnOMpYvwLOR_cDeXi2pCSxFqpgia2MWaib4a7CTM52HGThyyUVniqMCONRNx2_ubb2ZqRX4b1bfY",
              tag: "ECO FRIENDLY",
              buttonText: "Start Redesign",
            ),

            // About Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                "About This App",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B130D),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  _InfoCard(
                    icon: Icons.analytics,
                    title: "Waste Prediction",
                    subtitle:
                        "Predict fabric lifecycle based on fiber quality.",
                  ),
                  SizedBox(width: 12),
                  _InfoCard(
                    icon: Icons.psychology,
                    title: "AI Reasoning",
                    subtitle:
                        "Transparent insights for ethical choices.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // -------------------- BOTTOM NAV --------------------
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF8F7F6),
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: _NavItem(icon: Icons.home, label: "Home", active: true)),
              const Expanded(child: _NavItem(icon: Icons.checkroom, label: "Wardrobe")),
              const SizedBox(width: 40),
              const Expanded(child: _NavItem(icon: Icons.people, label: "Partners")),
              const Expanded(child: _NavItem(icon: Icons.account_circle, label: "Profile")),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF602D08),
        elevation: 6,
        onPressed: () {},
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// -------------------- WIDGETS --------------------

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String tag;
  final String buttonText;
  final VoidCallback? onPressed;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tag,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(description,
                      style: const TextStyle(color: Color(0xFF9A6C4C))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tag,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF602D08))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF602D08),
                        ),
                        onPressed: onPressed ?? () {},
                        child: Text(buttonText),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDEA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Color(0xFF602D08)),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF9A6C4C))),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF602D08), size: 24),
        const SizedBox(height: 4),
        Text(label, 
          style: const TextStyle(fontSize: 11, color: Color(0xFF602D08)),
        ),
      ],
    );
  }
}
