import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackDeliveryScreen extends StatelessWidget {
  const TrackDeliveryScreen({super.key});

  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

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

  Color _colorFor(String s) => _statusColors[s] ?? Colors.grey;
  IconData _iconFor(String s) => _statusIcons[s] ?? Icons.circle;
  String _labelFor(String s) => _statusLabels[s] ?? s;
  int _stepIndex(String s) => _statusOrder.indexOf(s).clamp(0, 4);

  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
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
          'Track Delivery',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _uid.isEmpty
          ? const Center(child: Text('Please log in to view orders'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('buyerId', isEqualTo: _uid)
                  .snapshots(), // ✅ removed orderBy
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: brown),
                  );
                }

                List docs = snap.data?.docs ?? [];

                // ✅ SORT manually (NO UI CHANGE)
                docs.sort((a, b) {
                  final aTime = (a['createdAt'] as Timestamp?)?.toDate();
                  final bTime = (b['createdAt'] as Timestamp?)?.toDate();

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return bTime.compareTo(aTime);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Books you buy will appear here',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    data['orderId'] = doc.id;

                    return _OrderCard(
                      data: data,
                      colorFor: _colorFor,
                      iconFor: _iconFor,
                      labelFor: _labelFor,
                      stepIndex: _stepIndex,
                      timeAgo: _timeAgo,
                      statusOrder: _statusOrder,
                      statusLabels: _statusLabels,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color Function(String) colorFor;
  final IconData Function(String) iconFor;
  final String Function(String) labelFor;
  final int Function(String) stepIndex;
  final String Function(dynamic) timeAgo;
  final List<String> statusOrder;
  final Map<String, String> statusLabels;

  const _OrderCard({
    required this.data,
    required this.colorFor,
    required this.iconFor,
    required this.labelFor,
    required this.stepIndex,
    required this.timeAgo,
    required this.statusOrder,
    required this.statusLabels,
  });

  @override
  Widget build(BuildContext context) {
    final orderId = data['orderId'] as String?;
    final bookTitle = data['bookName'] as String? ?? 'Unknown Book';
    final status = data['status'] as String? ?? 'ordered';
    final createdAt = data['createdAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: TrackDeliveryScreen.brown),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bookTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: $orderId',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Ordered: ${timeAgo(createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: statusOrder.map((s) {
                final isActive = stepIndex(status) >= stepIndex(s);
                final isCurrent = stepIndex(status) == stepIndex(s);
                return Expanded(
                  child: Column(
                    children: [
                      Icon(
                        iconFor(s),
                        color: isActive ? colorFor(s) : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labelFor(s),
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? colorFor(s) : Colors.grey,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
