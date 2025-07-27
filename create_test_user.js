const { createClient } = require('@supabase/supabase-js');

// Replace with your actual Supabase URL and anon key
const supabaseUrl = 'https://tmucyuaffclznrfnmyda.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtdWN5dWFmZmNsem5yZm5teWRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0OTM3MDcsImV4cCI6MjA2OTA2OTcwN30.MN74FTi3UGtpRy2W-RPJK6V7ZUrS5DlxOiqdO7QGdO0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function createTestUser() {
  try {
    console.log('Creating test travel agent user...');
    
    // First, sign in as anon user to get a session
    const { data: { session }, error: signInError } = await supabase.auth.signInAnonymously();
    
    if (signInError) {
      console.error('Error signing in anonymously:', signInError);
      return;
    }

    console.log('Signed in anonymously, calling create-user function...');

    // Call the create-user Edge Function to create a travel agent
    const { data, error } = await supabase.functions.invoke('create-user', {
      body: {
        email: 'travelagent@test.com',
        password: 'Test123!',
        name: 'Test Travel Agent',
        roles: ['travelAgent'],
        photoUrl: null
      }
    });

    if (error) {
      console.error('Error creating travel agent user:', error);
      return;
    }

    console.log('✅ Travel agent user created successfully!');
    console.log('User ID:', data.userId);
    console.log('Email:', data.email);
    console.log('Roles:', data.roles);

    // Now create an editor user
    console.log('\nCreating test editor user...');
    const { data: editorData, error: editorError } = await supabase.functions.invoke('create-user', {
      body: {
        email: 'editor@test.com',
        password: 'Test123!',
        name: 'Test Editor',
        roles: ['editor'],
        photoUrl: null
      }
    });

    if (editorError) {
      console.error('Error creating editor user:', editorError);
    } else {
      console.log('✅ Editor user created successfully!');
      console.log('User ID:', editorData.userId);
      console.log('Email:', editorData.email);
      console.log('Roles:', editorData.roles);
    }

    // Now create a content editor user
    console.log('\nCreating test content editor user...');
    const { data: contentEditorData, error: contentEditorError } = await supabase.functions.invoke('create-user', {
      body: {
        email: 'contenteditor@test.com',
        password: 'Test123!',
        name: 'Test Content Editor',
        roles: ['contentEditor'],
        photoUrl: null
      }
    });

    if (contentEditorError) {
      console.error('Error creating content editor user:', contentEditorError);
    } else {
      console.log('✅ Content editor user created successfully!');
      console.log('User ID:', contentEditorData.userId);
      console.log('Email:', contentEditorData.email);
      console.log('Roles:', contentEditorData.roles);
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

createTestUser(); 