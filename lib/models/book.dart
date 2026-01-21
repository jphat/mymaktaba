class Book {
  final int? id;
  final String title;
  final String authors;
  final String? isbn10;
  final String? isbn13;
  final String? description;
  final String? thumbnailUrl;
  // Indicates if the book is saved in local database
  bool isSaved;

  Book({
    this.id,
    required this.title,
    required this.authors,
    this.isbn10,
    this.isbn13,
    this.description,
    this.thumbnailUrl,
    this.isSaved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'isbn10': isbn10,
      'isbn13': isbn13,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      authors: map['authors'] ?? '',
      isbn10: map['isbn10'],
      isbn13: map['isbn13'],
      description: map['description'],
      thumbnailUrl: map['thumbnailUrl'],
      isSaved:
          true, // Assuming from map implies from DB unless specified otherwise
    );
  }

  // Create a copy with overrides
  Book copyWith({
    int? id,
    String? title,
    String? authors,
    String? isbn10,
    String? isbn13,
    String? description,
    String? thumbnailUrl,
    bool? isSaved,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      isbn10: isbn10 ?? this.isbn10,
      isbn13: isbn13 ?? this.isbn13,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
