import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../widgets/custom_app_bar.dart';

class AddBookScreen extends StatefulWidget {
  final Book? bookToEdit;
  const AddBookScreen({super.key, this.bookToEdit});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorsController = TextEditingController();
  final _isbn10Controller = TextEditingController();
  final _isbn13Controller = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      _titleController.text = widget.bookToEdit!.title;
      _authorsController.text = widget.bookToEdit!.authors;
      _isbn10Controller.text = widget.bookToEdit!.isbn10 ?? '';
      _isbn13Controller.text = widget.bookToEdit!.isbn13 ?? '';
      _descController.text = widget.bookToEdit!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorsController.dispose();
    _isbn10Controller.dispose();
    _isbn13Controller.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        id: widget.bookToEdit?.id,
        title: _titleController.text,
        authors: _authorsController.text,
        isbn10: _isbn10Controller.text.isNotEmpty
            ? _isbn10Controller.text
            : null,
        isbn13: _isbn13Controller.text.isNotEmpty
            ? _isbn13Controller.text
            : null,
        description: _descController.text.isNotEmpty
            ? _descController.text
            : null,
        thumbnailUrl: widget.bookToEdit?.thumbnailUrl,
        isSaved: true,
      );

      final provider = Provider.of<BookProvider>(context, listen: false);
      if (widget.bookToEdit != null) {
        provider.updateBook(newBook);
      } else {
        provider.addBook(newBook);
      }

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        // Clear form if we are in the TabView and didn't push a new route
        _titleController.clear();
        _authorsController.clear();
        _isbn10Controller.clear();
        _isbn13Controller.clear();
        _descController.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Book saved!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookToEdit != null;
    return Scaffold(
      appBar: CustomAppBar(title: isEditing ? 'Edit Book' : 'Add Book'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (Required)',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter title'
                    : null,
              ),
              TextFormField(
                controller: _authorsController,
                decoration: const InputDecoration(
                  labelText: 'Authors (comma separated)',
                ),
              ),
              TextFormField(
                controller: _isbn10Controller,
                decoration: const InputDecoration(labelText: 'ISBN 10'),
              ),
              TextFormField(
                controller: _isbn13Controller,
                decoration: const InputDecoration(labelText: 'ISBN 13'),
              ),
              TextFormField(
                controller: _descController,
                maxLength: 100,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  helperText: 'Max 100 characters',
                ),
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) {
                      return Text('$currentLength/$maxLength');
                    },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(isEditing ? 'Update Book' : 'Save Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
