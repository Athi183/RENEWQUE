import 'package:flutter/material.dart';
import 'home.dart';
import 'partner_boutiques.dart';

class PrelovedPage extends StatefulWidget {
  const PrelovedPage({super.key});

  @override
  State<PrelovedPage> createState() => _PrelovedPageState();
}

class _PrelovedPageState extends State<PrelovedPage> {
  String selectedCategory = 'All';
  String selectedCondition = 'All';
  RangeValues priceRange = const RangeValues(0, 5000);
  final List<String> categories = ['All', 'Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Accessories'];

  // Sample data - Replace with actual API data later
  final List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'Vintage Denim Jacket',
      'price': 899,
      'condition': 'Good',
      'category': 'Outerwear',
      'size': 'M',
      'imageUrl': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800',
      'seller': 'Sarah M.',
    },
    {
      'id': '2',
      'name': 'Floral Summer Dress',
      'price': 1299,
      'condition': 'Excellent',
      'category': 'Dresses',
      'size': 'S',
      'imageUrl': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800',
      'seller': 'Emma K.',
    },
    {
      'id': '3',
      'name': 'Black Leather Boots',
      'price': 1599,
      'condition': 'Good',
      'category': 'Accessories',
      'size': '7',
      'imageUrl': 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=800',
      'seller': 'Mike R.',
    },
    {
      'id': '4',
      'name': 'White Cotton Blouse',
      'price': 699,
      'condition': 'Excellent',
      'category': 'Tops',
      'size': 'M',
      'imageUrl': 'https://images.unsplash.com/photo-1618932260643-eee4a2f652a6?w=800',
      'seller': 'Lisa T.',
    },
    {
      'id': '5',
      'name': 'High-Waist Jeans',
      'price': 899,
      'condition': 'Good',
      'category': 'Bottoms',
      'size': '30',
      'imageUrl': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800',
      'seller': 'Alex P.',
    },
    {
      'id': '6',
      'name': 'Silk Scarf',
      'price': 399,
      'condition': 'Excellent',
      'category': 'Accessories',
      'size': 'One Size',
      'imageUrl': 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=800',
      'seller': 'Nina S.',
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((p) {
      final categoryMatch = selectedCategory == 'All' || p['category'] == selectedCategory;
      final conditionMatch = selectedCondition == 'All' || p['condition'] == selectedCondition;
      final priceMatch = p['price'] >= priceRange.start && p['price'] <= priceRange.end;
      return categoryMatch && conditionMatch && priceMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      
      // -------------------- BODY --------------------
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            const SizedBox(height: 8),

            // Category Filter Chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      selectedColor: const Color(0xFF602D08),
                      backgroundColor: const Color(0xFFF0EDEA),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF602D08),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Product Grid
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Color(0xFF9A6C4C),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No items in this category',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9A6C4C),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _ProductCard(
                          product: filteredProducts[index],
                          onTap: () => _showProductDetail(filteredProducts[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
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

  // -------------------- TOP BAR --------------------
  Widget _topBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1B130D)),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Marketplace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B130D),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isCompact
                      ? IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF602D08)),
                          onPressed: _showSellOptionsSheet,
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF602D08),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onPressed: _showSellOptionsSheet,
                          icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
                          label: const Text(
                            'Sell',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Color(0xFF602D08)),
                    onPressed: _showFilterBottomSheet,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF602D08)),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------- BOTTOM NAV --------------------
  Widget _bottomNav() {
    return BottomAppBar(
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.checkroom,
                label: "Wardrobe",
                onTap: () => _showComingSoon(context),
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: _NavItem(
                icon: Icons.people,
                label: "Partners",
                active: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PartnerBoutiquesPage()),
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.account_circle,
                label: "Profile",
                onTap: () => _showComingSoon(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon'),
        backgroundColor: Color(0xFF602D08),
      ),
    );
  }

  void _showSellOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F7F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How would you like to sell?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B130D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your preferred selling method',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9A6C4C),
                ),
              ),
              const SizedBox(height: 24),

              // Option 1: List Yourself
              _SellOptionCard(
                icon: Icons.edit,
                title: 'List It Yourself',
                description: 'Upload details and manage your listing. Verification required.',
                color: const Color(0xFF602D08),
                onTap: () {
                  Navigator.pop(context);
                  _showSelfListingForm();
                },
              ),

              const SizedBox(height: 12),

              // Option 2: Ship to Us
              _SellOptionCard(
                icon: Icons.local_shipping,
                title: 'Ship to Us',
                description: 'Send us your item and we\'ll handle everything for you.',
                color: const Color(0xFF9A6C4C),
                onTap: () {
                  Navigator.pop(context);
                  _showShipToUsForm();
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSelfListingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SelfListingFormSheet(),
    );
  }

  void _showShipToUsForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ShipToUsFormSheet(),
    );
  }

  void _showFilterBottomSheet() {
    // Temporary variables to hold state while in the sheet
    String tempCondition = selectedCondition;
    RangeValues tempPrice = priceRange;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F7F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B130D),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempCondition = 'All';
                            tempPrice = const RangeValues(0, 5000);
                          });
                        },
                        child: const Text('Reset', style: TextStyle(color: Color(0xFF9A6C4C))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Condition Filter
                  const Text(
                    'Condition',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF602D08),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Excellent', 'Good', 'Fair'].map((condition) {
                      final isSelected = tempCondition == condition;
                      return ChoiceChip(
                        label: Text(condition),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            tempCondition = condition;
                          });
                        },
                        selectedColor: const Color(0xFF602D08),
                        backgroundColor: const Color(0xFFF0EDEA),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF602D08),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Price Range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF602D08),
                        ),
                      ),
                      Text(
                        '₹${tempPrice.start.round()} - ₹${tempPrice.end.round()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: tempPrice,
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    activeColor: const Color(0xFF602D08),
                    inactiveColor: const Color(0xFFEEDCC8),
                    labels: RangeLabels('₹${tempPrice.start.round()}', '₹${tempPrice.end.round()}'),
                    onChanged: (values) {
                      setModalState(() {
                        tempPrice = values;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF602D08),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCondition = tempCondition;
                          priceRange = tempPrice;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showProductDetail(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(product: product),
    );
  }
}

// -------------------- PRODUCT CARD WIDGET --------------------
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF602D08).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: const Color(0xFFFFFDFB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFEEDCC8).withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        product['imageUrl'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF0EDEA),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Color(0xFF9A6C4C),
                            ),
                          );
                        },
                      ),
                      // Condition Badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            product['condition'].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF602D08),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'PlayfairDisplay',
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B130D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Size: ${product['size']}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Manrope',
                          color: Color(0xFF9A6C4C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${product['price']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF602D08),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF602D08).withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Color(0xFF602D08),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- PRODUCT DETAIL SHEET --------------------
