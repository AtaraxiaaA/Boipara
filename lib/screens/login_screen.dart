import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup_screen.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); // Changed from mobile
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isGuestLoading = false;

  static const darkBrown = Color(0xFF613613);
  static const mediumBrown = Color(0xFF7C4700);
  static const lightBrown = Color(0xFF7E481C);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Login ─────────────────────────────────────────────────────────────
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        // Email not verified — resend verification and redirect
        await user.sendEmailVerification();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EmailVerificationScreen(
                username: user.displayName ?? 'User',
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        default:
          message = 'Login failed. Please try again';
      }
      _showError(message);
    } catch (_) {
      _showError('Something went wrong. Please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────
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
      final googleAuth = await googleUser.authentication;
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
      if (mounted)
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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

      if (mounted)
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  } catch (_) {
    _showError('Google sign-in failed. Please try again');
  } finally {
    if (mounted) setState(() => _isGoogleLoading = false);
  }
}
  

      
       
  // ── Guest Login ───────────────────────────────────────────────────────
  Future<void> _guestLogin() async {
    setState(() => _isGuestLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (mounted)
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (_) {
      _showError('Could not continue as guest. Try again.');
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
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
      backgroundColor: const Color(0xFFF5F0E9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    _buildEmailField(), // Changed from mobile to email
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildForgotPassword(),
                    const SizedBox(height: 20),
                    _buildLoginButton(),
                    const SizedBox(height: 16),

                    // ── Guest button ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _isGuestLoading ? null : _guestLogin,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: darkBrown.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        icon: _isGuestLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.person_outline_rounded,
                                color: darkBrown,
                              ),
                        label: const Text(
                          'Browse as Guest',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Guests can browse but cannot buy, sell or publish',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildGoogleButton(),
                    const SizedBox(height: 32),
                    _buildSignUpLink(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      children: [
        ClipPath(
          clipper: LayeredWaveClipper(offset: 25),
          child: Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(darkBrown, Colors.white, 0.18)!,
                  darkBrown,
                  Color.lerp(darkBrown, Colors.black, 0.18)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: LayeredWaveClipper(offset: 0),
          child: Container(
            height: 260,
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
            padding: const EdgeInsets.fromLTRB(28, 60, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back to',
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
                    'Log in to your account',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() => TextField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      labelText: 'Email Address',
      prefixIcon: const Icon(Icons.email_outlined, color: darkBrown),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkBrown, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
  );

  Widget _buildPasswordField() => TextField(
    controller: _passwordController,
    obscureText: _obscurePassword,
    decoration: InputDecoration(
      labelText: 'Password',
      prefixIcon: const Icon(Icons.lock_outline, color: darkBrown),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkBrown, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
  );

  Widget _buildForgotPassword() => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
      ),
      style: TextButton.styleFrom(foregroundColor: darkBrown),
      child: const Text(
        'Forgot Password?',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
  );

  Widget _buildLoginButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: darkBrown,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              'LOG IN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
    ),
  );

  Widget _buildDivider() => Row(
    children: [
      Expanded(child: Divider(color: Colors.grey.shade400)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'or login with',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
      Expanded(child: Divider(color: Colors.grey.shade400)),
    ],
  );

  Widget _buildGoogleButton() => SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton(
      onPressed: _isGoogleLoading ? null : _googleSignIn,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
      ),
      child: _isGoogleLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                  height: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
    ),
  );

  Widget _buildSignUpLink() => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    ),
    child: RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black87, fontSize: 15),
        children: [
          TextSpan(text: "Don't have an account? "),
          TextSpan(
            text: 'SIGN UP',
            style: TextStyle(
              color: darkBrown,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

class LayeredWaveClipper extends CustomClipper<Path> {
  final double offset;
  LayeredWaveClipper({this.offset = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 70 - offset);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height - 20 - offset,
      size.width * 0.55,
      size.height - 80 - offset,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height - 130 - offset,
      size.width,
      size.height - 70 - offset,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}