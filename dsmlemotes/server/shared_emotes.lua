-- ============================================================================
-- DSML EMOTES - SHARED (PARTNER) EMOTES (SERVER)
-- ============================================================================
-- The server is the sole authority on whether a shared emote actually
-- starts: a client can NEVER force an animation onto another client. Every
-- request is validated (target exists, in range, request not expired, both
-- players alive) before the target's client is even told a request exists.
-- ============================================================================

local pendingRequests = {} -- [requesterSource] = { target, name, expires }
local activePairs = {}     -- [source] = partnerSource, for both sides of an active shared emote

local function isValidTarget(id)
	return id and id ~= 0 and GetPlayerName(id) ~= nil
end

local function bothAliveAndInRange(a, b)
	local pedA, pedB = GetPlayerPed(a), GetPlayerPed(b)
	if not pedA or pedA == 0 or not pedB or pedB == 0 then return false end
	if IsEntityDead(pedA) or IsEntityDead(pedB) then return false end

	local dist = #(GetEntityCoords(pedA) - GetEntityCoords(pedB))
	-- small server-side buffer over the client distance to tolerate latency
	return dist <= (Config.SharedEmoteDistance + 2.0)
end

local function clearPending(requester)
	pendingRequests[requester] = nil
end

RegisterNetEvent("dsmlemotes:requestShared", function(targetServerId, name)
	local source = source
	if not Config.EnableSharedEmotes then return end

	local entry = SharedIndex[name]
	if not entry then return end

	targetServerId = tonumber(targetServerId)
	if not isValidTarget(targetServerId) or targetServerId == source then return end
	if not bothAliveAndInRange(source, targetServerId) then
		TriggerClientEvent("dsmlemotes:sharedDeclined", source, "That player", name)
		return
	end

	pendingRequests[source] = {
		target = targetServerId, name = name,
		expires = GetGameTimer() + (Config.SharedEmoteTimeout * 1000)
	}

	TriggerClientEvent("dsmlemotes:sharedRequestIncoming", targetServerId, source, GetPlayerName(source), name, Config.SharedEmoteTimeout)
end)

RegisterNetEvent("dsmlemotes:acceptShared", function(requesterServerId, name)
	local source = source
	requesterServerId = tonumber(requesterServerId)

	local req = pendingRequests[requesterServerId]
	local valid = req and req.target == source and req.name == name and GetGameTimer() <= req.expires

	if valid and not bothAliveAndInRange(requesterServerId, source) then
		valid = false
	end

	clearPending(requesterServerId)

	if not valid then
		TriggerClientEvent("dsmlemotes:sharedDeclined", requesterServerId, "That player", name)
		return
	end

	activePairs[requesterServerId] = source
	activePairs[source] = requesterServerId

	TriggerClientEvent("dsmlemotes:sharedAccepted", requesterServerId, source, name)
end)

RegisterNetEvent("dsmlemotes:declineShared", function(requesterServerId, name)
	local source = source
	requesterServerId = tonumber(requesterServerId)

	local req = pendingRequests[requesterServerId]
	if req and req.target == source then
		clearPending(requesterServerId)
	end

	if isValidTarget(requesterServerId) then
		TriggerClientEvent("dsmlemotes:sharedDeclined", requesterServerId, GetPlayerName(source) or "That player", name)
	end
end)

RegisterNetEvent("dsmlemotes:cancelShared", function(partnerServerId)
	local source = source
	partnerServerId = tonumber(partnerServerId)

	if activePairs[source] == partnerServerId then
		activePairs[source] = nil
	end
	if activePairs[partnerServerId] == source then
		activePairs[partnerServerId] = nil
	end

	if isValidTarget(partnerServerId) then
		TriggerClientEvent("dsmlemotes:sharedCancelled", partnerServerId)
	end
end)

AddEventHandler("playerDropped", function()
	local source = source

	local partner = activePairs[source]
	if partner then
		activePairs[source] = nil
		activePairs[partner] = nil
		if isValidTarget(partner) then
			TriggerClientEvent("dsmlemotes:sharedCancelled", partner)
		end
	end

	clearPending(source)
	for requester, req in pairs(pendingRequests) do
		if req.target == source then
			pendingRequests[requester] = nil
		end
	end
end)

-- Low-frequency sweep so an abandoned/expired request can never linger
-- forever - runs once every 30s, not per-frame.
CreateThread(function()
	while true do
		Wait(30000)
		local now = GetGameTimer()
		for requester, req in pairs(pendingRequests) do
			if now > req.expires then
				pendingRequests[requester] = nil
			end
		end
	end
end)
