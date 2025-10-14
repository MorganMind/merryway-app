-- Create table for suggestion feedback
CREATE TABLE IF NOT EXISTS public.suggestion_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    member_id UUID NOT NULL REFERENCES public.family_members(id) ON DELETE CASCADE,
    activity_name TEXT NOT NULL,
    feedback_type TEXT NOT NULL CHECK (feedback_type IN ('love', 'neutral', 'not_interested')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(household_id, member_id, activity_name)
);

-- Add RLS policies
ALTER TABLE public.suggestion_feedback ENABLE ROW LEVEL SECURITY;

-- Users can read feedback for their household
CREATE POLICY "Users can read feedback for their household"
ON public.suggestion_feedback
FOR SELECT
USING (
    household_id IN (
        SELECT id FROM public.households
        WHERE user_id = auth.uid()
    )
);

-- Users can insert feedback for their household
CREATE POLICY "Users can insert feedback for their household"
ON public.suggestion_feedback
FOR INSERT
WITH CHECK (
    household_id IN (
        SELECT id FROM public.households
        WHERE user_id = auth.uid()
    )
);

-- Users can update feedback for their household
CREATE POLICY "Users can update feedback for their household"
ON public.suggestion_feedback
FOR UPDATE
USING (
    household_id IN (
        SELECT id FROM public.households
        WHERE user_id = auth.uid()
    )
);

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_suggestion_feedback_household_member 
ON public.suggestion_feedback(household_id, member_id);

-- Add index for activity name lookups
CREATE INDEX IF NOT EXISTS idx_suggestion_feedback_activity 
ON public.suggestion_feedback(activity_name);

