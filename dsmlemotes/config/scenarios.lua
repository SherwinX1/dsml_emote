-- ============================================================================
-- DSML EMOTES - SCENARIO DEFINITIONS
-- ============================================================================
-- Most entries play via TaskStartScenarioInPlace(scenario, ...) - every one of
-- those MUST set type = "scenario" (client/main.lua's StartEmoteEntry
-- dispatches on that field; without it an entry silently does nothing instead
-- of playing - see config/emotes.lua's own scenario entries, e.g.
-- lean_wall/sit_ground, for the same convention). Scenario names (and, where
-- set, conditionalAnim) are real RDR2 identifiers taken verbatim from
-- scenario_types_with_conditional_anims.lua (a community-sourced dump of
-- every scenario type and its valid "conditional anim" variants, cross-
-- referenced against the game's own amb_rest.meta/amb_rest_CA.meta) - see the
-- README for sourcing notes. Unlike anim dicts, TaskStartScenarioInPlace
-- never throws or crashes on an unrecognised name - worst case the ped simply
-- performs no visible action, which is why every entry here is safe to ship
-- even at "best effort" confidence. Verify in-game and prune/replace as
-- needed.
--
-- A handful of entries below are marked [ANIM FALLBACK] and set
-- type = "anim" instead. These were originally type = "scenario" but,
-- per in-game testing with Config.Debug on, never actually took hold on a
-- player-controlled ped (IsPedUsingAnyScenario stayed false ~0.5s after
-- starting - see client/animation.lua's debugCheckScenario) even with a
-- conditionalAnim pin. Cross-referencing ingameanims_list.lua/
-- megadictanims.lua (full anim dict/clip dumps of everything in the game)
-- turned up the exact same underlying motion as a plain anim dict+clip, which
-- IS reliably playable via TaskPlayAnim regardless of the scenario system's
-- player-vs-NPC gating - so these play that directly instead of going through
-- the scenario system at all. They keep their original name/category/tags so
-- nothing else about the catalogue changes.
--
-- Schema:
-- {
--     name        = "unique_id",
--     label       = "Display Name",
--     category    = "Town",       -- one of the SCENARIO_CATEGORIES below
--     description = "Shown as a tooltip in the menu.",
--     type        = "scenario",   -- REQUIRED for scenario playback, see above
--     scenario    = "SCENARIO_TYPE_NAME",
--     conditionalAnim = "EXACT_ANIM_NAME", -- optional, male variant - see below
--     conditionalAnimFemale = "EXACT_ANIM_NAME", -- optional, female variant
--     gender      = "male",       -- optional, only that gender can use it
--     femaleAnim  = { dict = "...", anim = "...", flag = 1 }, -- optional, female plays this instead
--     -- [ANIM FALLBACK] entries use these instead of scenario/conditionalAnim:
--     dict        = "anim_dict",
--     anim        = "anim_name",
--     flag        = 1,
--     restricted  = false,        -- false OR { jobs = { "police", ... } }
--     tags        = { "tag1", "tag2" },
-- }
--
-- Male / female (the game decides which variants a ped may play by gender, and
-- some are NPC-only, so leaving it to chance often did nothing on a player):
--   conditionalAnim       = the variant a MALE character plays
--   conditionalAnimFemale = the variant a FEMALE character plays
--     (both taken from scenario_types_with_conditional_anims.lua; if a pinned
--     variant still won't start, client/animation.lua retries with the game's own pick)
--   gender = "male"       = the game has NO female version - hidden from female
--                           characters' menus instead of silently doing nothing
--   femaleAnim / maleAnim = { dict, anim, flag } - plain animation the other gender
--                           plays instead (e.g. the female sit-on-steps clip)
-- ============================================================================

Config.ScenarioCategories = {
	"Town", "Camp", "Lean", "Sit & Rest", "Sleep",
	"Drink & Smoke", "Music", "Read & Write", "Work", "Farming", "Mining",
	"Fishing", "Hunting", "Guard & Stoic", "Misc"
}

Config.Scenarios = {
	-- ------------------------------------------------------------------
	-- Lean (lean_wall/lean_railing/lean_post/lean_fence already cover the
	-- plain idle poses over in config/emotes.lua - these are the more
	-- specific compound variants)
	-- ------------------------------------------------------------------
	{
		name = "lean_railing_smoke", label = "Lean & Smoke (Railing)", category = "Lean",
		description = "Lean on a railing, smoking.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_RAILING_SMOKING",
		restricted = false, tags = { "lean", "railing", "smoke" },
		conditionalAnim = "WORLD_HUMAN_LEAN_RAILING_SMOKING_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_LEAN_RAILING_SMOKING_FEMALE_A",
	},
	{
		name = "lean_railing_drink", label = "Lean & Drink (Railing)", category = "Lean",
		description = "Lean on a railing, drinking.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_RAILING_DRINKING",
		conditionalAnim = "WORLD_HUMAN_LEAN_RAILING_DRINKING_MALE_B",
		restricted = false, tags = { "lean", "railing", "drink" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "lean_back_railing_drink", label = "Lean Back & Drink (Railing)", category = "Lean",
		description = "Lean back on a railing, drinking.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_BACK_RAILING_DRINKING",
		conditionalAnim = "WORLD_HUMAN_LEAN_BACK_RAILING_DRINKING_MALE_A",
		restricted = false, tags = { "lean", "railing", "drink" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "lean_post_right", label = "Lean on Post (Right)", category = "Lean",
		description = "Lean against a post.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_POST_RIGHT",
		restricted = false, tags = { "lean", "post" },
		conditionalAnim = "WORLD_HUMAN_LEAN_POST_RIGHT_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_LEAN_POST_RIGHT_FEMALE_A",
	},
	{
		name = "lean_barrel_read", label = "Lean on Barrel, Reading", category = "Lean",
		description = "Lean on a barrel, reading a paper.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_BARREL",
		conditionalAnim = "WORLD_HUMAN_LEAN_BARREL_READ_PAPER_MALE_A",
		restricted = false, tags = { "lean", "read", "paper" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "lean_read_paper", label = "Lean, Reading a Paper", category = "Lean",
		description = "Lean and read a paper.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_READ_PAPER",
		conditionalAnim = "WORLD_HUMAN_LEAN_READ_PAPER_MALE_A",
		restricted = false, tags = { "lean", "read", "paper" },
		gender = "male", -- the game has no female version of this one
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_LEAN_BAR_READ_NEWSPAPER never took hold
		-- on a player ped even pinned. amb_misc@world_human_bar_read_paper is
		-- the same "leaning at the bar reading a paper" motion as a plain dict.
		name = "lean_bar_read_newspaper", label = "Lean at Bar, Reading", category = "Lean",
		description = "Lean at a bar counter, reading a newspaper.",
		type = "anim",
		dict = "amb_misc@world_human_bar_read_paper@wip_base@male_a", anim = "wip_base", flag = 1,
		restricted = false, tags = { "lean", "bar", "read", "newspaper" },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_LEAN_CHECK_PISTOL never took hold on a
		-- player ped even pinned - amb_rest_lean@...check_pistol is the same
		-- motion as a plain dict.
		name = "lean_check_pistol", label = "Lean, Check Pistol", category = "Lean",
		description = "Lean and check over a pistol.",
		type = "anim",
		dict = "amb_rest_lean@world_human_lean@wall@check_pistol@male_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "lean", "pistol" },
	},
	{
		name = "lean_sharpen_knife", label = "Lean, Sharpen Knife", category = "Lean",
		description = "Lean at a table, sharpening a knife.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_TABLE_SHARPEN_KNIFE",
		conditionalAnim = "WORLD_HUMAN_LEAN_TABLE_SHARPEN_KNIFE_MALE_A",
		restricted = false, tags = { "lean", "knife", "sharpen" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "lean_whittle", label = "Lean & Whittle", category = "Lean",
		description = "Lean back, whittling a stick.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_BACK_WHITTLE",
		conditionalAnim = "WORLD_HUMAN_LEAN_BACK_WHITTLE_MALE_D",
		restricted = false, tags = { "lean", "whittle" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "lean_fence_watch", label = "Lean on Fence, Watching", category = "Lean",
		description = "Lean on a fence, watching livestock.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_FENCE_FWD_CHECK_OUT_LIVESTOCK",
		restricted = false, tags = { "lean", "fence", "farm" },
		conditionalAnim = "WORLD_HUMAN_LEAN_FENCE_FWD_CHECK_OUT_LIVESTOCK_MALE_E",
		gender = "male", -- the game has no female version of this one
	},
	-- lean_back_wall_smoke (dupe of emotes.lua's now-fixed "lean_smoke") and
	-- lean_back_wall_drink were both removed: WORLD_HUMAN_LEAN_BACK_WALL_
	-- SMOKING/DRINKING never took hold on a player ped, and unlike the
	-- lean-check-pistol/bar-read cases above, no standalone "leaning against
	-- a wall while drinking" anim dict exists in ingameanims_list.lua/
	-- megadictanims.lua to fall back to - only bar-counter and railing
	-- drinking dicts do, and those are already covered by lean_railing_drink/
	-- lean_back_railing_drink/drink_at_bar above and below.

	-- ------------------------------------------------------------------
	-- Sit & Rest (ground/ledge - chairs and benches need a real prop nearby
	-- to look right, so they aren't offered as generic menu entries here)
	-- ------------------------------------------------------------------
	{
		name = "sit_ground_reading_book", label = "Sit & Read a Book", category = "Sit & Rest",
		description = "Sit on the ground reading a book.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_GROUND_READING_BOOK",
		restricted = false, tags = { "sit", "read", "book" },
		conditionalAnim = "WORLD_HUMAN_SIT_GROUND_READING_BOOK_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_GROUND_READING_BOOK_FEMALE_A",
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_SIT_GROUND_READING_JOURNAL never took
		-- hold on a player ped even pinned - amb_rest_sit@...read_journal is
		-- the same motion as a plain dict.
		name = "sit_ground_reading_journal", label = "Sit & Read a Journal", category = "Sit & Rest",
		description = "Sit on the ground reading a journal.",
		type = "anim",
		dict = "amb_rest_sit@world_human_sit_ground@read_journal@female_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "sit", "read", "journal" },
	},
	{
		name = "sit_ground_reading_paper", label = "Sit & Read a Newspaper", category = "Sit & Rest",
		description = "Sit on the ground reading a newspaper.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_GROUND_READ_NEWSPAPER",
		conditionalAnim = "WORLD_HUMAN_SIT_GROUND_READING_NEWSPAPER_MALE_A",
		restricted = false, tags = { "sit", "read", "newspaper" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "sit_ground_whittle", label = "Sit & Whittle", category = "Sit & Rest",
		description = "Sit on the ground, whittling a stick.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_GROUND_WHITTLE",
		conditionalAnim = "WORLD_HUMAN_SIT_GROUND_WHITTLE_MALE_B",
		restricted = false, tags = { "sit", "whittle" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "sit_ground_coffee", label = "Sit & Drink Coffee", category = "Sit & Rest",
		description = "Sit on the ground drinking coffee.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_GROUND_COFFEE_DRINK",
		restricted = false, tags = { "sit", "coffee", "drink" },
		conditionalAnim = "WORLD_HUMAN_SIT_GROUND_COFFEE_DRINK_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_GROUND_COFFEE_DRINK_FEMALE_A",
	},
	{
		name = "sit_ground_smoke", label = "Sit & Smoke", category = "Sit & Rest",
		description = "Sit on the ground, smoking.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_SMOKE",
		restricted = false, tags = { "sit", "smoke" },
		conditionalAnim = "WORLD_HUMAN_SIT_SMOKE_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_SMOKE_FEMALE_A",
	},
	{
		name = "sit_ground_drink", label = "Sit & Drink", category = "Sit & Rest",
		description = "Sit on the ground, drinking.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_DRINK",
		restricted = false, tags = { "sit", "drink" },
		conditionalAnim = "WORLD_HUMAN_SIT_DRINK_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_DRINK_FEMALE_A",
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_SIT_GROUND_SKETCHING never took hold on
		-- a player ped even pinned - amb_rest_sit@...sketching is the same
		-- motion as a plain dict.
		name = "sit_ground_sketch", label = "Sit & Sketch", category = "Sit & Rest",
		description = "Sit on the ground, sketching.",
		type = "anim",
		dict = "amb_rest_sit@world_human_sit_ground@sketching@female_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "sit", "sketch", "draw" },
	},
	{
		name = "sit_ledge", label = "Sit on Ledge", category = "Sit & Rest",
		description = "Sit on a ledge.",
		type = "scenario", scenario = "WORLD_HUMAN_SEAT_LEDGE",
		conditionalAnim = "WORLD_HUMAN_SEAT_LEDGE_NEW_MALE_A",
		restricted = false, tags = { "sit", "ledge" },
		femaleAnim = { dict = "amb_rest_sit@world_human_seat_ledge@male_a@base", anim = "base", flag = 1 },
	},
	{
		name = "sit_steps", label = "Sit on Steps", category = "Sit & Rest",
		description = "Sit on a set of steps.",
		type = "scenario", scenario = "WORLD_HUMAN_SEAT_STEPS",
		conditionalAnim = "WORLD_HUMAN_SEAT_STEPS_MALE_A",
		restricted = false, tags = { "sit", "steps" },
		femaleAnim = { dict = "amb_temp@world_human_seat_steps@female@hands_by_sides@base", anim = "base", flag = 1 },
	},
	{
		name = "sit_exhausted", label = "Sit, Exhausted", category = "Sit & Rest",
		description = "Sit back, exhausted.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_BACK_EXHAUSTED",
		restricted = false, tags = { "sit", "tired", "exhausted" },
		conditionalAnim = "WORLD_HUMAN_SIT_BACK_EXHAUSTED_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_BACK_EXHAUSTED_FEMALE_A",
	},

	-- ------------------------------------------------------------------
	-- Sleep
	-- ------------------------------------------------------------------
	{
		name = "nap_ground_arm", label = "Nap (Arm Pillow)", category = "Sleep",
		description = "Lie down and sleep, using your arm as a pillow.",
		type = "scenario", scenario = "WORLD_HUMAN_SLEEP_GROUND_ARM",
		restricted = false, tags = { "sleep", "nap", "ground" },
		conditionalAnim = "WORLD_HUMAN_SLEEP_GROUND_ARM_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_SLEEP_GROUND_ARM_FEMALE_A",
	},
	{
		name = "nap_ground_pillow", label = "Nap (Pillow)", category = "Sleep",
		description = "Lie down and sleep on a pillow.",
		type = "scenario", scenario = "WORLD_HUMAN_SLEEP_GROUND_PILLOW",
		restricted = false, tags = { "sleep", "nap", "ground", "pillow" },
		conditionalAnim = "WORLD_HUMAN_SLEEP_GROUND_PILLOW_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_SLEEP_GROUND_PILLOW_FEMALE_A",
	},
	{
		name = "passed_out_floor", label = "Passed Out", category = "Sleep",
		description = "Passed out flat on the floor.",
		type = "scenario", scenario = "WORLD_HUMAN_DRUNK_PASSED_OUT_FLOOR",
		conditionalAnim = "WORLD_HUMAN_DRUNK_PASSED_OUT_FLOOR_MALE_A",
		restricted = false, tags = { "sleep", "drunk", "passed out" },
		gender = "male", -- the game has no female version of this one
	},

	-- Chair & Bench category removed entirely (per request) - every
	-- PROP_HUMAN_SEAT_*/bench scenario in it needs a real chair/bench/stool
	-- prop already standing at the exact spot to look right at all, which a
	-- generic "play anywhere" menu entry can never guarantee, so in practice
	-- every one of them looked broken (ped sitting in mid-air on nothing) most
	-- of the time. The music "*_seated" entries below have the same caveat
	-- but were left in since they're clearly labelled as needing a chair/
	-- bench nearby.

	-- ------------------------------------------------------------------
	-- Drink & Smoke (standing)
	-- ------------------------------------------------------------------
	{
		name = "drink_standing", label = "Drink", category = "Drink & Smoke",
		description = "Stand and drink.",
		type = "scenario", scenario = "WORLD_HUMAN_DRINKING",
		restricted = false, tags = { "drink" },
		conditionalAnim = "WORLD_HUMAN_STAND_DRINK_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_STAND_DRINK_FEMALE_A",
	},
	{
		name = "drink_moonshine_standing", label = "Drink Moonshine", category = "Drink & Smoke",
		description = "Stand and drink moonshine.",
		type = "scenario", scenario = "WORLD_HUMAN_DRINKING_MOONSHINE",
		restricted = false, tags = { "drink", "moonshine" },
		conditionalAnim = "WORLD_HUMAN_STAND_DRINK_MOONSHINE_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_STAND_DRINK_MOONSHINE_FEMALE_A",
	},
	{
		name = "drink_flask", label = "Drink from Flask", category = "Drink & Smoke",
		description = "Drink from a flask.",
		type = "scenario", scenario = "WORLD_HUMAN_DRINK_FLASK",
		conditionalAnim = "WORLD_HUMAN_DRINK_FLASK_MALE_A",
		restricted = false, tags = { "drink", "flask" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "drink_coffee_standing", label = "Drink Coffee", category = "Drink & Smoke",
		description = "Stand and drink coffee.",
		type = "scenario", scenario = "WORLD_HUMAN_COFFEE_DRINK",
		restricted = false, tags = { "drink", "coffee" },
		conditionalAnim = "WORLD_HUMAN_COFFEE_DRINK_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_COFFEE_DRINK_FEMALE_C",
	},
	{
		name = "drink_champagne", label = "Drink Champagne", category = "Drink & Smoke",
		description = "Stand and drink champagne.",
		type = "scenario", scenario = "WORLD_HUMAN_DRINK_CHAMPAGNE",
		restricted = false, tags = { "drink", "champagne" },
		conditionalAnim = "WORLD_HUMAN_DRINK_CHAMPAGNE_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_DRINK_CHAMPAGNE_FEMALE_A",
	},
	{
		name = "drink_at_bar", label = "Drink at the Bar", category = "Drink & Smoke",
		description = "Lean at the bar and drink.",
		type = "scenario", scenario = "WORLD_HUMAN_BAR_DRINK_BARTENDER",
		conditionalAnim = "WORLD_HUMAN_BAR_DRINK_BARTENDER_MALE_A",
		restricted = false, tags = { "drink", "bar" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "smoke_standing", label = "Smoke a Cigarette", category = "Drink & Smoke",
		description = "Stand and smoke.",
		type = "scenario", scenario = "WORLD_HUMAN_SMOKE",
		restricted = false, tags = { "smoke", "cigarette" },
		conditionalAnim = "WORLD_HUMAN_SMOKE_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SMOKE_FEMALE_A",
	},
	{
		name = "smoke_cigar_standing", label = "Smoke a Cigar", category = "Drink & Smoke",
		description = "Stand and smoke a cigar.",
		type = "scenario", scenario = "WORLD_HUMAN_SMOKE_CIGAR",
		conditionalAnim = "WORLD_HUMAN_SMOKE_CIGAR_MALE_A",
		restricted = false, tags = { "smoke", "cigar" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "drunk_brace_wall", label = "Drunk, Bracing Wall", category = "Drink & Smoke",
		description = "Brace yourself against a wall, drunk.",
		type = "scenario", scenario = "WORLD_HUMAN_DRUNK_BRACE_WALL_NO_VOMIT",
		restricted = false, tags = { "drunk", "wall" },
		conditionalAnim = "WORLD_HUMAN_DRUNK_BRACE_WALL_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_DRUNK_BRACE_WALL_FEMALE_A",
	},

	-- ------------------------------------------------------------------
	-- Music (the pickup/putdown one-shots were removed per request - the
	-- "*_seated" ones need a chair/bench nearby, same caveat as above)
	-- ------------------------------------------------------------------
	{
		name = "guitar_seated", label = "Sit & Play Guitar", category = "Music",
		description = "Sit and play guitar.",
		type = "scenario", scenario = "PROP_HUMAN_SEAT_CHAIR_GUITAR",
		conditionalAnim = "PROP_HUMAN_SEAT_CHAIR_GUITAR_MALE_A",
		restricted = false, tags = { "music", "guitar", "sit" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "banjo_seated", label = "Sit & Play Banjo", category = "Music",
		description = "Sit and play banjo.",
		type = "scenario", scenario = "PROP_HUMAN_SEAT_CHAIR_BANJO",
		conditionalAnim = "PROP_HUMAN_SEAT_CHAIR_BANJO_MALE_A",
		restricted = false, tags = { "music", "banjo", "sit" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "fiddle_seated", label = "Sit & Play Fiddle", category = "Music",
		description = "Sit on a bench and play fiddle.",
		type = "scenario", scenario = "PROP_HUMAN_SEAT_BENCH_FIDDLE",
		conditionalAnim = "PROP_HUMAN_SEAT_BENCH_FIDDLE",
		restricted = false, tags = { "music", "fiddle", "sit" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "mandolin_seated", label = "Sit & Play Mandolin", category = "Music",
		description = "Sit on a bench and play mandolin.",
		type = "scenario", scenario = "PROP_HUMAN_SEAT_BENCH_MANDOLIN",
		conditionalAnim = "PROP_HUMAN_SEAT_BENCH_MANDOLIN_MALE",
		restricted = false, tags = { "music", "mandolin", "sit" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "trumpet_play", label = "Play Trumpet", category = "Music",
		description = "Stand and play trumpet.",
		type = "scenario", scenario = "WORLD_HUMAN_TRUMPET",
		conditionalAnim = "WORLD_HUMAN_TRUMPET_MALE_A",
		restricted = false, tags = { "music", "trumpet" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "harmonica_seated", label = "Sit & Play Harmonica", category = "Music",
		description = "Sit on a bench and play harmonica.",
		type = "scenario", scenario = "PROP_HUMAN_SEAT_BENCH_HARMONICA",
		conditionalAnim = "PROP_HUMAN_SEAT_BENCH_HARMONICA",
		restricted = false, tags = { "music", "harmonica", "sit" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "piano_seated", label = "Sit & Play Piano", category = "Music",
		description = "Sit and play piano - needs an actual piano prop nearby to look right.",
		type = "scenario", scenario = "PROP_HUMAN_PIANO",
		conditionalAnim = "PROP_HUMAN_PIANO",
		restricted = false, tags = { "music", "piano", "sit" },
		femaleAnim = { dict = "amb_misc@prop_human_piano@female_a@base", anim = "base", flag = 1 },
	},

	-- ------------------------------------------------------------------
	-- Read & Write
	-- ------------------------------------------------------------------
	{
		name = "write_notebook", label = "Write in Notebook", category = "Read & Write",
		description = "Stand and write in a notebook.",
		type = "scenario", scenario = "WORLD_HUMAN_WRITE_NOTEBOOK",
		restricted = false, tags = { "write", "notebook" },
		conditionalAnim = "WORLD_HUMAN_WRITE_NOTEBOOK_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_WRITE_NOTEBOOK_FEMALE_A",
	},

	-- ------------------------------------------------------------------
	-- Work (the pickup/putdown one-shots were removed per request)
	-- ------------------------------------------------------------------
	{
		name = "broom_sweep", label = "Sweep with Broom", category = "Work",
		description = "Sweep with a broom.",
		type = "scenario", scenario = "WORLD_HUMAN_BROOM_WORKING",
		restricted = false, tags = { "work", "broom", "sweep" },
		conditionalAnim = "WORLD_HUMAN_BROOM_WORKING_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_BROOM_WORKING_FEMALE_B",
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_HAMMER_TABLE never took hold on a
		-- player ped even pinned - amb_work@world_human_hammer@table is the
		-- same motion as a plain dict.
		name = "hammer_table", label = "Hammer (Table)", category = "Work",
		description = "Hammer something on a table.",
		type = "anim",
		dict = "amb_work@world_human_hammer@table@male_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "work", "hammer" },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_HAMMER_WALL never took hold on a
		-- player ped even pinned - amb_work@world_human_hammer@wall is the
		-- same motion as a plain dict.
		name = "hammer_wall", label = "Hammer (Wall)", category = "Work",
		description = "Hammer something on a wall.",
		type = "anim",
		dict = "amb_work@world_human_hammer@wall@male_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "work", "hammer" },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_SAW_WOOD never took hold on a player
		-- ped even pinned - amb_work@world_human_saw_wood is the same motion
		-- as a plain dict.
		name = "saw_wood", label = "Saw Wood", category = "Work",
		description = "Saw a piece of wood.",
		type = "anim",
		dict = "amb_work@world_human_saw_wood@male_a@base", anim = "base", flag = 1,
		restricted = false, tags = { "work", "saw", "wood" },
	},
	{
		name = "wagon_wheel_repair", label = "Repair Wagon Wheel", category = "Work",
		description = "Kneel and repair a wagon wheel.",
		type = "scenario", scenario = "PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL",
		conditionalAnim = "PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_SMALL_MALE_A",
		restricted = false, tags = { "work", "wagon", "repair" },
		gender = "male", -- the game has no female version of this one
	},
	{
		-- [ANIM FALLBACK] PROP_HUMAN_GRINDSTONE never took hold on a player
		-- ped even pinned - amb_work@prop_human_grindstone is the same motion
		-- as a plain dict.
		name = "grindstone_sharpen", label = "Sharpen at Grindstone", category = "Work",
		description = "Sharpen a blade at a grindstone.",
		type = "anim",
		dict = "amb_work@prop_human_grindstone@male_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "work", "grindstone", "sharpen" },
	},
	{
		name = "clean_table_scenario", label = "Clean a Table", category = "Work",
		description = "Wipe down a table.",
		type = "scenario", scenario = "WORLD_HUMAN_CLEAN_TABLE",
		restricted = false, tags = { "work", "clean" },
		conditionalAnim = "WORLD_HUMAN_CLEAN_TABLE_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_CLEAN_TABLE_FEMALE_B",
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_CLEAN_WINDOW never took hold on a
		-- player ped even pinned - amb_work@world_human_clean_window is the
		-- same motion as a plain dict.
		name = "clean_window", label = "Clean a Window", category = "Work",
		description = "Wipe down a window.",
		type = "anim",
		dict = "amb_work@world_human_clean_window@female_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "work", "clean", "window" },
	},

	-- ------------------------------------------------------------------
	-- Farming
	-- ------------------------------------------------------------------
	{
		name = "feed_chicken", label = "Feed Chickens", category = "Farming",
		description = "Feed the chickens.",
		type = "scenario", scenario = "WORLD_HUMAN_FEED_CHICKEN",
		restricted = false, tags = { "farm", "chicken", "feed" },
		conditionalAnim = "WORLD_HUMAN_FEED_CHICKENS_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_FEED_CHICKENS_FEMALE_A",
	},
	{
		name = "feed_pigs", label = "Feed Pigs", category = "Farming",
		description = "Feed the pigs.",
		type = "scenario", scenario = "WORLD_HUMAN_FEED_PIGS",
		conditionalAnim = "WORLD_HUMAN_FEED_PIGS_MALE_A",
		restricted = false, tags = { "farm", "pigs", "feed" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "farmer_rake", label = "Rake Field", category = "Farming",
		description = "Rake a field.",
		type = "scenario", scenario = "WORLD_HUMAN_FARMER_RAKE",
		conditionalAnim = "WORLD_HUMAN_FARMER_RAKE_MALE_A",
		restricted = false, tags = { "farm", "rake" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "farmer_weeding", label = "Pull Weeds", category = "Farming",
		description = "Kneel and pull weeds.",
		type = "scenario", scenario = "WORLD_HUMAN_FARMER_WEEDING",
		conditionalAnim = "WORLD_HUMAN_FARMER_WEEDING_MALE_A",
		restricted = false, tags = { "farm", "weeding" },
		gender = "male", -- the game has no female version of this one
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_HORSE_TEND_BRUSH_LINK never took hold
		-- on a player ped even pinned. amb_work@...horse_tend_brush_link is
		-- the same motion as a plain dict - it's a "paired" animation
		-- authored to go with a horse standing in front of you, so it may
		-- look best used near one, but it plays and loops correctly either
		-- way (unlike the scenario, which simply never started).
		name = "horse_brush", label = "Brush a Horse", category = "Farming",
		description = "Brush down a nearby horse.",
		type = "anim",
		dict = "amb_work@world_human_horse_tend_brush_link@paired@male_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "farm", "horse", "brush" },
	},

	-- ------------------------------------------------------------------
	-- Mining
	-- ------------------------------------------------------------------
	{
		name = "pickaxe_wall", label = "Mine with Pickaxe", category = "Mining",
		description = "Swing a pickaxe at a wall.",
		type = "scenario", scenario = "WORLD_HUMAN_PICKAXE_WALL",
		conditionalAnim = "WORLD_HUMAN_PICKAXE_WALL_WORKING_MALE_D",
		restricted = false, tags = { "mine", "pickaxe" },
		gender = "male", -- the game has no female version of this one
	},
	{
		-- [ANIM FALLBACK] WORLD_VEHICLE_MINECART_COAL_SHOVEL never took hold
		-- on a player ped even pinned - amb_work@world_human_coal_shovel is
		-- the same motion as a plain dict.
		name = "minecart_shovel", label = "Shovel Coal (Minecart)", category = "Mining",
		description = "Shovel coal into a minecart.",
		type = "anim",
		dict = "amb_work@world_human_coal_shovel@male_a@base", anim = "base", flag = 1,
		restricted = false, tags = { "mine", "coal", "shovel" },
	},

	-- ------------------------------------------------------------------
	-- Fishing
	-- ------------------------------------------------------------------
	{
		name = "fishing_stand", label = "Stand & Fish", category = "Fishing",
		description = "Stand and fish.",
		type = "scenario", scenario = "WORLD_HUMAN_STAND_FISHING",
		conditionalAnim = "WORLD_HUMAN_STAND_FISHING_MALE_A",
		restricted = false, tags = { "fish", "stand" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "fishing_chair", label = "Sit & Fish (Chair)", category = "Fishing",
		description = "Sit in a chair, fishing.",
		type = "scenario", scenario = "PROP_HUMAN_SEAT_CHAIR_FISHING_ROD",
		conditionalAnim = "PROP_HUMAN_SEAT_CHAIR_FISHING_ROD_MALE_A",
		restricted = false, tags = { "fish", "chair", "sit" },
		gender = "male", -- the game has no female version of this one
	},
	{
		name = "crab_trap_chair", label = "Sit & Mend Crab Trap", category = "Fishing",
		description = "Sit and mend a crab trap.",
		type = "scenario", scenario = "PROP_HUMAN_SEAT_CHAIR_CRAB_TRAP",
		conditionalAnim = "PROP_HUMAN_SEAT_CHAIR_CRAB_TRAP_MALE_A",
		restricted = false, tags = { "fish", "crab", "chair" },
		gender = "male", -- the game has no female version of this one
	},

	-- ------------------------------------------------------------------
	-- Hunting (needs a nearby carcass to look fully right - the anim dicts
	-- below are still worth having since they at least reliably PLAY, unlike
	-- the scenario types they replace)
	-- ------------------------------------------------------------------
	{
		-- [ANIM FALLBACK] PROP_HUMAN_BUTCHER_DEER never took hold on a
		-- player ped. amb_camp@prop_camp_butcher@working@deer@...leg_slice
		-- is a real active butchering motion (cutting into the carcass) from
		-- the same dict family, played directly.
		name = "butcher_deer_scenario", label = "Butcher a Deer", category = "Hunting",
		description = "Butcher a deer carcass - stand over one for it to look right.",
		type = "anim",
		dict = "amb_camp@prop_camp_butcher@working@deer@male_a@leg_slice@base", anim = "base", flag = 1,
		restricted = false, tags = { "hunt", "butcher", "deer" },
		femaleAnim = { dict = "amb_camp@prop_camp_butcher@working@deer@female_a@leg_slice@base", anim = "base", flag = 1 },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_BUTCHER_RABBIT never took hold on a
		-- player ped. amb_camp@prop_camp_butcher@working@rabbit@...
		-- rabbit_chop is the equivalent active butchering motion, played
		-- directly.
		name = "butcher_rabbit_scenario", label = "Butcher a Rabbit", category = "Hunting",
		description = "Butcher a rabbit carcass - stand over one for it to look right.",
		type = "anim",
		dict = "amb_camp@prop_camp_butcher@working@rabbit@male_a@rabbit_chop@base", anim = "base", flag = 1,
		restricted = false, tags = { "hunt", "butcher", "rabbit" },
		femaleAnim = { dict = "amb_camp@prop_camp_butcher@working@rabbit@female_a@rabbit_chop@base", anim = "base", flag = 1 },
	},

	-- ------------------------------------------------------------------
	-- Guard & Stoic
	-- ------------------------------------------------------------------
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_GUARD_LAZY never took hold on a player
		-- ped even pinned - amb_work@world_human_guard@lazy is the same
		-- motion as a plain dict.
		name = "guard_lazy", label = "Guard, Relaxed", category = "Guard & Stoic",
		description = "Stand guard, relaxed.",
		type = "anim",
		dict = "amb_work@world_human_guard@lazy@male_b@base", anim = "base", flag = 1,
		restricted = false, tags = { "guard" },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_GUARD_LEAN_WALL never took hold on a
		-- player ped even pinned - amb_work@world_human_guard_lean@wall is
		-- the same motion as a plain dict.
		name = "guard_lean_wall", label = "Guard, Leaning", category = "Guard & Stoic",
		description = "Stand guard, leaning against a wall.",
		type = "anim",
		dict = "amb_work@world_human_guard_lean@wall@male_e@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "guard", "lean" },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_GUARD_MILITARY never took hold on a
		-- player ped even pinned - amb_work@world_human_guard@military is
		-- the same motion as a plain dict.
		name = "guard_military", label = "Guard, At Attention", category = "Guard & Stoic",
		description = "Stand guard, military-style.",
		type = "anim",
		dict = "amb_work@world_human_guard@military@male_b@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "guard", "military" },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_GUARD_SCOUT never took hold on a
		-- player ped even pinned - amb_work@world_human_guard@scout is the
		-- same motion as a plain dict.
		name = "guard_scout", label = "Guard, Scouting", category = "Guard & Stoic",
		description = "Stand guard, scouting the area.",
		type = "anim",
		dict = "amb_work@world_human_guard@scout@male_c@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "guard", "scout" },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_STARE_STOIC never took hold on a
		-- player ped even pinned - amb_misc@world_human_stare_stoic is the
		-- same motion as a plain dict.
		name = "stare_stoic_scenario", label = "Stare Stoically", category = "Guard & Stoic",
		description = "Stand and stare stoically into the distance.",
		type = "anim",
		dict = "amb_misc@world_human_stare_stoic@male_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "stare", "stoic" },
		femaleAnim = { dict = "amb_misc@world_human_stare_stoic@female_a@idle_a", anim = "idle_a", flag = 1 },
	},
	{
		-- Confirmed working in-game - left as a real scenario.
		name = "stand_waiting_scenario", label = "Stand & Wait", category = "Guard & Stoic",
		description = "Stand around, waiting.",
		type = "scenario", scenario = "WORLD_HUMAN_STAND_WAITING",
		restricted = false, tags = { "wait", "stand" },
		conditionalAnim = "WORLD_HUMAN_STAND_WAITING_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_STAND_WAITING_FEMALE_A",
	},
	{
		-- Confirmed working in-game - left as a real scenario.
		name = "wait_impatient_scenario", label = "Wait, Impatiently", category = "Guard & Stoic",
		description = "Stand around, waiting impatiently.",
		type = "scenario", scenario = "WORLD_HUMAN_WAITING_IMPATIENT",
		restricted = false, tags = { "wait", "impatient" },
		conditionalAnim = "WORLD_HUMAN_WAITING_IMPATIENT_MALE_D",
		conditionalAnimFemale = "WORLD_HUMAN_WAITING_IMPATIENT_FEMALE_A",
	},

	-- ------------------------------------------------------------------
	-- Town / Misc
	-- ------------------------------------------------------------------
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_SHOP_BROWSE never took hold on a
		-- player ped even pinned - amb_misc@world_human_shop_browse is the
		-- same motion as a plain dict.
		name = "shop_browse", label = "Browse Shop Shelves", category = "Town",
		description = "Browse a shop's shelves.",
		type = "anim",
		dict = "amb_misc@world_human_shop_browse@female_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "shop", "browse" },
	},
	{
		name = "shop_browse_counter", label = "Browse Shop Counter", category = "Town",
		description = "Browse items at a shop counter.",
		type = "scenario", scenario = "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
		conditionalAnim = "WORLD_HUMAN_SHOP_BROWSE_COUNTER_MALE_A",
		restricted = false, tags = { "shop", "browse", "counter" },
		femaleAnim = { dict = "amb_misc@world_human_shop_browse_counter@male_a@base", anim = "base", flag = 1 },
	},
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_NATURALIST_MICROSCOPE never took hold
		-- on a player ped even pinned - amb_misc@world_human_naturalist@
		-- microscope is the same motion as a plain dict.
		name = "naturalist_scope", label = "Naturalist's Microscope", category = "Town",
		description = "Peer through a microscope.",
		type = "anim",
		dict = "amb_misc@world_human_naturalist@microscope@female_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "naturalist", "microscope" },
	},
	-- dance_solo_scenario (WORLD_HUMAN_DANCING) removed: never took hold on
	-- a player ped even pinned, and is redundant anyway - config/emotes.lua's
	-- Dances category already has several confirmed-working plain anim
	-- entries (dance_confident, dance_wild, dance_old, ...).
	{
		-- [ANIM FALLBACK] WORLD_HUMAN_STIR_SOUP never took hold on a player
		-- ped even pinned (this is the exact one caught live via
		-- Config.Debug: "does NOT appear active ~0.5s after starting it").
		-- amb_camp@prop_camp_cauldron_stir is the same stirring motion as a
		-- plain dict.
		name = "stir_soup", label = "Stir a Pot", category = "Camp",
		description = "Stir a pot of soup or stew.",
		type = "anim",
		dict = "amb_camp@prop_camp_cauldron_stir@female_a@idle_a", anim = "idle_a", flag = 1,
		restricted = false, tags = { "camp", "cook", "stir" },
		maleAnim = { dict = "amb_camp@prop_camp_cauldron_stir@male_a@idle_a", anim = "idle_a", flag = 1 },
	},
	-- ------------------------------------------------------------------
	-- Added: scenarios the game has BOTH a male and a female version of
	-- (scenario_types_with_conditional_anims.lua) - each pinned per gender.
	-- ------------------------------------------------------------------
	{
		name = "lean_back_wall_scn", label = "Lean Back on Wall", category = "Lean",
		description = "Lean back against a wall.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_BACK_WALL",
		conditionalAnim = "WORLD_HUMAN_LEAN_BACK_WALL_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_LEAN_BACK_WALL_FEMALE_A",
		restricted = false, tags = { "lean", "wall" },
	},
	{
		name = "lean_post_moonshine", label = "Lean on Post, Moonshine", category = "Lean",
		description = "Lean on a post, sipping moonshine.",
		type = "scenario", scenario = "WORLD_HUMAN_LEAN_POST_LEFT_MOONSHINE",
		conditionalAnim = "WORLD_HUMAN_LEAN_POST_LEFT_MOONSHINE_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_LEAN_POST_LEFT_MOONSHINE_FEMALE_A",
		restricted = false, tags = { "lean", "post", "moonshine" },
	},
	{
		name = "warm_hands_fire", label = "Warm Hands by the Fire", category = "Camp",
		description = "Stand by a fire, warming your hands.",
		type = "scenario", scenario = "WORLD_HUMAN_FIRE_STAND",
		conditionalAnim = "WORLD_HUMAN_FIRE_STAND_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_FIRE_STAND_FEMALE_A",
		restricted = false, tags = { "camp", "fire", "warm" },
	},
	{
		name = "cauldron_stir", label = "Stir a Cauldron", category = "Camp",
		description = "Stir a big cooking pot.",
		type = "scenario", scenario = "WORLD_HUMAN_CAULDRON_STIR",
		conditionalAnim = "WORLD_HUMAN_CAULDRON_STIR_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_CAULDRON_STIR_FEMALE_A",
		restricted = false, tags = { "camp", "cook", "stir" },
	},
	{
		name = "wash_face_bucket", label = "Wash Face (Bucket)", category = "Camp",
		description = "Kneel and wash your face in a bucket.",
		type = "scenario", scenario = "WORLD_HUMAN_WASH_FACE_BUCKET_GROUND",
		conditionalAnim = "WORLD_HUMAN_WASH_FACE_BUCKET_GROUND_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_WASH_FACE_BUCKET_GROUND_FEMALE_A",
		restricted = false, tags = { "camp", "wash" },
	},
	{
		name = "drink_ladle", label = "Drink from a Bucket", category = "Camp",
		description = "Drink water with a ladle.",
		type = "scenario", scenario = "WORLD_HUMAN_BUCKET_DRINK_LADLE_GROUND",
		conditionalAnim = "WORLD_HUMAN_BUCKET_DRINK_LADLE_GROUND_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_BUCKET_DRINK_LADLE_GROUND_FEMALE_B",
		restricted = false, tags = { "camp", "drink", "water" },
	},
	{
		name = "sit_doze", label = "Doze Off (Sitting)", category = "Sleep",
		description = "Sit on the ground and nod off.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_FALL_ASLEEP",
		conditionalAnim = "WORLD_HUMAN_SIT_GROUND_SLEEPING_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_GROUND_SLEEPING_FEMALE_A",
		restricted = false, tags = { "sleep", "sit", "nap" },
	},
	{
		name = "drunk_passed_out_sit", label = "Passed Out Drunk (Sitting)", category = "Sleep",
		description = "Slumped on the ground after one too many.",
		type = "scenario", scenario = "WORLD_HUMAN_SIT_GROUND_DRINKING_DRUNK_PASSED_OUT",
		conditionalAnim = "WORLD_HUMAN_SIT_GROUND_DRINKING_DRUNK_PASSED_OUT_MALE_D",
		conditionalAnimFemale = "WORLD_HUMAN_SIT_GROUND_DRINKING_DRUNK_PASSED_OUT_FEMALE_A",
		restricted = false, tags = { "drunk", "sleep", "passed out" },
	},
	{
		name = "mourn_grave", label = "Mourn at a Grave", category = "Misc",
		description = "Stand and mourn.",
		type = "scenario", scenario = "WORLD_HUMAN_GRAVE_MOURNING",
		conditionalAnim = "WORLD_HUMAN_GRAVE_MOURNING_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_GRAVE_MOURNING_FEMALE_A",
		restricted = false, tags = { "mourn", "grave", "sad" },
	},
	{
		name = "mourn_grave_kneel", label = "Kneel at a Grave", category = "Misc",
		description = "Kneel and mourn.",
		type = "scenario", scenario = "WORLD_HUMAN_GRAVE_MOURNING_KNEEL",
		conditionalAnim = "WORLD_HUMAN_GRAVE_MOURNING_KNEEL_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_GRAVE_MOURNING_KNEEL_FEMALE_A",
		restricted = false, tags = { "mourn", "grave", "kneel" },
	},
	{
		name = "crouch_inspect", label = "Crouch & Inspect", category = "Misc",
		description = "Crouch down to look at something on the ground.",
		type = "scenario", scenario = "WORLD_HUMAN_CROUCH_INSPECT",
		conditionalAnim = "WORLD_HUMAN_CROUCH_INSPECT_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_CROUCH_INSPECT_FEMALE_A",
		restricted = false, tags = { "crouch", "inspect", "look" },
	},
	{
		name = "inspect_area", label = "Inspect", category = "Town",
		description = "Look something over closely.",
		type = "scenario", scenario = "WORLD_HUMAN_INSPECT",
		conditionalAnim = "WORLD_HUMAN_INSPECT_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_INSPECT_FEMALE_D",
		restricted = false, tags = { "inspect", "look" },
	},
	{
		name = "shopkeeper", label = "Shopkeeper", category = "Town",
		description = "Stand behind the counter like a shopkeeper.",
		type = "scenario", scenario = "WORLD_HUMAN_SHOPKEEPER",
		conditionalAnim = "WORLD_HUMAN_SHOPKEEPER_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_SHOPKEEPER_FEMALE_A",
		restricted = false, tags = { "shop", "work", "counter" },
	},
	{
		name = "scout_lookout", label = "Scout the Area", category = "Guard & Stoic",
		description = "Keep a lookout.",
		type = "scenario", scenario = "WORLD_HUMAN_GUARD_SCOUT",
		conditionalAnim = "WORLD_HUMAN_GUARD_SCOUT_MALE_C",
		conditionalAnimFemale = "WORLD_HUMAN_GUARD_SCOUT_FEMALE_A",
		restricted = false, tags = { "guard", "scout", "watch" },
	},
	{
		name = "clean_glass", label = "Clean a Glass", category = "Work",
		description = "Polish a glass behind the bar.",
		type = "scenario", scenario = "WORLD_HUMAN_BARTENDER_CLEAN_GLASS",
		conditionalAnim = "WORLD_HUMAN_BARTENDER_CLEAN_GLASS_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_BARTENDER_CLEAN_GLASS_FEMALE_A",
		restricted = false, tags = { "bar", "clean", "work" },
	},
	{
		name = "broom_rest", label = "Rest on a Broom", category = "Work",
		description = "Lean on a broom for a break.",
		type = "scenario", scenario = "WORLD_HUMAN_BROOM_RESTING",
		conditionalAnim = "WORLD_HUMAN_BROOM_RESTING_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_BROOM_RESTING_FEMALE_B",
		restricted = false, tags = { "broom", "rest", "work" },
	},
	{
		name = "bucket_fill", label = "Fill a Bucket", category = "Farming",
		description = "Fill a bucket with water.",
		type = "scenario", scenario = "WORLD_HUMAN_BUCKET_FILL",
		conditionalAnim = "WORLD_HUMAN_BUCKET_FILL_MALE_B",
		conditionalAnimFemale = "WORLD_HUMAN_BUCKET_FILL_FEMALE_A",
		restricted = false, tags = { "bucket", "water", "farm" },
	},
	{
		name = "bucket_pour", label = "Pour a Bucket", category = "Farming",
		description = "Pour out a bucket.",
		type = "scenario", scenario = "WORLD_HUMAN_BUCKET_POUR_LOW",
		conditionalAnim = "WORLD_HUMAN_BUCKET_POUR_LOW_MALE_A",
		conditionalAnimFemale = "WORLD_HUMAN_BUCKET_POUR_LOW_FEMALE_A",
		restricted = false, tags = { "bucket", "water", "farm" },
	},
}

ScenariosIndex = {}
for _, entry in ipairs(Config.Scenarios) do
	ScenariosIndex[entry.name] = entry
end
