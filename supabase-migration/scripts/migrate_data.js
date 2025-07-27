const admin = require('firebase-admin');
const { createClient } = require('@supabase/supabase-js');

// Initialize Firebase Admin
const serviceAccount = require('./firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Initialize Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function migrateUsers() {
  console.log('🔄 Migrating users...');
  
  try {
    // Get all users from Firebase Auth
    const listUsersResult = await admin.auth().listUsers();
    const firebaseUsers = listUsersResult.users;
    
    console.log(`Found ${firebaseUsers.length} users in Firebase Auth`);
    
    for (const firebaseUser of firebaseUsers) {
      try {
        // Get user data from Firestore
        const userDoc = await admin.firestore()
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
        
        let userData = {};
        if (userDoc.exists) {
          userData = userDoc.data();
        }
        
        // Transform user data for Supabase
        const supabaseUser = {
          id: firebaseUser.uid,
          email: firebaseUser.email,
          name: userData.name || firebaseUser.displayName || 'Unknown',
          photo_url: userData.photoUrl || firebaseUser.photoURL,
          roles: userData.roles || ['traveler'],
          is_active: userData.isActive !== false,
          created_at: firebaseUser.metadata.creationTime,
          last_login_at: firebaseUser.metadata.lastSignInTime || firebaseUser.metadata.creationTime,
          profile: userData.profile || {},
          assigned_travelers: userData.assignedTravelers || [],
          travel_agent_id: userData.travelAgentId,
        };
        
        // Insert user into Supabase
        const { error } = await supabase
          .from('users')
          .upsert(supabaseUser, { onConflict: 'id' });
        
        if (error) {
          console.error(`❌ Error migrating user ${firebaseUser.email}:`, error);
        } else {
          console.log(`✅ Migrated user: ${firebaseUser.email}`);
        }
        
      } catch (error) {
        console.error(`❌ Error processing user ${firebaseUser.email}:`, error);
      }
    }
    
    console.log('✅ User migration completed');
    
  } catch (error) {
    console.error('❌ Error in user migration:', error);
  }
}

async function migrateDestinations() {
  console.log('🔄 Migrating destinations...');
  
  try {
    const destinationsSnapshot = await admin.firestore()
      .collection('destinations')
      .get();
    
    console.log(`Found ${destinationsSnapshot.size} destinations`);
    
    for (const doc of destinationsSnapshot.docs) {
      try {
        const firebaseData = doc.data();
        
        // Transform destination data for Supabase
        const supabaseDestination = {
          id: doc.id,
          name: firebaseData.name,
          description: firebaseData.description,
          image_url: firebaseData.imageUrl,
          location: firebaseData.location,
          price_range: firebaseData.priceRange,
          rating: firebaseData.rating,
          tags: firebaseData.tags || [],
          is_featured: firebaseData.isFeatured || false,
          is_active: firebaseData.isActive !== false,
          created_at: firebaseData.createdAt?.toDate?.() || new Date(),
          updated_at: firebaseData.updatedAt?.toDate?.() || new Date(),
        };
        
        // Insert destination into Supabase
        const { error } = await supabase
          .from('destinations')
          .upsert(supabaseDestination, { onConflict: 'id' });
        
        if (error) {
          console.error(`❌ Error migrating destination ${firebaseData.name}:`, error);
        } else {
          console.log(`✅ Migrated destination: ${firebaseData.name}`);
        }
        
      } catch (error) {
        console.error(`❌ Error processing destination ${doc.id}:`, error);
      }
    }
    
    console.log('✅ Destination migration completed');
    
  } catch (error) {
    console.error('❌ Error in destination migration:', error);
  }
}

async function migrateItineraries() {
  console.log('🔄 Migrating itineraries...');
  
  try {
    const itinerariesSnapshot = await admin.firestore()
      .collection('itineraries')
      .get();
    
    console.log(`Found ${itinerariesSnapshot.size} itineraries`);
    
    for (const doc of itinerariesSnapshot.docs) {
      try {
        const firebaseData = doc.data();
        
        // Transform itinerary data for Supabase
        const supabaseItinerary = {
          id: doc.id,
          user_id: firebaseData.userId,
          title: firebaseData.title,
          description: firebaseData.description,
          start_date: firebaseData.startDate,
          end_date: firebaseData.endDate,
          status: firebaseData.status || 'draft',
          is_public: firebaseData.isPublic || false,
          created_at: firebaseData.createdAt?.toDate?.() || new Date(),
          updated_at: firebaseData.updatedAt?.toDate?.() || new Date(),
        };
        
        // Insert itinerary into Supabase
        const { error } = await supabase
          .from('itineraries')
          .upsert(supabaseItinerary, { onConflict: 'id' });
        
        if (error) {
          console.error(`❌ Error migrating itinerary ${firebaseData.title}:`, error);
        } else {
          console.log(`✅ Migrated itinerary: ${firebaseData.title}`);
          
          // Migrate itinerary destinations if they exist
          if (firebaseData.destinations) {
            for (let i = 0; i < firebaseData.destinations.length; i++) {
              const destination = firebaseData.destinations[i];
              
              const itineraryDestination = {
                itinerary_id: doc.id,
                destination_id: destination.id,
                day_number: destination.dayNumber || i + 1,
                order_index: i,
                notes: destination.notes,
                created_at: new Date(),
              };
              
              const { error: destError } = await supabase
                .from('itinerary_destinations')
                .insert(itineraryDestination);
              
              if (destError) {
                console.error(`❌ Error migrating itinerary destination:`, destError);
              }
            }
          }
        }
        
      } catch (error) {
        console.error(`❌ Error processing itinerary ${doc.id}:`, error);
      }
    }
    
    console.log('✅ Itinerary migration completed');
    
  } catch (error) {
    console.error('❌ Error in itinerary migration:', error);
  }
}

async function main() {
  console.log('🚀 Starting Firebase to Supabase migration...');
  
  // Check environment variables
  if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
    console.error('❌ Missing required environment variables:');
    console.error('   - SUPABASE_URL');
    console.error('   - SUPABASE_SERVICE_ROLE_KEY');
    process.exit(1);
  }
  
  try {
    await migrateUsers();
    await migrateDestinations();
    await migrateItineraries();
    
    console.log('🎉 Migration completed successfully!');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

// Run migration
main(); 