# WanderWise Admin Web

The web-based administrative interface for WanderWise - manage users, destinations, itineraries, and analytics.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.0.0 or higher
- Modern web browser (Chrome, Firefox, Safari, Edge)

### Installation
```bash
cd admin-web
flutter pub get
```

### Running the App
```bash
# Run in debug mode
flutter run -d chrome

# Run in release mode
flutter run -d chrome --release

# Run on specific port
flutter run -d chrome --web-port 8080
```

## 🌐 Features

- **User Management**: View and manage user accounts
- **Destination Management**: Add, edit, and moderate destinations
- **Analytics Dashboard**: View app usage statistics
- **Content Moderation**: Review and approve user-generated content
- **System Configuration**: Manage app settings and features
- **Real-time Analytics**: Live data visualization

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
    ├── dashboard/                # Admin dashboard
    ├── users/                    # User management
    ├── destinations/             # Destination management
    └── analytics/                # Analytics and reporting
```

## 🔧 Development

### State Management
- **Provider**: For state management
- **Supabase**: For backend services

### Key Dependencies
- `supabase_flutter`: Supabase client and authentication
- `provider`: State management
- `fl_chart`: Data visualization
- `data_table_2`: Data tables
- `url_launcher`: External links
- `file_picker`: File uploads

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
# Build for web
flutter build web --release

# Build with specific base href
flutter build web --release --base-href /admin/
```

## 🌐 Web Configuration

### Browser Support
- **Chrome**: 90+
- **Firefox**: 88+
- **Safari**: 14+
- **Edge**: 90+ 