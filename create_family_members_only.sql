-- Simple: Just create the missing family_members table
-- (households table already exists)

CREATE TABLE IF NOT EXISTS public.family_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  age INTEGER NOT NULL CHECK (age > 0 AND age <= 150),
  role TEXT NOT NULL CHECK (role IN ('parent', 'child', 'caregiver')),
  favorite_activities JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their household members"
  ON public.family_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = family_members.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create members in their households"
  ON public.family_members FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = family_members.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update members in their households"
  ON public.family_members FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = family_members.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete members in their households"
  ON public.family_members FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = family_members.household_id
      AND households.user_id = auth.uid()
    )
  );

-- Create index
CREATE INDEX IF NOT EXISTS family_members_household_id_idx ON public.family_members(household_id);

-- Create or replace the trigger function (in case it doesn't exist)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger
DROP TRIGGER IF EXISTS update_family_members_updated_at ON public.family_members;
CREATE TRIGGER update_family_members_updated_at BEFORE UPDATE ON public.family_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

