import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mymaktaba/services/auth_service.dart';
import '../providers/theme_provider.dart';

class AccountScreen extends StatelessWidget {
  final AuthService? authService;

  const AccountScreen({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    final auth = authService ?? AuthService();
    final user = auth.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentBrightness = Theme.of(context).brightness;
    final isDarkMode =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            currentBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              if (user.photoURL != null)
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.photoURL!),
                  ),
                )
              else
                const Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 20),
              if (user.displayName != null && user.displayName!.isNotEmpty) ...[
                Text('Name', style: Theme.of(context).textTheme.labelLarge),
                Text(
                  user.displayName!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
              ],
              Text('Email', style: Theme.of(context).textTheme.labelLarge),
              Text(
                user.email ?? 'No email available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text('User ID', style: Theme.of(context).textTheme.labelLarge),
              Text(user.uid, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(
                  themeProvider.themeMode == ThemeMode.system
                      ? 'Following system settings'
                      : isDarkMode
                      ? 'Enabled'
                      : 'Disabled',
                ),
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const Text('No user signed in'),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await auth.signOut();
                  // Pop the account screen.
                  // Since main.dart listens to auth state changes,
                  // the app will likely redirect to login screen automatically if the MainLayout is wrapped in StreamBuilder (which it is).
                  // But if we pushed this screen, we might need to pop it first or let the rebuilding of MaterialApp handle it.
                  // The StreamBuilder in main.dart switches between MainLayout and LoginScreen.
                  // If we are deep in navigation stack (MainLayout -> AccountScreen), and auth state changes,
                  // MainLayout is replaced by LoginScreen. So the stack might be reset or we might need to pop.
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
