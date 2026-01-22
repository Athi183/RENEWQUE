import 'package:flutter/material.dart';

class PartnerBoutiquesPage extends StatelessWidget {
  const PartnerBoutiquesPage({super.key});

  static const primaryColor = Color(0xFF602D08);
  static const darkText = Color(0xFF1B130D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {},
        child: const Icon(Icons.map, color: Colors.white),
      ),
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _searchBar(),
            _filters(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _featuredSection(),
                    _localArtisans(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔝 Top App Bar
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios, color: primaryColor),
          const Spacer(),
          const Text(
            'Partner Boutiques',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none, color: primaryColor),
        ],
      ),
    );
  }

  // 🔍 Search Bar
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search mending, upcycling, or tailors',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🏷 Filters
  Widget _filters() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip('Near Me', selected: true),
          _chip('Mending'),
          _chip('Upcycling'),
          _chip('Price'),
        ],
      ),
    );
  }

  Widget _chip(String label, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        backgroundColor: selected ? primaryColor : Colors.white,
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ⭐ Featured Section
  Widget _featuredSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Featured Upcyclers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _featuredCard(
                'The Denim Lab',
                'Reconstructed Denim',
                '\$\$\$',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDHqfIcDtIR4vVLjqDGtD1i9rfSNBk1K9avYzCn_acPDEYrulX1gAitd6ZeDBG7NxwIfIZd-cdqlFitCvqlK46A0-3r2gMfzYzSSs41X8bKuY_ka6U9xA_iCOm4TZccmS0Jd6G004c92piZq9R1h36Mo_xzwf5GZj-QLfKLbTfzFRjYFYheqW75TiP62mO6VET44oqf1UTjHN62-Qhcl0g6o1iGn0KmhFOHgqZ_B3bJ9OBEsJvDaMWFwMLHZSOe2PNaNWUi1pIf_7k',
              ),
              _featuredCard(
                'Green Stitch Studio',
                'Invisible Mending',
                '\$\$',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD0ft6g3X31bCWpVyx2BIvZKJuOFeE6NY4UOWUxiUofWFql_8WNNw8nbVkGy65r1KMSh_ivP3nRJr7bih4eTlFlRBDtVULBdyaBKsd4wUfVpUrKWlKMoegXW8wAhvdsuZsi5dqreuEpPEEd3vmHFKYMT8ZnmjAoVZv5NEmd_x0mXTDJjgzf5VgPTHtP6HPPEfH-9rAvWRqC-m0iys_YpoLP7UuqyG181u3o5kypeAPGqQ41GvH_wDHxRBWUKLWoLERmA8I6eW1yxRs',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featuredCard(
    String title,
    String subtitle,
    String price,
    String image,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(color: primaryColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 📍 Local Artisans
  Widget _localArtisans() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local Artisans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _artisanTile('Ethical Alterations', '4.9', '\$\$'),
          _artisanTile('Old Soul Repair Shop', '4.8', '\$'),
          _artisanTile('Modern Menders', '4.7', '\$\$'),
        ],
      ),
    );
  }

  Widget _artisanTile(String name, String rating, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Rating $rating  •  $price',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⬇ Bottom Navigation
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Closet'),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront),
          label: 'Partners',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Impact'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
