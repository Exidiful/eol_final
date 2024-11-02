import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'services/firebase_service.dart';
import 'providers/aws_service_provider.dart';
import 'providers/migration_project_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/theme_provider.dart';
import 'mock_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseService.initializeFirebase();
  
  // Load mock data
  await MockData.loadData();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AwsServiceProvider()..fetchAwsServices()),
        ChangeNotifierProvider(create: (_) => MigrationProjectProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'AWS Migration Dashboard',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark().copyWith(
              // Customize dark theme here if needed
              scaffoldBackgroundColor: Color(0xFF1E2632),
              cardColor: Color(0xFF2A3441),
            ),
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
