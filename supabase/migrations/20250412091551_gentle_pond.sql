/*
  # Fix base path format and constraints

  1. Changes
    - Update base_path constraint to match required format
    - Add validation function for base_path
    - Update existing records to match new format

  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing base_path constraint if it exists
ALTER TABLE projects DROP CONSTRAINT IF EXISTS valid_base_path;

-- Update base_path format for existing records
UPDATE projects
SET base_path = api_name || '/api/' || version
WHERE base_path IS NULL OR base_path != api_name || '/api/' || version;

-- Add new constraint for base_path format
ALTER TABLE projects
ADD CONSTRAINT valid_base_path CHECK (
  base_path = api_name || '/api/' || version
);