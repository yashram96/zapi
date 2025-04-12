/*
  # Add API key generation

  1. Changes
    - Add function to generate secure API keys
    - Add trigger to automatically generate API key before insert
    - Add function to validate API key format

  2. Security
    - Maintain existing RLS policies
    - Ensure API keys are cryptographically secure
*/

-- Create function to generate secure API keys
CREATE OR REPLACE FUNCTION generate_api_key()
RETURNS text AS $$
DECLARE
  key text;
BEGIN
  -- Generate a secure random key with prefix 'zapi_' followed by 32 random characters
  key := 'zapi_' || encode(gen_random_bytes(24), 'hex');
  RETURN key;
END;
$$ LANGUAGE plpgsql VOLATILE;

-- Create trigger function to set API key before insert
CREATE OR REPLACE FUNCTION set_api_key()
RETURNS TRIGGER AS $$
BEGIN
  -- Only set key if not provided
  IF NEW.key IS NULL THEN
    NEW.key := generate_api_key();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set API key
DROP TRIGGER IF EXISTS set_api_key_trigger ON api_keys;
CREATE TRIGGER set_api_key_trigger
  BEFORE INSERT ON api_keys
  FOR EACH ROW
  EXECUTE FUNCTION set_api_key();

-- Add function to validate API key format
CREATE OR REPLACE FUNCTION is_valid_api_key(key text)
RETURNS boolean AS $$
BEGIN
  RETURN key ~ '^zapi_[a-f0-9]{48}$';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add constraint to validate API key format
ALTER TABLE api_keys
ADD CONSTRAINT valid_api_key_format
CHECK (is_valid_api_key(key));