import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final _genreController = TextEditingController();
  final _isbnController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  // Payment method controllers
  final _accountHolderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _cardNumberController = TextEditingController();

  XFile? _coverImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  String _selectedLanguage = 'Bangla';
  String _selectedBinding = 'Paperback';

  // Payment method state
  bool _acceptedPaymentTerms = false;
  String? _selectedPaymentMethod;
  String? _selectedMobileBanking;
  String? _selectedBank;

  // Theme colors
  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color lightBrown = Color(0xFF7E481C);
  static const Color accentOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFF5F0E9);

  final List<String> _mobileBankingOptions = ['bKash', 'Nagad', 'Upay'];
  final List<String> _bankOptions = [
    'Dutch-Bangla Bank (DBBL)',
    'BRAC Bank',
    'Eastern Bank Limited (EBL)',
    'City Bank',
    'Prime Bank',
    'Islami Bank Bangladesh',
    'Pubali Bank',
    'Sonali Bank',
    'Janata Bank',
    'Agrani Bank',
    'Rupali Bank',
    'Standard Chartered Bangladesh',
    'HSBC Bangladesh',
    'Bank Asia',
    'Mutual Trust Bank',
    'Southeast Bank',
    'United Commercial Bank',
    'AB Bank',
    'NCC Bank',
    'One Bank',
  ];

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
      );
      if (image != null) {
        setState(() {
          _coverImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitBook() {
    if (_formKey.currentState!.validate()) {
      if (_coverImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add a cover image for your book'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (!_acceptedPaymentTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the payment terms to continue'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a payment method'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Validate payment details
      if (_selectedPaymentMethod == 'mobile_banking' && _selectedMobileBanking == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a mobile banking provider'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedPaymentMethod == 'bank_account' && _selectedBank == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your bank'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSubmitting = false;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkBrown.withOpacity(0.1),
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
                  'Your book has been submitted for review. Our team will verify and list it within 48 hours. Payment will be sent to your selected method after sales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
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
      });
    }
  }

  @override
  void dispose() {
    _bookTitleController.dispose();
    _authorNameController.dispose();
    _synopsisController.dispose();
    _genreController.dispose();
    _isbnController.dispose();
    _pageCountController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _mobileNumberController.dispose();
    _cardNumberController.dispose();
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
          'Publish Your Book',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mediumBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mediumBrown.withOpacity(0.3),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: lightBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Book Cover Section
                const Text(
                  'Book Cover *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
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
                                  onTap: () {
                                    setState(() {
                                      _coverImage = null;
                                    });
                                  },
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
                                  color: darkBrown.withOpacity(0.1),
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
                                'Recommended: 600x900 pixels',
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

                // Book Details Section
                const Text(
                  'Book Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
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

                _buildTextField(
                  controller: _genreController,
                  label: 'Genre / Category',
                  hint: 'e.g., Fiction, Non-fiction, Self-help, Poetry',
                  icon: Icons.category_rounded,
                  isRequired: true,
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

                const SizedBox(height: 16),

                // Language Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Language',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          value: _selectedLanguage,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: ['Bangla', 'English', 'Hindi', 'Arabic', 'Other']
                              .map((lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Binding Type Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Binding Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          value: _selectedBinding,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: ['Paperback', 'Hardcover', 'Spiral Bound']
                              .map((binding) => DropdownMenuItem(
                                    value: binding,
                                    child: Text(binding),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBinding = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Pricing & Inventory Section
                const Text(
                  'Pricing & Inventory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
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

                // How It Works Section
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
                      _buildStepItem('1', 'Submit your book details'),
                      _buildStepItem('2', 'We review and approve within 48 hours'),
                      _buildStepItem('3', 'You print the books yourself'),
                      _buildStepItem('4', 'Our delivery team picks up from you'),
                      _buildStepItem('5', 'We deliver to readers, you get paid!'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Method Section
                _buildPaymentMethodSection(),

                const SizedBox(height: 16),

                // Commission Notice
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
                          'Boipara charges 15% commission per sale. You handle printing and quality control. No COD - payment via selected method only.',
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

                // Submit Button
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBrown.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: darkBrown.withOpacity(0.1),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Terms Checkbox
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _acceptedPaymentTerms ? darkBrown.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _acceptedPaymentTerms ? darkBrown.withOpacity(0.2) : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _acceptedPaymentTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedPaymentTerms = value ?? false;
                        if (!_acceptedPaymentTerms) {
                          _selectedPaymentMethod = null;
                        }
                      });
                    },
                    activeColor: darkBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'I agree to receive payment through mobile banking, bank account, or debit/credit card. Cash on Delivery (COD) is not available.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_acceptedPaymentTerms) ...[
            const SizedBox(height: 16),

            // Payment Method Options
            _buildPaymentOption(
              title: 'Mobile Banking',
              subtitle: 'bKash, Nagad, Upay',
              icon: Icons.phone_android_rounded,
              value: 'mobile_banking',
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              title: 'Bank Account',
              subtitle: 'Transfer to your bank account',
              icon: Icons.account_balance_rounded,
              value: 'bank_account',
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              title: 'Debit/Credit Card',
              subtitle: 'Visa, Mastercard',
              icon: Icons.credit_card_rounded,
              value: 'card',
            ),

            // Show details based on selection
            if (_selectedPaymentMethod == 'mobile_banking') ...[
              const SizedBox(height: 16),
              _buildMobileBankingDetails(),
            ],

            if (_selectedPaymentMethod == 'bank_account') ...[
              const SizedBox(height: 16),
              _buildBankAccountDetails(),
            ],

            if (_selectedPaymentMethod == 'card') ...[
              const SizedBox(height: 16),
              _buildCardDetails(),
            ],
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? darkBrown : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? darkBrown : const Color(0xFF333333),
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
                  _selectedPaymentMethod = val;
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
            'Select Mobile Banking Provider',
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
          TextFormField(
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              hintText: '01XXXXXXXXX',
              prefixIcon: const Icon(Icons.phone, color: darkBrown),
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
            ),
            validator: (value) {
              if (_selectedPaymentMethod == 'mobile_banking') {
                if (value == null || value.trim().isEmpty) {
                  return 'Mobile number is required';
                }
                if (value.length < 11) {
                  return 'Enter a valid mobile number';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountDetails() {
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
            'Bank Account Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          // Bank Selection Dropdown
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: InputDecoration(
              labelText: 'Select Bank',
              prefixIcon: const Icon(Icons.account_balance, color: darkBrown),
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
            ),
            items: _bankOptions.map((bank) {
              return DropdownMenuItem(
                value: bank,
                child: Text(
                  bank,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBank = value;
              });
            },
            validator: (value) {
              if (_selectedPaymentMethod == 'bank_account' && value == null) {
                return 'Please select a bank';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accountHolderNameController,
            decoration: InputDecoration(
              labelText: 'Account Holder Name',
              hintText: 'As per bank records',
              prefixIcon: const Icon(Icons.person_outline, color: darkBrown),
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
            ),
            validator: (value) {
              if (_selectedPaymentMethod == 'bank_account') {
                if (value == null || value.trim().isEmpty) {
                  return 'Account holder name is required';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Account Number',
              hintText: 'Enter your bank account number',
              prefixIcon: const Icon(Icons.numbers, color: darkBrown),
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
            ),
            validator: (value) {
              if (_selectedPaymentMethod == 'bank_account') {
                if (value == null || value.trim().isEmpty) {
                  return 'Account number is required';
                }
              }
              return null;
            },
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _accountHolderNameController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'Name on card',
              prefixIcon: const Icon(Icons.person_outline, color: darkBrown),
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
            ),
            validator: (value) {
              if (_selectedPaymentMethod == 'card') {
                if (value == null || value.trim().isEmpty) {
                  return 'Cardholder name is required';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: 'XXXX XXXX XXXX XXXX',
              prefixIcon: const Icon(Icons.credit_card, color: darkBrown),
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
            ),
            validator: (value) {
              if (_selectedPaymentMethod == 'card') {
                if (value == null || value.trim().isEmpty) {
                  return 'Card number is required';
                }
                if (value.replaceAll(' ', '').length < 16) {
                  return 'Enter a valid card number';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your card details are encrypted and secure',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: darkBrown.withOpacity(0.1),
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
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
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
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: darkBrown,
              size: 20,
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
              borderSide: const BorderSide(
                color: darkBrown,
                width: 2,
              ),
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
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
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
              borderSide: const BorderSide(
                color: darkBrown,
                width: 2,
              ),
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
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            if (double.tryParse(value) == null) {
              return 'Enter valid price';
            }
            return null;
          },
        ),
      ],
    );
  }
}
