-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
DOTACLASSIC_VERSION = "0.10"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
DOTACLASSIC_DEBUG_SPEW = false 

if GameMode == nil then
    _G.GameMode = class({})
end 


--filters.lua
require('filters')


-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')


-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "playground" then
  require("examples/playground")
end

--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  --DebugPrint("[DOTA CLASSIX] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  --DebugPrint("[DOTA CLASSIX] First Player has loaded")
  
  -- Apply a modifier that makes it obey our armour formula
  LinkLuaModifier("modifier_common_custom_armor", "abilities/common_custom_armor.lua", LUA_MODIFIER_MOTION_NONE)

  -- Apply a modifier that makes STR HP REGEN obey our will. Current Valve Constant does nothing. Fuck that cancer
  LinkLuaModifier("modifier_nerf_cancer_regen", "abilities/nerf_cancer_regen.lua", LUA_MODIFIER_MOTION_NONE)

end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  --DebugPrint("[DOTA CLASSIX] All Players have loaded into the game")

 -- Force Random a hero for every play that didnt pick a hero when time runs out
  local delay = HERO_SELECTION_TIME + PENALTY_TIME -0.1 --+ STRATEGY_TIME - 0.1
  if ENABLE_BANNING_PHASE then
    delay = delay + BANNING_PHASE_TIME
  end
  Timers:CreateTimer(delay, function()
    for playerID = 0, 9 do
      local player = PlayerResource:GetPlayer(playerID)
      if PlayerResource:IsValidPlayerID(playerID) then
        -- If this player still hasn't picked a hero, random one
        -- PlayerResource:IsConnected(index) is custom-made; can be found in 'player_resource.lua' library
        if not PlayerResource:HasSelectedHero(playerID) and player ~= nil and (not PlayerResource:IsBroadcaster(playerID)) then
          PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection() -- this will cause an error if player is disconnected
          PlayerResource:SetHasRandomed(playerID)
          PlayerResource:SetCanRepick(playerID, false)
          --DebugPrint("[BAREBONES] Randomed a hero for a player number "..playerID)
        end
      end
    end
  end)




end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  --DebugPrint("[DOTA CLASSIX] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 625 unreliable gold
  -- hero:SetGold(625, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_bfury", hero, hero)
  hero:AddItem(item)
  
  local playerID = hero:GetPlayerID()    

     if PlayerResource:HasRandomed(playerID) then

        Timers:CreateTimer(0.1, function()
        local mango = hero:FindItemInInventory("item_enchanted_mango")
        local faerie = hero:FindItemInInventory("item_faerie_fire")
        print(mango)
        print(faerie)

          if mango ~= nil then 
            hero:RemoveItem(mango)
          end

          if faerie ~= nil then 
            hero:RemoveItem(faerie)
          end
        end)
          
        hero:ModifyGold(200,false,DOTA_ModifyGold_Unspecified)
     end

     Timers:CreateTimer(0.1, function()
     local tp = hero:FindItemInInventory("item_tpscroll")
     hero:RemoveItem(tp)
     end)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability]]

  --local abil = hero:GetAbilityByIndex(1)
  --hero:RemoveAbility(abil:GetAbilityName())
  -- hero:AddAbility("example_ability")
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  --DebugPrint("[DOTA CLASSIX] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      --DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)

  -- A timer running every 4 seconds that starts 60 seconds in the future, respects pauses
  Timers:CreateTimer(PRE_GAME_TIME, function()
        --Add additional Gold so it's 1 gold / 0.6 seconds over all, update buybackcost every 4 seconds
        for i=0,9 do
          PlayerResource:ModifyGold(i,1,false,DOTA_ModifyGold_GameTick)

          local lvl = PlayerResource:GetLevel(i)
          local time = GameRules:GetGameTime()
          if lvl ~= nil then
            local bbcost = 150 + (time-PRE_GAME_TIME) * 0.25 + lvl * lvl * 1.5
            PlayerResource:SetCustomBuybackCost(i,bbcost)
          end
        end 
      return 4.0
    end
  )




end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  --DebugPrint('[DOTA CLASSIX] Starting to load Barebones gamemode...')

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  --DebugPrint('[DOTA CLASSIX] Done loading Barebones gamemode!\n\n')
end


-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end