-- ============================================================================
-- DSML EMOTES - VORP INTEGRATION (SERVER)
-- ============================================================================
-- Resolves a player's current job through vorp_core, for the optional
-- `restricted = { jobs = {...} }` config field. Returns nil (unrestricted-
-- safe) if VORP isn't running or the player has no character loaded yet.
-- ============================================================================

local function getCore()
	if not Config.UseVorp then return nil end
	if GetResourceState("vorp_core") ~= "started" then return nil end

	local ok, core = pcall(function()
		return exports.vorp_core:GetCore()
	end)

	if ok then return core end
	return nil
end

function GetPlayerJobServer(source)
	local core = getCore()
	if not core then return nil end

	local ok, user = pcall(function() return core.getUser(source) end)
	if not ok or not user then return nil end

	local character = user.getUsedCharacter
	if not character then return nil end

	return character.job
end

RegisterNetEvent("dsmlemotes:requestJob", function()
	local source = source
	TriggerClientEvent("dsmlemotes:syncJob", source, GetPlayerJobServer(source))
end)
