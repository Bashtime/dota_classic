-- In this file you can set up all the properties and settings for your game mode.


ENABLE_HERO_RESPAWN = true              
UNIVERSAL_SHOP_MODE = false             
ALLOW_SAME_HERO_SELECTION = false       

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 60.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   
TREE_REGROW_TIME = 300.0                 

GOLD_PER_TICK = 1                    
GOLD_TICK_TIME = 0.6                      

RECOMMENDED_BUILDS_DISABLED = false     
CAMERA_DISTANCE_OVERRIDE = -1           

MINIMAP_ICON_SIZE = 1                   
MINIMAP_CREEP_ICON_SIZE = 1             
MINIMAP_RUNE_ICON_SIZE = 1              

RUNE_SPAWN_TIME = 120                   
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
      

USE_CUSTOM_HERO_LEVELS = true           


MAX_LEVEL = 25                         
USE_CUSTOM_XP_VALUES = true             

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,6 do
  XP_PER_LEVEL_TABLE[i] = i * 100
end

XP_PER_LEVEL_TABLE[7] = 600
XP_PER_LEVEL_TABLE[8] = 800
XP_PER_LEVEL_TABLE[9] = 1000
XP_PER_LEVEL_TABLE[10] = 1000
XP_PER_LEVEL_TABLE[11] = 600
XP_PER_LEVEL_TABLE[12] = 2200

for i=14,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = i * 100
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
MAXIMUM_ATTACK_SPEED = 700              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

GAME_END_DELAY = -1                     -- How long should we wait after the game winner is set to display the victory banner and End Screen?  Use -1 to keep the default (about 10 seconds)
VICTORY_MESSAGE_DURATION = 3            -- How long should we wait after the victory message displays to show the End Screen?  Use 
STARTING_GOLD = 825                     -- How much starting gold should we give to each player?
DISABLE_DAY_NIGHT_CYCLE = false         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?
SKIP_TEAM_SETUP = true                 -- Should we skip the team setup entirely?
ENABLE_AUTO_LAUNCH = true               -- Should we automatically have the game complete team setup after AUTO_LAUNCH_DELAY seconds?
AUTO_LAUNCH_DELAY = 30                  -- How long should the default team selection launch timer be?  The default for custom games is 30.  Setting to 0 will skip team selection.
LOCK_TEAM_SETUP = true                 -- Should we lock the teams initially?  Note that the host can still unlock the teams 


-- NOTE: You always need at least 2 non-bounty type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = true
ENABLED_RUNES[DOTA_RUNE_ARCANE] = true


MAX_NUMBER_OF_TEAMS = 2                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true           -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = false          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 0, 90, 10 }  --    Dark Red
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 220, 0, 20 }   --    Dark Green

USE_AUTOMATIC_PLAYERS_PER_TEAM = true   

--CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
--CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
--CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5
