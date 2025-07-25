# WanderWise Mobile App

The mobile frontend for WanderWise - a comprehensive travel planning and exploration app for iOS and Android.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for platform-specific development)

### Installation
```bash
cd mobile-app
flutter pub get
```

### Running the App
```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

## 📱 Features

- **User Authentication**: Email/password and social login
- **Destination Discovery**: Explore travel destinations worldwide
- **Itinerary Planning**: Create and manage travel plans
- **Offline Maps**: Access maps without internet connection
- **Social Features**: Share experiences with other travelers
- **Real-time Updates**: Get live information about destinations

## 🏗️ Architecture

```
lib/
├── main.dart                     # App entry point
├── firebase_options.dart         # Firebase configuration
├── core/                         # Core functionality
│   ├── models/                   # Data models
│   ├── providers/                # State management
│   ├── services/                 # Business logic
│   └── theme/                    # App theming
└── features/                     # Feature modules
    ├── auth/                     # Authentication
    ├── home/                     # Home screen
    ├── explore/                  # Destination exploration
    ├── itinerary/                # Trip planning
    └── profile/                  # User profile
```

## 🔧 Development

### State Management
- **Provider**: For state management
- **Firebase**: For backend services

### Key Dependencies
- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: Database
- `google_maps_flutter`: Maps integration
- `geolocator`: Location services
- `cached_network_image`: Image caching

### Testing
```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Building
```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

## 📦 Platform Configuration

### Android
- **Minimum SDK**: 23
- **Target SDK**: 34
- **Package**: com.example.wanderwise

### iOS
- **Minimum Version**: 14.0
- **Target Version**: 18.0

## 🚀 Deployment

### Android
1. Build app bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Submit for review

### iOS
1. Build iOS app: `flutter build ios --release`
2. Archive in Xcode
3. Upload to App Store Connect

## 🔐 Environment Variables

Create `.env` file:
```
FIREBASE_PROJECT_ID=wanderwise-app
GOOGLE_MAPS_API_KEY=your_maps_api_key
```

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/WanderWise/issues)
- **Documentation**: [Project Wiki](https://github.com/your-org/WanderWise/wiki)
- **Email**: mobile@wanderwise.com 