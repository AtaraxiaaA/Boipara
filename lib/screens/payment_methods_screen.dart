import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  List<Map<String, dynamic>> _methods = [];
  bool _isLoading = true;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _paymentRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('payment_methods');

  final _typeColors = {
    'bKash': const Color(0xFFE2136E),
    'Nagad': const Color(0xFFF6921E),
    'Bank Account': const Color(0xFF1A5276),
  };

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _paymentRef.get();
      setState(() {
        _methods = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          data['color'] = _typeColors[data['type']] ?? brown;
          data['logo'] = data['type'] == 'Bank Account'
              ? 'BA'
              : (data['type'] as String)[0];
          return data;
        }).toList();
      });
    } catch (e) {
      _showError('Failed to load payment methods');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var m in _methods) {
        batch.update(_paymentRef.doc(m['id']), {'isDefault': m['id'] == id});
      }
      await batch.commit();
      setState(() {
        for (var m in _methods) {
          m['isDefault'] = m['id'] == id;
        }
      });
      _showSuccess('Default payment method updated');
    } catch (e) {
      _showError('Failed to update default');
    }
  }

  Future<void> _deleteMethod(String id) async {
    try {
      await _paymentRef.doc(id).delete();
      setState(() => _methods.removeWhere((m) => m['id'] == id));
      _showSuccess('Payment method removed');
    } catch (e) {
      _showError('Failed to remove payment method');
    }
  }

  void _showAddMethodSheet() {
    String selectedType = 'bKash';
    final numberController = TextEditingController(text: '+88');
    final nameController = TextEditingController();
    final bankNameController = TextEditingController();
    final branchController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
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

                  const Text(
                    'Add Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Type selector
                  const Text(
                    'Method Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['bKash', 'Nagad', 'Bank Account'].map((type) {
                      final isSelected = selectedType == type;
                      final color = _typeColors[type]!;
                      final isLast = type == 'Bank Account';
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedType = type;
                              // Pre-fill +880 for mobile types, clear for bank
                              if (type != 'Bank Account') {
                                numberController.text = '+88';
                                numberController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: numberController.text.length,
                                      ),
                                    );
                              } else {
                                numberController.clear();
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: isLast ? 0 : 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              type == 'Bank Account' ? 'Bank' : type,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Account holder name
                  _sheetField(
                    controller: nameController,
                    label: 'Account Holder Name',
                    hint: 'Your full name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Number / Account number
                  _sheetField(
                    controller: numberController,
                    label: selectedType == 'Bank Account'
                        ? 'Account Number'
                        : 'Mobile Number',
                    hint: selectedType == 'Bank Account'
                        ? 'e.g. 1234 5678 9012 3456'
                        : '+880 1XXX-XXXXXX',
                    icon: selectedType == 'Bank Account'
                        ? Icons.account_balance_outlined
                        : Icons.phone_outlined,
                    keyboardType: selectedType == 'Bank Account'
                        ? TextInputType.number
                        : TextInputType.phone,
                    validator: (v) =>
                        v!.trim().isEmpty ? 'This field is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Bank-specific fields
                  if (selectedType == 'Bank Account') ...[
                    _sheetField(
                      controller: bankNameController,
                      label: 'Bank Name',
                      hint: 'e.g. Dutch-Bangla Bank',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 14),
                    _sheetField(
                      controller: branchController,
                      label: 'Branch',
                      hint: 'e.g. Dhanmondi Branch',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),
                  ],

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setSheetState(() => isSaving = true);
                              try {
                                final data = {
                                  'type': selectedType,
                                  'number': numberController.text.trim(),
                                  'name': nameController.text.trim(),
                                  'isDefault': _methods.isEmpty,
                                  'createdAt': FieldValue.serverTimestamp(),
                                  if (selectedType == 'Bank Account') ...{
                                    'bankName': bankNameController.text.trim(),
                                    'branch': branchController.text.trim(),
                                  },
                                };
                                await _paymentRef.add(data);
                                if (context.mounted) Navigator.pop(context);
                                await _loadMethods();
                                _showSuccess('Payment method added!');
                              } catch (e) {
                                setSheetState(() => isSaving = false);
                                _showError('Failed to add payment method');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Add Method',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Method',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Remove ${method['type']} (${method['number']})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMethod(method['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
          'Payment Methods',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMethodSheet,
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Method',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brown))
          : _methods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No payment methods',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap "+ Add Method" to add one',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _methods.length,
              itemBuilder: (context, index) =>
                  _buildMethodCard(_methods[index]),
            ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    final color = method['color'] as Color;
    final isBank = method['type'] == 'Bank Account';
    final isDefault = method['isDefault'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDefault
            ? Border.all(color: accentOrange, width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Logo
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  method['logo'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
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
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      if (isBank &&
                          (method['bankName'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· ${method['bankName']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    method['number'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['name'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                  if (isBank &&
                      (method['branch'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      method['branch'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                  if (isDefault) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                GestureDetector(
                  onTap: () => _confirmDelete(method),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                if (!isDefault) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _setDefault(method['id']),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: brown.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star_outline_rounded,
                        size: 18,
                        color: brown,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: brown, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
