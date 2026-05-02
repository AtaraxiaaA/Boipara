import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buy_books_screen.dart'; // BookDetailScreen & CartManager live here

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with SingleTickerProviderStateMixin {
  // ── Colors ────────────────────────────────────────────────────────────
  static const darkBrown = Color(0xFF613613);
  static const mediumBrown = Color(0xFF7C4700);
  static const lightBrown = Color(0xFF7E481C);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  // ── State ─────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  bool _hasSearched = false;
  String _lastQuery = '';

  String _activeFilter = 'All'; // 'All' | 'Title' | 'Author'
  final _filters = ['All', 'Title', 'Author'];

  late AnimationController _shimmerCtrl;

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadAllBooks();
    // Auto-focus the search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────
  Future<void> _loadAllBooks() async {
    setState(() => _isLoading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('books')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();

      final books = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        d['id'] = doc.id;
        // Fetch seller name — best-effort, silent fail
        try {
          final sd = await FirebaseFirestore.instance
              .collection('users')
              .doc(d['sellerId'])
              .get();
          d['sellerName'] = sd.data()?['username'] ?? 'Unknown';
          d['sellerPhoto'] = sd.data()?['profilePhoto'] ?? '';
        } catch (_) {
          d['sellerName'] = 'Unknown';
          d['sellerPhoto'] = '';
        }
        books.add(d);
      }

      setState(() {
        _allBooks = books;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  // ── Search Logic ──────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _lastQuery = query;
      _hasSearched = q.isNotEmpty;
      if (q.isEmpty) {
        _results = [];
        return;
      }
      _results = _allBooks.where((book) {
        final title = (book['bookName'] ?? '').toString().toLowerCase();
        final author = (book['authorName'] ?? '').toString().toLowerCase();
        switch (_activeFilter) {
          case 'Title':
            return title.contains(q);
          case 'Author':
            return author.contains(q);
          default:
            return title.contains(q) || author.contains(q);
        }
      }).toList();
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
      _lastQuery = '';
    });
    _focusNode.requestFocus();
  }

  void _setFilter(String f) {
    setState(() => _activeFilter = f);
    if (_searchCtrl.text.isNotEmpty) _onSearchChanged(_searchCtrl.text);
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  Color _condColor(String? c) {
    final s = (c ?? '').toLowerCase();
    if (s.contains('brand') || s.contains('new')) return Colors.green;
    if (s.contains('like')) return Colors.teal;
    if (s.contains('very')) return mediumBrown;
    if (s.contains('good')) return lightBrown;
    return Colors.grey;
  }

  /// Wrap matching substring in a TextSpan so it highlights in orange.
  TextSpan _highlighted(String text, String query, TextStyle base) {
    if (query.isEmpty) return TextSpan(text: text, style: base);
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final idx = lower.indexOf(q);
    if (idx == -1) return TextSpan(text: text, style: base);
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, idx), style: base),
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: base.copyWith(
            color: accentOrange,
            fontWeight: FontWeight.bold,
            backgroundColor: accentOrange.withValues(alpha: 0.10),
          ),
        ),
        TextSpan(text: text.substring(idx + q.length), style: base),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkBrown,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Container(
        height: 42,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search by title or author…',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white70,
              size: 20,
            ),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: darkBrown,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: _filters.map((f) {
          final active = _activeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? accentOrange
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? accentOrange
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (!_hasSearched) return _buildEmptyState();
    if (_results.isEmpty) return _buildNoResults();
    return _buildResultsList();
  }

  // ── Loading shimmer ───────────────────────────────────────────────────
  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) {
        final shimmer = LinearGradient(
          begin: Alignment(-1.0 + _shimmerCtrl.value * 2, 0),
          end: Alignment(1.0 + _shimmerCtrl.value * 2, 0),
          colors: const [
            Color(0xFFEAE0D5),
            Color(0xFFF5F0E9),
            Color(0xFFEAE0D5),
          ],
        );
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => Container(
            height: 92,
            decoration: BoxDecoration(
              gradient: shimmer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  // ── Empty / idle state ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: darkBrown.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, size: 52, color: darkBrown),
          ),
          const SizedBox(height: 20),
          const Text(
            'Search Boipara',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a book title or author name\nto find available books',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Quick tip chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _tipChip(Icons.auto_stories_rounded, 'Search by title'),
              _tipChip(Icons.person_outline_rounded, 'Search by author'),
              _tipChip(Icons.filter_list_rounded, 'Use filters above'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_allBooks.length} books available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentOrange),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: darkBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── No results ────────────────────────────────────────────────────────
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No books found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No results for "$_lastQuery"\nTry a different name or author',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.refresh_rounded, color: accentOrange),
            label: const Text(
              'Clear search',
              style: TextStyle(
                color: accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Results list ──────────────────────────────────────────────────────
  Widget _buildResultsList() {
    final query = _searchCtrl.text.trim();
    return Column(
      children: [
        // Result count bar
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_results.length} result${_results.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentOrange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'for "$query"',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _bookCard(_results[i], query),
          ),
        ),
      ],
    );
  }

  Widget _bookCard(Map<String, dynamic> book, String query) {
    final cc = _condColor(book['condition']);
    final orig = (book['buyingPrice'] as num?)?.toDouble() ?? 0;
    final ask = (book['askingPrice'] as num?)?.toDouble() ?? 0;
    final disc = orig > 0 ? (((orig - ask) / orig) * 100).round() : 0;
    final isPublished = book['listingType'] == 'published';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ).then((_) => setState(() {})),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Book cover placeholder ────────────────────────────────
            Container(
              width: 80,
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    lightBrown.withValues(alpha: 0.18),
                    mediumBrown.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 36,
                  color: darkBrown.withValues(alpha: 0.35),
                ),
              ),
            ),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with highlight
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: _highlighted(
                        book['bookName'] ?? '',
                        (_activeFilter == 'Author') ? '' : query,
                        const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Author with highlight
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: _highlighted(
                        'by ${book['authorName'] ?? ''}',
                        (_activeFilter == 'Title') ? '' : query,
                        TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tags row
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (isPublished)
                          _tag('New Release', accentOrange)
                        else
                          _tag(
                            (book['condition'] ?? 'Used').split(' ').first,
                            cc,
                          ),
                        if (disc > 0) _tag('$disc% OFF', Colors.green),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '৳$ask',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: accentOrange,
                              ),
                            ),
                            if (orig > 0) ...[
                              const SizedBox(width: 5),
                              Text(
                                '৳$orig',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Seller
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              book['sellerName'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Arrow ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
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
