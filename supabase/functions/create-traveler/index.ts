import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create a Supabase client with the service role key for admin operations
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get the authenticated user
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    
    if (authError || !user) {
      console.error('Auth error:', authError)
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`Request from user: ${user.id} (${user.email})`)

    // Get request body
    const { email, password, name, phone, notes, isActive, profile } = await req.json()

    // NO ROLE CHECKING - Allow any authenticated user
    console.log(`User ${user.id} is creating traveler (no restrictions)`);

    // Validate input
    if (!email || !password || !name) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: email, password, name' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`=== CREATE-TRAVELER FUNCTION V2 ===`)
    console.log(`Creating traveler: ${email} by user: ${user.id}`)

    // Check if traveler already exists - use a simpler approach
    console.log(`Checking for existing user with email: ${email}`)
    
    let existingUser = null;
    
    try {
      const { data: existingUsers, error: checkError } = await supabaseClient
        .from('users')
        .select('id, email, name, travel_agent_id, roles, is_active, profile')
        .eq('email', email)

      console.log(`Query result - existingUsers:`, existingUsers)
      console.log(`Query result - checkError:`, checkError)

      if (checkError) {
        console.error('Error checking for existing user:', checkError)
        return new Response(
          JSON.stringify({ error: 'Error checking for existing traveler' }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      existingUser = existingUsers && existingUsers.length > 0 ? existingUsers[0] : null

      console.log(`Found ${existingUsers ? existingUsers.length : 0} existing users`)
      if (existingUser) {
        console.log(`Existing user found: ${existingUser.id}, travel_agent_id: ${existingUser.travel_agent_id}`)
        console.log(`Existing user data:`, JSON.stringify(existingUser, null, 2))
      } else {
        console.log(`No existing user found for email: ${email}`)
      }
    } catch (error) {
      console.error('Exception during existing user check:', error)
      return new Response(
        JSON.stringify({ error: 'Error checking for existing traveler' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    if (existingUser) {
      // Traveler already exists
      console.log(`Traveler already exists: ${existingUser.id}`)
      
      // Check if they're already assigned to this travel agent
      if (existingUser.travel_agent_id === user.id) {
        return new Response(
          JSON.stringify({ 
            error: 'Traveler is already assigned to you',
            existingUser: {
              id: existingUser.id,
              email: existingUser.email,
              name: existingUser.name,
              roles: existingUser.roles,
            }
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      // Check if they're assigned to another travel agent
      if (existingUser.travel_agent_id && existingUser.travel_agent_id !== user.id) {
        return new Response(
          JSON.stringify({ 
            error: 'Traveler is already assigned to another travel agent',
            existingUser: {
              id: existingUser.id,
              email: existingUser.email,
              name: existingUser.name,
              roles: existingUser.roles,
            }
          }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      // Traveler exists but not assigned to any agent - assign them to this agent
      console.log(`Assigning existing traveler ${existingUser.id} to agent ${user.id}`)
      
      // Merge existing profile with new profile data
      const existingProfile = existingUser.profile || {}
      const newProfile = profile || {}
      const mergedProfile = {
        ...existingProfile,
        ...newProfile,
        phone: phone || existingProfile.phone || null,
        notes: notes || existingProfile.notes || null,
      }

      const { data: updatedUser, error: updateError } = await supabaseClient
        .from('users')
        .update({
          travel_agent_id: user.id,
          name: name,
          profile: mergedProfile,
          is_active: isActive ?? existingUser.is_active ?? true,
        })
        .eq('id', existingUser.id)
        .select()
        .single()

      console.log(`Update result - updatedUser:`, updatedUser)
      console.log(`Update result - updateError:`, updateError)

      if (updateError) {
        console.error('Error updating existing traveler:', updateError)
        return new Response(
          JSON.stringify({ error: 'Error assigning traveler to you' }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      console.log(`Existing traveler assigned to agent: ${existingUser.id} -> ${user.id}`)

      return new Response(
        JSON.stringify({
          success: true,
          user: {
            id: existingUser.id,
            email: existingUser.email,
            name: existingUser.name,
            roles: existingUser.roles,
          },
          message: 'Existing traveler assigned to you successfully'
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Traveler doesn't exist - create new traveler
    const newUserId = crypto.randomUUID()
    
    // Prepare profile data for new traveler
    const newProfile = {
      phone: phone || null,
      notes: notes || null,
      ...(profile || {}), // Include any additional profile fields
    }

    // Create user record in database
    const { data: userData, error: dbError } = await supabaseClient
      .from('users')
      .insert({
        id: newUserId,
        email: email,
        name: name,
        photo_url: null,
        roles: ['traveler'],
        is_active: isActive ?? true,
        profile: newProfile,
        assigned_travelers: null,
        travel_agent_id: user.id, // Link to the travel agent who created this traveler
        created_at: new Date().toISOString(),
        last_login_at: new Date().toISOString(),
      })
      .select()
      .single()

    if (dbError) {
      console.error('Error creating user in database:', dbError)
      return new Response(
        JSON.stringify({ error: dbError.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`New traveler created successfully: ${newUserId} by agent: ${user.id}`)

    return new Response(
      JSON.stringify({
        success: true,
        user: {
          id: newUserId,
          email: email,
          name: name,
          roles: ['traveler'],
        },
        message: 'New traveler created successfully'
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
}) 