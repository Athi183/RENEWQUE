import 'package:flutter/material.dart';
import 'home.dart';
import 'selling.dart';

class PartnerBoutiquesPage extends StatefulWidget {
  const PartnerBoutiquesPage({super.key});

  @override
  State<PartnerBoutiquesPage> createState() => _PartnerBoutiquesPageState();
}

class _PartnerBoutiquesPageState extends State<PartnerBoutiquesPage> {
  String searchQuery = '';
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Mending', 'Upcycling', 'Tailoring'];

  static const primaryColor = Color(0xFF602D08);
  static const secondaryColor = Color(0xFF9A6C4C);
  static const darkText = Color(0xFF1B130D);
  static const bgColor = Color(0xFFF8F7F6);

  // Sample Boutique Data
  final List<Map<String, dynamic>> boutiques = [
    {
      'id': '1',
      'name': 'The Denim Lab',
      'specialty': 'Reconstructed Denim',
      'category': 'Upcycling',
      'rating': '4.9',
      'price': '₹₹₹',
      'address': '123 Baker Street, Mumbai',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDHqfIcDtIR4vVLjqDGtD1i9rfSNBk1K9avYzCn_acPDEYrulX1gAitd6ZeDBG7NxwIfIZd-cdqlFitCvqlK46A0-3r2gMfzYzSSs41X8bKuY_ka6U9xA_iCOm4TZccmS0Jd6G004c92piZq9R1h36Mo_xzwf5GZj-QLfKLbTfzFRjYFYheqW75TiP62mO6VET44oqf1UTjHN62-Qhcl0g6o1iGn0KmhFOHgqZ_B3bJ9OBEsJvDaMWFwMLHZSOe2PNaNWUi1pIf_7k',
      'website': 'https://thedenimlab.example.com',
      'phone': '+91 9876543210',
    },
    {
      'id': '2',
      'name': 'Green Stitch Studio',
      'specialty': 'Invisible Mending',
      'category': 'Mending',
      'rating': '4.8',
      'price': '₹₹',
      'address': '45 Greenway Ave, Pune',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0ft6g3X31bCWpVyx2BIvZKJuOFeE6NY4UOWUxiUofWFql_8WNNw8nbVkGy65r1KMSh_ivP3nRJr7bih4eTlFlRBDtVULBdyaBKsd4wUfVpUrKWlKMoegXW8wAhvdsuZsi5dqreuEpPEEd3vmHFKYMT8ZnmjAoVZv5NEmd_x0mXTDJjgzf5VgPTHtP6HPPEfH-9rAvWRqC-m0iys_YpoLP7UuqyG181u3o5kypeAPGqQ41GvH_wDHxRBWUKLWoLERmA8I6eW1yxRs',
      'website': 'https://greenstitch.example.com',
      'phone': '+91 9876543211',
    },
    {
      'id': '3',
      'name': 'Modern Menders',
      'specialty': 'Custom Tailoring',
      'category': 'Tailoring',
      'rating': '4.7',
      'price': '₹₹',
      'address': 'Fashion Street, Bangalore',
      'imageUrl': 'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?q=80&w=1471&auto=format&fit=crop',
      'website': 'https://modernmenders.example.com',
      'phone': '+91 9876543212',
    },
    {
      'id': '4',
      'name': 'Ethical Alterations',
      'specialty': 'Sustainable Repairs',
      'category': 'Mending',
      'rating': '4.9',
      'price': '₹₹',
      'address': 'Old Town, Delhi',
      'imageUrl': 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=1470&auto=format&fit=crop',
      'website': 'https://ethicalalt.example.com',
      'phone': '+91 9876543213',
    },
  ];

  List<Map<String, dynamic>> get filteredBoutiques {
    return boutiques.where((b) {
      final nameMatch = b['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          b['specialty'].toLowerCase().contains(searchQuery.toLowerCase());
      final categoryMatch = selectedFilter == 'All' || b['category'] == selectedFilter;
      return nameMatch && categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        elevation: 6,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening Map View...'), backgroundColor: primaryColor),
          );
        },
        child: const Icon(Icons.map_rounded, color: Colors.white),
      ),
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            _searchBar(),
            _filters(),
            Expanded(
              child: filteredBoutiques.isEmpty
                  ? _emptyState()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('Featured Upcyclers'),
                          _featuredCarousel(),
                          _sectionHeader('Local Artisans'),
                          _artisansList(),
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

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Partner Boutiques',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, color: secondaryColor),
            hintText: 'Search mending, upcycling, or tailors',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() => selectedFilter = filter);
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : darkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: isSelected ? primaryColor : Colors.transparent),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: darkText,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _featuredCarousel() {
    final featured = filteredBoutiques.where((b) => b['price'] == '₹₹₹' || b['category'] == 'Upcycling').toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final b = featured[index];
          return GestureDetector(
            onTap: () => _showBoutiqueDetail(b),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      b['imageUrl'],
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(b['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            Text(b['price'], style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(b['specialty'], style: const TextStyle(fontSize: 13, color: secondaryColor)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(b['rating'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _artisansList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredBoutiques.length,
      itemBuilder: (context, index) {
        final b = filteredBoutiques[index];
        return GestureDetector(
          onTap: () => _showBoutiqueDetail(b),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    b['imageUrl'],
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Rating ${b['rating']}  •  ${b['price']}  •  ${b['category']}',
                        style: const TextStyle(fontSize: 12, color: secondaryColor),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: secondaryColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.store_outlined, size: 64, color: secondaryColor),
          SizedBox(height: 16),
          Text(
            'No boutiques found',
            style: TextStyle(fontSize: 16, color: secondaryColor, fontWeight: FontWeight.bold),
          ),
          Text('Try a different search or filter', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _bottomNav() {
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
            _navItem(Icons.people_rounded, "Partners", active: true),
            _navItem(Icons.account_circle_rounded, "Profile", onTap: () {}),
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

  void _showBoutiqueDetail(Map<String, dynamic> boutique) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BoutiqueDetailSheet(boutique: boutique),
    );
  }
}

class _BoutiqueDetailSheet extends StatelessWidget {
  final Map<String, dynamic> boutique;
  const _BoutiqueDetailSheet({required this.boutique});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F7F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(boutique['imageUrl'], height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(boutique['name'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'PlayfairDisplay')),
                        const SizedBox(height: 4),
                        Text(boutique['specialty'], style: const TextStyle(fontSize: 16, color: Color(0xFF9A6C4C))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF602D08).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(boutique['rating'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'A premier destination for ${boutique['specialty'].toLowerCase()} and sustainable fashion. ${boutique['name']} focuses on high-quality ${boutique['category'].toLowerCase()} services to extend the life of your precious garments.',
                style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 24),
              _contactRow(Icons.location_on_rounded, boutique['address']),
              const SizedBox(height: 12),
              _contactRow(Icons.phone_rounded, boutique['phone']),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(Icons.language_rounded, 'Website', () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Website...')));
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(Icons.directions_rounded, 'Directions', () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calculating Route...')));
                    }, isPrimary: true),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9A6C4C), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: isPrimary ? Colors.white : const Color(0xFF602D08), size: 18),
      label: Text(label, style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF602D08), fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF602D08) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF602D08), width: isPrimary ? 0 : 1.5),
        ),
      ),
    );
  }
}
