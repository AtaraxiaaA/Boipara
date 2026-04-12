import 'package:flutter/material.dart';

/// YourPostsPage - Placeholder page for user's listings
/// TODO: Implement full functionality later
class YourPostsPage extends StatelessWidget {
  const YourPostsPage({super.key});

  // Theme colors matching app palette
  static const Color darkBrown = Color(0xFF613613);
  static const Color backgroundColor = Color(0xFFF5F0E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkBrown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Posts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            fontSize: 18,
            color: darkBrown,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
