import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Dark Mode'),
            subtitle: Text(themeProvider.isDarkMode ? 'On' : 'Off'),
            leading: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),
          ListTile(
            title: Text('Notifications'),
            subtitle: Text('On'),
            leading: Icon(Icons.notifications),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notifications toggle
              },
            ),
          ),
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show about dialog
            },
          ),
          Divider(),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: () async {
              await FirebaseService.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
