/*
  # Add theme preference to profiles

  1. Changes
    - Add theme_preference column to profiles table
    - Set default theme to 'light'
    - Add check constraint to ensure valid theme values

  2. Security
    - Maintain existing RLS policies
*/

-- Add theme_preference column
ALTER TABLE profiles
ADD COLUMN theme_preference text NOT NULL DEFAULT 'light'
CHECK (theme_preference IN ('light', 'dark'));