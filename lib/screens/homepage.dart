import 'package:flutter/material.dart';
import 'sell_book_page.dart';
import 'profile_page.dart';
import 'publish_book_page.dart';
import 'buy_books_page.dart';
import 'your_posts_page.dart';
import 'search_page.dart';
import '../widgets/action_card.dart';

/// HomePage - Main landing page of the Boipara app
/// Clean, minimal design focusing on core actions
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color lightBrown = Color(0xFF7E481C);
  static const Color backgroundColor = Color(0xFFF5F0E9);
  static const Color accentOrange = Color(0xFFE07B39);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: darkBrown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Boipara',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Search button moved to top
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 26),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: accentOrange,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                    const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),

          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfilePage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF9A6B3C),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/ChatGPT%20Image%20Mar%2015%2C%202026%2C%2005_47_51%20AM-GXbXEb0j68PJ7PKZCR9UeHy6jEPxun.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          darkBrown.withOpacity(0.7),
                          Colors.transparent,
                          darkBrown.withOpacity(0.4),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        'Thrift, Trade, Sell',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your preloved books deserve a new home',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkBrown,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          icon: Icons.upload_rounded,
                          title: 'Sell a Book',
                          subtitle: 'List your preloved books',
                          color: accentOrange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const SellBookPage()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionCard(
                          icon: Icons.edit_note_rounded,
                          title: 'Publish Book',
                          subtitle: 'Publish your own book',
                          color: mediumBrown,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const PublishBookPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          icon: Icons.shopping_cart_rounded,
                          title: 'Buy Books',
                          subtitle: 'Browse and purchase books',
                          color: lightBrown,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const BuyBooksPage()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionCard(
                          icon: Icons.local_shipping_rounded,
                          title: 'Track Delivery',
                          subtitle: 'Track your orders',
                          color: const Color(0xFF8B5E3C),
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _buildAuthorProgramSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });

                if (index == 1) {
                  // Your Posts button - navigate to Your Posts page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const YourPostsPage()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BuyBooksPage()),
                  );
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: darkBrown,
              unselectedItemColor: Colors.grey,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.article_outlined),
                  activeIcon: Icon(Icons.article_rounded),
                  label: 'Your Posts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined),
                  activeIcon: Icon(Icons.groups_rounded),
                  label: 'Clubs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag_rounded),
                  label: 'Orders',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Author Publishing Program Section
  Widget _buildAuthorProgramSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkBrown,
            darkBrown.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Are You an Author?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Publish your book with Boipara and reach thousands of readers',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              _buildSupportItem(Icons.print_rounded, 'You Print'),
              const SizedBox(width: 16),
              _buildSupportItem(Icons.local_shipping_rounded, 'We Deliver'),
              const SizedBox(width: 16),
              _buildSupportItem(Icons.campaign_rounded, 'We Market'),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PublishBookPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Publish Your Book',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: accentOrange, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
