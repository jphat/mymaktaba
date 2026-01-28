import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String _googleBooksUrl =
      'https://www.googleapis.com/books/v1/volumes';
  static const String _openLibraryUrl = 'https://openlibrary.org/search.json';

  Future<List<Book>> searchBooks(String query) async {
    final googleBooksFuture = _searchGoogleBooks(query);
    final openLibraryFuture = _searchOpenLibrary(query);

    final results = await Future.wait([googleBooksFuture, openLibraryFuture]);

    // Merge results
    return [...results[0], ...results[1]];
  }

  Future<List<Book>> _searchGoogleBooks(String query) async {
    try {
      final response = await http.get(Uri.parse('$_googleBooksUrl?q=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          return (data['items'] as List).map((item) {
            final volumeInfo = item['volumeInfo'];
            final authors = volumeInfo['authors'] != null
                ? (volumeInfo['authors'] as List).join(', ')
                : 'Unknown Author';

            String? isbn10;
            String? isbn13;
            if (volumeInfo['industryIdentifiers'] != null) {
              for (var id in volumeInfo['industryIdentifiers']) {
                if (id['type'] == 'ISBN_10') isbn10 = id['identifier'];
                if (id['type'] == 'ISBN_13') isbn13 = id['identifier'];
              }
            }

            return Book(
              title: volumeInfo['title'] ?? 'No Title',
              authors: authors,
              isbn10: isbn10,
              isbn13: isbn13,
              description: volumeInfo['description'],
              thumbnailUrl: volumeInfo['imageLinks']?['thumbnail'],
              isSaved: false,
            );
          }).toList();
        }
      }
    } catch (e) {
      developer.log('Google Books API Error: $e');
    }
    return [];
  }

  Future<List<Book>> _searchOpenLibrary(String query) async {
    try {
      final response = await http.get(Uri.parse('$_openLibraryUrl?q=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['docs'] != null) {
          return (data['docs'] as List).take(10).map((doc) {
            final authors = doc['author_name'] != null
                ? (doc['author_name'] as List).join(', ')
                : 'Unknown Author';

            String? isbn10;
            String? isbn13;

            if (doc['isbn'] != null) {
              for (var isbn in doc['isbn']) {
                if (isbn.length == 10) isbn10 = isbn;
                if (isbn.length == 13) isbn13 = isbn;
                if (isbn10 != null && isbn13 != null) break;
              }
            }

            return Book(
              title: doc['title'] ?? 'No Title',
              authors: authors,
              isbn10: isbn10,
              isbn13: isbn13,
              description: doc['first_sentence'] != null
                  ? (doc['first_sentence'] is List
                        ? doc['first_sentence'][0]
                        : doc['first_sentence'])
                  : null, // OpenLibrary search results provide limited description usually
              thumbnailUrl: doc['cover_i'] != null
                  ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg'
                  : null,
              isSaved: false,
            );
          }).toList();
        }
      }
    } catch (e) {
      developer.log('Open Library API Error: $e');
    }
    return [];
  }
}
