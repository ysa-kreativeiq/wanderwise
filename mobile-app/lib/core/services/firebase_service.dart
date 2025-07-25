import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseAnalytics? _analytics;

  static FirebaseApp get app {
    if (_app == null) {
      throw Exception(
          'Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _app!;
  }

  static FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  static FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  static FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  static FirebaseAnalytics get analytics {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  static Future<void> initialize() async {
    try {
      _app = await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _analytics = FirebaseAnalytics.instance;
      print('Firebase services initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static Future<bool> isInitialized() async {
    try {
      await Firebase.initializeApp();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Test method to verify Firebase configuration
  static Future<Map<String, bool>> testFirebaseServices() async {
    Map<String, bool> results = {};

    try {
      // Test Auth
      results['auth'] = auth != null;

      // Test Firestore
      await firestore.collection('test').limit(1).get();
      results['firestore'] = true;

      // Test Storage
      results['storage'] = storage != null;

      // Test Analytics
      results['analytics'] = analytics != null;

      print('Firebase services test results: $results');
      return results;
    } catch (e) {
      print('Error testing Firebase services: $e');
      return results;
    }
  }
}
