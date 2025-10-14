-- Create ai_suggestion_logs table to track AI-generated activity suggestions

CREATE TABLE IF NOT EXISTS public.ai_suggestion_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  pod_id UUID REFERENCES public.pods(id) ON DELETE SET NULL,
  prompt TEXT NOT NULL,  -- User's search prompt
  context JSONB,  -- Weather, time of day, day of week
  participant_ids UUID[] DEFAULT ARRAY[]::uuid[],  -- Members included in the search
  suggestions JSONB NOT NULL,  -- Array of generated suggestions
  model_used TEXT DEFAULT 'gpt-3.5-turbo',  -- AI model used
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Track user interactions
  user_accepted_suggestion TEXT,  -- Which suggestion was accepted
  user_dismissed BOOLEAN DEFAULT FALSE,
  feedback_rating INTEGER CHECK (feedback_rating >= 1 AND feedback_rating <= 5)
);

-- Enable RLS
ALTER TABLE public.ai_suggestion_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view AI suggestions in their households"
  ON public.ai_suggestion_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = ai_suggestion_logs.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create AI suggestions in their households"
  ON public.ai_suggestion_logs FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = ai_suggestion_logs.household_id
      AND households.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update AI suggestions in their households"
  ON public.ai_suggestion_logs FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.households
      WHERE households.id = ai_suggestion_logs.household_id
      AND households.user_id = auth.uid()
    )
  );

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS ai_suggestion_logs_household_id_idx ON public.ai_suggestion_logs(household_id);
CREATE INDEX IF NOT EXISTS ai_suggestion_logs_created_at_idx ON public.ai_suggestion_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS ai_suggestion_logs_pod_id_idx ON public.ai_suggestion_logs(pod_id);

-- Add comment for documentation
COMMENT ON TABLE public.ai_suggestion_logs IS 'Logs all AI-generated activity suggestions from user searches';
COMMENT ON COLUMN public.ai_suggestion_logs.prompt IS 'The user''s natural language search query';
COMMENT ON COLUMN public.ai_suggestion_logs.context IS 'Context at time of search (weather, time, day)';
COMMENT ON COLUMN public.ai_suggestion_logs.suggestions IS 'Array of AI-generated activity suggestions';
COMMENT ON COLUMN public.ai_suggestion_logs.user_accepted_suggestion IS 'Name of the suggestion the user accepted (if any)';

