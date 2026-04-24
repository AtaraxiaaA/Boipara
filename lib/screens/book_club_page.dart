import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookClubPage extends StatefulWidget {
  final String clubId;
  final String clubName;
  final String university;
  final Color color;
  final IconData icon;

  const BookClubPage({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.university,
    required this.color,
    required this.icon,
  });

  @override
  State<BookClubPage> createState() => _BookClubPageState();
}

class _BookClubPageState extends State<BookClubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();
  // Chat controller — used by the messenger-style chat in Discussions
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  bool _sendingChat = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  // Firestore refs
  DocumentReference get _clubRef =>
      FirebaseFirestore.instance.collection('clubs').doc(widget.clubId);
  CollectionReference get _membersRef => _clubRef.collection('members');
  CollectionReference get _chatRef => _clubRef.collection('chat');
  CollectionReference get _postsRef => _clubRef.collection('posts');
  CollectionReference get _eventsRef => _clubRef.collection('events');

  bool _isJoined = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkMembership();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _chatController.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  Future<void> _checkMembership() async {
    if (_uid.isEmpty) return;
    final snap = await _membersRef.doc(_uid).get();
    if (mounted)
      setState(() {
        _isJoined = snap.exists;
        _isAdmin = (snap.data() as Map<String, dynamic>?)?['role'] == 'admin';
      });
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

  // ── Join / Leave ───────────────────────────────────────────────────────
  Future<void> _toggleJoin() async {
    if (_isGuest) {
      _showSnack('Please log in to join clubs', Colors.orange);
      return;
    }
    if (_isJoined) {
      await _membersRef.doc(_uid).delete();
      await _clubRef.update({'memberCount': FieldValue.increment(-1)});
      setState(() {
        _isJoined = false;
        _isAdmin = false;
      });
    } else {
      final name = await _getMyName();
      final photo = FirebaseAuth.instance.currentUser?.photoURL ?? '';
      await _membersRef.doc(_uid).set({
        'uid': _uid,
        'name': name,
        'photo': photo,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });
      await _clubRef.update({'memberCount': FieldValue.increment(1)});
      setState(() => _isJoined = true);
    }
  }

  // ── Send chat message (messenger-style) ───────────────────────────────
  Future<void> _sendChat() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _sendingChat) return;
    if (!_isJoined) {
      _showSnack('Join the club to chat', Colors.orange);
      return;
    }
    setState(() => _sendingChat = true);
    try {
      final name = await _getMyName();
      final photo = FirebaseAuth.instance.currentUser?.photoURL ?? '';
      await _chatRef.add({
        'text': text,
        'senderId': _uid,
        'senderName': name,
        'senderPhoto': photo,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _chatController.clear();
      // Scroll to bottom after send
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_chatScroll.hasClients) {
          _chatScroll.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      _showSnack('Failed to send', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _sendingChat = false);
    }
  }

  // ── Create post ────────────────────────────────────────────────────────
  Future<void> _createPost(String text, String? taggedBook) async {
    if (text.isEmpty) return;
    final name = await _getMyName();
    await _postsRef.add({
      'user': name,
      'content': text,
      'book': taggedBook,
      'authorId': _uid,
      'likes': 0,
      'likedBy': [],
      'comments': 0,
      'time': 'Just now',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Like post ──────────────────────────────────────────────────────────
  Future<void> _toggleLike(String postId, List likedBy) async {
    final ref = _postsRef.doc(postId);
    if (likedBy.contains(_uid)) {
      await ref.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([_uid]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([_uid]),
      });
    }
  }

  // ── RSVP event ────────────────────────────────────────────────────────
  Future<void> _rsvpEvent(String eventId, List attendeeIds) async {
    final ref = _eventsRef.doc(eventId);
    if (attendeeIds.contains(_uid)) {
      await ref.update({
        'attendeeIds': FieldValue.arrayRemove([_uid]),
        'attendees': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'attendeeIds': FieldValue.arrayUnion([_uid]),
        'attendees': FieldValue.increment(1),
      });
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

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as Timestamp).toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _clubRef.snapshots(),
      builder: (context, clubSnap) {
        final clubData = (clubSnap.data?.data() as Map<String, dynamic>?) ?? {};
        final memberCount = clubData['memberCount'] ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F5F1),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // ── SliverAppBar — exact same as original ────────────────
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: widget.color,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.clubName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color,
                          widget.color.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.university,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Stats + Join/Leave — same layout as original ─────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.people_rounded,
                            '$memberCount members',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(Icons.article_rounded, 'Discussions'),
                          const SizedBox(width: 12),
                          _buildInfoChip(Icons.event_rounded, 'Events'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _toggleJoin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isJoined
                                    ? Colors.grey.shade200
                                    : widget.color,
                                foregroundColor: _isJoined
                                    ? Colors.black87
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _isJoined ? 'Leave Club' : 'Join Club',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: widget.color),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: widget.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── TabBar — same as original ─────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: widget.color,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: widget.color,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Discussions'),
                      Tab(text: 'Events'),
                      Tab(text: 'Members'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDiscussionsTab(),
                _buildEventsTab(),
                _buildMembersTab(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreatePostDialog,
            backgroundColor: widget.color,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    ),
  );

  // ── DISCUSSIONS TAB — live posts + messenger chat at bottom ───────────
  Widget _buildDiscussionsTab() => Column(
    children: [
      // ── Live posts feed ────────────────────────────────────────────────
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _postsRef.orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No discussions yet. Start one!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final postId = docs[index].id;
                final likedBy = List.from(data['likedBy'] ?? []);
                final liked = likedBy.contains(_uid);
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: widget.color.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              (data['user'] ?? 'U')[0],
                              style: TextStyle(
                                color: widget.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['user'] ?? 'User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _timeAgo(data['createdAt']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (data['authorId'] == _uid || _isAdmin)
                            IconButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.grey[400],
                              ),
                              onPressed: () => _showPostOptions(postId),
                            )
                          else
                            IconButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {},
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['content'] ?? '',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      if (data['book'] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.book_rounded,
                                size: 16,
                                color: widget.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['book'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleLike(postId, likedBy),
                            child: Row(
                              children: [
                                Icon(
                                  liked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: liked
                                      ? Colors.redAccent
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${data['likes'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(
                            Icons.comment_outlined,
                            '${data['comments'] ?? 0}',
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(Icons.share_outlined, 'Share'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      // ── Messenger-style group chat ────────────────────────────────────
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chat messages (last 5 shown above input as preview)
            StreamBuilder<QuerySnapshot>(
              stream: _chatRef
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snap) {
                final msgs = snap.data?.docs ?? [];
                if (msgs.isEmpty) return const SizedBox.shrink();
                return Container(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: ListView.builder(
                    controller: _chatScroll,
                    reverse: true,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final m = msgs[i].data() as Map<String, dynamic>;
                      final isMe = m['senderId'] == _uid;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: widget.color.withValues(
                                  alpha: 0.15,
                                ),
                                child: Text(
                                  (m['senderName'] ?? 'U')[0],
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: widget.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? widget.color
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: Radius.circular(isMe ? 12 : 2),
                                    bottomRight: Radius.circular(isMe ? 2 : 12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        m['senderName'] ?? '',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: widget.color,
                                        ),
                                      ),
                                    Text(
                                      m['text'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Message input
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      enabled: _isJoined,
                      decoration: InputDecoration(
                        hintText: _isJoined
                            ? 'Message the group...'
                            : 'Join to chat',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendChat(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendChat,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isJoined ? widget.color : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: _sendingChat
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildActionButton(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ],
  );

  void _showPostOptions(String postId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text(
              'Delete Post',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _postsRef.doc(postId).delete();
              _showSnack('Post deleted', Colors.grey);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ── EVENTS TAB — live from Firestore ──────────────────────────────────
  Widget _buildEventsTab() => StreamBuilder<QuerySnapshot>(
    stream: _eventsRef.orderBy('createdAt', descending: true).snapshots(),
    builder: (context, snap) {
      final docs = snap.data?.docs ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isAdmin || _isJoined)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: _isAdmin ? _showAddEventDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  _isAdmin ? 'Add Event' : 'Only admins can add events',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (docs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No events yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...docs.map((doc) {
            final event = doc.data() as Map<String, dynamic>;
            final eventId = doc.id;
            final attendeeIds = List.from(event['attendeeIds'] ?? []);
            final hasRsvp = attendeeIds.contains(_uid);
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event['book'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isAdmin)
                          GestureDetector(
                            onTap: () => doc.reference.delete().then(
                              (_) => _showSnack('Event deleted', Colors.grey),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildEventInfo(
                          Icons.calendar_today_rounded,
                          event['date'] ?? '',
                        ),
                        const SizedBox(width: 24),
                        _buildEventInfo(
                          Icons.access_time_rounded,
                          event['time'] ?? '',
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${event['attendees'] ?? 0} going',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isJoined
                            ? () => _rsvpEvent(eventId, attendeeIds)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasRsvp
                              ? Colors.grey.shade200
                              : widget.color,
                          foregroundColor: hasRsvp
                              ? Colors.black87
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          hasRsvp ? 'Cancel RSVP' : 'RSVP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    },
  );

  Widget _buildEventInfo(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
    ],
  );

  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    final bookCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(titleCtrl, 'Event Title'),
              const SizedBox(height: 10),
              _dialogField(bookCtrl, 'Book / Topic'),
              const SizedBox(height: 10),
              _dialogField(dateCtrl, 'Date (e.g. April 30, 2026)'),
              const SizedBox(height: 10),
              _dialogField(timeCtrl, 'Time (e.g. 5:00 PM)'),
            ],
          ),
        ),
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
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              final name = await _getMyName();
              await _eventsRef.add({
                'title': titleCtrl.text.trim(),
                'book': bookCtrl.text.trim(),
                'date': dateCtrl.text.trim(),
                'time': timeCtrl.text.trim(),
                'attendees': 0,
                'attendeeIds': [],
                'createdBy': _uid,
                'createdByName': name,
                'createdAt': FieldValue.serverTimestamp(),
              });
              _showSnack('Event added!', widget.color);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: widget.color, width: 1.5),
      ),
    ),
  );

  // ── MEMBERS TAB — live from Firestore ─────────────────────────────────
  Widget _buildMembersTab() => StreamBuilder<QuerySnapshot>(
    stream: _membersRef.orderBy('joinedAt').snapshots(),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final members = snap.data?.docs ?? [];
      if (members.isEmpty) {
        return const Center(
          child: Text('No members yet', style: TextStyle(color: Colors.grey)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index].data() as Map<String, dynamic>;
          final role = member['role'] ?? 'Member';
          final isSelf = member['uid'] == _uid;
          final isAdmin = role == 'admin';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: widget.color.withValues(alpha: 0.2),
                  backgroundImage: (member['photo'] ?? '').isNotEmpty
                      ? NetworkImage(member['photo'])
                      : null,
                  child: (member['photo'] ?? '').isEmpty
                      ? Text(
                          (member['name'] ?? 'U')[0],
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member['name'] ?? 'User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                          if (isAdmin || role == 'Moderator') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? widget.color
                                    : widget.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isAdmin ? 'Admin' : 'Moderator',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isAdmin ? Colors.white : widget.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Joined ${_timeAgo(member['joinedAt'])}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                // Admin: promote / remove other members
                if (_isAdmin && !isSelf)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onSelected: (action) async {
                      if (action == 'promote') {
                        await members[index].reference.update({
                          'role': 'admin',
                        });
                        _showSnack(
                          '${member['name']} is now admin',
                          widget.color,
                        );
                      } else if (action == 'remove') {
                        await members[index].reference.delete();
                        await _clubRef.update({
                          'memberCount': FieldValue.increment(-1),
                        });
                        _showSnack(
                          '${member['name']} removed',
                          Colors.redAccent,
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      if (!isAdmin)
                        const PopupMenuItem(
                          value: 'promote',
                          child: Text('Promote to Admin'),
                        ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text(
                          'Remove',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.message_outlined,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
          );
        },
      );
    },
  );

  // ── Create Post dialog — exact same UI as original ────────────────────
  void _showCreatePostDialog() {
    if (!_isJoined) {
      _showSnack('Join the club to post', Colors.orange);
      return;
    }
    String? taggedBook;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _postController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts about a book...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
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
                      borderSide: BorderSide(color: widget.color, width: 2),
                    ),
                  ),
                ),
                if (taggedBook != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.book_rounded,
                            size: 14,
                            color: widget.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            taggedBook!,
                            style: TextStyle(fontSize: 12, color: widget.color),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setSheet(() => taggedBook = null),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: widget.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAttachButton(
                      Icons.book_rounded,
                      'Tag Book',
                      () async {
                        final ctrl = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Tag a Book'),
                            content: TextField(
                              controller: ctrl,
                              decoration: const InputDecoration(
                                hintText: 'Book title',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, ctrl.text.trim()),
                                child: const Text('Tag'),
                              ),
                            ],
                          ),
                        );
                        if (result != null && result.isNotEmpty)
                          setSheet(() => taggedBook = result);
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildAttachButton(Icons.image_rounded, 'Add Photo', () {}),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final text = _postController.text.trim();
                      if (text.isEmpty) return;
                      await _createPost(text, taggedBook);
                      _postController.clear();
                      if (mounted) Navigator.pop(context);
                      _showSnack('Post created!', widget.color);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildAttachButton(IconData icon, String label, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: widget.color),
        label: Text(label, style: TextStyle(color: widget.color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: widget.color.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
}

// ── SliverTabBar delegate — unchanged ─────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(color: Colors.white, child: tabBar);
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
