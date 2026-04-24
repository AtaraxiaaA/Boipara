import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_club_page.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});
  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  static const brown = Color(0xFF5C2C06);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  final List<Color> _clubColors = const [
    Color(0xFF5C2C06),
    Color(0xFF1A5276),
    Color(0xFF1E8449),
    Color(0xFF7D3C98),
    Color(0xFFB7950B),
    Color(0xFFDC2626),
    Color(0xFF0E7490),
    Color(0xFFB45309),
  ];
  final List<IconData> _clubIcons = const [
    Icons.menu_book_rounded,
    Icons.auto_stories_rounded,
    Icons.library_books_rounded,
    Icons.collections_bookmark_rounded,
    Icons.bookmark_rounded,
    Icons.school_rounded,
    Icons.local_library_rounded,
    Icons.book_rounded,
  ];

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

  Future<String> _getMyName() async {
    try {
      final ud = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      return ud.data()?['username'] ??
          FirebaseAuth.instance.currentUser?.displayName ??
          'User';
    } catch (_) {
      return 'User';
    }
  }

  // ── Seed default clubs on first run if Firestore is empty ─────────────
  Future<void> _seedDefaultClubs() async {
    final snap = await FirebaseFirestore.instance
        .collection('clubs')
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) return;
    final defaults = [
      {
        'clubName': 'Dhaka Readers Circle',
        'university': 'University of Dhaka',
        'color': const Color(0xFF5C2C06),
        'icon': Icons.menu_book_rounded,
      },
      {
        'clubName': 'BUET Book Society',
        'university': 'BUET',
        'color': const Color(0xFF1A5276),
        'icon': Icons.auto_stories_rounded,
      },
      {
        'clubName': 'NSU Literary Club',
        'university': 'North South University',
        'color': const Color(0xFF1E8449),
        'icon': Icons.library_books_rounded,
      },
      {
        'clubName': 'BRAC Bibliophiles',
        'university': 'BRAC University',
        'color': const Color(0xFF7D3C98),
        'icon': Icons.collections_bookmark_rounded,
      },
      {
        'clubName': 'Chittagong Book Club',
        'university': 'University of Chittagong',
        'color': const Color(0xFFB7950B),
        'icon': Icons.bookmark_rounded,
      },
    ];
    for (final d in defaults) {
      await FirebaseFirestore.instance.collection('clubs').add({
        'clubName': d['clubName'],
        'university': d['university'],
        'color': (d['color'] as Color).toARGB32(),
        'icon': (d['icon'] as IconData).codePoint,
        'memberCount': 0,
        'createdBy': 'system',
        'currentlyReading': '',
        'nextEvent': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Join / Leave ───────────────────────────────────────────────────────
  Future<void> _toggleMembership(String clubId, bool isJoined) async {
    if (_isGuest) {
      _showSnack('Please log in to join clubs', Colors.orange);
      return;
    }
    final clubRef = FirebaseFirestore.instance.collection('clubs').doc(clubId);
    final memberRef = clubRef.collection('members').doc(_uid);
    if (isJoined) {
      await memberRef.delete();
      await clubRef.update({'memberCount': FieldValue.increment(-1)});
    } else {
      final name = await _getMyName();
      final photo = FirebaseAuth.instance.currentUser?.photoURL ?? '';
      await memberRef.set({
        'uid': _uid,
        'name': name,
        'photo': photo,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });
      await clubRef.update({'memberCount': FieldValue.increment(1)});
    }
  }

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  // ── Create Club ────────────────────────────────────────────────────────
  void _showCreateClubSheet() {
    if (_isGuest) {
      _showSnack('Please log in to create a club', Colors.orange);
      return;
    }
    final nameController = TextEditingController();
    final universityController = TextEditingController();
    Color selectedColor = _clubColors[0];
    IconData selectedIcon = _clubIcons[0];
    bool creating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Create a Book Club',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C2C06),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start a reading community',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Club Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _inputField(nameController, 'e.g. DU Literary Society'),
                const SizedBox(height: 16),

                const Text(
                  'University / Institution',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _inputField(universityController, 'e.g. University of Dhaka'),
                const SizedBox(height: 20),

                const Text(
                  'Club Color',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _clubColors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black45, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Club Icon',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _clubIcons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withValues(alpha: 0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: selectedColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? selectedColor
                              : Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: creating
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final university = universityController.text.trim();
                            if (name.isEmpty || university.isEmpty) {
                              _showSnack(
                                'Please fill in all fields',
                                Colors.redAccent,
                              );
                              return;
                            }
                            setSheetState(() => creating = true);
                            try {
                              final myName = await _getMyName();
                              final photo =
                                  FirebaseAuth.instance.currentUser?.photoURL ??
                                  '';
                              final clubRef = await FirebaseFirestore.instance
                                  .collection('clubs')
                                  .add({
                                    'clubName': name,
                                    'university': university,
                                    'color': selectedColor.toARGB32(),
                                    'icon': selectedIcon.codePoint,
                                    'memberCount': 1,
                                    'createdBy': _uid,
                                    'creatorName': myName,
                                    'currentlyReading': '',
                                    'nextEvent': '',
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                              await clubRef
                                  .collection('members')
                                  .doc(_uid)
                                  .set({
                                    'uid': _uid,
                                    'name': myName,
                                    'photo': photo,
                                    'role': 'admin',
                                    'joinedAt': FieldValue.serverTimestamp(),
                                  });
                              if (mounted) {
                                Navigator.pop(context);
                                _showSnack('"$name" created!', brown);
                              }
                            } catch (e) {
                              _showSnack('Failed: $e', Colors.redAccent);
                            } finally {
                              if (mounted)
                                setSheetState(() => creating = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C2C06),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: creating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Club',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5C2C06)),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _seedDefaultClubs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Clubs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateClubSheet,
        backgroundColor: brown,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Club',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brown));
          }
          final docs = snapshot.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 90,
            ),
            children: [
              const Text(
                'Join a community of readers',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'No clubs yet. Create the first one!',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final clubId = doc.id;
                final color = _toColor(data['color']);
                final icon = _toIcon(data['icon']);
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('clubs')
                      .doc(clubId)
                      .collection('members')
                      .doc(_uid)
                      .snapshots(),
                  builder: (context, memberSnap) {
                    final isJoined = memberSnap.data?.exists ?? false;
                    return _ClubCard(
                      clubName: data['clubName'] ?? '',
                      university: data['university'] ?? '',
                      color: color,
                      icon: icon,
                      members: data['memberCount'] ?? 0,
                      items: const [],
                      isJoined: isJoined,
                      onJoinTap: () => _toggleMembership(clubId, isJoined),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookClubPage(
                            clubId: clubId,
                            clubName: data['clubName'] ?? '',
                            university: data['university'] ?? '',
                            color: color,
                            icon: icon,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// ── Club Card — exact same UI + join button ────────────────────────────────
class _ClubCard extends StatelessWidget {
  final String clubName;
  final String university;
  final Color color;
  final List<String> items;
  final int members;
  final IconData icon;
  final bool isJoined;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;

  const _ClubCard({
    required this.clubName,
    required this.university,
    required this.color,
    required this.items,
    required this.members,
    required this.icon,
    required this.isJoined,
    required this.onTap,
    required this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
            // Colored top banner — unchanged
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
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
                        const SizedBox(height: 3),
                        Text(
                          university,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$members members',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.menu_book_outlined,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${items.length} books',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Join / Joined button
                  GestureDetector(
                    onTap: onJoinTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isJoined ? Colors.grey.shade100 : color,
                        borderRadius: BorderRadius.circular(20),
                        border: isJoined
                            ? Border.all(color: Colors.grey.shade300)
                            : null,
                      ),
                      child: Text(
                        isJoined ? 'Joined ✓' : 'Join',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isJoined ? Colors.grey.shade600 : Colors.white,
                        ),
                      ),
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
