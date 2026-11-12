-- ============================================================================
-- DSML EMOTES - CORE (CLIENT)
-- ============================================================================
-- Single source of truth for "what is currently playing" and the one
-- teardown function (StopUsingEmote) every safety/cleanup path funnels into.
-- ============================================================================

CurrentPlaying = nil   -- full internal play-state table, or nil
CurrentEmoteName = nil -- convenience alias: name of whatever is playing, or nil

-- ----------------------------------------------------------------------------
-- Debug / notifications
-- ----------------------------------------------------------------------------

function DsmlDebug(msg)
	if Config.Debug then
		print(("[DSML_EMOTES] %s"):format(msg))
	end
end

function DsmlError(msg)
	print(("[DSML_EMOTES] ERROR: %s"):format(msg))
	DsmlNotify("Animation unavailable.")
end

--- Minimal on-screen text fallback used when vorp_core isn't available.
--- Bounded to `duration` - never a permanent thread.
function ShowFallbackNotification(text, duration)
	CreateThread(function()
		local endTime = GetGameTimer() + (duration or 4000)
		while GetGameTimer() < endTime do
			SetTextScale(0.35, 0.35)
			SetTextColor(241, 241, 241, 255)
			SetTextCentre(true)
			SetTextDropshadow(1, 0, 0, 0, 200)
			SetTextFontForCurrentCommand(0)
			DisplayText(CreateVarString(10, "LITERAL_STRING", text), 0.5, 0.9)
			Wait(0)
		end
	end)
end

-- ----------------------------------------------------------------------------
-- Playback
-- ----------------------------------------------------------------------------

local function isJobAllowed(entry)
	if not entry.restricted or entry.restricted == false then
		return true
	end

	local job = GetPlayerJob()
	if not job then
		return false
	end

	for _, allowedJob in ipairs(entry.restricted.jobs or {}) do
		if allowedJob == job then
			return true
		end
	end

	return false
end

-- PlayAnimation/CreateAndAttachProp both contain bounded Wait() loops
-- (dict/model streaming), so beginPlaying() can yield mid-call. If a second
-- emote is requested (double-click, a slash command spammed twice, clicking
-- another row) before the first has finished loading, CurrentPlaying is
-- still nil at that point - the "stop whatever's currently playing" guard
-- below has nothing to stop, and whichever call finishes LAST silently
-- overwrites CurrentPlaying, orphaning the other one's FreezeEntityPosition
-- with nothing left tracking it to undo. That's exactly a "stuck frozen,
-- wrong/glitchy animation" bug report. playToken closes that race: only the
-- most recent beginPlaying() call is allowed to commit its state; a call
-- that finds itself superseded cleans up after itself (unfreezes/deletes
-- its own prop) and bails instead of touching global state.
local playToken = 0

-- Name of whatever beginPlaying() is CURRENTLY mid-load for (dict/prop
-- streaming), or nil once it's settled one way or another. A duplicate
-- request for that same name - a double-click before the NUI got its
-- confirmation back, or the same /name command typed twice fast - used to
-- tear down and restart the first attempt via the playToken supersede
-- path below, which looks exactly like the emote starting and then
-- immediately stopping itself. The NUI now also debounces this
-- client-side (see html/js/app.js), but the per-emote slash commands
-- bypass the NUI entirely, so this check is the one place that covers
-- every trigger path.
local loadingName = nil

local function beginPlaying(playing)
	if loadingName == playing.name or (CurrentPlaying and CurrentPlaying.name == playing.name) then
		DsmlDebug("Ignoring duplicate play request for: " .. playing.name)
		return false
	end

	if CurrentPlaying then
		StopUsingEmote(true)
	end

	playToken = playToken + 1
	local myToken = playToken
	loadingName = playing.name

	local ped = PlayerPedId()
	local started

	if playing.kind == "scenario" then
		started = PlayScenario(ped, playing.scenario, playing.conditionalAnim)
	elseif playing.kind == "nativeEmote" then
		started = PlayNativeEmote(ped, playing.emoteType)
	elseif playing.dict and playing.anim then
		started = PlayAnimation(ped, { dict = playing.dict, anim = playing.anim, flag = playing.flag })
	else
		started = true -- prop-only entry, nothing to animate
	end

	if playing.prop and Config.EnableProps and myToken == playToken then
		playing.propHandle = CreateAndAttachProp(ped, playing.prop)
	end

	if myToken ~= playToken then
		-- Superseded while we were loading - undo whatever we just did and
		-- let the newer call own CurrentPlaying instead. Only the "anim"
		-- case needs an explicit undo (StopAnimTask targets that exact
		-- dict+anim, so it can't touch whatever the winner started) - it's
		-- also the only case that can leave the player frozen
		-- (FreezeEntityPosition, flag == 1). A superseded scenario or
		-- native emote is left alone: neither freezes via our code, and
		-- starting any new task naturally replaces it, so there's nothing
		-- that needs undoing - and their "stop" natives
		-- (ClearPedTasksImmediately / ClearPedTasks) would risk wiping out
		-- whatever the winning call just started.
		if started and playing.kind == "anim" and playing.dict and playing.anim then
			StopAnimation(ped, { dict = playing.dict, anim = playing.anim, flag = playing.flag })
		end
		if playing.propHandle then
			DeleteAttachedProp(playing.propHandle)
		end
		if loadingName == playing.name then
			loadingName = nil
		end
		return false
	end

	if not started and not playing.propHandle then
		if loadingName == playing.name then
			loadingName = nil
		end
		return false
	end

	if loadingName == playing.name then
		loadingName = nil
	end

	CurrentPlaying = playing
	CurrentEmoteName = playing.name

	StartSafetyWatch(playing)

	SendNUIMessage({ action = "playingState", playing = true, name = playing.name, label = playing.label })
	AddRecent(playing.name)

	return true
end

--- Looks up `name` in the Emotes or Scenarios config and plays it.
function StartEmote(name)
	local entry = EmotesIndex[name]
	if entry then
		StartEmoteEntry(entry)
		return
	end

	entry = ScenariosIndex[name]
	if entry then
		StartEmoteEntry(entry)
		return
	end

	DsmlError("Unknown emote or scenario: " .. tostring(name))
end

--- Plays a resolved config entry. `animOverride` (used for shared emotes) is
--- an optional { anim = { dict, anim, flag } } that takes priority over the
--- entry's own dict/anim/scenario fields. `partnerId` marks this as one half
--- of an active shared emote.
--- Whether an entry can be used by this character's gender (`gender = "male"` /
--- `"female"` in the config = only that gender; the game has no version for the other).
function IsEmoteForMyGender(entry)
	if not entry.gender then return true end
	return entry.gender == (IsPedMale(PlayerPedId()) and "male" or "female")
