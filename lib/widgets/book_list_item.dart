import 'package:flutter/material.dart';
import '../models/book.dart';

class BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BookListItem({
    super.key,
    required this.book,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: book.thumbnailUrl != null
          ? Image.network(
              book.thumbnailUrl!,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.book),
            )
          : const Icon(Icons.book, size: 50),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.authors, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (book.isbn13 != null)
            Text(
              'ISBN13: ${book.isbn13}',
              style: const TextStyle(fontSize: 12),
            ),
          if (book.isbn10 != null)
            Text(
              'ISBN10: ${book.isbn10}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      trailing: trailing,
      onTap: onTap,
      isThreeLine: true,
    );
  }
}
