import 'package:flutter/material.dart';
import '../widgets/custom_icon.dart';
import 'home_screen.dart';
import 'add_book_screen.dart';
import 'export_screen.dart';
import 'search_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AddBookScreen(),
    const ExportScreen(),
    const SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: CustomIcon('house-heart'), label: 'Home'),
          NavigationDestination(icon: CustomIcon('plus'), label: 'Add'),
          NavigationDestination(icon: CustomIcon('download'), label: 'Export'),
          NavigationDestination(icon: CustomIcon('search'), label: 'Search'),
        ],
      ),
    );
  }
}
