/*
  # Remove subdomain from profiles table

  1. Changes
    - Remove subdomain column from profiles table since it's redundant
    - Organization subdomain should be used instead

  2. Security
    - No security changes needed
    - Existing RLS policies remain unchanged
*/

-- Remove subdomain column from profiles
ALTER TABLE profiles DROP COLUMN subdomain;