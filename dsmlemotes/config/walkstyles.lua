-- ============================================================================
-- DSML EMOTES - WALK ANIMATIONS (WALK STYLES)
-- ============================================================================
-- Ported from vorp_walkanim (already installed on this server) - same
-- MP_Style_* movement clipset names, same two natives:
--   SET_PED_MOVEMENT_CLIPSET   (hash 0xCB9401F918CB0F75) - applies a style
--   RESET_PED_MOVEMENT_CLIPSET (hash 0xA6F67BEC53379A32) - removes one
-- These aren't TaskPlayAnim-based, so there's no dict streaming involved and
-- nothing for client/animation.lua's engine to do - see client/walkstyle.lua.
-- "Default" (clipset = nil) is the reset/no-override case - vorp_walkanim's
-- own menu called this "RemoveWalk".
--
-- Also see server/walkstyle.lua: the chosen style is persisted to the same
-- `characters.walk` column vorp_walkanim already added to the database (via
-- oxmysql), so a player's existing saved walk style keeps working exactly as
-- before even if vorp_walkanim is later stopped in favour of this menu.
-- ============================================================================

Config.WalkStyles = {
	{ name = "default",     label = "Default",     clipset = nil },
	{ name = "casual",      label = "Casual",      clipset = "MP_Style_Casual" },
	{ name = "crazy",       label = "Crazy",       clipset = "MP_Style_Crazy" },
	{ name = "drunk",       label = "Drunk",       clipset = "MP_Style_drunk" },
	{ name = "easyrider",   label = "EasyRider",   clipset = "MP_Style_EasyRider" },
	{ name = "flamboyant",  label = "Flamboyant",  clipset = "MP_Style_Flamboyant" },
	{ name = "greenhorn",   label = "Greenhorn",   clipset = "MP_Style_Greenhorn" },
	{ name = "gunslinger",  label = "Gunslinger",  clipset = "MP_Style_Gunslinger" },
	{ name = "inquisitive", label = "Inquisitive", clipset = "MP_Style_inquisitive" },
	{ name = "refined",     label = "Refined",     clipset = "MP_Style_Refined" },
	{ name = "silenttype",  label = "SilentType",  clipset = "MP_Style_SilentType" },
	{ name = "veteran",     label = "Veteran",     clipset = "MP_Style_Veteran" },
}

-- Walk-speed slider bounds/default (see client/walkstyle.lua's "Limit walk
-- speed" toggle + slider) - matches vorp_walkanim's own /walkSlow command,
-- which accepted values from just above 0 up to 3.0 (its own hard cap).
Config.WalkSpeed = {
	min = 0.1,
	max = 3.0,
	step = 0.1,
	default = 1.0,
}

WalkStylesIndex = {}
for _, entry in ipairs(Config.WalkStyles) do
	WalkStylesIndex[entry.name] = entry
end
