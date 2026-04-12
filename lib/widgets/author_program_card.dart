import 'package:flutter/material.dart';

/// AuthorProgramCard - Reusable widget for Author Publishing Program section
/// Displays the "Are You an Author?" promotion with:
/// - Title and description
/// - Visual support model (You Print, We Deliver, We Market)
/// - Large featured card design with clean illustration placeholder
/// - Elevated card design
/// - Primary "Publish Your Book" button
class AuthorProgramCard extends StatelessWidget {
  final VoidCallback onPublishPressed;

  // Theme colors - DO NOT CHANGE
  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color lightBrown = Color(0xFF7E481C);

  const AuthorProgramCard({
    super.key,
    required this.onPublishPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mediumBrown.withOpacity(0.12),
            lightBrown.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mediumBrown.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: mediumBrown,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: mediumBrown.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are You an Author?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Publish your book with Boipara',
                      style: TextStyle(
                        fontSize: 14,
                        color: mediumBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Description text
          const Text(
            'New authors can publish their books through Boipara. We help you reach thousands of readers across Bangladesh!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          // Visual support model - 3 benefit icons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: mediumBrown.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                _buildBenefitItem(Icons.print_rounded, 'You Print'),
                _buildDivider(),
                _buildBenefitItem(Icons.local_shipping_rounded, 'We Deliver'),
                _buildDivider(),
                _buildBenefitItem(Icons.campaign_rounded, 'We Market'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Primary "Publish Your Book" button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPublishPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: mediumBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: mediumBrown.withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.publish_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Publish Your Book',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mediumBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: mediumBrown,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkBrown,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.withOpacity(0.2),
    );
  }
}
