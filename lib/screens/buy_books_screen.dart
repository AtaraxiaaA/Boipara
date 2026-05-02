import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addresses_screen.dart';
import 'guest_guard.dart';
import 'notif_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cart singleton
// ─────────────────────────────────────────────────────────────────────────────
class CartManager {
  static final CartManager _i = CartManager._();
  factory CartManager() => _i;
  CartManager._();

  final List<Map<String, dynamic>> items = [];
  void add(Map<String, dynamic> b) {
    if (!items.any((x) => x['id'] == b['id'])) items.add(Map.from(b));
  }

  void remove(String id) => items.removeWhere((x) => x['id'] == id);
  bool contains(String id) => items.any((x) => x['id'] == id);
  int get count => items.length;
  double get total => items.fold(
    0,
    (s, b) => s + ((b['askingPrice'] as num?)?.toDouble() ?? 0),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BuyBooksScreen
// ─────────────────────────────────────────────────────────────────────────────
class BuyBooksScreen extends StatefulWidget {
  const BuyBooksScreen({super.key});
  @override
  State<BuyBooksScreen> createState() => _BuyBooksScreenState();
}

class _BuyBooksScreenState extends State<BuyBooksScreen> {
  static const darkBrown = Color(0xFF613613);
  static const mediumBrown = Color(0xFF7C4700);
  static const lightBrown = Color(0xFF7E481C);
  static const backgroundColor = Color(0xFFF5F0E9);
  static const accentOrange = Color(0xFFE07B39);

  String _selectedCategory = 'All';
  final _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Textbook',
    'Poetry',
    'Self-Help',
    'Horror',
    'History',
  ];
  List<Map<String, dynamic>> _newReleases = [];
  List<Map<String, dynamic>> _thriftBooks = [];
  bool _isLoading = true;
  final _cart = CartManager();
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
        _newReleases = books
            .where((b) => b['listingType'] == 'published')
            .toList();
        _thriftBooks = books
            .where((b) => b['listingType'] != 'published')
            .toList();
        if (_newReleases.isEmpty && _thriftBooks.isEmpty) {
          _newReleases = books.take(4).toList();
          _thriftBooks = books.skip(4).toList();
        }
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 'All') return _thriftBooks;
    return _thriftBooks
        .where(
          (b) => (b['category'] ?? b['condition'] ?? '').toLowerCase().contains(
            _selectedCategory.toLowerCase(),
          ),
        )
        .toList();
  }

  Color _condColor(String? c) {
    final s = (c ?? '').toLowerCase();
    if (s.contains('brand') || s.contains('new')) return Colors.green;
    if (s.contains('like')) return Colors.teal;
    if (s.contains('very')) return mediumBrown;
    if (s.contains('good')) return lightBrown;
    return Colors.grey;
  }

  int _disc(dynamic o, dynamic a) {
    final ov = (o as num?)?.toDouble() ?? 0;
    final av = (a as num?)?.toDouble() ?? 0;
    return ov <= 0 ? 0 : (((ov - av) / ov) * 100).round();
  }

  void _open(Map<String, dynamic> book) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
  ).then((_) => setState(() {}));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkBrown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buy Books',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: _showCart,
              ),
              if (_cart.count > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: accentOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_cart.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: darkBrown))
          : RefreshIndicator(
              onRefresh: _load,
              color: darkBrown,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _catFilter()),
                  if (_newReleases.isNotEmpty)
                    SliverToBoxAdapter(child: _newReleasesSection()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thrift Books / Preloved',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkBrown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quality books at great prices',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _filtered.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.menu_book_outlined,
                                    size: 56,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No books available yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _thriftCard(_filtered[i]),
                              childCount: _filtered.length,
                            ),
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _catFilter() => Container(
    height: 50,
    margin: const EdgeInsets.only(top: 12),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _categories.length,
      itemBuilder: (_, i) {
        final cat = _categories[i];
        final isSel = _selectedCategory == cat;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(
              cat,
              style: TextStyle(
                color: isSel ? Colors.white : darkBrown,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            selected: isSel,
            onSelected: (_) => setState(() => _selectedCategory = cat),
            backgroundColor: Colors.white,
            selectedColor: darkBrown,
            checkmarkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isSel ? darkBrown : Colors.grey.shade300),
            ),
          ),
        );
      },
    ),
  );

  Widget _newReleasesSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recently Published',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fresh releases from new authors',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: accentOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _newReleases.length,
          itemBuilder: (_, i) => Padding(
            padding: EdgeInsets.only(
              right: i < _newReleases.length - 1 ? 12 : 0,
            ),
            child: SizedBox(width: 160, child: _publishedCard(_newReleases[i])),
          ),
        ),
      ),
    ],
  );

  Widget _publishedCard(Map<String, dynamic> book) => GestureDetector(
    onTap: () => _open(book),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        lightBrown.withValues(alpha: 0.15),
                        mediumBrown.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 52,
                      color: darkBrown.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'New Release',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['bookName'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${book['authorName'] ?? ''}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '৳${book['askingPrice'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: accentOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _thriftCard(Map<String, dynamic> book) {
    final cc = _condColor(book['condition']);
    final disc = _disc(book['buyingPrice'], book['askingPrice']);
    final inCart = _cart.contains(book['id'] ?? '');
    final isMe = book['sellerId'] == _uid;

    return GestureDetector(
      onTap: () => _open(book),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          lightBrown.withValues(alpha: 0.15),
                          mediumBrown.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 52,
                        color: darkBrown.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cc,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (book['condition'] ?? 'Used').split(' ').first,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (disc > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$disc% OFF',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (isMe)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Your Book',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['bookName'] ?? 'Book Name',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'by ${book['authorName'] ?? ''}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 11,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${book['sellerName'] ?? 'Seller'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((book['buyingPrice'] ?? 0) > 0)
                            Text(
                              '৳${book['buyingPrice']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '৳${book['askingPrice'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: accentOrange,
                            ),
                          ),
                        ],
                      ),
                      if (!isMe)
                        GestureDetector(
                          onTap: () {
                            if (!inCart && showGuestDialog(context)) return;
                            setState(() {
                              inCart
                                  ? _cart.remove(book['id'])
                                  : _cart.add(book);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  !inCart
                                      ? '🛒 Added to cart!'
                                      : 'Removed from cart',
                                ),
                                backgroundColor: !inCart
                                    ? const Color(0xFF059669)
                                    : Colors.grey,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: inCart
                                  ? const Color(0xFF059669)
                                  : accentOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  inCart
                                      ? Icons.check_rounded
                                      : Icons.add_shopping_cart_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  inCart ? 'Added' : 'Add',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkBrown,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_cart.items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Browse books and add them to your cart',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              else ...[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cart.items.length,
                    itemBuilder: (_, i) {
                      final item = _cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 56,
                              decoration: BoxDecoration(
                                color: darkBrown.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: darkBrown.withValues(alpha: 0.4),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['bookName'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'by ${item['authorName'] ?? ''}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '৳${item['askingPrice'] ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: accentOrange,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                _cart.remove(item['id']);
                                setSheet(() {});
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '৳${_cart.total.toInt() + (_cart.count * 50)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Includes ৳50 delivery per book (${_cart.count} book${_cart.count != 1 ? 's' : ''})',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (_cart.items.isNotEmpty) _open(_cart.items.first);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BookDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetailScreen({super.key, required this.book});
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  static const darkBrown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  List<Map<String, dynamic>> _sellerBooks = [];
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddr;
  String _selectedPayment = 'bKash';
  bool _isOrdering = false;
  bool _inCart = false;
  final _cart = CartManager();

  final _questionCtrl = TextEditingController();
  bool _postingQ = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _displayName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  bool get _isMe => widget.book['sellerId'] == _uid;

  final _payOpts = ['Cash on Delivery', 'bKash', 'Nagad', 'Bank'];
  final _payColors = <String, Color>{
    'Cash on Delivery': Color(0xFF059669),
    'bKash': Color(0xFFE2136E),
    'Nagad': Color(0xFFF6921E),
    'Bank': Color(0xFF1A5276),
  };

  @override
  void initState() {
    super.initState();
    _inCart = _cart.contains(widget.book['id'] ?? '');
    _loadSellerBooks();
    _loadAddresses();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSellerBooks() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('books')
          .where('sellerId', isEqualTo: widget.book['sellerId'])
          .where('status', isEqualTo: 'approved')
          .get();
      if (mounted)
        setState(() {
          _sellerBooks = snap.docs.where((d) => d.id != widget.book['id']).map((
            d,
          ) {
            final data = d.data();
            data['id'] = d.id;
            data['sellerName'] = widget.book['sellerName'];
            data['sellerPhoto'] = widget.book['sellerPhoto'];
            return data;
          }).toList();
        });
    } catch (_) {}
  }

  Future<void> _loadAddresses() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('addresses')
          .get();
      if (mounted)
        setState(() {
          _addresses = snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return data;
          }).toList();
          final def = _addresses.firstWhere(
            (a) => a['isDefault'] == true,
            orElse: () => _addresses.isNotEmpty ? _addresses[0] : {},
          );
          if (def.isNotEmpty) _selectedAddr = def;
        });
    } catch (_) {}
  }

  // ── Helper: get current user's display name from Firestore ────────────
  Future<String> _getMyName() async {
    try {
      final ud = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      return ud.data()?['username'] ?? _displayName;
    } catch (_) {
      return _displayName;
    }
  }

  // ── Post question → notify seller (respects seller's qa preference) ───
  Future<void> _postQuestion() async {
    final q = _questionCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _postingQ = true);
    try {
      final name = await _getMyName();

      // Save question
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book['id'])
          .collection('questions')
          .add({
            'question': q,
            'askerId': _uid,
            'askerName': name,
            'createdAt': FieldValue.serverTimestamp(),
            'answers': [],
          });

      // Notify seller — only if buyer ≠ seller, respects qa preference
      final sellerId = widget.book['sellerId'] ?? '';
      if (sellerId.isNotEmpty && sellerId != _uid) {
        await NotifHelper.sendNewQuestion(
          sellerId: sellerId,
          payload: {
            'type': 'new_question',
            'title': '❓ New Question',
            'body': '$name asked: "$q"',
            'bookId': widget.book['id'],
            'bookName': widget.book['bookName'] ?? '',
            'askerId': _uid,
            'askerName': name,
            'question': q,
          },
        );
      }

      _questionCtrl.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      _showSnack('Failed to post question', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _postingQ = false);
    }
  }

  // ── Post answer → notify the original question asker only ─────────────
  Future<void> _postAnswer(
    String questionId,
    String answerText,
    String askerId, // ← uid of the person who asked
    String question, // ← original question text (for notification body)
  ) async {
    if (answerText.trim().isEmpty) return;
    try {
      final name = await _getMyName();

      final qRef = FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book['id'])
          .collection('questions')
          .doc(questionId);
      final qSnap = await qRef.get();
      final existing = List.from(qSnap.data()?['answers'] ?? []);
      existing.add({
        'answer': answerText.trim(),
        'answererId': _uid,
        'answererName': name,
        'isSeller': _isMe,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await qRef.update({'answers': existing});

      // Notify the original asker — only if they're not the one answering,
      // respects asker's qa preference
      if (askerId.isNotEmpty && askerId != _uid) {
        await NotifHelper.sendNewAnswer(
          askerId: askerId,
          payload: {
            'type': 'new_answer',
            'title': _isMe
                ? '💬 Seller replied to your question'
                : '💬 Someone answered your question',
            'body': '$name answered: "${answerText.trim()}"',
            'bookId': widget.book['id'],
            'bookName': widget.book['bookName'] ?? '',
            'question': question,
            'answer': answerText.trim(),
            'answererName': name,
            'isSeller': _isMe,
          },
        );
      }
    } catch (e) {
      _showSnack('Failed to post answer', Colors.redAccent);
    }
  }

  // ── Answer dialog — now passes askerId & question text ────────────────
  void _showAnswerDialog(
    String questionId,
    String questionText,
    String askerId,
  ) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Write an Answer',
          style: TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                questionText,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your answer...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: darkBrown, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ],
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
              Navigator.pop(context);
              await _postAnswer(questionId, ctrl.text, askerId, questionText);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Post Answer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Place Order ───────────────────────────────────────────────────────
  Future<void> _placeOrder() async {
    if (showGuestDialog(context)) return;
    if (_isMe) {
      _showSnack('You cannot buy your own book', Colors.orange);
      return;
    }
    if (_selectedAddr == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddressesScreen()),
      );
      await _loadAddresses();
      if (_selectedAddr == null) return;
    }
    setState(() => _isOrdering = true);
    try {
      final uid = _uid;
      await FirebaseFirestore.instance.collection('orders').add({
        'buyerId': uid,
        'sellerId': widget.book['sellerId'],
        'bookId': widget.book['id'],
        'bookName': widget.book['bookName'],
        'authorName': widget.book['authorName'],
        'condition': widget.book['condition'],
        'askingPrice': widget.book['askingPrice'],
        'paymentMethod': _selectedPayment,
        'deliveryAddress': {
          'name': _selectedAddr!['name'] ?? '',
          'phone': _selectedAddr!['phone'] ?? '',
          'backup1': _selectedAddr!['backup1'] ?? '',
          'backup2': _selectedAddr!['backup2'] ?? '',
          'street': _selectedAddr!['street'] ?? '',
          'upazila': _selectedAddr!['upazila'] ?? '',
          'district': _selectedAddr!['district'] ?? '',
          'division': _selectedAddr!['division'] ?? '',
          'postalCode': _selectedAddr!['postalCode'] ?? '',
        },
        'status': 'ordered',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book['id'])
          .update({'status': 'sold'});

      String buyerName = 'Someone';
      String buyerPhone = '';
      try {
        final bd = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        buyerName = bd.data()?['username'] ?? 'Someone';
        buyerPhone = bd.data()?['mobile'] ?? '';
      } catch (_) {}

      // In-app notification → seller (respects seller's orders preference)
      await NotifHelper.sendNewOrder(
        sellerId: widget.book['sellerId'],
        payload: {
          'type': 'new_order',
          'title': '📦 New Order!',
          'body': '$buyerName wants to buy "${widget.book['bookName']}"',
          'bookId': widget.book['id'],
          'bookName': widget.book['bookName'],
          'authorName': widget.book['authorName'] ?? '',
          'askingPrice': widget.book['askingPrice'],
          'buyerId': uid,
          'buyerName': buyerName,
          'buyerPhone': buyerPhone,
          'paymentMethod': _selectedPayment,
          'deliveryAddress': {
            'name': _selectedAddr!['name'] ?? '',
            'phone': _selectedAddr!['phone'] ?? '',
            'backup1': _selectedAddr!['backup1'] ?? '',
            'backup2': _selectedAddr!['backup2'] ?? '',
            'street': _selectedAddr!['street'] ?? '',
            'upazila': _selectedAddr!['upazila'] ?? '',
            'district': _selectedAddr!['district'] ?? '',
            'division': _selectedAddr!['division'] ?? '',
            'postalCode': _selectedAddr!['postalCode'] ?? '',
          },
        },
      );

      // Email
      try {
        final sd = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.book['sellerId'])
            .get();
        final email = sd.data()?['email'] ?? '';
        if (email.isNotEmpty) {
          await FirebaseFirestore.instance.collection('mail').add({
            'to': email,
            'message': {
              'subject': '📦 New Order — ${widget.book['bookName']}',
              'html':
                  '<h2>New Order!</h2><p><b>Book:</b> ${widget.book['bookName']}</p><p><b>Buyer:</b> $buyerName</p><p><b>Payment:</b> $_selectedPayment</p><p><b>Deliver to:</b><br>${_selectedAddr!['name']}<br>${_selectedAddr!['phone']}<br>${_selectedAddr!['street']}, ${_selectedAddr!['upazila']}, ${_selectedAddr!['district']}</p>',
            },
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}

      // SMS
      try {
        final sd = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.book['sellerId'])
            .get();
        final phone = sd.data()?['mobile'] ?? '';
        if (phone.isNotEmpty) {
          await FirebaseFirestore.instance.collection('sms_queue').add({
            'to': phone,
            'body':
                '📦 Boipara: New order! $buyerName wants "${widget.book['bookName']}". Open app for details.',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}

      _cart.remove(widget.book['id'] ?? '');
      setState(() => _isOrdering = false);
      if (mounted) _showSuccess();
    } catch (e) {
      setState(() => _isOrdering = false);
      _showSnack('Failed to place order: $e', Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color c) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: c,
          behavior: SnackBarBehavior.floating,
        ),
      );

  void _showSuccess() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Order Placed!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order for "${widget.book['bookName']}" is placed!\n\nSeller notified via:\n✅ In-app\n📧 Email (Blaze)\n📱 SMS (Blaze+Twilio)',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBrown,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
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
  );

  Color _condColor(String? c) {
    final s = (c ?? '').toLowerCase();
    if (s.contains('new')) return const Color(0xFF059669);
    if (s.contains('good')) return const Color(0xFF0E7490);
    return const Color(0xFFB45309);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final orig = (book['buyingPrice'] as num?)?.toDouble() ?? 0;
    final ask = (book['askingPrice'] as num?)?.toDouble() ?? 0;
    final disc = orig > 0 ? (((orig - ask) / orig) * 100).round() : 0;
    final cc = _condColor(book['condition']);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          book['bookName'] ?? 'Book Details',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (!_isMe)
            IconButton(
              icon: Icon(
                _inCart
                    ? Icons.check_circle_rounded
                    : Icons.add_shopping_cart_rounded,
                color: _inCart ? Colors.greenAccent : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _inCart ? _cart.remove(book['id'] ?? '') : _cart.add(book);
                  _inCart = !_inCart;
                });
                _showSnack(
                  _inCart ? 'Added to cart!' : 'Removed from cart',
                  _inCart ? const Color(0xFF059669) : Colors.grey,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Book card ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          darkBrown.withValues(alpha: 0.15),
                          darkBrown.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: darkBrown.withValues(alpha: 0.4),
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['bookName'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book['authorName'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if ((book['edition'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            book['edition'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cc.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book['condition'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: cc,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '৳$ask',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: accentOrange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (orig > 0)
                              Text(
                                '৳$orig',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            if (disc > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$disc% OFF',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if ((book['additionalNotes'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        book['additionalNotes'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Seller ─────────────────────────────────────────────────
            const SizedBox(height: 20),
            _title('Seller'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: darkBrown.withValues(alpha: 0.15),
                    backgroundImage: (book['sellerPhoto'] ?? '').isNotEmpty
                        ? NetworkImage(book['sellerPhoto'])
                        : null,
                    child: (book['sellerPhoto'] ?? '').isEmpty
                        ? Text(
                            (book['sellerName'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: darkBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['sellerName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_sellerBooks.length + 1} books listed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isMe)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: darkBrown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (_sellerBooks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'More from this seller',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sellerBooks.length,
                  itemBuilder: (_, i) {
                    final sb = _sellerBooks[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(book: sb),
                        ),
                      ),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: darkBrown.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    color: darkBrown.withValues(alpha: 0.4),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sb['bookName'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '৳${sb['askingPrice'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // ── Q&A Section ────────────────────────────────────────────
            const SizedBox(height: 24),
            _buildQASection(),

            if (!_isMe) ...[
              // ── Delivery address ────────────────────────────────────
              const SizedBox(height: 20),
              _title('Delivery Address'),
              const SizedBox(height: 10),
              if (_addresses.isEmpty) _noAddrWidget() else _addrList(),

              // ── Payment ─────────────────────────────────────────────
              const SizedBox(height: 20),
              _title('Payment Method'),
              const SizedBox(height: 10),
              ..._payOpts.map((opt) {
                final isSel = _selectedPayment == opt;
                final col = _payColors[opt]!;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPayment = opt),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSel ? col.withValues(alpha: 0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? col : Colors.grey.shade200,
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            opt == 'Cash on Delivery'
                                ? Icons.money_rounded
                                : opt == 'Bank'
                                ? Icons.account_balance_outlined
                                : Icons.phone_android_rounded,
                            color: col,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isSel ? col : Colors.black87,
                            ),
                          ),
                        ),
                        Radio<String>(
                          value: opt,
                          groupValue: _selectedPayment,
                          onChanged: (v) =>
                              setState(() => _selectedPayment = v!),
                          activeColor: col,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // ── Order Summary ───────────────────────────────────────
              const SizedBox(height: 20),
              _title('Order Summary'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _sumRow('Book Price', '৳$ask'),
                    _sumRow('Delivery Fee', '৳50'),
                    const Divider(height: 16),
                    _sumRow('Total', '৳${(ask + 50).toInt()}', bold: true),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF059669).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFF059669),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Seller will be notified instantly',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '✅ In-app (always active)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '📧 Email (needs Blaze plan)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '📱 SMS (needs Blaze + Twilio)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Buy button ──────────────────────────────────────────
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isOrdering ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: _isOrdering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Buy for ৳${(ask + 50).toInt()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            if (_isMe) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkBrown.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: darkBrown.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: darkBrown, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This is your own listing. You cannot buy your own book.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  // ── Q&A Section ────────────────────────────────────────────────────────
  Widget _buildQASection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.question_answer_outlined,
              color: darkBrown,
              size: 20,
            ),
            const SizedBox(width: 8),
            _title('Questions about this product'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Ask publicly — seller and community can answer',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 14),

        // ── Ask question input ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              TextField(
                controller: _questionCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ask a question about this book...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
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
                    borderSide: const BorderSide(color: darkBrown, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _postingQ ? null : _postQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _postingQ
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Post Question',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Questions stream ──────────────────────────────────────────
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('books')
              .doc(widget.book['id'])
              .collection('questions')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: darkBrown),
                ),
              );
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No questions yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to ask!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final answers = List.from(data['answers'] ?? []);
                final askerName = data['askerName'] ?? 'User';
                final question = data['question'] ?? '';
                final askerId = data['askerId'] ?? ''; // ← captured here

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: darkBrown.withValues(alpha: 0.12),
                            child: Text(
                              askerName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: darkBrown,
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
                                      askerName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (askerId == _uid)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: darkBrown.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'You',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: darkBrown,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  question,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Answer button — passes askerId so notification
                          // goes only to the question author
                          GestureDetector(
                            onTap: () => _showAnswerDialog(
                              doc.id,
                              question,
                              askerId, // ← pass askerId
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _isMe
                                    ? accentOrange.withValues(alpha: 0.1)
                                    : darkBrown.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isMe
                                      ? accentOrange.withValues(alpha: 0.3)
                                      : darkBrown.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    size: 13,
                                    color: _isMe ? accentOrange : darkBrown,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isMe ? 'Answer as Seller' : 'Answer',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _isMe ? accentOrange : darkBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Answers
                      if (answers.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            children: answers.map((ans) {
                              final answerer = ans['answererName'] ?? 'User';
                              final isSeller = ans['isSeller'] == true;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 13,
                                      backgroundColor: isSeller
                                          ? accentOrange.withValues(alpha: 0.15)
                                          : Colors.grey.shade200,
                                      child: Text(
                                        answerer[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSeller
                                              ? accentOrange
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                answerer,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (isSeller) ...[
                                                const SizedBox(width: 5),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: accentOrange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .storefront_rounded,
                                                        size: 10,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 3),
                                                      Text(
                                                        'Seller',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            ans['answer'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _noAddrWidget() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No delivery address saved. Add one to continue.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressesScreen()),
            );
            _loadAddresses();
          },
          icon: const Icon(Icons.add, color: darkBrown),
          label: const Text('Add Address', style: TextStyle(color: darkBrown)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: darkBrown),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _addrList() => Column(
    children: [
      ..._addresses.map((addr) {
        final isSel = _selectedAddr?['id'] == addr['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedAddr = addr),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSel ? darkBrown.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? darkBrown : Colors.grey.shade200,
                width: isSel ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: addr['id'],
                  groupValue: _selectedAddr?['id'],
                  onChanged: (_) => setState(() => _selectedAddr = addr),
                  activeColor: darkBrown,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            addr['label'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (addr['isDefault'] == true) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF059669,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${addr['street'] ?? ''}, ${addr['upazila'] ?? ''}, ${addr['district'] ?? ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        addr['phone'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressesScreen()),
          );
          _loadAddresses();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 15,
              color: darkBrown.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Add or manage addresses',
              style: TextStyle(
                fontSize: 12,
                color: darkBrown.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _title(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: darkBrown,
    ),
  );

  Widget _sumRow(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: bold ? Colors.black87 : Colors.grey.shade500,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: bold ? accentOrange : Colors.black87,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
