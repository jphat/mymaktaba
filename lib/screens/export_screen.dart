import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'account_screen.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Export Books')),
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Export',
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
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          final isEmpty = provider.savedBooks.isEmpty;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Add saved books to enable export.'),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isEmpty ? null : () => provider.exportData('CSV'),
                  child: const Text('Export to CSV'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isEmpty ? null : () => provider.exportData('JSON'),
                  child: const Text('Export to JSON'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isEmpty ? null : () => provider.exportData('Text'),
                  child: const Text('Export to Plain Text'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
