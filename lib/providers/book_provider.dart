import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/book.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _savedBooks = [];
  List<Book> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get savedBooks => _savedBooks;
  List<Book> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiService _apiService = ApiService();

  Future<void> loadSavedBooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _savedBooks = await _dbHelper.readAllBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(Book book) async {
    await _dbHelper.create(book);
    await loadSavedBooks();

    // Update state in search results if present
    final index = _searchResults.indexWhere(
      (b) =>
          (b.isbn13 != null && b.isbn13 == book.isbn13) ||
          (b.isbn10 != null && b.isbn10 == book.isbn10) ||
          b.title == book.title,
    );

    if (index != -1) {
      _searchResults[index] = _searchResults[index].copyWith(isSaved: true);
      notifyListeners();
    }
  }

  Future<void> updateBook(Book book) async {
    await _dbHelper.update(book);
    await loadSavedBooks();
  }

  Future<void> deleteBook(int id) async {
    await _dbHelper.delete(id);
    await loadSavedBooks();

    // We might want to update search results too
    // but mapping back from ID to search result (which has no ID) is hard.
    // However, simpler to just searching again or ignoring it,
    // but for consistency we can match by ISBNs in search results to mark isSaved=false.
  }

  Future<void> searchBooks(String query) async {
    _isLoading = true;
    _error = null;
    _searchResults = [];
    notifyListeners();

    try {
      // 1. Search Local
      final localResults = await _dbHelper.searchLocalBooks(query);

      // 2. Search API
      final apiResults = await _apiService.searchBooks(query);

      // 3. Merge and Check Saved Status
      // We want to show local results first? Or mixed?
      // "Unified search of saved books and ... APIs"
      // Let's list local books first, marked as saved.

      List<Book> results = [...localResults];

      for (var book in apiResults) {
        // Check if this book is already in localResults (by ISBN or Title exact match?)
        // Or check if it is in _savedBooks (more reliable for isSaved flag)

        bool alreadyInList = results.any(
          (b) =>
              (b.isbn13 != null &&
                  book.isbn13 != null &&
                  b.isbn13 == book.isbn13) ||
              (b.isbn10 != null &&
                  book.isbn10 != null &&
                  b.isbn10 == book.isbn10),
        );

        if (!alreadyInList) {
          // check if actually saved in DB even if not in local search results (e.g. search query match API but not local by text)
          bool isSaved = await _dbHelper.isBookSaved(book.isbn10, book.isbn13);
          results.add(book.copyWith(isSaved: isSaved));
        }
      }

      _searchResults = results;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Export
  Future<void> exportData(String format) async {
    if (_savedBooks.isEmpty) return;

    String data = '';
    String fileName = 'books_export';
    String mimeType = 'text/plain';

    switch (format) {
      case 'CSV':
        final List<List<dynamic>> rows = [];
        rows.add(['Title', 'Authors', 'ISBN10', 'ISBN13', 'Description']);
        for (var book in _savedBooks) {
          rows.add([
            book.title,
            book.authors,
            book.isbn10 ?? '',
            book.isbn13 ?? '',
            book.description ?? '',
          ]);
        }
        data = const ListToCsvConverter().convert(rows);
        fileName += '.csv';
        mimeType = 'text/csv';
        break;
      case 'JSON':
        data = jsonEncode(_savedBooks.map((b) => b.toMap()).toList());
        fileName += '.json';
        mimeType = 'application/json';
        break;
      case 'Text':
        final buffer = StringBuffer();
        for (var book in _savedBooks) {
          buffer.writeln('Title: ${book.title}');
          buffer.writeln('Authors: ${book.authors}');
          buffer.writeln('ISBN: ${book.isbn13 ?? book.isbn10 ?? 'N/A'}');
          buffer.writeln('---');
        }
        data = buffer.toString();
        fileName += '.txt';
        break;
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(data);

    await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
  }

  bool isValidIsbn(String isbn) {
    final regex = RegExp(r'^(?:(?:\d[\s-]?){9}[\dX]|(?:\d[\s-]?){12}\d)$');
    return regex.hasMatch(isbn);
  }
}
