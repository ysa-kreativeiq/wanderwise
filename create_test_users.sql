-- Create test users with different roles
-- Run this in your Supabase SQL Editor

-- First, let's create a travel agent user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  gen_random_uuid(),
  'travelagent@test.com',
  crypt('Test123!', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"name": "Test Travel Agent", "roles": ["travelAgent"]}',
  false,
  '',
  '',
  '',
  ''
);

-- Get the user ID we just created
DO $$
DECLARE
  travel_agent_id uuid;
BEGIN
  SELECT id INTO travel_agent_id FROM auth.users WHERE email = 'travelagent@test.com';
  
  -- Insert into our users table
  INSERT INTO public.users (
    id,
    email,
    name,
    roles,
    is_active,
    created_at,
    last_login_at,
    profile,
    assigned_travelers,
    travel_agent_id
  ) VALUES (
    travel_agent_id,
    'travelagent@test.com',
    'Test Travel Agent',
    ARRAY['travelAgent'],
    true,
    now(),
    now(),
    '{}',
    ARRAY[]::uuid[],
    null
  );
END $$;

-- Create an editor user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  gen_random_uuid(),
  'editor@test.com',
  crypt('Test123!', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"name": "Test Editor", "roles": ["editor"]}',
  false,
  '',
  '',
  '',
  ''
);

-- Get the editor user ID and insert into our table
DO $$
DECLARE
  editor_id uuid;
BEGIN
  SELECT id INTO editor_id FROM auth.users WHERE email = 'editor@test.com';
  
  INSERT INTO public.users (
    id,
    email,
    name,
    roles,
    is_active,
    created_at,
    last_login_at,
    profile,
    assigned_travelers,
    travel_agent_id
  ) VALUES (
    editor_id,
    'editor@test.com',
    'Test Editor',
    ARRAY['editor'],
    true,
    now(),
    now(),
    '{}',
    ARRAY[]::uuid[],
    null
  );
END $$;

-- Create a content editor user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  gen_random_uuid(),
  'contenteditor@test.com',
  crypt('Test123!', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"name": "Test Content Editor", "roles": ["contentEditor"]}',
  false,
  '',
  '',
  '',
  ''
);

-- Get the content editor user ID and insert into our table
DO $$
DECLARE
  content_editor_id uuid;
BEGIN
  SELECT id INTO content_editor_id FROM auth.users WHERE email = 'contenteditor@test.com';
  
  INSERT INTO public.users (
    id,
    email,
    name,
    roles,
    is_active,
    created_at,
    last_login_at,
    profile,
    assigned_travelers,
    travel_agent_id
  ) VALUES (
    content_editor_id,
    'contenteditor@test.com',
    'Test Content Editor',
    ARRAY['contentEditor'],
    true,
    now(),
    now(),
    '{}',
    ARRAY[]::uuid[],
    null
  );
END $$;

-- Show the created users
SELECT 
  u.email,
  u.name,
  u.roles,
  u.is_active,
  u.created_at
FROM public.users u
WHERE u.email IN ('travelagent@test.com', 'editor@test.com', 'contenteditor@test.com')
ORDER BY u.created_at; 