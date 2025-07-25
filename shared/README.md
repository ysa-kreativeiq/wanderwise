# WanderWise Shared Package

Shared code, models, and services for WanderWise mobile and admin applications.

## 📦 Overview

This package contains common code that is shared between the mobile app and admin web interface, including:
- Data models (User, Destination, Itinerary)
- Firebase service layer
- Common utilities and helpers
- Shared constants and configurations

## 🚀 Quick Start

### Installation
```bash
cd shared
flutter pub get
```

### Usage in Mobile App
```yaml
# mobile-app/pubspec.yaml
dependencies:
  wanderwise_shared:
    path: ../shared
```

### Usage in Admin Web
```yaml
# admin-web/pubspec.yaml
dependencies:
  wanderwise_shared:
    path: ../shared
```

## 🏗️ Architecture

```
lib/
├── models/                       # Data models
│   ├── user_model.dart          # User data model
│   ├── destination_model.dart   # Destination data model
│   └── itinerary_model.dart     # Itinerary data model
├── services/                     # Service layer
│   ├── firebase_service.dart    # Firebase operations
│   └── preferences_service.dart # Local storage
├── utils/                        # Utilities
│   ├── constants.dart           # App constants
│   ├── helpers.dart             # Helper functions
│   └── validators.dart          # Input validation
└── assets/                       # Shared assets
    ├── images/                  # Common images
    └── icons/                   # Common icons
```

## 📋 Data Models

### User Model
```dart
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> roles;
  // ... more fields
}
```

### Destination Model
```dart
class Destination {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> categories;
  final Map<String, dynamic> location;
  final List<String> attractions;
  final Map<String, dynamic> weather;
  final double estimatedCost;
  final String currency;
  final String bestTimeToVisit;
  final List<String> languages;
  // ... more fields
}
```

### Itinerary Model
```dart
class Itinerary {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> destinationIds;
  final List<ItineraryDay> days;
  final ItineraryStatus status;
  // ... more fields
}
```

## 🔧 Services

### Firebase Service
```dart
class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Authentication methods
  static Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  static Future<void> signOut();
  
  // Firestore methods
  static Future<void> createUser(User user);
  static Future<User?> getUser(String userId);
  static Stream<List<Destination>> getDestinations();
  // ... more methods
}
```

### Preferences Service
```dart
class PreferencesService {
  static SharedPreferences? _prefs;
  
  // Local storage methods
  static Future<String?> getString(String key);
  static Future<bool> setString(String key, String value);
  static Future<bool> remove(String key);
  // ... more methods
}
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/user_model_test.dart
```

### Test Structure
```
test/
├── models/                       # Model tests
│   ├── user_model_test.dart
│   ├── destination_model_test.dart
│   └── itinerary_model_test.dart
├── services/                     # Service tests
│   ├── firebase_service_test.dart
│   └── preferences_service_test.dart
└── utils/                        # Utility tests
    ├── helpers_test.dart
    └── validators_test.dart
```

## 📦 Publishing

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update version in `pubspec.yaml`
- Document breaking changes

### Publishing to pub.dev
```bash
# Dry run
flutter pub publish --dry-run

# Publish
flutter pub publish
```

## 🔄 Development Workflow

### Making Changes
1. **Create feature branch** from `develop`
2. **Make changes** in shared package
3. **Update tests** for new functionality
4. **Test in both apps** (mobile and admin)
5. **Submit pull request** to `develop`

### Breaking Changes
- **Increment major version** for breaking changes
- **Update documentation** for API changes
- **Notify teams** about breaking changes
- **Provide migration guide** if needed

## 📚 API Documentation

### Models
- [User Model](lib/models/user_model.dart)
- [Destination Model](lib/models/destination_model.dart)
- [Itinerary Model](lib/models/itinerary_model.dart)

### Services
- [Firebase Service](lib/services/firebase_service.dart)
- [Preferences Service](lib/services/preferences_service.dart)

### Utilities
- [Constants](lib/utils/constants.dart)
- [Helpers](lib/utils/helpers.dart)
- [Validators](lib/utils/validators.dart)

## 🔗 Dependencies

### Core Dependencies
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `json_annotation`: JSON serialization

### Dev Dependencies
- `build_runner`: Code generation
- `json_serializable`: JSON serialization
- `flutter_test`: Testing framework
- `flutter_lints`: Code analysis

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/WanderWise/issues)
- **Documentation**: [Project Wiki](https://github.com/your-org/WanderWise/wiki)
- **Email**: shared@wanderwise.com 