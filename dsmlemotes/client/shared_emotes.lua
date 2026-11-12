-- ============================================================================
-- DSML EMOTES - SHARED (PARTNER) EMOTES (CLIENT)
-- ============================================================================
-- Nearest-player targeting + accept/decline flow + offset math adapted from
-- the already-installed kibook/redm-emotes client.lua (EnumeratePeds /
-- TeleportToPartner), extended with server-side validation (see
-- server/shared_emotes.lua), a distance-break watchdog, and a small
-- non-focus-stealing accept/decline overlay instead of a permanent
-- control-polling loop.
-- ============================================================================

local pendingRequest = nil   -- { targetServerId, entry } - we are waiting on someone else
local incomingRequest = nil  -- { fromServerId, fromName, entry, expires } - someone is waiting on us
local sharedPartnerId = nil  -- server id of the player we are currently sharing an emote with

-- ----------------------------------------------------------------------------
-- Nearest-player helpers (adapted from kibook/redm-emotes)
-- ----------------------------------------------------------------------------

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function enumerateEntities(firstFunc, nextFunc, endFunc)
	return coroutine.wrap(function()
		local iter, id = firstFunc()

		if not id or id == 0 then
			endFunc(iter)
			return
		end

		local enum = { handle = iter, destructor = endFunc }
		setmetatable(enum, entityEnumerator)

		local more = true
		repeat
			coroutine.yield(id)
			more, id = nextFunc(iter)
		until not more

		enum.destructor, enum.handle = nil, nil
		endFunc(iter)
	end)
end

local function enumeratePeds()
	return enumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

local function getClosestPlayerPed()
	local myPed = PlayerPedId()
	local myPos = GetEntityCoords(myPed)

	local minDist, closest

	for ped in enumeratePeds() do
		if ped ~= myPed and IsPedAPlayer(ped) then
			local dist = #(myPos - GetEntityCoords(ped))
			if dist < Config.SharedEmoteDistance and (not minDist or dist < minDist) then
				minDist = dist
				closest = ped
			end
		end
	end

	return closest
end

local function getPlayerFromPed(ped)
	for _, player in ipairs(GetActivePlayers()) do
		if GetPlayerPed(player) == ped then
			return player
		end
	end
end

local function getServerIdFromPed(ped)
	local player = getPlayerFromPed(ped)
	return player and GetPlayerServerId(player) or nil
end

local function teleportToPartner(ped, partnerPed, offset)
	local partnerPos = GetEntityCoords(partnerPed)
	local partnerHeading = GetEntityHeading(partnerPed)

	local r = math.rad(partnerHeading)
	local cosr, sinr = math.cos(r), math.sin(r)

	local x = offset.x * cosr - offset.y * sinr + partnerPos.x
	local y = offset.y * cosr + offset.x * sinr + partnerPos.y
	local z = offset.z + partnerPos.z
	local h = offset.w + partnerHeading

	SetEntityCoordsNoOffset(ped, x, y, z)
	SetEntityHeading(ped, h)
end

-- ----------------------------------------------------------------------------
-- Requesting
-- ----------------------------------------------------------------------------

--- Called from the NUI when the player picks a shared emote: finds the
--- nearest player and sends them a request.
function RequestSharedEmote(name)
	local entry = SharedIndex[name]
	if not entry then return end

	if CurrentEmoteName then
		StopUsingEmote(true)
	end

	local targetPed = getClosestPlayerPed()
	if not targetPed then
		DsmlNotify("Nobody nearby to share this emote with.")
		return
	end

	local targetServerId = getServerIdFromPed(targetPed)
	if not targetServerId then return end

	pendingRequest = { targetServerId = targetServerId, entry = entry }
	TriggerServerEvent("dsmlemotes:requestShared", targetServerId, entry.name)
	DsmlNotify("Shared emote request sent.")
end

RegisterNetEvent("dsmlemotes:sharedAccepted", function(byServerId, name)
	if not pendingRequest or pendingRequest.entry.name ~= name then return end

	local entry = pendingRequest.entry
	pendingRequest = nil
	sharedPartnerId = byServerId

	StartEmoteEntry(entry, { anim = entry.animation }, byServerId)
	StartSharedDistanceWatch(byServerId)
end)

