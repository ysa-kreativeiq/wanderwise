const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and anon key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtdWN5dWFmZmNsem5yZm5teWRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0OTM3MDcsImV4cCI6MjA2OTA2OTcwN30.MN74FTi3UGtpRy2W-RPJK6V7ZUrS5DlxOiqdO7QGdO0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function createTestUsers() {
  try {
    console.log('Creating test users...');
    
    // First, let's try to sign in with an existing admin user
    // You'll need to provide the correct admin credentials
    const adminEmail = 'admin@wanderwise.com'; // Replace with your admin email
    const adminPassword = 'Admin123!'; // Replace with your admin password
    
    console.log(`Signing in as admin: ${adminEmail}`);
    
    const { data: adminData, error: adminError } = await supabase.auth.signInWithPassword({
      email: adminEmail,
      password: adminPassword
    });

    if (adminError) {
      console.error('❌ Admin sign in failed:', adminError.message);
      console.log('\nPlease provide correct admin credentials or create an admin user first.');
      console.log('You can run: node create_admin_user.js to create an admin user.');
      return;
    }

    console.log('✅ Admin sign in successful!');
    console.log('Admin user ID:', adminData.user.id);

    // Now create test users using the create-user function
    const testUsers = [
      {
        email: 'travelagent@test.com',
        password: 'Test123!',
        name: 'Test Travel Agent',
        roles: ['travelAgent']
      },
      {
        email: 'editor@test.com',
        password: 'Test123!',
        name: 'Test Editor',
        roles: ['editor']
      },
      {
        email: 'contenteditor@test.com',
        password: 'Test123!',
        name: 'Test Content Editor',
        roles: ['contentEditor']
      }
    ];

    for (const user of testUsers) {
      console.log(`\nCreating ${user.name}...`);
      
      const { data, error } = await supabase.functions.invoke('create-user', {
        body: user
      });

      if (error) {
        console.error(`❌ Error creating ${user.name}:`, error.message);
      } else {
        console.log(`✅ ${user.name} created successfully!`);
        console.log('User ID:', data.userId);
        console.log('Email:', data.email);
        console.log('Roles:', data.roles);
      }
    }

    // Sign out
    await supabase.auth.signOut();
    
    console.log('\n🎉 Test users created! You can now test login with:');
    console.log('Travel Agent: travelagent@test.com / Test123!');
    console.log('Editor: editor@test.com / Test123!');
    console.log('Content Editor: contenteditor@test.com / Test123!');
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

createTestUsers(); 