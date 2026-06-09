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

  // ── Leave club ────────────────────────────────────────────────────────────
  Future<void> _leaveClub(String clubId, String clubName) async {
    final confirmed = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(clubId)
          .collection('members')
          .doc(_uid)
          .delete();
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).update({
        'memberCount': FieldValue.increment(-1),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have left the club'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: const Center(child: Text('Please log in to view your clubs')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      // Strategy: stream ALL clubs, then for each club check if
      // clubs/{clubId}/members/{uid} exists. This avoids the
      // collectionGroup index requirement entirely.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, allClubsSnap) {
          if (allClubsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brown));
          }

          if (allClubsSnap.hasError) {
            return Center(child: Text('Error: ${allClubsSnap.error}'));
          }

          final allDocs = allClubsSnap.data?.docs ?? [];

          if (allDocs.isEmpty) {
            return _emptyState();
          }

          // For each club, stream the member doc for this user.
          // Only render the card if the member doc exists.
          return _MemberClubList(
            uid: _uid,
            allClubDocs: allDocs,
            toColor: _toColor,
            toIcon: _toIcon,
            formatCount: _formatCount,
            onLeave: _leaveClub,
            backgroundColor: backgroundColor,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
}

// ── Renders only clubs the user has joined ────────────────────────────────────
// Uses one StreamBuilder per club to check membership, then shows only joined ones.
class _MemberClubList extends StatelessWidget {
  final String uid;
  final List<QueryDocumentSnapshot> allClubDocs;
  final Color Function(dynamic) toColor;
  final IconData Function(dynamic) toIcon;
  final String Function(int) formatCount;
  final Future<void> Function(String, String) onLeave;
  final Color backgroundColor;

  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);

  const _MemberClubList({
    required this.uid,
    required this.allClubDocs,
    required this.toColor,
    required this.toIcon,
    required this.formatCount,
    required this.onLeave,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allClubDocs.length,
      itemBuilder: (context, i) {
        final doc = allClubDocs[i];
        final clubId = doc.id;
        final data = doc.data() as Map<String, dynamic>;

        // Stream the member doc — renders only if exists
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('clubs')
              .doc(clubId)
              .collection('members')
              .doc(uid)
              .snapshots(),
          builder: (context, memberSnap) {
            // Not joined → render nothing
            if (!memberSnap.hasData) return const SizedBox.shrink();
            if (!(memberSnap.data?.exists ?? false)) {
              return const SizedBox.shrink();
            }

            final memberData =
                memberSnap.data!.data() as Map<String, dynamic>? ?? {};
            final role = memberData['role'] as String? ?? 'member';
            final color = toColor(data['color']);
            final icon = toIcon(data['icon']);

            return _MyClubCard(
              clubId: clubId,
              club: data,
              color: color,
              icon: icon,
              role: role,
              uid: uid,
              formatCount: formatCount,
              onLeave: onLeave,
              backgroundColor: backgroundColor,
            );
          },
        );
      },
    );
  }
}

// ── Single club card ──────────────────────────────────────────────────────────
class _MyClubCard extends StatelessWidget {
  final String clubId;
  final Map<String, dynamic> club;
  final Color color;
  final IconData icon;
  final String role;
  final String uid;
  final String Function(int) formatCount;
  final Future<void> Function(String, String) onLeave;
  final Color backgroundColor;

  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);

  const _MyClubCard({
    required this.clubId,
    required this.club,
    required this.color,
    required this.icon,
    required this.role,
    required this.uid,
    required this.formatCount,
    required this.onLeave,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    final isModerator = role == 'Moderator';
    final memberCount = (club['memberCount'] as num?)?.toInt() ?? 0;
    final clubName = club['clubName'] as String? ?? '';
    final university = club['university'] as String? ?? '';

    // Currently reading: try list first, then string field
    String currentBook = '—';
    final cr = club['currentlyReading'];
    if (cr is List && cr.isNotEmpty) {
      currentBook = cr.first.toString();
    } else if (cr is String && cr.isNotEmpty) {
      currentBook = cr;
    }

    // Next event from events subcollection — shown via stream below
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookClubPage(
            clubId: clubId,
            clubName: clubName,
            university: university,
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
            // Colored top bar
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
                  // ── Header row ─────────────────────────────────────────
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
                              clubName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              university,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Role badge
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

                  // ── Member count ───────────────────────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${formatCount(memberCount)} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Currently reading + next event ─────────────────────
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
                                currentBook,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        // Next event from subcollection
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('clubs')
                                .doc(clubId)
                                .collection('events')
                                .orderBy('date', descending: false)
                                .limit(1)
                                .snapshots(),
                            builder: (context, evSnap) {
                              String nextEvent = '—';
                              if (evSnap.hasData &&
                                  evSnap.data!.docs.isNotEmpty) {
                                final ev =
                                    evSnap.data!.docs.first.data()
                                        as Map<String, dynamic>;
                                nextEvent = ev['title'] as String? ?? '—';
                              }
                              return Column(
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
                                    nextEvent,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Bottom row: post count + leave ─────────────────────
                  Row(
                    children: [
                      // Live post count badge
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
                          if (count == 0) {
                            return Text(
                              'No posts yet',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            );
                          }
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
                      // Leave button
                      GestureDetector(
                        onTap: () => onLeave(clubId, clubName),
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
}
