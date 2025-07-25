import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/destination_provider.dart';
import 'core/providers/itinerary_provider.dart';
import 'features/auth/presentation/screens/simple_login_screen.dart';
import 'features/admin/presentation/screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue running the app even if Firebase fails
  }

  runApp(const WanderWiseApp());
}

class WanderWiseApp extends StatelessWidget {
  const WanderWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
      ],
      child: MaterialApp(
        title: 'WanderWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SimpleLoginScreen(),
          '/admin': (context) => const AdminLoginScreen(),
        },
      ),
    );
  }
}
