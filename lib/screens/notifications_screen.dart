import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void _showOrderDetails(Map<String, dynamic> data, String docId) async {
    await _markRead(docId);

    final addr = data['deliveryAddress'] as Map<String, dynamic>?;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle + header
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
                      // ── Book Details ───────────────────────────────
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

                      // ── Buyer Details ──────────────────────────────
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
                        _detailRow(
                          'Payment Method',
                          data['paymentMethod'] ?? '-',
                          Icons.payments_outlined,
                          highlight: true,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── Delivery Address ───────────────────────────
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
                                  'No delivery address was saved with this order. Contact the buyer directly.',
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
                            'Recipient Name',
                            addr['name'] ?? '-',
                            Icons.person_outline,
                            copyable: true,
                            onCopy: () => _copyToClipboard(
                              addr['name'] ?? '',
                              'Recipient name',
                            ),
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
                              'Backup Phone 1',
                              addr['backup1'],
                              Icons.phone_callback_outlined,
                              copyable: true,
                              onCopy: () => _copyToClipboard(
                                addr['backup1'],
                                'Backup phone 1',
                              ),
                            ),
                          if ((addr['backup2'] ?? '').toString().isNotEmpty)
                            _detailRow(
                              'Backup Phone 2',
                              addr['backup2'],
                              Icons.phone_callback_outlined,
                              copyable: true,
                              onCopy: () => _copyToClipboard(
                                addr['backup2'],
                                'Backup phone 2',
                              ),
                            ),
                          _detailRow(
                            'Street / House',
                            addr['street'] ?? '-',
                            Icons.home_outlined,
                            copyable: true,
                            onCopy: () => _copyToClipboard(
                              addr['street'] ?? '',
                              'Street',
                            ),
                          ),
                          _detailRow(
                            'Upazila / Thana',
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

                      const SizedBox(height: 20),

                      // ── Copy full address button ───────────────────
                      if (addr != null &&
                          (addr['name'] ?? '').toString().isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final fullAddr =
                                  '''${addr['name']}
${addr['phone']}${(addr['backup1'] ?? '').isNotEmpty ? '\n${addr['backup1']}' : ''}${(addr['backup2'] ?? '').isNotEmpty ? '\n${addr['backup2']}' : ''}
${addr['street']}, ${addr['upazila']}, ${addr['district']}, ${addr['division']}${(addr['postalCode'] ?? '').isNotEmpty ? ' - ${addr['postalCode']}' : ''}''';
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
                        const SizedBox(height: 10),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
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
                      'You\'ll be notified when someone buys your book',
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
              final isOrder = data['type'] == 'new_order';
              final addr = data['deliveryAddress'] as Map<String, dynamic>?;

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
                  onTap: () => isOrder
                      ? _showOrderDetails(data, docId)
                      : _markRead(docId),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white
                          : accentOrange.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isRead
                            ? Colors.grey.shade200
                            : accentOrange.withValues(alpha: 0.35),
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
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isOrder
                                  ? accentOrange.withValues(alpha: 0.12)
                                  : brown.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isOrder
                                  ? Icons.shopping_bag_rounded
                                  : Icons.notifications_rounded,
                              color: isOrder ? accentOrange : brown,
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
                                        decoration: const BoxDecoration(
                                          color: accentOrange,
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

                                // Preview chips
                                if (isOrder) ...[
                                  const SizedBox(height: 8),
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
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentOrange.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 11,
                                          color: accentOrange,
                                        ),
                                        const SizedBox(width: 5),
                                        const Text(
                                          'Tap for full delivery details',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: accentOrange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

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

// ── Notification Badge Widget ──────────────────────────────────────────
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
