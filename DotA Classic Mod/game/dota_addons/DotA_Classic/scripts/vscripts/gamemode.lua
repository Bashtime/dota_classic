-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

require('libraries/keyvalues')
require('libraries/notifications')
require('libraries/player')
require('libraries/player_resource')
require('libraries/timers')

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
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
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
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  --hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_example_item", hero, hero)
  hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end


--#########################################################
--##  Stuff from the Old GameMode/Events Files down here
--#########################################################


-------------------------------------------------------------
--Bonus Gold for Randoming and Free TPs removed at GameStart

function GameMode:OnHeroInGame(hero)
  
  local playerID = hero:GetPlayerID()    

     if PlayerResource:HasRandomed(playerID) then
   
        hero:ModifyGold(200,false,DOTA_ModifyGold_Unspecified)
     end

     Timers:CreateTimer(0.1, function()

     local tp = hero:FindItemInInventory("item_tpscroll")
     hero:RemoveItem(tp)
     
     end)

end


--------------------------------------------------------------------------
-- Timer updating BBcost and adds Gold, to make 0.7 ticks become 0.6 ticks

function GameMode:OnGameInProgress()

  -- A timer running every 4 seconds that starts after the Pregame, respects pauses
  Timers:CreateTimer(PRE_GAME_TIME, function()

        --Add additional Gold so it's 1 gold / 0.6 seconds over all, update buybackcost every 4 seconds
        for i=0,9 do
          
          PlayerResource:ModifyGold(i,1,false,DOTA_ModifyGold_GameTick)

          local lvl = PlayerResource:GetLevel(i)
          local time = GameRules:GetGameTime()

          if lvl ~= nil then

            local bb_base = BUYBACK_BASE_COST_TABLE[lvl]
            local bb_timecost = (time-PRE_GAME_TIME) * BUYBACK_COST_PER_SECOND
            
            local bbcost = bb_base + bb_timecost
            PlayerResource:SetCustomBuybackCost(i,bbcost)
          end

        end 
      return 4.0
	end
  )
end


--------------------------------------------------------------------------
-- Normal Death time and death time penalty for suicides, Gold Loss

function GameMode:OnEntityKilled(keys)

  local killed_unit = EntIndexToHScript(keys.entindex_killed)
  local killer_unit = nil

  if keys.entindex_attacker ~= nil then
    killer_unit = EntIndexToHScript(keys.entindex_attacker)
  end

  local killing_ability = nil

  if keys.entindex_inflictor ~= nil then
    killing_ability = EntIndexToHScript(keys.entindex_inflictor)
  end

  -- For Meepo clones, find the original
  if killed_unit:IsClone() then
    if killed_unit:GetCloneSource() then
      killed_unit = killed_unit:GetCloneSource()
    end
  end

  if killed_unit:IsRealHero() and (not killed_unit:IsReincarnating()) then

        --Calculate Gold Lost on Death
        local playerID = killed_unit:GetPlayerID()
        local herolvl = killed_unit:GetLevel()
        local deathcost = CUSTOM_DEATH_GOLD_COST[herolvl]

        --Modify Gold after Death
        killed_unit:ModifyGold(-deathcost, false, DOTA_ModifyGold_Death)

        --Calculate Respawntime
  		local respawn_time = 1

        -- Get respawn time from the table that we defined
        respawn_time = CUSTOM_RESPAWN_TIME[herolvl]


      	-- Bloodstone reduction (bloodstone can't be in backpack)
        for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
         		local item = killed_unit:GetItemInSlot(i)
        	if item then
          		if item:GetName() == "item_bloodstone" then
             		local respawn_reduction = 10
             		respawn_time = math.max(1, respawn_time-respawn_reduction)
             		break -- break the for loop, to prevent multiple bloodstones granting respawn reduction
          		end
        	end
        end

     	-- Reaper's Scythe respawn time increase
      	if killing_ability then
        	if killing_ability:GetAbilityName() == "necrolyte_reapers_scythe" then
                local respawn_extra_time = killing_ability:GetLevelSpecialValueFor("respawn_constant", killing_ability:GetLevel() - 1)
          		respawn_time = respawn_time + respawn_extra_time
        	end
      	end

      	-- Neutral Suicide Penalty
      	if ( killer_unit:IsNeutralUnitType() or killer_unit:IsAncient() ) then
        	respawn_time = math.max(respawn_time , NEUTRAL_SUICIDE_DEATH_TIME_EARLY_GAME)
      	end

      	-- Tower Suicide / Tower Death Penalty in Early Game
      	if ( killer_unit:IsTower() ) and (not (killer_unit:IsNeutralUnitType() or killer_unit:IsAncient())) then
        	if respawn_time < 25 then 
          		respawn_time = respawn_time + TOWER_SUICIDE_ADDITIONAL_DEATH_TIME_EARLY_GAME
        	end
      	end

      	--Final Result
        killed_unit:SetTimeUntilRespawn(respawn_time)
    end
end
