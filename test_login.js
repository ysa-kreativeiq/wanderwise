const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and anon key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtdWN5dWFmZmNsem5yZm5teWRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0OTM3MDcsImV4cCI6MjA2OTA2OTcwN30.MN74FTi3UGtpRy2W-RPJK6V7ZUrS5DlxOiqdO7QGdO0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testLogin(email, password) {
  try {
    console.log(`Testing login for: ${email}`);
    
    // Try to sign in
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email,
      password: password
    });

    if (error) {
      console.log('❌ Sign in failed:', error.message);
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
      
      // Check if user has admin access
      const hasAdmin = dbUser.roles.includes('admin');
      const hasTravelAgent = dbUser.roles.includes('travelAgent');
      const hasEditor = dbUser.roles.includes('editor');
      const hasContentEditor = dbUser.roles.includes('contentEditor');
      
      console.log('Role checks:');
      console.log('  - admin:', hasAdmin);
      console.log('  - travelAgent:', hasTravelAgent);
      console.log('  - editor:', hasEditor);
      console.log('  - contentEditor:', hasContentEditor);
      
      const hasAccess = hasAdmin || hasTravelAgent || hasEditor || hasContentEditor;
      console.log('Has admin access:', hasAccess);
    }

    // Sign out
    await supabase.auth.signOut();
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

// Test with the user that's having issues
// You'll need to provide the correct password
testLogin('claude.villeneuve@espacevoyages.ca', 'YOUR_PASSWORD_HERE'); 