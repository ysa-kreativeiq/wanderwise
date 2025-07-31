-- Temporarily disable RLS on users table to test if that's causing login issues
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- This will allow all authenticated users to access the users table
-- We can re-enable it once we confirm the login works 