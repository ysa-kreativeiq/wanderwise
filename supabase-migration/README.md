# WanderWise Firebase to Supabase Migration

This project contains the migration setup and scripts to move WanderWise from Firebase to Supabase.

## 📁 Project Structure

```
supabase-migration/
├── supabase/
│   ├── migrations/
│   │   └── 001_initial_schema.sql    # Database schema
│   └── functions/
│       ├── create-user/
│       │   └── index.ts              # Create user Edge Function
│       ├── update-user/
│       │   └── index.ts              # Update user Edge Function
│       └── delete-user/
│           └── index.ts              # Delete user Edge Function
├── lib/
│   ├── core/
│   │   ├── models/
│   │   │   └── user_model.dart       # User model for Supabase
│   │   └── services/
│   │       └── supabase_service.dart # Supabase service
├── scripts/
│   ├── migrate_data.js               # Data migration script
│   └── package.json                  # Migration dependencies
├── MIGRATION_GUIDE.md               # Detailed migration guide
└── README.md                        # This file
```

## 🚀 Quick Start

### 1. Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/cli) installed
- [Node.js](https://nodejs.org/) (for migration scripts)
- [Flutter](https://flutter.dev/) (for app development)

### 2. Setup Supabase Project

```bash
# Create a new Supabase project at https://supabase.com
# Note down your project URL and anon key

# Initialize local Supabase
supabase init
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

### 3. Apply Database Schema

```bash
# Apply the initial schema
supabase db push
```

### 4. Deploy Edge Functions

```bash
# Deploy all Edge Functions
supabase functions deploy create-user
supabase functions deploy update-user
supabase functions deploy delete-user
```

### 5. Run Data Migration

```bash
# Install migration dependencies
cd scripts
npm install

# Set environment variables
export SUPABASE_URL="your-supabase-url"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"

# Run migration
npm run migrate
```

## 📊 Database Schema

### Tables

- **users** - User accounts and profiles
- **destinations** - Travel destinations
- **itineraries** - User travel itineraries
- **itinerary_destinations** - Junction table for itinerary-destination relationships

### Key Features

- **Row Level Security (RLS)** - Granular access control
- **UUID primary keys** - Secure and scalable
- **JSONB fields** - Flexible data storage
- **Automatic timestamps** - Created/updated tracking

## 🔧 Edge Functions

### create-user
Creates new users in both Supabase Auth and the database.

### update-user
Updates user information (admin only).

### delete-user
Deletes users from both Auth and database (admin only).

## 📱 Flutter Integration

### Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.3.4
  shared_preferences: ^2.2.2
```

### Initialize Supabase

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

### Use Supabase Service

```dart
import 'package:your_app/core/services/supabase_service.dart';

// Create user
final result = await SupabaseService.createUser(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
  roles: [UserRole.traveler],
);

// Get all users
final users = await SupabaseService.getAllUsers();
```

## 🔐 Authentication

### User Roles

- **admin** - Full system access
- **travelAgent** - Can manage assigned travelers
- **traveler** - Basic user access

### Row Level Security Policies

- Users can view their own profile
- Admins can manage all users
- Destinations are publicly readable
- Users can manage their own itineraries

## 📈 Migration Benefits

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

## 🧪 Testing

### Test Authentication
```bash
# Test user creation
curl -X POST https://your-project.supabase.co/functions/v1/create-user \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password","name":"Test User","roles":["traveler"]}'
```

### Test Database Operations
```bash
# Test user retrieval
curl -X GET https://your-project.supabase.co/rest/v1/users \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

## 📞 Support

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)
- [Migration Guide](./MIGRATION_GUIDE.md)

## 🚀 Next Steps

1. **Complete the migration** following the [Migration Guide](./MIGRATION_GUIDE.md)
2. **Test thoroughly** - All features should work as expected
3. **Monitor performance** - Ensure good response times
4. **Optimize queries** - Use Supabase's query optimization features
5. **Set up monitoring** - Monitor usage and performance

## 📄 License

MIT License - see LICENSE file for details. 