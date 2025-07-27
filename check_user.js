const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and anon key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtdWN5dWFmZmNsem5yZm5teWRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0OTM3MDcsImV4cCI6MjA2OTA2OTcwN30.MN74FTi3UGtpRy2W-RPJK6V7ZUrS5DlxOiqdO7QGdO0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkUser(email) {
  try {
    console.log(`Checking user: ${email}`);
    
    // Try to sign in with the user
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email,
      password: 'Admin123!' // Try with a common password
    });

    if (error) {
      console.log('❌ Sign in failed:', error.message);
      
      // Try to check if user exists in auth
      const { data: userData, error: userError } = await supabase.auth.admin.listUsers();
      if (userError) {
        console.log('❌ Cannot list users (need admin access):', userError.message);
      } else {
        const user = userData.users.find(u => u.email === email);
        if (user) {
          console.log('✅ User exists in auth but password might be wrong');
          console.log('User ID:', user.id);
          console.log('User metadata:', user.user_metadata);
        } else {
          console.log('❌ User does not exist in auth');
        }
      }
      return;
    }

    console.log('✅ Sign in successful!');
    console.log('User ID:', data.user.id);
    console.log('User metadata:', data.user.user_metadata);
    
    // Now try to get user data from the database
    const { data: dbUser, error: dbError } = await supabase
      .from('users')
      .select('*')
      .eq('id', data.user.id)
      .single();

    if (dbError) {
      console.log('❌ Database query failed:', dbError.message);
    } else {
      console.log('✅ User data from database:');
      console.log('Roles:', dbUser.roles);
      console.log('Is Active:', dbUser.is_active);
      console.log('Name:', dbUser.name);
    }

    // Sign out
    await supabase.auth.signOut();
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

// Check the user that's having issues
checkUser('claude.villeneuve@espacevoyages.ca'); 