-- Re-enable RLS and create proper policies that allow login
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop any existing policies to start clean
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Admins have full access" ON users;
DROP POLICY IF EXISTS "Travel agents can create travelers" ON users;
DROP POLICY IF EXISTS "Travel agents can read their travelers" ON users;
DROP POLICY IF EXISTS "Travel agents can update their travelers" ON users;
DROP POLICY IF EXISTS "Public profiles are viewable" ON users;

-- Create the essential policies that allow login and proper functionality

-- 1. CRITICAL: All authenticated users can read their own profile (required for login)
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT USING (auth.uid() = id);

-- 2. All authenticated users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- 3. Admins can do everything (read, write, delete all users)
CREATE POLICY "Admins have full access" ON users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND 'admin' = ANY(roles)
    )
  );

-- 4. Travel agents can create travelers
CREATE POLICY "Travel agents can create travelers" ON users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
    )
    AND 'traveler' = ANY(roles)
  );

-- 5. Travel agents can read travelers they created
CREATE POLICY "Travel agents can read their travelers" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
    )
    AND travel_agent_id = auth.uid()
  );

-- 6. Travel agents can update travelers they created
CREATE POLICY "Travel agents can update their travelers" ON users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
    )
    AND travel_agent_id = auth.uid()
  );

-- 7. Public profiles can be viewed by anyone (for basic user discovery)
CREATE POLICY "Public profiles are viewable" ON users
  FOR SELECT USING (is_active = true); 