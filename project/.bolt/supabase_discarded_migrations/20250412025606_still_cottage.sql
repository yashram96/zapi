/*
  # Update API path structure to include /api/

  1. Changes
    - Update base_path format to include /api/
    - Update base_path constraint
    - Update existing records

  2. Security
    - Maintain existing RLS policies
*/

-- First remove the existing constraint
ALTER TABLE projects DROP CONSTRAINT IF EXISTS valid_base_path;

-- Update existing base_paths to include /api/
UPDATE projects
SET base_path = api_name || '/api/' || version
WHERE base_path IS NULL OR base_path != (api_name || '/api/' || version);

-- Add updated constraint
ALTER TABLE projects
ADD CONSTRAINT valid_base_path CHECK (
  base_path = api_name || '/api/' || version
);