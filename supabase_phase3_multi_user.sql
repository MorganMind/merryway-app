-- ============================================
-- Phase 3: Multi-User Identity & Consent
-- ============================================

-- Add user_id to family_members (nullable - not all members have their own auth account)
ALTER TABLE family_members 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS device_pin VARCHAR(6),
ADD COLUMN IF NOT EXISTS pin_required BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS avatar_emoji VARCHAR(10);

-- Add family_mode to households (parents can enable user switcher)
ALTER TABLE households
ADD COLUMN IF NOT EXISTS family_mode_enabled BOOLEAN DEFAULT FALSE;

-- Create index for user_id lookups
CREATE INDEX IF NOT EXISTS idx_family_members_user_id ON family_members(user_id);

-- ============================================
-- Consent Scopes (predefined capabilities)
-- ============================================
CREATE TABLE IF NOT EXISTS consent_scopes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    default_allowed BOOLEAN DEFAULT FALSE,
    child_allowed BOOLEAN DEFAULT TRUE,
    parent_only BOOLEAN DEFAULT FALSE,
    has_limits BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed default consent scopes
INSERT INTO consent_scopes (key, name, description, default_allowed, child_allowed, parent_only, has_limits)
VALUES
    ('location_coarse', 'Neighborhood Location', 'Share general location with family', TRUE, TRUE, FALSE, FALSE),
    ('location_fine', 'Precise Location', 'Share exact GPS location', FALSE, FALSE, TRUE, FALSE),
    ('media_upload', 'Upload Photos', 'Upload and share photos with family', TRUE, TRUE, FALSE, FALSE),
    ('media_view', 'View Media', 'View household photos and media', TRUE, TRUE, FALSE, FALSE),
    ('create_experience', 'Create Activities', 'Create and plan shared activities', FALSE, FALSE, TRUE, FALSE),
    ('cost_approved', 'Paid Activities', 'Participate in activities with costs', FALSE, TRUE, FALSE, TRUE),
    ('cost_initiate', 'Suggest Paid Activities', 'Can suggest paid activities to family', FALSE, FALSE, TRUE, FALSE),
    ('invite_others', 'Invite Friends', 'Invite non-household members to activities', FALSE, FALSE, TRUE, FALSE),
    ('account_create', 'Create Accounts', 'Create new household member accounts', FALSE, FALSE, TRUE, FALSE)
ON CONFLICT (key) DO NOTHING;

-- ============================================
-- Member Consents (per-member permissions)
-- ============================================
CREATE TABLE IF NOT EXISTS member_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
    scope_key TEXT NOT NULL REFERENCES consent_scopes(key),
    allowed BOOLEAN DEFAULT FALSE,
    limits JSONB DEFAULT NULL,  -- {cost_usd: 20, time_minutes: 60, etc}
    expires_at TIMESTAMP WITH TIME ZONE,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(member_id, scope_key)
);

CREATE INDEX IF NOT EXISTS idx_member_consents_member ON member_consents(member_id);
CREATE INDEX IF NOT EXISTS idx_member_consents_scope ON member_consents(scope_key);

-- ============================================
-- Household Norms (household-wide rules)
-- ============================================
CREATE TABLE IF NOT EXISTS household_norms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL UNIQUE REFERENCES households(id) ON DELETE CASCADE,
    quiet_hours_start TEXT,  -- "HH:MM" format
    quiet_hours_end TEXT,
    bedtime_window_start TEXT,
    bedtime_window_end TEXT,
    travel_limit_km FLOAT,
    travel_limit_duration_minutes INT,
    max_cost_per_activity_usd FLOAT,
    max_cost_per_week_usd FLOAT,
    outdoor_after_dark_allowed BOOLEAN DEFAULT TRUE,
    max_daily_screen_time_minutes INT,
    approved_activity_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    blocked_activity_tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    require_parent_approval_for TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- Policy Logs (audit trail)
