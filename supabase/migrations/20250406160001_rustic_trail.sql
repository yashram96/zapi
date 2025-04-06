/*
  # Create organization members schema

  1. New Tables
    - `organization_members`
      - `id` (uuid, primary key)
      - `organization_id` (uuid, foreign key to organizations)
      - `user_id` (uuid, foreign key to auth.users)
      - `role` (text, default 'member')
      - `created_at` (timestamp)
      - Unique constraint on (organization_id, user_id)

  2. Security
    - Enable RLS on `organization_members` table
    - Add policies for users to read and create their own memberships
*/

-- Create the organization_members table
CREATE TABLE IF NOT EXISTS organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member',
  created_at timestamptz DEFAULT now(),
  UNIQUE(organization_id, user_id)
);

-- Enable Row Level Security
ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;

-- Create policies
DO $$ BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Users can read their own organization memberships" ON organization_members;
  DROP POLICY IF EXISTS "Users can insert their own organization memberships" ON organization_members;
  
  -- Create new policies
  CREATE POLICY "Users can read their own organization memberships"
    ON organization_members
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

  CREATE POLICY "Users can insert their own organization memberships"
    ON organization_members
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);
END $$;