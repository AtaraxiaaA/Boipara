import 'package:flutter/material.dart';

/// BookCard - Reusable widget for displaying book items
/// Used in both horizontal lists (new releases) and grid layouts (thrift books)
/// Features:
/// - Book cover image on top (placeholder if none)
/// - "New Release" label for new author books
/// - Book title, author/seller name
/// - Price tag (for thrift books)
/// - Rounded corners, soft elevation
class BookCard extends StatelessWidget {
  final String title;
  final String subtitle; // Author name for new releases, Seller name for thrift
  final String? price; // Optional - only for thrift books
  final bool isNewRelease;
  final String? coverUrl;
  final VoidCallback onTap;

  // Theme colors - DO NOT CHANGE
  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color lightBrown = Color(0xFF7E481C);
  static const Color accentOrange = Color(0xFFE07B39);

  const BookCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.price,
    this.isNewRelease = false,
    this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover image area
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Cover image or placeholder
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          lightBrown.withOpacity(0.15),
                          mediumBrown.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: coverUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderCover(),
                            ),
                          )
                        : _buildPlaceholderCover(),
                  ),
                  // "New Release" label
                  if (isNewRelease)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'New Release',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Text information below
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Author/Seller name
                        Text(
                          isNewRelease ? 'by $subtitle' : 'Seller: $subtitle',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Price tag (only for thrift books)
                    if (price != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '৳$price',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: accentOrange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: darkBrown.withOpacity(0.3),
      ),
    );
  }
}
