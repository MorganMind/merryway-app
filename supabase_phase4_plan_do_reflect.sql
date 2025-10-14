-- =====================================================
-- Phase 4: Plan · Do · Reflect
-- Migrations for Experiences, Reviews, Merry Moments, Media
-- =====================================================

-- Drop existing tables if needed (for fresh setup)
DROP TABLE IF EXISTS public.media_items CASCADE;
DROP TABLE IF EXISTS public.merry_moments CASCADE;
DROP TABLE IF EXISTS public.experience_reviews CASCADE;
DROP TABLE IF EXISTS public.experiences CASCADE;

-- =====================================================
-- 1. EXPERIENCES TABLE
-- =====================================================
CREATE TABLE public.experiences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  activity_name TEXT,
  suggestion_id TEXT, -- optional reference to suggestion/activity
  participant_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
  start_at TIMESTAMPTZ,
  end_at TIMESTAMPTZ,
  place TEXT,
  place_address TEXT,
  place_lat DOUBLE PRECISION,
  place_lng DOUBLE PRECISION,
  status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'live', 'done', 'cancelled')),
  prep_notes TEXT,
  needs_adult BOOLEAN DEFAULT false,
  cost_estimate DECIMAL(10, 2),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for household queries
CREATE INDEX idx_experiences_household ON public.experiences(household_id);
CREATE INDEX idx_experiences_status ON public.experiences(status);
CREATE INDEX idx_experiences_start_at ON public.experiences(start_at);

-- RLS Policies for experiences
ALTER TABLE public.experiences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their household experiences" ON public.experiences;
CREATE POLICY "Users can view their household experiences"
  ON public.experiences FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid() OR household_id IN (
        SELECT id FROM public.households WHERE id = household_id
      )
    )
  );

DROP POLICY IF EXISTS "Users can create experiences" ON public.experiences;
CREATE POLICY "Users can create experiences"
  ON public.experiences FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update their household experiences" ON public.experiences;
CREATE POLICY "Users can update their household experiences"
  ON public.experiences FOR UPDATE
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete their household experiences" ON public.experiences;
CREATE POLICY "Users can delete their household experiences"
  ON public.experiences FOR DELETE
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

-- Trigger for updated_at
DROP TRIGGER IF EXISTS update_experiences_updated_at ON public.experiences;
CREATE TRIGGER update_experiences_updated_at
  BEFORE UPDATE ON public.experiences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 2. EXPERIENCE REVIEWS TABLE
-- =====================================================
CREATE TABLE public.experience_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  experience_id UUID NOT NULL REFERENCES public.experiences(id) ON DELETE CASCADE,
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  effort_felt TEXT CHECK (effort_felt IN ('easy', 'moderate', 'hard')),
  cleanup_felt TEXT CHECK (cleanup_felt IN ('easy', 'moderate', 'hard')),
  note TEXT,
  reviewed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for experience queries
CREATE INDEX idx_experience_reviews_experience ON public.experience_reviews(experience_id);
CREATE INDEX idx_experience_reviews_household ON public.experience_reviews(household_id);

-- RLS Policies for experience_reviews
ALTER TABLE public.experience_reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their household reviews" ON public.experience_reviews;
CREATE POLICY "Users can view their household reviews"
  ON public.experience_reviews FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create reviews" ON public.experience_reviews;
CREATE POLICY "Users can create reviews"
  ON public.experience_reviews FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update their reviews" ON public.experience_reviews;
CREATE POLICY "Users can update their reviews"
  ON public.experience_reviews FOR UPDATE
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

-- =====================================================
-- 3. MERRY MOMENTS TABLE
-- =====================================================
CREATE TABLE public.merry_moments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  experience_id UUID REFERENCES public.experiences(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  participant_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
  occurred_at TIMESTAMPTZ NOT NULL,
  place TEXT,
  media_ids JSONB DEFAULT '[]'::jsonb,
  created_by UUID REFERENCES auth.users(id),
  is_manual BOOLEAN DEFAULT false, -- true if manually created (journaling)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for merry_moments
CREATE INDEX idx_merry_moments_household ON public.merry_moments(household_id);
CREATE INDEX idx_merry_moments_experience ON public.merry_moments(experience_id);
CREATE INDEX idx_merry_moments_occurred_at ON public.merry_moments(occurred_at DESC);

-- RLS Policies for merry_moments
ALTER TABLE public.merry_moments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their household moments" ON public.merry_moments;
CREATE POLICY "Users can view their household moments"
  ON public.merry_moments FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create moments" ON public.merry_moments;
CREATE POLICY "Users can create moments"
  ON public.merry_moments FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update their moments" ON public.merry_moments;
CREATE POLICY "Users can update their moments"
  ON public.merry_moments FOR UPDATE
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete their moments" ON public.merry_moments;
CREATE POLICY "Users can delete their moments"
  ON public.merry_moments FOR DELETE
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

-- Trigger for updated_at
DROP TRIGGER IF EXISTS update_merry_moments_updated_at ON public.merry_moments;
CREATE TRIGGER update_merry_moments_updated_at
  BEFORE UPDATE ON public.merry_moments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 4. MEDIA ITEMS TABLE
-- =====================================================
CREATE TABLE public.media_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
  merry_moment_id UUID REFERENCES public.merry_moments(id) ON DELETE CASCADE,
  experience_id UUID REFERENCES public.experiences(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  mime_type TEXT NOT NULL,
  file_size_bytes INTEGER,
  width_px INTEGER,
  height_px INTEGER,
  duration_seconds INTEGER, -- for videos
  caption TEXT,
  uploaded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for media_items
CREATE INDEX idx_media_items_household ON public.media_items(household_id);
CREATE INDEX idx_media_items_moment ON public.media_items(merry_moment_id);
CREATE INDEX idx_media_items_experience ON public.media_items(experience_id);

-- RLS Policies for media_items
ALTER TABLE public.media_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their household media" ON public.media_items;
CREATE POLICY "Users can view their household media"
  ON public.media_items FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can upload media" ON public.media_items;
CREATE POLICY "Users can upload media"
  ON public.media_items FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update their media" ON public.media_items;
CREATE POLICY "Users can update their media"
  ON public.media_items FOR UPDATE
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete their media" ON public.media_items;
CREATE POLICY "Users can delete their media"
  ON public.media_items FOR DELETE
  USING (
    household_id IN (
      SELECT household_id FROM public.family_members
      WHERE user_id = auth.uid()
    )
  );

-- =====================================================
-- 5. ADD COLUMNS TO EXISTING TABLES
-- =====================================================

-- Add last_activity_at to pods for "days since" tracking
ALTER TABLE public.pods
ADD COLUMN IF NOT EXISTS last_activity_at TIMESTAMPTZ;

-- Add last_activity_at to households for "days since" tracking
ALTER TABLE public.households
ADD COLUMN IF NOT EXISTS last_activity_at TIMESTAMPTZ;

-- =====================================================
-- PHASE 4 COMPLETE
-- =====================================================

-- To verify tables were created:
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('experiences', 'experience_reviews', 'merry_moments', 'media_items');

