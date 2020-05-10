-- In this file you can set up all the properties and settings for your game mode.

-- Barebones constants
AUTO_LAUNCH_DELAY = 10.0
HERO_SELECTION_TIME = 60.0
SELECT_PENALTY_TIME = 0.0
STRATEGY_TIME = 15.0					-- How long should strategy time last?
SHOWCASE_TIME = 0.0					-- How long should showcase time last?
AP_BAN_TIME = 10.0

AP_GAME_TIME = 60.0
PRE_GAME_TIME = 70.0						-- How long after people select their heroes should the horn blow and the game start?
TREE_REGROW_TIME = 300.0					-- How long should it take individual trees to respawn after being cut down/destroyed?
if IsInToolsMode() then
	POST_GAME_TIME = 60000.0				-- How long should we let people look at the scoreboard before closing the server automatically?
else
	POST_GAME_TIME = 600.0					-- How long should we let people look at the scoreboard before closing the server automatically?
end
CAMERA_DISTANCE_OVERRIDE = -1
GOLD_PER_TICK = 1

USE_AUTOMATIC_PLAYERS_PER_TEAM = false		-- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?
UNIVERSAL_SHOP_MODE = false 				-- Should the main shop contain Secret Shop items as well as regular items
-- if IsInToolsMode() then
	-- UNIVERSAL_SHOP_MODE = true
-- end
USE_STANDARD_HERO_GOLD_BOUNTY = false

MINIMAP_ICON_SIZE = 1						-- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1					-- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1					-- What icon size should we use for runes?

-- TODO: Set back to true and fix it
CUSTOM_BUYBACK_COST_ENABLED = false			-- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true		-- Should we use a custom buyback time?
BUYBACK_ENABLED = true						-- Should we allow people to buyback when they die?

USE_NONSTANDARD_HERO_GOLD_BOUNTY = false	-- Should heroes follow their own gold bounty rules instead of the default DOTA ones?
USE_NONSTANDARD_HERO_XP_BOUNTY = true		-- Should heroes follow their own XP bounty rules instead of the default DOTA ones?
-- Currently setting USE_NONSTANDARD_HERO_XP_BOUNTY to true due to map multipliers making the vanilla values give way too insane level boosts

ENABLE_TOWER_BACKDOOR_PROTECTION = true		-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false			-- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false					-- Should we disable the gold sound when players get gold?

ENABLE_FIRST_BLOOD = true					-- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false					-- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = true					-- Should we have players lose the normal amount of dota gold on death?
ENABLE_TPSCROLL_ON_FIRST_SPAWN = true		-- Should heroes spawn with a TP Scroll?
FORCE_PICKED_HERO = "npc_dota_hero_dummy_dummy"		-- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

MAXIMUM_ATTACK_SPEED = 1000					-- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 0					-- What should we use for the minimum attack speed?

b_USE_MULTIPLE_COURIERS = true

-------------------------------------------------------------------------------------------------
-- IMBA: gameplay globals
-------------------------------------------------------------------------------------------------

BUYBACK_COOLDOWN_ENABLED = true												-- Is the buyback cooldown enabled?

BUYBACK_BASE_COST = 100														-- Base cost to buyback
BUYBACK_COST_PER_LEVEL = 1.25												-- Level-based buyback cost
BUYBACK_COST_PER_LEVEL_AFTER_25 = 20										-- Level-based buyback cost growth after level 25
BUYBACK_COST_PER_SECOND = 0.25												-- Time-based buyback cost

BUYBACK_COOLDOWN_MAXIMUM = 180												-- Maximum buyback cooldown

BUYBACK_RESPAWN_PENALTY	= 15												-- Increased respawn time when dying after a buyback

ABANDON_TIME = 180															-- Time for a player to be considered as having abandoned the game (in seconds)
FULL_ABANDON_TIME = 5.0														-- Time for a team to be considered as having abandoned the game (in seconds)

GAME_ROSHAN_KILLS = 0														-- Tracks amount of Roshan kills
_G.GAME_ROSHAN_KILLER_TEAM = 0
ROSHAN_RESPAWN_TIME_MIN = 3
ROSHAN_RESPAWN_TIME_MAX = 6													-- Roshan respawn timer (in minutes)
AEGIS_DURATION = 300														-- Aegis expiration timer (in seconds)
IMBA_ROSHAN_GOLD_KILL_MIN = 150
IMBA_ROSHAN_GOLD_KILL_MAX = 400
IMBA_ROSHAN_GOLD_ASSIST = 150