end

function StartEmoteEntry(entry, animOverride, partnerId)
	if not isJobAllowed(entry) then
		DsmlNotify("You are not permitted to use that.")
		return
	end

	if not IsEmoteForMyGender(entry) then
		DsmlNotify("That emote isn't available for your character.")
		return
	end

	local isMale = IsPedMale(PlayerPedId())
	-- the other gender's version of an anim, when the config has one (maleAnim / femaleAnim)
	local genderAnim = isMale and entry.maleAnim or (not isMale and entry.femaleAnim) or nil

	local playing = {
		name = entry.name, label = entry.label, prop = Config.EnableProps and entry.prop or nil,
		allowWeapon = entry.allowWeapon, allowCombat = entry.allowCombat,
		partnerId = partnerId
	}

	if animOverride and animOverride.anim then
		playing.kind = "anim"
		playing.dict = animOverride.anim.dict
		playing.anim = animOverride.anim.anim
		playing.flag = animOverride.anim.flag
	elseif genderAnim and genderAnim.dict and genderAnim.anim then
		playing.kind = "anim"
		playing.dict = genderAnim.dict
		playing.anim = genderAnim.anim
		playing.flag = genderAnim.flag
	elseif entry.type == "scenario" then
		playing.kind = "scenario"
		playing.scenario = entry.scenario
		-- the variant for this character's gender (conditionalAnim = male, conditionalAnimFemale = female)
		if isMale then
			playing.conditionalAnim = entry.conditionalAnim
		else
			playing.conditionalAnim = entry.conditionalAnimFemale
		end
	elseif entry.type == "nativeEmote" then
		playing.kind = "nativeEmote"
		playing.emoteType = entry.emoteType
	else
		playing.kind = "anim"
		playing.dict = entry.dict
		playing.anim = entry.anim
		playing.flag = entry.flag
	end

	beginPlaying(playing)
end

--- The single teardown path. Called by /stop, menu "stop", death, vehicle
--- entry, weapon draw, resource stop, and shared-emote cancellation.
--- `silent` suppresses the "stopped" debug line (used by safety triggers).
function StopUsingEmote(silent)
	if not CurrentPlaying then
		return
	end

	local playing = CurrentPlaying
	CurrentPlaying = nil
	CurrentEmoteName = nil

	StopSafetyWatch()

	local ped = PlayerPedId()

	if playing.kind == "scenario" then
		StopScenario(ped)
	elseif playing.kind == "nativeEmote" then
		StopNativeEmote(ped)
	else
		StopAnimation(ped, { dict = playing.dict, anim = playing.anim, flag = playing.flag })
	end

	if playing.propHandle then
		DeleteAttachedProp(playing.propHandle)
		playing.propHandle = nil
	end

	if GetSharedPartnerId() then
		ClearSharedPartner()
	end

	SendNUIMessage({ action = "playingState", playing = false })

	if not silent then
		DsmlDebug("Animation stopped")
	end
end

-- ----------------------------------------------------------------------------
-- Cleanup
-- ----------------------------------------------------------------------------

AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end

	StopUsingEmote(true)
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "closeMenu" })
end)

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------

exports("StartEmote", StartEmote)
exports("StopEmote", function() StopUsingEmote(false) end)
exports("IsPlaying", function() return CurrentEmoteName ~= nil end)
exports("GetCurrentEmote", function() return CurrentEmoteName end)
