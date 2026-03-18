import 'package:flutter/material.dart';

class TrackDeliveryScreen extends StatelessWidget {
  const TrackDeliveryScreen({super.key});

  static const brown = Color(0xFF613613);
  static const mediumBrown = Color(0xFF7C4700);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  // All orders sorted by date — replace with API later
  static final List<Map<String, dynamic>> _orders = [
    {
      'orderId': '#ORD-2841',
      'book': 'Atomic Habits',
      'author': 'James Clear',
      'price': '420',
      'orderDate': 'Mar 7, 2026',
      'estimatedDelivery': 'Mar 12, 2026',
      'status': 'Out for Delivery',
      'statusColor': Color(0xFF0E7490),
      'currentStep': 3,
      'steps': [
        {
          'title': 'Order Placed',
          'date': 'Mar 7, 2026',
          'time': '10:32 AM',
          'done': true,
        },
        {
          'title': 'Verified',
          'date': 'Mar 8, 2026',
          'time': '2:15 PM',
          'done': true,
        },
        {
          'title': 'Picked Up',
          'date': 'Mar 9, 2026',
          'time': '11:00 AM',
          'done': true,
        },
        {
          'title': 'Out for Delivery',
          'date': 'Mar 10, 2026',
          'time': '9:45 AM',
          'done': true,
        },
        {
          'title': 'Delivered',
          'date': 'Estimated Mar 12',
          'time': '',
          'done': false,
        },
      ],
      'seller': 'Tasnim Haque',
      'sellerPhone': '+880 1711-000001',
      'deliveryAddress': 'House 12, Road 5, Dhanmondi, Dhaka',
    },
    {
      'orderId': '#ORD-2796',
      'book': 'Sapiens',
      'author': 'Yuval Harari',
      'price': '500',
      'orderDate': 'Mar 5, 2026',
      'estimatedDelivery': 'Mar 14, 2026',
      'status': 'Picked Up',
      'statusColor': Color(0xFF7C3AED),
      'currentStep': 2,
      'steps': [
        {
          'title': 'Order Placed',
          'date': 'Mar 5, 2026',
          'time': '3:10 PM',
          'done': true,
        },
        {
          'title': 'Verified',
          'date': 'Mar 6, 2026',
          'time': '10:00 AM',
          'done': true,
        },
        {
          'title': 'Picked Up',
          'date': 'Mar 7, 2026',
          'time': '4:30 PM',
          'done': true,
        },
        {'title': 'Out for Delivery', 'date': '', 'time': '', 'done': false},
        {
          'title': 'Delivered',
          'date': 'Estimated Mar 14',
          'time': '',
          'done': false,
        },
      ],
      'seller': 'Farhan Islam',
      'sellerPhone': '+880 1722-000002',
      'deliveryAddress': 'House 12, Road 5, Dhanmondi, Dhaka',
    },
    {
      'orderId': '#ORD-2755',
      'book': 'Pather Panchali',
      'author': 'Bibhutibhushan',
      'price': '280',
      'orderDate': 'Mar 3, 2026',
      'estimatedDelivery': 'Mar 10, 2026',
      'status': 'Verified',
      'statusColor': Color(0xFF059669),
      'currentStep': 1,
      'steps': [
        {
          'title': 'Order Placed',
          'date': 'Mar 3, 2026',
          'time': '1:20 PM',
          'done': true,
        },
        {
          'title': 'Verified',
          'date': 'Mar 4, 2026',
          'time': '9:00 AM',
          'done': true,
        },
        {'title': 'Picked Up', 'date': '', 'time': '', 'done': false},
        {'title': 'Out for Delivery', 'date': '', 'time': '', 'done': false},
        {
          'title': 'Delivered',
          'date': 'Estimated Mar 10',
          'time': '',
          'done': false,
        },
      ],
      'seller': 'Sadia Rahman',
      'sellerPhone': '+880 1733-000003',
      'deliveryAddress': 'House 12, Road 5, Dhanmondi, Dhaka',
    },
    {
      'orderId': '#ORD-2701',
      'book': 'The Alchemist',
      'author': 'Paulo Coelho',
      'price': '350',
      'orderDate': 'Feb 28, 2026',
      'estimatedDelivery': 'Mar 5, 2026',
      'status': 'Delivered',
      'statusColor': Color(0xFF059669),
      'currentStep': 4,
      'steps': [
        {
          'title': 'Order Placed',
          'date': 'Feb 28, 2026',
          'time': '11:00 AM',
          'done': true,
        },
        {
          'title': 'Verified',
          'date': 'Mar 1, 2026',
          'time': '2:00 PM',
          'done': true,
        },
        {
          'title': 'Picked Up',
          'date': 'Mar 2, 2026',
          'time': '10:30 AM',
          'done': true,
        },
        {
          'title': 'Out for Delivery',
          'date': 'Mar 4, 2026',
          'time': '8:00 AM',
          'done': true,
        },
        {
          'title': 'Delivered',
          'date': 'Mar 5, 2026',
          'time': '3:15 PM',
          'done': true,
        },
      ],
      'seller': 'Rafi Ahmed',
      'sellerPhone': '+880 1744-000004',
      'deliveryAddress': 'House 12, Road 5, Dhanmondi, Dhaka',
    },
    {
      'orderId': '#ORD-2634',
      'book': '1984',
      'author': 'George Orwell',
      'price': '280',
      'orderDate': 'Feb 20, 2026',
      'estimatedDelivery': 'Feb 26, 2026',
      'status': 'Delivered',
      'statusColor': Color(0xFF059669),
      'currentStep': 4,
      'steps': [
        {
          'title': 'Order Placed',
          'date': 'Feb 20, 2026',
          'time': '9:30 AM',
          'done': true,
        },
        {
          'title': 'Verified',
          'date': 'Feb 21, 2026',
          'time': '11:00 AM',
          'done': true,
        },
        {
          'title': 'Picked Up',
          'date': 'Feb 22, 2026',
          'time': '2:00 PM',
          'done': true,
        },
        {
          'title': 'Out for Delivery',
          'date': 'Feb 25, 2026',
          'time': '8:30 AM',
          'done': true,
        },
        {
          'title': 'Delivered',
          'date': 'Feb 26, 2026',
          'time': '1:00 PM',
          'done': true,
        },
      ],
      'seller': 'Nabil Hossain',
      'sellerPhone': '+880 1755-000005',
      'deliveryAddress': 'House 12, Road 5, Dhanmondi, Dhaka',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF059669);
      case 'Out for Delivery':
        return const Color(0xFF0E7490);
      case 'Picked Up':
        return const Color(0xFF7C3AED);
      case 'Verified':
        return const Color(0xFF059669);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle_rounded;
      case 'Out for Delivery':
        return Icons.local_shipping_rounded;
      case 'Picked Up':
        return Icons.inventory_2_rounded;
      case 'Verified':
        return Icons.verified_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final color = order['statusColor'] as Color;
    final isDelivered = order['status'] == 'Delivered';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TrackingDetailScreen(order: order)),
        );
      },
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
        child: Column(
          children: [
            // Colored top strip
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _statusIcon(order['status']),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
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
                        const SizedBox(height: 2),
                        Text(
                          order['author'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                            Text(
                              '·',
                              style: TextStyle(color: Colors.grey.shade300),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              order['orderDate'],
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

                  // Status & chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isDelivered
                            ? 'Delivered'
                            : 'Est. ${order['estimatedDelivery']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade300,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tracking Detail Screen
// ─────────────────────────────────────────────
class TrackingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const TrackingDetailScreen({required this.order});

  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  @override
  Widget build(BuildContext context) {
    final color = order['statusColor'] as Color;
    final steps = List<Map<String, dynamic>>.from(order['steps']);
    final currentStep = order['currentStep'] as int;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          order['orderId'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book summary card
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
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: brown.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: brown,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['book'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          order['author'],
                          style: TextStyle(
                            fontSize: 13,
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
                      fontSize: 18,
                      color: accentOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusIconFromColor(order['status']),
                    color: color,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['status'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                      Text(
                        order['status'] == 'Delivered'
                            ? 'Your book has been delivered!'
                            : 'Estimated delivery: ${order['estimatedDelivery']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline
            const Text(
              'Tracking Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(steps.length, (i) {
              final step = steps[i];
              final isDone = step['done'] as bool;
              final isLast = i == steps.length - 1;
              final isCurrent = i == currentStep;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone
                              ? color
                              : isCurrent
                              ? color.withValues(alpha: 0.2)
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: isCurrent && !isDone
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : isCurrent
                            ? Icon(
                                Icons.radio_button_checked,
                                color: color,
                                size: 16,
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey.shade400,
                                size: 16,
                              ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 48,
                          color: isDone ? color : Colors.grey.shade200,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Step info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            step['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDone || isCurrent
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                            ),
                          ),
                          if (step['date'] != '')
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                step['time'] != ''
                                    ? '${step['date']}  •  ${step['time']}'
                                    : step['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDone
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 8),

            // Delivery info
            const Text(
              'Delivery Info',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.person_outline_rounded,
                    'Seller',
                    order['seller'],
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.phone_outlined,
                    'Seller Phone',
                    order['sellerPhone'],
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Delivery Address',
                    order['deliveryAddress'],
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.calendar_today_outlined,
                    'Order Date',
                    order['orderDate'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 2),
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
        ),
      ],
    );
  }

  IconData _statusIconFromColor(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle_rounded;
      case 'Out for Delivery':
        return Icons.local_shipping_rounded;
      case 'Picked Up':
        return Icons.inventory_2_rounded;
      case 'Verified':
        return Icons.verified_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}
