import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_club_page.dart';
import 'clubs_list_screen.dart';

class MyBookClubsScreen extends StatefulWidget {
  const MyBookClubsScreen({super.key});
  @override
  State<MyBookClubsScreen> createState() => _MyBookClubsScreenState();
}

class _MyBookClubsScreenState extends State<MyBookClubsScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Color _toColor(dynamic v) {
    if (v is int) return Color(v);
    if (v is Color) return v;
    return brown;
  }

  IconData _toIcon(dynamic v) {
    if (v is int) return IconData(v, fontFamily: 'MaterialIcons');
    if (v is IconData) return v;
    return Icons.menu_book_rounded;
  }

  // ── Leave club ────────────────────────────────────────────────────────
  void _leaveClub(String clubId, String clubName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Leave Club',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to leave "$clubName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('clubs')
                  .doc(clubId)
                  .collection('members')
                  .doc(_uid)
                  .delete();
              await FirebaseFirestore.instance
                  .collection('clubs')
                  .doc(clubId)
                  .update({'memberCount': FieldValue.increment(-1)});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You have left the club'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
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
          'My Book Clubs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClubsListScreen()),
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text(
              'Join More',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
      // ── Stream: all clubs where this user is a member ─────────────────
      body: StreamBuilder<QuerySnapshot>(
        // We query all clubs, then filter by membership in the card.
        // Better approach: collectionGroup query on 'members' where uid == _uid
        stream: FirebaseFirestore.instance
            .collectionGroup('members')
            .where('uid', isEqualTo: _uid)
            .snapshots(),
        builder: (context, memberSnap) {
          if (memberSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brown));
          }
          final memberDocs = memberSnap.data?.docs ?? [];
          if (memberDocs.isEmpty) return _emptyState();

          // Get club IDs from the member docs
          final clubIds = memberDocs
              .map((d) => d.reference.parent.parent!.id)
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubIds.length,
            itemBuilder: (context, index) {
              final clubId = clubIds[index];
              final memberData =
                  memberDocs[index].data() as Map<String, dynamic>;
              final role = memberData['role'] ?? 'member';
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clubs')
                    .doc(clubId)
                    .snapshots(),
                builder: (context, clubSnap) {
                  if (!clubSnap.hasData) return const SizedBox.shrink();
                  final club = clubSnap.data?.data() as Map<String, dynamic>?;
                  if (club == null) return const SizedBox.shrink();
                  final color = _toColor(club['color']);
                  final icon = _toIcon(club['icon']);
                  return _buildClubCard(
                    clubId: clubId,
                    club: club,
                    color: color,
                    icon: icon,
                    role: role,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.groups_outlined, size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          'No clubs joined yet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join a book club to start discussing',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClubsListScreen()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: brown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.search_rounded),
          label: const Text(
            'Browse Clubs',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Widget _buildClubCard({
    required String clubId,
    required Map<String, dynamic> club,
    required Color color,
    required IconData icon,
    required String role,
  }) {
    final isModerator = role == 'Moderator';
    final isAdmin = role == 'admin';
    final memberCount = club['memberCount'] ?? 0;
    final currentBook = club['currentlyReading'] ?? '';
    final nextEvent = club['nextEvent'] ?? '';
    // For unread posts we stream the posts count — simplified to show badge
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookClubPage(
            clubId: clubId,
            clubName: club['clubName'] ?? '',
            university: club['university'] ?? '',
            color: color,
            icon: icon,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Colored top bar — unchanged
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row — unchanged layout
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club['clubName'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              club['university'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Role badge — unchanged
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? color.withValues(alpha: 0.15)
                              : isModerator
                              ? accentOrange.withValues(alpha: 0.12)
                              : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAdmin
                              ? 'Admin'
                              : isModerator
                              ? 'Moderator'
                              : 'Member',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isModerator ? accentOrange : color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Stats — unchanged layout
                  Row(
                    children: [
                      _statChip(
                        Icons.people_outline_rounded,
                        '${_formatCount(memberCount)} members',
                        Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Current book & next meeting — unchanged layout
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Currently Reading',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentBook.isEmpty ? '—' : currentBook,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Event',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextEvent.isEmpty ? '—' : nextEvent,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom action row — unchanged layout
                  Row(
                    children: [
                      // Live unread posts badge
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('clubs')
                            .doc(clubId)
                            .collection('posts')
                            .orderBy('createdAt', descending: true)
                            .limit(20)
                            .snapshots(),
                        builder: (context, postsSnap) {
                          final count = postsSnap.data?.docs.length ?? 0;
                          if (count == 0)
                            return Text(
                              'No new posts',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            );
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: accentOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 13,
                                  color: accentOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$count posts',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      // Leave button — unchanged style
                      GestureDetector(
                        onTap: () => _leaveClub(clubId, club['clubName'] ?? ''),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Leave',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
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
  }

  Widget _statChip(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: Colors.grey.shade400),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ],
  );
}
