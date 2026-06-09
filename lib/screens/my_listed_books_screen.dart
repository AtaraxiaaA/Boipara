import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── Firestore status → display label ─────────────────────────────────────
  static const _statusLabel = {
    'pending_review': 'Pending Review',
    'approved': 'Active',
    'rejected': 'Rejected',
    'sold': 'Sold',
  };

  static const _statusColor = {
    'pending_review': Color(0xFFB45309),
    'approved': Color(0xFF059669),
    'rejected': Color(0xFFDC2626),
    'sold': Color(0xFF7C3AED),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${dt.day}/${dt.month}/${dt.year}';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ── Delete with Firestore ─────────────────────────────────────────────────

  Future<void> _confirmDelete(String docId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Listing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Remove "$title" from your listings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('books').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing removed'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: brown,
          foregroundColor: Colors.white,
          title: const Text(
            'My Listed Books',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: const Center(child: Text('Please log in to view your listings')),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('sellerId', isEqualTo: _uid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: _buildAppBar(0, 0, 0),
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }

        List<QueryDocumentSnapshot> allDocs = snap.data?.docs ?? [];

        // Sort newest first in client (avoids composite index requirement)
        allDocs.sort((a, b) {
          final aTime = (a.data() as Map)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map)['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        final active = allDocs
            .where(
              (d) =>
                  (d.data() as Map)['status'] == 'approved' ||
                  (d.data() as Map)['status'] == 'pending_review',
            )
            .toList();

        final sold = allDocs
            .where((d) => (d.data() as Map)['status'] == 'sold')
            .toList();

        final rejected = allDocs
            .where((d) => (d.data() as Map)['status'] == 'rejected')
            .toList();

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildAppBar(active.length, sold.length, rejected.length),
          body: snap.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator(color: brown))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(active, showDelete: true),
                    _buildList(sold, showDelete: false),
                    _buildList(rejected, showDelete: true),
                  ],
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(int active, int sold, int rejected) {
    return AppBar(
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: [
          Tab(text: 'Active ($active)'),
          Tab(text: 'Sold ($sold)'),
          Tab(text: 'Rejected ($rejected)'),
        ],
      ),
    );
  }

  // ── List builder ──────────────────────────────────────────────────────────

  Widget _buildList(
    List<QueryDocumentSnapshot> docs, {
    required bool showDelete,
  }) {
    if (docs.isEmpty) {
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
              showDelete ? 'No listings here' : 'No sold books yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              showDelete
                  ? 'Books you list will appear here'
                  : 'Your sold books will appear here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final doc = docs[i];
        final data = doc.data() as Map<String, dynamic>;
        return _BookCard(
          docId: doc.id,
          data: data,
          showDelete: showDelete,
          conditionColor: _conditionColor(data['condition'] ?? ''),
          statusLabel:
              _statusLabel[data['status']] ?? (data['status'] ?? 'Unknown'),
          statusColor: _statusColor[data['status']] ?? Colors.grey,
          timeAgo: _timeAgo(data['createdAt']),
          onDelete: () => _confirmDelete(doc.id, data['bookName'] ?? 'Book'),
        );
      },
    );
  }
}

// ── Book Card ─────────────────────────────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final bool showDelete;
  final Color conditionColor;
  final String statusLabel;
  final Color statusColor;
  final String timeAgo;
  final VoidCallback onDelete;

  static const brown = Color(0xFF613613);
  static const mediumBrown = Color(0xFF7C4700);
  static const accentOrange = Color(0xFFE07B39);

  const _BookCard({
    required this.docId,
    required this.data,
    required this.showDelete,
    required this.conditionColor,
    required this.statusLabel,
    required this.statusColor,
    required this.timeAgo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bookName = data['bookName'] as String? ?? 'Unknown Book';
    final authorName = data['authorName'] as String? ?? '';
    final edition = data['edition'] as String? ?? '';
    final condition = data['condition'] as String? ?? '';
    final listingType = data['listingType'] as String? ?? 'thrift';
    final askingPrice = (data['askingPrice'] as num?)?.toDouble() ?? 0;
    final buyingPrice = (data['buyingPrice'] as num?)?.toDouble() ?? 0;
    final category = data['category'] as String? ?? '';
    final status = data['status'] as String? ?? '';

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
            // ── Top row: book icon + info ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover placeholder
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
                    listingType == 'published'
                        ? Icons.auto_stories_rounded
                        : Icons.menu_book_rounded,
                    color: brown.withValues(alpha: 0.4),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              bookName,
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
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
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
                        authorName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Chips row: condition + edition + listingType
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (condition.isNotEmpty)
                            _chip(condition, conditionColor),
                          if (listingType == 'published')
                            _chip('Published', const Color(0xFF7C3AED)),
                          if (listingType == 'thrift')
                            _chip('Thrift', const Color(0xFF0E7490)),
                          if (category.isNotEmpty)
                            _chip(
                              category,
                              Colors.grey.shade500,
                              bg: Colors.grey.shade100,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price row
                      Row(
                        children: [
                          Text(
                            '৳${askingPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: accentOrange,
                            ),
                          ),
                          if (buyingPrice > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '৳${buyingPrice.toStringAsFixed(0)} original',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Edition
                      if (edition.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          edition,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Bottom row: posted time + actions ──────────────────────
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Posted $timeAgo',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),

                // Rejected reason hint
                if (status == 'rejected') ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Didn\'t pass review',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade300),
                  ),
                ],

                const Spacer(),

                // Delete button (active + rejected tabs only)
                if (showDelete)
                  GestureDetector(
                    onTap: onDelete,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color, {Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