class _ProductDetailSheet extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F7F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9A6C4C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product['imageUrl'],
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              // Product Name & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B130D),
                      ),
                    ),
                  ),
                  Text(
                    '₹${product['price']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF602D08),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details
              _DetailRow(
                icon: Icons.checkroom,
                label: 'Category',
                value: product['category'],
              ),
              _DetailRow(
                icon: Icons.straighten,
                label: 'Size',
                value: product['size'],
              ),
              _DetailRow(
                icon: Icons.stars,
                label: 'Condition',
                value: product['condition'],
              ),
              _DetailRow(
                icon: Icons.person,
                label: 'Seller',
                value: product['seller'],
              ),

              const SizedBox(height: 24),

              // Description Section
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B130D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gently used ${product['name'].toLowerCase()} in ${product['condition'].toLowerCase()} condition. Perfect for sustainable fashion lovers looking to add quality pieces to their wardrobe.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9A6C4C),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF602D08)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.message,
                        color: Color(0xFF602D08),
                      ),
                      label: const Text(
                        'Message',
                        style: TextStyle(
                          color: Color(0xFF602D08),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF602D08),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: const Text(
                        'Buy Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF602D08)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B130D),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9A6C4C),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- SELL OPTION CARD WIDGET --------------------
class _SellOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _SellOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EDEA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B130D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9A6C4C),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9A6C4C)),
          ],
        ),
      ),
    );
  }
}

