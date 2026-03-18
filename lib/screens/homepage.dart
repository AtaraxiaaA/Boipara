import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sell_book_page.dart';
import 'profile_page.dart';
import 'book_club_page.dart';
import 'publish_book_page.dart';
import 'browse_screen.dart';
import 'clubs_list_screen.dart';
import 'orders_screen.dart';
import 'buy_books_screen.dart';
import 'track_delivery_screen.dart';
import 'notifications_screen.dart';

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

  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _featuredBooks = [];
  bool _loadingBooks = true;
  int _totalBooks = 0;
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFeaturedBooks();
    _loadStats();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() => _userData = doc.data());
      } else {
        setState(
          () => _userData = {
            'username':
                user.displayName ?? (user.email?.split('@').first ?? 'Reader'),
            'profilePhoto': user.photoURL ?? '',
          },
        );
      }
    } catch (_) {}
  }

  Future<void> _loadFeaturedBooks() async {
    setState(() => _loadingBooks = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .limit(6)
          .get();

      final books = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        try {
          final sellerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['sellerId'])
              .get();
          data['sellerName'] = sellerDoc.data()?['username'] ?? 'Unknown';
          data['sellerPhoto'] = sellerDoc.data()?['profilePhoto'] ?? '';
        } catch (_) {
          data['sellerName'] = 'Unknown';
          data['sellerPhoto'] = '';
        }
        books.add(data);
      }
      setState(() => _featuredBooks = books);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingBooks = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final booksSnap = await FirebaseFirestore.instance
          .collection('books')
          .where('status', isEqualTo: 'approved')
          .get();
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .get();
      setState(() {
        _totalBooks = booksSnap.docs.length;
        _totalUsers = usersSnap.docs.length;
      });
    } catch (_) {}
  }

  String get _firstName {
    final name = _userData?['username'] ?? '';
    if (name.isEmpty) return 'Reader';
    return name.split(' ').first;
  }

  String get _photoUrl => _userData?['profilePhoto'] ?? '';

  Color _conditionColor(String? condition) {
    final c = (condition ?? '').toLowerCase();
    if (c.contains('new')) return const Color(0xFF059669);
    if (c.contains('good')) return const Color(0xFF0E7490);
    return const Color(0xFFB45309);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkBrown,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Boipara',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Georgia',
              ),
            ),
          ],
        ),
        actions: [
          // Live notification badge
          IconButton(
            icon: NotificationBadge(
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(width: 4),
          // Profile avatar with real photo/initial
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
                _loadUserData();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF9A6B3C),
                  backgroundImage: _photoUrl.isNotEmpty
                      ? NetworkImage(_photoUrl)
                      : null,
                  child: _photoUrl.isEmpty
                      ? Text(
                          _firstName.isNotEmpty
                              ? _firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          await _loadFeaturedBooks();
          await _loadStats();
        },
        color: darkBrown,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLayeredWaveBanner(),
              _buildQuickActions(),
              _buildBookClubsSection(),
              _buildFeaturedBooksSection(),
              _buildNewAuthorsSection(),
              _buildHowItWorksSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) {
              setState(() => _selectedIndex = 0);
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClubsListScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: darkBrown,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_rounded),
              label: 'Clubs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Orders',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellBookPage()),
        ),
        backgroundColor: accentOrange,
        elevation: 4,
        icon: const Icon(Icons.sell_rounded, color: Colors.white),
        label: const Text(
          'Sell a Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── 3D Layered Wave Banner ─────────────────────────────────────────
  Widget _buildLayeredWaveBanner() {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(offset: 20),
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A2508), Color(0xFF613613)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(offset: 10),
              child: Container(
                height: 190,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF613613), Color(0xFF7C4700)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(offset: 0),
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C4700), Color(0xFF7E481C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // Highlight strip
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            top: 20,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_firstName! 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your Preloved Books\'\nNew Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Georgia',
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      _totalBooks > 0 ? '$_totalBooks+' : '0',
                      'Books Listed',
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      _totalUsers > 0 ? '$_totalUsers+' : '0',
                      'Happy Readers',
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard('4', 'Book Clubs'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.sell_rounded,
                  title: 'Sell a Book',
                  subtitle: 'List your preloved books',
                  color: accentOrange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SellBookPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Publish Book',
                  subtitle: 'For new authors',
                  color: mediumBrown,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PublishBookPage()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.shopping_cart_rounded,
                  title: 'Buy Books',
                  subtitle: 'Browse available books',
                  color: lightBrown,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BuyBooksScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.local_shipping_rounded,
                  title: 'Track Delivery',
                  subtitle: 'Check order status',
                  color: const Color(0xFF8B5E3C),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrackDeliveryScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ── Book Clubs ─────────────────────────────────────────────────────
  Widget _buildBookClubsSection() {
    final bookClubs = [
      {
        'name': 'NSU Book Club',
        'university': 'North South University',
        'members': '1.2K',
        'color': const Color(0xFF1E3A8A),
        'icon': Icons.school_rounded,
      },
      {
        'name': 'BRACU Readers',
        'university': 'BRAC University',
        'members': '980',
        'color': const Color(0xFF7C3AED),
        'icon': Icons.auto_stories_rounded,
      },
      {
        'name': 'AIUB Bibliophiles',
        'university': 'AIUB',
        'members': '750',
        'color': const Color(0xFF059669),
        'icon': Icons.book_rounded,
      },
      {
        'name': 'IUB Literature',
        'university': 'IUB',
        'members': '620',
        'color': const Color(0xFFDC2626),
        'icon': Icons.menu_book_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Book Clubs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClubsListScreen()),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Join discussions with fellow book lovers',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 165,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: bookClubs.length,
              itemBuilder: (context, index) {
                final club = bookClubs[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookClubPage(
                        clubName: club['name'] as String,
                        university: club['university'] as String,
                        color: club['color'] as Color,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 155,
                    margin: EdgeInsets.only(
                      right: index < bookClubs.length - 1 ? 12 : 0,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (club['color'] as Color).withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: darkBrown.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (club['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            club['icon'] as IconData,
                            color: club['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          club['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          club['university'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.people_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${club['members']} members',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured Books (real from Firebase) ───────────────────────────
  Widget _buildFeaturedBooksSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Books',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyBooksScreen()),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingBooks)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: darkBrown),
              ),
            )
          else if (_featuredBooks.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No books available yet',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to list a book!',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _featuredBooks.length,
                itemBuilder: (context, index) {
                  final book = _featuredBooks[index];
                  final condColor = _conditionColor(book['condition']);
                  final condition = book['condition'] ?? '';
                  final condShort = condition.isNotEmpty
                      ? condition.split(' ').first
                      : '';
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    ).then((_) => _loadFeaturedBooks()),
                    child: Container(
                      width: 145,
                      margin: EdgeInsets.only(
                        right: index < _featuredBooks.length - 1 ? 12 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: darkBrown.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 130,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  lightBrown.withValues(alpha: 0.15),
                                  mediumBrown.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 48,
                                color: darkBrown.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book['bookName'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  book['authorName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '৳${book['askingPrice'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: accentOrange,
                                      ),
                                    ),
                                    if (condShort.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: condColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          condShort,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: condColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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
            ),
        ],
      ),
    );
  }

  // ── New Authors ────────────────────────────────────────────────────
  Widget _buildNewAuthorsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mediumBrown.withValues(alpha: 0.1),
            lightBrown.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mediumBrown.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mediumBrown,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are You an Author?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Publish your book with us!',
                      style: TextStyle(fontSize: 13, color: mediumBrown),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'New authors can publish their books through Boipara. You handle the printing, our delivery team picks up from you and delivers to readers!',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureChip(Icons.print_rounded, 'You Print'),
              const SizedBox(width: 8),
              _buildFeatureChip(Icons.local_shipping_rounded, 'We Deliver'),
              const SizedBox(width: 8),
              _buildFeatureChip(Icons.campaign_rounded, 'We Market'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PublishBookPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: mediumBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Publish Your Book',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mediumBrown.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: mediumBrown),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: darkBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── How It Works ───────────────────────────────────────────────────
  Widget _buildHowItWorksSection() {
    final steps = [
      {
        'step': '1',
        'title': 'List Your Book',
        'description': 'Upload photos and set your price',
        'icon': Icons.camera_alt_rounded,
      },
      {
        'step': '2',
        'title': 'We Verify',
        'description': 'Admin reviews and approves listing',
        'icon': Icons.verified_rounded,
      },
      {
        'step': '3',
        'title': 'Buyer Orders',
        'description': 'You get notified instantly in-app',
        'icon': Icons.notifications_active_rounded,
      },
      {
        'step': '4',
        'title': 'Get Paid',
        'description': 'Receive payment via bKash/Nagad/Bank',
        'icon': Icons.payments_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentOrange, Color(0xFFCC6B2E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          step['step'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(step['icon'] as IconData, color: darkBrown, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave Clipper ───────────────────────────────────────────────────────
class WaveClipper extends CustomClipper<Path> {
  final double offset;
  WaveClipper({this.offset = 0});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40 - offset);
    var firstControlPoint = Offset(size.width / 4, size.height - offset);
    var firstEndPoint = Offset(size.width / 2, size.height - 30 - offset);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(
      size.width * 3 / 4,
      size.height - 60 - offset,
    );
    var secondEndPoint = Offset(size.width, size.height - 20 - offset);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
