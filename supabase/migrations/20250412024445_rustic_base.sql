/*
  # Add API name to projects table with proper constraint handling

  1. Changes
    - Add api_name column to projects table if not exists
    - Add validation function for api_name format
    - Add unique constraint for api_name within organization
    - Add index for performance
    - Handle existing constraints safely

  2. Validation Rules
    - Must be between 2 and 63 characters
    - Can only contain lowercase letters, numbers, and hyphens
    - Must start and end with alphanumeric character
    - Cannot have consecutive hyphens
    - Must be unique within an organization
*/

-- Create validation function for api_name if it doesn't exist
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

-- Add api_name column if it doesn't exist
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'projects' AND column_name = 'api_name'
  ) THEN
    ALTER TABLE projects ADD COLUMN api_name text;
  END IF;
END $$;

-- Update existing projects with a default api_name if needed
UPDATE projects 
SET api_name = LOWER(REGEXP_REPLACE(name, '[^a-zA-Z0-9]', '-', 'g'))
WHERE api_name IS NULL;

-- Make the column required
ALTER TABLE projects 
ALTER COLUMN api_name SET NOT NULL;

-- Drop existing constraints if they exist
DO $$ BEGIN
  ALTER TABLE projects DROP CONSTRAINT IF EXISTS valid_api_name;
  ALTER TABLE projects DROP CONSTRAINT IF EXISTS unique_org_api_name;
EXCEPTION
  WHEN undefined_object THEN NULL;
END $$;

-- Add check constraint for api_name format
ALTER TABLE projects
ADD CONSTRAINT valid_api_name CHECK (is_valid_api_name(api_name));

-- Add unique constraint for api_name within organization
ALTER TABLE projects
ADD CONSTRAINT unique_org_api_name UNIQUE (organization_id, api_name);

-- Create index for api_name lookups if it doesn't exist
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = 'projects' AND indexname = 'idx_projects_api_name'
  ) THEN
    CREATE INDEX idx_projects_api_name ON projects(api_name);
  END IF;
END $$;