import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GooglePhoneVerifyScreen extends StatefulWidget {
  final User googleUser;
  const GooglePhoneVerifyScreen({super.key, required this.googleUser});

  @override
  State<GooglePhoneVerifyScreen> createState() => _GooglePhoneVerifyScreenState();
}

class _GooglePhoneVerifyScreenState extends State<GooglePhoneVerifyScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);
  static const backgroundColor = Color(0xFFF5F0E9);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-complete registration without phone verification
    _completeRegistration();
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);

    try {
      // Save user to Firestore without phone verification
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.googleUser.uid)
          .set({
            'uid': widget.googleUser.uid,
            'username': widget.googleUser.displayName ?? 'Google User',
            'email': widget.googleUser.email ?? '',
            'mobile': '', // Empty - user can add later if they want
            'profilePhoto': widget.googleUser.photoURL ?? '',
            'phoneVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
            'bio': '',
            'gender': '',
            'address': '',
          });

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to complete registration. Please try again.');
        setState(() => _isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Setting Up Your Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User info
              CircleAvatar(
                radius: 48,
                backgroundImage: widget.googleUser.photoURL != null
                    ? NetworkImage(widget.googleUser.photoURL!)
                    : null,
                backgroundColor: brown.withValues(alpha: 0.1),
                child: widget.googleUser.photoURL == null
                    ? const Icon(Icons.person, color: brown, size: 40)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                widget.googleUser.displayName ?? 'Google User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Text(
                widget.googleUser.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 32),

              // Loading indicator
              if (_isLoading) ...[
                const CircularProgressIndicator(color: brown),
                const SizedBox(height: 16),
                const Text(
                  'Creating your account...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                // Error state
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again or use email sign up.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _completeRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}