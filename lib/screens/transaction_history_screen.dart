import 'package:flutter/material.dart';

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

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'This Month', 'Last Month'];

  // Placeholder transactions — replace with API later
  final List<Map<String, dynamic>> _purchases = [
    {
      'id': 'TXN-8821',
      'book': 'Atomic Habits',
      'author': 'James Clear',
      'amount': 420,
      'date': 'Mar 7, 2026',
      'time': '10:32 AM',
      'method': 'bKash',
      'methodIcon': Icons.phone_android_rounded,
      'status': 'Completed',
      'type': 'Purchase',
    },
    {
      'id': 'TXN-8796',
      'book': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'amount': 500,
      'date': 'Mar 5, 2026',
      'time': '3:10 PM',
      'method': 'Nagad',
      'methodIcon': Icons.phone_android_rounded,
      'status': 'Pending',
      'type': 'Purchase',
    },
    {
      'id': 'TXN-8701',
      'book': 'The Alchemist',
      'author': 'Paulo Coelho',
      'amount': 350,
      'date': 'Feb 28, 2026',
      'time': '11:00 AM',
      'method': 'bKash',
      'methodIcon': Icons.phone_android_rounded,
      'status': 'Completed',
      'type': 'Purchase',
    },
    {
      'id': 'TXN-8634',
      'book': '1984',
      'author': 'George Orwell',
      'amount': 280,
      'date': 'Feb 20, 2026',
      'time': '9:30 AM',
      'method': 'Bank Transfer',
      'methodIcon': Icons.account_balance_outlined,
      'status': 'Completed',
      'type': 'Purchase',
    },
    {
      'id': 'TXN-8501',
      'book': 'Himu',
      'author': 'Humayun Ahmed',
      'amount': 150,
      'date': 'Jan 25, 2026',
      'time': '2:45 PM',
      'method': 'Nagad',
      'methodIcon': Icons.phone_android_rounded,
      'status': 'Refunded',
      'type': 'Purchase',
    },
  ];

  final List<Map<String, dynamic>> _earnings = [
    {
      'id': 'TXN-9101',
      'book': 'Pather Panchali',
      'author': 'Bibhutibhushan',
      'amount': 200,
      'date': 'Mar 1, 2026',
      'time': '4:20 PM',
      'method': 'bKash',
      'methodIcon': Icons.phone_android_rounded,
      'status': 'Completed',
      'type': 'Sale',
    },
    {
      'id': 'TXN-9045',
      'book': 'Lalsalu',
      'author': 'Syed Waliullah',
      'amount': 220,
      'date': 'Feb 15, 2026',
      'time': '1:00 PM',
      'method': 'Nagad',
      'methodIcon': Icons.phone_android_rounded,
      'status': 'Completed',
      'type': 'Sale',
    },
    {
      'id': 'TXN-8988',
      'book': 'Aranyak',
      'author': 'Bibhutibhushan',
      'amount': 260,
      'date': 'Jan 30, 2026',
      'time': '11:30 AM',
      'method': 'Bank Transfer',
      'methodIcon': Icons.account_balance_outlined,
      'status': 'Completed',
      'type': 'Sale',
    },
  ];

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> list) {
    if (_selectedFilter == 'All') return list;
    if (_selectedFilter == 'This Month') {
      return list.where((t) => t['date'].toString().contains('Mar')).toList();
    }
    if (_selectedFilter == 'Last Month') {
      return list.where((t) => t['date'].toString().contains('Feb')).toList();
    }
    return list;
  }

  int get _totalSpent => _purchases
      .where((t) => t['status'] == 'Completed')
      .fold(0, (sum, t) => sum + (t['amount'] as int));

  int get _totalEarned => _earnings
      .where((t) => t['status'] == 'Completed')
      .fold(0, (sum, t) => sum + (t['amount'] as int));

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

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF059669);
      case 'Pending':
        return const Color(0xFFB45309);
      case 'Refunded':
        return const Color(0xFF7C3AED);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPurchases = _applyFilter(_purchases);
    final filteredEarnings = _applyFilter(_earnings);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Purchases'),
            Tab(text: 'Earnings'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            color: brown,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    label: 'Total Spent',
                    amount: _totalSpent,
                    icon: Icons.shopping_bag_outlined,
                    color: accentOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    label: 'Total Earned',
                    amount: _totalEarned,
                    icon: Icons.payments_outlined,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filters.map((f) {
                final selected = _selectedFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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
                        color: selected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Transaction lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(filteredPurchases, isPurchase: true),
                _buildTransactionList(filteredEarnings, isPurchase: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required int amount,
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
                '৳$amount',
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

  Widget _buildTransactionList(
    List<Map<String, dynamic>> transactions, {
    required bool isPurchase,
  }) {
    if (transactions.isEmpty) {
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
              'No transactions found',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(
          transactions[index],
          isPurchase: isPurchase,
        );
      },
    );
  }

  Widget _buildTransactionCard(
    Map<String, dynamic> txn, {
    required bool isPurchase,
  }) {
    final statusColor = _statusColor(txn['status']);

    return GestureDetector(
      onTap: () => _showTransactionDetail(txn, isPurchase: isPurchase),
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
            // Method icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (isPurchase ? accentOrange : const Color(0xFF059669))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                txn['methodIcon'] as IconData,
                color: isPurchase ? accentOrange : const Color(0xFF059669),
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
                    txn['book'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    txn['author'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        txn['id'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('·', style: TextStyle(color: Colors.grey.shade300)),
                      const SizedBox(width: 6),
                      Text(
                        '${txn['date']}  ${txn['time']}',
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
                  '${isPurchase ? '-' : '+'}৳${txn['amount']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPurchase
                        ? Colors.black87
                        : const Color(0xFF059669),
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
                    txn['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  txn['method'],
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(
    Map<String, dynamic> txn, {
    required bool isPurchase,
  }) {
    final statusColor = _statusColor(txn['status']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Amount
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: (isPurchase ? accentOrange : const Color(0xFF059669))
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPurchase
                      ? Icons.shopping_bag_outlined
                      : Icons.payments_outlined,
                  size: 32,
                  color: isPurchase ? accentOrange : const Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${isPurchase ? '-' : '+'}৳${txn['amount']}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isPurchase ? Colors.black87 : const Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 4),
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
                  txn['status'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Details
              _detailRow('Transaction ID', txn['id']),
              _detailRow('Book', '${txn['book']} — ${txn['author']}'),
              _detailRow('Type', isPurchase ? 'Purchase' : 'Sale'),
              _detailRow('Payment Method', txn['method']),
              _detailRow('Date', txn['date']),
              _detailRow('Time', txn['time']),

              const SizedBox(height: 24),
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
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
