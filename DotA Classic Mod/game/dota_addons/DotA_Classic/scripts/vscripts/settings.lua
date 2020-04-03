GAME_VERSION = "1.0"
CustomNetTables:SetTableValue("game_options", "game_version", {value = GAME_VERSION, game_type = CUSTOM_GAME_TYPE})
CustomNetTables:SetTableValue("game_options", "gamemode", {1})

-- IMBA constants
IMBA_REINCARNATION_TIME = 3.0
IMBA_MAX_RESPAWN_TIME = 50.0		-- Maximum respawn time, does not include bonus reaper scythe duration
IMBA_RESPAWN_TIME_PCT = 50			-- Percentage of the respawn time from vanilla respawn time

RUNE_SPAWN_TIME = 120				-- How long in seconds should we wait between rune spawns?
BOUNTY_RUNE_SPAWN_TIME = 300
if IsInToolsMode() then
	-- Might be worth setting something here to differentiate our workspaces, since you seem to like bots on, but I don't...
	BOTS_ENABLED = false
else
	BOTS_ENABLED = false
end

-- Barebones constants
AUTO_LAUNCH_DELAY = 10.0
HERO_SELECTION_TIME = 60.0
SELECT_PENALTY_TIME = 0.0
STRATEGY_TIME = 10.0					-- How long should strategy time last?
SHOWCASE_TIME = 0.0					-- How long should showcase time last?
AP_BAN_TIME = 10.0

AP_GAME_TIME = 60.0
PRE_GAME_TIME = 90.0						-- How long after people select their heroes should the horn blow and the game start?
TREE_REGROW_TIME = 180.0					-- How long should it take individual trees to respawn after being cut down/destroyed?
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

if GetMapName() == Map1v1() then
	IMBA_PLAYERS_ON_GAME = 2
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 1
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 1
	IMBA_1V1_SCORE = 3
	PRE_GAME_TIME = 30.0 + AP_GAME_TIME
elseif string.find(GetMapName(), "10v10") then
	IMBA_PLAYERS_ON_GAME = 20
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 10
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 10

	PLAYER_COLORS[10] = { 255, 0, 255 }
	PLAYER_COLORS[11]  = { 128, 128, 0 }
	PLAYER_COLORS[12] = { 100, 255, 255 }
	PLAYER_COLORS[13] = { 0, 190, 0 }
	PLAYER_COLORS[14] = { 170, 110, 40 }
	PLAYER_COLORS[15] = { 0, 0, 128 }
	PLAYER_COLORS[16] = { 230, 190, 255 }
	PLAYER_COLORS[17] = { 128, 0, 0 }
	PLAYER_COLORS[18] = { 144, 144, 144 }
	PLAYER_COLORS[19] = { 254, 254, 254 }
	PLAYER_COLORS[20] = { 166, 166, 166 }
	PLAYER_COLORS[21] = { 255, 89, 255 }
	PLAYER_COLORS[22] = { 203, 255, 89 }
	PLAYER_COLORS[23] = { 108, 167, 255 }
elseif GetMapName() == "imba_demo" then
	IMBA_PLAYERS_ON_GAME = 2
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 1
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 1
end

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
HERO_INITIAL_GOLD = 600
GOLD_TICK_TIME = 0.6

BANNED_ITEMS = {}
BANNED_ITEMS[Map1v1()] = {
	"item_bottle",
	"item_infused_raindrop",
	"item_soul_ring",
	"item_tome_of_knowledge",
}
TOWER_ABILITIES = {}
TOWER_ABILITIES["tower1"] = {
	"imba_tower_secondary_resistance",
	"imba_tower_tenacity",
	-- "imba_tower_thorns",
	"imba_tower_multishot"
}
TOWER_ABILITIES["tower2"] = {
	"imba_tower_secondary_resistance",
	"imba_tower_tenacity",
	-- "imba_tower_thorns",
	"imba_tower_regeneration",
	"imba_tower_multishot"
}
TOWER_ABILITIES["tower3"] = {
	"imba_tower_secondary_resistance",
	"imba_tower_tenacity",
	-- "imba_tower_thorns",
	"imba_tower_regeneration",
	"imba_tower_toughness",
	"imba_tower_multishot"
}
TOWER_ABILITIES["tower4"] = {
	"imba_tower_secondary_resistance",
	"imba_tower_tenacity",
	-- "imba_tower_thorns",
	"imba_tower_regeneration",
	"imba_tower_toughness",
	-- "imba_tower_splash_fire",
	"imba_tower_multishot"
}

