import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_methods_screen.dart';
import 'guest_guard.dart';

class PublishBookPage extends StatefulWidget {
  const PublishBookPage({super.key});

  @override
  State<PublishBookPage> createState() => _PublishBookPageState();
}

class _PublishBookPageState extends State<PublishBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _bookTitleController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _isbnController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  XFile? _coverImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Category — must match buy_books_screen filter chips
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

  String _selectedLanguage = 'Bangla';
  String _selectedBinding = 'Paperback';

  // Payment
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _loadingPayments = true;
  String? _selectedPaymentId;

  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color lightBrown = Color(0xFF7E481C);
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
    _bookTitleController.dispose();
    _authorNameController.dispose();
    _synopsisController.dispose();
    _isbnController.dispose();
    _pageCountController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
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

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
      );
      if (image != null) setState(() => _coverImage = image);
    } catch (e) {
      _showSnack('Error picking image: $e', Colors.red);
    }
  }

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
    if (_coverImage == null) {
      _showSnack('Please add a cover image for your book', Colors.orange);
      return;
    }
    if (_selectedPaymentId == null) {
      _showSnack('Please select a payment method', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch seller profile so buy screen shows name/photo immediately
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
        'bookName': _bookTitleController.text.trim(),
        'authorName': _authorNameController.text.trim(),
        'additionalNotes': _synopsisController.text.trim(),
        'edition': '',
        'condition': 'Brand New',

        // ── Category — used by buy screen filter chips ────────────
        'category': _selectedCategory,

        // ── Listing type — 'published' shows in Recently Published row
        'listingType': 'published',

        // ── Publish-specific fields ───────────────────────────────
        'isbn': _isbnController.text.trim(),
        'pageCount': int.tryParse(_pageCountController.text.trim()) ?? 0,
        'language': _selectedLanguage,
        'binding': _selectedBinding,
        'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,

        // ── Pricing (no buyingPrice for new books) ────────────────
        'buyingPrice': 0,
        'askingPrice': double.tryParse(_priceController.text.trim()) ?? 0,

        // ── Payment ───────────────────────────────────────────────
        'paymentMethod': selectedMethod['type'],
        'paymentNumber': selectedMethod['number'] ?? '',
        'paymentName': selectedMethod['name'] ?? '',

        // ── Status — admin approves → 'approved' ──────────────────
        'status': 'pending_review',

        // ── Cover image placeholder (upload when Blaze enabled) ───
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
              'Book Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your book has been submitted for review. Our team will verify and list it within 48 hours. Once live it will appear in the "Recently Published" section. Payment will be sent to your selected method after sales.',
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
          'Publish Your Book',
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
                    color: mediumBrown.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mediumBrown.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: mediumBrown,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'For New Authors',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: mediumBrown,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'You handle the printing, our delivery team handles distribution to readers!',
                              style: TextStyle(fontSize: 12, color: lightBrown),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Cover image ───────────────────────────────────────
                _sectionTitle('Book Cover *'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _coverImage != null
                            ? darkBrown
                            : Colors.grey.shade300,
                        width: _coverImage != null ? 2 : 1,
                      ),
                    ),
                    child: _coverImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(_coverImage!.path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _coverImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: darkBrown.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 40,
                                  color: darkBrown,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Upload Book Cover',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkBrown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recommended: 600×900 pixels',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
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
                          color: isSel ? mediumBrown : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? mediumBrown : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSel ? Colors.white : mediumBrown,
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
                  controller: _bookTitleController,
                  label: 'Book Title',
                  hint: 'Enter your book\'s title',
                  icon: Icons.book_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _authorNameController,
                  label: 'Author Name',
                  hint: 'Your name as it appears on the book',
                  icon: Icons.person_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _synopsisController,
                  label: 'Synopsis / Description',
                  hint: 'Write a compelling description of your book...',
                  icon: Icons.description_rounded,
                  isRequired: true,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),

                // Language & Binding row
                Row(
                  children: [
                    Expanded(
                      child: _dropdownField(
                        label: 'Language',
                        value: _selectedLanguage,
                        items: [
                          'Bangla',
                          'English',
                          'Hindi',
                          'Arabic',
                          'Other',
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedLanguage = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _dropdownField(
                        label: 'Binding',
                        value: _selectedBinding,
                        items: ['Paperback', 'Hardcover', 'Spiral Bound'],
                        onChanged: (v) => setState(() => _selectedBinding = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _isbnController,
                        label: 'ISBN (Optional)',
                        hint: 'ISBN number',
                        icon: Icons.qr_code_rounded,
                        isRequired: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _pageCountController,
                        label: 'Page Count',
                        hint: 'Number of pages',
                        icon: Icons.format_list_numbered_rounded,
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Pricing & Inventory ───────────────────────────────
                _sectionTitle('Pricing & Inventory'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceField(
                        controller: _priceController,
                        label: 'Selling Price',
                        hint: 'Price per copy',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _quantityController,
                        label: 'Initial Stock',
                        hint: 'Number of copies',
                        icon: Icons.inventory_2_rounded,
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── How it works ──────────────────────────────────────
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
                        'How Publishing Works',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _stepItem('1', 'Submit your book details & cover'),
                      _stepItem('2', 'Admin reviews and approves within 48h'),
                      _stepItem(
                        '3',
                        'Your book appears in "Recently Published" section',
                      ),
                      _stepItem(
                        '4',
                        'Buyers can ask questions — answer to boost sales',
                      ),
                      _stepItem('5', 'You print copies; we handle delivery'),
                      _stepItem(
                        '6',
                        'Payment sent to your selected method after each sale',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Payment ───────────────────────────────────────────
                _buildPaymentSection(),
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
                          'Boipara charges 15% commission per sale. You handle printing and quality control. No COD — payment via selected method only.',
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
                      backgroundColor: mediumBrown,
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
                            'Submit for Review',
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
                      'How would you like to receive payment?',
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
            color: mediumBrown.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: mediumBrown,
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

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
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
    required bool isRequired,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
