/// Hardcoded Book Data for Boipara App
/// This file contains sample data that simulates backend data
/// TODO: Replace with actual backend API calls

import '../models/book_model.dart';

/// Sample Published Books from Indie Authors
final List<PublishedBook> publishedBooks = [
  PublishedBook(
    id: 'pub_001',
    title: 'The Silent Echo',
    authorName: 'Rahim Ahmed',
    description:
        'A gripping tale of mystery and self-discovery set in the bustling streets of Dhaka. Follow protagonist Karim as he unravels secrets that have been buried for generations.',
    summary:
        'When Karim returns to his ancestral home after his grandfather\'s death, he discovers a hidden diary that reveals family secrets spanning decades. As he delves deeper into the past, he realizes that some echoes of history refuse to stay silent. This debut novel weaves together themes of family, identity, and the weight of unspoken truths.',
    genre: 'Mystery/Thriller',
    language: 'Bangla',
    pageCount: 284,
    bindingType: BindingType.paperback,
    price: 450,
    inStock: 25,
    isbn: '978-984-123-456-7',
    publishedDate: DateTime(2026, 1, 15),
    rating: 4.5,
    reviews: [
      BookReview(
        id: 'rev_001',
        reviewerName: 'Fatima Khan',
        reviewerId: 'user_101',
        rating: 5.0,
        comment:
            'Absolutely captivating! Could not put it down. A brilliant debut from Rahim Ahmed.',
        reviewDate: DateTime(2026, 2, 10),
      ),
      BookReview(
        id: 'rev_002',
        reviewerName: 'Sakib Hasan',
        reviewerId: 'user_102',
        rating: 4.0,
        comment:
            'Well-written with great character development. The ending was unexpected.',
        reviewDate: DateTime(2026, 2, 20),
      ),
    ],
  ),
  PublishedBook(
    id: 'pub_002',
    title: 'Dreams of Tomorrow',
    authorName: 'Fatima Khan',
    description:
        'An inspiring collection of short stories about hope, resilience, and the human spirit in modern Bangladesh.',
    summary:
        'Through twelve interconnected stories, Fatima Khan paints a vivid portrait of contemporary Bangladeshi life. From the tech entrepreneurs of Gulshan to the fishermen of Cox\'s Bazar, these tales celebrate the dreams that keep us moving forward.',
    genre: 'Short Stories',
    language: 'English',
    pageCount: 198,
    bindingType: BindingType.paperback,
    price: 380,
    inStock: 40,
    publishedDate: DateTime(2026, 2, 1),
    rating: 4.8,
    reviews: [
      BookReview(
        id: 'rev_003',
        reviewerName: 'Nadia Islam',
        reviewerId: 'user_103',
        rating: 5.0,
        comment: 'Each story touched my heart. Beautiful writing!',
        reviewDate: DateTime(2026, 3, 5),
      ),
    ],
  ),
  PublishedBook(
    id: 'pub_003',
    title: 'Midnight Stories',
    authorName: 'Karim Hossain',
    description:
        'A collection of spine-tingling horror stories rooted in Bengali folklore and urban legends.',
    summary:
        'From the haunted ruins of ancient temples to the eerie corridors of modern apartments, these thirteen stories will keep you awake long after midnight. Karim Hossain masterfully blends traditional Bengali ghost stories with contemporary horror.',
    genre: 'Horror',
    language: 'Bangla',
    pageCount: 256,
    bindingType: BindingType.hardcover,
    price: 520,
    inStock: 15,
    isbn: '978-984-789-012-3',
    publishedDate: DateTime(2025, 12, 1),
    rating: 4.3,
    reviews: [],
  ),
  PublishedBook(
    id: 'pub_004',
    title: 'Bengal Tales',
    authorName: 'Nasreen Akter',
    description:
        'Heartwarming stories of village life in Bangladesh, celebrating the simple joys and enduring traditions.',
    summary:
        'Nasreen Akter takes us on a journey through the verdant landscapes of rural Bangladesh. These tales capture the essence of village life - the festivals, the harvests, the love stories, and the unbreakable bonds of community.',
    genre: 'Fiction',
    language: 'Bangla',
    pageCount: 312,
    bindingType: BindingType.paperback,
    price: 420,
    inStock: 30,
    publishedDate: DateTime(2026, 1, 20),
    rating: 4.6,
    reviews: [
      BookReview(
        id: 'rev_004',
        reviewerName: 'Tanvir Rahman',
        reviewerId: 'user_104',
        rating: 5.0,
        comment: 'Reminded me of my childhood in the village. Nostalgic and beautiful.',
        reviewDate: DateTime(2026, 2, 15),
      ),
    ],
  ),
  PublishedBook(
    id: 'pub_005',
    title: 'Poetry of Life',
    authorName: 'Imran Chowdhury',
    description:
        'A contemporary poetry collection exploring love, loss, and the digital age.',
    summary:
        'In this debut collection, Imran Chowdhury crafts verses that speak to the millennial experience. From the glow of smartphone screens to the ache of distant love, these poems capture the complexities of modern life with honesty and beauty.',
    genre: 'Poetry',
    language: 'English',
    pageCount: 128,
    bindingType: BindingType.paperback,
    price: 280,
    inStock: 50,
    publishedDate: DateTime(2026, 2, 14),
    rating: 4.7,
    reviews: [],
  ),
  PublishedBook(
    id: 'pub_006',
    title: 'The River Remembers',
    authorName: 'Anika Rahman',
    description:
        'A powerful novel about the 1971 Liberation War, told through the eyes of a young woman.',
    summary:
        'Based on her grandmother\'s memoirs, Anika Rahman brings to life the courage and sacrifice of ordinary Bangladeshis during the Liberation War. This is a story of love, loss, and the indomitable spirit of a nation.',
    genre: 'Historical Fiction',
    language: 'Bangla',
    pageCount: 368,
    bindingType: BindingType.hardcover,
    price: 580,
    inStock: 20,
    isbn: '978-984-456-789-0',
    publishedDate: DateTime(2025, 12, 16),
    rating: 4.9,
    reviews: [
      BookReview(
        id: 'rev_005',
        reviewerName: 'Rafiq Ali',
        reviewerId: 'user_105',
        rating: 5.0,
        comment: 'A masterpiece. Every Bangladeshi should read this book.',
        reviewDate: DateTime(2026, 1, 10),
      ),
      BookReview(
        id: 'rev_006',
        reviewerName: 'Ayesha Begum',
        reviewerId: 'user_106',
        rating: 5.0,
        comment: 'I cried multiple times. Beautifully written and deeply moving.',
        reviewDate: DateTime(2026, 1, 25),
      ),
    ],
  ),
];

