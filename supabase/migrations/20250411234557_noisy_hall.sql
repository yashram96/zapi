/*
  # Create many-to-many relationship between API keys and projects

  1. Changes
    - Remove direct project_id from api_keys table
    - Create api_key_projects junction table
    - Add appropriate foreign keys and constraints
    - Update RLS policies

  2. Security
    - Enable RLS on new table
    - Add policies for organization members
*/

-- First remove the direct relationship
ALTER TABLE api_keys DROP COLUMN project_id;

-- Create junction table
CREATE TABLE api_key_projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  api_key_id uuid NOT NULL REFERENCES api_keys(id) ON DELETE CASCADE,
  project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(api_key_id, project_id)
);

-- Enable RLS
ALTER TABLE api_key_projects ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Organization members can view api key projects"
  ON api_key_projects
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM api_keys
      JOIN organization_members ON organization_members.organization_id = api_keys.organization_id
      WHERE api_keys.id = api_key_projects.api_key_id
      AND organization_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage api key projects"
  ON api_key_projects
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM api_keys
      JOIN organization_members ON organization_members.organization_id = api_keys.organization_id
      WHERE api_keys.id = api_key_projects.api_key_id
      AND organization_members.user_id = auth.uid()
      AND organization_members.role = 'admin'
    )
  );