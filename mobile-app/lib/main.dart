import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/destination_provider.dart';
import 'core/providers/itinerary_provider.dart';
import 'features/auth/presentation/screens/simple_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Test network connectivity
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('Network connectivity test passed');
    }
  } on SocketException catch (_) {
    print('Network connectivity test failed - no internet connection');
  }

  // Test Supabase URL resolution
  try {
    final result =
        await InternetAddress.lookup('tmucyuaffclznrfnmyda.supabase.co');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('Supabase URL resolution test passed: ${result[0].address}');
    }
  } on SocketException catch (e) {
    print('Supabase URL resolution test failed: $e');
  }

  try {
    print('Initializing Supabase with URL: ${SupabaseConfig.url}');
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    print('Error type: ${e.runtimeType}');
    if (e is SocketException) {
      print('Socket error details: ${e.message}');
      print('Socket error address: ${e.address}');
      print('Socket error port: ${e.port}');
    }
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
        home: const SimpleLoginScreen(),
      ),
    );
  }
}
