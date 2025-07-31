const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and anon key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const supabaseAnonKey = 'your-anon-key-here'; // You'll need to get this from your Supabase dashboard

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function testCreateTraveler() {
  try {
    console.log('Testing create-traveler function...');
    
    // First, sign in as a user to get an auth token
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: 'ysalembier@kreativeiq.com', // Use your admin email
      password: 'your-password-here' // You'll need to provide this
    });

    if (authError) {
      console.error('Auth error:', authError);
      return;
    }

    console.log('Authenticated as:', authData.user.email);

    // Call the create-traveler function
    const { data, error } = await supabase.functions.invoke('create-traveler', {
      body: {
        email: 'test-traveler@example.com',
        password: 'testpassword123',
        name: 'Test Traveler',
        phone: '+1234567890',
        notes: 'Test traveler created for debugging',
        isActive: true
      }
    });

    if (error) {
      console.error('Function error:', error);
      console.error('Error details:', error.message);
      console.error('Error status:', error.status);
      console.error('Error details:', error.details);
    } else {
      console.log('Success:', data);
    }

  } catch (err) {
    console.error('Unexpected error:', err);
  }
}

testCreateTraveler(); 