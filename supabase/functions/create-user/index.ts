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
    // Create a Supabase client with the Auth context of the function
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get the authenticated user
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get request body
    const { email, password, name, roles, photoUrl } = await req.json()

    // Validate input
    if (!email || !password || !name || !roles) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: email, password, name, roles' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    if (!Array.isArray(roles) || roles.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Roles must be a non-empty array' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`Creating user: ${email} with roles: ${roles.join(', ')}`)

    // Create user in Supabase Auth
    const { data: authData, error: createUserError } = await supabaseClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        name,
        photo_url: photoUrl,
        roles
      }
    })

    if (createUserError) {
      console.error('Error creating user in auth:', createUserError)
      return new Response(
        JSON.stringify({ error: createUserError.message }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Create user record in database
    const { data: userData, error: dbError } = await supabaseClient
      .from('users')
      .insert({
        id: authData.user.id,
        email: email,
        name: name,
        photo_url: photoUrl,
        roles: roles,
        is_active: true,
        profile: {
          phone: null,
          address: null,
          company: null,
          position: null,
        },
        assigned_travelers: null,
        travel_agent_id: null,
      })
      .select()
      .single()

    if (dbError) {
      console.error('Error creating user in database:', dbError)
      // Try to clean up the auth user if database insert fails
      await supabaseClient.auth.admin.deleteUser(authData.user.id)
      
      return new Response(
        JSON.stringify({ error: dbError.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`User created successfully: ${authData.user.id}`)

    return new Response(
      JSON.stringify({
        success: true,
        userId: authData.user.id,
        email: email,
        name: name,
        roles: roles,
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