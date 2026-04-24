import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_methods_screen.dart';
import 'guest_guard.dart';

class SellBookPage extends StatefulWidget {
  const SellBookPage({super.key});

  @override
  State<SellBookPage> createState() => _SellBookPageState();
}

class _SellBookPageState extends State<SellBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _editionController = TextEditingController();
  final _conditionController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _askingPriceController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Category & listing type — must match buy_books_screen filters
  String _selectedCategory = 'Fiction';
  final _categories = [
    'Fiction',
    'Non-Fiction',
    'Textbook',
    'Poetry',
    'Self-Help',
    'Horror',
    'History',
  ];

  // Payment
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _loadingPayments = true;
  String? _selectedPaymentId;

  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color accentOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFF5F0E9);

  final _typeColors = {
    'bKash': const Color(0xFFE2136E),
    'Nagad': const Color(0xFFF6921E),
    'Bank Account': const Color(0xFF1A5276),
  };

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorNameController.dispose();
    _editionController.dispose();
    _conditionController.dispose();
    _buyingPriceController.dispose();
    _askingPriceController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _loadingPayments = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('payment_methods')
          .get();
      setState(() {
        _paymentMethods = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        final defaultMethod = _paymentMethods.firstWhere(
          (m) => m['isDefault'] == true,
          orElse: () => {},
        );
        if (defaultMethod.isNotEmpty) {
          _selectedPaymentId = defaultMethod['id'];
        }
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingPayments = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (images.isNotEmpty) setState(() => _selectedImages.addAll(images));
    } catch (e) {
      _showSnack('Error picking images: $e', Colors.red);
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (image != null) setState(() => _selectedImages.add(image));
    } catch (e) {
      _showSnack('Error taking picture: $e', Colors.red);
    }
  }

  void _removeImage(int index) =>
      setState(() => _selectedImages.removeAt(index));

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitBook() async {
    if (showGuestDialog(context)) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      _showSnack('Please add at least one photo of your book', Colors.orange);
      return;
    }
    if (_selectedPaymentId == null) {
      _showSnack('Please select a payment method', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch seller profile so buy screen can show name/photo immediately
      String sellerName = 'Unknown';
      String sellerPhoto = '';
      try {
        final ud = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        sellerName = ud.data()?['username'] ?? 'Unknown';
        sellerPhoto = ud.data()?['profilePhoto'] ?? '';
      } catch (_) {}

      final selectedMethod = _paymentMethods.firstWhere(
        (m) => m['id'] == _selectedPaymentId,
      );

      await FirebaseFirestore.instance.collection('books').add({
        // ── Identity ──────────────────────────────────────────────
        'sellerId': uid,
        'sellerName': sellerName,
        'sellerPhoto': sellerPhoto,

        // ── Book info ─────────────────────────────────────────────
        'bookName': _bookNameController.text.trim(),
        'authorName': _authorNameController.text.trim(),
        'edition': _editionController.text.trim(),
        'condition': _conditionController.text.trim(),

        // ── Category — used by buy screen filter chips ────────────
        'category': _selectedCategory,

        // ── Listing type — 'thrift' shows in Thrift/Preloved grid ─
        'listingType': 'thrift',

        // ── Pricing ───────────────────────────────────────────────
        'buyingPrice': double.tryParse(_buyingPriceController.text.trim()) ?? 0,
        'askingPrice': double.tryParse(_askingPriceController.text.trim()) ?? 0,

        // ── Extra ─────────────────────────────────────────────────
        'additionalNotes': _additionalNotesController.text.trim(),
        'paymentMethod': selectedMethod['type'],
        'paymentNumber': selectedMethod['number'] ?? '',
        'paymentName': selectedMethod['name'] ?? '',

        // ── Status — admin approves → 'approved' ──────────────────
        'status': 'pending_review',

        // ── Images placeholder (upload when Blaze enabled) ────────
        'images': [],

        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isSubmitting = false);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnack('Failed to submit. Please try again', Colors.red);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkBrown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: darkBrown,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Book Listed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your book has been submitted for review. We\'ll contact you within 24 hours. Payment will be sent to your selected method after the book is sold.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
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
          'Sell a Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                // ── Info banner ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: accentOrange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Upload clear photos and provide accurate details to get the best price for your book!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8B5E3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Photos ────────────────────────────────────────────
                _sectionTitle('Book Photos *'),
                const SizedBox(height: 4),
                Text(
                  'Add multiple photos showing front cover, back cover, and any damages',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      if (_selectedImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_selectedImages.isNotEmpty)
                        const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _imagePickerButton(
                              icon: Icons.photo_library_rounded,
                              label: 'Gallery',
                              onTap: _pickImages,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _imagePickerButton(
                              icon: Icons.camera_alt_rounded,
                              label: 'Camera',
                              onTap: _takePicture,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Category ──────────────────────────────────────────
                _sectionTitle('Category *'),
                const SizedBox(height: 4),
                Text(
                  'Select the genre — buyers filter by this',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSel ? darkBrown : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? darkBrown : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSel ? Colors.white : darkBrown,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── Book Details ──────────────────────────────────────
                _sectionTitle('Book Details'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bookNameController,
                  label: 'Book Name',
                  hint: 'Enter the book title',
                  icon: Icons.book_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _authorNameController,
                  label: 'Author Name',
                  hint: 'Enter the author\'s name',
                  icon: Icons.person_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _editionController,
                  label: 'Edition (Optional)',
                  hint: 'e.g., 1st Edition, Revised Edition',
                  icon: Icons.format_list_numbered_rounded,
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _conditionController,
                  label: 'Condition',
                  hint: 'e.g., Brand New, Like New, Very Good, Good',
                  icon: Icons.star_rounded,
                  isRequired: true,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // ── Pricing ───────────────────────────────────────────
                _sectionTitle('Pricing'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceField(
                        controller: _buyingPriceController,
                        label: 'Buying Price',
                        hint: 'Original price',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPriceField(
                        controller: _askingPriceController,
                        label: 'Asking Price',
                        hint: 'Your expected price',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _additionalNotesController,
                  label: 'Additional Notes (Optional)',
                  hint: 'Any marks, missing pages, damage details...',
                  icon: Icons.notes_rounded,
                  isRequired: false,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // ── Payment ───────────────────────────────────────────
                _buildPaymentSection(),
                const SizedBox(height: 24),

                // ── What happens next ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What happens next?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _stepItem(
                        '1',
                        'Admin reviews your submission (within 24h)',
                      ),
                      _stepItem(
                        '2',
                        'Your book goes live in the Thrift/Preloved section',
                      ),
                      _stepItem(
                        '3',
                        'Buyers can ask questions — answer them to boost sales',
                      ),
                      _stepItem(
                        '4',
                        'A buyer places an order and you get notified instantly',
                      ),
                      _stepItem(
                        '5',
                        'Payment is sent to your selected method after delivery',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Commission notice ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Boipara charges 10–15% commission after successful sale. Payment will be sent via your selected method.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Submit ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Submit Book for Sale',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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

  // ── Payment Section ──────────────────────────────────────────────────
  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBrown.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: darkBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: darkBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                      ),
                    ),
                    Text(
                      'Select how you want to receive payment',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingPayments)
            const Center(child: CircularProgressIndicator(color: darkBrown))
          else if (_paymentMethods.isEmpty)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
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
                          'No saved payment methods. Add one to receive payment after selling.',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      );
                      _loadPaymentMethods();
                    },
                    icon: const Icon(Icons.add, color: darkBrown),
                    label: const Text(
                      'Add Payment Method',
                      style: TextStyle(color: darkBrown),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: darkBrown),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                ..._paymentMethods.map((method) {
                  final isSelected = _selectedPaymentId == method['id'];
                  final color = _typeColors[method['type']] ?? darkBrown;
                  final logo = method['type'] == 'Bank Account'
                      ? 'BA'
                      : (method['type'] as String)[0];
                  final isBank = method['type'] == 'Bank Account';
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPaymentId = method['id']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? darkBrown.withValues(alpha: 0.06)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? darkBrown : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                logo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      method['type'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (isBank &&
                                        (method['bankName'] ?? '')
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '· ${method['bankName']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                    if (method['isDefault'] == true) ...[
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'Default',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  method['number'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  method['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: method['id'],
                            groupValue: _selectedPaymentId,
                            onChanged: (val) =>
                                setState(() => _selectedPaymentId = val),
                            activeColor: darkBrown,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentMethodsScreen(),
                      ),
                    );
                    _loadPaymentMethods();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: darkBrown.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add another payment method',
                        style: TextStyle(
                          fontSize: 13,
                          color: darkBrown.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
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

  // ── Helpers ──────────────────────────────────────────────────────────
  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: darkBrown,
    ),
  );

  Widget _stepItem(String number, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: darkBrown.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    ),
  );

  Widget _imagePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: darkBrown.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: darkBrown.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: darkBrown, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isRequired,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: darkBrown, size: 20),
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
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Text(
                '৳',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
            ),
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            if (double.tryParse(value) == null) return 'Enter valid price';
            return null;
          },
        ),
      ],
    );
  }
}