RegisterNetEvent("dsmlemotes:sharedDeclined", function(byName, name)
	if pendingRequest and pendingRequest.entry.name == name then
		pendingRequest = nil
	end
	DsmlNotify((byName or "The player") .. " declined the shared emote.")
end)

-- ----------------------------------------------------------------------------
-- Receiving
-- ----------------------------------------------------------------------------

RegisterNetEvent("dsmlemotes:sharedRequestIncoming", function(fromServerId, fromName, name, timeoutSeconds)
	local entry = SharedIndex[name]
	if not entry then return end

	incomingRequest = {
		fromServerId = fromServerId, fromName = fromName, entry = entry,
		expires = GetGameTimer() + (timeoutSeconds * 1000)
	}

	SendNUIMessage({
		action = "sharedRequest",
		fromName = fromName,
		label = entry.label,
		seconds = timeoutSeconds
	})

	CreateThread(function()
		local request = incomingRequest
		while incomingRequest == request and GetGameTimer() < request.expires do
			Wait(200)
		end

		if incomingRequest == request then
			-- expired without a response
			incomingRequest = nil
			SendNUIMessage({ action = "sharedRequestClear" })
		end
	end)
end)

function AcceptSharedEmote()
	if not incomingRequest then return end

	local request = incomingRequest
	incomingRequest = nil
	SendNUIMessage({ action = "sharedRequestClear" })

	if CurrentEmoteName then
		StopUsingEmote(true)
	end

	TriggerServerEvent("dsmlemotes:acceptShared", request.fromServerId, request.entry.name)

	local partnerPed = GetPlayerPedFromServerId(request.fromServerId)
	if partnerPed and partnerPed ~= 0 then
		teleportToPartner(PlayerPedId(), partnerPed, request.entry.partner.offset)
	end

	sharedPartnerId = request.fromServerId
	StartEmoteEntry(request.entry, { anim = request.entry.partner.animation }, request.fromServerId)
	StartSharedDistanceWatch(request.fromServerId)
end

function DeclineSharedEmote()
	if not incomingRequest then return end

	TriggerServerEvent("dsmlemotes:declineShared", incomingRequest.fromServerId, incomingRequest.entry.name)
	incomingRequest = nil
	SendNUIMessage({ action = "sharedRequestClear" })
end

-- ----------------------------------------------------------------------------
-- Cancellation / distance watchdog
-- ----------------------------------------------------------------------------

RegisterNetEvent("dsmlemotes:sharedCancelled", function()
	if sharedPartnerId then
		sharedPartnerId = nil -- clear first so StopUsingEmote doesn't re-notify the server
		StopUsingEmote(true)
		DsmlNotify("Shared emote cancelled.")
	end
end)

--- Bounded thread: only runs while a shared emote is active for this player.
function StartSharedDistanceWatch(partnerServerId)
	CreateThread(function()
		while sharedPartnerId == partnerServerId do
			Wait(500)

			local partnerPlayer = GetPlayerFromServerId(partnerServerId)
			if partnerPlayer == -1 then
				break
			end

			local partnerPed = GetPlayerPed(partnerPlayer)
			if not partnerPed or partnerPed == 0 or not DoesEntityExist(partnerPed) then
				break
			end

			local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(partnerPed))
			if dist > Config.SharedEmoteDistance then
				break
			end
		end

		if sharedPartnerId == partnerServerId then
			sharedPartnerId = nil
			if CurrentEmoteName then
				StopUsingEmote(true)
				DsmlNotify("Shared emote cancelled.")
			end
		end
	end)
end

function GetSharedPartnerId()
	return sharedPartnerId
end

function ClearSharedPartner()
	if sharedPartnerId then
		TriggerServerEvent("dsmlemotes:cancelShared", sharedPartnerId)
	end
	sharedPartnerId = nil
end

function GetPlayerPedFromServerId(serverId)
	local player = GetPlayerFromServerId(serverId)
	if player == -1 then return nil end
	return GetPlayerPed(player)
end