-- ============================================
CREATE TABLE IF NOT EXISTS policy_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    participant_ids UUID[] DEFAULT ARRAY[]::UUID[],
    action TEXT NOT NULL,
    action_context JSONB DEFAULT '{}'::JSONB,
    allowed BOOLEAN DEFAULT TRUE,
    reason TEXT,
    blocked_by TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_policy_logs_household ON policy_logs(household_id);
CREATE INDEX IF NOT EXISTS idx_policy_logs_timestamp ON policy_logs(timestamp DESC);

-- ============================================
-- RLS Policies
-- ============================================

-- Consent Scopes (public read-only)
ALTER TABLE consent_scopes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view consent scopes" ON consent_scopes;
CREATE POLICY "Anyone can view consent scopes"
    ON consent_scopes FOR SELECT
    USING (true);

-- Member Consents
ALTER TABLE member_consents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Household members can view member consents" ON member_consents;
CREATE POLICY "Household members can view member consents"
    ON member_consents FOR SELECT
    USING (
        member_id IN (
            SELECT fm.id FROM family_members fm
            JOIN households h ON fm.household_id = h.id
            WHERE h.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Household owners can manage member consents" ON member_consents;
CREATE POLICY "Household owners can manage member consents"
    ON member_consents FOR ALL
    USING (
        member_id IN (
            SELECT fm.id FROM family_members fm
            JOIN households h ON fm.household_id = h.id
            WHERE h.user_id = auth.uid()
        )
    );

-- Household Norms
ALTER TABLE household_norms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Household owners can view norms" ON household_norms;
CREATE POLICY "Household owners can view norms"
    ON household_norms FOR SELECT
    USING (
        household_id IN (
            SELECT id FROM households WHERE user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Household owners can manage norms" ON household_norms;
CREATE POLICY "Household owners can manage norms"
    ON household_norms FOR ALL
    USING (
        household_id IN (
            SELECT id FROM households WHERE user_id = auth.uid()
        )
    );

-- Policy Logs
ALTER TABLE policy_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Household owners can view policy logs" ON policy_logs;
CREATE POLICY "Household owners can view policy logs"
    ON policy_logs FOR SELECT
    USING (
        household_id IN (
            SELECT id FROM households WHERE user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Household owners can insert policy logs" ON policy_logs;
CREATE POLICY "Household owners can insert policy logs"
    ON policy_logs FOR INSERT
    WITH CHECK (
        household_id IN (
            SELECT id FROM households WHERE user_id = auth.uid()
        )
    );

-- ============================================
-- Helper Functions
-- ============================================

-- Function to get current member ID
-- Returns either: user's linked member ID, or active switcher member ID
CREATE OR REPLACE FUNCTION get_current_member_id()
RETURNS UUID AS $$
DECLARE
    member_id UUID;
BEGIN
    -- First try to get member linked to current auth user
    SELECT id INTO member_id
    FROM family_members
    WHERE user_id = auth.uid()
    LIMIT 1;
    
    -- If found, return it
    IF member_id IS NOT NULL THEN
        RETURN member_id;
    END IF;
    
    -- Otherwise, return NULL (app will use switcher selection)
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to member_consents
DROP TRIGGER IF EXISTS update_member_consents_updated_at ON member_consents;
CREATE TRIGGER update_member_consents_updated_at
    BEFORE UPDATE ON member_consents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply updated_at trigger to household_norms
DROP TRIGGER IF EXISTS update_household_norms_updated_at ON household_norms;
CREATE TRIGGER update_household_norms_updated_at
    BEFORE UPDATE ON household_norms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Summary
-- ============================================
-- ✓ family_members.user_id: Links Supabase auth to member (nullable)
-- ✓ family_members.device_pin: Optional PIN for switcher
-- ✓ family_members.pin_required: Whether PIN is required
-- ✓ family_members.avatar_emoji: Profile emoji
-- ✓ households.family_mode_enabled: Parent can enable user switcher
-- ✓ consent_scopes: Predefined capabilities (seeded)
-- ✓ member_consents: Per-member permissions
-- ✓ household_norms: Household-wide rules
-- ✓ policy_logs: Audit trail
-- ✓ RLS policies: Secure access control
-- ✓ Helper functions: get_current_member_id()

