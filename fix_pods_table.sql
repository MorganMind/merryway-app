-- Fix Pods table by dropping and recreating with correct schema

-- Drop existing policies first
DROP POLICY IF EXISTS "Users can view pods in their households" ON public.pods;
DROP POLICY IF EXISTS "Users can create pods in their households" ON public.pods;
DROP POLICY IF EXISTS "Users can update pods in their households" ON public.pods;
DROP POLICY IF EXISTS "Users can delete pods in their households" ON public.pods;

-- Drop existing trigger
DROP TRIGGER IF EXISTS update_pods_updated_at ON public.pods;

-- Drop existing index
DROP INDEX IF EXISTS pods_household_id_idx;

-- Drop the table
DROP TABLE IF EXISTS public.pods;

-- Recreate with correct schema
CREATE TABLE public.pods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  member_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
  color TEXT DEFAULT '#B4D7E8',
  icon TEXT DEFAULT '👥',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.pods ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view pods in their households"
  ON public.pods FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = pods.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create pods in their households"
  ON public.pods FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = pods.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update pods in their households"
  ON public.pods FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = pods.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete pods in their households"
  ON public.pods FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = pods.household_id
      AND households.user_id = auth.uid()
    )
  );

-- Create index
CREATE INDEX pods_household_id_idx ON public.pods(household_id);

-- Create trigger for updated_at
CREATE TRIGGER update_pods_updated_at BEFORE UPDATE ON public.pods
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

