/*
  # Fix endpoints schema and validation

  1. Changes
    - Add IF NOT EXISTS to table creation
    - Add missing constraints and policies
    - Ensure proper RLS setup

  2. Security
    - Enable RLS
    - Add policies for organization members
*/

-- Create endpoints table if it doesn't exist
DO $$ BEGIN
  CREATE TABLE IF NOT EXISTS endpoints (
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
    updated_at timestamptz DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN NULL;
END $$;

-- Drop existing constraints if they exist
DO $$ BEGIN
  ALTER TABLE endpoints DROP CONSTRAINT IF EXISTS valid_method;
  ALTER TABLE endpoints DROP CONSTRAINT IF EXISTS valid_response_type;
  ALTER TABLE endpoints DROP CONSTRAINT IF EXISTS valid_status_code;
  ALTER TABLE endpoints DROP CONSTRAINT IF EXISTS unique_project_path;
EXCEPTION
  WHEN undefined_object THEN NULL;
END $$;

-- Add constraints
ALTER TABLE endpoints
ADD CONSTRAINT valid_method CHECK (method IN ('GET', 'POST', 'PUT', 'DELETE')),
ADD CONSTRAINT valid_response_type CHECK (response_type IN ('json', 'xml', 'text')),
ADD CONSTRAINT valid_status_code CHECK (status_code BETWEEN 100 AND 599),
ADD CONSTRAINT unique_project_path UNIQUE (project_id, method, path);

-- Create indexes if they don't exist
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_endpoints_project_id') THEN
    CREATE INDEX idx_endpoints_project_id ON endpoints(project_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_endpoints_path') THEN
    CREATE INDEX idx_endpoints_path ON endpoints(path);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_endpoints_active') THEN
    CREATE INDEX idx_endpoints_active ON endpoints(active);
  END IF;
END $$;

-- Enable RLS
ALTER TABLE endpoints ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Organization members can view endpoints" ON endpoints;
DROP POLICY IF EXISTS "Organization admins and managers can manage endpoints" ON endpoints;

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

-- Create updated_at trigger if it doesn't exist
DO $$ BEGIN
  CREATE TRIGGER update_endpoints_updated_at
    BEFORE UPDATE ON endpoints
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;