/// Sample Thrift/Preloved Books from Sellers
final List<ThriftBook> thriftBooks = [
  ThriftBook(
    id: 'thrift_001',
    title: 'The Alchemist',
    authorName: 'Paulo Coelho',
    sellerName: 'Sakib Rahman',
    sellerId: 'seller_001',
    condition: BookCondition.veryGood,
    conditionNotes: 'Minor wear on spine, pages in excellent condition',
    originalPrice: 450,
    askingPrice: 250,
    edition: 'International Edition',
    pageCount: 208,
    purchasedDate: DateTime(2023, 6, 15),
    listedDate: DateTime(2026, 3, 1),
    additionalNotes: 'One of my favorite books. Selling because I have a newer edition.',
  ),
  ThriftBook(
    id: 'thrift_002',
    title: 'Atomic Habits',
    authorName: 'James Clear',
    sellerName: 'Nadia Islam',
    sellerId: 'seller_002',
    condition: BookCondition.likeNew,
    conditionNotes: 'Read once, no marks or highlights',
    originalPrice: 680,
    askingPrice: 380,
    edition: '1st Edition',
    pageCount: 320,
    purchasedDate: DateTime(2024, 1, 10),
    listedDate: DateTime(2026, 3, 5),
    additionalNotes: 'Includes the original bookmark.',
  ),
  ThriftBook(
    id: 'thrift_003',
    title: '1984',
    authorName: 'George Orwell',
    sellerName: 'Tanvir Hasan',
    sellerId: 'seller_003',
    condition: BookCondition.good,
    conditionNotes: 'Some highlighting on first few chapters, cover has minor scratches',
    originalPrice: 380,
    askingPrice: 220,
    pageCount: 328,
    purchasedDate: DateTime(2022, 8, 20),
    listedDate: DateTime(2026, 2, 28),
  ),
  ThriftBook(
    id: 'thrift_004',
    title: 'Sapiens: A Brief History of Humankind',
    authorName: 'Yuval Noah Harari',
    sellerName: 'Ayesha Begum',
    sellerId: 'seller_004',
    condition: BookCondition.veryGood,
    conditionNotes: 'Excellent condition, no marks',
    originalPrice: 850,
    askingPrice: 450,
    edition: 'Paperback Edition',
    pageCount: 464,
    purchasedDate: DateTime(2023, 3, 5),
    listedDate: DateTime(2026, 3, 8),
    additionalNotes: 'A must-read! Selling to make room for new books.',
  ),
  ThriftBook(
    id: 'thrift_005',
    title: 'The Great Gatsby',
    authorName: 'F. Scott Fitzgerald',
    sellerName: 'Rafiq Ali',
    sellerId: 'seller_005',
    condition: BookCondition.acceptable,
    conditionNotes: 'Cover worn, pages yellowed but all intact',
    originalPrice: 320,
    askingPrice: 180,
    edition: 'Vintage Classics',
    pageCount: 180,
    purchasedDate: DateTime(2020, 5, 12),
    listedDate: DateTime(2026, 3, 2),
  ),
  ThriftBook(
    id: 'thrift_006',
    title: 'Pride and Prejudice',
    authorName: 'Jane Austen',
    sellerName: 'Mim Chowdhury',
    sellerId: 'seller_006',
    condition: BookCondition.likeNew,
    conditionNotes: 'Beautiful collector\'s edition, never read',
    originalPrice: 520,
    askingPrice: 350,
    edition: 'Collector\'s Edition',
    pageCount: 432,
    purchasedDate: DateTime(2024, 2, 14),
    listedDate: DateTime(2026, 3, 10),
    additionalNotes: 'Gift that I already have. Includes ribbon bookmark.',
  ),
  ThriftBook(
    id: 'thrift_007',
    title: 'The Psychology of Money',
    authorName: 'Morgan Housel',
    sellerName: 'Imran Khan',
    sellerId: 'seller_007',
    condition: BookCondition.veryGood,
    conditionNotes: 'Light pencil notes in margins, easily erasable',
    originalPrice: 580,
    askingPrice: 320,
    edition: '1st Edition',
    pageCount: 256,
    purchasedDate: DateTime(2023, 11, 20),
    listedDate: DateTime(2026, 3, 12),
  ),
  ThriftBook(
    id: 'thrift_008',
    title: 'To Kill a Mockingbird',
    authorName: 'Harper Lee',
    sellerName: 'Fariha Ahmed',
    sellerId: 'seller_008',
    condition: BookCondition.good,
    conditionNotes: 'School edition, some wear on cover',
    originalPrice: 400,
    askingPrice: 200,
    pageCount: 336,
    purchasedDate: DateTime(2021, 9, 1),
    listedDate: DateTime(2026, 3, 6),
  ),
];

/// Helper function to get all books combined
List<dynamic> getAllBooks() {
  return [...publishedBooks, ...thriftBooks];
}

/// Get published book by ID
PublishedBook? getPublishedBookById(String id) {
  try {
    return publishedBooks.firstWhere((book) => book.id == id);
  } catch (e) {
    return null;
  }
}

/// Get thrift book by ID
ThriftBook? getThriftBookById(String id) {
  try {
    return thriftBooks.firstWhere((book) => book.id == id);
  } catch (e) {
    return null;
  }
}
