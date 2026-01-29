import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
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

  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference? get _userBooksRef {
    final uid = _userId;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('books');
  }

  Future<void> loadSavedBooks() async {
    if (_userBooksRef == null) {
      _savedBooks = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _userBooksRef!.get();
      _savedBooks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Book.fromMap(data);
      }).toList();

      _savedBooks.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading books from Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(Book book) async {
    if (_userBooksRef == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      final newDoc = _userBooksRef!.doc();
      final bookToSave = book.copyWith(id: newDoc.id, isSaved: true);

      await newDoc.set(bookToSave.toMap());
      await loadSavedBooks();

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
    } catch (e) {
      debugPrint('Error adding book to Firestore: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateBook(Book book) async {
    if (_userBooksRef == null) return;
    if (book.id == null) return;

    try {
      await _userBooksRef!.doc(book.id).update(book.toMap());
      await loadSavedBooks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBook(String id) async {
    if (_userBooksRef == null) return;

    try {
      await _userBooksRef!.doc(id).delete();
      await loadSavedBooks();

      for (int i = 0; i < _searchResults.length; i++) {
        if (_searchResults[i].id == id) {
          _searchResults[i] = _searchResults[i].copyWith(isSaved: false);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    _isLoading = true;
    _error = null;
    _searchResults = [];
    notifyListeners();

    try {
      final q = query.toLowerCase();
      final localResults = _savedBooks.where((book) {
        return book.title.toLowerCase().contains(q) ||
            book.authors.toLowerCase().contains(q) ||
            (book.isbn10?.contains(q) ?? false) ||
            (book.isbn13?.contains(q) ?? false);
      }).toList();

      final apiResults = await _apiService.searchBooks(query);

      List<Book> results = [...localResults];

      for (var book in apiResults) {
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
          bool isSaved = _savedBooks.any(
            (b) =>
                (b.isbn13 != null &&
                    book.isbn13 != null &&
                    b.isbn13 == book.isbn13) ||
                (b.isbn10 != null &&
                    book.isbn10 != null &&
                    b.isbn10 == book.isbn10),
          );

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

  Future<void> exportData(String format) async {
    if (_savedBooks.isEmpty) return;

    String data = '';
    String fileName = 'MyMaktaba_Export';
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

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)]),
    );
  }

  bool isValidIsbn(String isbn) {
    final regex = RegExp(r'^(?:(?:\d[\s-]?){9}[\dX]|(?:\d[\s-]?){12}\d)$');
    return regex.hasMatch(isbn);
  }
}
