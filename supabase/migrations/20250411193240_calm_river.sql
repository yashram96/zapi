/*
  # Add organization update policy

  1. Changes
    - Add RLS policy for organization admins and managers to update organization details
    - Add RLS policy for organization members to view organization details

  2. Security
    - Only admins and managers can update organization details
    - All organization members can view organization details
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can read organizations" ON organizations;
DROP POLICY IF EXISTS "Only authenticated users can create organizations" ON organizations;

-- Create new policies
CREATE POLICY "Organization members can view organizations"
  ON organizations
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = organizations.id
      AND organization_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Organization admins and managers can update organizations"
  ON organizations
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = organizations.id
      AND organization_members.user_id = auth.uid()
      AND organization_members.role IN ('admin', 'manager')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = organizations.id
      AND organization_members.user_id = auth.uid()
      AND organization_members.role IN ('admin', 'manager')
    )
  );

CREATE POLICY "Only authenticated users can create organizations"
  ON organizations
  FOR INSERT
  TO authenticated
  WITH CHECK (true);