// -------------------- SELF LISTING FORM SHEET --------------------
class _SelfListingFormSheet extends StatefulWidget {
  const _SelfListingFormSheet();

  @override
  State<_SelfListingFormSheet> createState() => _SelfListingFormSheetState();
}

class _SelfListingFormSheetState extends State<_SelfListingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  String? selectedCondition;
  String? selectedSize;
  
  final List<String> categories = ['Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Accessories'];
  final List<String> conditions = ['Excellent', 'Good', 'Fair'];
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'One Size'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F7F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9A6C4C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  'List Your Item',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B130D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fill in the details below. Your listing will be verified before going live.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9A6C4C),
                  ),
                ),
                const SizedBox(height: 24),

                // Upload Image Section
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDEA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF9A6C4C).withOpacity(0.3),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: const Color(0xFF602D08).withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload Product Images',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF602D08),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add up to 5 photos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Item Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g., Vintage Denim Jacket',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9A6C4C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  value: selectedCategory,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Size and Condition Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Size',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                          ),
                        ),
                        value: selectedSize,
                        items: sizes.map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSize = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Select size';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Condition',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                          ),
                        ),
                        value: selectedCondition,
                        items: conditions.map((condition) {
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCondition = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Select condition';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (₹)',
                    hintText: 'e.g., 999',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Description
                TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your item...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Verification Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDEA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF9A6C4C).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: const Color(0xFF602D08), size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Your listing will be reviewed and verified within 24-48 hours before going live.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF1B130D)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF602D08),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Submit form data to backend
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Listing submitted for verification!'),
                          backgroundColor: Color(0xFF602D08),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Submit for Verification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------------------- SHIP TO US FORM SHEET --------------------
class _ShipToUsFormSheet extends StatefulWidget {
  const _ShipToUsFormSheet();

  @override
  State<_ShipToUsFormSheet> createState() => _ShipToUsFormSheetState();
}

class _ShipToUsFormSheetState extends State<_ShipToUsFormSheet> {
  final _formKey = GlobalKey<FormState>();

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9A6C4C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  'Ship to Us',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B130D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Send us your items and we\'ll handle the rest!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9A6C4C),
                  ),
                ),
                const SizedBox(height: 24),

                // How it Works Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How It Works',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF602D08),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StepItem(
                        number: '1',
                        text: 'Fill in your contact details',
                      ),
                      _StepItem(
                        number: '2',
                        text: 'We\'ll send you a shipping label',
                      ),
                      _StepItem(
                        number: '3',
                        text: 'Pack and ship your items to us',
                      ),
                      _StepItem(
                        number: '4',
                        text: 'We inspect, photograph, and list them',
                      ),
                      _StepItem(
                        number: '5',
                        text: 'Get paid when items sell!',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contact Information
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B130D),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF602D08)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF602D08)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF602D08)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Pickup Address',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: Icon(Icons.location_on, color: Color(0xFF602D08)),
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Item Details
                const Text(
                  'Item Details (Optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B130D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help us prepare by sharing item details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9A6C4C),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Number of Items',
                    hintText: 'e.g., 5 pieces',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Item Description (Optional)',
                    hintText: 'Brief description of items you\'re sending...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF602D08), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Commission Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDEA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF9A6C4C).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: const Color(0xFF602D08), size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'We charge a 15% commission on sold items. You\'ll receive 85% of the sale price.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF1B130D)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF602D08),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Submit form data to backend
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request submitted! We\'ll contact you soon with shipping details.'),
                          backgroundColor: Color(0xFF602D08),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Request Shipping Label',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------------------- STEP ITEM WIDGET --------------------
class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF602D08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1B130D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- BOTTOM NAV ITEM --------------------
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
          Icon(icon, color: const Color(0xFF602D08), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF602D08)),
          ),
        ],
      ),
    );
  }
}
