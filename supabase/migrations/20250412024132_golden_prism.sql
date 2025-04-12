/*
  # Add API name to projects

  1. Changes
    - Add api_name column to projects table
    - Add unique constraint for api_name within organization
    - Add validation function for api_name format
    - Add check constraint for valid api_name

  2. Security
    - Maintain existing RLS policies
*/

-- Create validation function for api_name
CREATE OR REPLACE FUNCTION is_valid_api_name(api_name text)
RETURNS boolean AS $$
BEGIN
  -- Check if api_name is null
  IF api_name IS NULL THEN
    RETURN false;
  END IF;

  -- Check length (2-63 characters)
  IF length(api_name) < 2 OR length(api_name) > 63 THEN
    RETURN false;
  END IF;

  -- Must contain only lowercase letters, numbers, and hyphens
  -- Must start and end with alphanumeric
  -- No consecutive hyphens
  RETURN api_name ~ '^[a-z0-9][a-z0-9-]*[a-z0-9]$' 
    AND api_name !~ '--';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add api_name column to projects
ALTER TABLE projects
ADD COLUMN api_name text NOT NULL;

-- Add check constraint for api_name format
ALTER TABLE projects
ADD CONSTRAINT valid_api_name CHECK (is_valid_api_name(api_name));

-- Add unique constraint for api_name within organization
ALTER TABLE projects
ADD CONSTRAINT unique_org_api_name UNIQUE (organization_id, api_name);

-- Create index for api_name lookups
CREATE INDEX idx_projects_api_name ON projects(api_name);