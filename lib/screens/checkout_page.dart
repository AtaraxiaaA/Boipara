import 'package:flutter/material.dart';
import '../models/book_model.dart';

/// CheckoutPage - Complete purchase flow
/// Includes:
/// - Order summary with book details
/// - Shipping information form
/// - Payment method selection
/// - Order placement
class CheckoutPage extends StatefulWidget {
  final String bookTitle;
  final String authorOrSeller;
  final double price;
  final int quantity;
  final BookType bookType;

  const CheckoutPage({
    super.key,
    required this.bookTitle,
    required this.authorOrSeller,
    required this.price,
    required this.quantity,
    required this.bookType,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();

  // Payment method controllers
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _mobileNumberController = TextEditingController();

  String _selectedPaymentMethod = 'cod';
  String? _selectedMobileBanking;
  bool _isProcessing = false;

  // Theme colors
  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color lightBrown = Color(0xFF7E481C);
  static const Color backgroundColor = Color(0xFFF5F0E9);
  static const Color accentOrange = Color(0xFFE07B39);

  // Delivery charge
  static const double deliveryCharge = 60.0;

  double get subtotal => widget.price * widget.quantity;
  double get total => subtotal + deliveryCharge;

  final List<String> _mobileBankingOptions = ['bKash', 'Nagad', 'Upay'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

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
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                _buildOrderSummary(),

                const SizedBox(height: 24),

                // Shipping Information
                _buildSectionTitle('Shipping Information'),
                const SizedBox(height: 16),
                _buildShippingForm(),

                const SizedBox(height: 24),

                // Payment Method
                _buildSectionTitle('Payment Method'),
                const SizedBox(height: 16),
                _buildPaymentMethodSection(),

                const SizedBox(height: 24),

                // Order Notes
                _buildSectionTitle('Order Notes (Optional)'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _notesController,
                  label: 'Special instructions for delivery',
                  hint: 'Any specific delivery instructions...',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  isRequired: false,
                ),

                const SizedBox(height: 24),

                // Price Breakdown
                _buildPriceBreakdown(),

                const SizedBox(height: 24),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Place Order - ${total.toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms notice
                Center(
                  child: Text(
                    'By placing this order, you agree to our Terms of Service',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: darkBrown,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.bookType == BookType.published
                      ? accentOrange.withOpacity(0.1)
                      : mediumBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.bookType == BookType.published
                      ? 'Published'
                      : 'Thrift',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.bookType == BookType.published
                        ? accentOrange
                        : mediumBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover placeholder
              Container(
                width: 60,
                height: 85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lightBrown.withOpacity(0.2),
                      mediumBrown.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: darkBrown.withOpacity(0.4),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.bookType == BookType.published
                          ? 'by ${widget.authorOrSeller}'
                          : 'Seller: ${widget.authorOrSeller}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${widget.price.toInt()} x ${widget.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${subtotal.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_rounded,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '01XXXXXXXXX',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'your@email.com',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Delivery Address',
            hint: 'House/Flat, Road, Area',
            icon: Icons.location_on_rounded,
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'City name',
                  icon: Icons.location_city_rounded,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  hint: 'Postal code',
                  icon: Icons.markunread_mailbox_rounded,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cash on Delivery
          _buildPaymentOption(
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive',
            icon: Icons.money_rounded,
            value: 'cod',
          ),
          const SizedBox(height: 12),

          // Mobile Banking
          _buildPaymentOption(
            title: 'Mobile Banking',
            subtitle: 'bKash, Nagad, Upay',
            icon: Icons.phone_android_rounded,
            value: 'mobile_banking',
          ),

          // Mobile banking details
          if (_selectedPaymentMethod == 'mobile_banking') ...[
            const SizedBox(height: 16),
            _buildMobileBankingDetails(),
          ],

          const SizedBox(height: 12),

          // Card Payment
          _buildPaymentOption(
            title: 'Card Payment',
            subtitle: 'Visa, Mastercard',
            icon: Icons.credit_card_rounded,
            value: 'card',
          ),

          // Card details
          if (_selectedPaymentMethod == 'card') ...[
            const SizedBox(height: 16),
            _buildCardDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? darkBrown.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? darkBrown : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? darkBrown : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? darkBrown : const Color(0xFF333333),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val!;
                });
              },
              activeColor: darkBrown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBankingDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Provider',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _mobileBankingOptions.map((option) {
              final isSelected = _selectedMobileBanking == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMobileBanking = option;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: option != _mobileBankingOptions.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? darkBrown : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? darkBrown : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _mobileNumberController,
            label: 'Mobile Number',
            hint: '01XXXXXXXXX',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _cardNumberController,
            label: 'Card Number',
            hint: 'XXXX XXXX XXXX XXXX',
            icon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cardExpiryController,
                  label: 'Expiry',
                  hint: 'MM/YY',
                  icon: Icons.calendar_today_rounded,
                  keyboardType: TextInputType.datetime,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cardCvvController,
                  label: 'CVV',
                  hint: 'XXX',
                  icon: Icons.lock_rounded,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  obscureText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '${subtotal.toInt()}'),
          const SizedBox(height: 12),
          _buildPriceRow('Delivery Charge', '${deliveryCharge.toInt()}'),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              Text(
                '${total.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: darkBrown),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              if (label.contains('Email') && !value.contains('@')) {
                return 'Enter a valid email address';
              }
              if (label.contains('Phone') && value.length < 11) {
                return 'Enter a valid phone number';
              }
              return null;
            }
          : null,
    );
  }

  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      // Validate payment method specific fields
      if (_selectedPaymentMethod == 'mobile_banking') {
        if (_selectedMobileBanking == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a mobile banking provider'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        if (_mobileNumberController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your mobile banking number'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      if (_selectedPaymentMethod == 'card') {
        if (_cardNumberController.text.trim().isEmpty ||
            _cardExpiryController.text.trim().isEmpty ||
            _cardCvvController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all card details'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      setState(() {
        _isProcessing = true;
      });

      // Simulate order processing
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isProcessing = false;
        });

        _showOrderSuccessDialog();
      });
    }
  }

  void _showOrderSuccessDialog() {
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #BP${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you for your order! You will receive a confirmation email shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: mediumBrown,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated delivery: 3-5 business days',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Pop until we reach home
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
                // TODO: Navigate to orders page
              },
              child: const Text(
                'View My Orders',
                style: TextStyle(
                  color: accentOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
