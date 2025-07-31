-- Allow travel agents to create travelers
CREATE POLICY "Travel agents can create travelers" ON users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
    )
    AND 'traveler' = ANY(roles)
  );

-- Allow travel agents to update travelers they created
CREATE POLICY "Travel agents can update their travelers" ON users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
    )
    AND travel_agent_id = auth.uid()
  );

-- Allow travel agents to view travelers they created
CREATE POLICY "Travel agents can view their travelers" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND ('travelAgent' = ANY(roles) OR 'admin' = ANY(roles))
    )
    AND (travel_agent_id = auth.uid() OR id = auth.uid())
  ); 