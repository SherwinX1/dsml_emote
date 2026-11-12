-- ============================================================================
-- DSML EMOTES - NUI (CLIENT)
-- ============================================================================
-- Menu open/close + all RegisterNUICallback handlers. The full emote/
-- scenario/walk-style/shared catalogue is sent once, on open, and the NUI
-- does its own client-side search/category filtering - no per-keystroke
-- round trips.
-- ============================================================================

local menuOpen = false

function MenuIsOpen()
	return menuOpen
end

-- Only the entries this character's gender can play (see IsEmoteForMyGender, client/main.lua) -
-- the game has no female version of some scenarios, so they're hidden instead of doing nothing.
local function forMyGender(list)
	local out = {}
	for _, entry in ipairs(list or {}) do
		if IsEmoteForMyGender(entry) then
			out[#out + 1] = entry
		end
	end
	return out
end

local function buildCatalogue()
	return {
		theme = Config.Theme,
		emotes = forMyGender(Config.Emotes),
		scenarios = Config.EnableScenarios and forMyGender(Config.Scenarios) or {},
		shared = Config.EnableSharedEmotes and Config.SharedEmotes or {},
		walkStyles = Config.WalkStyles,
		walkSpeed = Config.WalkSpeed,
		currentWalkStyle = GetCurrentWalkStyleName(),
		walkSpeedValue = GetWalkSpeedValue(),
		walkSpeedLimitEnabled = IsWalkSpeedLimitEnabled(),
		favoritesEnabled = Config.EnableFavorites,
		recentEnabled = Config.EnableRecent,
		favorites = GetFavoriteList(),
		recent = GetRecentList(),
		playing = CurrentEmoteName
	}
end

function PushFavoritesAndRecent()
	SendNUIMessage({
		action = "updateFavoritesRecent",
		favorites = GetFavoriteList(),
		recent = GetRecentList()
	})
end

function OpenMenu()
	if menuOpen then return end

	menuOpen = true
	SetNuiFocus(true, true)
	SendNUIMessage({ action = "openMenu", data = buildCatalogue() })
	DsmlDebug("Menu opened")
end

function CloseMenu()
	if not menuOpen then return end

	menuOpen = false
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "closeMenu" })

	if Config.StopOnMenuClose then
		StopUsingEmote(false)
	end

	DsmlDebug("Menu closed")
end

-- ----------------------------------------------------------------------------
-- NUI callbacks - every one validates against the server-defined config
-- before doing anything. The NUI can only ever request things that already
-- exist in Config.Emotes/Scenarios/SharedEmotes/WalkStyles; it can't invent
-- new ones.
-- ----------------------------------------------------------------------------

RegisterNUICallback("closeMenu", function(_, cb)
	CloseMenu()
	cb({})
end)

RegisterNUICallback("playEmote", function(data, cb)
	if type(data) == "table" and type(data.name) == "string" and EmotesIndex[data.name] then
		StartEmoteEntry(EmotesIndex[data.name])
	end
	cb({})
end)

RegisterNUICallback("playScenario", function(data, cb)
	if type(data) == "table" and type(data.name) == "string" and ScenariosIndex[data.name] then
		StartEmoteEntry(ScenariosIndex[data.name])
	end
	cb({})
end)

RegisterNUICallback("playShared", function(data, cb)
	if type(data) == "table" and type(data.name) == "string" and Config.EnableSharedEmotes and SharedIndex[data.name] then
		RequestSharedEmote(data.name)
	end
	cb({})
end)

RegisterNUICallback("stopEmote", function(_, cb)
	StopUsingEmote(false)
	cb({})
end)

RegisterNUICallback("toggleFavorite", function(data, cb)
	if type(data) == "table" and type(data.name) == "string" then
		if EmotesIndex[data.name] or ScenariosIndex[data.name] or SharedIndex[data.name] then
			ToggleFavorite(data.name)
			PushFavoritesAndRecent()
		end
	end
	cb({})
end)

RegisterNUICallback("acceptShared", function(_, cb)
	AcceptSharedEmote()
	cb({})
end)

RegisterNUICallback("declineShared", function(_, cb)
	DeclineSharedEmote()
	cb({})
end)

-- ----------------------------------------------------------------------------
-- Walk Animations tab - see client/walkstyle.lua for the actual apply/
-- persist logic; this just validates the NUI's request against the config
-- before handing off to it, same pattern as every other callback above.
-- ----------------------------------------------------------------------------

RegisterNUICallback("setWalkStyle", function(data, cb)
	if type(data) == "table" and type(data.name) == "string" and WalkStylesIndex[data.name] then
		ApplyWalkStyle(data.name)
		SendNUIMessage({ action = "walkStyleState", name = GetCurrentWalkStyleName() })
	end
	cb({})
end)

RegisterNUICallback("setWalkSpeedValue", function(data, cb)
	if type(data) == "table" and type(data.value) == "number" then
		SetWalkSpeedValue(data.value)
	end
	cb({})
end)

RegisterNUICallback("setWalkSpeedLimit", function(data, cb)
	if type(data) == "table" then
		SetWalkSpeedLimitEnabled(data.enabled and true or false)
	end
	cb({})
end)
