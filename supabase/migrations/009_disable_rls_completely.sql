-- Completely disable RLS on users table and use application-level security
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- This will allow all authenticated users to access the users table
-- We'll implement security at the application level instead 