-- First, create the user in auth.users (you'll need to replace USER_ID_HERE with the actual UUID from step 1)
-- This is just for reference - you'll do this manually in the Auth section

-- Then insert the user record into the users table
INSERT INTO users (
  id,
  email,
  name,
  roles,
  is_active,
  profile,
  assigned_travelers,
  travel_agent_id
) VALUES (
  'USER_ID_HERE', -- Replace with the actual UUID from auth.users
  'admin@wanderwise.com',
  'Admin User',
  ARRAY['admin'], -- This is the correct PostgreSQL array syntax
  true,
  '{}',
  ARRAY[]::uuid[],
  null
);

-- To verify the user was created correctly:
SELECT id, email, name, roles, is_active FROM users WHERE email = 'admin@wanderwise.com'; 