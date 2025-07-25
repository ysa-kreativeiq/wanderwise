# Contributing to WanderWise

Thank you for your interest in contributing to WanderWise! This document provides guidelines for contributing to our monorepo project.

## 🏗️ Project Structure

```
WanderWise/
├── mobile-app/                    # Mobile Frontend (iOS/Android)
├── admin-web/                     # Web Backend (Admin Panel)
├── shared/                        # Shared Code & Assets
├── docs/                          # Documentation
└── firebase/                      # Firebase Configuration
```

## 👥 Team Structure

### Mobile Team
- **Focus**: `mobile-app/` directory
- **Responsibilities**: iOS/Android app development
- **Technologies**: Flutter, Dart, Firebase

### Admin Team
- **Focus**: `admin-web/` directory
- **Responsibilities**: Web admin panel development
- **Technologies**: Flutter Web, Dart, Firebase

### Shared Team
- **Focus**: `shared/` directory
- **Responsibilities**: Common models, services, utilities
- **Technologies**: Dart, Firebase

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.0.0 or higher
- Git

### Setup
1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/WanderWise.git
   cd WanderWise
   ```

3. **Install dependencies**:
   ```bash
   # For mobile development
   cd mobile-app && flutter pub get
   
   # For admin web development
   cd admin-web && flutter pub get
   
   # For shared package development
   cd shared && flutter pub get
   ```

## 📝 Development Workflow

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/feature-name` - Feature development
- `hotfix/hotfix-name` - Critical bug fixes

### Commit Convention
We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(mobile): add user authentication screen
fix(admin): resolve login form validation issue
docs(shared): update API documentation
```

### Pull Request Process
1. **Create a feature branch** from `develop`
2. **Make your changes** in the appropriate directory
3. **Write tests** for new functionality
4. **Update documentation** if needed
5. **Submit a pull request** to `develop`
6. **Request review** from appropriate team members

## 🧪 Testing

### Mobile App Testing
```bash
cd mobile-app
flutter test
flutter analyze
```

### Admin Web Testing
```bash
cd admin-web
flutter test
flutter analyze
```

### Shared Package Testing
```bash
cd shared
flutter test
flutter analyze
```

## 📦 Dependencies

### Adding Dependencies
- **Mobile-specific**: Add to `mobile-app/pubspec.yaml`
- **Web-specific**: Add to `admin-web/pubspec.yaml`
- **Shared**: Add to `shared/pubspec.yaml`

### Version Management
- Use semantic versioning
- Keep dependencies up to date
- Document breaking changes

## 🔧 Development Guidelines

### Code Style
- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### File Organization
- Group related files together
- Use consistent naming conventions
- Separate concerns (UI, business logic, data)

### Error Handling
- Use proper exception handling
- Log errors appropriately
- Provide user-friendly error messages

## 🚀 Deployment

### Mobile App
- **Android**: Google Play Console
- **iOS**: App Store Connect
- **CI/CD**: Automated via GitHub Actions

### Admin Web
- **Hosting**: Vercel/Netlify
- **Domain**: admin.wanderwise.com
- **CI/CD**: Automated via GitHub Actions

## 🐛 Bug Reports

When reporting bugs, please include:
- **Description** of the issue
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Environment** (OS, Flutter version, device)
- **Screenshots** if applicable

## 💡 Feature Requests

When requesting features, please include:
- **Description** of the feature
- **Use case** and benefits
- **Mockups** or wireframes if applicable
- **Priority** level

## 📞 Support

- **Issues**: Use GitHub Issues
- **Discussions**: Use GitHub Discussions
- **Email**: support@wanderwise.com

## 📄 License

By contributing to WanderWise, you agree that your contributions will be licensed under the MIT License. 