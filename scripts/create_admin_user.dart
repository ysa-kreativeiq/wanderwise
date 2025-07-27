import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

// This script creates an admin user in Firebase
// Run with: dart scripts/create_admin_user.dart

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  print('🚀 Firebase Admin User Creator');
  print('==============================\n');

  // Get user input
  stdout.write('Enter admin email: ');
  final email = stdin.readLineSync()?.trim();

  if (email == null || email.isEmpty) {
    print('❌ Email is required');
    exit(1);
  }

  stdout.write('Enter admin password (min 6 chars): ');
  final password = stdin.readLineSync();

  if (password == null || password.length < 6) {
    print('❌ Password must be at least 6 characters');
    exit(1);
  }

  stdout.write('Enter admin name: ');
  final name = stdin.readLineSync()?.trim();

  if (name == null || name.isEmpty) {
    print('❌ Name is required');
    exit(1);
  }

  try {
    print('\n🔄 Creating admin user...');

    // 1. Create user in Firebase Authentication
    final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final firebase_auth.UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebase_auth.User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Failed to create user in Firebase Authentication');
    }

    // 2. Create admin user document in Firestore
    final adminUserData = {
      'email': email,
      'name': name,
      'photoUrl': null,
      'roles': ['admin'],
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'profile': {
        'phone': null,
        'address': null,
        'company': 'WanderWise Admin',
        'position': 'Administrator',
      },
    };

    await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(adminUserData);

    print('\n✅ Admin user created successfully!');
    print('📧 Email: $email');
    print('👤 Name: $name');
    print('🆔 UID: ${firebaseUser.uid}');
    print('🔑 Role: Admin');
    print('\n🎉 You can now log into the admin panel with these credentials!');
  } catch (e) {
    print('\n❌ Error creating admin user: $e');
    exit(1);
  }
}
