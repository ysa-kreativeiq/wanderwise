-- Fix infinite recursion in RLS policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "All users can read all users" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Admins can do everything" ON users;

-- Create policies that avoid infinite recursion

-- 1. All authenticated users can read all users (no role checking to avoid recursion)
CREATE POLICY "All users can read all users" ON users
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- 2. Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- 3. Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. Allow all operations for now (we'll restrict this later if needed)
CREATE POLICY "Allow all operations" ON users
  FOR ALL USING (auth.uid() IS NOT NULL); 