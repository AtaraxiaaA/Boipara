import 'package:flutter/material.dart';
import 'buy_books_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  static const brown = Color(0xFF613613);
  static const mediumBrown = Color(0xFF7C4700);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  // Placeholder wishlist — replace with API later
  final List<Map<String, dynamic>> _wishlist = [
    {
      'id': 1,
      'title': 'The Alchemist',
      'author': 'Paulo Coelho',
      'askingPrice': 350,
      'buyingPrice': 700,
      'condition': 'Like New',
      'seller': 'Rafi Ahmed',
      'location': 'Dhanmondi, Dhaka',
      'addedDate': 'Mar 8, 2026',
      'available': true,
    },
    {
      'id': 2,
      'title': 'Misir Ali Omnibus',
      'author': 'Humayun Ahmed',
      'askingPrice': 380,
      'buyingPrice': 650,
      'condition': 'Good',
      'seller': 'Imran Khan',
      'location': 'Mirpur, Dhaka',
      'addedDate': 'Mar 6, 2026',
      'available': true,
    },
    {
      'id': 3,
      'title': 'Lalsalu',
      'author': 'Syed Waliullah',
      'askingPrice': 220,
      'buyingPrice': 400,
      'condition': 'Acceptable',
      'seller': 'Nabil Hossain',
      'location': 'Uttara, Dhaka',
      'addedDate': 'Mar 2, 2026',
      'available': false,
    },
    {
      'id': 4,
      'title': 'Aranyak',
      'author': 'Bibhutibhushan Bandyopadhyay',
      'askingPrice': 260,
      'buyingPrice': 500,
      'condition': 'Good',
      'seller': 'Sadia Rahman',
      'location': 'Gulshan, Dhaka',
      'addedDate': 'Feb 28, 2026',
      'available': true,
    },
  ];

  void _removeFromWishlist(int id) {
    setState(() => _wishlist.removeWhere((b) => b['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from wishlist'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'Like New':
        return const Color(0xFF059669);
      case 'Good':
        return const Color(0xFF0E7490);
      case 'Acceptable':
        return const Color(0xFFB45309);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (_wishlist.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Clear Wishlist',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text('Remove all books from your wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _wishlist.clear());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
        ],
      ),
      body: _wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your wishlist is empty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Books you save will appear here',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyBooksScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text(
                      'Browse Books',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_wishlist.length} saved book${_wishlist.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_wishlist.where((b) => b['available'] == true).length} available',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _wishlist.length,
                    itemBuilder: (context, index) =>
                        _buildWishlistCard(_wishlist[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWishlistCard(Map<String, dynamic> book) {
    final conditionColor = _conditionColor(book['condition']);
    final isAvailable = book['available'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Stack(
              children: [
                Container(
                  width: 68,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        brown.withValues(alpha: isAvailable ? 0.15 : 0.06),
                        mediumBrown.withValues(
                          alpha: isAvailable ? 0.08 : 0.04,
                        ),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: brown.withValues(alpha: isAvailable ? 0.4 : 0.2),
                    size: 32,
                  ),
                ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Sold',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isAvailable
                                ? Colors.black87
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      // Remove button
                      GestureDetector(
                        onTap: () => _removeFromWishlist(book['id']),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book['author'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),

                  // Condition badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: conditionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      book['condition'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: conditionColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        '৳${book['askingPrice']}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isAvailable
                              ? accentOrange
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '৳${book['buyingPrice']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Seller & location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          book['location'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Buy button (only if available)
                  if (isAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Connect to backend
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Order placed for "${book['title']}"!',
                              ),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                  if (!isAvailable)
                    Text(
                      'This book has been sold',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
