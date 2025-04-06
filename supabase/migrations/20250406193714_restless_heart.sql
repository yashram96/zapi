/*
  # Add role-based access control

  1. Changes
    - Create org_role enum type
    - Add temporary column for role conversion
    - Convert existing roles to enum type
    - Drop old role column and rename new one
    - Add role hierarchy function

  2. Security
    - Maintain existing RLS policies
*/

-- Create the role enum type
DO $$ BEGIN
  CREATE TYPE org_role AS ENUM ('admin', 'manager', 'editor', 'viewer');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Add a new column for the enum type
ALTER TABLE organization_members
ADD COLUMN role_enum org_role;

-- Update the new column with converted values
UPDATE organization_members
SET role_enum = CASE
  WHEN role = 'admin' THEN 'admin'::org_role
  WHEN role = 'manager' THEN 'manager'::org_role
  WHEN role = 'editor' THEN 'editor'::org_role
  ELSE 'viewer'::org_role
END;

-- Drop the old column and rename the new one
ALTER TABLE organization_members
DROP COLUMN role,
ALTER COLUMN role_enum SET NOT NULL,
ALTER COLUMN role_enum SET DEFAULT 'viewer'::org_role,
RENAME COLUMN role_enum TO role;

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