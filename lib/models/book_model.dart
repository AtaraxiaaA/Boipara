/// Book Models for Boipara App
/// Contains models for:
/// - PublishedBook: Books from new indie authors
/// - ThriftBook: Preloved/secondhand books from sellers
/// - CartItem: Items in shopping cart

// Enum for book condition
enum BookCondition {
  brandNew,
  likeNew,
  veryGood,
  good,
  acceptable,
}

extension BookConditionExtension on BookCondition {
  String get displayName {
    switch (this) {
      case BookCondition.brandNew:
        return 'Brand New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.veryGood:
        return 'Very Good';
      case BookCondition.good:
        return 'Good';
      case BookCondition.acceptable:
        return 'Acceptable';
    }
  }

  String get description {
    switch (this) {
      case BookCondition.brandNew:
        return 'Never used, in original packaging';
      case BookCondition.likeNew:
        return 'No signs of wear, pristine condition';
      case BookCondition.veryGood:
        return 'Minimal wear, no major defects';
      case BookCondition.good:
        return 'Some wear, but fully readable';
      case BookCondition.acceptable:
        return 'Noticeable wear, all pages intact';
    }
  }
}

// Enum for book binding type
enum BindingType {
  paperback,
  hardcover,
}

extension BindingTypeExtension on BindingType {
  String get displayName {
    switch (this) {
      case BindingType.paperback:
        return 'Paperback';
      case BindingType.hardcover:
        return 'Hardcover';
    }
  }
}

// Enum for book type (published or thrift)
enum BookType {
  published,
  thrift,
}

/// Model for books published by indie authors
class PublishedBook {
  final String id;
  final String title;
  final String authorName;
  final String description;
  final String summary;
  final String genre;
  final String language;
  final int pageCount;
  final BindingType bindingType;
  final double price;
  final int inStock;
  final String? coverUrl;
  final String? isbn;
  final DateTime publishedDate;
  final List<BookReview> reviews;
  final double rating;

  const PublishedBook({
    required this.id,
    required this.title,
    required this.authorName,
    required this.description,
    required this.summary,
    required this.genre,
    required this.language,
    required this.pageCount,
    required this.bindingType,
    required this.price,
    required this.inStock,
    this.coverUrl,
    this.isbn,
    required this.publishedDate,
    this.reviews = const [],
    this.rating = 0.0,
  });
}

/// Model for thrift/preloved books from sellers
class ThriftBook {
  final String id;
  final String title;
  final String authorName;
  final String sellerName;
  final String sellerId;
  final BookCondition condition;
  final String conditionNotes;
  final double originalPrice;
  final double askingPrice;
  final String? edition;
  final int pageCount;
  final DateTime purchasedDate;
  final List<String> imageUrls;
  final String? additionalNotes;
  final DateTime listedDate;

  const ThriftBook({
    required this.id,
    required this.title,
    required this.authorName,
    required this.sellerName,
    required this.sellerId,
    required this.condition,
    required this.conditionNotes,
    required this.originalPrice,
    required this.askingPrice,
    this.edition,
    required this.pageCount,
    required this.purchasedDate,
    this.imageUrls = const [],
    this.additionalNotes,
    required this.listedDate,
  });
}

/// Model for book reviews
class BookReview {
  final String id;
  final String reviewerName;
  final String reviewerId;
  final double rating;
  final String comment;
  final DateTime reviewDate;

  const BookReview({
    required this.id,
    required this.reviewerName,
    required this.reviewerId,
    required this.rating,
    required this.comment,
    required this.reviewDate,
  });
}

/// Model for cart items
class CartItem {
  final String id;
  final String bookId;
  final String title;
  final String authorOrSeller;
  final double price;
  final int quantity;
  final BookType bookType;
  final String? coverUrl;

  const CartItem({
    required this.id,
    required this.bookId,
    required this.title,
    required this.authorOrSeller,
    required this.price,
    required this.quantity,
    required this.bookType,
    this.coverUrl,
  });

  double get totalPrice => price * quantity;
}

/// Model for user shipping info
class ShippingInfo {
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String postalCode;

  const ShippingInfo({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.postalCode,
  });
}
