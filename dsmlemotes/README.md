# dsmlemotes

A polished, menu-driven RedM emote system. Kibook's proven animation engine
(dict/anim playback, prop attachment, partner-synced shared emotes) as the
backend, job permissions, and full cleanup/safety handling. VORP-compatible,
but does not require VORP to function.

**F5** opens **EMOTES!**, this resource's own custom NUI panel (no external
menu library involved) - a torn-paper banner, anchored to the right side of
the screen, vertically centered. Three tabs: **Animations** (every solo
emote/scenario, with a search box and All/Dances/Emotes/Prop Emotes quick
filters), **Walk Animations** (walk-style clipsets + a walk-speed slider,
replacing vorp_walkanim), and **Shared**, plus an always-visible **Cancel**
button next to the tabs that stops whatever's playing regardless of which
tab you're on. A **Stop** button also lives in the footer whenever something
is playing, next to `/stop`, so there's always an obvious way to cancel
without hunting for the right row.

## 1. Installation

The resource must be named `dsmlemotes` on disk (it already is). Add to your
`server.cfg`, after your VORP resources:

```
ensure dsmlemotes
```

Nothing else is required to run it.

## 2. Dependencies

None are required. The animation engine (playing emotes/scenarios, props,
shared emotes) is fully framework-independent.

## 3. VORP setup (optional)

If `vorp_core` is `ensure`d and running, `dsmlemotes` automatically:

- Uses `exports.vorp_core:DisplayTip` for notifications instead of the
  built-in on-screen text fallback.
- Resolves each player's current job (via `exports.vorp_core:GetCore()` /
  `getUser(source).getUsedCharacter.job`) so `restricted = { jobs = {...} }`
  entries in the config can be gated per job.
- Persists the chosen Walk Animation to the `characters.walk` database
  column and restores it on `vorp:SelectedCharacter` (see section 10) -
  requires `oxmysql` too, same as vorp_walkanim already did.

Set `Config.UseVorp = false` in `config/config.lua` to disable this entirely
and run in framework-independent mode even with vorp_core present.

## 4. Commands / keybind

