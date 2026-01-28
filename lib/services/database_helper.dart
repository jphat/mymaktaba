import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('maktaba.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE books ADD COLUMN dateAdded TEXT');
      await db.execute('ALTER TABLE books ADD COLUMN dateModified TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT'; // Nullable by default
    const textNotNull = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE books ( 
  id $idType, 
  title $textNotNull,
  authors $textNotNull,
  isbn10 $textType,
  isbn13 $textType,
  description $textType,
  thumbnailUrl $textType,
  dateAdded $textType,
  dateModified $textType
  )
    ''');
  }

  Future<Book> create(Book book) async {
    final db = await instance.database;
    // The Book constructor handles setting dateAdded and dateModified to now if not provided
    final id = await db.insert('books', book.toMap());
    return book.copyWith(id: id, isSaved: true);
  }

  Future<Book> readBook(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'books',
      columns: [
        'id',
        'title',
        'authors',
        'isbn10',
        'isbn13',
        'description',
        'thumbnailUrl',
        'dateAdded',
        'dateModified',
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Book>> readAllBooks() async {
    final db = await instance.database;
    const orderBy = 'dateAdded DESC, id DESC';
    final result = await db.query('books', orderBy: orderBy);

    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<int> update(Book book) async {
    final db = await instance.database;
    final bookWithModified = book.copyWith(dateModified: DateTime.now());

    return db.update(
      'books',
      bookWithModified.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Book>> searchLocalBooks(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'books',
      where: 'title LIKE ? OR authors LIKE ? OR isbn10 LIKE ? OR isbn13 LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<bool> isBookSaved(String? isbn10, String? isbn13) async {
    final db = await instance.database;
    if (isbn10 == null && isbn13 == null) return false;

    // Construct where clause dynamically
    String where = '';
    List<dynamic> args = [];

    if (isbn10 != null && isbn10.isNotEmpty) {
      where += 'isbn10 = ?';
      args.add(isbn10);
    }

    if (isbn13 != null && isbn13.isNotEmpty) {
      if (where.isNotEmpty) where += ' OR ';
      where += 'isbn13 = ?';
      args.add(isbn13);
    }

    if (where.isEmpty) return false;

    final result = await db.query('books', where: where, whereArgs: args);
    return result.isNotEmpty;
  }
}
