-- ============================================================================
-- DSML EMOTES - CORE (SERVER)
-- ============================================================================

CreateThread(function()
	print(("[DSML_EMOTES] Loaded - %d emotes, %d scenarios, %d walk styles, %d shared emotes"):format(
		#Config.Emotes, #Config.Scenarios, #Config.WalkStyles, #Config.SharedEmotes
	))
end)

-- Every connected client cleans itself up on its own onResourceStop handler
-- (client/main.lua). This just makes sure nothing is left waiting on the
-- server side either.
AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end

	TriggerClientEvent("dsmlemotes:sharedCancelled", -1)
end)
