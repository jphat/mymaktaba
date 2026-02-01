import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/account_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isSignedIn = FirebaseAuth.instance.currentUser != null;

    return AppBar(
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
      ),
      actions: isSignedIn
          ? [
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                iconSize: 32,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8), // Padding from the right edge
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
