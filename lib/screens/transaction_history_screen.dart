import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final int initialTab;
  const TransactionHistoryScreen({super.key, this.initialTab = 0});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);
  static const green = Color(0xFF059669);

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'This Month', 'Last Month'];

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Orders are a "transaction" when they are at any status.
  /// Status mapping: delivered = Completed, ordered/packaging/picked_up/out_for_delivery = Pending
  String _txnStatus(String orderStatus) {
    return orderStatus == 'delivered' ? 'Completed' : 'Pending';
  }

  Color _statusColor(String txnStatus) {
    switch (txnStatus) {
      case 'Completed':
        return green;
      case 'Pending':
        return const Color(0xFFB45309);
      default:
        return Colors.grey;
    }
  }

  IconData _methodIcon(String method) {
    if (method.toLowerCase().contains('bank')) {
      return Icons.account_balance_outlined;
    }
    return Icons.phone_android_rounded;
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '—';
    final dt = ts.toDate();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// Filter by createdAt month
  bool _passesFilter(Timestamp? ts) {
    if (_selectedFilter == 'All' || ts == null) return true;
    final dt = ts.toDate();
    final now = DateTime.now();
    if (_selectedFilter == 'This Month') {
      return dt.month == now.month && dt.year == now.year;
    }
    if (_selectedFilter == 'Last Month') {
      final lastMonth = DateTime(now.year, now.month - 1);
      return dt.month == lastMonth.month && dt.year == lastMonth.year;
    }
    return true;
  }

  String _shortOrderId(String docId) {
    return 'TXN-${docId.substring(0, 6).toUpperCase()}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: const Center(child: Text('Please log in to view transactions')),
      );
    }

    // Fetch both purchase and earning streams simultaneously
    final purchasesStream = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: _uid)
        .snapshots();

    final earningsStream = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: _uid)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: purchasesStream,
      builder: (context, purchaseSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: earningsStream,
          builder: (context, earningSnap) {
            final isLoading =
                purchaseSnap.connectionState == ConnectionState.waiting ||
                earningSnap.connectionState == ConnectionState.waiting;

            // All purchase docs sorted newest first
            List<QueryDocumentSnapshot> purchaseDocs = List.from(
              purchaseSnap.data?.docs ?? [],
            );
            purchaseDocs.sort((a, b) {
              final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
              final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
              if (aTs == null && bTs == null) return 0;
              if (aTs == null) return 1;
              if (bTs == null) return -1;
              return bTs.compareTo(aTs);
            });

            // All earning docs sorted newest first
            List<QueryDocumentSnapshot> earningDocs = List.from(
              earningSnap.data?.docs ?? [],
            );
            earningDocs.sort((a, b) {
              final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
              final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
              if (aTs == null && bTs == null) return 0;
              if (aTs == null) return 1;
              if (bTs == null) return -1;
              return bTs.compareTo(aTs);
            });

            // Apply date filter
            final filteredPurchases = purchaseDocs.where((d) {
              final ts = (d.data() as Map)['createdAt'] as Timestamp?;
              return _passesFilter(ts);
            }).toList();

            final filteredEarnings = earningDocs.where((d) {
              final ts = (d.data() as Map)['createdAt'] as Timestamp?;
              return _passesFilter(ts);
            }).toList();

            // Totals — only delivered orders count as "Completed"
            double totalSpent = purchaseDocs.fold(0, (sum, d) {
              final data = d.data() as Map;
              if (data['status'] == 'delivered') {
                return sum + ((data['askingPrice'] as num?)?.toDouble() ?? 0);
              }
              return sum;
            });

            double totalEarned = earningDocs.fold(0, (sum, d) {
              final data = d.data() as Map;
              if (data['status'] == 'delivered') {
                return sum + ((data['askingPrice'] as num?)?.toDouble() ?? 0);
              }
              return sum;
            });

            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: _buildAppBar(),
              body: Column(
                children: [
                  // ── Summary cards ──────────────────────────────────────
                  Container(
                    color: brown,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            label: 'Total Spent',
                            amount: totalSpent,
                            icon: Icons.shopping_bag_outlined,
                            color: accentOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            label: 'Total Earned',
                            amount: totalEarned,
                            icon: Icons.payments_outlined,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Filter chips ───────────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: _filters.map((f) {
                        final selected = _selectedFilter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? brown : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── Tab views ──────────────────────────────────────────
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: brown),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildList(filteredPurchases, isPurchase: true),
                              _buildList(filteredEarnings, isPurchase: false),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: brown,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Transaction History',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: accentOrange,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'Purchases'),
          Tab(text: 'Earnings'),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '৳${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Transaction list ──────────────────────────────────────────────────────

  Widget _buildList(
    List<QueryDocumentSnapshot> docs, {
    required bool isPurchase,
  }) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              isPurchase ? 'No purchases yet' : 'No earnings yet',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPurchase
                  ? 'Books you buy will show here'
                  : 'Books you sell will show here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
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
        return _TxnCard(
          docId: doc.id,
          data: data,
          isPurchase: isPurchase,
          txnStatus: _txnStatus(data['status'] as String? ?? ''),
          statusColor: _statusColor(
            _txnStatus(data['status'] as String? ?? ''),
          ),
          methodIcon: _methodIcon(data['paymentMethod'] as String? ?? ''),
          dateStr: _formatDate(data['createdAt'] as Timestamp?),
          timeStr: _formatTime(data['createdAt'] as Timestamp?),
          shortId: _shortOrderId(doc.id),
          onTap: () => _showDetail(
            context,
            docId: doc.id,
            data: data,
            isPurchase: isPurchase,
          ),
        );
      },
    );
  }

  // ── Detail bottom sheet ───────────────────────────────────────────────────

  void _showDetail(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> data,
    required bool isPurchase,
  }) {
    final txnStatus = _txnStatus(data['status'] as String? ?? '');
    final statusColor = _statusColor(txnStatus);
    final amount = (data['askingPrice'] as num?)?.toDouble() ?? 0;
    final method = data['paymentMethod'] as String? ?? '—';
    final bookName = data['bookName'] as String? ?? '—';
    final authorName = data['authorName'] as String? ?? '';
    final dateStr = _formatDate(data['createdAt'] as Timestamp?);
    final timeStr = _formatTime(data['createdAt'] as Timestamp?);
    final deliveryAddr = data['deliveryAddress'] as Map<String, dynamic>?;
    final orderStatus = data['status'] as String? ?? '—';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  // Handle bar
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

                  // Amount circle
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: (isPurchase ? accentOrange : green)
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPurchase
                                ? Icons.shopping_bag_outlined
                                : Icons.payments_outlined,
                            size: 32,
                            color: isPurchase ? accentOrange : green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${isPurchase ? '-' : '+'}৳${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isPurchase ? Colors.black87 : green,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            txnStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Detail rows
                  _detailRow('Transaction ID', _shortOrderId(docId)),
                  _detailRow(
                    'Book',
                    authorName.isNotEmpty
                        ? '$bookName — $authorName'
                        : bookName,
                  ),
                  _detailRow('Type', isPurchase ? 'Purchase' : 'Sale'),
                  _detailRow('Payment Method', method),
                  _detailRow('Delivery Status', _orderStatusLabel(orderStatus)),
                  _detailRow('Date', dateStr),
                  _detailRow('Time', timeStr),

                  // Delivery address (purchases only)
                  if (isPurchase && deliveryAddr != null) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _addressBlock(deliveryAddr),
                  ],

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _orderStatusLabel(String status) {
    const labels = {
      'ordered': 'Order Placed',
      'packaging': 'Packaging',
      'picked_up': 'Picked Up',
      'out_for_delivery': 'Out for Delivery',
      'delivered': 'Delivered',
    };
    return labels[status] ?? status;
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressBlock(Map<String, dynamic> addr) {
    final parts = [
      addr['name'],
      addr['phone'],
      addr['street'],
      addr['upazila'],
      addr['district'],
      addr['division'],
    ].where((p) => p != null && p.toString().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.isNotEmpty ? parts : '—',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Card Widget ───────────────────────────────────────────────────

class _TxnCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final bool isPurchase;
  final String txnStatus;
  final Color statusColor;
  final IconData methodIcon;
  final String dateStr;
  final String timeStr;
  final String shortId;
  final VoidCallback onTap;

  static const accentOrange = Color(0xFFE07B39);
  static const green = Color(0xFF059669);

  const _TxnCard({
    required this.docId,
    required this.data,
    required this.isPurchase,
    required this.txnStatus,
    required this.statusColor,
    required this.methodIcon,
    required this.dateStr,
    required this.timeStr,
    required this.shortId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bookName = data['bookName'] as String? ?? 'Unknown Book';
    final authorName = data['authorName'] as String? ?? '';
    final amount = (data['askingPrice'] as num?)?.toDouble() ?? 0;
    final method = data['paymentMethod'] as String? ?? '—';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Method icon container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (isPurchase ? accentOrange : green).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                methodIcon,
                color: isPurchase ? accentOrange : green,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (authorName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      authorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        shortId,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Text(
                        '  ·  ',
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                      Text(
                        '$dateStr  $timeStr',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount & status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPurchase ? '-' : '+'}৳${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPurchase ? Colors.black87 : green,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    txnStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  method,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