IMBA_DAMAGE_EFFECTS_DISTANCE_CUTOFF = 2500									-- Range at which most on-damage effects no longer trigger

-------------------------------------------------------------------------------------------------
-- IMBA: map-based settings
-------------------------------------------------------------------------------------------------

MAX_NUMBER_OF_TEAMS = 2														-- How many potential teams can be in this game mode?
IMBA_PLAYERS_ON_GAME = 10													-- Number of players in the game
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = false									-- Should we use custom team colors to color the players/minimap?

PLAYER_COLORS = {}															-- Stores individual player colors
PLAYER_COLORS[0] = { 67, 133, 255 }
PLAYER_COLORS[1]  = { 170, 255, 195 }
PLAYER_COLORS[2] = { 130, 0, 150 }
PLAYER_COLORS[3] = { 255, 234, 0 }
PLAYER_COLORS[4] = { 255, 153, 0 }
PLAYER_COLORS[5] = { 190, 255, 0 }
PLAYER_COLORS[6] = { 255, 0, 0 }
PLAYER_COLORS[7] = { 0, 128, 128 }
PLAYER_COLORS[8] = { 255, 250, 200 }
PLAYER_COLORS[9] = { 49, 49, 49 }

TEAM_COLORS = {}															-- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }							-- Teal
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }							-- Yellow

CUSTOM_TEAM_PLAYER_COUNT = {}
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5

-------------------------------------------------------------------------------------------------
-- IMBA: game mode globals
-------------------------------------------------------------------------------------------------
GAME_WINNER_TEAM = 0														-- Tracks game winner
GG_TEAM = {}
GG_TEAM[2] = 0
GG_TEAM[3] = 0

IMBA_PICK_MODE_ALL_PICK = true												-- Activates All Pick mode when true
IMBA_PICK_MODE_ALL_RANDOM = false											-- Activates All Random mode when true
IMBA_PICK_MODE_ALL_RANDOM_SAME_HERO = false									-- Activates All Random Same Hero mode when true
IMBA_ALL_RANDOM_HERO_SELECTION_TIME = 5.0									-- Time we need to wait before the game starts when all heroes are randomed

CUSTOM_GOLD_BONUS = 100
CUSTOM_XP_BONUS = 100
MAX_LEVEL = 25
HERO_INITIAL_GOLD = 625
GOLD_TICK_TIME = 0.6

-- Update game mode net tables
CustomNetTables:SetTableValue("game_options", "all_pick", {IMBA_PICK_MODE_ALL_PICK})
CustomNetTables:SetTableValue("game_options", "all_random", {IMBA_PICK_MODE_ALL_RANDOM})
CustomNetTables:SetTableValue("game_options", "all_random_same_hero", {IMBA_PICK_MODE_ALL_RANDOM_SAME_HERO})
CustomNetTables:SetTableValue("game_options", "gold_tick", {GOLD_TICK_TIME})
CustomNetTables:SetTableValue("game_options", "max_level", {MAX_LEVEL})

USE_CUSTOM_HERO_LEVELS = false	-- Should we allow heroes to have custom levels?

-- Vanilla xp increase per level
local vanilla_xp = {}
vanilla_xp[1]	= 0
vanilla_xp[2]	= 200
vanilla_xp[3]	= 400
vanilla_xp[4]	= 480
vanilla_xp[5]	= 580
vanilla_xp[6]	= 600
vanilla_xp[7]	= 640
vanilla_xp[8]	= 660
vanilla_xp[9]	= 680
vanilla_xp[10]	= 800
vanilla_xp[11]	= 820
vanilla_xp[12]	= 840
vanilla_xp[13]	= 900
vanilla_xp[14]	= 1225
vanilla_xp[15]	= 1250
vanilla_xp[16]	= 1275
vanilla_xp[17]	= 1300
vanilla_xp[18]	= 1325
vanilla_xp[19]	= 1500
vanilla_xp[20]	= 1590
vanilla_xp[21]	= 1600
vanilla_xp[22]	= 1850
vanilla_xp[23]	= 2100
vanilla_xp[24]	= 2350
vanilla_xp[25]	= 2600

