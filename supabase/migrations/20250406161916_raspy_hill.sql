/*
  # Add onboarding data to profiles

  1. Changes
    - Add onboarding fields to profiles table:
      - display_name (text)
      - role (text)
      - use_cases (text[])
      - team_size (text)
      - onboarding_completed (boolean)

  2. Security
    - Maintain existing RLS policies
*/

-- Add onboarding fields to profiles table
ALTER TABLE profiles
ADD COLUMN display_name text,
ADD COLUMN role text CHECK (role IN ('frontend_developer', 'full_stack_developer', 'qa_tester', 'designer', 'product_manager', 'other')),
ADD COLUMN use_cases text[],
ADD COLUMN team_size text CHECK (team_size IN ('solo', 'small_team', 'growing_team', 'large_team')),
ADD COLUMN onboarding_completed boolean DEFAULT false;