-- ============================================================================
-- DSML EMOTES - ANIMATION ENGINE (CLIENT)
-- ============================================================================
-- Adapted from the already-installed kibook/redm-emotes client.lua. Keeps the
-- same proven dict-loading / TaskPlayAnim / prop-attach approach, extended to
-- also support TaskStartScenario entries and to never hard-error on a bad
-- dict/scenario name (logs + notifies + skips instead, per spec section 28).
-- ============================================================================

--- Loads an anim dict (with a bounded wait) and returns true if it loaded.
local function loadAnimDict(dict)
	if not DoesAnimDictExist(dict) then
		return false
	end

	RequestAnimDict(dict)

	local attempts = 0
	while not HasAnimDictLoaded(dict) and attempts < 200 do -- ~2s ceiling, never hangs forever
		Wait(10)
		attempts = attempts + 1
	end

	return HasAnimDictLoaded(dict)
end

--- Plays a { dict, anim, flag } definition on `ped`. Returns true on success.
function PlayAnimation(ped, anim)
	if not anim or not anim.dict or not anim.anim then
		return false -- prop-only entry, nothing to play
	end

	if not loadAnimDict(anim.dict) then
		DsmlError("Animation dictionary could not be loaded: " .. tostring(anim.dict))
		return false
	end

	local flag = anim.flag or 1

	if flag == 1 then
		FreezeEntityPosition(ped, true)
	end

	TaskPlayAnim(ped, anim.dict, anim.anim, 1.0, 1.0, -1, flag, 0.0, false, false, false, "", false)
	RemoveAnimDict(anim.dict)

	DsmlDebug(("Playing: %s / %s"):format(anim.dict, anim.anim))
	return true
end

--- Stops a { dict, anim, flag } definition on `ped`.
function StopAnimation(ped, anim)
	if not anim or not anim.dict or not anim.anim then
		return
	end

	StopAnimTask(ped, anim.dict, anim.anim, 1.0)

	if (anim.flag or 1) == 1 then
		FreezeEntityPosition(ped, false)
	end

	DsmlDebug("Animation stopped")
end

function IsPlayingAnimation(ped, anim)
	if not anim or not anim.dict or not anim.anim then
		return true -- nothing to (re)play, treat as "satisfied"
	end
	-- Same call shape as the already-proven kibook/redm-emotes IsPlayingAnimation()
	return IsEntityPlayingAnim(ped, anim.dict, anim.anim, anim.flag or 1)
end

--- Debug-only: confirms whether a scenario actually took effect.
--- TaskStartScenarioInPlace never errors, even on an invalid/unsupported
--- name, so PlayAnimation-style pcall success alone can't tell us whether
--- anything really happened. IsPedUsingAnyScenario + the raw scenario-hash
--- native below are the exact pattern vorp_admin's client/devTools.lua
--- already uses (already installed on this server) to inspect a ped's live
--- scenario state - reused here read-only, nothing is changed by it.
local function debugCheckScenario(ped, scenario, expectedHash)
	if not Config.Debug then return end

	CreateThread(function()
		Wait(500) -- give the scenario a moment to actually take hold

		local usingOk, using = pcall(IsPedUsingAnyScenario, ped)
		if not usingOk then
			print("[DSML_EMOTES] DEBUG: IsPedUsingAnyScenario check itself failed: " .. tostring(using))
			return
		end

		if not using then
			print(("[DSML_EMOTES] DEBUG: '%s' does NOT appear active ~0.5s after starting it (IsPedUsingAnyScenario = false) - the name is likely wrong, or not usable via in-place playback."):format(scenario))
			return
		end

		local hashOk, activeHash = pcall(Citizen.InvokeNative, 0x569F1E1237508DEB, ped)
		if hashOk then
			print(("[DSML_EMOTES] DEBUG: '%s' IS active - live scenario hash %s (expected %s)"):format(scenario, tostring(activeHash), tostring(expectedHash)))
		else
			print(("[DSML_EMOTES] DEBUG: '%s' is active (IsPedUsingAnyScenario = true), but couldn't read back its hash to confirm which one"):format(scenario))
		end
	end)
end