XP_PER_LEVEL_TABLE = {}			-- XP per level table (only active if custom hero levels are enabled)
XP_PER_LEVEL_TABLE[1] = 0
for i = 2, 25 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i - 1] + vanilla_xp[i]
end

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 5.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 100                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 5                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes
CAMERA_DISTANCE_OVERRIDE = -1           -- How far out should we allow the camera to go?  Use -1 for the default (1134) while still allowing for panorama camera distance changes

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = true                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 50                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = (i-1) * 100
end

ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = true               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = nil                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = -1                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 600              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

GAME_END_DELAY = -1                     -- How long should we wait after the game winner is set to display the victory banner and End Screen?  Use -1 to keep the default (about 10 seconds)
VICTORY_MESSAGE_DURATION = 3            -- How long should we wait after the victory message displays to show the End Screen?  Use 
STARTING_GOLD = 500                     -- How much starting gold should we give to each player?
DISABLE_DAY_NIGHT_CYCLE = false         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?
SKIP_TEAM_SETUP = false                 -- Should we skip the team setup entirely?
ENABLE_AUTO_LAUNCH = true               -- Should we automatically have the game complete team setup after AUTO_LAUNCH_DELAY seconds?
AUTO_LAUNCH_DELAY = 30                  -- How long should the default team selection launch timer be?  The default for custom games is 30.  Setting to 0 will skip team selection.
LOCK_TEAM_SETUP = false                 -- Should we lock the teams initially?  Note that the host can still unlock the teams 


-- NOTE: You always need at least 2 non-bounty type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true
ENABLED_RUNES[DOTA_RUNE_ARCANE] = true

---------------------------------------------------------
-- Stuff from old Settings
---------------------------------------------------------

-- 6.88 XP Values Table
XP_PER_LEVEL_TABLE = {}

XP_PER_LEVEL_TABLE[1] = 0
XP_PER_LEVEL_TABLE[2] = 200
XP_PER_LEVEL_TABLE[3] = 500
XP_PER_LEVEL_TABLE[4] = 900
XP_PER_LEVEL_TABLE[5] = 1400
XP_PER_LEVEL_TABLE[6] = 2000
XP_PER_LEVEL_TABLE[7] = 2600
XP_PER_LEVEL_TABLE[8] = 3400
XP_PER_LEVEL_TABLE[9] = 4400
XP_PER_LEVEL_TABLE[10] = 5400
XP_PER_LEVEL_TABLE[11] = 6000
XP_PER_LEVEL_TABLE[12] = 8200
XP_PER_LEVEL_TABLE[13] = 9000

for i=14,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = 50 * (i-13) * (i-13) + 1350 * (i-13) + 9000
end


CUSTOM_DEATH_GOLD_COST = {}
for i=1,MAX_LEVEL do
 CUSTOM_DEATH_GOLD_COST[i] = 30 * i + 50
end


CUSTOM_RESPAWN_TIME = {}
for i=1,MAX_LEVEL do
 CUSTOM_RESPAWN_TIME[i] = 5 + 3.8 * i
end

--Formula: bbcost = 120 + (time - PRE_GAME_TIME) * 0.25 + victimlvl * victimlvl * 1.5
BUYBACK_BASE_COST_TABLE = {}
for i=1,MAX_LEVEL do
	BUYBACK_BASE_COST_TABLE[i] = 120 + i * i * 1.5
end

BUYBACK_COST_PER_SECOND = 0.25  --4 sec periodic timer increasing bbcost by 1


NEUTRAL_SUICIDE_DEATH_TIME_EARLY_GAME = 22
TOWER_SUICIDE_ADDITIONAL_DEATH_TIME_EARLY_GAME = 5


CUSTOM_BUYBACK_COOLDOWN_TIME = 360.0


MAXIMUM_ATTACK_SPEED = 700              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

HERO_KILL_GOLD_BASE = 200
HERO_KILL_GOLD_PER_STREAK = 125				-- Gold you gain for killing heroes with streaks >3 
HERO_KILL_GOLD_PER_LEVEL = 9				-- IceFrog called this VictimLevel

SKILL_POINTS_AT_EVERY_LEVEL = true			-- Should there be more than 20 skill points?
