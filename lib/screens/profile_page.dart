import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'my_listed_books_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'transaction_history_screen.dart';
import 'payment_methods_screen.dart';
import 'my_book_clubs_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'admin_screen.dart';
import 'settings_screen.dart';
import 'track_delivery_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const green = Color(0xFF2D5A27);
  static const darkBrown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);

  // ── ADMIN UIDs — add more UIDs here when needed ──────────────
  static const _adminUids = [
    'ej8fi1fN0JQsjgaOFVpWCa8KUTI2', // Towsif
    // 'PARTNER_UID_HERE',            // Partner (add later)
  ];

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isAdmin = false; // ← NEW

  int _booksSold = 0;
  int _booksBought = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ── Check if current user is admin ───────────────────────
      final isAdmin = _adminUids.contains(user.uid);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() => _userData = doc.data());
      } else {
        setState(() {
          _userData = {
            'username':
                user.displayName ?? _usernameFromEmail(user.email ?? ''),
            'email': user.email ?? '',
            'profilePhoto': user.photoURL ?? '',
          };
        });
      }

      final db = FirebaseFirestore.instance;
      final uid = user.uid;

      final soldQuery = await db
          .collection('orders')
          .where('sellerId', isEqualTo: uid)
          .where('status', isEqualTo: 'delivered')
          .get();

      final boughtQuery = await db
          .collection('orders')
          .where('buyerId', isEqualTo: uid)
          .where('status', isEqualTo: 'delivered')
          .get();

      if (mounted) {
        setState(() {
          _booksSold = soldQuery.docs.length;
          _booksBought = boughtQuery.docs.length;
          _isAdmin = isAdmin; // ← set admin flag
        });
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _usernameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    return email.split('@').first;
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: darkBrown),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _userData?['username'] ?? 'User';
    final email = _userData?['email'] ?? '';
    final photoUrl = _userData?['profilePhoto'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F1),
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: green))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Profile Header ───────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                            _loadUserData();
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: const Color(0xFF4A7C43),
                                  backgroundImage: photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl.isEmpty
                                      ? Text(
                                          username.isNotEmpty
                                              ? username[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: accentOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),

                        // ── Admin badge ──────────────────────
                        if (_isAdmin) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: darkBrown,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(_booksSold.toString(), 'Books Sold'),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white30,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                            ),
                            _buildStatItem(
                              _booksBought.toString(),
                              'Books Bought',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white30,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                            ),
                            _buildStatItem('—', 'Rating'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // My Account
                        _buildSectionTitle('My Account'),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.book_rounded,
                          title: 'My Listed Books',
                          subtitle: 'View and manage your listings',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyListedBooksScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.shopping_bag_rounded,
                          title: 'My Orders',
                          subtitle: 'Track your purchases',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TrackDeliveryScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.shopping_cart_rounded,
                          title: 'My Cart',
                          subtitle: 'Books you added to cart',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WishlistScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.history_rounded,
                          title: 'Transaction History',
                          subtitle: 'View past transactions',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TransactionHistoryScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Payment
                        _buildSectionTitle('Payment'),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Payment Methods',
                          subtitle: 'bKash, Nagad, Bank Account',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentMethodsScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.receipt_long_rounded,
                          title: 'Earnings',
                          subtitle: 'View your seller earnings',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TransactionHistoryScreen(initialTab: 1),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Book Clubs
                        _buildSectionTitle('Book Clubs'),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.groups_rounded,
                          title: 'My Book Clubs',
                          subtitle: 'Clubs you\'ve joined',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyBookClubsScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Settings
                        _buildSectionTitle('Settings'),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          subtitle: 'Update your information',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                            _loadUserData();
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Addresses',
                          subtitle: 'Manage delivery addresses',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressesScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'All Settings',
                          subtitle: 'Privacy, security, app preferences',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'FAQs and contact support',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Admin Panel — ONLY visible to admins ──
                        if (_isAdmin) ...[
                          _buildSectionTitle('Administration'),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Admin Panel',
                            subtitle: 'Manage orders, books & users',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminScreen(),
                              ),
                            ),
                            isAdmin: true,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Logout
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: green,
    ),
  );

  Widget _buildStatItem(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
    ],
  );

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isAdmin = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xFF613613).withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isAdmin
            ? Border.all(color: const Color(0xFF613613).withValues(alpha: 0.15))
            : null,
        boxShadow: isAdmin
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAdmin
                ? const Color(0xFF613613).withValues(alpha: 0.1)
                : green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isAdmin ? const Color(0xFF613613) : green,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
