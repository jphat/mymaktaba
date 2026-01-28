import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/book_provider.dart';
import '../widgets/book_list_item.dart';
import 'add_book_screen.dart';

import 'package:mymaktaba/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load books every time the screen is initialized (or displayed if possible)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).loadSavedBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.savedBooks.isEmpty) {
            return const Center(child: Text('No saved books. Add some!'));
          }
          return ListView.builder(
            itemCount: provider.savedBooks.length,
            itemBuilder: (context, index) {
              final book = provider.savedBooks[index];
              return Slidable(
                key: ValueKey(book.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        final text =
                            'CheckoutBook: ${book.title}\nAuthor: ${book.authors}\nISBN: ${book.isbn13 ?? book.isbn10}';
                        SharePlus.instance.share(ShareParams(text: text));
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons
                          .share, // fallback if custom icon not easy in SlidableAction, but check below
                      label: 'Share',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddBookScreen(bookToEdit: book),
                          ),
                        );
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        Provider.of<BookProvider>(
                          context,
                          listen: false,
                        ).deleteBook(book.id!);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: BookListItem(book: book),
              );
            },
          );
        },
      ),
    );
  }
}