--- Starts a named RDR2 scenario on `ped`, in place. Never throws on a bad
--- name. RDR3's TaskStartScenarioInPlace expects a hashed scenario name
--- (unlike its GTA V counterpart, which takes the raw string).
---
--- `conditionalAnim` (optional) pins the scenario to one specific "conditional
--- anim" instead of leaving the pick up to the scenario system itself. Most
--- scenario TYPES (e.g. WORLD_HUMAN_LEAN_BACK_WALL) are really an umbrella
--- over several concrete animation variants (male/female, smoking/drinking/
--- idle, ...), normally chosen at random by the game's own AI-condition
--- checks - but some of those conditions are gated to NPCs only (see the
--- comment atop scenario_types_with_conditional_anims.lua: "...this scenario
--- type have possible conditional anim ...SMOKING_MALE_D, but it can not be
--- played by player, because condition is set to NOT be CAIConditionIsPlayer"),
--- so on a player-controlled ped the pick can come back empty/unexpected.
--- Passing an explicit conditionalAnim (via the 7-arg
--- TASK_START_SCENARIO_IN_PLACE_HASH native instead of the plain 4-arg one)
--- sidesteps that entirely - config/scenarios.lua only sets this for entries
--- where that data file lists exactly one valid conditional anim for the
--- scenario type, so there's no risk of forcing a wrong-gender variant.
function PlayScenario(ped, scenario, conditionalAnim)
	if not scenario then return false end

	local hash = GetHashKey(scenario)

	local ok = pcall(function()
		if conditionalAnim then
			-- TASK_START_SCENARIO_IN_PLACE_HASH(ped, scenarioHash, duration,
			-- mustPlayEnterAnim, conditionalAnimHash, unk5, unk6)
			Citizen.InvokeNative(0x524B54361229154F, ped, hash, -1, true, GetHashKey(conditionalAnim), -1.0, 0)
		else
			TaskStartScenarioInPlace(ped, hash, -1, true)
		end
	end)

	if not ok then
		DsmlError("Scenario could not be started: " .. tostring(scenario))
		return false
	end

	DsmlDebug(("Playing scenario: %s%s"):format(scenario, conditionalAnim and (" (conditional anim: " .. conditionalAnim .. ")") or ""))
	debugCheckScenario(ped, scenario, hash)

	-- A pinned variant the game won't run on this ped (e.g. one it gates to NPCs) leaves the
	-- player just standing there - give it a moment, then let the game pick an allowed one.
	if conditionalAnim then
		CreateThread(function()
			Wait(900)
			if CurrentPlaying and CurrentPlaying.scenario == scenario and not IsPedUsingAnyScenario(ped) then
				DsmlDebug(("'%s' didn't start pinned to %s - retrying with the game's own pick"):format(scenario, conditionalAnim))
				TaskStartScenarioInPlace(ped, hash, -1, true)
			end
		end)
	end
	return true
end

function StopScenario(ped)
	-- Scenarios started via TaskStartScenarioInPlace aren't stoppable via
	-- StopAnimTask - ClearPedTasksImmediately is the proven pattern already
	-- used elsewhere on this server (dsml_crafting) for the same native.
	ClearPedTasksImmediately(ped)
end

--- Plays one of RDR2's own built-in "emote wheel" animations (identified by
--- a KIT_EMOTE_* name) on `ped`. This is a separate system from
--- TaskPlayAnim/dict+anim entries - it's the same mechanism the game's own
--- emote wheel uses, which is why entries like the smoking emotes look
--- correct (cigarette/cigar prop included) without us having to attach one
--- ourselves. Confirmed against xakra_animations, already running on this
--- server: TaskEmote(ped, 0, 2, joaat(emoteType), true, true, true, true, true).
function PlayNativeEmote(ped, emoteType)
	if not emoteType then return false end

	local ok = pcall(function()
		ClearPedTasks(ped)
		TaskEmote(ped, 0, 2, joaat(emoteType), true, true, true, true, true)
	end)

	if not ok then
		DsmlError("Native emote could not be started: " .. tostring(emoteType))
		return false
	end

	DsmlDebug("Playing native emote: " .. emoteType)
	return true
end

function StopNativeEmote(ped)
	-- Same native emote system as xakra_animations - it also stops one via
	-- plain ClearPedTasks (not the Immediately variant scenarios need).
	ClearPedTasks(ped)
end

-- ----------------------------------------------------------------------------
-- Props
-- ----------------------------------------------------------------------------

--- Creates and attaches `prop` (see config schema) to `ped`. Returns the
--- created object handle, or nil on failure.
function CreateAndAttachProp(ped, prop)
	if not prop or not prop.model then return nil end

	local model = GetHashKey(prop.model)

	if not IsModelValid(model) then
		DsmlError("Prop model is not valid: " .. tostring(prop.model))
		return nil
	end

	RequestModel(model)
	local attempts = 0
	while not HasModelLoaded(model) and attempts < 200 do
		Wait(10)
		attempts = attempts + 1
	end

	if not HasModelLoaded(model) then
		DsmlError("Prop model failed to load: " .. tostring(prop.model))
		return nil
	end

	local handle = CreateObjectNoOffset(model, 0.0, 0.0, 0.0, true, false, false, false)
	SetModelAsNoLongerNeeded(model)

	if not handle or handle == 0 then
		return nil
	end

	local bone = prop.bone
	if type(bone) == "string" then
		bone = GetEntityBoneIndexByName(ped, bone)
	end

	-- Same call shape as the already-proven kibook/redm-emotes AttachProp():
	-- position/rotation are passed as vector3 values, not flattened floats.
	AttachEntityToEntity(handle, ped, bone, prop.position, prop.rotation, false, false, true, false, 0, true, false, false)

	DsmlDebug("Prop created: " .. prop.model)
	return handle
end

--- Detaches and deletes a previously created prop handle. Safe to call with nil.
function DeleteAttachedProp(handle)
	if not handle or handle == 0 or not DoesEntityExist(handle) then
		return
	end

	DetachEntity(handle, true, true)
	DeleteObject(handle)

	DsmlDebug("Prop deleted")
end
