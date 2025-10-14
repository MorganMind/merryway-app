-- Merryway Supabase Schema Setup
-- Run this in your Supabase SQL Editor

-- ============================================
-- 1. Create households table
-- ============================================
CREATE TABLE IF NOT EXISTS public.households (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;

-- RLS Policies for households
CREATE POLICY "Users can view their own households"
  ON public.households FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own households"
  ON public.households FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own households"
  ON public.households FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own households"
  ON public.households FOR DELETE
  USING (auth.uid() = user_id);

-- Create index
CREATE INDEX IF NOT EXISTS households_user_id_idx ON public.households(user_id);

-- ============================================
-- 2. Create family_members table
-- ============================================
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

-- RLS Policies for family_members
-- Users can view members in their households
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

-- Create indexes
CREATE INDEX IF NOT EXISTS family_members_household_id_idx ON public.family_members(household_id);

-- ============================================
-- 3. Create function to update updated_at timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================
-- 4. Create triggers for updated_at
-- ============================================
CREATE TRIGGER update_households_updated_at BEFORE UPDATE ON public.households
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_family_members_updated_at BEFORE UPDATE ON public.family_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

