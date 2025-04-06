/*
  # Add insert policy for profiles table

  1. Security Changes
    - Add RLS policy to allow authenticated users to create their own profiles
    - Policy ensures users can only create profiles with their own user ID
*/

CREATE POLICY "Users can create their own profile"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);