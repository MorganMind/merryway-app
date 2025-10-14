-- Add birthday field to family_members table
ALTER TABLE public.family_members
ADD COLUMN IF NOT EXISTS birthday DATE;

-- Create locations table
CREATE TABLE IF NOT EXISTS public.locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  name TEXT NOT NULL,  -- e.g., "Home", "School", "Work", "Grandma's House"
  address TEXT NOT NULL,
  latitude DECIMAL(10, 8),  -- For future distance calculations
  longitude DECIMAL(11, 8),
  notes TEXT,  -- Optional notes about the location
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for locations
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;

-- RLS Policies for locations
DROP POLICY IF EXISTS "Users can view locations in their households" ON public.locations;
CREATE POLICY "Users can view locations in their households"
  ON public.locations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = locations.household_id
      AND households.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create locations in their households" ON public.locations;
CREATE POLICY "Users can create locations in their households"
  ON public.locations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = locations.household_id
      AND households.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update locations in their households" ON public.locations;
CREATE POLICY "Users can update locations in their households"
  ON public.locations FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = locations.household_id
      AND households.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete locations in their households" ON public.locations;
CREATE POLICY "Users can delete locations in their households"
  ON public.locations FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = locations.household_id
      AND households.user_id = auth.uid()
    )
  );

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS locations_household_id_idx ON public.locations(household_id);

-- Add updated_at trigger
DROP TRIGGER IF EXISTS update_locations_updated_at ON public.locations;
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON public.locations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add some helpful comments
COMMENT ON TABLE public.locations IS 'Named locations (home, school, work, etc.) for households';
COMMENT ON COLUMN public.locations.name IS 'Display name like "Home", "School", "Grandmas House"';
COMMENT ON COLUMN public.locations.address IS 'Full address string';
COMMENT ON COLUMN public.locations.latitude IS 'Latitude for distance calculations';
COMMENT ON COLUMN public.locations.longitude IS 'Longitude for distance calculations';

