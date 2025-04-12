/*
  # Fix API key creation

  1. Changes
    - Add function to get organization member ID
    - Update API key trigger to handle created_by field
    - Add helper functions for API key management

  2. Security
    - Maintain existing RLS policies
*/

-- Function to get organization member ID
CREATE OR REPLACE FUNCTION get_organization_member_id(org_id uuid, user_id uuid)
RETURNS uuid AS $$
DECLARE
  member_id uuid;
BEGIN
  SELECT id INTO member_id
  FROM organization_members
  WHERE organization_id = org_id AND user_id = user_id
  LIMIT 1;
  
  RETURN member_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Update set_api_key trigger function
CREATE OR REPLACE FUNCTION set_api_key()
RETURNS TRIGGER AS $$
BEGIN
  -- Set API key if not provided
  IF NEW.key IS NULL THEN
    NEW.key := generate_api_key();
  END IF;

  -- Get organization member ID if not provided
  IF NEW.created_by IS NULL THEN
    NEW.created_by := get_organization_member_id(NEW.organization_id, auth.uid());
    
    IF NEW.created_by IS NULL THEN
      RAISE EXCEPTION 'User is not a member of the organization';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;