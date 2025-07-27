import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new user using Supabase Edge Functions
  static Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String name,
    required List<UserRole> roles,
    String? photoUrl,
  }) async {
    try {
      print('🔄 Calling Supabase Edge Function: create-user');

      // Check authentication state
      final user = _supabase.auth.currentUser;
      print('🔍 Current user: ${user?.email}');
      print('🔍 User ID: ${user?.id}');
      print('🔍 Is authenticated: ${user != null}');

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.functions.invoke(
        'create-user',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'roles':
              roles.map((role) => role.toString().split('.').last).toList(),
          'photoUrl': photoUrl,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        print('✅ User created successfully via Supabase Edge Function');
        print('📧 Email: ${data['email']}');
        print('👤 Name: ${data['name']}');
        print('🆔 UID: ${data['userId']}');
        print('🔑 Roles: ${data['roles'].join(', ')}');
      }

      return data;
    } catch (e) {
      print('❌ Error calling create-user function: $e');
      rethrow;
    }
  }

  /// Update a user using Supabase Edge Functions
  static Future<Map<String, dynamic>> updateUser({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      print('🔄 Calling Supabase Edge Function: update-user');

      final response = await _supabase.functions.invoke(
        'update-user',
        body: {
          'userId': userId,
          'updates': updates,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        print('✅ User updated successfully via Supabase Edge Function');
        print('🆔 UID: ${data['userId']}');
      }

      return data;
    } catch (e) {
      print('❌ Error calling update-user function: $e');
      rethrow;
    }
  }

  /// Delete a user using Supabase Edge Functions
  static Future<Map<String, dynamic>> deleteUser({
    required String userId,
  }) async {
    try {
      print('🔄 Calling Supabase Edge Function: delete-user');

      final response = await _supabase.functions.invoke(
        'delete-user',
        body: {
          'userId': userId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        print('✅ User deleted successfully via Supabase Edge Function');
        print('🆔 UID: ${data['userId']}');
      }

      return data;
    } catch (e) {
      print('❌ Error calling delete-user function: $e');
      rethrow;
    }
  }

  /// Get all users from Supabase
  static Future<List<User>> getAllUsers() async {
    try {
      print('🔄 Fetching all users from Supabase');

      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      final List<dynamic> usersData = response as List<dynamic>;
      final users = usersData.map((data) => User.fromSupabase(data)).toList();

      print('✅ Fetched ${users.length} users from Supabase');
      return users;
    } catch (e) {
      print('❌ Error fetching users from Supabase: $e');
      rethrow;
    }
  }

  /// Get user by ID from Supabase
  static Future<User?> getUserById(String userId) async {
    try {
      print('🔄 Fetching user by ID: $userId');

      final response =
          await _supabase.from('users').select('*').eq('id', userId).single();

      final user = User.fromSupabase(response);
      print('✅ Fetched user: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Error fetching user by ID: $e');
      return null;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Signing in with email: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Signed in successfully: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      print('❌ Error signing in: $e');
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      print('🔄 Signing out');

      await _supabase.auth.signOut();
      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // Convert Supabase user to our User model
      return User(
        id: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'] ?? '',
        photoUrl: user.userMetadata?['photo_url'],
        roles: (user.userMetadata?['roles'] as List<dynamic>?)
                ?.map((role) => UserRole.values.firstWhere(
                      (e) => e.toString().split('.').last == role,
                      orElse: () => UserRole.traveler,
                    ))
                .toList() ??
            [UserRole.traveler],
        isActive: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    }
    return null;
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