-- Update game mode net tables
CustomNetTables:SetTableValue("game_options", "all_pick", {IMBA_PICK_MODE_ALL_PICK})
CustomNetTables:SetTableValue("game_options", "all_random", {IMBA_PICK_MODE_ALL_RANDOM})
CustomNetTables:SetTableValue("game_options", "all_random_same_hero", {IMBA_PICK_MODE_ALL_RANDOM_SAME_HERO})
CustomNetTables:SetTableValue("game_options", "gold_tick", {GOLD_TICK_TIME[GetMapName()]})
CustomNetTables:SetTableValue("game_options", "max_level", {MAX_LEVEL[GetMapName()]})

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

-- Was using GetRespawnTime() but Meepo respawn time is always 3, so let's use static values instead...
RESPAWN_TIME_VANILLA = {}
RESPAWN_TIME_VANILLA[1] = 6
RESPAWN_TIME_VANILLA[2] = 8
RESPAWN_TIME_VANILLA[3] = 10
RESPAWN_TIME_VANILLA[4] = 14
RESPAWN_TIME_VANILLA[5] = 16
RESPAWN_TIME_VANILLA[6] = 26
RESPAWN_TIME_VANILLA[7] = 28
RESPAWN_TIME_VANILLA[8] = 30
RESPAWN_TIME_VANILLA[9] = 32
RESPAWN_TIME_VANILLA[10] = 34
RESPAWN_TIME_VANILLA[11] = 36
RESPAWN_TIME_VANILLA[12] = 44
RESPAWN_TIME_VANILLA[13] = 46
RESPAWN_TIME_VANILLA[14] = 48
RESPAWN_TIME_VANILLA[15] = 50
RESPAWN_TIME_VANILLA[16] = 52
RESPAWN_TIME_VANILLA[17] = 54
RESPAWN_TIME_VANILLA[18] = 65
RESPAWN_TIME_VANILLA[19] = 70
RESPAWN_TIME_VANILLA[20] = 75
RESPAWN_TIME_VANILLA[21] = 80
RESPAWN_TIME_VANILLA[22] = 85
RESPAWN_TIME_VANILLA[23] = 90
RESPAWN_TIME_VANILLA[24] = 95
RESPAWN_TIME_VANILLA[25] = 100
RESPAWN_TIME_VANILLA[26] = 100
RESPAWN_TIME_VANILLA[27] = 100
RESPAWN_TIME_VANILLA[28] = 100
RESPAWN_TIME_VANILLA[29] = 100
RESPAWN_TIME_VANILLA[30] = 100

-- XP AWARDED per level table (how much bounty heroes are worth beyond level 25)
HERO_XP_BOUNTY_PER_LEVEL = {}
HERO_XP_BOUNTY_PER_LEVEL[1] = 100

for i = 2, 500 do
	HERO_XP_BOUNTY_PER_LEVEL[i] = HERO_XP_BOUNTY_PER_LEVEL[i-1] + 40
end

USE_MEME_SOUNDS = true														-- Should we use meme/fun sounds on abilities occasionally?
MEME_SOUNDS_CHANCE = 50

-------------------------------------------------------------------------------------------------
-- IMBA: Keyvalue tables
-------------------------------------------------------------------------------------------------

IMBA_FIRST_BLOOD = false

-- IMBA override vanilla systems
USE_TEAM_COURIER = true -- Should we use vanilla couriers? -- nil to use none of turbo or team couriers

SAME_HERO_SELECTION = false

-- if IsInToolsMode() then SAME_HERO_SELECTION = true end
