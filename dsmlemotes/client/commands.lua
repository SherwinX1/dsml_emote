-- ============================================================================
-- DSML EMOTES - COMMANDS / KEYBIND (CLIENT)
-- ============================================================================
-- F5 (Config.MenuKeybind, rebindable in RedM's Key Bindings settings) toggles
-- the menu. /stop always stops whatever is playing. Every emote/scenario
-- also gets its own direct command (e.g. /smoke) when
-- Config.EnablePerEmoteCommands is true - see config/config.lua.
-- ============================================================================

RegisterCommand("dsmlemotes:togglemenu", function()
	if MenuIsOpen() then
		CloseMenu()
	else
		OpenMenu()
	end
end, false)

RegisterKeyMapping("dsmlemotes:togglemenu", "Open/close the DSML emote menu", "keyboard", Config.MenuKeybind)

RegisterCommand(Config.StopCommand, function()
	StopUsingEmote(false)
end, false)

CreateThread(function()
	TriggerEvent("chat:addSuggestion", "/" .. Config.StopCommand, "Stop the current animation and clean up")

	if not Config.EnablePerEmoteCommands then
		return
	end

	-- One direct command per emote/scenario, named after its `name` field.
	-- Skips anything that collides with an already-registered command name
	-- (e.g. the stop command, or a duplicate between the two lists) instead
	-- of silently overwriting it.
	local taken = { [Config.StopCommand] = true, ["dsmlemotes:togglemenu"] = true }

	local function registerDirect(entry)
		if taken[entry.name] then
			DsmlDebug("Skipped direct command /" .. entry.name .. " - name already taken")
			return
		end
		taken[entry.name] = true

		RegisterCommand(entry.name, function()
			StartEmote(entry.name)
		end, false)
	end

	for _, entry in ipairs(Config.Emotes) do
		registerDirect(entry)
	end

	for _, entry in ipairs(Config.Scenarios) do
		registerDirect(entry)
	end

	DsmlDebug(("Registered %d direct emote/scenario commands"):format((function()
		local n = 0
		for k in pairs(taken) do n = n + 1 end
		return n - 2 -- exclude the two reserved names counted above
	end)()))
end)
