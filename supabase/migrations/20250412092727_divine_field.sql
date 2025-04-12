/*
  # Remove unique_org_api_name constraint
  
  1. Changes
    - Drop the unique constraint on organization_id and api_name
    - Keep the api_name column and its format validation
    - Keep the base_path uniqueness check
*/

-- Drop the unique constraint for api_name
ALTER TABLE projects DROP CONSTRAINT IF EXISTS unique_org_api_name;

-- Keep the base_path constraint
ALTER TABLE projects DROP CONSTRAINT IF EXISTS valid_base_path;

-- Re-add the base_path constraint
ALTER TABLE projects
ADD CONSTRAINT valid_base_path CHECK (
  base_path = api_name || '/api/' || version
);