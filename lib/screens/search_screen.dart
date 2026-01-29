import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_list_item.dart';
import '../widgets/custom_icon.dart';
import 'scanner_screen.dart';
import 'account_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Provider.of<BookProvider>(context, listen: false).searchBooks(query);
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (result != null && result is String) {
      if (_isValidIsbn(result)) {
        _searchController.text = result;
        _performSearch();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid ISBN scanned.')),
          );
        }
      }
    }
  }

  bool _isValidIsbn(String isbn) {
    final regex = RegExp(r'^(?:(?:\d[\s-]?){9}[\dX]|(?:\d[\s-]?){12}\d)$');
    return regex.hasMatch(isbn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Search Books')),
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            iconSize: 32,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          const SizedBox(width: 8), // Padding from the right edge
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Title, Author or ISBN',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                IconButton(
                  icon: const CustomIcon('scan-barcode', size: 24),
                  onPressed: _scanBarcode,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.searchResults.isEmpty &&
                    _searchController.text.isNotEmpty &&
                    !provider.isLoading) {
                  return const Center(child: Text('No results found.'));
                }

                return ListView.builder(
                  itemCount: provider.searchResults.length,
                  itemBuilder: (context, index) {
                    final book = provider.searchResults[index];
                    return BookListItem(
                      book: book,
                      trailing: book.isSaved
                          ? const Icon(Icons.check, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () {
                                provider.addBook(book);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Book saved!')),
                                );
                              },
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
