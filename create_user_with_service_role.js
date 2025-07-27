const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and service role key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
// You'll need to get the service role key from your Supabase dashboard
// Go to Settings > API > service_role key
const serviceRoleKey = 'YOUR_SERVICE_ROLE_KEY'; // Replace this with your actual service role key

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function createUserWithServiceRole() {
  try {
    console.log('Creating test users with service role...');
    
    // Create travel agent user
    const { data: travelAgentData, error: travelAgentError } = await supabase.auth.admin.createUser({
      email: 'travelagent@test.com',
      password: 'Test123!',
      email_confirm: true,
      user_metadata: {
        name: 'Test Travel Agent',
        roles: ['travelAgent']
      }
    });

    if (travelAgentError) {
      console.error('Error creating travel agent:', travelAgentError);
    } else {
      console.log('✅ Travel agent created:', travelAgentData.user.id);
      
      // Insert into users table
      const { error: dbError } = await supabase
        .from('users')
        .insert({
          id: travelAgentData.user.id,
          email: 'travelagent@test.com',
          name: 'Test Travel Agent',
          roles: ['travelAgent'],
          is_active: true,
          profile: {},
          assigned_travelers: [],
          travel_agent_id: null,
        });

      if (dbError) {
        console.error('Error inserting travel agent into database:', dbError);
      } else {
        console.log('✅ Travel agent inserted into database');
      }
    }

    // Create editor user
    const { data: editorData, error: editorError } = await supabase.auth.admin.createUser({
      email: 'editor@test.com',
      password: 'Test123!',
      email_confirm: true,
      user_metadata: {
        name: 'Test Editor',
        roles: ['editor']
      }
    });

    if (editorError) {
      console.error('Error creating editor:', editorError);
    } else {
      console.log('✅ Editor created:', editorData.user.id);
      
      // Insert into users table
      const { error: dbError } = await supabase
        .from('users')
        .insert({
          id: editorData.user.id,
          email: 'editor@test.com',
          name: 'Test Editor',
          roles: ['editor'],
          is_active: true,
          profile: {},
          assigned_travelers: [],
          travel_agent_id: null,
        });

      if (dbError) {
        console.error('Error inserting editor into database:', dbError);
      } else {
        console.log('✅ Editor inserted into database');
      }
    }

    console.log('\n🎉 Test users created! You can now test login with:');
    console.log('Travel Agent: travelagent@test.com / Test123!');
    console.log('Editor: editor@test.com / Test123!');
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

// Check if service role key is set
if (serviceRoleKey === 'YOUR_SERVICE_ROLE_KEY') {
  console.log('❌ Please set your service role key in the script first!');
  console.log('Go to your Supabase dashboard > Settings > API > service_role key');
} else {
  createUserWithServiceRole();
} 