import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'assistant_chat.dart';
import 'partner_boutiques.dart';
import 'profile.dart';
import 'risk.dart';
import 'selling.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? "User";
        });
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),

      // ── APP BAR ──
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F7F6),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuCvN50vd08Q8JJlsJOVzKXpX_uLwOMUph1xmnPWxTmj0aqU2rmvtO6zuKF39u89yqJnt03i3Nw-HIxkyp1dMwHGa2dsckEV7Vi1u-JblRBq7QGJwMWG6wya55s-qqkBOLGWjUp9eHSUsjJTZheL02w-1R9_HFIA0ZhmC7-Uu9HI6SDM-EyVZvlOGy3IRq6u7Yi7d3nTK5Lp7RfYzxSekbtg7g7vMle7ojqlmw8dur1tFq-6DYT8DkC-cU_PXapUhUkbafzAkNnQNpc",
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Welcome, $userName",
              style: const TextStyle(
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

      // ── BODY ──
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Background Decorators ──
            Stack(
              children: [
                Positioned(
                  right: -30,
                  top: 0,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF602D08).withOpacity(0.03),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -40,
                  top: 150,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA0522D).withOpacity(0.02),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _SustainabilityDashboard(userName: userName),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                      child: Text(
                        "Featured",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'PlayfairDisplay',
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B130D),
                        ),
                      ),
                    ),

                    // Spotlight Hero: Redesign My Clothing
                    _FeatureCard(
                      title: "Redesign My Clothing",
                      description:
                          "Transform your old textiles into something new and ethical. Generate AI fashion designs from photos of your existing wardrobe.",
                      imageUrl:
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuAA1hxBujIVD3B62kOf0SgmqQbIwlcGXJpJBqbohxo_z-dR5q3I_fthjQvW6Qr7_B7-LK8QzS59Fu2FkzP9h2vRdqXuw5R2P7Mrz3i_EKsJSa-Cozg62ab5n7z0hRdIv26LwaFPxozMC50B27PpSGv3z--gtYHP6ea9wOWYQERDtY_BRAZfeqDrvLNSoBbP9daOnOMpYvwLOR_cDeXi2pCSxFqpgia2MWaib4a7CTM52HGThyyUVniqMCONRNx2_ubb2ZqRX4b1bfY",
                      tag: "CORE AI",
                      buttonText: "Start Redesign",
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AssistantChatPage())),
                    ),
                  ],
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                "Explore More",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B130D),
                ),
              ),
            ),

            // Fashion Risk Analysis
            _FeatureCard(
              title: "Risk Analysis",
              description:
                  "Understand the footprint of your wardrobe. Get instant sustainability scores using our advanced AI reasoning engine.",
              imageUrl:
                  "https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=1374&auto=format&fit=crop",
              tag: "ANALYSIS",
              buttonText: "Check Risk",
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RiskPage())),
            ),

            const SizedBox(height: 16),

            // Marketplace
            _FeatureCard(
              title: "Preloved marketplace",
              description:
                  "Buy and sell verified items. Extend the lifecycle of your garments while looking your best.",
              imageUrl:
                  "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1470&auto=format&fit=crop",
              tag: "MARKET",
              buttonText: "Shop Preloved",
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrelovedPage())),
            ),

            const SizedBox(height: 16),

            // Partner Boutiques
            _FeatureCard(
              title: "Partner Boutiques",
              description:
                  "Discover local and global boutiques that prioritize ethical manufacturing and sustainable materials.",
              imageUrl:
                  "https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=1470&auto=format&fit=crop",
              tag: "BOUTIQUES",
              buttonText: "Find Boutiques",
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PartnerBoutiquesPage())),
            ),

            const SizedBox(height: 32),

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

            // ── RenewQue Eco-Hub ──
            Stack(
              children: [
                // Organic background blobs for "life"
                Positioned(
                  right: -20,
                  top: 0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF602D08).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: 0,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9A6C4C).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Tip Section
                    Builder(
                      builder: (context) {
                        final tips = [
                          "Repairing a garment extends its life by 9 months and reduces footprint by 30%.",
                          "Washing at 30°C saves up to 40% energy compared to hotter cycles.",
                          "Nearly 60% of all clothing ends up in incinerators within a year of being made.",
                          "Natural fibers like cotton and wool can take as little as 6 months to decompose.",
                        ];
                        // Using hour to pseudo-randomize daily
                        final tipIndex = DateTime.now().hour % tips.length;
                        return Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF602D08).withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.tips_and_updates_rounded,
                                        color: Color(0xFF2E7D32), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Daily Eco-Tip",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tips[tipIndex],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1B130D),
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Feature Highlights (horizontal scroll)
                    const Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 12),
                      child: Text(
                        "AI Superpowers",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B130D),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 185, // Increased height to prevent text clipping
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.none,
                        children: const [
                          _FeatureHighlight(
                            icon: Icons.analytics_rounded,
                            iconColor: Color(0xFF388E3C),
                            bgColor: Color(0xFFE8F5E9),
                            title: "Waste Risk AI",
                            subtitle: "Deep-learning analysis of fabric durability.",
                          ),
                          _FeatureHighlight(
                            icon: Icons.auto_awesome_rounded,
                            iconColor: Color(0xFF7B1FA2),
                            bgColor: Color(0xFFF3E5F5),
                            title: "AI Reasoning",
                            subtitle: "Understand the 'why' behind sustainability.",
                          ),
                          _FeatureHighlight(
                            icon: Icons.brush_rounded,
                            iconColor: Color(0xFFF9A825),
                            bgColor: Color(0xFFFFF8E1),
                            title: "Flux Design",
                            subtitle: "Professional-grade fashion redesigns.",
                          ),
                          _FeatureHighlight(
                            icon: Icons.eco_rounded,
                            iconColor: Color(0xFF2E7D32),
                            bgColor: Color(0xFFE8F5E9),
                            title: "Planetary Score",
                            subtitle: "Track your contribution to a better world.",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // ── BOTTOM NAV ──
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
              Expanded(
                  child: _NavItem(
                      icon: Icons.home,
                      label: "Home",
                      active: true,
                      onTap: () {})),
              Expanded(
                  child: _NavItem(
                      icon: Icons.checkroom,
                      label: "Wardrobe",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrelovedPage())))),
              const SizedBox(width: 40),
              Expanded(
                  child: _NavItem(
                      icon: Icons.people,
                      label: "Partners",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PartnerBoutiquesPage())))),
              Expanded(
                  child: _NavItem(
                      icon: Icons.account_circle_rounded,
                      label: "Profile",
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ProfilePage())))),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF602D08),
        elevation: 6,
        shape: const CircleBorder(),
        tooltip: "AI Redesign",
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssistantChatPage()),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ── Feature Card (supports both asset and network images) ──
class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String? imageAsset;
  final String tag;
  final String buttonText;
  final VoidCallback? onPressed;

  const _FeatureCard({
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageAsset,
    required this.tag,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imageAsset != null) {
      imageWidget = Image.asset(
        imageAsset!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    } else {
      imageWidget = Image.network(
        imageUrl ?? '',
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEEDCC8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF602D08).withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: const Color(0xFFFFF9F5), // Warm Sand/Cream color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageWidget,
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'PlayfairDisplay',
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B130D),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF602D08).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (tag.contains("AI") || tag.contains("CORE"))
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF602D08),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                tag.split(' ').first, // Shorter tag for elegance
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF602D08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF602D08),
                        height: 1.6,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF602D08),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: onPressed,
                        child: Text(
                          buttonText.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 180,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_rounded, size: 48, color: Colors.grey),
        ),
      );
}

// ── Quick Action Card (for the 2x2 grid) ──

// ── Sustainability Dashboard ──
class _SustainabilityDashboard extends StatelessWidget {
  final String userName;
  const _SustainabilityDashboard({required this.userName});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF602D08), Color(0xFF8B4513)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF602D08).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_getGreeting()}, $userName",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Sustainability Hub",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.auto_awesome, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Goal Progress
          const Text(
            "Weekly Goal: 15 Points",
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatBadge(label: "Level 4", icon: Icons.shutter_speed),
              const SizedBox(width: 12),
              _StatBadge(label: "12 Garments Saved", icon: Icons.eco),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature Highlight (premium card style for About section) ──
class _FeatureHighlight extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;

  const _FeatureHighlight({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Slightly wider for better breathing room
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0EDEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(0xFF1B130D),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9A6C4C),
                height: 1.5,
              ),
              // Removed maxLines to show full text
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Item ──
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: active
                  ? const Color(0xFF602D08)
                  : const Color(0xFF9A6C4C),
              size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
              color: active
                  ? const Color(0xFF602D08)
                  : const Color(0xFF9A6C4C),
            ),
          ),
        ],
      ),
    );
  }
}
