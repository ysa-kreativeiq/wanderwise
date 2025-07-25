# WanderWise Architecture

## Project Structure

```
WanderWise/
├── mobile-app/                    # Mobile Frontend (iOS/Android)
├── admin-web/                     # Web Backend (Admin Panel)
├── shared/                        # Shared Code & Assets
├── firebase/                      # Firebase Configuration
└── docs/                          # Documentation
```

## Mobile App (`mobile-app/`)

### Purpose
- Travel planning and exploration app
- Offline-first experience
- Location-based features
- Social features

### Key Features
- User authentication
- Destination discovery
- Itinerary planning
- Offline maps
- Push notifications

### Dependencies
- `google_maps_flutter` - Maps integration
- `geolocator` - Location services
- `google_sign_in` - Social authentication
- `cached_network_image` - Image caching

## Admin Web (`admin-web/`)

### Purpose
- Administrative interface
- Data management
- Analytics dashboard
- User management

### Key Features
- User management
- Destination management
- Analytics and reporting
- Content moderation
- System configuration

### Dependencies
- `fl_chart` - Data visualization
- `data_table_2` - Data tables
- `firebase_analytics` - Analytics
- `url_launcher` - External links

## Shared Package (`shared/`)

### Purpose
- Common business logic
- Shared data models
- Firebase services
- Utility functions

### Components
- Data models (User, Destination, Itinerary)
- Firebase service layer
- Common utilities
- Shared constants

## Firebase Configuration (`firebase/`)

### Purpose
- Centralized Firebase configuration
- Cloud Functions (future)
- Deployment configuration

## Development Workflow

### Mobile Development
```bash
cd mobile-app
flutter pub get
flutter run
```

### Admin Development
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

## Deployment Strategy

### Mobile App
- **iOS**: App Store Connect
- **Android**: Google Play Console
- **CI/CD**: GitHub Actions

### Admin Web
- **Hosting**: Vercel/Netlify
- **Domain**: admin.wanderwise.com
- **CI/CD**: GitHub Actions

### Shared Package
- **Registry**: pub.dev (if public) or private registry
- **Versioning**: Semantic versioning

## Team Structure

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