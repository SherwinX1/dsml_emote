-- ============================================================================
-- DSML EMOTES - VORP INTEGRATION (CLIENT)
-- ============================================================================
-- The animation engine never requires VORP. This module only adds optional
-- niceties (nicer notifications, job-based menu filtering) when vorp_core is
-- actually running. Everything falls back gracefully if it is not.
-- ============================================================================

VorpAvailable = false
local playerJob = nil

CreateThread(function()
	if not Config.UseVorp then return end

	local ok = pcall(function()
		return exports.vorp_core:GetCore()
	end)

	VorpAvailable = ok and GetResourceState("vorp_core") == "started"

	if VorpAvailable then
		DsmlDebug("VORP core detected - notifications and job restrictions enabled")
		TriggerServerEvent("dsmlemotes:requestJob")
	else
		DsmlDebug("VORP core not available - running framework-independent")
	end
end)

RegisterNetEvent("dsmlemotes:syncJob", function(job)
	playerJob = job
end)

--- Returns the player's current job name, or nil if unknown/VORP unavailable.
function GetPlayerJob()
	return playerJob
end

--- Shows a notification via VORP if available, otherwise a simple on-screen tip.
function DsmlNotify(text, duration)
	duration = duration or 4000

	if VorpAvailable then
		local ok = pcall(function()
			exports.vorp_core:DisplayTip(text, duration)
		end)
		if ok then return end
	end

	ShowFallbackNotification(text, duration)
end
