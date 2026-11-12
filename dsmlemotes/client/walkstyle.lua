-- ============================================================================
-- DSML EMOTES - WALK ANIMATIONS (CLIENT)
-- ============================================================================
-- See config/walkstyles.lua for where the style list/native hashes/speed
-- bounds come from. This module owns two independent pieces of state:
--   1. The applied movement clipset ("walk style") - a single native call,
--      persists on its own until changed, synced/saved through VORP if
--      available (see server/walkstyle.lua).
--   2. The walk-speed limiter - SetPedMaxMoveBlendRatio gets overridden by
--      lots of other game systems every frame, so (exactly like
--      vorp_walkanim's own /walkSlow command) enforcing a cap requires a
--      bounded while-enabled thread re-applying it continuously, not a
--      single call.
-- ============================================================================

local currentWalkClipset = nil  -- clipset currently applied via the native, or nil (Default)
local currentWalkStyleName = "default"

local walkSpeedLimitEnabled = false
local walkSpeedValue = Config.WalkSpeed and Config.WalkSpeed.default or 1.0
local walkSpeedToken = 0 -- bumped on every enable/disable so only the latest thread loops

--- Applies (or clears, if styleName == "default"/nil) a walk style by name.
--- Safe to call with an unknown name (no-op).
function ApplyWalkStyle(styleName)
	local style = styleName and WalkStylesIndex[styleName]
	if styleName and not style then
		DsmlDebug("Unknown walk style: " .. tostring(styleName))
		return false
	end

	local ped = PlayerPedId()

	if currentWalkClipset then
		Citizen.InvokeNative(0xA6F67BEC53379A32, ped, currentWalkClipset) -- RESET_PED_MOVEMENT_CLIPSET
	end

	local newClipset = style and style.clipset or nil
	if newClipset then
		Citizen.InvokeNative(0xCB9401F918CB0F75, ped, newClipset, 1, -1) -- SET_PED_MOVEMENT_CLIPSET
	end

	currentWalkClipset = newClipset
	currentWalkStyleName = (style and style.name) or "default"

	DsmlDebug("Walk style set: " .. currentWalkStyleName)

	if VorpAvailable then
		TriggerServerEvent("dsmlemotes:saveWalkStyle", newClipset or "noanim")
	end

	return true
end

function GetCurrentWalkStyleName()
	return currentWalkStyleName
end

--- Re-applies the current clipset without touching persistence - used only
--- to restore state after a resource restart's automatic sync from the
--- server (see the RegisterNetEvent below), never called directly by the
--- menu (which should go through ApplyWalkStyle so it also saves).
local function restoreWalkClipset(clipset)
	local ped = PlayerPedId()
	if clipset and clipset ~= "noanim" then
		Citizen.InvokeNative(0xCB9401F918CB0F75, ped, clipset, 1, -1)
		currentWalkClipset = clipset
		for _, style in ipairs(Config.WalkStyles) do
			if style.clipset == clipset then
				currentWalkStyleName = style.name
				break
			end
		end
	end
end

RegisterNetEvent("dsmlemotes:syncWalkStyle", function(clipset)
	restoreWalkClipset(clipset)
end)

-- ----------------------------------------------------------------------------
-- Walk speed limiter
-- ----------------------------------------------------------------------------

function GetWalkSpeedValue()
	return walkSpeedValue
end

function IsWalkSpeedLimitEnabled()
	return walkSpeedLimitEnabled
end

--- Sets the slider value used by the speed limiter. Takes effect immediately
--- if the limiter is currently enabled.
function SetWalkSpeedValue(value)
	local bounds = Config.WalkSpeed or { min = 0.1, max = 3.0 }
	value = math.max(bounds.min or 0.1, math.min(bounds.max or 3.0, tonumber(value) or walkSpeedValue))
	walkSpeedValue = value
end

--- Enables/disables the walk-speed cap. When enabling, starts a bounded
--- thread (tokened, same pattern as client/safety.lua's watchLoop) that
--- keeps re-applying SetPedMaxMoveBlendRatio every tick for as long as the
--- limiter stays enabled; disabling restores the game's normal run cap.
function SetWalkSpeedLimitEnabled(enabled)
	walkSpeedLimitEnabled = enabled and true or false
	walkSpeedToken = walkSpeedToken + 1
	local myToken = walkSpeedToken

	if not walkSpeedLimitEnabled then
		SetPedMaxMoveBlendRatio(PlayerPedId(), 3.0)
		return
	end

	CreateThread(function()
		while walkSpeedLimitEnabled and walkSpeedToken == myToken do
			SetPedMaxMoveBlendRatio(PlayerPedId(), walkSpeedValue)
			Wait(0)
		end
	end)
end

AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then return end
	if walkSpeedLimitEnabled then
		SetPedMaxMoveBlendRatio(PlayerPedId(), 3.0)
	end
end)
