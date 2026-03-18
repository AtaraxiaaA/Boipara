import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);

  // Ongoing orders
  final List<Map<String, dynamic>> _ongoingOrders = [
    {
      'orderId': '#ORD-2841',
      'book': 'Atomic Habits',
      'author': 'James Clear',
      'price': '420',
      'date': 'Mar 7, 2026',
      'status': 'Out for Delivery',
      'statusColor': Color(0xFF0E7490),
      'statusIcon': Icons.local_shipping_rounded,
      'steps': ['Ordered', 'Verified', 'Picked Up', 'Out for Delivery'],
      'currentStep': 3,
    },
    {
      'orderId': '#ORD-2796',
      'book': 'Sapiens',
      'author': 'Yuval Harari',
      'price': '500',
      'date': 'Mar 5, 2026',
      'status': 'Picked Up',
      'statusColor': Color(0xFF7C3AED),
      'statusIcon': Icons.inventory_2_rounded,
      'steps': ['Ordered', 'Verified', 'Picked Up', 'Out for Delivery'],
      'currentStep': 2,
    },
    {
      'orderId': '#ORD-2755',
      'book': 'Pather Panchali',
      'author': 'Bibhutibhushan',
      'price': '280',
      'date': 'Mar 3, 2026',
      'status': 'Verified',
      'statusColor': Color(0xFF059669),
      'statusIcon': Icons.verified_rounded,
      'steps': ['Ordered', 'Verified', 'Picked Up', 'Out for Delivery'],
      'currentStep': 1,
    },
  ];

  // Past/completed orders
  final List<Map<String, dynamic>> _pastOrders = [
    {
      'orderId': '#ORD-2701',
      'book': 'The Alchemist',
      'author': 'Paulo Coelho',
      'price': '350',
      'date': 'Feb 28, 2026',
      'status': 'Delivered',
      'statusColor': Color(0xFF059669),
      'statusIcon': Icons.check_circle_rounded,
    },
    {
      'orderId': '#ORD-2634',
      'book': '1984',
      'author': 'George Orwell',
      'price': '280',
      'date': 'Feb 20, 2026',
      'status': 'Delivered',
      'statusColor': Color(0xFF059669),
      'statusIcon': Icons.check_circle_rounded,
    },
    {
      'orderId': '#ORD-2589',
      'book': 'Himu',
      'author': 'Humayun Ahmed',
      'price': '200',
      'date': 'Feb 14, 2026',
      'status': 'Delivered',
      'statusColor': Color(0xFF059669),
      'statusIcon': Icons.check_circle_rounded,
    },
    {
      'orderId': '#ORD-2501',
      'book': 'Lalsalu',
      'author': 'Syed Waliullah',
      'price': '220',
      'date': 'Feb 2, 2026',
      'status': 'Cancelled',
      'statusColor': Color(0xFFDC2626),
      'statusIcon': Icons.cancel_rounded,
    },
    {
      'orderId': '#ORD-2488',
      'book': 'Nondito Noroke',
      'author': 'Humayun Ahmed',
      'price': '180',
      'date': 'Jan 25, 2026',
      'status': 'Delivered',
      'statusColor': Color(0xFF059669),
      'statusIcon': Icons.check_circle_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E9),
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Orders',
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
          tabs: [
            Tab(text: 'Ongoing (${_ongoingOrders.length})'),
            Tab(text: 'Past Orders (${_pastOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOngoingTab(), _buildPastTab()],
      ),
    );
  }

  Widget _buildOngoingTab() {
    if (_ongoingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_shipping_outlined,
        message: 'No ongoing orders',
        subtitle: 'Your active orders will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ongoingOrders.length,
      itemBuilder: (context, index) {
        final order = _ongoingOrders[index];
        return _buildOngoingCard(order);
      },
    );
  }

  Widget _buildPastTab() {
    if (_pastOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        message: 'No past orders',
        subtitle: 'Your completed orders will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastOrders.length,
      itemBuilder: (context, index) {
        final order = _pastOrders[index];
        return _buildPastCard(order);
      },
    );
  }

  Widget _buildOngoingCard(Map<String, dynamic> order) {
    final steps = List<String>.from(order['steps']);
    final currentStep = order['currentStep'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top colored bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: order['statusColor'] as Color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID & status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['orderId'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (order['statusColor'] as Color).withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order['statusIcon'] as IconData,
                            size: 12,
                            color: order['statusColor'] as Color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: order['statusColor'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Book info
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF613613).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: brown,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['book'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            order['author'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '৳${order['price']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress tracker
                Row(
                  children: List.generate(steps.length, (i) {
                    final isDone = i <= currentStep;
                    final isLast = i == steps.length - 1;
                    return Expanded(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? order['statusColor'] as Color
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isDone ? Icons.check : Icons.circle,
                                  size: isDone ? 14 : 6,
                                  color: isDone
                                      ? Colors.white
                                      : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                steps[i],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDone
                                      ? Colors.black87
                                      : Colors.grey.shade400,
                                  fontWeight: isDone
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                height: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                color: i < currentStep
                                    ? order['statusColor'] as Color
                                    : Colors.grey.shade200,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 8),
                Text(
                  'Ordered on ${order['date']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastCard(Map<String, dynamic> order) {
    final isDelivered = order['status'] == 'Delivered';

    return Container(
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
          // Book icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDelivered
                  ? const Color(0xFF059669).withValues(alpha: 0.08)
                  : const Color(0xFFDC2626).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              order['statusIcon'] as IconData,
              color: order['statusColor'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['book'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order['author'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      order['orderId'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('·', style: TextStyle(color: Colors.grey.shade300)),
                    const SizedBox(width: 8),
                    Text(
                      order['date'],
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

          // Price & status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${order['price']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: accentOrange,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (order['statusColor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: order['statusColor'] as Color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
