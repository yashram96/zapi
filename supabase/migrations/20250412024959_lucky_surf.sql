/*
  # Add version validation and update base path structure

  1. Changes
    - Add version column to projects table
    - Add validation function for version format
    - Update base_path to include api_name
    - Add constraints and validation

  2. Validation Rules
    - Version must be in format 'v1', 'v2', etc.
    - Version is required
    - Base path will be constructed as /{api_name}/{version}
*/

-- Create version validation function
CREATE OR REPLACE FUNCTION is_valid_version(version text)
RETURNS boolean AS $$
BEGIN
  -- Check if version is null
  IF version IS NULL THEN
    RETURN false;
  END IF;

  -- Must be in format 'v' followed by a number
  RETURN version ~ '^v[1-9][0-9]*$';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add version column if it doesn't exist
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'projects' AND column_name = 'version'
  ) THEN
    ALTER TABLE projects ADD COLUMN version text DEFAULT 'v1';
  END IF;
END $$;

-- Make version required and add constraint
ALTER TABLE projects 
ALTER COLUMN version SET NOT NULL,
ADD CONSTRAINT valid_version CHECK (is_valid_version(version));

-- Create unique constraint for api_name and version within organization
ALTER TABLE projects
DROP CONSTRAINT IF EXISTS unique_org_api_version,
ADD CONSTRAINT unique_org_api_version UNIQUE (organization_id, api_name, version);

-- Update base_path to follow new structure
UPDATE projects
SET base_path = api_name || '/' || version
WHERE base_path IS NULL OR base_path = '';

-- Add constraint to ensure base_path matches api_name/version format
ALTER TABLE projects
ADD CONSTRAINT valid_base_path CHECK (
  base_path = api_name || '/' || version
);