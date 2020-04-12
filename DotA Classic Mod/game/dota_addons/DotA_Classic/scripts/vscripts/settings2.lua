ENABLE_HERO_RESPAWN = true              
UNIVERSAL_SHOP_MODE = false             
ALLOW_SAME_HERO_SELECTION = false       


ENABLE_BANNING_PHASE = true				--Should we enable a banning phase?
BANNING_PHASE_TIME = 10

HERO_SELECTION_TIME = 25.0              -- How long should we let people select their hero?
TIME_BEFORE_FORCED_RANDOM = 8			-- How long can people pick after the time has run out before getting a random hero? 
PRE_GAME_TIME = 60.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   
PENALTY_TIME = 10.0
STRATEGY_TIME = 20.0                 
TREE_REGROW_TIME = 300.0

GOLD_PER_TICK = 1                    
GOLD_TICK_TIME = 1                      

RECOMMENDED_BUILDS_DISABLED = false     
CAMERA_DISTANCE_OVERRIDE = -1           

MINIMAP_ICON_SIZE = 1                   
MINIMAP_CREEP_ICON_SIZE = 1             
MINIMAP_RUNE_ICON_SIZE = 1              

CUSTOM_BUYBACK_COST_ENABLED = true      
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  
BUYBACK_ENABLED = true                 

DISABLE_FOG_OF_WAR_ENTIRELY = false     
USE_UNSEEN_FOG_OF_WAR = false           

USE_STANDARD_DOTA_BOT_THINKING = false  
USE_STANDARD_HERO_GOLD_BOUNTY = false    

USE_CUSTOM_TOP_BAR_VALUES = false        
TOP_BAR_VISIBLE = true                  
SHOW_KILLS_ON_TOPBAR = true             

ENABLE_TOWER_BACKDOOR_PROTECTION = true
REMOVE_ILLUSIONS_ON_DEATH = false       
DISABLE_GOLD_SOUNDS = false             

END_GAME_ON_KILLS = false                



TELEPORT_SCROLL_ON_START = false         -- Should the heroes have a teleport scroll in their inventory right at the start of the game?


MAX_LEVEL = 25                         
USE_CUSTOM_XP_VALUES = true             

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

USE_CUSTOM_RESPAWN_TIMES = true

CUSTOM_RESPAWN_TIME = {}
for i=1,MAX_LEVEL do
 CUSTOM_RESPAWN_TIME[i] = 5 + 3.8 * i
end

CUSTOM_BUYBACK_COOLDOWN_TIME = 360.0
MAX_RESPAWN_TIME = 140



ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = false               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = nil                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = -1                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 700              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

GAME_END_DELAY = -1                     -- How long should we wait after the game winner is set to display the victory banner and End Screen?  Use -1 to keep the default (about 10 seconds)
VICTORY_MESSAGE_DURATION = 3            -- How long should we wait after the victory message displays to show the End Screen?  Use 
STARTING_GOLD = 625                     -- How much starting gold should we give to each player?
DISABLE_DAY_NIGHT_CYCLE = false         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?
SKIP_TEAM_SETUP = true                 -- Should we skip the team setup entirely?
ENABLE_AUTO_LAUNCH = true               -- Should we automatically have the game complete team setup after AUTO_LAUNCH_DELAY seconds?
AUTO_LAUNCH_DELAY = 0                  -- How long should the default team selection launch timer be?  The default for custom games is 30.  Setting to 0 will skip team selection.
LOCK_TEAM_SETUP = true                 -- Should we lock the teams initially?  Note that the host can still unlock the teams 



RUNE_SPAWN_TIME = 120

-- NOTE: You always need at least 2 non-bounty type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true
ENABLED_RUNES[DOTA_RUNE_ARCANE] = true

BOUNTY_RUNE_SPAWN_INTERVAL = 300
POWER_RUNE_SPAWN_INTERVAL = 120

USE_DEFAULT_RUNE_SYSTEM = true 


MAX_NUMBER_OF_TEAMS = 2                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = false           -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = false          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 38, 136, 0 }  --    Dark Red
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 220, 0, 20 }   --    Dark Green

USE_AUTOMATIC_PLAYERS_PER_TEAM = true   

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5



CUSTOM_DEATH_GOLD_COST = {}
for i=1,MAX_LEVEL do
 CUSTOM_DEATH_GOLD_COST[i] = 30 * i + 50
end


USE_CUSTOM_HERO_GOLD_BOUNTY = true
HERO_KILL_GOLD_BASE = 200


USE_CUSTOM_HERO_LEVELS = true

SKILL_POINTS_AT_EVERY_LEVEL = true			-- Should there be more than 20 skill points?
HERO_KILL_GOLD_PER_STREAK = 125				-- Gold you gain for killing heroes with streaks >3 
HERO_KILL_GOLD_PER_LEVEL = 9				-- IceFrog called this VictimLevel



--Test XP_PER_LEVEL_TABLE for fast leveling and more gold
for i=2,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = (i-1)*50
end




STARTING_GOLD = 62500
UNIVERSAL_SHOP_MODE = true
HERO_SELECTION_TIME = 18.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 4.0                    -- How long after people select their heroes should the horn blow and the game start?
TIME_BEFORE_FORCED_RANDOM = 10
PENALTY_TIME = 5.0
STRATEGY_TIME = 5.0  