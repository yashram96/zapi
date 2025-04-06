/*
  # Add role-based access control

  1. Changes
    - Update organization_members table with strict role types
    - Add default role policy
    - Add role validation

  2. Security
    - Maintain existing RLS policies
    - Add role-specific access controls
*/

-- Update the role column to use an enum type
DO $$ BEGIN
  -- Create the role enum type if it doesn't exist
  CREATE TYPE org_role AS ENUM ('admin', 'manager', 'editor', 'viewer');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Update the role column
ALTER TABLE organization_members
  ALTER COLUMN role TYPE org_role USING role::org_role,
  ALTER COLUMN role SET DEFAULT 'viewer'::org_role;

-- Add role hierarchy function
CREATE OR REPLACE FUNCTION is_role_at_least(user_role org_role, required_role org_role)
RETURNS boolean AS $$
BEGIN
  -- Define role hierarchy (higher index = more permissions)
  RETURN CASE user_role
    WHEN 'admin' THEN true  -- Admin can do everything
    WHEN 'manager' THEN required_role IN ('manager', 'editor', 'viewer')
    WHEN 'editor' THEN required_role IN ('editor', 'viewer')
    WHEN 'viewer' THEN required_role = 'viewer'
    ELSE false
  END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;