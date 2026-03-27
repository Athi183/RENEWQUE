import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'selling.dart';
import 'partner_boutiques.dart';
import 'welcome.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const primaryColor = Color(0xFF602D08);
  static const secondaryColor = Color(0xFF9A6C4C);
  static const bgColor = Color(0xFFF8F7F6);
  static const darkText = Color(0xFF1B130D);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _topBar(context),
              _profileHeader(user),
              _impactDashboard(),
              _achievementsSection(),
              _settingsSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Impact Profile',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(User? user) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: secondaryColor.withOpacity(0.1),
                child: const Icon(Icons.person_rounded, size: 50, color: primaryColor),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? 'RenewQue Pioneer',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: darkText),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Sustainability Level: Eco-Warrior',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryColor),
          ),
        ),
      ],
    );
  }

  Widget _impactDashboard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sustainability Impact',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _impactCard('CO2 Saved', '124kg', Icons.cloud_done_rounded, Colors.blue),
              const SizedBox(width: 12),
              _impactCard('Water Saved', '450L', Icons.water_drop_rounded, Colors.cyan),
              const SizedBox(width: 12),
              _impactCard('Renewed', '18 items', Icons.recycling_rounded, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: darkText)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _achievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Your Badges',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _badgeItem('Upcycler', Icons.auto_awesome_rounded, Colors.amber),
              _badgeItem('Care Pro', Icons.wash_rounded, Colors.blue),
              _badgeItem('Market Scout', Icons.shopping_bag_rounded, Colors.deepOrange),
              _badgeItem('Thrift King', Icons.verified_rounded, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badgeItem(String label, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: darkText),
          ),
        ],
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _settingsTile(Icons.person_outline_rounded, 'Personal Information', () {}),
          _settingsTile(Icons.favorite_outline_rounded, 'Saved Boutiques', () {}),
          _settingsTile(Icons.history_rounded, 'Impact History', () {}),
          _settingsTile(Icons.help_outline_rounded, 'Support & Feedback', () {}),
          _settingsTile(Icons.logout_rounded, 'Log Out', () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomePage()),
                (route) => false,
              );
            }
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? Colors.red : secondaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : darkText,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomAppBar(
      color: bgColor,
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home_rounded, "Home", onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()))),
            _navItem(Icons.checkroom_rounded, "Market", onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrelovedPage()))),
            const SizedBox(width: 40),
            _navItem(Icons.people_rounded, "Partners", onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PartnerBoutiquesPage()))),
            _navItem(Icons.account_circle_rounded, "Profile", active: true),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool active = false, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? primaryColor : secondaryColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? primaryColor : secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
