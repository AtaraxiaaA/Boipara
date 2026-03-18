import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addresses_screen.dart';

class BuyBooksScreen extends StatefulWidget {
  const BuyBooksScreen({super.key});

  @override
  State<BuyBooksScreen> createState() => _BuyBooksScreenState();
}

class _BuyBooksScreenState extends State<BuyBooksScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCondition = 'All';
  final List<String> _conditions = ['All', 'Like New', 'Good', 'Acceptable'];

  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();

      final books = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Fetch seller username
        try {
          final sellerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['sellerId'])
              .get();
          if (sellerDoc.exists) {
            data['sellerName'] = sellerDoc.data()?['username'] ?? 'Unknown';
            data['sellerPhoto'] = sellerDoc.data()?['profilePhoto'] ?? '';
          }
        } catch (_) {
          data['sellerName'] = 'Unknown';
          data['sellerPhoto'] = '';
        }

        books.add(data);
      }

      setState(() => _books = books);
    } catch (e) {
      _showError('Failed to load books');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredBooks {
    return _books.where((book) {
      final matchSearch =
          _searchQuery.isEmpty ||
          (book['bookName'] ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (book['authorName'] ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchCondition =
          _selectedCondition == 'All' ||
          (book['condition'] ?? '').toLowerCase().contains(
            _selectedCondition.toLowerCase(),
          );
      return matchSearch && matchCondition;
    }).toList();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _conditionColor(String? condition) {
    final c = (condition ?? '').toLowerCase();
    if (c.contains('new')) return const Color(0xFF059669);
    if (c.contains('good')) return const Color(0xFF0E7490);
    return const Color(0xFFB45309);
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
          'Buy Books',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: brown,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search books or authors...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Condition filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _conditions.map((c) {
                  final isSelected = _selectedCondition == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCondition = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? brown : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c,
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

          // Book list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: brown))
                : _filteredBooks.isEmpty
                ? Center(
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
                          _searchQuery.isNotEmpty
                              ? 'No results found'
                              : 'No books available',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBooks,
                    color: brown,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredBooks.length,
                      itemBuilder: (context, index) =>
                          _buildBookCard(_filteredBooks[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final isMyBook = book['sellerId'] == _currentUid;
    final conditionColor = _conditionColor(book['condition']);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ).then((_) => _loadBooks()),
      child: Container(
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
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Container(
                width: 70,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brown.withValues(alpha: 0.15),
                      brown.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: brown.withValues(alpha: 0.4),
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            book['bookName'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isMyBook)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: brown.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Your Book',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: brown,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      book['authorName'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Condition badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: conditionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book['condition'] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: conditionColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          '৳${book['askingPrice'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accentOrange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '৳${book['buyingPrice'] ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Seller
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 13,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book['sellerName'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Book Detail Screen
// ─────────────────────────────────────────────────────────────────────────
class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  List<Map<String, dynamic>> _sellerBooks = [];
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  String _selectedPayment = 'bKash';
  bool _isOrdering = false;
  bool _loadingSellerBooks = true;
  bool _loadingAddresses = true;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isMyBook => widget.book['sellerId'] == _currentUid;

  final _paymentOptions = ['Cash on Delivery', 'bKash', 'Nagad', 'Bank'];
  final _paymentColors = {
    'Cash on Delivery': Color(0xFF059669),
    'bKash': Color(0xFFE2136E),
    'Nagad': Color(0xFFF6921E),
    'Bank': Color(0xFF1A5276),
  };

  @override
  void initState() {
    super.initState();
    _loadSellerBooks();
    _loadAddresses();
  }

  Future<void> _loadSellerBooks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('sellerId', isEqualTo: widget.book['sellerId'])
          .where('status', isEqualTo: 'approved')
          .get();

      setState(() {
        _sellerBooks = snapshot.docs
            .where((doc) => doc.id != widget.book['id'])
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            })
            .toList();
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingSellerBooks = false);
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUid)
          .collection('addresses')
          .get();

      setState(() {
        _addresses = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        // Auto-select default
        final defaultAddr = _addresses.firstWhere(
          (a) => a['isDefault'] == true,
          orElse: () => _addresses.isNotEmpty ? _addresses[0] : {},
        );
        if (defaultAddr.isNotEmpty) _selectedAddress = defaultAddr;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_isMyBook) {
      _showError('You cannot buy your own book');
      return;
    }

    if (_selectedAddress == null) {
      // No address — go to addresses screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddressesScreen()),
      );
      await _loadAddresses();
      if (_selectedAddress == null) return;
    }

    setState(() => _isOrdering = true);

    try {
      final uid = _currentUid;

      // Save order to Firestore
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
          'name': _selectedAddress!['name'],
          'phone': _selectedAddress!['phone'],
          'street': _selectedAddress!['street'],
          'upazila': _selectedAddress!['upazila'],
          'district': _selectedAddress!['district'],
          'division': _selectedAddress!['division'],
          'postalCode': _selectedAddress!['postalCode'] ?? '',
        },
        'status': 'ordered',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mark book as sold
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book['id'])
          .update({'status': 'sold'});

      // Get buyer's username for notification
      String buyerName = 'Someone';
      try {
        final buyerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        buyerName = buyerDoc.data()?['username'] ?? 'Someone';
      } catch (_) {}

      // Save notification to seller's notifications subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.book['sellerId'])
          .collection('notifications')
          .add({
            'type': 'new_order',
            'title': '📦 New Order!',
            'body': '$buyerName wants to buy "${widget.book['bookName']}"',
            'bookId': widget.book['id'],
            'bookName': widget.book['bookName'],
            'authorName': widget.book['authorName'] ?? '',
            'askingPrice': widget.book['askingPrice'],
            'buyerId': uid,
            'buyerName': buyerName,
            'paymentMethod': _selectedPayment,
            // Full delivery address so seller knows where to send
            'deliveryAddress': {
              'name': _selectedAddress!['name'] ?? '',
              'phone': _selectedAddress!['phone'] ?? '',
              'backup1': _selectedAddress!['backup1'] ?? '',
              'backup2': _selectedAddress!['backup2'] ?? '',
              'street': _selectedAddress!['street'] ?? '',
              'upazila': _selectedAddress!['upazila'] ?? '',
              'district': _selectedAddress!['district'] ?? '',
              'division': _selectedAddress!['division'] ?? '',
              'postalCode': _selectedAddress!['postalCode'] ?? '',
            },
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      setState(() => _isOrdering = false);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
                    color: brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order for "${widget.book['bookName']}" has been placed. The seller will be notified.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                      backgroundColor: brown,
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
      }
    } catch (e) {
      setState(() => _isOrdering = false);
      _showError('Failed to place order. Please try again');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _conditionColor(String? condition) {
    final c = (condition ?? '').toLowerCase();
    if (c.contains('new')) return const Color(0xFF059669);
    if (c.contains('good')) return const Color(0xFF0E7490);
    return const Color(0xFFB45309);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final conditionColor = _conditionColor(book['condition']);
    final discount =
        book['buyingPrice'] != null &&
            book['askingPrice'] != null &&
            (book['buyingPrice'] as num) > 0
        ? (((book['buyingPrice'] as num) - (book['askingPrice'] as num)) /
                  (book['buyingPrice'] as num) *
                  100)
              .round()
        : 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          book['bookName'] ?? 'Book Details',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Book Card ────────────────────────────────────────────
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
                          brown.withValues(alpha: 0.15),
                          brown.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: brown.withValues(alpha: 0.4),
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
                            color: conditionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book['condition'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: conditionColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '৳${book['askingPrice'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: accentOrange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '৳${book['buyingPrice'] ?? 0}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            if (discount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$discount% off',
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
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

            // ── Seller Section ───────────────────────────────────────
            const SizedBox(height: 20),
            _buildSectionTitle('Seller'),
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
                    backgroundColor: brown.withValues(alpha: 0.15),
                    backgroundImage: (book['sellerPhoto'] ?? '').isNotEmpty
                        ? NetworkImage(book['sellerPhoto'])
                        : null,
                    child: (book['sellerPhoto'] ?? '').isEmpty
                        ? Text(
                            (book['sellerName'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: brown,
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
                          '${_sellerBooks.length + 1} book${_sellerBooks.length + 1 != 1 ? 's' : ''} listed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isMyBook)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: brown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: brown,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Seller's other books
            if (!_loadingSellerBooks && _sellerBooks.isNotEmpty) ...[
              const SizedBox(height: 12),
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
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sellerBooks.length,
                  itemBuilder: (context, index) {
                    final sb = _sellerBooks[index];
                    sb['sellerName'] = book['sellerName'];
                    sb['sellerPhoto'] = book['sellerPhoto'];
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
                                  color: brown.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    color: brown.withValues(alpha: 0.4),
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
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '৳${sb['askingPrice'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 12,
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

            // ── Delivery Address ─────────────────────────────────────
            if (!_isMyBook) ...[
              const SizedBox(height: 20),
              _buildSectionTitle('Delivery Address'),
              const SizedBox(height: 10),

              if (_loadingAddresses)
                const Center(child: CircularProgressIndicator(color: brown))
              else if (_addresses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressesScreen(),
                              ),
                            );
                            _loadAddresses();
                          },
                          icon: const Icon(Icons.add, color: brown),
                          label: const Text(
                            'Add Address',
                            style: TextStyle(color: brown),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: brown),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    ..._addresses.map((addr) {
                      final isSelected = _selectedAddress?['id'] == addr['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAddress = addr),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? brown.withValues(alpha: 0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? brown : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: addr['id'],
                                groupValue: _selectedAddress?['id'],
                                onChanged: (val) =>
                                    setState(() => _selectedAddress = addr),
                                activeColor: brown,
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                          MaterialPageRoute(
                            builder: (_) => const AddressesScreen(),
                          ),
                        );
                        _loadAddresses();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 15,
                            color: brown.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Add or manage addresses',
                            style: TextStyle(
                              fontSize: 12,
                              color: brown.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // ── Payment Method ─────────────────────────────────────
              const SizedBox(height: 20),
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 10),
              Column(
                children: _paymentOptions.map((option) {
                  final isSelected = _selectedPayment == option;
                  final color = _paymentColors[option]!;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPayment = option),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                option == 'Cash on Delivery'
                                    ? Icons.money_rounded
                                    : option == 'Bank'
                                    ? Icons.account_balance_outlined
                                    : Icons.phone_android_rounded,
                                color: color,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isSelected ? color : Colors.black87,
                              ),
                            ),
                          ),
                          Radio<String>(
                            value: option,
                            groupValue: _selectedPayment,
                            onChanged: (val) =>
                                setState(() => _selectedPayment = val!),
                            activeColor: color,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ── Order Summary ──────────────────────────────────────
              const SizedBox(height: 20),
              _buildSectionTitle('Order Summary'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _summaryRow('Book Price', '৳${book['askingPrice'] ?? 0}'),
                    _summaryRow('Delivery Fee', '৳50'),
                    const Divider(height: 16),
                    _summaryRow(
                      'Total',
                      '৳${(((book['askingPrice'] ?? 0) as num) + 50).toInt()}',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              // ── Buy Button ─────────────────────────────────────────
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
                          'Buy for ৳${(((book['askingPrice'] ?? 0) as num) + 50).toInt()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // If it's seller's own book
            if (_isMyBook) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: brown.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: brown.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: brown, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'This is your own listing. You cannot buy your own book.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: brown,
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? Colors.black87 : Colors.grey.shade500,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? accentOrange : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
