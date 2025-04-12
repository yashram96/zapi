/*
  # Add project features

  1. New Columns
    - Add base_path for API routing
    - Add tags array for project categorization
    - Add is_favorite for project starring

  2. Changes
    - Modify projects table to include new columns
    - Add indexes for performance optimization
*/

-- Add new columns to projects table
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS base_path text,
ADD COLUMN IF NOT EXISTS tags text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS is_favorite boolean DEFAULT false;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_projects_is_favorite ON projects(is_favorite);
CREATE INDEX IF NOT EXISTS idx_projects_tags ON projects USING gin(tags);

-- Update RLS policies to include new columns
ALTER POLICY "Organization members can view projects" 
ON projects 
USING (
  EXISTS (
    SELECT 1 FROM organization_members
    WHERE organization_members.organization_id = projects.organization_id
    AND organization_members.user_id = auth.uid()
  )
);

ALTER POLICY "Organization admins and managers can manage projects"
ON projects
USING (
  EXISTS (
    SELECT 1 FROM organization_members
    WHERE organization_members.organization_id = projects.organization_id
    AND organization_members.user_id = auth.uid()
    AND organization_members.role IN ('admin', 'manager')
  )
);