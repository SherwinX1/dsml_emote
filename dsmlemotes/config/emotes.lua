-- ============================================================================
-- DSML EMOTES - EMOTE DEFINITIONS
-- ============================================================================
-- Three entry "type"s are supported:
--   type = "anim"        -> played with TaskPlayAnim(dict, anim, flag, ...)
--   type = "scenario"    -> played with TaskStartScenarioInPlace(scenario, ...)
--   type = "nativeEmote" -> played with TaskEmote(..., emoteType, ...), RDR2's
--                           own built-in "emote wheel" system (identified by
--                           a KIT_EMOTE_* name). Use this instead of
--                           "scenario" for anything that normally holds a
--                           prop (smoking, etc.) - TaskStartScenarioInPlace
--                           plays the motion but has no prop to attach (that
--                           comes from the scenario POINT's own data, which
--                           in-place playback doesn't have), so it looks
--                           like it's missing whatever it's meant to be
--                           holding. The native emote system supplies its
--                           own prop, no manual `prop` field needed.
--
-- Every dict/anim/scenario/emoteType identifier below is a REAL RDR2/RedM
-- identifier. Entries marked [KIBOOK] are the exact, already-installed &
-- working kibook/redm-emotes definitions from this resource's original
-- config.lua - 100% verified because they were already shipped and running
-- on this server. Entries marked [vorp_animations] are copied dict/anim/prop
-- combos straight out of that resource's config.lua - also already
-- installed, `ensure`d, and running on this server (used by its /playanim
-- system), so these are as verified as it gets short of testing every one
-- individually in dsmlemotes itself. Entries marked [SOURCED] were pulled
-- directly from the config.lua of Rexshack-RedM/rsg-animations, an actively
-- used open-source RedM emote resource, or cross-checked against multiple
-- independent RDR2 scenario listings - real, documented identifiers, but
-- not verified on THIS server specifically. Either way, if one turns out
-- wrong for any reason, PlayAnimation()/PlayScenario()/PlayNativeEmote() in
-- client/animation.lua catch it, log "[DSML_EMOTES] ERROR: ..." to console,
-- notify the player, and skip it - nothing crashes.
--
-- If a scenario-type entry plays but looks wrong/incomplete/does nothing,
-- set Config.Debug = true and try it again: PlayScenario() now also checks
-- (via IsPedUsingAnyScenario, the same native vorp_admin's dev tools use)
-- whether the scenario actually took hold half a second later, and prints
-- what it finds - that tells you whether the scenario name itself is bad,
-- versus it genuinely running but missing an item it should be holding (in
-- which case "nativeEmote" - see the type comment above - or an explicit
-- `prop` field is the fix, not a different scenario name).
--
-- Add more entries by copying the schema below - no code changes required.
--
-- Schema:
-- {
--     name        = "unique_id",
--     label       = "Display Name",
--     category    = "Greetings",     -- one of the EMOTE_CATEGORIES below
--     description = "Shown as a tooltip in the menu.",
--     type        = "anim",          -- "anim", "scenario", or "nativeEmote"
--     dict        = "anim_dict",     -- type == "anim"
--     anim        = "anim_name",     -- type == "anim"
--     scenario    = "SCENARIO_NAME", -- type == "scenario"
--     emoteType   = "KIT_EMOTE_...", -- type == "nativeEmote"
--     flag        = 1,               -- type == "anim" only, TaskPlayAnim flag
--     canMove     = false,
--     canRun      = false,
--     canJump     = false,
--     canAttack   = false,
--     canCancel   = true,
--     allowWeapon = false,
--     allowCombat = false,
--     prop        = nil,             -- { model, bone, position=vector3, rotation=vector3 }
--     restricted  = false,           -- false OR { jobs = { "police", ... } }
--     tags        = { "tag1", "tag2" },
--     -- male / female (optional):
--     maleAnim    = { dict = "...", anim = "...", flag = 1 }, -- a male character plays this instead
--     femaleAnim  = { dict = "...", anim = "...", flag = 1 }, -- a female character plays this instead
--     conditionalAnimFemale = "...", -- type == "scenario": female variant (conditionalAnim = male)
--     gender      = "male",          -- only that gender can use it (hidden for the other)
-- }
-- ============================================================================

Config.EmoteCategories = {
	"Greetings", "Reactions", "Dances", "Sitting", "Drinking",
	"Smoking", "Working", "Social", "Combat", "Town", "Camp", "Farming", "Mining", "Misc"
}

Config.Emotes = {

	-- ======================================================================
	-- GREETINGS
	-- ======================================================================
	{
		name = "wave", label = "Wave", category = "Greetings",
		description = "A friendly wave hello.",
		type = "anim",
		dict = "mech_loco_m@character@nicholas_timmins@normal@unarmed@idle@variations@big_wave", anim = "idle", flag = 1,
		canCancel = true, tags = { "greeting", "wave", "hello" }
	},
	{
		name = "nod", label = "Nod", category = "Greetings",
		description = "A silent, respectful nod.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_neutral_greet_f_002", flag = 1,
		tags = { "greeting", "nod" }
	},
	{
		name = "tip_hat", label = "Tip Hat", category = "Greetings",
		description = "Politely tip your hat.",
		type = "anim",
		dict = "mech_loco_m@character@arthur@fidgets@hat@normal@unarmed@normal@left_hand", anim = "hat_lhand_b", flag = 1,
		tags = { "greeting", "hat", "social" }
	},
	{
		name = "smooth_greet", label = "Smooth Greeting", category = "Greetings",
		description = "A cocky, self-assured greeting.",
		type = "anim",
		dict = "ai_gestures@arthur@standing@speaker@rt_hand", anim = "greet_cocky_l_003", flag = 1,
		tags = { "greeting", "cocky" }
	},
	{
		name = "discreet_wave", label = "Discreet Wave", category = "Greetings",
		description = "A subtle, flirtatious little wave.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_flirty_greet_r_001", flag = 1,
		tags = { "greeting", "flirty", "wave" }
	},
	{
		name = "sarcastic_wave", label = "Sarcastic Wave", category = "Greetings",
		description = "A dismissive, sarcastic wave.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_neutral_wave_r_001", flag = 1,
		tags = { "greeting", "sarcastic", "wave" }
	},

	-- ======================================================================
	-- REACTIONS
	-- ======================================================================
	{
		-- [KIBOOK]
		name = "handsup", label = "Hands Up", category = "Reactions",
		description = "Raise your hands in surrender.",
		type = "anim",
		dict = "script_proc@robberies@homestead@lonnies_shack@deception", anim = "hands_up_loop", flag = 25,
		canMove = true, tags = { "surrender", "reaction", "hostage" }
	},
	{
		name = "handsup_alt", label = "Hands Up (Alt)", category = "Reactions",
		description = "An alternate hands-up surrender pose.",
		type = "anim",
		dict = "mech_loco_f@generic@reaction@handsup@unarmed@normal", anim = "loop", flag = 1,
		tags = { "surrender", "reaction" },
		maleAnim = { dict = "mech_loco_m@generic@reaction@handsup@unarmed@normal", anim = "loop", flag = 1 },
	},
	{
		name = "cry", label = "Cry", category = "Reactions",
		description = "Break down in tears.",
		type = "anim",
		dict = "script_common@other@unapproved", anim = "cry_loop", flag = 1,
		tags = { "reaction", "sad", "cry" }
	},
	{
		name = "cower", label = "Cower in Fear", category = "Reactions",
		description = "Cower and flinch in fear.",
		type = "anim",
		dict = "script_common@crowd_control@unapproved@a@ped_d@cower", anim = "cower", flag = 1,
		tags = { "reaction", "scared", "fear" }
	},
	{
		name = "angry", label = "Angry", category = "Reactions",
		description = "A sharp, angry glare.",
		type = "anim",
		dict = "ai_react@react_look_layers@base_emotions@angry", anim = "direct", flag = 1,
		tags = { "reaction", "angry" }
	},
	{
		name = "sad", label = "Sad", category = "Reactions",
		description = "A sad, downcast idle.",
		type = "anim",
		dict = "mech_loco_m@generic@emotion@unarmed@sad@idle", anim = "idle", flag = 1,
		tags = { "reaction", "sad" },
		femaleAnim = { dict = "mech_loco_f@generic@emotion@unarmed@sad@idle", anim = "idle", flag = 1 },
	},
	{
		name = "confused", label = "Confused", category = "Reactions",
		description = "Look around, confused.",
		type = "anim",
		dict = "script_common@other@unapproved", anim = "security_look_around@idle_c", flag = 1,
		tags = { "reaction", "confused" }
	},
	{
		name = "nervous", label = "Nervous", category = "Reactions",
		description = "A nervous, uneasy idle.",
		type = "anim",
		dict = "script_rc@rmyr4@unapproved@scared", anim = "idle", flag = 1,
		tags = { "reaction", "nervous", "scared" }
	},
	{
		name = "impatient", label = "Impatient", category = "Reactions",
		description = "Wait around impatiently.",
		type = "anim",
		dict = "amb_misc@world_human_waiting_impatient@male_d@idle_b", anim = "idle_d", flag = 1,
		tags = { "reaction", "impatient", "wait" }
	},

	-- ======================================================================
	-- DANCES
	-- ======================================================================
	{
		-- [KIBOOK] solo version of the shared "dance" lead role
		name = "dance_lead", label = "Dance: Lead", category = "Dances",
		description = "The leading half of a couple's dance, performed solo.",
		type = "anim",
		dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen", anim = "arthur_dance_loop", flag = 1,
		tags = { "dance" }
	},
	{
		-- [KIBOOK] solo version of the shared "dance" follow role
		name = "dance_follow", label = "Dance: Follow", category = "Dances",
		description = "The following half of a couple's dance, performed solo.",
		type = "anim",
		dict = "cnv_camp@rchso@cnv@ccdtc33@player_karen", anim = "karen_dance_loop", flag = 1,
		tags = { "dance" }
	},
	{
		name = "dance_drunk", label = "Drunken Dance", category = "Dances",
		description = "A sloppy, drunken jig.",
		type = "anim",
		dict = "amb_misc@world_human_drunk_dancing@male@male_b@idle_a", anim = "idle_b", flag = 1,
		tags = { "dance", "drunk" }
	},
	{
		name = "dance_confident", label = "Confident Dance", category = "Dances",
		description = "A confident, showy dance.",
		type = "anim",
		dict = "script_mp@emotes@dance@confident@b@male@unarmed@full", anim = "fullbody", flag = 1,
		tags = { "dance", "confident" }
	},
	{
		name = "dance_wild", label = "Wild Dance", category = "Dances",
		description = "An energetic, wild dance.",
		type = "anim",
		dict = "script_mp@emotes@dance@wild@b@male@unarmed@full", anim = "fullbody", flag = 1,
		tags = { "dance", "wild" }
	},
	{
		name = "dance_old", label = "Old-Timer's Dance", category = "Dances",
		description = "A slower, old-fashioned dance.",
		type = "anim",
		dict = "script_mp@emotes@dance@old@a@male@unarmed@full", anim = "fullbody", flag = 1,
		tags = { "dance" }
	},
	{
		name = "dance_carefree", label = "Carefree Dance", category = "Dances",
		description = "A light, carefree dance.",
		type = "anim",
		dict = "script_mp@emotes@dance@carefree@a@male@unarmed@full", anim = "fullbody", flag = 1,
		tags = { "dance", "carefree" }
	},
	{
		name = "dance_awkward", label = "Awkward Dance", category = "Dances",
		description = "A stiff, awkward dance.",
		type = "anim",
		dict = "script_mp@emotes@dance@awkward@a@male@unarmed@full", anim = "fullbody", flag = 1,
		tags = { "dance", "awkward" }
	},

	-- ======================================================================
	-- SITTING
	-- ======================================================================
	{
		name = "sit_ground", label = "Sit on Ground", category = "Sitting",
		description = "Sit down on the ground.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_GROUND",
		tags = { "sit", "ground" },
		conditionalAnim = "WORLD_HUMAN_SIT_GROUND_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_GROUND_FEMALE_A",
	},
	{
		name = "sit_ground_generic", label = "Sit on Ground (Alt)", category = "Sitting",
		description = "An alternate seated ground pose.",
		type = "scenario", scenario = "GENERIC_SIT_GROUND_SCENARIO",
		tags = { "sit", "ground" },
		conditionalAnim = "GENERIC_SIT_GROUND_SCENARIO_LF_FWD_MALE_A",
		conditionalAnimFemale = "GENERIC_SIT_GROUND_SCENARIO_LEGS_DOWN_FEMALE_A",
	},
	{
		name = "sit_campfire", label = "Sit by Campfire", category = "Sitting",
		description = "Sit down beside a campfire.",
		type = "anim",
		dict = "amb_camp@world_camp_fire_sit_ground@male_c@idle_a", anim = "idle_a", flag = 1,
		tags = { "sit", "camp", "fire" }
	},
	{
		name = "sleep_ground", label = "Sleep on Ground", category = "Sitting",
		description = "Lie down and sleep on the ground.",
		type = "anim",
		dict = "amb_rest@world_human_sleep_ground@arm@male_b@idle_b", anim = "idle_f", flag = 1,
		tags = { "sleep", "rest", "ground" }
	},

	-- ======================================================================
	-- DRINKING
	-- ======================================================================
	-- ======================================================================
	-- SMOKING
	-- ======================================================================

	-- ======================================================================
	-- WORKING
	-- ======================================================================
	{
		-- [KIBOOK] prop emote, repurposed as a "working" carry pose
		name = "carry_basket", label = "Carry Basket", category = "Working",
		description = "Carry a basket while you walk about.",
		type = "anim",
		dict = "amb_wander@code_human_basket_wander@female_a@base", anim = "base", flag = 25,
		canMove = true,
		prop = {
			model = "p_basket04x", bone = "skel_r_hand",
			position = vector3(0.26, -0.07, -0.21), rotation = vector3(134.0, -176.0, -124.0)
		},
		tags = { "work", "carry", "basket" }
	},
	{
		name = "knock", label = "Knock", category = "Working",
		description = "Knock on a door.",
		type = "anim",
		dict = "amb_misc@world_human_door_knock@male_a@idle_c", anim = "idle_h", flag = 1,
		tags = { "work", "knock", "door" }
	},
	{
		-- dict/anim/prop copied from vorp_animations' "carry_box" entry
		-- (already installed and running on this server).
		name = "carry_crate", label = "Carry Crate", category = "Working",
		description = "Carry a wooden crate.",
		type = "anim",
		dict = "mech_carry_box", anim = "idle", flag = 31,
		canMove = true,
		prop = {
			model = "p_chair_crate02x", bone = "SKEL_L_Hand",
			position = vector3(0.1, -0.1399, 0.21), rotation = vector3(263.2899, 619.19, 334.3)
		},
		tags = { "work", "carry", "crate" }
	},
	{
		-- [vorp_animations] "carry_sugar"
		name = "carry_sugar_sack", label = "Carry Sugar Sack", category = "Working",
		description = "Carry a sack of sugar.",
		type = "anim",
		dict = "mech_carry_box", anim = "idle", flag = 31,
		canMove = true,
		prop = {
			model = "p_cs_sacksugarcornwall01x", bone = "SKEL_L_Hand",
			position = vector3(-0.04999999999999, 0.0101, 0.17999999999998), rotation = vector3(323.68989999999985, 705.8900000000004, 361.4000000000001)
		},
		tags = { "work", "carry", "sack" }
	},
	{
		-- [vorp_animations] "carry_barrel"
		name = "carry_barrel", label = "Carry Barrel", category = "Working",
		description = "Carry a barrel.",
		type = "anim",
		dict = "mech_carry_box", anim = "idle", flag = 31,
		canMove = true,
		prop = {
			model = "p_barrel010x", bone = "SKEL_L_Hand",
			position = vector3(-0.04999999999999, -0.0899, 0.17999999999998), rotation = vector3(320.68989999999985, 714.8900000000004, 361.4000000000001)
		},
		tags = { "work", "carry", "barrel" }
	},
	{
		-- [vorp_animations] "carry_moonshine"
		name = "carry_moonshine_crate", label = "Carry Moonshine Crate", category = "Working",
		description = "Carry a crate of moonshine.",
		type = "anim",
		dict = "mech_carry_box", anim = "idle", flag = 31,
		canMove = true,
		prop = {
			model = "p_bottlecrate_mil", bone = "SKEL_L_Hand",
			position = vector3(0.1, -0.1399, 0.26), rotation = vector3(263.2899, 619.19, 334.3)
		},
		tags = { "work", "carry", "moonshine", "crate" }
	},
	{
		-- [vorp_animations] "carry_moonshine2"
		name = "carry_moonshine_crate_alt", label = "Carry Moonshine Crate (Alt)", category = "Working",
		description = "Carry a crate of moonshine.",
		type = "anim",
		dict = "mech_carry_box", anim = "idle", flag = 31,
		canMove = true,
		prop = {
			model = "p_bottlecrate_cul", bone = "SKEL_L_Hand",
			position = vector3(0.1, -0.1399, 0.26), rotation = vector3(263.2899, 619.19, 334.3)
		},
		tags = { "work", "carry", "moonshine", "crate" }
	},
	{
		-- [vorp_animations] "chopping_wood" - that resource's own comment
		-- flags this one as not individually verified in-game (added for
		-- dsml_lumberjack, prop coords approximated) - carried over as-is,
		-- with the same caveat.
		name = "chop_wood", label = "Chop Wood", category = "Working",
		description = "Chop wood with an axe.",
		type = "anim",
		dict = "amb_work@world_human_tree_chop_new@working@pre_swing@male_a@trans", anim = "pre_swing_trans_after_swing", flag = 17,
		prop = {
			model = "p_axe02x", bone = "SKEL_R_Hand",
			position = vector3(0.0, -0.09, -0.09), rotation = vector3(250.2899, 579.19, 373.3)
		},
		tags = { "work", "chop", "wood", "axe" }
	},

	-- ======================================================================
	-- TOWN
	-- ======================================================================
	{
		-- [vorp_animations] "readnewspaper"
		name = "read_newspaper", label = "Read Newspaper", category = "Town",
		description = "Read the newspaper.",
		type = "anim",
		dict = "mech_carry_box", anim = "idle", flag = 17,
		prop = {
			model = "p_cs_newspaper_02x_noanim", bone = "SKEL_L_Finger12",
			position = vector3(0.15, -0.0399, 0.0), rotation = vector3(0.0, 0.0, 0.0)
		},
		tags = { "town", "read", "newspaper" }
	},

	-- ======================================================================
	-- CAMP
	-- ======================================================================
	{
		-- [vorp_animations] "campfire"
		name = "light_campfire", label = "Light a Campfire", category = "Camp",
		description = "Light a campfire.",
		type = "anim",
		dict = "script_campfire@lighting_fire@male_male", anim = "light_fire_b_p2_male_b", flag = 17,
		tags = { "camp", "fire", "light" }
	},
	{
		-- [vorp_animations] "riverwash"
		name = "wash_river", label = "Wash by the River", category = "Camp",
		description = "Kneel and wash up by the river.",
		type = "anim",
		dict = "amb_misc@world_human_wash_kneel_river@female_a@idle_a", anim = "idle_c", flag = 17,
		tags = { "camp", "wash", "river" },
		maleAnim = { dict = "amb_misc@world_human_wash_kneel_river@male_a@idle_a", anim = "idle_c", flag = 1 },
	},

	-- ======================================================================
	-- FARMING
	-- ======================================================================

	-- ======================================================================
	-- MINING
	-- ======================================================================

	-- ======================================================================
	-- SOCIAL
	-- ======================================================================
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_LEAN_BACK_WALL_SMOKING_BAR_CA never
		-- took hold on a player ped, even pinned to a conditional anim -
		-- confirmed via Config.Debug (IsPedUsingAnyScenario stayed false).
		-- amb_rest_lean@world_human_lean@wall@smoking is the exact same
		-- "leaning against a wall, smoking" motion as a plain dict, which
		-- TaskPlayAnim always plays regardless of the scenario system's
		-- player-vs-NPC gating.
		name = "lean_smoke", label = "Lean on wall smoking", category = "Social",
		description = "Lean back against a wall, smoking.",
		type = "anim",
		dict = "amb_rest_lean@world_human_lean@wall@smoking@male_a@idle_a", anim = "idle_a", flag = 1,
		tags = { "lean", "wall", "smoke", "idle" },
		femaleAnim = { dict = "amb_rest_lean@world_human_lean@wall@smoking@female_a@idle_a", anim = "idle_a", flag = 1 },
	},
	{
		name = "lean_railing", label = "Lean on Railing", category = "Social",
		description = "Lean on a railing.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_RAILING",
		tags = { "lean", "railing", "idle" },
		conditionalAnim = "WORLD_HUMAN_LEAN_RAILING_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_LEAN_RAILING_FEMALE_A",
	},
	{
		name = "lean_post", label = "Lean on Post", category = "Social",
		description = "Lean against a post.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_POST_LEFT",
		tags = { "lean", "post", "idle" },
		conditionalAnim = "WORLD_HUMAN_LEAN_POST_LEFT_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_LEAN_POST_LEFT_FEMALE_A",
	},
	{
		name = "lean_fence", label = "Lean on Fence", category = "Social",
		description = "Lean on a fence, watching the livestock.",
		type = "anim",
		dict = "amb_rest_lean@world_human_lean_fence_fwd_check_out_livestock@male_e@idle_c", anim = "idle_g", flag = 1,
		tags = { "lean", "fence", "idle" }
	},
	{
		name = "hands_belt", label = "Hands on Belt", category = "Social",
		description = "Stand casually with your hands on your belt.",
		type = "anim",
		dict = "mech_loco@generic@spectator@b@streamed_idles", anim = "idle_c", flag = 1,
		tags = { "social", "idle", "stand" }
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_POCKET_MIRROR never took hold on a
		-- player ped - confirmed via Config.Debug. amb_misc@
		-- world_human_pocket_mirror is the exact same "checking yourself in
		-- a pocket mirror" motion as a plain dict.
		name = "check_appearance", label = "Check Appearance", category = "Social",
		description = "Check yourself over with a pocket mirror.",
		type = "anim",
		dict = "amb_misc@world_human_pocket_mirror@female_a@idle_a", anim = "idle_a", flag = 1,
		tags = { "social", "vanity", "mirror" }
	},
	{
		name = "calm_down", label = "Calm Down", category = "Social",
		description = "A calming, settle-down gesture.",
		type = "anim",
		dict = "mech_loco_m@character@arthur@calming@unarmed@idle", anim = "idle", flag = 1,
		tags = { "social", "calm" }
	},
	{
		-- [KIBOOK] prop emote
		name = "use_fan_right", label = "Fan Yourself (Right Hand)", category = "Social",
		description = "Cool off with a hand fan.",
		type = "anim",
		dict = "amb_wander@code_human_fan_wander@female_a@base", anim = "base", flag = 25,
		canMove = true,
		prop = {
			model = "p_cs_fan01x", bone = "skel_r_hand",
			position = vector3(0.1, 0, -0.035), rotation = vector3(0, 150, -9)
		},
		tags = { "fan", "social", "hot" }
	},
	{
		-- [KIBOOK] prop emote
		name = "use_fan_left", label = "Fan Yourself (Left Hand)", category = "Social",
		description = "Cool off with a hand fan, seated.",
		type = "anim",
		dict = "amb_camp@prop_camp_marybeth_seat_chair@fan@female_a@base", anim = "base", flag = 25,
		canMove = true,
		prop = {
			model = "p_cs_fan01x", bone = "skel_l_hand",
			position = vector3(0.07, 0.02, 0.04), rotation = vector3(-20, 0, 0)
		},
		tags = { "fan", "social", "hot" }
	},
	{
		-- [KIBOOK] prop emote
		name = "use_parasol", label = "Use Parasol", category = "Social",
		description = "Shield yourself from the sun with a parasol.",
		type = "anim",
		dict = "amb_rest_sit@prop_human_seat_bench@parasol@female_a@wip_base", anim = "wip_base", flag = 25,
		canMove = true,
		prop = {
			model = "p_parasol02x", bone = "skel_r_hand",
			position = vector3(0.07, -0.04, -0.02), rotation = vector3(-90.0, 0.0, 0.0)
		},
		tags = { "parasol", "social", "sun" }
	},

	-- ======================================================================
	-- COMBAT
	-- ======================================================================
	{
		-- [KIBOOK] the "attacker" half of the shared "hostage" emote, usable solo
		name = "threaten", label = "Threaten", category = "Combat",
		description = "Hold someone at gunpoint.",
		type = "anim",
		dict = "mech_grapple@blade@_male@_ambient@_healthy@back@loco@attacker", anim = "idle", flag = 1,
		allowWeapon = true, allowCombat = true,
		tags = { "combat", "threaten", "hostage" }
	},
	{
		name = "kneel_hostage", label = "Kneel", category = "Combat",
		description = "Kneel down, hands raised.",
		type = "anim",
		dict = "mini_hostage", anim = "gped_host_knl_idl", flag = 1,
		tags = { "combat", "kneel", "surrender" }
	},
	{
		name = "stand_guard", label = "Stand Guard", category = "Combat",
		description = "Stand watch, alert and ready.",
		type = "anim",
		dict = "script_common@other@unapproved", anim = "stand_guard@idle_a", flag = 1,
		allowWeapon = true, allowCombat = true,
		tags = { "combat", "guard", "watch" }
	},

	-- ======================================================================
	-- MISC
	-- ======================================================================
	{
		name = "itch", label = "Itch", category = "Misc",
		description = "Scratch an itch.",
		type = "anim",
		dict = "mech_loco_m@generic@special@unarmed@itchy@idle", anim = "idle_intro", flag = 1,
		tags = { "misc", "itch" }
	},
	{
		name = "sick", label = "Feeling Sick", category = "Misc",
		description = "Look queasy and unwell.",
		type = "anim",
		dict = "amb_wander@upperbody_idles@sick@both_arms@male_a@idle_a", anim = "idle_c", flag = 1,
		tags = { "misc", "sick" }
	},
	{
		name = "cough", label = "Cough", category = "Misc",
		description = "A rough coughing fit.",
		type = "anim",
		dict = "amb_misc@world_human_coughing@male_c@wip_base", anim = "wip_base", flag = 1,
		tags = { "misc", "cough", "sick" }
	},
	{
		name = "fan_self_hot", label = "Fan Self (No Prop)", category = "Misc",
		description = "Fan yourself with your hand.",
		type = "anim",
		dict = "mech_loco_m@generic@fidgets@hot", anim = "both_hands_fanning_02", flag = 1,
		tags = { "misc", "hot", "fan" }
	},
	{
		name = "drunk_idle", label = "Drunk Idle", category = "Misc",
		description = "Sway unsteadily, clearly drunk.",
		type = "anim",
		dict = "mech_loco_m@generic@drunk@unarmed@idle_moderate_drunk", anim = "idle", flag = 1,
		tags = { "misc", "drunk" }
	},
	{
		name = "badass", label = "Tough Stance", category = "Misc",
		description = "A tough, badass standing pose.",
		type = "scenario", scenario = "WORLD_HUMAN_BADASS",
		tags = { "misc", "tough", "stance" },
		conditionalAnim = "WORLD_HUMAN_BADASS_MALE_A",
		gender = "male", -- the game has no female version of this one
	},

	-- ======================================================================
	-- MORE GESTURES - sourced from ingameanims_list.lua/megadictanims.lua's
	-- "ai_gestures@gen_female@standing@silent"/"@speaker" dicts, the exact
	-- same proven family already used above for nod/discreet_wave/
	-- sarcastic_wave. Every dict+clip pair below was confirmed to exist in
	-- that dump before being added.
	-- ======================================================================
	{
		name = "shrug", label = "Shrug", category = "Reactions",
		description = "An annoyed shrug.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@speaker", anim = "annoyed_shrug_f_001", flag = 1,
		tags = { "reaction", "shrug", "annoyed" }
	},
	{
		name = "shrug_confused", label = "Confused Shrug", category = "Reactions",
		description = "A confused, unsure shrug.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@speaker", anim = "confused_shrug_f_001", flag = 1,
		tags = { "reaction", "shrug", "confused" }
	},
	{
		name = "damn_it", label = "Damn It!", category = "Reactions",
		description = "A frustrated \"damn it\" gesture.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@speaker", anim = "damn_it_f_001", flag = 1,
		tags = { "reaction", "frustrated" }
	},
	{
		name = "curious_nod", label = "Curious Nod", category = "Reactions",
		description = "A curious, interested nod.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@speaker", anim = "curious_nod_f_001", flag = 1,
		tags = { "reaction", "curious", "nod" }
	},
	{
		name = "curious_headshake", label = "Curious Headshake", category = "Reactions",
		description = "A puzzled headshake.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@speaker", anim = "curious_headshake_f_001", flag = 1,
		tags = { "reaction", "curious", "confused" }
	},
	{
		name = "cheer", label = "Cheer", category = "Reactions",
		description = "A happy cheer.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_happy_cheer_l_001", flag = 1,
		tags = { "reaction", "happy", "cheer" }
	},
	{
		name = "look_down_timid", label = "Look Down (Timid)", category = "Reactions",
		description = "Look down, timid and uneasy.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "aknwoledge_timid_look_down_f_001", flag = 1,
		tags = { "reaction", "timid", "nervous" },
		maleAnim = { dict = "ai_gestures@gen_male@standing@silent", anim = "aknwoledge_timid_look_down_f_001", flag = 1 },
	},
	{
		name = "point_accuse", label = "Point (Accusing)", category = "Social",
		description = "Point accusingly at someone.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@speaker", anim = "angry_point_l_003", flag = 1,
		tags = { "social", "point", "accuse", "angry" },
		maleAnim = { dict = "ai_gestures@gen_male@standing@speaker", anim = "angry_point_l_003", flag = 1 },
	},
	{
		name = "chastise", label = "Scold", category = "Social",
		description = "Scold someone with a wagging hand.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@speaker", anim = "annoyed_chastise_l_001", flag = 1,
		tags = { "social", "scold", "annoyed" }
	},
	{
		name = "plead", label = "Plead", category = "Social",
		description = "Plead with open hands.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_defensive_plead_f_001", flag = 1,
		tags = { "social", "plead", "defensive" }
	},
	{
		name = "chin_up", label = "Chin Up (Tough)", category = "Social",
		description = "Lift your chin, tough and unbothered.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "aknwoledge_tough_chin_up_f_001", flag = 1,
		tags = { "social", "tough", "confident" },
		maleAnim = { dict = "ai_gestures@gen_male@standing@silent", anim = "aknwoledge_tough_chin_up_f_001", flag = 1 },
	},
	{
		name = "get_attention", label = "Get Attention", category = "Greetings",
		description = "Wave a hand to get someone's attention.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_get_attention_l_001", flag = 1,
		tags = { "greeting", "attention" }
	},
	{
		name = "greet_distance", label = "Greet from a Distance", category = "Greetings",
		description = "Greet someone across the way.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_greet_distance_l_001", flag = 1,
		tags = { "greeting", "wave" },
		maleAnim = { dict = "ai_gestures@gen_male@standing@silent", anim = "silent_greet_distance_l_001", flag = 1 },
	},
	{
		name = "intimidate_point", label = "Intimidating Point", category = "Combat",
		description = "Point at someone to intimidate them.",
		type = "anim",
		dict = "ai_gestures@gen_female@standing@silent", anim = "silent_intimidation_witness_01", flag = 1,
		allowWeapon = true, allowCombat = true,
		tags = { "combat", "intimidate", "point" },
		maleAnim = { dict = "ai_gestures@gen_male@standing@silent", anim = "silent_intimidation_witness_01", flag = 1 },
	},

	-- ------------------------------------------------------------------
	-- Companion dog / pet emotes - REMOVED FOR NOW (per request). Kept
	-- here commented out, not deleted, so they're a one-line uncomment
	-- away from coming back. All 12 entries below are [KIBOOK] - the
	-- exact, already-installed & working kibook/redm-emotes definitions -
	-- so if they're restored later they don't need re-verifying.
	-- ------------------------------------------------------------------
	--[[
	{
		name = "dogbarkground", label = "Dog: Bark on Ground", category = "Misc",
		description = "Bark on the ground like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_barking_ground@base", anim = "base", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogbarkup", label = "Dog: Bark Up", category = "Misc",
		description = "Bark upward like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_barking_up@base", anim = "base", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogbeg", label = "Dog: Beg", category = "Misc",
		description = "Beg like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_begging@idle", anim = "idle_a", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogrest", label = "Dog: Rest", category = "Misc",
		description = "Rest like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_resting@base", anim = "base", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogroll", label = "Dog: Roll", category = "Misc",
		description = "Roll on the ground like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_roll_ground@base", anim = "base", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogsit", label = "Dog: Sit", category = "Misc",
		description = "Sit like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_sitting@base", anim = "base", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogsleep", label = "Dog: Sleep", category = "Misc",
		description = "Sleep like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_sleeping@base", anim = "base", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogsniff", label = "Sniff", category = "Misc",
		description = "Sniff the ground like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@world_dog_sniffing_ground@base", anim = "base", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		name = "dogwagtail", label = "Dog: Wag Tail", category = "Misc",
		description = "Wag like a happy dog (roleplay).",
		type = "anim",
		dict = "creatures_mammal@dog_pers@happy@idle", anim = "idle", flag = 1,
		tags = { "dog", "companion", "misc" }
	},
	{
		-- [KIBOOK] prop emotes - dog bone
		name = "dogbone", label = "Hold Dog Bone", category = "Misc",
		description = "Hold a dog bone.",
		type = "anim", dict = nil, anim = nil,
		prop = {
			model = "p_dogbone01x", bone = "skel_head",
			position = vector3(0.18, 0.02, 0.0), rotation = vector3(0.0, 90.0, 0.0)
		},
		tags = { "dog", "prop", "misc" }
	},
	{
		name = "dogchewbone", label = "Chew on Bone", category = "Misc",
		description = "Chew on a bone like a dog (roleplay).",
		type = "anim",
		dict = "amb_creature_mammal@prop_dog_eat_bone@base", anim = "base", flag = 1,
		prop = {
			model = "p_dogbone01x", bone = "skel_head",
			position = vector3(0.18, 0.02, 0.0), rotation = vector3(0.0, 90.0, 0.0)
		},
		tags = { "dog", "prop", "misc" }
	},
	{
		name = "pet_dog", label = "Pet (Solo)", category = "Misc",
		description = "Crouch down and pet the air in front of you.",
		type = "anim",
		dict = "mech_animal_interaction@dog@patting@1h", anim = "base", flag = 1,
		tags = { "dog", "companion", "pet" }
	},
	--]]
}

-- Fast lookup by unique name, built once at load time (used by both client
-- and server since this file is loaded in both contexts).
EmotesIndex = {}
for _, entry in ipairs(Config.Emotes) do
	EmotesIndex[entry.name] = entry
end
