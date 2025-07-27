-- Fix the infinite recursion issue in RLS policies
-- First, drop the problematic policies
DROP POLICY IF EXISTS "Admins can manage all users" ON users;
DROP POLICY IF EXISTS "Admins can manage destinations" ON destinations;

-- Create a function to check if user is admin (bypasses RLS)
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users 
    WHERE id = user_id 
    AND 'admin' = ANY(roles)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the admin policies using the function
CREATE POLICY "Admins can manage all users" ON users
  FOR ALL USING (
    auth.uid() = id OR -- Users can manage their own profile
    is_admin(auth.uid()) -- Admins can manage all users
  );

CREATE POLICY "Admins can manage destinations" ON destinations
  FOR ALL USING (
    is_active = true OR -- Public read access
    is_admin(auth.uid()) -- Admins can manage all destinations
  );

-- Also fix the destinations policy to allow public read access
DROP POLICY IF EXISTS "Destinations are publicly readable" ON destinations;
CREATE POLICY "Destinations are publicly readable" ON destinations
  FOR SELECT USING (is_active = true); 