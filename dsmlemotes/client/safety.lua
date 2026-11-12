-- ============================================================================
-- DSML EMOTES - ANIMATION SAFETY (CLIENT)
-- ============================================================================
-- Watches for conditions that should interrupt the current emote: death,
-- entering a vehicle, drawing a weapon/entering combat (unless the entry
-- allows it). Also re-applies the animation/prop if something else in the
-- game momentarily interrupted it (the same resilience kibook's original
-- always-on loop provided) - but bounded to only run while an emote is
-- active, not as a permanent background loop, per the performance
-- requirements.
-- ============================================================================

-- A single shared `watching = true/false` flag isn't enough to guard this
-- loop: it doesn't distinguish "the emote was stopped" from "a DIFFERENT
-- emote started" - and either way, this thread could be asleep inside the
-- Wait() below when that happens. Without a re-check right after waking,
-- the already-queued iteration runs anyway on stale `playing` data - at
-- best redundant, at worst (the resilience block) it sees the
-- just-stopped animation as "not playing" and restarts it, re-freezing the
-- player on flag == 1 entries. That's /stop appearing to do nothing and
-- the player getting stuck.
--
-- currentToken closes this properly: every Start/StopSafetyWatch call
-- bumps it, so a watchLoop() only keeps running while its OWN token is
-- still the current one - any older thread notices on its very next wake
-- and exits immediately instead of acting on stale state.
local currentToken = 0

--- Runs `fn()`, guarded by pcall. If it errors, prints it ONCE (via
--- `disabledFlags[key]`) and permanently skips that one check for the rest
--- of this watch session instead of taking the whole safety loop down with
--- it - a single unexpected native shouldn't cost death/vehicle/prop
--- resilience checks too.
local function guarded(disabledFlags, key, fn)
	if disabledFlags[key] then return end

	local ok, err = pcall(fn)
	if not ok then
		disabledFlags[key] = true
		print(("[DSML_EMOTES] ERROR: safety check '%s' failed and has been disabled for this emote: %s"):format(key, tostring(err)))
	end
end

local function watchLoop(playing, myToken)
	local disabled = {}

	while currentToken == myToken do
		Wait(250)

		if currentToken ~= myToken then
			break
		end

		local ped = PlayerPedId()
		local stop = false

		if IsPedDeadOrDying(ped, true) or IsEntityDead(ped) then
			DsmlDebug("Safety: player died - stopping emote")
			stop = true
		end

		if not stop and not Config.AllowInVehicle and IsPedInAnyVehicle(ped, false) then
			DsmlDebug("Safety: player entered a vehicle - stopping emote")
			stop = true
		end

		-- Scoped to plain "anim" entries only - scenario and nativeEmote entries whose
		-- animation itself involves holding something (the smoking/drinking/instrument/tool
		-- scenarios in config/scenarios.lua, or emotes.lua's KIT_EMOTE_*-based nativeEmote
		-- entries like smoke/smoke_cigar) get that prop from the game itself, attached
		-- through the same weapon-slot mechanism real weapons use (confirmed via
		-- Config.Debug: the weapon read correctly as unarmed the instant the scenario
		-- started, then flipped to a real non-unarmed hash a couple of watch cycles later -
		-- right as the scenario's own held prop, e.g. a cigarette, actually attached) - so
		-- this check could never tell "the emote gave you a prop" apart from "you actually
		-- drew a weapon" for those two kinds, and was stopping nearly every one of them a
		-- fraction of a second in. Plain "anim" entries are unaffected - they only ever get
		-- a prop through our own CreateAndAttachProp, which never touches the weapon system,
		-- so any detected weapon there is unambiguously the player's own.
		if not stop and not playing.allowWeapon and not Config.AllowWithWeapon and playing.kind == "anim" then
			guarded(disabled, "weapon", function()
				-- Comparing against the WEAPON_UNARMED hash alone caught nothing, and
				-- GetPedCurrentHeldWeapon(ped) ~= 0 alone caught everything - treating EITHER known
				-- "unarmed" representation as unarmed (the same convention vorp_inventory's own
				-- ammoService.lua already uses successfully on this install) is the correct check
				-- for a plain "anim" entry, where any detected weapon is unambiguously the
				-- player's own (see the guard above scoping this whole check to playing.kind ==
				-- "anim" for why scenario/nativeEmote entries never reach this at all).
				local unarmedHash = GetHashKey("WEAPON_UNARMED")
				local weapon = GetPedCurrentHeldWeapon(ped)
				local unarmed = (weapon == 0) or (weapon == unarmedHash)

				if not unarmed then
					if Config.Debug then
						print(("[DSML_EMOTES] DEBUG: GetPedCurrentHeldWeapon = %s (WEAPON_UNARMED hash = %s) - treated as armed, stopping"):format(
							tostring(weapon), tostring(unarmedHash)))
					end
					DsmlDebug("Safety: weapon drawn - stopping emote")
					stop = true
				end
			end)
		end

		if not stop and not playing.allowCombat and not Config.AllowInCombat then
			guarded(disabled, "combat", function()
				if IsPedInCombat(ped, 0) then
					DsmlDebug("Safety: entered combat - stopping emote")
					stop = true
				end
			end)
		end

		if stop then
			StopUsingEmote(true)
			break
		end

		-- Resilience: re-apply the animation / re-attach the prop if the
		-- game interrupted either without us stopping the emote ourselves.
		if playing.kind == "anim" and playing.dict and playing.anim then
			guarded(disabled, "anim_resilience", function()
				local anim = { dict = playing.dict, anim = playing.anim, flag = playing.flag }
				if not IsPlayingAnimation(ped, anim) then
					PlayAnimation(ped, anim)
				end
			end)
		end

		if playing.prop then
			guarded(disabled, "prop_resilience", function()
				if not (playing.propHandle and DoesEntityExist(playing.propHandle)) then
					playing.propHandle = CreateAndAttachProp(ped, playing.prop)
				elseif not IsEntityAttachedToEntity(playing.propHandle, ped) then
					DeleteAttachedProp(playing.propHandle)
					playing.propHandle = CreateAndAttachProp(ped, playing.prop)
				end
			end)
		end
	end
end

--- Starts the bounded safety-watch thread for the given `playing` state
--- table (see client/main.lua) - the same table is mutated in place so
--- prop-reattachment stays visible to StopUsingEmote's cleanup.
function StartSafetyWatch(playing)
	currentToken = currentToken + 1
	local myToken = currentToken
	CreateThread(function() watchLoop(playing, myToken) end)
end

--- Stops the safety-watch thread (called when the emote itself is stopped).
function StopSafetyWatch()
	currentToken = currentToken + 1
end
