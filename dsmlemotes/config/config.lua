Config = {}

-- ============================================================================
-- DSML EMOTES - CORE CONFIGURATION
-- ============================================================================

-- Set to true to print [DSML_EMOTES] debug lines to the server/client console.
Config.Debug = false

-- ----------------------------------------------------------------------------
-- Commands / keybind
-- ----------------------------------------------------------------------------
-- F5 (rebindable in RedM's own Key Bindings settings) toggles the menu open
-- and closed - see client/commands.lua.
Config.MenuKeybind = "F5"

-- /stop always stops whatever is currently playing. This is the only
-- "stop" command registered - no /stopemote alias.
Config.StopCommand = "stop"

-- If true, every entry in Config.Emotes/Config.Scenarios also gets its own
-- direct chat command named after its `name` (e.g. "smoke" -> /smoke),
-- so players don't have to open the menu for emotes they already know.
-- Shared (partner) emotes are never given direct commands - they need the
-- accept/decline flow, which only the menu (or a nearby-player pick)
-- provides.
Config.EnablePerEmoteCommands = true

-- ----------------------------------------------------------------------------
-- Feature toggles
-- ----------------------------------------------------------------------------
-- The menu only shows 3 tabs by default: Emote (solo animations +
-- scenarios), Dance, and Shared. Favorites/Recent are off by default to
-- keep the menu simple - flip either to true and its tab reappears
-- automatically, no other changes needed.
Config.EnableFavorites = false
Config.EnableRecent = false
Config.EnableSharedEmotes = true
Config.EnableProps = true
Config.EnableScenarios = true -- scenarios are folded into the "Emote" tab, not a separate one

-- Maximum number of entries kept in the "Recent" list per player.
Config.MaxRecent = 15

-- ----------------------------------------------------------------------------
-- Shared (partner) emotes
-- ----------------------------------------------------------------------------
-- Maximum distance (in game units/metres) allowed between the two players
-- while a shared emote is active. Exceeding it cancels the shared emote.
Config.SharedEmoteDistance = 3.0

-- How long (in seconds) a shared emote request stays valid before it
-- automatically expires if the target does not respond.
Config.SharedEmoteTimeout = 10

-- ----------------------------------------------------------------------------
-- Menu behaviour
-- ----------------------------------------------------------------------------
-- Closing the NUI with ESC does NOT stop the current animation by default.
Config.StopOnMenuClose = false

-- ----------------------------------------------------------------------------
-- Restrictions
-- ----------------------------------------------------------------------------
-- Global defaults - individual emotes can still opt in via allowWeapon /
-- allowCombat on the entry itself (see config/emotes.lua).
Config.AllowInCombat = false
Config.AllowWithWeapon = false
Config.AllowInVehicle = false

-- ----------------------------------------------------------------------------
-- Persistence (favorites / recent)
-- ----------------------------------------------------------------------------
-- "file" - stored server-side as JSON under data/<identifier>.json using
--          SaveResourceFile/LoadResourceFile. No database required.
-- "none" - favorites/recent only live for the current session (not saved).
Config.Persistence = "file"

-- ----------------------------------------------------------------------------
-- VORP
-- ----------------------------------------------------------------------------
-- If true, the resource will look for a running vorp_core and, when found,
-- use it for notifications and job-based restrictions. The animation engine
-- itself never requires VORP - this only enables extra integration.
Config.UseVorp = true

-- ----------------------------------------------------------------------------
-- Theme - the menu now uses the same monochrome look as dsml_crafting (ui-src/src/styles.css);
-- these values are still sent to the NUI on open but no longer change its colours.
-- ----------------------------------------------------------------------------
Config.Theme = {
	primary = "#ffffff",
	background = "#0a0a0a",
	panel = "#0a0a0a",
	text = "#ffffff"
}
