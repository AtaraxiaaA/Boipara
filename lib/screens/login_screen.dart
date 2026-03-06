import 'package:flutter/material.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final darkBrown = const Color(0xFF613613);
    final mediumBrown = const Color(0xFF7C4700);
    final lightBrown = const Color(0xFF7E481C);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 3D Layered Banner
              Stack(
                children: [
                  // ── Layer 1: Back (darkest) ──
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

                  // ── Layer 2: Middle shadow bleed ──
                  ClipPath(
                    clipper: LayeredWaveClipper(offset: 12 - 12),
                    child: Container(
                      height: 260,
                      width: double.infinity,
                      color: const Color(0x66000000),
                    ),
                  ),
                  // ── Layer 2: Middle fill ──
                  ClipPath(
                    clipper: LayeredWaveClipper(offset: 12),
                    child: Container(
                      height: 260,
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
                  // ── Layer 2: Highlight strip ──
                  ClipPath(
                    clipper: _EdgeStripClipper(LayeredWaveClipper(offset: 12), thickness: 7),
                    child: Container(
                      height: 260,
                      color: Color.lerp(mediumBrown, Colors.white, 0.45)!.withOpacity(0.65),
                    ),
                  ),

                  // ── Layer 3: Front shadow bleed ──
                  ClipPath(
                    clipper: LayeredWaveClipper(offset: 0 - 14),
                    child: Container(
                      height: 260,
                      width: double.infinity,
                      color: const Color(0x77000000),
                    ),
                  ),
                  // ── Layer 3: Front fill ──
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
                          Row(
                            children: [
                              const Text(
                                "Welcome back to",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Boipara!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Log in to your account",
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
                  // ── Layer 3: Highlight strip ──
                  ClipPath(
                    clipper: _EdgeStripClipper(LayeredWaveClipper(offset: 0), thickness: 7),
                    child: Container(
                      height: 260,
                      color: Color.lerp(lightBrown, Colors.white, 0.50)!.withOpacity(0.70),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                child: Column(
                  children: [
                    // Email/Mobile Field
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email or Mobile",
                        prefixIcon: Icon(Icons.person_outline, color: darkBrown),
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
                          borderSide: BorderSide(color: darkBrown, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline, color: darkBrown),
                        suffixIcon: const Icon(Icons.visibility_outlined, color: Colors.grey),
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
                          borderSide: BorderSide(color: darkBrown, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: darkBrown,
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "LOG IN",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Divider with "or login with"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "or login with",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Social Login Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 55,
                          height: 55,
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
                          child: IconButton(
                            icon: Image.network(
                              'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                              height: 28,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 25),
                        Container(
                          width: 55,
                          height: 55,
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
                          child: IconButton(
                            icon: Image.network(
                              'https://cdn-icons-png.flaticon.com/512/733/733547.png',
                              height: 28,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "SIGN UP",
                              style: TextStyle(
                                color: darkBrown,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

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
}

// ── Original LayeredWaveClipper (unchanged) ───────────────────────
class LayeredWaveClipper extends CustomClipper<Path> {
  final double offset;

  LayeredWaveClipper({this.offset = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 70 - offset);

    final cp1 = Offset(size.width * 0.3, size.height - 20 - offset);
    final ep1 = Offset(size.width * 0.55, size.height - 80 - offset);
    path.quadraticBezierTo(cp1.dx, cp1.dy, ep1.dx, ep1.dy);

    final cp2 = Offset(size.width * 0.8, size.height - 130 - offset);
    final ep2 = Offset(size.width, size.height - 70 - offset);
    path.quadraticBezierTo(cp2.dx, cp2.dy, ep2.dx, ep2.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

// ── Edge-strip clipper for highlight lip ─────────────────────────
class _EdgeStripClipper extends CustomClipper<Path> {
  final LayeredWaveClipper base;
  final double thickness;
  _EdgeStripClipper(this.base, {required this.thickness});

  @override
  Path getClip(Size size) {
    final outer = base.getClip(size);
    final innerClipper = LayeredWaveClipper(offset: base.offset + thickness);
    final inner = innerClipper.getClip(size);
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(_EdgeStripClipper old) => old.thickness != thickness;
}