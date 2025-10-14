-- Merryway Supabase Schema Setup (Clean Install)
-- This version drops and recreates everything cleanly

-- ============================================
-- 1. Drop existing policies (if any)
-- ============================================
DROP POLICY IF EXISTS "Users can view their own households" ON public.households;
DROP POLICY IF EXISTS "Users can create their own households" ON public.households;
DROP POLICY IF EXISTS "Users can update their own households" ON public.households;
DROP POLICY IF EXISTS "Users can delete their own households" ON public.households;

DROP POLICY IF EXISTS "Users can view their household members" ON public.family_members;
DROP POLICY IF EXISTS "Users can create members in their households" ON public.family_members;
DROP POLICY IF EXISTS "Users can update members in their households" ON public.family_members;
DROP POLICY IF EXISTS "Users can delete members in their households" ON public.family_members;

-- ============================================
-- 2. Create tables (if they don't exist)
-- ============================================
CREATE TABLE IF NOT EXISTS public.households (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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

-- ============================================
-- 3. Enable RLS
-- ============================================
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. Create RLS Policies for households
-- ============================================
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

-- ============================================
-- 5. Create RLS Policies for family_members
-- ============================================
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

-- ============================================
-- 6. Create indexes
-- ============================================
CREATE INDEX IF NOT EXISTS households_user_id_idx ON public.households(user_id);
CREATE INDEX IF NOT EXISTS family_members_household_id_idx ON public.family_members(household_id);

-- ============================================
-- 7. Create update trigger function
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================
-- 8. Drop existing triggers (if any)
-- ============================================
DROP TRIGGER IF EXISTS update_households_updated_at ON public.households;
DROP TRIGGER IF EXISTS update_family_members_updated_at ON public.family_members;

-- ============================================
-- 9. Create triggers
-- ============================================
CREATE TRIGGER update_households_updated_at BEFORE UPDATE ON public.households
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_family_members_updated_at BEFORE UPDATE ON public.family_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

