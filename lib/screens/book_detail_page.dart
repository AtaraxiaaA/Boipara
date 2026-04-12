import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../data/book_data.dart';
import 'checkout_page.dart';

/// BookDetailPage - Detailed view of a book
/// Shows all book information including:
/// - For Published books: author, description, summary, reviews, stock, binding type, etc.
/// - For Thrift books: condition, seller info, purchase date, images, notes
/// Includes Add to Cart and Buy Now buttons
class BookDetailPage extends StatefulWidget {
  final String bookId;
  final BookType bookType;

  const BookDetailPage({
    super.key,
    required this.bookId,
    required this.bookType,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  int _quantity = 1;
  bool _isDescriptionExpanded = false;

  // Theme colors
  static const Color darkBrown = Color(0xFF613613);
  static const Color mediumBrown = Color(0xFF7C4700);
  static const Color lightBrown = Color(0xFF7E481C);
  static const Color backgroundColor = Color(0xFFF5F0E9);
  static const Color accentOrange = Color(0xFFE07B39);

  @override
  Widget build(BuildContext context) {
    if (widget.bookType == BookType.published) {
      final book = getPublishedBookById(widget.bookId);
      if (book == null) {
        return _buildNotFound();
      }
      return _buildPublishedBookDetail(book);
    } else {
      final book = getThriftBookById(widget.bookId);
      if (book == null) {
        return _buildNotFound();
      }
      return _buildThriftBookDetail(book);
    }
  }

  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: darkBrown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Not Found',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text('The requested book could not be found.'),
      ),
    );
  }

  Widget _buildPublishedBookDetail(PublishedBook book) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with book cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: darkBrown,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      darkBrown,
                      mediumBrown.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'book_${book.id}',
                    child: Container(
                      width: 150,
                      height: 220,
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: darkBrown.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Book Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'New Release',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: book.inStock > 0
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                book.inStock > 0
                                    ? 'In Stock (${book.inStock})'
                                    : 'Out of Stock',
                                style: TextStyle(
                                  color: book.inStock > 0 ? Colors.green : Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Author
                        Row(
                          children: [
                            const Text(
                              'by ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                            Text(
                              book.authorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: darkBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Rating and Reviews
                        if (book.rating > 0)
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < book.rating.floor()
                                        ? Icons.star_rounded
                                        : (index < book.rating
                                            ? Icons.star_half_rounded
                                            : Icons.star_outline_rounded),
                                    color: Colors.amber,
                                    size: 22,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${book.rating}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${book.reviews.length} reviews)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${book.price.toInt()}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: accentOrange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                book.bindingType.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: backgroundColor,
                  ),

                  // Book Details Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Book Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Genre', book.genre),
                        _buildDetailRow('Language', book.language),
                        _buildDetailRow('Pages', '${book.pageCount}'),
                        _buildDetailRow('Binding', book.bindingType.displayName),
                        if (book.isbn != null)
                          _buildDetailRow('ISBN', book.isbn!),
                        _buildDetailRow(
                          'Published',
                          '${book.publishedDate.day}/${book.publishedDate.month}/${book.publishedDate.year}',
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: backgroundColor,
                  ),

                  // Description Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          book.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: backgroundColor,
                  ),

                  // Summary Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isDescriptionExpanded
                              ? book.summary
                              : (book.summary.length > 200
                                  ? '${book.summary.substring(0, 200)}...'
                                  : book.summary),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF555555),
                          ),
                        ),
                        if (book.summary.length > 200)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isDescriptionExpanded = !_isDescriptionExpanded;
                              });
                            },
                            child: Text(
                              _isDescriptionExpanded ? 'Show Less' : 'Read More',
                              style: const TextStyle(
                                color: accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Reviews Section
                  if (book.reviews.isNotEmpty) ...[
                    Container(
                      height: 8,
                      color: backgroundColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkBrown,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    color: accentOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...book.reviews.take(3).map((review) => _buildReviewCard(review)),
                        ],
                      ),
                    ),
                  ],

                  // Bottom spacing for buttons
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
        price: book.price,
        isInStock: book.inStock > 0,
        bookTitle: book.title,
        authorOrSeller: book.authorName,
        bookType: BookType.published,
      ),
    );
  }

  Widget _buildThriftBookDetail(ThriftBook book) {
    final daysSincePurchase = DateTime.now().difference(book.purchasedDate).inDays;
    final yearsOwned = (daysSincePurchase / 365).floor();
    final monthsOwned = ((daysSincePurchase % 365) / 30).floor();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with book cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: darkBrown,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lightBrown,
                      mediumBrown.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'book_${book.id}',
                    child: Container(
                      width: 150,
                      height: 220,
                      margin: const EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: darkBrown.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Book Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: mediumBrown,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Thrift Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _getConditionColor(book.condition).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                book.condition.displayName,
                                style: TextStyle(
                                  color: _getConditionColor(book.condition),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_calculateDiscount(book.originalPrice, book.askingPrice)}% OFF',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Author
                        Row(
                          children: [
                            const Text(
                              'by ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                            Text(
                              book.authorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: darkBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${book.askingPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: accentOrange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${book.originalPrice.toInt()}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: backgroundColor,
                  ),

                  // Seller Info Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seller Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: darkBrown.withOpacity(0.1),
                                child: Text(
                                  book.sellerName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.sellerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 14,
                                          color: Colors.green[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified Seller',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: darkBrown),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Contact',
                                  style: TextStyle(
                                    color: darkBrown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: backgroundColor,
                  ),

                  // Book Details Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Book Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Pages', '${book.pageCount}'),
                        if (book.edition != null)
                          _buildDetailRow('Edition', book.edition!),
                        _buildDetailRow(
                          'Originally Purchased',
                          '${book.purchasedDate.day}/${book.purchasedDate.month}/${book.purchasedDate.year}',
                        ),
                        _buildDetailRow(
                          'Time Since Purchase',
                          yearsOwned > 0
                              ? '$yearsOwned year${yearsOwned > 1 ? 's' : ''} ${monthsOwned > 0 ? '$monthsOwned month${monthsOwned > 1 ? 's' : ''}' : ''}'
                              : '$monthsOwned month${monthsOwned > 1 ? 's' : ''}',
                        ),
                        _buildDetailRow(
                          'Listed On',
                          '${book.listedDate.day}/${book.listedDate.month}/${book.listedDate.year}',
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: backgroundColor,
                  ),

                  // Condition Details Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Condition Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getConditionColor(book.condition).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getConditionColor(book.condition).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getConditionColor(book.condition),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      book.condition.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      book.condition.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Seller\'s Notes:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.conditionNotes,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Additional Notes Section
                  if (book.additionalNotes != null) ...[
                    Container(
                      height: 8,
                      color: backgroundColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Additional Notes from Seller',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            book.additionalNotes!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bottom spacing for buttons
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
        price: book.askingPrice,
        isInStock: true,
        bookTitle: book.title,
        authorOrSeller: book.sellerName,
        bookType: BookType.thrift,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BookReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: darkBrown.withOpacity(0.1),
                child: Text(
                  review.reviewerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 14,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${review.reviewDate.day}/${review.reviewDate.month}/${review.reviewDate.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar({
    required double price,
    required bool isInStock,
    required String bookTitle,
    required String authorOrSeller,
    required BookType bookType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            if (isInStock) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : null,
                      icon: Icon(
                        Icons.remove,
                        size: 18,
                        color: _quantity > 1 ? darkBrown : Colors.grey,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: darkBrown,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Add to Cart button
            Expanded(
              child: OutlinedButton(
                onPressed: isInStock
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $_quantity item(s) to cart'),
                            backgroundColor: darkBrown,
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                          ),
                        );
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isInStock ? darkBrown : Colors.grey,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Buy Now button
            Expanded(
              child: ElevatedButton(
                onPressed: isInStock
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              bookTitle: bookTitle,
                              authorOrSeller: authorOrSeller,
                              price: price,
                              quantity: _quantity,
                              bookType: bookType,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInStock ? accentOrange : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Buy Now',
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
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.brandNew:
        return Colors.green;
      case BookCondition.likeNew:
        return Colors.teal;
      case BookCondition.veryGood:
        return mediumBrown;
      case BookCondition.good:
        return lightBrown;
      case BookCondition.acceptable:
        return Colors.grey;
    }
  }

  int _calculateDiscount(double original, double asking) {
    return (((original - asking) / original) * 100).round();
  }
}
