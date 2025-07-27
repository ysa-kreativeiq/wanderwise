const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and anon key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtdWN5dWFmZmNsem5yZm5teWRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0OTM3MDcsImV4cCI6MjA2OTA2OTcwN30.MN74FTi3UGtpRy2W-RPJK6V7ZUrS5DlxOiqdO7QGdO0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function createAdminUser() {
  try {
    console.log('Creating admin user...');
    
    // First, sign in as anon user to get a session
    const { data: { session }, error: signInError } = await supabase.auth.signInAnonymously();
    
    if (signInError) {
      console.error('Error signing in anonymously:', signInError);
      return;
    }

    console.log('Signed in anonymously, calling create-user function...');

    // Call the create-user Edge Function
    const { data, error } = await supabase.functions.invoke('create-user', {
      body: {
        email: 'admin@wanderwise.com',
        password: 'Admin123!',
        name: 'Admin User',
        roles: ['admin'],
        photoUrl: null
      }
    });

    if (error) {
      console.error('Error creating user:', error);
      return;
    }

    console.log('✅ Admin user created successfully!');
    console.log('User ID:', data.userId);
    console.log('Email:', data.email);
    console.log('Roles:', data.roles);

    // Sign out
    await supabase.auth.signOut();
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

createAdminUser(); 