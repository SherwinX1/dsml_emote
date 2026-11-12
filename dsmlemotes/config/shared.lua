-- ============================================================================
-- DSML EMOTES - SHARED (PARTNER) EMOTE DEFINITIONS
-- ============================================================================
-- Two-player synchronised emotes. The requester plays `animation`, the
-- target (once they accept) is teleported next to the requester using
-- `partner.offset` (a vector4: local x, y, z offset + heading offset,
-- relative to the requester) and plays `partner.animation`.
--
-- This is the exact synchronisation model from the already-installed
-- kibook/redm-emotes resource (TeleportToPartner/offset math), just
-- reorganised into named, categorised config entries instead of ad-hoc
-- chat-command strings.
--
-- Schema:
-- {
--     name        = "unique_id",
--     label       = "Display Name",
--     category    = "Handshake",   -- one of the SHARED_CATEGORIES below
--     description = "Shown as a tooltip in the menu.",
--     animation   = { dict = "...", anim = "...", flag = 1 },
--     partner = {
--         offset    = vector4(x, y, z, headingOffset),
--         animation = { dict = "...", anim = "...", flag = 1 },
--     },
--     restricted  = false,
--     tags        = { "tag1", "tag2" },
-- }
-- ============================================================================

Config.SharedCategories = {
	"Handshake", "Hug", "Dance", "High Five", "Other"
}

Config.SharedEmotes = {
	{
		-- [KIBOOK]
		name = "dance_together", label = "Dance", category = "Dance",
		description = "Dance together with a nearby player.",
		animation = { dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen", anim = "arthur_dance_loop", flag = 1 },
		partner = {
			offset = vector4(0.2, 0.5, 0.0, 155.0),
			animation = { dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen", anim = "karen_dance_loop", flag = 1 }
		},
		tags = { "dance", "shared", "partner" }
	},
	{
		-- [KIBOOK]
		name = "hostage", label = "Take Hostage", category = "Other",
		description = "Take a nearby player hostage at gunpoint.",
		animation = { dict = "mech_grapple@blade@_male@_ambient@_healthy@back@loco@attacker", anim = "idle", flag = 1 },
		partner = {
			offset = vector4(0, 0.2, 0, 0),
			animation = { dict = "mech_grapple@blade@_male@_ambient@_healthy@back@loco@victim", anim = "idle", flag = 1 }
		},
		allowWeapon = true, allowCombat = true,
		tags = { "combat", "hostage", "shared", "partner" }
	},
	-- pet_standing / pet_sitting (Pet Dog, Standing/Sitting) - REMOVED FOR
	-- NOW (per request), not deleted. Both [KIBOOK] - already-verified -
	-- so they don't need re-checking if restored later.
	--[[
	{
		name = "pet_standing", label = "Pet Dog (Standing)", category = "Other",
		description = "Pet a nearby player's dog companion, standing.",
		animation = { dict = "mech_animal_interaction@dog@patting@1h", anim = "base", flag = 1 },
		partner = {
			offset = vector4(0, 0.85, -0.6, 180),
			animation = { dict = "creatures_mammal@dog_pers@happy@idle", anim = "idle", flag = 1 }
		},
		tags = { "dog", "pet", "shared", "partner" }
	},
	{
		name = "pet_sitting", label = "Pet Dog (Sitting)", category = "Other",
		description = "Pet a nearby player's dog companion, sitting.",
		animation = { dict = "mech_animal_interaction@dog@patting@1h", anim = "base", flag = 1 },
		partner = {
			offset = vector4(0, 0.7, -0.6, 180),
			animation = { dict = "amb_creature_mammal@world_dog_sitting@base", anim = "base", flag = 1 }
		},
		tags = { "dog", "pet", "shared", "partner" }
	},
	--]]

	-- ------------------------------------------------------------------
	-- Handshake / Hug / High Five: no verified, correctly two-person
	-- synchronised dict/anim pair for these met this resource's
	-- confidence bar (they require matching mirrored animations on both
	-- participants, which is easy to get subtly wrong). Left empty
	-- rather than guessing - add entries here once verified in-game,
	-- using the schema above.
	-- ------------------------------------------------------------------
}

SharedIndex = {}
for _, entry in ipairs(Config.SharedEmotes) do
	SharedIndex[entry.name] = entry
end
