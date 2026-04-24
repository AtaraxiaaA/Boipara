import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buy_books_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference get _notifRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('notifications');

  // ── Status system ─────────────────────────────────────────────────────
  static const _statusOrder = [
    'ordered',
    'packaging',
    'picked_up',
    'out_for_delivery',
    'delivered',
  ];

  static const _statusLabels = {
    'ordered': 'Order Placed',
    'packaging': 'Packaging',
    'picked_up': 'Picked Up',
    'out_for_delivery': 'Out for Delivery',
    'delivered': 'Delivered',
  };

  static const _statusColors = {
    'ordered': Color(0xFF0E7490),
    'packaging': Color(0xFFB45309),
    'picked_up': Color(0xFF7C3AED),
    'out_for_delivery': Color(0xFF0E7490),
    'delivered': Color(0xFF059669),
  };

  static const _statusIcons = {
    'ordered': Icons.receipt_long_rounded,
    'packaging': Icons.inventory_2_rounded,
    'picked_up': Icons.handshake_rounded,
    'out_for_delivery': Icons.local_shipping_rounded,
    'delivered': Icons.check_circle_rounded,
  };

  // Next action labels for seller to tap
  static const _nextActions = {
    'ordered': 'Start Packaging',
    'packaging': 'Mark as Picked Up',
    'picked_up': 'Send Out for Delivery',
    'out_for_delivery': 'Mark as Delivered',
    'delivered': null, // final state
  };

  String _nextStatus(String current) {
    final i = _statusOrder.indexOf(current);
    return i >= 0 && i < _statusOrder.length - 1
        ? _statusOrder[i + 1]
        : current;
  }

  // ── Update order status ───────────────────────────────────────────────
  Future<void> _updateOrderStatus(String bookId, String newStatus) async {
    try {
      // Find order by bookId + sellerId
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('bookId', isEqualTo: bookId)
          .where('sellerId', isEqualTo: _uid)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _showSnack('Order not found', Colors.redAccent);
        return;
      }

      await snap.docs.first.reference.update({'status': newStatus});
      _showSnack(
        'Status updated: ${_statusLabels[newStatus]}',
        _statusColors[newStatus] ?? brown,
      );
    } catch (e) {
      _showSnack('Failed to update status', Colors.redAccent);
    }
  }

  // ── Get live order status ─────────────────────────────────────────────
  Stream<String>? _orderStatusStream(String bookId) {
    if (bookId.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('orders')
        .where('bookId', isEqualTo: bookId)
        .where('sellerId', isEqualTo: _uid)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return 'ordered';
          return (snap.docs.first.data()['status'] as String?) ?? 'ordered';
        });
  }

  Future<void> _markAllRead() async {
    final snapshot = await _notifRef.where('isRead', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _markRead(String docId) async {
    await _notifRef.doc(docId).update({'isRead': true});
  }

  Future<void> _deleteNotification(String docId) async {
    await _notifRef.doc(docId).delete();
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied!'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSnack(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Navigate to BookDetailScreen Q&A ──────────────────────────────────
  Future<void> _goToBookQA(Map<String, dynamic> notifData, String docId) async {
    await _markRead(docId);
    final bookId = notifData['bookId'] ?? '';
    if (bookId.isEmpty) {
      _showSnack('Book not found', Colors.redAccent);
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: brown)),
    );
    try {
      final bookDoc = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();
      if (!mounted) return;
      Navigator.pop(context);
      if (!bookDoc.exists) {
        _showSnack('Listing no longer exists', Colors.orange);
        return;
      }
      final bookData = bookDoc.data()!;
      bookData['id'] = bookDoc.id;
      try {
        final sd = await FirebaseFirestore.instance
            .collection('users')
            .doc(bookData['sellerId'])
            .get();
        bookData['sellerName'] = sd.data()?['username'] ?? 'Unknown';
        bookData['sellerPhoto'] = sd.data()?['profilePhoto'] ?? '';
      } catch (_) {
        bookData['sellerName'] = 'Unknown';
        bookData['sellerPhoto'] = '';
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: bookData)),
      );
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        _showSnack('Failed to open. Try again.', Colors.redAccent);
      }
    }
  }

  // ── Order detail sheet WITH seller management ─────────────────────────
  void _showOrderDetails(Map<String, dynamic> data, String docId) async {
    await _markRead(docId);
    final addr = data['deliveryAddress'] as Map<String, dynamic>?;
    final bookId = data['bookId'] ?? '';
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  decoration: BoxDecoration(
                    color: accentOrange.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: accentOrange.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentOrange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'New Order Received!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: brown,
                                  ),
                                ),
                                Text(
                                  _timeAgo(data['createdAt']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── SELLER STATUS MANAGEMENT ────────────────────────
                      if (bookId.isNotEmpty)
                        StreamBuilder<String>(
                          stream: _orderStatusStream(bookId),
                          builder: (context, statusSnap) {
                            final status = statusSnap.data ?? 'ordered';
                            final statusLabel = _statusLabels[status] ?? status;
                            final statusColor = _statusColors[status] ?? brown;
                            final statusIcon =
                                _statusIcons[status] ?? Icons.circle;
                            final nextAction = _nextActions[status];
                            final nextSt = _nextStatus(status);
                            final isDelivered = status == 'delivered';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section title
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '📦 Order Status',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: brown,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Current status card
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: statusColor.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          statusIcon,
                                          color: statusColor,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: statusColor,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isDelivered
                                                  ? 'Order complete ✅'
                                                  : 'Update status when ready',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (statusSnap.connectionState ==
                                          ConnectionState.active)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF059669,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 6,
                                                color: Color(0xFF059669),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Live',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Color(0xFF059669),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Progress steps
                                const SizedBox(height: 12),
                                Row(
                                  children: List.generate(_statusOrder.length, (
                                    i,
                                  ) {
                                    final stepStatus = _statusOrder[i];
                                    final stepColor =
                                        _statusColors[stepStatus] ??
                                        Colors.grey;
                                    final isDone =
                                        _statusOrder.indexOf(status) >= i;
                                    return Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: isDone
                                                    ? stepColor
                                                    : Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          if (i < _statusOrder.length - 1)
                                            const SizedBox(width: 2),
                                        ],
                                      ),
                                    );
                                  }),
                                ),

                                // Next action button
                                if (nextAction != null) ...[
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _updateOrderStatus(bookId, nextSt);
                                      },
                                      icon: Icon(
                                        _statusIcons[nextSt] ??
                                            Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: Text(
                                        nextAction,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _statusColors[nextSt] ?? brown,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Center(
                                    child: Text(
                                      'Buyer will see this update instantly',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),

                      // ── Book Details ────────────────────────────────────
                      _sectionHeader('📚 Book Details', accentOrange),
                      const SizedBox(height: 10),
                      _detailsCard([
                        _detailRow(
                          'Book Name',
                          data['bookName'] ?? '-',
                          Icons.book_rounded,
                          copyable: true,
                          onCopy: () => _copyToClipboard(
                            data['bookName'] ?? '',
                            'Book name',
                          ),
                        ),
                        _detailRow(
                          'Author',
                          data['authorName'] ?? '-',
                          Icons.person_outline,
                        ),
                        _detailRow(
                          'Asking Price',
                          '৳${data['askingPrice'] ?? '-'}',
                          Icons.sell_outlined,
                          highlight: true,
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _sectionHeader(
                        '👤 Buyer Details',
                        const Color(0xFF0E7490),
                      ),
                      const SizedBox(height: 10),
                      _detailsCard([
                        _detailRow(
                          'Buyer Name',
                          data['buyerName'] ?? '-',
                          Icons.person_rounded,
                        ),
                        if ((data['buyerPhone'] ?? '').toString().isNotEmpty)
                          _detailRow(
                            'Buyer Phone',
                            data['buyerPhone'],
                            Icons.phone_rounded,
                            highlight: true,
                            copyable: true,
                            onCopy: () => _copyToClipboard(
                              data['buyerPhone'] ?? '',
                              'Phone',
                            ),
                          ),
                        _detailRow(
                          'Payment Method',
                          data['paymentMethod'] ?? '-',
                          Icons.payments_outlined,
                          highlight: true,
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _sectionHeader(
                        '📍 Delivery Address',
                        const Color(0xFF059669),
                      ),
                      const SizedBox(height: 10),

                      if (addr == null ||
                          (addr['name'] ?? '').toString().isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'No delivery address saved with this order.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _detailsCard([
                          _detailRow(
                            'Recipient',
                            addr['name'] ?? '-',
                            Icons.person_outline,
                            copyable: true,
                            onCopy: () =>
                                _copyToClipboard(addr['name'] ?? '', 'Name'),
                          ),
                          _detailRow(
                            'Phone',
                            addr['phone'] ?? '-',
                            Icons.phone_rounded,
                            highlight: true,
                            copyable: true,
                            onCopy: () =>
                                _copyToClipboard(addr['phone'] ?? '', 'Phone'),
                          ),
                          if ((addr['backup1'] ?? '').toString().isNotEmpty)
                            _detailRow(
                              'Backup 1',
                              addr['backup1'],
                              Icons.phone_callback_outlined,
                              copyable: true,
                              onCopy: () =>
                                  _copyToClipboard(addr['backup1'], 'Backup'),
                            ),
                          if ((addr['backup2'] ?? '').toString().isNotEmpty)
                            _detailRow(
                              'Backup 2',
                              addr['backup2'],
                              Icons.phone_callback_outlined,
                              copyable: true,
                              onCopy: () =>
                                  _copyToClipboard(addr['backup2'], 'Backup'),
                            ),
                          _detailRow(
                            'Street',
                            addr['street'] ?? '-',
                            Icons.home_outlined,
                            copyable: true,
                            onCopy: () => _copyToClipboard(
                              addr['street'] ?? '',
                              'Street',
                            ),
                          ),
                          _detailRow(
                            'Upazila',
                            addr['upazila'] ?? '-',
                            Icons.place_outlined,
                          ),
                          _detailRow(
                            'District',
                            addr['district'] ?? '-',
                            Icons.location_city_outlined,
                          ),
                          _detailRow(
                            'Division',
                            addr['division'] ?? '-',
                            Icons.map_outlined,
                          ),
                          if ((addr['postalCode'] ?? '').toString().isNotEmpty)
                            _detailRow(
                              'Postal Code',
                              addr['postalCode'],
                              Icons.markunread_mailbox_outlined,
                            ),
                        ]),

                      if (addr != null &&
                          (addr['name'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final fullAddr =
                                  '${addr['name']}\n${addr['phone']}'
                                  '${(addr['backup1'] ?? '').isNotEmpty ? '\n${addr['backup1']}' : ''}'
                                  '${(addr['backup2'] ?? '').isNotEmpty ? '\n${addr['backup2']}' : ''}'
                                  '\n${addr['street']}, ${addr['upazila']}, ${addr['district']}, ${addr['division']}'
                                  '${(addr['postalCode'] ?? '').isNotEmpty ? ' - ${addr['postalCode']}' : ''}';
                              _copyToClipboard(fullAddr, 'Full address');
                            },
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Copy Full Address',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brown,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  // ── Helpers ───────────────────────────────────────────────────────────
  IconData _iconFor(String type) {
    switch (type) {
      case 'new_order':
        return Icons.shopping_bag_rounded;
      case 'new_question':
        return Icons.help_outline_rounded;
      case 'new_answer':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'new_order':
        return accentOrange;
      case 'new_question':
        return const Color(0xFF0E7490);
      case 'new_answer':
        return accentOrange;
      default:
        return brown;
    }
  }

  String _tapHintFor(String type) {
    switch (type) {
      case 'new_order':
        return 'Tap to manage order & update status';
      case 'new_question':
        return 'Tap to view & answer the question';
      case 'new_answer':
        return 'Tap to view the answer & reply';
      default:
        return 'Tap to open';
    }
  }

  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: brown,
          ),
        ),
      ],
    );
  }

  Widget _detailsCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: rows),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
    bool copyable = false,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? accentOrange : Colors.black87,
              ),
            ),
          ),
          if (copyable && value.isNotEmpty)
            GestureDetector(
              onTap: onCopy,
              child: Icon(
                Icons.copy_outlined,
                size: 15,
                color: Colors.grey.shade400,
              ),
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
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notifRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: brown));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'You\'ll be notified about orders, questions, and answers',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final isRead = data['isRead'] == true;
              final type = data['type'] ?? '';
              final addr = data['deliveryAddress'] as Map<String, dynamic>?;
              final iconColor = _colorFor(type);

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) => _deleteNotification(docId),
                child: GestureDetector(
                  onTap: () {
                    if (type == 'new_order') {
                      _showOrderDetails(data, docId);
                    } else if (type == 'new_question' || type == 'new_answer') {
                      _goToBookQA(data, docId);
                    } else {
                      _markRead(docId);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white
                          : iconColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isRead
                            ? Colors.grey.shade200
                            : iconColor.withValues(alpha: 0.35),
                        width: isRead ? 1 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconFor(type),
                              color: iconColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data['title'] ?? '',
                                        style: TextStyle(
                                          fontWeight: isRead
                                              ? FontWeight.w600
                                              : FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: iconColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['body'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),

                                // Order: show status + payment preview chips
                                if (type == 'new_order') ...[
                                  const SizedBox(height: 8),
                                  // Live status badge
                                  if ((data['bookId'] ?? '').isNotEmpty)
                                    StreamBuilder<String>(
                                      stream: _orderStatusStream(
                                        data['bookId'],
                                      ),
                                      builder: (_, statusSnap) {
                                        final s = statusSnap.data ?? 'ordered';
                                        final sc =
                                            _statusColors[s] ?? Colors.grey;
                                        final sl = _statusLabels[s] ?? s;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: sc.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: sc.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 7,
                                                color: sc,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                sl,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: sc,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if ((data['paymentMethod'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        _previewChip(
                                          Icons.payments_outlined,
                                          data['paymentMethod'],
                                        ),
                                      if (addr != null &&
                                          (addr['district'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                        _previewChip(
                                          Icons.location_on_outlined,
                                          addr['district'],
                                        ),
                                      if (addr != null &&
                                          (addr['phone'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                        _previewChip(
                                          Icons.phone_outlined,
                                          addr['phone'],
                                        ),
                                    ],
                                  ),
                                ],

                                // Q&A previews
                                if (type == 'new_question' ||
                                    type == 'new_answer') ...[
                                  const SizedBox(height: 8),
                                  if ((data['bookName'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    _previewChip(
                                      Icons.book_outlined,
                                      data['bookName'],
                                    ),
                                  if ((data['question'] ?? '')
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        '"${data['question']}"',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                  if (type == 'new_answer' &&
                                      (data['answer'] ?? '')
                                          .toString()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accentOrange.withValues(
                                          alpha: 0.06,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: accentOrange.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          if (data['isSeller'] == true) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: accentOrange,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Seller',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                          Expanded(
                                            child: Text(
                                              data['answer'],
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],

                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 11,
                                        color: iconColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _tapHintFor(type),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: iconColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _timeAgo(data['createdAt']),
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _previewChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Badge Widget ─────────────────────────────────────────────────
class NotificationBadge extends StatelessWidget {
  final Widget child;
  const NotificationBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return child;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        if (count == 0) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
