# WanderWise

A comprehensive travel planning platform with a mobile app for users and a web-based admin panel for management.

## 🏗️ Project Structure

```
WanderWise/
├── mobile-app/                    # Mobile Frontend (iOS/Android)
├── admin-web/                     # Web Backend (Admin Panel)
├── shared/                        # Shared Code & Assets
├── firebase/                      # Firebase Configuration
└── docs/                          # Documentation
```

## 🚀 Quick Start

### Mobile App Development

```bash
cd mobile-app
flutter pub get
flutter run
```

### Admin Web Development

```bash
cd admin-web
flutter pub get
flutter run -d chrome
```

### Shared Package Development

```bash
cd shared
flutter pub get
flutter test
```

## 📱 Mobile App

The WanderWise mobile app provides users with:
- **Destination Discovery**: Explore travel destinations worldwide
- **Itinerary Planning**: Create and manage travel plans
- **Offline Maps**: Access maps without internet connection
- **Social Features**: Share experiences with other travelers
- **Real-time Updates**: Get live information about destinations

### Features
- User authentication (Email/Password, Google Sign-In)
- Location-based destination recommendations
- Offline-first experience
- Push notifications
- Social sharing

### Platforms
- iOS (App Store)
- Android (Google Play)

## 🌐 Admin Web Panel

The admin panel provides administrators with:
- **User Management**: View and manage user accounts
- **Destination Management**: Add, edit, and moderate destinations
- **Analytics Dashboard**: View app usage statistics
- **Content Moderation**: Review and approve user-generated content
- **System Configuration**: Manage app settings and features

### Features
- Real-time analytics
- Data visualization
- Bulk operations
- Export functionality
- Role-based access control

### Deployment
- Vercel (Recommended)
- Netlify
- Firebase Hosting

## 🔧 Technology Stack

### Mobile App
- **Framework**: Flutter
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage

### Admin Web
- **Framework**: Flutter Web
- **State Management**: Provider
- **Charts**: FL Chart
- **Tables**: Data Table 2
- **Authentication**: Firebase Auth
- **Analytics**: Firebase Analytics

### Shared Components
- **Models**: JSON serializable
- **Services**: Firebase services
- **Utilities**: Common functions

## 🚀 Deployment

### Mobile App
- **iOS**: App Store Connect
- **Android**: Google Play Console
- **CI/CD**: GitHub Actions

### Admin Web
- **Hosting**: Vercel/Netlify
- **Domain**: admin.wanderwise.com
- **CI/CD**: GitHub Actions

## 📚 Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [API Documentation](docs/API.md)

## 👥 Team Structure

### Mobile Team
- iOS Developer
- Android Developer
- Mobile UI/UX Designer

### Admin Team
- Web Developer
- Backend Developer
- Data Analyst

### Shared Team
- Backend Developer
- DevOps Engineer
- QA Engineer

## 🔐 Security

- Firebase Authentication
- Role-based access control
- HTTPS enforcement
- API key management
- Data encryption

## 📊 Analytics

- Firebase Analytics
- Crashlytics
- Performance monitoring
- User behavior tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, email support@wanderwise.com or create an issue in the repository. 