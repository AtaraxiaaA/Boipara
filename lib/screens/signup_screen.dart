import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryBrown = const Color(0xFF613613);
    final mediumBrown = const Color(0xFF7C4700);
    final lightBrown = const Color(0xFF7E481C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 3D Layered Banner
              Stack(
                children: [
                  // ── Layer 1: Back (darkest) – shadow only, no highlight ──
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

                  // ── Layer 2: Middle shadow (bleed below middle layer) ──
                  ClipPath(
                    clipper: WaveClipper(offset: 15 - 12),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      color: const Color(0x66000000),
                    ),
                  ),
                  // ── Layer 2: Middle fill + highlight ──
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
                  // ── Layer 2: Top-edge highlight strip ──
                  ClipPath(
                    clipper: _EdgeStripClipper(WaveClipper(offset: 15), thickness: 7),
                    child: Container(
                      height: 240,
                      color: Color.lerp(mediumBrown, Colors.white, 0.45)!.withOpacity(0.65),
                    ),
                  ),

                  // ── Layer 3: Front shadow (bleed below front layer) ──
                  ClipPath(
                    clipper: WaveClipper(offset: 0 - 14),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      color: const Color(0x77000000),
                    ),
                  ),
                  // ── Layer 3: Front fill + gradient ──
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
                            "Welcome to",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
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
                              "Sign up to continue",
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
                  // ── Layer 3: Top-edge highlight strip ──
                  ClipPath(
                    clipper: _EdgeStripClipper(WaveClipper(offset: 0), thickness: 7),
                    child: Container(
                      height: 240,
                      color: Color.lerp(lightBrown, Colors.white, 0.50)!.withOpacity(0.70),
                    ),
                  ),
                ],
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: Icon(Icons.person_outline, color: primaryBrown),
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
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, color: primaryBrown),
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
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline, color: primaryBrown),
                        suffixIcon: const Icon(Icons.visibility_outlined, color: Colors.grey),
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
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Mobile",
                        prefixIcon: Icon(Icons.phone_android_outlined, color: primaryBrown),
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
                    const SizedBox(height: 32),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "SIGN UP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Social Login Options
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "or sign up with",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Image.network(
                              'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                              height: 24,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Image.network(
                              'https://cdn-icons-png.flaticon.com/512/733/733547.png',
                              height: 24,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                          children: [
                            const TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "LOG IN",
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
}

// ── Original WaveClipper (unchanged) ─────────────────────────────
class WaveClipper extends CustomClipper<Path> {
  final double offset;

  WaveClipper({this.offset = 0});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50 - offset);

    var firstControlPoint = Offset(size.width * 0.25, size.height - 10 - offset);
    var firstEndPoint = Offset(size.width * 0.5, size.height - 60 - offset);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height - 110 - offset);
    var secondEndPoint = Offset(size.width, size.height - 60 - offset);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

// ── Edge-strip clipper for highlight lip ─────────────────────────
class _EdgeStripClipper extends CustomClipper<Path> {
  final WaveClipper base;
  final double thickness;
  _EdgeStripClipper(this.base, {required this.thickness});

  @override
  Path getClip(Size size) {
    final outer = base.getClip(size);
    // Inner = same wave shifted UP by thickness → difference = thin strip on edge
    final innerClipper = WaveClipper(offset: base.offset + thickness);
    final inner = innerClipper.getClip(size);
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(_EdgeStripClipper old) => old.thickness != thickness;
}