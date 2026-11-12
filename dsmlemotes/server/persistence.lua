-- ============================================================================
-- DSML EMOTES - FAVORITES / RECENT PERSISTENCE (SERVER)
-- ============================================================================
-- Config.Persistence = "file": stored as one small JSON file per player
-- (keyed by license identifier) under data/, via SaveResourceFile /
-- LoadResourceFile. No database of any kind is required.
-- Config.Persistence = "none": favorites/recent are session-only.
-- ============================================================================

local function getIdentifier(source)
	local id = GetPlayerIdentifierByType(source, "license")
		or GetPlayerIdentifierByType(source, "license2")
		or GetPlayerIdentifierByType(source, "fivem")

	return id or ("src_" .. tostring(source))
end

local function dataPath(identifier)
	local safe = identifier:gsub("[^%w_%-]", "_")
	return ("data/%s.json"):format(safe)
end

local function loadData(identifier)
	local raw = LoadResourceFile(GetCurrentResourceName(), dataPath(identifier))
	if not raw then
		return { favorites = {}, recent = {} }
	end

	local ok, decoded = pcall(json.decode, raw)
	if not ok or type(decoded) ~= "table" then
		return { favorites = {}, recent = {} }
	end

	return { favorites = decoded.favorites or {}, recent = decoded.recent or {} }
end

local function saveData(identifier, data)
	if Config.Persistence ~= "file" then return end
	SaveResourceFile(GetCurrentResourceName(), dataPath(identifier), json.encode(data), -1)
end

--- Validates that every entry in `list` is a real, known emote/scenario/
--- shared-emote name, and caps the length. Never trusts client input.
local function sanitizeList(list, maxLen, allowShared)
	local clean = {}

	if type(list) ~= "table" then
		return clean
	end

	for _, name in ipairs(list) do
		if type(name) == "string" and
			(EmotesIndex[name] or ScenariosIndex[name] or (allowShared and SharedIndex[name])) then
			clean[#clean + 1] = name
		end

		if #clean >= maxLen then
			break
		end
	end

	return clean
end

RegisterNetEvent("dsmlemotes:requestData", function()
	local source = source

	if Config.Persistence == "none" then
		TriggerClientEvent("dsmlemotes:syncData", source, { favorites = {}, recent = {} })
		return
	end

	TriggerClientEvent("dsmlemotes:syncData", source, loadData(getIdentifier(source)))
end)

RegisterNetEvent("dsmlemotes:saveFavorites", function(favorites)
	local source = source
	if Config.Persistence ~= "file" then return end

	local identifier = getIdentifier(source)
	local data = loadData(identifier)
	data.favorites = sanitizeList(favorites, 200, true)
	saveData(identifier, data)
end)

RegisterNetEvent("dsmlemotes:saveRecent", function(recent)
	local source = source
	if Config.Persistence ~= "file" then return end

	local identifier = getIdentifier(source)
	local data = loadData(identifier)
	data.recent = sanitizeList(recent, Config.MaxRecent or 15, false)
	saveData(identifier, data)
end)
