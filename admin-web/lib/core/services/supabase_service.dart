import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // User Management Functions
  static Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String name,
    required List<UserRole> roles,
    String? photoUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-user',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'roles': roles.map((role) => role.name).toList(),
          'photoUrl': photoUrl,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to create user: ${response.data['error']}');
      }

      return response.data;
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  static Future<Map<String, dynamic>> createTraveler({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? notes,
    bool isActive = true,
    Map<String, dynamic>? profile,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-traveler',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'notes': notes,
          'isActive': isActive,
          'profile': profile,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to create traveler: ${response.data['error']}');
      }

      return response.data;
    } catch (e) {
      throw Exception('Error creating traveler: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'update-user',
        body: {
          'userId': userId,
          'updates': updates,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to update user: ${response.data['error']}');
      }

      return response.data;
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// Update user email in both Auth and database (admin only)
  static Future<Map<String, dynamic>> updateUserEmail({
    required String userId,
    required String newEmail,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'update-user-email',
        body: {
          'userId': userId,
          'newEmail': newEmail,
        },
      );

      if (response.status != 200) {
        throw Exception(
            'Failed to update user email: ${response.data['error']}');
      }

      return response.data;
    } catch (e) {
      throw Exception('Error updating user email: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteUser({
    required String userId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'delete-user',
        body: {
          'userId': userId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to delete user: ${response.data['error']}');
      }

      return response.data;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // User Retrieval Functions
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((userData) => User.fromSupabase(userData))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<User?> getUserById(String userId) async {
    try {
      final response =
          await _supabase.from('users').select('*').eq('id', userId).single();

      final user = User.fromSupabase(response);

      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<List<User>> getTravelersByAgentId(String agentId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('travel_agent_id', agentId)
          .contains('roles', ['traveler']).order('created_at',
              ascending: false);

      return (response as List)
          .map((userData) => User.fromSupabase(userData))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('email', email.toLowerCase())
          .single();

      return User.fromSupabase(response);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> assignTravelerToAgent(
    String travelerId,
    String agentId, {
    String? name,
    String? phone,
    String? notes,
    bool? isActive,
    Map<String, dynamic>? profile,
  }) async {
    try {
      final updates = <String, dynamic>{
        'travel_agent_id': agentId,
      };

      if (name != null) updates['name'] = name;
      if (isActive != null) updates['is_active'] = isActive;

      // Update profile if provided
      if (phone != null || notes != null || profile != null) {
        final currentUser = await getUserById(travelerId);
        final currentProfile = currentUser?.profile ?? <String, dynamic>{};

        if (phone != null) currentProfile['phone'] = phone;
        if (notes != null) currentProfile['notes'] = notes;
        if (profile != null) {
          currentProfile.addAll(profile);
        }

        updates['profile'] = currentProfile;
      }

      await _supabase.from('users').update(updates).eq('id', travelerId);

      return true;
    } catch (e) {
      print('Error assigning traveler to agent: $e');
      return false;
    }
  }

  /// Update traveler profile data directly in database (no Edge Function required)
  static Future<bool> updateTravelerProfile({
    required String travelerId,
    String? name,
    Map<String, dynamic>? profile,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (profile != null) updateData['profile'] = profile;
      if (isActive != null) updateData['is_active'] = isActive;

      await _supabase.from('users').update(updateData).eq('id', travelerId);

      return true;
    } catch (e) {
      print('Error updating traveler profile: $e');
      return false;
    }
  }

  // Authentication Functions
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static SupabaseClient getSupabaseClient() {
    return _supabase;
  }

  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  static User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // For now, return a basic user object
    // In a real app, you'd fetch the full user data from the database
    return User(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? 'Unknown',
      photoUrl: user.userMetadata?['photo_url'],
      roles: [], // This should be fetched from the database
      isActive: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      profile: {},
    );
  }

  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
