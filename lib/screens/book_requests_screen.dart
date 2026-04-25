import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookRequestsScreen extends StatefulWidget {
  const BookRequestsScreen({super.key});

  @override
  State<BookRequestsScreen> createState() => _BookRequestsScreenState();
}

class _BookRequestsScreenState extends State<BookRequestsScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  // ── Auth ──────────────────────────────────────────────────────────────
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isAnon => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
  bool get _isLoggedIn => _uid.isNotEmpty && !_isAnon;

  // ── Firestore ─────────────────────────────────────────────────────────
  CollectionReference get _postsRef =>
      FirebaseFirestore.instance.collection('book_requests');

  // ── State ─────────────────────────────────────────────────────────────
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Wanted',
    'ISO',
    'Rare Find',
    'Offering',
    'Discussion',
  ];

  static const Map<String, Color> _tagColors = {
    'Wanted': Color(0xFFDC2626),
    'ISO': Color(0xFF0E7490),
    'Rare Find': Color(0xFFB45309),
    'Offering': Color(0xFF059669),
    'Discussion': Color(0xFF7C3AED),
  };

  // Avatar colors for users who haven't set profile photo
  static const List<Color> _avatarPalette = [
    Color(0xFF1E3A8A),
    Color(0xFF059669),
    Color(0xFF7C3AED),
    Color(0xFFB45309),
    Color(0xFFDC2626),
    Color(0xFF0E7490),
  ];

  // ── Helpers ───────────────────────────────────────────────────────────
  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color _avatarColor(String uid) {
    if (uid.isEmpty) return brown;
    return _avatarPalette[uid.codeUnits.first % _avatarPalette.length];
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _requireLogin() => _showSnack('Log in to do this', Colors.orange);

  // ── Fetch current user info ───────────────────────────────────────────
  Future<Map<String, String>> _myInfo() async {
    if (_uid.isEmpty) return {'name': 'User', 'photo': '', 'initial': 'U'};
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      final name = doc.data()?['username'] as String? ?? 'User';
      final photo = doc.data()?['profilePhoto'] as String? ?? '';
      return {
        'name': name,
        'photo': photo,
        'initial': name.isNotEmpty ? name[0].toUpperCase() : 'U',
      };
    } catch (_) {
      return {'name': 'User', 'photo': '', 'initial': 'U'};
    }
  }

  // ── Like / Unlike ─────────────────────────────────────────────────────
  Future<void> _toggleLike(String postId, List likes) async {
    if (!_isLoggedIn) {
      _requireLogin();
      return;
    }
    final ref = _postsRef.doc(postId);
    if (likes.contains(_uid)) {
      await ref.update({
        'likes': FieldValue.arrayRemove([_uid]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([_uid]),
      });
    }
  }

  // ── Create post ───────────────────────────────────────────────────────
  void _showPostComposer() {
    if (!_isLoggedIn) {
      _requireLogin();
      return;
    }
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String selectedTag = 'Wanted';
    bool posting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
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
                  'New Post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 20),

                // Tag selector
                const Text(
                  'Post Type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tagColors.entries.map((e) {
                    final isSel = selectedTag == e.key;
                    return GestureDetector(
                      onTap: () => setSheet(() => selectedTag = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? e.value.withValues(alpha: 0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? e.value : Colors.grey.shade300,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          e.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSel ? e.value : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Title
                _inputField(titleCtrl, 'Book title or post headline...', 1),
                const SizedBox(height: 12),

                // Body
                _inputField(
                  bodyCtrl,
                  'Describe the book, your budget, location, condition needed...',
                  4,
                ),
                const SizedBox(height: 12),

                // Image note (Storage requires Blaze)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Photo upload available after Firebase Blaze plan upgrade.',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: posting
                        ? null
                        : () async {
                            if (titleCtrl.text.trim().isEmpty) {
                              _showSnack(
                                'Please add a title',
                                Colors.redAccent,
                              );
                              return;
                            }
                            setSheet(() => posting = true);
                            final info = await _myInfo();
                            await _postsRef.add({
                              'authorId': _uid,
                              'authorName': info['name'],
                              'authorInitial': info['initial'],
                              'authorColorValue': _avatarColor(_uid).toARGB32(),
                              'authorPhoto': info['photo'],
                              'title': titleCtrl.text.trim(),
                              'body': bodyCtrl.text.trim(),
                              'tag': selectedTag,
                              'likes': [],
                              'commentCount': 0,
                              'imageUrl': '',
                              'createdAt': DateTime.now(),
                            });
                            if (mounted) {
                              Navigator.pop(context);
                              _showSnack(
                                'Post shared! 🎉',
                                const Color(0xFF059669),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: posting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Share Post',
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

  // ── Comments sheet ────────────────────────────────────────────────────
  void _showComments(String postId, String postTitle) {
    final commentCtrl = TextEditingController();
    bool sending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: brown,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: brown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          postTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Comments stream
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _postsRef
                        .doc(postId)
                        .collection('comments')
                        .orderBy('createdAt')
                        .snapshots(),
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 52,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No comments yet',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Be the first to reply!',
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          final name = data['authorName'] as String? ?? 'User';
                          final initial =
                              data['authorInitial'] as String? ?? 'U';
                          final text = data['text'] as String? ?? '';
                          final isMe = data['authorId'] == _uid;
                          final colorVal = data['authorColorValue'] as int?;
                          final color = colorVal != null
                              ? Color(colorVal)
                              : brown;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: color.withValues(alpha: 0.2),
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? brown.withValues(alpha: 0.06)
                                              : Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: isMe
                                              ? Border.all(
                                                  color: brown.withValues(
                                                    alpha: 0.12,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: brown,
                                                  ),
                                                ),
                                                if (isMe) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 1,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: brown.withValues(
                                                        alpha: 0.1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'You',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: brown,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              text,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _timeAgo(data['createdAt']),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Input
                Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // My avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _isLoggedIn
                            ? _avatarColor(_uid)
                            : Colors.grey.shade300,
                        child: Text(
                          _isLoggedIn ? '' : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: commentCtrl,
                          onTap: () {
                            if (!_isLoggedIn) _requireLogin();
                          },
                          readOnly: !_isLoggedIn,
                          decoration: InputDecoration(
                            hintText: _isLoggedIn
                                ? 'Write a reply...'
                                : 'Log in to comment',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (!_isLoggedIn) {
                            _requireLogin();
                            return;
                          }
                          final text = commentCtrl.text.trim();
                          if (text.isEmpty || sending) return;
                          setSheet(() => sending = true);
                          final info = await _myInfo();
                          final batch = FirebaseFirestore.instance.batch();
                          final commentRef = _postsRef
                              .doc(postId)
                              .collection('comments')
                              .doc();
                          batch.set(commentRef, {
                            'authorId': _uid,
                            'authorName': info['name'],
                            'authorInitial': info['initial'],
                            'authorColorValue': _avatarColor(_uid).toARGB32(),
                            'text': text,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          batch.update(_postsRef.doc(postId), {
                            'commentCount': FieldValue.increment(1),
                          });
                          await batch.commit();
                          commentCtrl.clear();
                          setSheet(() => sending = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: sending ? Colors.grey : brown,
                            shape: BoxShape.circle,
                          ),
                          child: sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete post ───────────────────────────────────────────────────────
  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _postsRef.doc(postId).delete();
              _showSnack('Post deleted', Colors.grey);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
          "Can't Find a Book?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: _showPostComposer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSel = _selectedFilter == f;
                  final color = _tagColors[f] ?? brown;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? (f == 'All' ? brown : color)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Posts — real-time Firestore stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedFilter == 'All'
                  ? _postsRef.orderBy('createdAt', descending: true).snapshots()
                  : _postsRef
                        .where('tag', isEqualTo: _selectedFilter)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: brown),
                  );
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No ${_selectedFilter == 'All' ? '' : '$_selectedFilter '}posts yet',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Be the first to post!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showPostComposer,
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Post a Request',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brown,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _PostCard(
                    postId: docs[i].id,
                    data: docs[i].data() as Map<String, dynamic>,
                    uid: _uid,
                    tagColors: _tagColors,
                    timeAgo: _timeAgo,
                    avatarColor: _avatarColor,
                    onLike: _toggleLike,
                    onComment: _showComments,
                    onDelete: _confirmDelete,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostComposer,
        backgroundColor: brown,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text(
          'Post a Request',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint, int maxLines) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
          borderSide: const BorderSide(color: brown, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post Card — reads live data, handles like/comment/delete
// ─────────────────────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String uid;
  final Map<String, Color> tagColors;
  final String Function(dynamic) timeAgo;
  final Color Function(String) avatarColor;
  final Future<void> Function(String, List) onLike;
  final void Function(String, String) onComment;
  final void Function(String) onDelete;

  const _PostCard({
    required this.postId,
    required this.data,
    required this.uid,
    required this.tagColors,
    required this.timeAgo,
    required this.avatarColor,
    required this.onLike,
    required this.onComment,
    required this.onDelete,
  });

  static const brown = Color(0xFF613613);

  @override
  Widget build(BuildContext context) {
    final name = data['authorName'] as String? ?? 'User';
    final initial = data['authorInitial'] as String? ?? 'U';
    final colorVal = data['authorColorValue'] as int?;
    final authorColor = colorVal != null
        ? Color(colorVal)
        : avatarColor(data['authorId'] ?? '');
    final tag = data['tag'] as String? ?? 'Wanted';
    final tagColor = tagColors[tag] ?? brown;
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final likes = List.from(data['likes'] ?? []);
    final commentCount = data['commentCount'] as int? ?? 0;
    final isLiked = likes.contains(uid);
    final isMe = data['authorId'] == uid;
    final imageUrl = data['imageUrl'] as String? ?? '';
    final ts = data['createdAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            // ── User row ────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: authorColor.withValues(alpha: 0.2),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: authorColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: brown.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        timeAgo(ts),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tag badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tagColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                    ),
                  ),
                ),
                // More menu (own posts only)
                if (isMe) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => onDelete(postId),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.08),
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
            const SizedBox(height: 12),

            // ── Title ───────────────────────────────────────────────────
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                body,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Image (if present) ───────────────────────────────────────
            if (imageUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 10),

            // ── Action row ───────────────────────────────────────────────
            Row(
              children: [
                // Like
                GestureDetector(
                  onTap: () => onLike(postId, likes),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(isLiked),
                          size: 20,
                          color: isLiked
                              ? Colors.redAccent
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${likes.length}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isLiked
                              ? Colors.redAccent
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Comment
                GestureDetector(
                  onTap: () => onComment(postId, title),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$commentCount',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Comment',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),

            // ── Comment preview ──────────────────────────────────────────
            if (commentCount > 0) ...[
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('book_requests')
                    .doc(postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (_, snap) {
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) return const SizedBox();
                  final c = docs.first.data() as Map<String, dynamic>;
                  final cName = c['authorName'] as String? ?? 'User';
                  final cText = c['text'] as String? ?? '';
                  final cInit = c['authorInitial'] as String? ?? 'U';
                  final cCol = c['authorColorValue'] as int?;
                  final cColor = cCol != null ? Color(cCol) : Colors.grey;
                  return GestureDetector(
                    onTap: () => onComment(postId, title),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: cColor.withValues(alpha: 0.2),
                            child: Text(
                              cInit,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: cColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$cName  ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: cText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (commentCount > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: GestureDetector(
                    onTap: () => onComment(postId, title),
                    child: Text(
                      'View all $commentCount comments',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
