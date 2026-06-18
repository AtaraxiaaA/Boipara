import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final primaryBrown = const Color(0xFF613613);
  final mediumBrown = const Color(0xFF7C4700);
  final lightBrown = const Color(0xFF7E481C);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user with email and password
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      // Update display name
      await userCredential.user?.updateDisplayName(username);

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Save user to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'username': username,
            'email': email,
            'mobile': '',
            'emailVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
            'profilePhoto': '',
            'bio': '',
            'gender': '',
            'address': '',
          });

      if (mounted) {
        // Navigate to email verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(username: username),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        default:
          message = e.message ?? 'Registration failed. Please try again';
      }
      _showError(message);
    } catch (e) {
      _showError('Something went wrong. Please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

 Future<void> _googleSignIn() async {
  setState(() => _isGoogleLoading = true);

  try {
    UserCredential userCredential;

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      userCredential = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
    }

    final user = userCredential.user!;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } else {
      // New Google user — create Firestore doc and go to home
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'username': user.displayName ?? 'Google User',
            'email': user.email ?? '',
            'mobile': '',
            'profilePhoto': user.photoURL ?? '',
            'emailVerified': true,
            'createdAt': FieldValue.serverTimestamp(),
            'bio': '',
            'gender': '',
            'address': '',
          });

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }
  } catch (e) {
    _showError('Google sign-in failed. Please try again');
  } finally {
    if (mounted) setState(() => _isGoogleLoading = false);
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
    final passwordsMatch =
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
    final passwordsMismatch =
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 3D Layered Banner
              Stack(
                children: [
                  ClipPath(
                    clipper: WaveClipper(offset: 30),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.lerp(primaryBrown, Colors.white, 0.18)!,
                            primaryBrown,
                            Color.lerp(primaryBrown, Colors.black, 0.18)!,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(offset: 15 - 12),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      color: const Color(0x66000000),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(offset: 15),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.lerp(mediumBrown, Colors.white, 0.22)!,
                            mediumBrown,
                            Color.lerp(mediumBrown, Colors.black, 0.18)!,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: _EdgeStripClipper(
                      WaveClipper(offset: 15),
                      thickness: 7,
                    ),
                    child: Container(
                      height: 240,
                      color: Color.lerp(
                        mediumBrown,
                        Colors.white,
                        0.45,
                      )!.withValues(alpha: 0.65),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(offset: 0 - 14),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      color: const Color(0x77000000),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(offset: 0),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(lightBrown, Colors.white, 0.20)!,
                            lightBrown,
                            Color.lerp(mediumBrown, Colors.black, 0.15)!,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Boipara!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Sign up to continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: _EdgeStripClipper(
                      WaveClipper(offset: 0),
                      thickness: 7,
                    ),
                    child: Container(
                      height: 240,
                      color: Color.lerp(
                        lightBrown,
                        Colors.white,
                        0.50,
                      )!.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username
                    _buildField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: primaryBrown,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryBrown, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(
                          Icons.lock_reset_outlined,
                          color: primaryBrown,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (passwordsMatch)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF059669),
                                size: 20,
                              ),
                            if (passwordsMismatch)
                              const Icon(
                                Icons.cancel,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: passwordsMatch
                                ? const Color(0xFF059669)
                                : passwordsMismatch
                                ? Colors.redAccent
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: passwordsMatch
                                ? const Color(0xFF059669)
                                : passwordsMismatch
                                ? Colors.redAccent
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: passwordsMatch
                                ? const Color(0xFF059669)
                                : passwordsMismatch
                                ? Colors.redAccent
                                : primaryBrown,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    if (passwordsMismatch) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Passwords do not match',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.redAccent.shade200,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (passwordsMatch) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 12,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Passwords match',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),

                    // SIGN UP Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or sign up with',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Google button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _isGoogleLoading ? null : _googleSignIn,
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: _isGoogleLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.network(
                                      'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'LOG IN',
                                style: TextStyle(
                                  color: primaryBrown,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBrown),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBrown, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double offset;
  WaveClipper({this.offset = 0});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50 - offset);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 10 - offset,
      size.width * 0.5,
      size.height - 60 - offset,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 110 - offset,
      size.width,
      size.height - 60 - offset,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _EdgeStripClipper extends CustomClipper<Path> {
  final WaveClipper base;
  final double thickness;
  _EdgeStripClipper(this.base, {required this.thickness});

  @override
  Path getClip(Size size) {
    final outer = base.getClip(size);
    final inner = WaveClipper(offset: base.offset + thickness).getClip(size);
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(_EdgeStripClipper old) => old.thickness != thickness;
}