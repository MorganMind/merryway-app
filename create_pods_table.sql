-- Create Pods table for family sub-groups

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
CREATE INDEX IF NOT EXISTS pods_household_id_idx ON public.pods(household_id);

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS update_pods_updated_at ON public.pods;
CREATE TRIGGER update_pods_updated_at BEFORE UPDATE ON public.pods
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some default pods for existing households (optional)
-- Uncomment if you want to create default pods for all households
-- INSERT INTO public.pods (household_id, name, description, icon)
-- SELECT id, 'Everyone', 'All family members', '👨‍👩‍👧‍👦'
-- FROM public.households;

