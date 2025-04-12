/*
  # Add API keys table
  
  1. New Tables
    - `api_keys`
      - `id` (uuid, primary key)
      - `organization_id` (uuid, foreign key to organizations)
      - `created_by` (uuid, foreign key to organization_members)
      - `name` (text)
      - `key` (text, unique)
      - `access_type` (text, either 'read' or 'write')
      - `created_at` (timestamp)
      - `last_used_at` (timestamp)
      - `expires_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policies for organization members to manage keys
*/

-- Create API keys table
CREATE TABLE api_keys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  created_by uuid NOT NULL REFERENCES organization_members(id) ON DELETE CASCADE,
  name text NOT NULL,
  key text UNIQUE NOT NULL,
  access_type text NOT NULL CHECK (access_type IN ('read', 'write')),
  created_at timestamptz DEFAULT now(),
  last_used_at timestamptz,
  expires_at timestamptz,
  UNIQUE(organization_id, name)
);

-- Enable RLS
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Organization members can view API keys"
  ON api_keys
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = api_keys.organization_id
      AND organization_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage API keys"
  ON api_keys
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = api_keys.organization_id
      AND organization_members.user_id = auth.uid()
      AND organization_members.role = 'admin'
    )
  );