import 'package:flutter/material.dart';

class BookRequestsScreen extends StatefulWidget {
  const BookRequestsScreen({super.key});

  @override
  State<BookRequestsScreen> createState() => _BookRequestsScreenState();
}

class _BookRequestsScreenState extends State<BookRequestsScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  // TODO: Replace with Firebase stream later
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'userName': 'Rakib Hassan',
      'userInitial': 'R',
      'userColor': Color(0xFF1E3A8A),
      'timeAgo': '2h ago',
      'title': 'Looking for: Atomic Habits',
      'body':
          'Need a copy of Atomic Habits by James Clear. Any edition is fine. Budget: 300-400 taka. DM me if you have one!',
      'tag': 'Wanted',
      'tagColor': Color(0xFFDC2626),
      'likes': 12,
      'commentCount': 4,
      'isLiked': false,
      'comments': [
        {
          'user': 'Sadia',
          'initial': 'S',
          'text': 'I have one! Will message you.',
          'time': '1h ago',
        },
        {
          'user': 'Tanim',
          'initial': 'T',
          'text': 'Check NSU book club, someone posted it.',
          'time': '45m ago',
        },
        {
          'user': 'Mim',
          'initial': 'M',
          'text': 'I saw it at a second hand store in Nilkhet!',
          'time': '30m ago',
        },
        {
          'user': 'Arif',
          'initial': 'A',
          'text': 'Budget seems a bit low. Usually goes for 500+',
          'time': '20m ago',
        },
      ],
    },
    {
      'id': '2',
      'userName': 'Farhan Alam',
      'userInitial': 'F',
      'userColor': Color(0xFF059669),
      'timeAgo': '5h ago',
      'title': 'Anyone has Sapiens?',
      'body':
          'Looking for Sapiens by Yuval Noah Harari. Budget: 300-400 taka. Condition: Good or better. Located in Dhanmondi.',
      'tag': 'Wanted',
      'tagColor': Color(0xFFDC2626),
      'likes': 8,
      'commentCount': 2,
      'isLiked': true,
      'comments': [
        {
          'user': 'Mitu',
          'initial': 'M',
          'text': 'I just listed it on Boipara! Check buy books.',
          'time': '4h ago',
        },
        {
          'user': 'Raju',
          'initial': 'R',
          'text': 'Also looking for the same!',
          'time': '3h ago',
        },
      ],
    },
    {
      'id': '3',
      'userName': 'Nusrat Jahan',
      'userInitial': 'N',
      'userColor': Color(0xFF7C3AED),
      'timeAgo': '1d ago',
      'title': 'Rare find: 1984 First Bangladeshi Edition',
      'body':
          'Found a 1984 first Bangladeshi print at an old book store in Nilkhet. Only one copy available. Anyone interested?',
      'tag': 'Rare Find',
      'tagColor': Color(0xFFB45309),
      'likes': 34,
      'commentCount': 3,
      'isLiked': false,
      'comments': [
        {
          'user': 'Arif',
          'initial': 'A',
          'text': 'Yes please! How much are you asking?',
          'time': '23h ago',
        },
        {
          'user': 'Rafa',
          'initial': 'R',
          'text': 'I am also very interested!',
          'time': '20h ago',
        },
        {
          'user': 'Sumaiya',
          'initial': 'S',
          'text': 'Please list it on Boipara 🙏',
          'time': '18h ago',
        },
      ],
    },
    {
      'id': '4',
      'userName': 'Mehedi Islam',
      'userInitial': 'M',
      'userColor': Color(0xFFB45309),
      'timeAgo': '2d ago',
      'title': 'ISO: Any Harry Potter book',
      'body':
          'In search of any Harry Potter series book. Bangla or English both okay. Located in Mirpur. Can meet up or arrange delivery.',
      'tag': 'ISO',
      'tagColor': Color(0xFF0E7490),
      'likes': 19,
      'commentCount': 1,
      'isLiked': false,
      'comments': [
        {
          'user': 'Priya',
          'initial': 'P',
          'text': 'I have Philosopher\'s Stone in Bangla!',
          'time': '1d ago',
        },
      ],
    },
    {
      'id': '5',
      'userName': 'Tanjila Ahmed',
      'userInitial': 'T',
      'userColor': Color(0xFFDC2626),
      'timeAgo': '3d ago',
      'title': 'Giving away: Old BUET textbooks',
      'body':
          'Have a bunch of old BUET engineering textbooks. Math, Physics, Chemistry. Free to a good home or cheap price. Pick up only — Uttara.',
      'tag': 'Offering',
      'tagColor': Color(0xFF059669),
      'likes': 56,
      'commentCount': 12,
      'isLiked': true,
      'comments': [
        {
          'user': 'Imran',
          'initial': 'I',
          'text': 'I need the Math ones! DM please!',
          'time': '2d ago',
        },
        {
          'user': 'Faria',
          'initial': 'F',
          'text': 'Which editions?',
          'time': '2d ago',
        },
      ],
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Wanted',
    'ISO',
    'Rare Find',
    'Offering',
    'Discussion',
  ];

  final Map<String, Color> _tagColors = {
    'Wanted': const Color(0xFFDC2626),
    'ISO': const Color(0xFF0E7490),
    'Rare Find': const Color(0xFFB45309),
    'Offering': const Color(0xFF059669),
    'Discussion': const Color(0xFF7C3AED),
  };

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedFilter == 'All') return _posts;
    return _posts.where((p) => p['tag'] == _selectedFilter).toList();
  }

  void _showPostComposer() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String selectedTag = 'Wanted';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Container(
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
                  children: _tagColors.entries.map((entry) {
                    final isSelected = selectedTag == entry.key;
                    return GestureDetector(
                      onTap: () => setSheet(() => selectedTag = entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? entry.value.withValues(alpha: 0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? entry.value
                                : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? entry.value
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Title
                _buildInputField(
                  controller: titleController,
                  hint: 'Book title or post headline...',
                  maxLines: 1,
                ),
                const SizedBox(height: 12),

                // Body
                _buildInputField(
                  controller: bodyController,
                  hint:
                      'Describe the book, your budget, location, condition needed...',
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add a title')),
                        );
                        return;
                      }
                      // TODO: Save to Firebase later
                      final newPost = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'userName': 'You',
                        'userInitial': 'Y',
                        'userColor': brown,
                        'timeAgo': 'Just now',
                        'title': titleController.text.trim(),
                        'body': bodyController.text.trim(),
                        'tag': selectedTag,
                        'tagColor': _tagColors[selectedTag]!,
                        'likes': 0,
                        'commentCount': 0,
                        'isLiked': false,
                        'comments': [],
                      };
                      setState(() => _posts.insert(0, newPost));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Post shared!'),
                          backgroundColor: const Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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

  void _showComments(Map<String, dynamic> post) {
    final commentController = TextEditingController();
    final comments = List<Map<String, dynamic>>.from(post['comments'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: brown.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${comments.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: brown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Post title
                    Text(
                      post['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Comments list
              Expanded(
                child: comments.isEmpty
                    ? Center(
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
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final c = comments[index];
                          final user = c['user'] as String? ?? 'User';
                          final initial =
                              c['initial'] as String? ??
                              (user.isNotEmpty ? user[0].toUpperCase() : 'U');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: brown.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: brown,
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
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: brown,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              c['text'] as String? ?? '',
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
                                        c['time'] as String? ?? '',
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
                      ),
              ),

              // Comment input
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: brown,
                      child: const Text(
                        'Y',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
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
                      onTap: () {
                        final text = commentController.text.trim();
                        if (text.isEmpty) return;
                        // TODO: Save to Firebase later
                        setSheet(() {
                          comments.add({
                            'user': 'You',
                            'initial': 'Y',
                            'text': text,
                            'time': 'Just now',
                          });
                        });
                        setState(() {
                          final idx = _posts.indexWhere(
                            (p) => p['id'] == post['id'],
                          );
                          if (idx != -1) {
                            _posts[idx]['comments'] = comments;
                            _posts[idx]['commentCount'] = comments.length;
                          }
                        });
                        commentController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: brown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
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
                  final isSelected = _selectedFilter == f;
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
                        color: isSelected
                            ? (f == 'All' ? brown : color)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Posts list
          Expanded(
            child: _filteredPosts.isEmpty
                ? Center(
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
                          'No $_selectedFilter posts yet',
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
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) =>
                        _buildPostCard(_filteredPosts[index]),
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

  Widget _buildPostCard(Map<String, dynamic> post) {
    final tagColor = post['tagColor'] as Color;
    final userColor = post['userColor'] as Color;

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
            // User row
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: userColor,
                  child: Text(
                    post['userInitial'] as String,
                    style: const TextStyle(
                      color: Colors.white,
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
                      Text(
                        post['userName'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        post['timeAgo'] as String,
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
                    post['tag'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              post['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),

            // Body
            if ((post['body'] as String).isNotEmpty)
              Text(
                post['body'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 10),

            // Action row
            Row(
              children: [
                // Like
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final idx = _posts.indexWhere(
                        (p) => p['id'] == post['id'],
                      );
                      if (idx != -1) {
                        final liked = _posts[idx]['isLiked'] as bool;
                        _posts[idx]['isLiked'] = !liked;
                        _posts[idx]['likes'] =
                            ((_posts[idx]['likes'] as int) + (liked ? -1 : 1));
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        post['isLiked'] as bool
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: post['isLiked'] as bool
                            ? Colors.redAccent
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: post['isLiked'] as bool
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
                  onTap: () => _showComments(post),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['commentCount']}',
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

            // First comment preview
            if ((post['comments'] as List).isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showComments(post),
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
                        backgroundColor: brown.withValues(alpha: 0.15),
                        child: Text(
                          ((post['comments'] as List).first['initial']
                                  as String? ??
                              ((post['comments'] as List).first['user']
                                          as String? ??
                                      'U')[0]
                                  .toUpperCase()),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${(post['comments'] as List).first['user']}  ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              TextSpan(
                                text:
                                    (post['comments'] as List).first['text']
                                        as String,
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
              ),
              if ((post['commentCount'] as int) > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: GestureDetector(
                    onTap: () => _showComments(post),
                    child: Text(
                      'View all ${post['commentCount']} comments',
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
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
