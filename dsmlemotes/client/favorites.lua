-- ============================================================================
-- DSML EMOTES - FAVORITES / RECENT (CLIENT)
-- ============================================================================

local favorites = {}  -- set: [emoteName] = true
local recent = {}     -- ordered list, most recent first

local dataLoaded = false

RegisterNetEvent("dsmlemotes:syncData", function(data)
	favorites = {}
	for _, name in ipairs(data.favorites or {}) do
		favorites[name] = true
	end
	recent = data.recent or {}
	dataLoaded = true

	if MenuIsOpen and MenuIsOpen() then
		PushFavoritesAndRecent()
	end
end)

CreateThread(function()
	if Config.EnableFavorites or Config.EnableRecent then
		TriggerServerEvent("dsmlemotes:requestData")
	end
end)

function GetFavoriteList()
	local list = {}
	for name in pairs(favorites) do
		list[#list + 1] = name
	end
	return list
end

function GetRecentList()
	return recent
end

function IsFavorite(name)
	return favorites[name] == true
end

function ToggleFavorite(name)
	if not Config.EnableFavorites then return end

	if favorites[name] then
		favorites[name] = nil
	else
		favorites[name] = true
	end

	if Config.Persistence ~= "none" then
		TriggerServerEvent("dsmlemotes:saveFavorites", GetFavoriteList())
	end
end

function AddRecent(name)
	if not Config.EnableRecent then return end

	-- remove any existing occurrence, then push to the front
	for i = #recent, 1, -1 do
		if recent[i] == name then
			table.remove(recent, i)
		end
	end

	table.insert(recent, 1, name)

	while #recent > (Config.MaxRecent or 15) do
		table.remove(recent, #recent)
	end

	if Config.Persistence ~= "none" then
		TriggerServerEvent("dsmlemotes:saveRecent", recent)
	end
end
