-- Drop the problematic policies that are preventing travel agent login
DROP POLICY IF EXISTS "Travel agents can create travelers" ON users;
DROP POLICY IF EXISTS "Travel agents can update their travelers" ON users;
DROP POLICY IF EXISTS "Travel agents can view their travelers" ON users;

-- Create corrected policies that allow travel agents to login AND manage travelers

-- Allow travel agents and admins to create travelers
CREATE POLICY "Travel agents can create travelers" ON users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
    )
    AND 'traveler' = ANY(roles)
  );

-- Allow travel agents to update travelers they created, and users to update their own profile
CREATE POLICY "Travel agents can update their travelers" ON users
  FOR UPDATE USING (
    id = auth.uid() OR -- Users can always update their own profile
    (
      EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
      )
      AND travel_agent_id = auth.uid()
    )
  );

-- Allow users to view their own profile, and travel agents to view their travelers
CREATE POLICY "Users can view own profile and travel agents can view travelers" ON users
  FOR SELECT USING (
    id = auth.uid() OR -- Users can always view their own profile
    (
      EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
      )
      AND (travel_agent_id = auth.uid() OR 'admin' = ANY(roles))
    )
  ); 