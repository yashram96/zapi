/*
  # Add settings fields to organizations and profiles
  
  1. Changes to organizations table:
    - Add logo_url for organization branding
    - Add billing_email for invoices
    - Add api_key_prefix for organization-specific API keys
  
  2. Changes to profiles table:
    - Add avatar_url for user profile pictures
    - Add notification_preferences for email settings
    - Add api_key_count to track personal API keys
*/

-- Add new fields to organizations
ALTER TABLE organizations
ADD COLUMN logo_url text,
ADD COLUMN billing_email text,
ADD COLUMN api_key_prefix text UNIQUE;

-- Add new fields to profiles
ALTER TABLE profiles
ADD COLUMN avatar_url text,
ADD COLUMN notification_preferences jsonb DEFAULT '{"email_updates": true, "security_alerts": true}'::jsonb,
ADD COLUMN api_key_count integer DEFAULT 0;