| Trigger | Effect |
|---|---|
| **F5** | Opens/closes EMOTES! (a real `RegisterKeyMapping` bind - rebindable per-player in RedM's own Settings > Key Bindings, same as any other RedM keybind). |
| `/stop` | Immediately stops whatever is playing: animation/scenario, attached prop, and any active shared emote (the other player is notified and stopped too). |
| `/<emote_name>` | Every entry in `config/emotes.lua` and `config/scenarios.lua` also gets its own direct chat command named after its `name` field - e.g. `/smoke`, `/wave`, `/tip_hat`, `/sit_ground`. Shared (partner) emotes are menu/F5-only, since they need the accept/decline flow. |

The keybind and stop command are configurable:

```lua
-- config/config.lua
Config.MenuKeybind = "F5"
Config.StopCommand = "stop"
Config.EnablePerEmoteCommands = true -- set false to disable the /<emote_name> shortcuts
```

No key is *required* to be pressed while playing - F5 only opens/closes the
browsing menu; `/<emote_name>` and `/stop` work from chat regardless.

## 5. Configuration

All tunables live in `config/config.lua` - feature toggles
(`EnableFavorites`, `EnableRecent`, `EnableSharedEmotes`, `EnableProps`,
`EnableScenarios`), shared-emote distance/timeout, persistence mode, and the
theme colors sent to the NUI.

## 6. Adding an emote

Edit `config/emotes.lua` and add a table to `Config.Emotes` (no code changes
needed - the resource re-indexes on start):

```lua
{
    name = "my_emote", label = "My Emote", category = "Social",
    description = "Shown as a tooltip.",
    type = "anim",              -- "anim", "scenario", or "nativeEmote"
    dict = "anim_dict_here", anim = "anim_name_here", flag = 1,
    -- scenario = "SCENARIO_NAME",        -- instead of dict/anim, if type = "scenario"
    -- emoteType = "KIT_EMOTE_...",       -- instead of dict/anim, if type = "nativeEmote"
    canMove = false, canRun = false, canJump = false, canAttack = false,
    canCancel = true,
    allowWeapon = false, allowCombat = false,
    prop = nil,                 -- see section 8
    restricted = false,         -- or { jobs = { "police" } }
    tags = { "tag1", "tag2" },
}
```

`category` must be one of `Config.EmoteCategories` (or add a new one there).

**`type = "scenario"` vs `type = "nativeEmote"`:** use `"scenario"` for
ambient poses (sitting, leaning, standing around). Use `"nativeEmote"` for
anything that's supposed to hold an item (smoking, etc.) -
`TaskStartScenarioInPlace` plays the motion but has no prop to attach (a
scenario POINT normally supplies that from its own placement data, which
in-place playback doesn't have), so it looks like it's missing whatever
it's meant to be holding. RDR2's own built-in emote-wheel system
(`type = "nativeEmote"`, a `KIT_EMOTE_*` name) supplies its own prop - see
the `smoke`/`smoke_cigar` entries in `config/emotes.lua` for a working
example. If neither fits and you need a specific prop on a regular `"anim"`
entry instead, see section 8.

## 7. Adding a scenario

Edit `config/scenarios.lua`, add to `Config.Scenarios`:

```lua
{
    name = "my_scenario", label = "My Scenario", category = "Town",
    description = "Shown as a tooltip.",
    type = "scenario",              -- REQUIRED - client/main.lua dispatches on this field;
                                     -- without it the entry silently does nothing instead of
                                     -- playing (an earlier version of this doc example omitted
                                     -- it - don't copy that mistake)
    scenario = "SCENARIO_NAME",
    conditionalAnim = nil,          -- optional, see below
    restricted = false,
    tags = { "tag1" },
}
```

`category` must be one of `Config.ScenarioCategories`.

**`conditionalAnim` (optional):** most scenario TYPES are really an umbrella over several
concrete animation variants (male/female builds, idle/smoking/drinking, ...) that the game
normally picks between at random - fine for an NPC, but some variants are gated to NPCs only and
can come back empty on a player-controlled ped (RDR3's own discovered-scenario data documents
this: a conditional anim can require "NOT CAIConditionIsPlayer"). Setting `conditionalAnim` to
one exact animation name (verified against a scenario/conditional-anim reference such as
`femga/rdr3_discoveries`) pins the scenario to that one guaranteed variant instead of leaving it
to chance, via the `TASK_START_SCENARIO_IN_PLACE_HASH` native. Only pin it when the reference
data lists a single valid conditional anim for that scenario type (or several that are all the
same gender) - see the entries in `config/scenarios.lua` for real examples - otherwise leave it
unset so the scenario system picks the variant matching the player's own ped model, same as it
would for an NPC.

## 8. Adding a prop

Attach a `prop` table to any emote entry in `config/emotes.lua`:

```lua
prop = {
    model = "p_bottlewhiskey01x",
    bone = "skel_r_hand",             -- bone name (string) or index (number)
    position = vector3(0.0, 0.0, 0.0),
    rotation = vector3(0.0, 0.0, 0.0)
}
```

Props are created when the emote starts and are **always** deleted when the
emote stops, the player dies, `/stop` is used, or the resource stops - there
is no code path that leaves a prop behind.

## 9. Shared (partner) emotes

Edit `config/shared.lua`, add to `Config.SharedEmotes`:

```lua
{
    name = "my_shared", label = "My Shared Emote", category = "Other",
    description = "Shown as a tooltip.",
    animation = { dict = "...", anim = "...", flag = 1 },       -- requester
    partner = {
        offset = vector4(0.0, 0.7, 0.0, 180.0),                 -- x, y, z, heading, relative to requester
        animation = { dict = "...", anim = "...", flag = 1 }    -- target
    },
    tags = { "tag1" },
}
```

Flow: the requester picks the emote in the menu, the nearest player within
`Config.SharedEmoteDistance` is sent a request; the target sees a small
accept/decline prompt (not the full menu) and has `Config.SharedEmoteTimeout`
seconds to respond. The server validates the target exists, is alive, and is
still in range before either side is allowed to start playing - a client can
never force an animation onto another client. If the two players move more
than `Config.SharedEmoteDistance` apart, the shared emote automatically
cancels for both.

## 10. Walk Animations

Replaces vorp_walkanim's menu (that resource can be safely stopped once
you've confirmed this works for you - see `config/walkstyles.lua` for the
full style list, sourced verbatim from vorp_walkanim's own `Walkstyle`
table). Two independent controls plus the style list itself:

- **Walk speed** - a slider (`Config.WalkSpeed` in `config/walkstyles.lua`
  sets the min/max/step) that only takes effect while...
- **Limit walk speed** is checked - a continuous `SetPedMaxMoveBlendRatio`
  override (the same technique as vorp_walkanim's own `/walkSlow` command),
  since the game resets that value every frame on its own.
- The **style list** (Default + 11 `MP_Style_*` clipsets) applies via
  `SET_PED_MOVEMENT_CLIPSET`/`RESET_PED_MOVEMENT_CLIPSET` - a single call,
  not a streamed anim dict, so it persists on its own with no background
  thread needed. Picking a style is saved to the same `characters.walk`
  database column vorp_walkanim already created (`server/walkstyle.lua`,
  needs `Config.UseVorp` + `oxmysql`) and restored automatically next time
  that character is selected - a player's existing saved walk style from
  vorp_walkanim keeps working here with no migration needed.

## 11. Permissions

Any emote or scenario entry can carry:

```lua
restricted = { jobs = { "police", "doctor", "blacksmith" } }
```

Players without a matching VORP job (see section 3) will have the menu item
blocked. Leave `restricted = false` (the default) for no restriction. This is
a display/vanity gate, not an anti-cheat measure - solo emotes have no
gameplay effect either way.

## 12. Troubleshooting

**Emotes stop themselves within a second of starting** - was the
weapon-drawn safety check (`client/safety.lua`) misreading a
scenario/nativeEmote's own held prop (a cigarette, a drink, an instrument -
RDR3 attaches those through the same weapon-slot mechanism real weapons use)
as a drawn weapon. Fixed by scoping that check to plain `type = "anim"`
entries only, where any detected weapon is unambiguously the player's own
(those get props through this resource's own `CreateAndAttachProp`, which
never touches the weapon system). With `Config.Debug = true` it prints
`[DSML_EMOTES] DEBUG: GetPedCurrentHeldWeapon = <value> (WEAPON_UNARMED hash
= <hash>) - treated as armed, stopping` if it ever fires again on a
genuinely empty-handed `"anim"` entry - please include that line when
reporting.

**A scenario-based entry plays briefly then does nothing / snaps back, or
never appeared active at all with `Config.Debug` on** - some
`TaskStartScenarioInPlace` scenario types simply never take hold on a
player-controlled ped, pinned `conditionalAnim` or not (confirmed via
`IsPedUsingAnyScenario` staying `false`). Every scenario in this catalogue
that had that problem (check appearance, several lean/sit/work/hunting/guard
poses, stirring a pot, ...) has already been converted to a plain
`type = "anim"` entry pointing at the same underlying motion as a real anim
dict/clip instead - see the `[ANIM FALLBACK]` comments in
`config/scenarios.lua` and `config/emotes.lua`. If you add a new scenario
entry and hit the same thing, that's the fix: find the equivalent dict/clip
(a full dump of every anim dict/clip in the game ships as
`ingameanims_list.lua`/`megadictanims.lua` alongside this resource) and
switch that one entry to `type = "anim"` too.

**`[DSML_EMOTES] ERROR: Animation dictionary could not be loaded: ...`** in
console - the `dict`/`anim` pair for that entry is wrong or no longer exists.
Remove or correct that entry in `config/emotes.lua`. The player only sees
"Animation unavailable." - nothing else breaks.

**A scenario entry does nothing visible** - `TaskStartScenarioInPlace` never
errors on an unrecognised scenario name, it just does nothing. Double-check
the `scenario` string in `config/scenarios.lua` against an in-game reference
and correct/remove it.

**Player gets frozen/stuck, and `/stop` doesn't seem to stop the emote** -
`/stop` (and the Stop button in the menu footer) should always recover the
player. Two related race conditions used to be able to defeat that, both
fixed:

1. **Starting a new emote while the previous one was still loading** (double
   -clicking a row, spamming a `/name` command twice) - `dict`/prop loading
   is asynchronous, so a second play attempt could begin before the first
   had finished and set its state, letting the first one's
   `FreezeEntityPosition` (on `flag = 1` entries) go untracked once it
   finally completed and overwrote the client's play-state.
   `client/main.lua`'s `beginPlaying()` now tags every attempt with a token;
   only the most recent one is allowed to commit, and a superseded one
   cleans up after itself (unfreezes, deletes its own prop) instead of
   leaking state.
2. **`/stop` itself getting silently undone** - the safety-watch thread
   (`client/safety.lua`) re-applies the animation every ~250ms if the game
   ever interrupts it. If `/stop` ran while that thread happened to be
   asleep mid-cycle, the already-queued cycle would still run afterward, see
   the animation it had just stopped as "not playing", and restart it -
   re-freezing the player right after `/stop` appeared to do nothing. The
   watch thread is now tagged with the same kind of generation token as
   above, and bails the instant it wakes up to find itself superseded,
   instead of acting on stale state.

If you ever see this again with `Config.Debug = true`, it's worth a bug
report with what you clicked/typed and how fast.

**Set `Config.Debug = true`** for verbose `[DSML_EMOTES]` logging of every
animation/prop load, play, and stop.

### A note on the shipped content

Every entry already in `config/emotes.lua` / `config/scenarios.lua` /
`config/shared.lua` is either (a) copied directly from the Kibook animations
already installed on this server before this resource existed, (b) sourced
from a real, actively-used open-source RedM animation resource, (c) taken
verbatim from `scenario_types_with_conditional_anims.lua` (a
community-sourced dump of every RDR2 scenario type and its valid
"conditional anim" variants, cross-referenced against the game's own
`amb_rest.meta`/`amb_rest_CA.meta`), or (d) for the `[ANIM FALLBACK]`
entries, cross-referenced against `ingameanims_list.lua`/`megadictanims.lua`
(a full dump of every anim dict + clip name in the game). None were
invented, and every dict/clip pair used was confirmed to actually exist in
that dump before being added.

Following an in-game review, the **Chair & Bench** scenario category and
every pickup/putdown one-shot scenario (guitar, banjo, fiddle, concertina,
mandolin, trumpet, book, sketchbook, shovel, rake, box, sack, fishing pole)
were removed outright - both need a real prop already placed at the exact
spot to look right, which a generic "play anywhere" menu entry can't
guarantee, so in practice most of them looked broken. A few remaining
scenario types still need something specific nearby to look right and say so
in their `description` (an actual carcass for the two Hunting entries, a
piano prop for `piano_seated`, the `*_seated` Music entries needing a chair/
bench). Handshake/Hug/High Five shared emotes were left empty on purpose
rather than filled with guesses - see the comment in `config/shared.lua`.

## 13. Performance

No permanent per-frame loops. Threads only run while something is actually
happening: an emote/prop is active (resilience + safety checks, every
250ms), a shared-emote request is pending, or an active shared emote's
distance is being watched (every 500ms). Menu open/close and every NUI
action are purely event-driven. Idle cost when the menu is closed and
nothing is playing is effectively zero.
