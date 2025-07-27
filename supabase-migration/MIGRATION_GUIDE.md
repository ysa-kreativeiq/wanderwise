# Firebase to Supabase Migration Guide

## 🚀 Migration Overview

This guide will help you migrate your WanderWise application from Firebase to Supabase.

## 📋 Prerequisites

- [ ] Supabase CLI installed (`brew install supabase/tap/supabase`)
- [ ] Supabase account created
- [ ] Flutter project with Supabase dependencies

## 🏗️ Step-by-Step Migration

### Phase 1: Supabase Setup

#### 1.1 Create Supabase Project
```bash
# Go to https://supabase.com and create a new project
# Note down your project URL and anon key
```

#### 1.2 Initialize Local Supabase
```bash
cd supabase-migration
supabase init
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

#### 1.3 Apply Database Schema
```bash
supabase db push
```

#### 1.4 Deploy Edge Functions
```bash
supabase functions deploy create-user
supabase functions deploy update-user
supabase functions deploy delete-user
```

### Phase 2: Flutter Dependencies

#### 2.1 Update pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Remove Firebase packages
  # firebase_core: ^x.x.x
  # firebase_auth: ^x.x.x
  # cloud_firestore: ^x.x.x
  # cloud_functions: ^x.x.x
  
  # Add Supabase packages
  supabase_flutter: ^2.3.4
  shared_preferences: ^2.2.2
```

#### 2.2 Install Dependencies
```bash
flutter pub get
```

### Phase 3: Configuration

#### 3.1 Initialize Supabase in main.dart
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(MyApp());
}
```

### Phase 4: Service Migration

#### 4.1 Replace Firebase Services

**Before (Firebase):**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
```

**After (Supabase):**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
}
```

#### 4.2 Authentication Migration

**Before (Firebase):**
```dart
// Sign in
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign out
await FirebaseAuth.instance.signOut();

// Get current user
final user = FirebaseAuth.instance.currentUser;
```

**After (Supabase):**
```dart
// Sign in
await Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: password,
);

// Sign out
await Supabase.instance.client.auth.signOut();

// Get current user
final user = Supabase.instance.client.auth.currentUser;
```

#### 4.3 Database Operations Migration

**Before (Firestore):**
```dart
// Create document
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .set(userData);

// Read document
final doc = await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get();

// Update document
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update(updates);

// Delete document
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .delete();
```

**After (Supabase):**
```dart
// Create record
await Supabase.instance.client
  .from('users')
  .insert(userData);

// Read record
final data = await Supabase.instance.client
  .from('users')
  .select()
  .eq('id', userId)
  .single();

// Update record
await Supabase.instance.client
  .from('users')
  .update(updates)
  .eq('id', userId);

// Delete record
await Supabase.instance.client
  .from('users')
  .delete()
  .eq('id', userId);
```

#### 4.4 Functions Migration

**Before (Firebase Functions):**
```dart
final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
final result = await functions.httpsCallable('createUser').call(data);
```

**After (Supabase Edge Functions):**
```dart
final response = await Supabase.instance.client.functions.invoke(
  'create-user',
  body: data,
);
```

### Phase 5: Data Migration

#### 5.1 Export Firebase Data
```bash
# Use Firebase Admin SDK to export data
# Or use Firebase Console to export collections
```

#### 5.2 Transform Data
```javascript
// Transform Firestore data to PostgreSQL format
// Convert timestamps, handle nested objects, etc.
```

#### 5.3 Import to Supabase
```bash
# Use Supabase CLI or dashboard to import data
supabase db reset
# Then import your transformed data
```

### Phase 6: Testing

#### 6.1 Test Authentication
- [ ] User registration
- [ ] User login/logout
- [ ] Password reset
- [ ] Email verification

#### 6.2 Test Database Operations
- [ ] CRUD operations on all tables
- [ ] Real-time subscriptions
- [ ] Row Level Security (RLS)

#### 6.3 Test Edge Functions
- [ ] User creation
- [ ] User updates
- [ ] User deletion
- [ ] Error handling

## 🔧 Common Issues & Solutions

### Issue 1: Authentication Context
**Problem:** Edge functions not receiving auth context
**Solution:** Ensure proper Authorization header is sent

### Issue 2: RLS Policies
**Problem:** Users can't access their own data
**Solution:** Check RLS policies and user roles

### Issue 3: Data Types
**Problem:** Type mismatches between Firestore and PostgreSQL
**Solution:** Transform data types during migration

## 📊 Migration Checklist

### Setup
- [ ] Supabase project created
- [ ] Database schema applied
- [ ] Edge functions deployed
- [ ] Flutter dependencies updated

### Authentication
- [ ] Supabase initialized in app
- [ ] Login/logout working
- [ ] User registration working
- [ ] Password reset working

### Database
- [ ] All CRUD operations working
- [ ] Real-time subscriptions working
- [ ] RLS policies configured
- [ ] Data migrated successfully

### Functions
- [ ] Edge functions deployed
- [ ] Function calls working
- [ ] Error handling implemented
- [ ] Admin functions working

### Testing
- [ ] Mobile app tested
- [ ] Admin web app tested
- [ ] All features working
- [ ] Performance acceptable

## 🎯 Benefits After Migration

### ✅ Advantages
- **Better SQL support** - Complex queries, joins, aggregations
- **Real-time subscriptions** - Built-in, no additional setup
- **Row Level Security** - More granular than Firestore rules
- **Open source** - No vendor lock-in
- **Better pricing** - Often more cost-effective

### ⚠️ Considerations
- **Learning curve** - New APIs and concepts
- **Migration effort** - Significant time investment
- **Team training** - Need to learn Supabase

## 📞 Support

If you encounter issues during migration:
1. Check Supabase documentation
2. Review error logs
3. Test with simple examples first
4. Consider incremental migration

## 🚀 Next Steps

After successful migration:
1. Monitor performance
2. Optimize queries
3. Set up monitoring
4. Plan feature enhancements 