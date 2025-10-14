-- Create idea_votes table for voting on activity suggestions

CREATE TABLE IF NOT EXISTS public.idea_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES public.family_members(id) ON DELETE CASCADE,
  activity_name TEXT NOT NULL,  -- Name of the suggested activity
  category TEXT DEFAULT 'today',  -- 'today', 'upcoming', 'saved', etc.
  vote_type TEXT NOT NULL CHECK (vote_type IN ('love', 'neutral', 'not_interested')),
  context JSONB,  -- Optional: store weather, time, etc. for context-specific votes
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one vote per member per activity
  UNIQUE(household_id, member_id, activity_name, category)
);

-- Enable RLS
ALTER TABLE public.idea_votes ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view votes in their households"
  ON public.idea_votes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = idea_votes.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create votes in their households"
  ON public.idea_votes FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = idea_votes.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update votes in their households"
  ON public.idea_votes FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = idea_votes.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete votes in their households"
  ON public.idea_votes FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = idea_votes.household_id
      AND households.user_id = auth.uid()
    )
  );

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idea_votes_household_id_idx ON public.idea_votes(household_id);
CREATE INDEX IF NOT EXISTS idea_votes_member_id_idx ON public.idea_votes(member_id);
CREATE INDEX IF NOT EXISTS idea_votes_activity_name_idx ON public.idea_votes(activity_name);
CREATE INDEX IF NOT EXISTS idea_votes_category_idx ON public.idea_votes(category);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_idea_votes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_idea_votes_updated_at ON public.idea_votes;
CREATE TRIGGER update_idea_votes_updated_at 
  BEFORE UPDATE ON public.idea_votes
  FOR EACH ROW 
  EXECUTE FUNCTION update_idea_votes_updated_at();

-- Add helpful comments
COMMENT ON TABLE public.idea_votes IS 'Votes on activity suggestions (love/neutral/not_interested)';
COMMENT ON COLUMN public.idea_votes.vote_type IS 'love, neutral, or not_interested';
COMMENT ON COLUMN public.idea_votes.category IS 'today, upcoming, saved, etc.';
COMMENT ON COLUMN public.idea_votes.context IS 'Optional context like weather, time_of_day for context-specific votes';

