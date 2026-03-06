import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  // Payment method controllers
  final _accountHolderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _cardNumberController = TextEditingController();

  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

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

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitBook() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one photo of your book'),
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
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to home
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
    _bookNameController.dispose();
    _authorNameController.dispose();
    _editionController.dispose();
    _conditionController.dispose();
    _buyingPriceController.dispose();
    _askingPriceController.dispose();
    _additionalNotesController.dispose();
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
          'Sell a Book',
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
                    color: accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentOrange.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: accentOrange,
                      ),
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

                // Photo Upload Section
                const Text(
                  'Book Photos *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add multiple photos showing front cover, back cover, and any damages',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                // Image Grid
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
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
                            );
                          },
                        ),
                      if (_selectedImages.isNotEmpty)
                        const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildImagePickerButton(
                              icon: Icons.photo_library_rounded,
                              label: 'Gallery',
                              onTap: _pickImages,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildImagePickerButton(
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

                // Book Name
                _buildTextField(
                  controller: _bookNameController,
                  label: 'Book Name',
                  hint: 'Enter the book title',
                  icon: Icons.book_rounded,
                  isRequired: true,
                ),

                const SizedBox(height: 16),

                // Author Name
                _buildTextField(
                  controller: _authorNameController,
                  label: 'Author Name',
                  hint: 'Enter the author\'s name',
                  icon: Icons.person_rounded,
                  isRequired: true,
                ),

                const SizedBox(height: 16),

                // Edition (Optional)
                _buildTextField(
                  controller: _editionController,
                  label: 'Edition (Optional)',
                  hint: 'e.g., 1st Edition, Revised Edition',
                  icon: Icons.format_list_numbered_rounded,
                  isRequired: false,
                ),

                const SizedBox(height: 16),

                // Condition
                _buildTextField(
                  controller: _conditionController,
                  label: 'Condition',
                  hint: 'e.g., Used - Good, Unused but old, Like new',
                  icon: Icons.star_rounded,
                  isRequired: true,
                  maxLines: 2,
                ),

                const SizedBox(height: 24),

                // Pricing Section
                const Text(
                  'Pricing',
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

                // Additional Notes
                _buildTextField(
                  controller: _additionalNotesController,
                  label: 'Additional Notes (Optional)',
                  hint: 'Any marks, missing pages, damage details...',
                  icon: Icons.notes_rounded,
                  isRequired: false,
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                // Payment Method Section
                _buildPaymentMethodSection(),

                const SizedBox(height: 24),

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
                          'Boipara charges 10-15% commission after successful sale. No COD available - payment will be sent via your selected method.',
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildImagePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: darkBrown.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: darkBrown.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: darkBrown,
              size: 28,
            ),
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
