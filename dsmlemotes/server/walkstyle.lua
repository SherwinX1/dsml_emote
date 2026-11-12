-- ============================================================================
-- DSML EMOTES - WALK ANIMATIONS (SERVER)
-- ============================================================================
-- Reuses the exact `characters.walk` column vorp_walkanim already added to
-- the database on this server (see that resource's sql.sql) - a player's
-- previously-saved walk style keeps working here with zero migration, and
-- picking a new one here stays compatible if vorp_walkanim is used again
-- later. Framework-independent by design: if vorp_core/oxmysql aren't
-- available, walk styles still work for the session, they just don't
-- persist across a relog (same fallback philosophy as favorites/recent in
-- server/persistence.lua).
-- ============================================================================

local function oxmysqlAvailable()
	return GetResourceState("oxmysql") == "started"
end

local function getCore()
	if not Config.UseVorp then return nil end
	if GetResourceState("vorp_core") ~= "started" then return nil end

	local ok, core = pcall(function() return exports.vorp_core:GetCore() end)
	if ok then return core end
	return nil
end

AddEventHandler("vorp:SelectedCharacter", function(source, character)
	if not Config.UseVorp or not oxmysqlAvailable() then return end

	local charIdentifier = character and character.charIdentifier
	if not charIdentifier then return end

	local ok = pcall(function()
		exports.oxmysql:execute(
			"SELECT walk FROM characters WHERE charidentifier = @charidentifier",
			{ charidentifier = charIdentifier },
			function(result)
				if result and result[1] and result[1].walk and result[1].walk ~= "noanim" then
					TriggerClientEvent("dsmlemotes:syncWalkStyle", source, result[1].walk)
				end
			end
		)
	end)

	if not ok then
		print("[DSML_EMOTES] WARNING: could not read saved walk style (characters.walk) - is the `walk` column missing? See vorp_walkanim's sql.sql.")
	end
end)

RegisterNetEvent("dsmlemotes:saveWalkStyle", function(clipsetOrNoanim)
	local source = source
	if not Config.UseVorp or not oxmysqlAvailable() then return end
	if type(clipsetOrNoanim) ~= "string" or #clipsetOrNoanim > 50 then return end

	local core = getCore()
	if not core then return end

	local ok, user = pcall(function() return core.getUser(source) end)
	if not ok or not user then return end

	local character = user.getUsedCharacter
	if not character then return end

	pcall(function()
		exports.oxmysql:execute(
			"UPDATE characters SET walk = @walk WHERE charidentifier = @charidentifier",
			{ walk = clipsetOrNoanim, charidentifier = character.charIdentifier }
		)
	end)
end)
