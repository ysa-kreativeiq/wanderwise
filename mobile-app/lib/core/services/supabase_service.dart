import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';
import '../models/destination_model.dart';
import '../models/itinerary_model.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

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

  static Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'roles': ['traveler'],
      },
    );
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

  // User Management Functions
  static Future<User?> getUserById(String userId) async {
    try {
      final response =
          await _supabase.from('users').select('*').eq('id', userId).single();

      return User.fromSupabase(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _supabase.from('users').update(updates).eq('id', userId);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Destination Functions
  static Future<List<Destination>> getAllDestinations() async {
    try {
      final response = await _supabase
          .from('destinations')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((destinationData) => Destination.fromSupabase(destinationData))
          .toList();
    } catch (e) {
      print('Error fetching destinations: $e');
      return [];
    }
  }

  static Future<List<Destination>> getFeaturedDestinations() async {
    try {
      final response = await _supabase
          .from('destinations')
          .select('*')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('name');

      return (response as List)
          .map((destinationData) => Destination.fromSupabase(destinationData))
          .toList();
    } catch (e) {
      print('Error fetching featured destinations: $e');
      return [];
    }
  }

  static Future<Destination?> getDestinationById(String destinationId) async {
    try {
      final response = await _supabase
          .from('destinations')
          .select('*')
          .eq('id', destinationId)
          .single();

      return Destination.fromSupabase(response);
    } catch (e) {
      print('Error fetching destination: $e');
      return null;
    }
  }

  // Itinerary Functions
  static Future<List<Itinerary>> getUserItineraries(String userId) async {
    try {
      final response = await _supabase
          .from('itineraries')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((itineraryData) => Itinerary.fromSupabase(itineraryData))
          .toList();
    } catch (e) {
      print('Error fetching user itineraries: $e');
      return [];
    }
  }

  static Future<Itinerary?> createItinerary({
    required String userId,
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _supabase
          .from('itineraries')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'start_date': startDate?.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'status': 'draft',
            'is_public': false,
          })
          .select()
          .single();

      return Itinerary.fromSupabase(response);
    } catch (e) {
      print('Error creating itinerary: $e');
      return null;
    }
  }

  static Future<void> updateItinerary({
    required String itineraryId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _supabase.from('itineraries').update(updates).eq('id', itineraryId);
    } catch (e) {
      print('Error updating itinerary: $e');
      rethrow;
    }
  }

  static Future<void> deleteItinerary(String itineraryId) async {
    try {
      await _supabase.from('itineraries').delete().eq('id', itineraryId);
    } catch (e) {
      print('Error deleting itinerary: $e');
      rethrow;
    }
  }
}
