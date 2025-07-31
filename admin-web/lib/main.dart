import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/destination_provider.dart';
import 'features/admin/presentation/screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    print('Supabase initialized successfully for Admin Panel');
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
      ],
      child: MaterialApp(
        title: 'WanderWise Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AdminLoginScreen(),
      ),
    );
  }
}
