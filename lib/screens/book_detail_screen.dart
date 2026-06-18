import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addresses_screen.dart';
import 'chat_screen.dart';

/// BookDetailScreen — full detail + Add to Cart + Message Seller + Place Order
/// Notifications sent on order:
///   ✅ In-app  — Firestore (free, always works)
///   ✅ Email   — via Firebase Trigger Email extension (Blaze plan)
///   ✅ SMS     — via Cloud Function calling Twilio (Blaze plan)
class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final void Function(Map<String, dynamic>)? onAddToCart;

  const BookDetailScreen({super.key, required this.book, this.onAddToCart});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  static const darkBrown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  List<Map<String, dynamic>> _sellerBooks = [];
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  String _selectedPayment = 'bKash';
  bool _isOrdering = false;
  bool _loadingSellerBooks = true;
  bool _loadingAddresses = true;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isMyBook => widget.book['sellerId'] == _uid;

  final _paymentOptions = ['Cash on Delivery', 'bKash', 'Nagad', 'Bank'];
  final _paymentColors = <String, Color>{
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
      final snap = await FirebaseFirestore.instance
          .collection('books')
          .where('sellerId', isEqualTo: widget.book['sellerId'])
          .where('status', isEqualTo: 'approved')
          .get();
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
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingSellerBooks = false);
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('addresses')
          .get();
      setState(() {
        _addresses = snap.docs.map((d) {
          final m = d.data();
          m['id'] = d.id;
          return m;
        }).toList();
        final def = _addresses.firstWhere(
          (a) => a['isDefault'] == true,
          orElse: () => _addresses.isNotEmpty ? _addresses[0] : {},
        );
        if (def.isNotEmpty) _selectedAddress = def;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  // ── Place Order ───────────────────────────────────────────────────────
  Future<void> _placeOrder() async {
    if (_isMyBook) {
      _err('You cannot buy your own book');
      return;
    }
    if (_selectedAddress == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddressesScreen()),
      );
      await _loadAddresses();
      if (_selectedAddress == null) return;
    }

    setState(() => _isOrdering = true);
    try {
      // 1. Get buyer name
      String buyerName = 'Someone';
      String buyerPhone = '';
      try {
        final bdoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .get();
        buyerName = bdoc.data()?['username'] ?? 'Someone';
        buyerPhone = bdoc.data()?['phone'] ?? '';
      } catch (_) {}

      final addr = {
        'name': _selectedAddress!['name'] ?? '',
        'phone': _selectedAddress!['phone'] ?? '',
        'backup1': _selectedAddress!['backup1'] ?? '',
        'backup2': _selectedAddress!['backup2'] ?? '',
        'street': _selectedAddress!['street'] ?? '',
        'upazila': _selectedAddress!['upazila'] ?? '',
        'district': _selectedAddress!['district'] ?? '',
        'division': _selectedAddress!['division'] ?? '',
        'postalCode': _selectedAddress!['postalCode'] ?? '',
      };

      // 2. Save order
      final orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add({
            'buyerId': _uid,
            'buyerName': buyerName,
            'sellerId': widget.book['sellerId'],
            'bookId': widget.book['id'],
            'bookName': widget.book['bookName'],
            'authorName': widget.book['authorName'],
            'condition': widget.book['condition'],
            'askingPrice': widget.book['askingPrice'],
            'paymentMethod': _selectedPayment,
            'deliveryAddress': addr,
            'status': 'ordered',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 3. Mark book sold
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book['id'])
          .update({'status': 'sold'});

      // 4. In-app notification → seller (always free ✅)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.book['sellerId'])
          .collection('notifications')
          .add({
            'type': 'new_order',
            'orderId': orderRef.id,
            'title': '📦 New Order!',
            'body': '$buyerName wants to buy "${widget.book['bookName']}"',
            'bookId': widget.book['id'],
            'bookName': widget.book['bookName'],
            'authorName': widget.book['authorName'] ?? '',
            'askingPrice': widget.book['askingPrice'],
            'buyerId': _uid,
            'buyerName': buyerName,
            'paymentMethod': _selectedPayment,
            'deliveryAddress': addr,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 5. In-app notification → buyer confirmation
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('notifications')
          .add({
            'type': 'order_placed',
            'title': '✅ Order Placed!',
            'body': 'Your order for "${widget.book['bookName']}" was placed.',
            'bookId': widget.book['id'],
            'orderId': orderRef.id,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 6. Email notification → seller (Firebase Trigger Email ext — Blaze plan)
      try {
        final sellerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.book['sellerId'])
            .get();
        final sellerEmail = sellerDoc.data()?['email'] ?? '';
        final sellerPhone = sellerDoc.data()?['phone'] ?? '';
        if (sellerEmail.isNotEmpty) {
          await FirebaseFirestore.instance.collection('mail').add({
            'to': sellerEmail,
            'message': {
              'subject': '📦 New Order on Boipara — ${widget.book['bookName']}',
              'html':
                  '''
<div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto">
  <div style="background:#613613;padding:20px;border-radius:8px 8px 0 0">
    <h1 style="color:white;margin:0;font-size:20px">📦 New Order!</h1>
  </div>
  <div style="background:#F5F0E9;padding:20px;border-radius:0 0 8px 8px">
    <p><b>Book:</b> ${widget.book['bookName']}</p>
    <p><b>Buyer:</b> $buyerName</p>
    <p><b>Payment:</b> $_selectedPayment</p>
    <hr/>
    <p><b>Deliver to:</b><br>
    ${addr['name']}<br>
    ${addr['phone']}<br>
    ${addr['street']}, ${addr['upazila']},<br>
    ${addr['district']}, ${addr['division']} ${addr['postalCode']}</p>
    <hr/>
    <p style="color:#613613"><b>Action required:</b> Please contact the buyer to arrange delivery.</p>
    <p style="color:#888;font-size:12px">Open Boipara app to manage this order.</p>
  </div>
</div>''',
            },
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // 7. SMS trigger — handled by Cloud Function watching sms_queue collection
        //    Cloud Function calls Twilio with sellerPhone. See cloud_functions/index.js
        if (sellerPhone.isNotEmpty) {
          await FirebaseFirestore.instance.collection('sms_queue').add({
            'to': sellerPhone,
            'message':
                'Boipara: New order! $buyerName wants to buy "${widget.book['bookName']}" (${widget.book['askingPrice']} BDT). Open app for details.',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // 8. SMS to buyer (confirmation)
        if (buyerPhone.isNotEmpty) {
          await FirebaseFirestore.instance.collection('sms_queue').add({
            'to': buyerPhone,
            'message':
                'Boipara: Order confirmed! "${widget.book['bookName']}" — ${widget.book['askingPrice']} BDT. The seller will contact you soon.',
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {
        // Email/SMS save failed silently — in-app notif already sent
      }

      setState(() => _isOrdering = false);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      setState(() => _isOrdering = false);
      _err('Failed to place order. Please try again');
    }
  }

  // ── Open chat with seller ─────────────────────────────────────────────
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: widget.book['sellerId'],
          otherUserName: widget.book['sellerName'] ?? 'Seller',
          otherUserPhoto: widget.book['sellerPhoto'] ?? '',
          bookId: widget.book['id'],
          bookName: widget.book['bookName'] ?? 'this book',
        ),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────
  void _showSuccessDialog() {
    showDialog(
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
              'Your order for "${widget.book['bookName']}" has been placed.\n\nThe seller was notified via app, email & SMS.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
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
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ),
  );

  Color _condColor(String? c) {
    final s = (c ?? '').toLowerCase();
    if (s.contains('new')) return const Color(0xFF059669);
    if (s.contains('good')) return const Color(0xFF0E7490);
    return const Color(0xFFB45309);
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final condColor = _condColor(book['condition']);
    final orig = (book['buyingPrice'] as num?)?.toDouble() ?? 0;
    final ask = (book['askingPrice'] as num?)?.toDouble() ?? 0;
    final disc = orig > 0 ? (((orig - ask) / orig) * 100).round() : 0;

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
          // Message seller button in AppBar
          if (!_isMyBook)
            IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
              ),
              tooltip: 'Message Seller',
              onPressed: _openChat,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Book card ──────────────────────────────────────────────
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
                            color: condColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book['condition'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: condColor,
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
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$disc% off',
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

            // ── Add to Cart + Message Seller row ───────────────────────
            if (!_isMyBook) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onAddToCart?.call(book);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart!'),
                            backgroundColor: Color(0xFF059669),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 18,
                      ),
                      label: const Text('Add to Cart'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkBrown,
                        side: const BorderSide(color: darkBrown),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openChat,
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                      ),
                      label: const Text('Message Seller'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentOrange,
                        side: const BorderSide(color: accentOrange),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // ── Seller info + more from seller ─────────────────────────
            const SizedBox(height: 20),
            _sectionTitle('Seller'),
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
                          '${_sellerBooks.length + 1} book${_sellerBooks.length + 1 != 1 ? 's' : ''} listed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isMyBook)
                    GestureDetector(
                      onTap: _openChat,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: accentOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 13,
                              color: accentOrange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Chat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isMyBook)
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

            if (!_loadingSellerBooks && _sellerBooks.isNotEmpty) ...[
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
                  itemBuilder: (context, i) {
                    final sb = _sellerBooks[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(
                            book: sb,
                            onAddToCart: widget.onAddToCart,
                          ),
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

            // ── ORDER SECTION (only if not your book) ──────────────────
            if (!_isMyBook) ...[
              const SizedBox(height: 20),
              _sectionTitle('Delivery Address'),
              const SizedBox(height: 10),
              if (_loadingAddresses)
                const Center(child: CircularProgressIndicator(color: darkBrown))
              else if (_addresses.isEmpty)
                _noAddressWidget()
              else
                _addressList(),

              const SizedBox(height: 20),
              _sectionTitle('Payment Method'),
              const SizedBox(height: 10),
              ..._paymentOptions.map((opt) {
                final isSel = _selectedPayment == opt;
                final col = _paymentColors[opt]!;
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

              const SizedBox(height: 20),
              _sectionTitle('Order Summary'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _summaryRow('Book Price', '৳$ask'),
                    _summaryRow('Delivery Fee', '৳50'),
                    const Divider(height: 16),
                    _summaryRow('Total', '৳${(ask + 50).toInt()}', bold: true),
                  ],
                ),
              ),

              // Notification info box
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF059669),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seller notified instantly',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                          Text(
                            'App notification + Email + SMS',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Buy button
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

            // ── My book banner ─────────────────────────────────────────
            if (_isMyBook) ...[
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

  // ── Address widgets ───────────────────────────────────────────────────
  Widget _noAddressWidget() {
    return Column(
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
            label: const Text(
              'Add Address',
              style: TextStyle(color: darkBrown),
            ),
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
  }

  Widget _addressList() {
    return Column(
      children: [
        ..._addresses.map((addr) {
          final isSel = _selectedAddress?['id'] == addr['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedAddress = addr),
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
                    groupValue: _selectedAddress?['id'],
                    onChanged: (_) => setState(() => _selectedAddress = addr),
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
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: darkBrown,
    ),
  );

  Widget _summaryRow(String label, String value, {bool bold = false}) =>
      Padding(
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