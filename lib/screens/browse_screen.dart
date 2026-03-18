import 'package:flutter/material.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  // Placeholder book data — replace with API results later
  final List<Map<String, String>> _allBooks = [
    {'title': 'Pather Panchali', 'author': 'Bibhutibhushan Bandyopadhyay'},
    {'title': 'Shesher Kobita', 'author': 'Rabindranath Tagore'},
    {'title': 'Lalsalu', 'author': 'Syed Waliullah'},
    {'title': 'Aranyak', 'author': 'Bibhutibhushan Bandyopadhyay'},
    {'title': 'Nondito Noroke', 'author': 'Humayun Ahmed'},
    {'title': 'Misir Ali Omnibus', 'author': 'Humayun Ahmed'},
    {'title': 'Tin Goyenda', 'author': 'Rakib Hasan'},
    {'title': 'Himu', 'author': 'Humayun Ahmed'},
    {'title': 'Kবিতার বই', 'author': 'Jibanananda Das'},
    {'title': 'Muktijuddher Itihas', 'author': 'Various Authors'},
  ];

  List<Map<String, String>> get _filtered {
    if (_query.isEmpty) return [];
    return _allBooks
        .where(
          (b) =>
              b['title']!.toLowerCase().contains(_query.toLowerCase()) ||
              b['author']!.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Auto-focus the search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF5C2C06);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brown,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        title: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (val) => setState(() => _query = val),
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search books, authors...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5C2C06)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildEmptyState()
          : _filtered.isEmpty
          ? _buildNoResults()
          : _buildResults(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Search for books or authors',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No results for "$_query"',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = _filtered[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF5C2C06).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF5C2C06),
              size: 22,
            ),
          ),
          title: Text(
            book['title']!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            book['author']!,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
          onTap: () {
            // TODO: Navigate to book detail screen
          },
        );
      },
    );
  }
}
