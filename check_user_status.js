const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and anon key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtdWN5dWFmZmNsem5yZm5teWRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0OTM3MDcsImV4cCI6MjA2OTA2OTcwN30.MN74FTi3UGtpRy2W-RPJK6V7ZUrS5DlxOiqdO7QGdO0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkUserStatus(email) {
  try {
    console.log(`Checking status for: ${email}`);
    
    // First, let's check if the user exists in the database
    const { data: dbUser, error: dbError } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (dbError) {
      console.log('❌ User not found in database:', dbError.message);
    } else {
      console.log('✅ User found in database:');
      console.log('  - ID:', dbUser.id);
      console.log('  - Name:', dbUser.name);
      console.log('  - Roles:', dbUser.roles);
      console.log('  - Is Active:', dbUser.is_active);
      console.log('  - Created At:', dbUser.created_at);
    }

    // Now let's try to sign in with a test password to see if the user exists in auth
    console.log('\nTesting authentication...');
    
    const testPasswords = ['Admin123!', 'Password123!', 'Test123!', 'password', 'admin'];
    
    for (const password of testPasswords) {
      try {
        const { data, error } = await supabase.auth.signInWithPassword({
          email: email,
          password: password
        });

        if (!error) {
          console.log(`✅ Authentication successful with password: ${password}`);
          console.log('  - User ID:', data.user.id);
          console.log('  - Email Confirmed:', data.user.email_confirmed_at);
          console.log('  - User Metadata:', data.user.user_metadata);
          
          // Sign out
          await supabase.auth.signOut();
          return;
        } else {
          console.log(`❌ Failed with password "${password}": ${error.message}`);
        }
      } catch (e) {
        console.log(`❌ Error with password "${password}": ${e.message}`);
      }
    }
    
    console.log('\n❌ Could not authenticate with any test password');
    console.log('The user might not exist in Supabase Auth or the password is different');
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

// Check the user that's having issues
checkUserStatus('claude.villeneuve@espacevoyages.ca'); 