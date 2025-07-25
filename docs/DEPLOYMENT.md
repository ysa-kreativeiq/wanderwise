# WanderWise Deployment Guide

## Mobile App Deployment

### iOS App Store Deployment

1. **Build iOS App**
   ```bash
   cd mobile-app
   flutter build ios --release
   ```

2. **Open in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Configure App Store Connect**
   - Set bundle identifier
   - Configure signing certificates
   - Set app version and build number

4. **Archive and Upload**
   - Product → Archive
   - Distribute App
   - Upload to App Store Connect

### Android Google Play Deployment

1. **Build Android App**
   ```bash
   cd mobile-app
   flutter build appbundle --release
   ```

2. **Configure Google Play Console**
   - Create app listing
   - Set app version
   - Configure signing

3. **Upload to Google Play**
   - Upload AAB file
   - Complete store listing
   - Submit for review

## Admin Web Deployment

### Vercel Deployment (Recommended)

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Build Admin Web**
   ```bash
   cd admin-web
   flutter build web --release
   ```

3. **Deploy to Vercel**
   ```bash
   cd build/web
   vercel --prod
   ```

### Netlify Deployment

1. **Build Admin Web**
   ```bash
   cd admin-web
   flutter build web --release
   ```

2. **Deploy to Netlify**
   ```bash
   cd build/web
   netlify deploy --prod --dir=.
   ```

### Firebase Hosting

1. **Build Admin Web**
   ```bash
   cd admin-web
   flutter build web --release
   ```

2. **Deploy to Firebase**
   ```bash
   cd ../firebase
   firebase deploy --only hosting
   ```

## CI/CD Pipeline

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy WanderWise

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-mobile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: cd mobile-app && flutter test

  test-admin:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: cd admin-web && flutter test

  deploy-admin:
    needs: test-admin
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: cd admin-web && flutter build web --release
      - uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          working-directory: ./admin-web/build/web
```

## Environment Configuration

### Mobile App Environment

Create `mobile-app/.env`:
```
FIREBASE_PROJECT_ID=wanderwise-app
GOOGLE_MAPS_API_KEY=your_maps_api_key
```

### Admin Web Environment

Create `admin-web/.env`:
```
FIREBASE_PROJECT_ID=wanderwise-app
ADMIN_DOMAIN=admin.wanderwise.com
```

## Security Considerations

### Mobile App
- API keys in secure storage
- Certificate pinning
- Code obfuscation
- ProGuard/R8 configuration

### Admin Web
- HTTPS enforcement
- CORS configuration
- Rate limiting
- Authentication middleware

## Monitoring and Analytics

### Mobile App
- Firebase Analytics
- Crashlytics
- Performance monitoring

### Admin Web
- Google Analytics
- Error tracking
- Performance monitoring
- User behavior analytics 