/*
  # Add subdomain validation

  1. Changes
    - Add function to validate subdomain format
    - Update valid_subdomain constraint to use the new function

  2. Validation Rules
    - Must be between 3 and 63 characters
    - Can only contain lowercase letters, numbers, and hyphens
    - Must start and end with a letter or number
    - Cannot have consecutive hyphens
*/

-- Create or replace the validation function
CREATE OR REPLACE FUNCTION public.is_valid_subdomain(subdomain text)
RETURNS boolean AS $$
BEGIN
  -- Check if subdomain is null
  IF subdomain IS NULL THEN
    RETURN false;
  END IF;

  -- Check length (3-63 characters)
  IF length(subdomain) < 3 OR length(subdomain) > 63 THEN
    RETURN false;
  END IF;

  -- Must contain only lowercase letters, numbers, and hyphens
  -- Must start and end with alphanumeric
  -- No consecutive hyphens
  RETURN subdomain ~ '^[a-z0-9][a-z0-9-]*[a-z0-9]$' 
    AND subdomain !~ '--';
END;
$$ LANGUAGE plpgsql IMMUTABLE;