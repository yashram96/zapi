/*
  # Add integrations and webhooks schema

  1. New Tables
    - `integrations`
      - `id` (uuid, primary key)
      - `organization_id` (uuid, foreign key)
      - `type` (text - github, postman, etc)
      - `config` (jsonb)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `webhooks`
      - `id` (uuid, primary key)
      - `organization_id` (uuid, foreign key)
      - `url` (text)
      - `events` (text[])
      - `secret` (text)
      - `active` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for organization admins
*/

-- Create integrations table
CREATE TABLE integrations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  type text NOT NULL,
  config jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_integration_type CHECK (
    type = ANY (ARRAY['github', 'postman', 'swagger', 'openapi'])
  )
);

-- Create webhooks table
CREATE TABLE webhooks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  url text NOT NULL,
  events text[] NOT NULL,
  secret text NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_webhook_events CHECK (
    events <@ ARRAY['endpoint.created', 'endpoint.updated', 'endpoint.deleted', 'request.received']
  )
);

-- Enable RLS
ALTER TABLE integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhooks ENABLE ROW LEVEL SECURITY;

-- Create policies for integrations
CREATE POLICY "Organization admins can manage integrations"
  ON integrations
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = integrations.organization_id
      AND organization_members.user_id = auth.uid()
      AND organization_members.role = 'admin'
    )
  );

CREATE POLICY "Organization members can view integrations"
  ON integrations
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = integrations.organization_id
      AND organization_members.user_id = auth.uid()
    )
  );

-- Create policies for webhooks
CREATE POLICY "Organization admins can manage webhooks"
  ON webhooks
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = webhooks.organization_id
      AND organization_members.user_id = auth.uid()
      AND organization_members.role = 'admin'
    )
  );

CREATE POLICY "Organization members can view webhooks"
  ON webhooks
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM organization_members
      WHERE organization_members.organization_id = webhooks.organization_id
      AND organization_members.user_id = auth.uid()
    )
  );

-- Create updated_at triggers
CREATE TRIGGER update_integrations_updated_at
  BEFORE UPDATE ON integrations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_webhooks_updated_at
  BEFORE UPDATE ON webhooks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();