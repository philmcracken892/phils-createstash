Config = {}



Config.AdminGroups = {
    'admin',
    'god',
    'mod'
   
}

-- ============================================
-- PROMPT SETTINGS
-- ============================================
Config.PromptKey = 0x760A9C6F -- G key hash

-- ============================================
-- STASH SETTINGS
-- ============================================
Config.Command = 'sc'
Config.DefaultSlots = 50
Config.DefaultWeight = 100000

-- ============================================
-- BLIP SETTINGS
-- ============================================
Config.ShowBlips = true
Config.BlipSprite = -1138864184  -- Default blip sprite (integer format)
Config.BlipScale = 0.2
Config.BlipColor = 'BLIP_MODIFIER_MP_COLOR_4'  -- Optional: 'BLIP_MODIFIER_MP_COLOR_1' etc. (set to nil for default)


-- Blip Color Modifiers (use with BlipAddModifier):
-- 'BLIP_MODIFIER_MP_COLOR_1'  = Red
-- 'BLIP_MODIFIER_MP_COLOR_2'  = Green
-- 'BLIP_MODIFIER_MP_COLOR_3'  = Blue
-- 'BLIP_MODIFIER_MP_COLOR_4'  = Yellow
-- 'BLIP_MODIFIER_MP_COLOR_5'  = Orange
-- 'BLIP_MODIFIER_MP_COLOR_6'  = Pink
-- 'BLIP_MODIFIER_MP_COLOR_7'  = Purple
-- 'BLIP_MODIFIER_MP_COLOR_8'  = Cyan

-- Interaction settings
Config.InteractionDistance = 4.0

-- Visual marker when creating stash
Config.MarkerEnabled = true
Config.MarkerColor = {r = 0, g = 255, b = 0, a = 150}

-- ============================================
-- STASH TYPES
-- ============================================
Config.StashTypes = {
    {label = 'Standard Stash', value = 'stash'},
    {label = 'Personal Stash', value = 'personal'},
    {label = 'Gang Stash', value = 'gang'},
    {label = 'Job Stash', value = 'job'},
    
}

-- ============================================
-- JOBS & GANGS
-- ============================================
Config.Jobs = {
    {label = 'Sheriff', value = 'vallaw'},
    {label = 'Doctor', value = 'medic'},
    
}

Config.Gangs = {
    {label = 'Van Der Linde', value = 'vanderlinde'},
    {label = "O'Driscoll", value = 'odriscoll'},
    {label = 'Lemoyne Raiders', value = 'lemoyne'},
}