const { createClient } = require('@supabase/supabase-js');

// You'll need to get the service role key from your Supabase dashboard
// Go to Settings → API → service_role key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const serviceRoleKey = 'YOUR_SERVICE_ROLE_KEY'; // Replace with your service role key

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function createAdminUser() {
  try {
    console.log('Creating admin user with service role...');
    
    // Create user in Auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: 'admin@wanderwise.com',
      password: 'Admin123!',
      email_confirm: true,
      user_metadata: {
        name: 'Admin User',
        roles: ['admin']
      }
    });

    if (authError) {
      console.error('Error creating auth user:', authError);
      return;
    }

    console.log('✅ Auth user created:', authData.user.id);

    // Create user record in database
    const { data: dbData, error: dbError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email: 'admin@wanderwise.com',
        name: 'Admin User',
        roles: ['admin'], // This should be a text array
        is_active: true,
        profile: {},
        assigned_travelers: [],
        travel_agent_id: null
      })
      .select()
      .single();

    if (dbError) {
      console.error('Error creating database user:', dbError);
      return;
    }

    console.log('✅ Database user created successfully!');
    console.log('User ID:', dbData.id);
    console.log('Email:', dbData.email);
    console.log('Roles:', dbData.roles);
    console.log('\n🎉 Admin user created successfully!');
    console.log('You can now login with:');
    console.log('Email: admin@wanderwise.com');
    console.log('Password: Admin123!');
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

createAdminUser(); 