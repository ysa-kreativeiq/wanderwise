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
    const { userId, newEmail } = await req.json()

    // Validate input
    if (!userId || !newEmail) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userId, newEmail' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(newEmail)) {
      return new Response(
        JSON.stringify({ error: 'Invalid email format' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if the requesting user is an admin
    const { data: requestingUser, error: userError } = await supabaseClient
      .from('users')
      .select('roles')
      .eq('id', user.id)
      .single()

    if (userError || !requestingUser) {
      return new Response(
        JSON.stringify({ error: 'User not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const isAdmin = requestingUser.roles.includes('admin')
    if (!isAdmin) {
      return new Response(
        JSON.stringify({ error: 'Only admins can change email addresses' }),
        { 
          status: 403, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`Admin ${user.id} updating email for user ${userId} to ${newEmail}`)

    // Check if the new email is already in use
    const { data: existingUser, error: checkError } = await supabaseClient
      .from('users')
      .select('id')
      .eq('email', newEmail)
      .neq('id', userId)
      .single()

    if (existingUser) {
      return new Response(
        JSON.stringify({ error: 'Email address is already in use' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Update email in Supabase Auth
    const { data: authData, error: authUpdateError } = await supabaseClient.auth.admin.updateUserById(
      userId,
      { email: newEmail }
    )

    if (authUpdateError) {
      console.error('Error updating email in auth:', authUpdateError)
      return new Response(
        JSON.stringify({ error: authUpdateError.message }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Update email in database
    const { data: dbData, error: dbError } = await supabaseClient
      .from('users')
      .update({ email: newEmail })
      .eq('id', userId)
      .select()
      .single()

    if (dbError) {
      console.error('Error updating email in database:', dbError)
      // Try to revert the auth change
      await supabaseClient.auth.admin.updateUserById(
        userId,
        { email: authData.user.email }
      )
      
      return new Response(
        JSON.stringify({ error: dbError.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log(`Email updated successfully for user ${userId}`)

    return new Response(
      JSON.stringify({
        success: true,
        userId: userId,
        oldEmail: authData.user.email,
        newEmail: newEmail,
        message: 'Email updated successfully in both Auth and database',
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