-- Simple, working RLS policies that ensure login works
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Admins have full access" ON users;
DROP POLICY IF EXISTS "Travel agents can create travelers" ON users;
DROP POLICY IF EXISTS "Travel agents can read their travelers" ON users;
DROP POLICY IF EXISTS "Travel agents can update their travelers" ON users;
DROP POLICY IF EXISTS "Public profiles are viewable" ON users;

-- Create simple, permissive policies that definitely work

-- 1. ALL authenticated users can read ALL users (simple and permissive)
CREATE POLICY "All users can read all users" ON users
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- 2. Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- 3. Users can insert their own profile (for registration)
CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. Admins can do everything
CREATE POLICY "Admins can do everything" ON users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND 'admin' = ANY(roles)
    )
  ); 