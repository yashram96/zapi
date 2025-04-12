/*
  # Create endpoints schema

  1. New Tables
    - `endpoints`
      - `id` (uuid, primary key)
      - `project_id` (uuid, foreign key to projects)
      - `method` (text - GET, POST, PUT, DELETE)
      - `path` (text)
      - `description` (text)
      - `response_type` (text - json, xml, text)
      - `response_body` (jsonb)
      - `status_code` (integer)
      - `headers` (jsonb)
      - `active` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policies for organization members
*/

-- Create endpoints table
CREATE TABLE endpoints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  method text NOT NULL,
  path text NOT NULL,
  description text,
  response_type text NOT NULL DEFAULT 'json',
  response_body jsonb NOT NULL DEFAULT '{}',
  status_code integer NOT NULL DEFAULT 200,
  headers jsonb DEFAULT '{}',
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Constraints
  CONSTRAINT valid_method CHECK (method IN ('GET', 'POST', 'PUT', 'DELETE')),
  CONSTRAINT valid_response_type CHECK (response_type IN ('json', 'xml', 'text')),
  CONSTRAINT valid_status_code CHECK (status_code BETWEEN 100 AND 599),
  CONSTRAINT unique_project_path UNIQUE (project_id, method, path)
);

-- Create index for faster lookups
CREATE INDEX idx_endpoints_project_id ON endpoints(project_id);
CREATE INDEX idx_endpoints_path ON endpoints(path);
CREATE INDEX idx_endpoints_active ON endpoints(active);

-- Enable RLS
ALTER TABLE endpoints ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Organization members can view endpoints"
  ON endpoints
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM projects
      JOIN organization_members ON organization_members.organization_id = projects.organization_id
      WHERE projects.id = endpoints.project_id
      AND organization_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Organization admins and managers can manage endpoints"
  ON endpoints
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM projects
      JOIN organization_members ON organization_members.organization_id = projects.organization_id
      WHERE projects.id = endpoints.project_id
      AND organization_members.user_id = auth.uid()
      AND organization_members.role IN ('admin', 'manager')
    )
  );

-- Create updated_at trigger
CREATE TRIGGER update_endpoints_updated_at
  BEFORE UPDATE ON endpoints
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();