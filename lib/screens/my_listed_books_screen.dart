import 'package:flutter/material.dart';

class MyListedBooksScreen extends StatefulWidget {
  const MyListedBooksScreen({super.key});

  @override
  State<MyListedBooksScreen> createState() => _MyListedBooksScreenState();
}

class _MyListedBooksScreenState extends State<MyListedBooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const brown = Color(0xFF613613);
  static const mediumBrown = Color(0xFF7C4700);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  // Placeholder listings — replace with API later
  final List<Map<String, dynamic>> _listings = [
    {
      'id': 1,
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'askingPrice': 420,
      'buyingPrice': 600,
      'condition': 'Good',
      'edition': '2nd Edition',
      'status': 'Active',
      'postedDate': 'Mar 7, 2026',
      'views': 24,
      'interested': 3,
    },
    {
      'id': 2,
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'askingPrice': 500,
      'buyingPrice': 900,
      'condition': 'Like New',
      'edition': '1st Edition',
      'status': 'Active',
      'postedDate': 'Mar 5, 2026',
      'views': 41,
      'interested': 7,
    },
    {
      'id': 3,
      'title': 'Pather Panchali',
      'author': 'Bibhutibhushan',
      'askingPrice': 200,
      'buyingPrice': 400,
      'condition': 'Acceptable',
      'edition': 'Classic Edition',
      'status': 'Sold',
      'postedDate': 'Feb 20, 2026',
      'views': 58,
      'interested': 12,
    },
    {
      'id': 4,
      'title': 'Himu',
      'author': 'Humayun Ahmed',
      'askingPrice': 150,
      'buyingPrice': 300,
      'condition': 'Acceptable',
      'edition': '',
      'status': 'Pending Verification',
      'postedDate': 'Mar 10, 2026',
      'views': 5,
      'interested': 0,
    },
    {
      'id': 5,
      'title': '1984',
      'author': 'George Orwell',
      'askingPrice': 280,
      'buyingPrice': 500,
      'condition': 'Good',
      'edition': 'Revised Edition',
      'status': 'Sold',
      'postedDate': 'Feb 10, 2026',
      'views': 73,
      'interested': 15,
    },
  ];

  List<Map<String, dynamic>> get _active => _listings
      .where(
        (b) => b['status'] == 'Active' || b['status'] == 'Pending Verification',
      )
      .toList();
  List<Map<String, dynamic>> get _sold =>
      _listings.where((b) => b['status'] == 'Sold').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF059669);
      case 'Sold':
        return const Color(0xFF7C3AED);
      case 'Pending Verification':
        return const Color(0xFFB45309);
      default:
        return Colors.grey;
    }
  }

  void _confirmDelete(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Listing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Remove "${book['title']}" from your listings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(
                () => _listings.removeWhere((b) => b['id'] == book['id']),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing removed'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          'My Listed Books',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentOrange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: 'Active (${_active.length})'),
            Tab(text: 'Sold (${_sold.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_active, showActions: true),
          _buildList(_sold, showActions: false),
        ],
      ),
    );
  }

  Widget _buildList(
    List<Map<String, dynamic>> books, {
    required bool showActions,
  }) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              showActions ? 'No active listings' : 'No sold books yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              showActions
                  ? 'Tap "Sell a Book" to list one'
                  : 'Your sold books will appear here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) =>
          _buildBookCard(books[index], showActions: showActions),
    );
  }

  Widget _buildBookCard(
    Map<String, dynamic> book, {
    required bool showActions,
  }) {
    final conditionColor = _conditionColor(book['condition']);
    final statusColor = _statusColor(book['status']);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover
                Container(
                  width: 64,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        brown.withValues(alpha: 0.15),
                        mediumBrown.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: brown.withValues(alpha: 0.4),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              book['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              book['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        book['author'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Condition + edition
                      Row(
                        children: [
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
                          if (book['edition'] != '') ...[
                            const SizedBox(width: 6),
                            Text(
                              book['edition'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          Text(
                            '৳${book['askingPrice']}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: accentOrange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '৳${book['buyingPrice']} original',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Stats & actions row
            Row(
              children: [
                // Views
                Icon(
                  Icons.visibility_outlined,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  '${book['views']} views',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 14),

                // Interested
                Icon(
                  Icons.people_outline_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  '${book['interested']} interested',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 14),

                // Posted date
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  book['postedDate'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),

                const Spacer(),

                // Actions
                if (showActions) ...[
                  // Edit
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to edit listing screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit listing — coming soon!'),
                          backgroundColor: brown,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: brown.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: brown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete
                  GestureDetector(
                    onTap: () => _confirmDelete(book),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
