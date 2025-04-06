/*
  # Add username to organization members

  1. Changes
    - Add username column to organization_members table
    - Add unique constraint on username
    - Add validation function for subdomains
  
  2. Security
    - Maintain existing RLS policies
*/

-- Create domain validation function
CREATE OR REPLACE FUNCTION is_valid_subdomain(subdomain text)
RETURNS boolean AS $$
BEGIN
  -- Check length (3-63 characters)
  IF length(subdomain) < 3 OR length(subdomain) > 63 THEN
    RETURN false;
  END IF;

  -- Must start with a letter
  IF NOT subdomain ~ '^[a-z]' THEN
    RETURN false;
  END IF;

  -- Only allow lowercase letters, numbers, and hyphens
  -- Must not start or end with hyphen
  IF NOT subdomain ~ '^[a-z][a-z0-9-]*[a-z0-9]$' THEN
    RETURN false;
  END IF;

  RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add check constraint to organizations table
ALTER TABLE organizations
ADD CONSTRAINT valid_subdomain 
CHECK (is_valid_subdomain(subdomain));

-- Add username to organization_members
ALTER TABLE organization_members
ADD COLUMN username text NOT NULL,
ADD CONSTRAINT organization_members_username_key UNIQUE (username);