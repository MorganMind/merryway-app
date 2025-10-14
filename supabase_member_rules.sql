-- =====================================================
-- Member Rules Table for Phase 3.5
-- =====================================================
-- This creates the member_rules table that stores rules for family members

-- Create member_rules table
CREATE TABLE IF NOT EXISTS public.member_rules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  member_id UUID NOT NULL REFERENCES public.family_members(id) ON DELETE CASCADE,
  rule_text TEXT NOT NULL,
  category TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_member_rules_member_id ON public.member_rules(member_id);
CREATE INDEX IF NOT EXISTS idx_member_rules_category ON public.member_rules(category);

-- Enable Row Level Security
ALTER TABLE public.member_rules ENABLE ROW LEVEL SECURITY;

-- RLS Policies for member_rules

-- Policy 1: Users can view rules for members in their household
CREATE POLICY "Users can view member rules in their household"
  ON public.member_rules
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.family_members fm
      JOIN public.households h ON fm.household_id = h.id
      WHERE fm.id = member_rules.member_id
        AND h.id IN (
          SELECT household_id FROM public.family_members
          WHERE user_id = auth.uid()
        )
    )
  );

-- Policy 2: Parents can insert rules for any member in their household
CREATE POLICY "Parents can add member rules in their household"
  ON public.member_rules
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.family_members fm_requester
      JOIN public.family_members fm_target ON fm_requester.household_id = fm_target.household_id
      WHERE fm_requester.user_id = auth.uid()
        AND fm_requester.role IN ('parent', 'caregiver')
        AND fm_target.id = member_rules.member_id
    )
  );

-- Policy 3: Parents can update rules in their household
CREATE POLICY "Parents can update member rules in their household"
  ON public.member_rules
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.family_members fm_requester
      JOIN public.family_members fm_target ON fm_requester.household_id = fm_target.household_id
      WHERE fm_requester.user_id = auth.uid()
        AND fm_requester.role IN ('parent', 'caregiver')
        AND fm_target.id = member_rules.member_id
    )
  );

-- Policy 4: Parents can delete rules in their household
CREATE POLICY "Parents can delete member rules in their household"
  ON public.member_rules
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.family_members fm_requester
      JOIN public.family_members fm_target ON fm_requester.household_id = fm_target.household_id
      WHERE fm_requester.user_id = auth.uid()
        AND fm_requester.role IN ('parent', 'caregiver')
        AND fm_target.id = member_rules.member_id
    )
  );

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_member_rules_updated_at ON public.member_rules;
CREATE TRIGGER update_member_rules_updated_at
  BEFORE UPDATE ON public.member_rules
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.member_rules TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

