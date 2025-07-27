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

- **User Authentication**: Email/password authentication via Supabase
- **Destination Discovery**: Explore travel destinations worldwide
- **Itinerary Planning**: Create and manage travel plans
- **Location Services**: Access location-based features
- **Social Features**: Share experiences with other travelers
- **Real-time Updates**: Get live information about destinations

## 🏗️ Architecture

```
lib/
├── main.dart                     # App entry point
├── core/                         # Core functionality
│   ├── config/                   # Configuration (Supabase)
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
- **Supabase**: For backend services

### Key Dependencies
- `supabase_flutter`: Supabase client and authentication
- `provider`: State management
- `geolocator`: Location services
- `cached_network_image`: Image caching
- `shared_preferences`: Local storage

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