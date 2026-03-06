import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D5A27),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D5A27),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
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
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF4A7C43),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE07B39),
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
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'johndoe@email.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('12', 'Books Sold'),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white30,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      _buildStatItem('8', 'Books Bought'),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white30,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      _buildStatItem('4.8', 'Rating'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A27),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.book_rounded,
                    title: 'My Listed Books',
                    subtitle: 'View and manage your listings',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_bag_rounded,
                    title: 'My Orders',
                    subtitle: 'Track your purchases',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_rounded,
                    title: 'Wishlist',
                    subtitle: 'Books you\'re interested in',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Transaction History',
                    subtitle: 'View past transactions',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A27),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Payment Methods',
                    subtitle: 'bKash, Nagad, Bank Account',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Earnings',
                    subtitle: 'View your seller earnings',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Book Clubs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A27),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.groups_rounded,
                    title: 'My Book Clubs',
                    subtitle: 'Clubs you\'ve joined',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A27),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Update your information',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                    subtitle: 'Manage delivery addresses',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQs and contact support',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Handle logout
                      },
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

  Widget _buildStatItem(String value, String label) {
    return Column(
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            color: const Color(0xFF2D5A27).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2D5A27),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
