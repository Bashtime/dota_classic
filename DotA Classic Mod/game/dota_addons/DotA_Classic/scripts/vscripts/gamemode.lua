if GameMode == nil then
	_G.GameMode = class({})
end

-- clientside KV loading
require('addon_init')

if IsInToolsMode() then -- might lag a bit and backend to get errors not working yet
	require('internal/eventtest')
end

require('libraries/adv_log') -- be careful! this library can hide lua errors in rare cases

require('settings')
require('libraries/keyvalues')
require('libraries/notifications')
require('libraries/player')
require('libraries/player_resource')
require('libraries/timers')

require('internal/gamemode')
require('internal/events')

require('components/courier/init')

require('events/events')
require('filters')

-- Use this function as much as possible over the regular Precache (this is Async Precache)
function GameMode:PostLoadPrecache()
	
end

function GameMode:OnFirstPlayerLoaded()
	
end

function GameMode:OnAllPlayersLoaded()
	-- Setup filters
	GameRules:GetGameModeEntity():SetHealingFilter( Dynamic_Wrap(GameMode, "HealingFilter"), self )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, "DamageFilter"), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "GoldFilter"), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, "ExperienceFilter"), self)
	GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode, "ModifierFilter"), self)
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(GameMode, "ItemAddedFilter"), self)
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(GameMode, "BountyRuneFilter"), self)
	GameRules:GetGameModeEntity():SetThink("OnThink", self, 1)
	GameRules:GetGameModeEntity():SetPauseEnabled(not IMBA_PICK_SCREEN)
	
	GameRules:GetGameModeEntity():SetRuneSpawnFilter(Dynamic_Wrap(GameMode, "RuneSpawnFilter"), self)

	if IsInToolsMode() then
		Convars:RegisterCommand('events_test', function() GameMode:StartEventTest() end, "events test", FCVAR_CHEAT)
	end
end

-- CAREFUL, FOR REASONS THIS FUNCTION IS ALWAYS CALLED TWICE
function GameMode:InitGameMode()
	self:_InitGameMode()
end

-- Set up fountain regen
function GameMode:SetupFountains()
--[[

	local fountainEntities = Entities:FindAllByClassname("ent_dota_fountain")
	for _, fountainEnt in pairs(fountainEntities) do
		fountainEnt:AddNewModifier(fountainEnt, fountainEnt, "modifier_fountain_aura_lua", {})
		fountainEnt:AddAbility("imba_fountain_danger_zone"):SetLevel(1)

		-- remove vanilla fountain healing
		if fountainEnt:HasModifier("modifier_fountain_aura") then
			fountainEnt:RemoveModifierByName("modifier_fountain_aura")
			fountainEnt:AddNewModifier(fountainEnt, nil, "modifier_fountain_aura_lua", {})
		end
	end
--]]
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