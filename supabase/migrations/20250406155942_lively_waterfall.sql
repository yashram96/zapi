/*
  # Create organizations schema

  1. New Tables
    - `organizations`
      - `id` (uuid, primary key)
      - `subdomain` (text, unique)
      - `name` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `organizations` table
    - Add policies for public read access
    - Add policies for authenticated users to create organizations
*/

-- Create the organizations table
CREATE TABLE IF NOT EXISTS organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subdomain text NOT NULL,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add unique constraint for subdomain
ALTER TABLE organizations 
  ADD CONSTRAINT organizations_subdomain_key UNIQUE (subdomain);

-- Enable Row Level Security
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- Create policies
DO $$ BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Anyone can read organizations" ON organizations;
  DROP POLICY IF EXISTS "Only authenticated users can create organizations" ON organizations;
  
  -- Create new policies
  CREATE POLICY "Anyone can read organizations"
    ON organizations
    FOR SELECT
    TO public
    USING (true);

  CREATE POLICY "Only authenticated users can create organizations"
    ON organizations
    FOR INSERT
    TO authenticated
    WITH CHECK (true);
END $$;