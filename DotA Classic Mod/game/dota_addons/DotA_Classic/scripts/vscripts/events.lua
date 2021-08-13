-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

--Credits go to Darkonius

require('settings')

if not CDOTA_PlayerResource.UserIDToPlayerID then
	CDOTA_PlayerResource.UserIDToPlayerID = {}
end

if CDOTA_PlayerResource.PlayerData == nil then
	CDOTA_PlayerResource.PlayerData = {}
end

-- PlayerID stays the same after disconnect/reconnect
-- Player is volatile; After disconnect its destroyed.
-- what about userid?
function CDOTA_PlayerResource:OnPlayerConnect(event)
		local userID = event.userid
		local playerID = event.index or event.PlayerID

	if not self.PlayerData[playerID] then
				self.UserIDToPlayerID[userID] = playerID
				self.PlayerData[playerID] = {}
		self.PlayerData[playerID].has_abandoned_due_to_long_disconnect = false
		self.PlayerData[playerID].distribute_gold_to_allies = false
		end
end

-- Verifies if this player ID already has player data assigned to it
function CDOTA_PlayerResource:IsRealPlayer(playerID)
	if self.PlayerData[playerID] then
		return true
	else
		return false
	end
end

-- Assigns a hero to a player
function CDOTA_PlayerResource:AssignHero(playerID, hero_entity)
	if self:IsRealPlayer(playerID) then
		self.PlayerData[playerID].hero = hero_entity
		self.PlayerData[playerID].hero_name = hero_entity:GetUnitName()
	end
end

-- Fetches a player's hero
function CDOTA_PlayerResource:GetAssignedHero(playerID)
	if self:IsRealPlayer(playerID) then
		local player = self:GetPlayer(playerID)
		if player then 
			local hero = player:GetAssignedHero()
			if hero then
				return hero
			else
				return self.PlayerData[playerID].hero
			end
		else
			return self.PlayerData[playerID].hero
		end
	elseif self:IsFakeClient(playerID) then
		-- For bots
		local player = self:GetPlayer(playerID)
		return player:GetAssignedHero()
	else
		local player = self:GetPlayer(playerID)
		if player then
			return player:GetAssignedHero()
		end
	end
	return nil
end

-- Fetches a player's hero name
function CDOTA_PlayerResource:GetAssignedHeroName(playerID)
	if self:IsRealPlayer(playerID) then
		return self.PlayerData[playerID].hero_name
	end
	return nil
end


-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
	--DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
	--DebugPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end


-- The overall game state has changed
function GameMode:OnGameRulesStateChange()
	--DebugPrint("[BAREBONES] GameRules State Changed")

	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		Timers:CreateTimer(2.0, function()
			if tostring(PlayerResource:GetSteamID(0)) == "76561198015161808" or tostring(PlayerResource:GetSteamID(0)) == "76561198047612370" then
				BOTS_ENABLED = true
			end

			if BOTS_ENABLED == true then
				SendToServerConsole('sm_gmode 1')
				SendToServerConsole('dota_bot_populate')
			end
		end)
	elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			if PlayerResource:IsValidPlayer(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
				if not PlayerResource:HasSelectedHero(i) then
					PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
					PlayerResource:SetCanRepick(i, false)
				end
			end
		end
	elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
		-- shows -1 for some reason by default
		GameRules:GetGameModeEntity():SetCustomDireScore(0)
	end 
	end 
	
	--Change Tower Models
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		direUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                  Vector(0, 0, 0),
                  nil,
                  FIND_UNITS_EVERYWHERE,
                  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                  DOTA_UNIT_TARGET_ALL,
                  DOTA_UNIT_TARGET_FLAG_NONE,
                  FIND_ANY_ORDER,
                  false)

		-- Change Tower Models for dire
			for _,unit in pairs(direUnits) do
				if unit:IsTower() then 
					unit:SetModel("models/items/world/towers/ti10_dire_tower/ti10_dire_tower.vmdl")
					unit:SetOriginalModel("models/items/world/towers/ti10_dire_tower/ti10_dire_tower.vmdl")
				end 
			end

		radiantUnits = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                  Vector(0, 0, 0),
                  nil,
                  FIND_UNITS_EVERYWHERE,
                  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                  DOTA_UNIT_TARGET_ALL,
                  DOTA_UNIT_TARGET_FLAG_NONE,
                  FIND_ANY_ORDER,
                  false)

		-- Change Tower Models for radiant
			for _,unit in pairs(radiantUnits) do
				if unit:IsTower() then 
					unit:SetModel("models/props_structures/rock_golem/tower_radiant_rock_golem.vmdl")
					unit:SetOriginalModel("models/props_structures/rock_golem/tower_radiant_rock_golem.vmdl")
				end 
			end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
	--DebugPrint("[BAREBONES] Entity Hurt")
	--DebugPrintTable(keys)

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless
	if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
		local entCause = EntIndexToHScript(keys.entindex_attacker)
		local entVictim = EntIndexToHScript(keys.entindex_killed)

		-- The ability/item used to damage, or nil if not damaged by an item/ability
		local damagingAbility = nil

		if keys.entindex_inflictor ~= nil then
			damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
		end
	end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
	--DebugPrint( '[BAREBONES] OnItemPickedUp' )
	--DebugPrintTable(keys)

	local unitEntity = nil
	if keys.UnitEntitIndex then
		unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
	elseif keys.HeroEntityIndex then
		unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
	end

	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname


end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
	--DebugPrint( '[BAREBONES] OnPlayerReconnect' )
 -- DebugPrintTable(keys) 
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
	--DebugPrint( '[BAREBONES] OnItemPurchased' )
	--DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname 
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost
	
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local hero = EntIndexToHScript(keys.caster_entindex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname

  --Adding decreasing MR to BKB
  if abilityname == "item_black_king_bar" then 
    if not hero:HasModifier("modifier_bkb_mr") then
      hero:AddNewModifier(hero, item_black_king_bar, "modifier_bkb_mr", { duration = -1})
      hero:SetModifierStackCount("modifier_bkb_mr", hero, 10)
    else
      local stack_count = hero:GetModifierStackCount("modifier_bkb_mr", hero)
      if stack_count > 5 then hero:SetModifierStackCount("modifier_bkb_mr", hero, stack_count - 1) end
    end
  end


  --Surprise MFer, Exoctic Mango not as innocuous as you thought
  if abilityname == "item_enchanted_mango" then
    if RandomInt(1, 10000) <= MANGOCHANCE then 
      hero:Kill(nil,hero)
      MANGOCHANCE = CVALUE_MANGO
    else
      MANGOCHANCE = MANGOCHANCE + CVALUE_MANGO
    end
  end


  --Holy Locket Charge Mechanic

  -- Find Heroes around the caster
  local enemies = FindUnitsInRadius(
    hero:GetTeamNumber(), -- int, your team number
    hero:GetOrigin(), -- point, center point
    nil,  -- handle, cacheUnit. (not known)
    1200, -- float, radius. or use FIND_UNITS_EVERYWHERE
    DOTA_UNIT_TARGET_TEAM_ENEMY,  -- int, team filter
    DOTA_UNIT_TARGET_HERO, -- int, type filter
    DOTA_UNIT_TARGET_FLAG_NONE,  -- int, flag filter
    0,  -- int, order filter
    false -- bool, can grow cache
    )

  for _,enemy in pairs(enemies) do 

    if enemy:HasModifier("modifier_holy_locket_classic_passive") then
      --Check if Locket carrier can see the caster 
      local result = UnitFilter(
          hero, -- Target Filter
          DOTA_UNIT_TARGET_TEAM_ENEMY,  -- Team Filter
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- Unit Filter
          DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,  -- Unit Flag
          enemy:GetTeamNumber()  -- Team reference
          )

      if result == UF_SUCCESS then

        local bAddCharges = true --Checks if charges are allowed to be added

        --Check if Wands or Sticks are not full yet
        for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do

          local item = enemy:GetItemInSlot(i)

          if item then

            if (item:GetName() == "item_magic_stick") and (item:GetCurrentCharges() < 10) then
              --print("Stick has" ..item:GetCurrentCharges())
              bAddCharges = false
              break
            end

            if (item:GetName() == "item_magic_wand") and (item:GetCurrentCharges() < 20 ) then
              --print("Wand has" ..item:GetCurrentCharges())
              bAddCharges = false
              break
            end

          end --the item exists
        end --loop end

        
        for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
          local item = enemy:GetItemInSlot(i)

          if item then
          --Only add charges to the first Locket
            if (item:GetName() == "item_holy_locket_classic") and bAddCharges then
              local k = item:GetCurrentCharges()

              if k<20 then
                item:SetCurrentCharges(k+1)
                break
              end
            end
          end
        end
      end
    end --if-end for locket carriers 
  end --loop end every found hero around the caster]]
end --function end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname =  keys.abilityname
  local hero = EntIndexToHScript(keys.caster_entindex)

  for k,v in pairs(keys) do
    print(k,v)
  end

  --Holy Locket Charge Mechanic

  --Find Heroes around the caster
  local enemies = FindUnitsInRadius(
    hero:GetTeamNumber(), -- int, your team number
    hero:GetOrigin(), -- point, center point
    nil,  -- handle, cacheUnit. (not known)
    1200, -- float, radius. or use FIND_UNITS_EVERYWHERE
    DOTA_UNIT_TARGET_TEAM_ENEMY,  -- int, team filter
    DOTA_UNIT_TARGET_HERO, -- int, type filter
    DOTA_UNIT_TARGET_FLAG_NONE,  -- int, flag filter
    0,  -- int, order filter
    false -- bool, can grow cache
    )

  for _,enemy in pairs(enemies) do 

    if enemy:HasModifier("modifier_holy_locket_classic_passive") then
      --Check if Locket carrier can see the caster 
      local result = UnitFilter(
          hero, -- Target Filter
          DOTA_UNIT_TARGET_TEAM_ENEMY,  -- Team Filter
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- Unit Filter
          DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,  -- Unit Flag
          enemy:GetTeamNumber()  -- Team reference
          )

      if result == UF_SUCCESS then

        local bAddCharges = true --Checks if charges are allowed to be added

        --Check if Wands or Sticks are not full yet
        for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do

          local item = enemy:GetItemInSlot(i)

          if item then

            if (item:GetName() == "item_magic_stick") and (item:GetCurrentCharges() < 10) then
              --print("Stick has" ..item:GetCurrentCharges())
              bAddCharges = false
              break
            end

            if (item:GetName() == "item_magic_wand") and (item:GetCurrentCharges() < 20 ) then
              --print("Wand has" ..item:GetCurrentCharges())
              bAddCharges = false
              break
            end

          end --the item exists
        end --loop end

        
        for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
          local item = enemy:GetItemInSlot(i)

          if item then
          --Only add charges to the first Locket
            if (item:GetName() == "item_holy_locket_classic") and bAddCharges then
              local k = item:GetCurrentCharges()

              if k<20 then
                item:SetCurrentCharges(k+1)
                break
              end
            end
          end
        end
      end
    end --if-end for locket carriers 
  end --loop end every found hero around the caster]]
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
	--DebugPrint('[BAREBONES] OnPlayerChangedName')
	--DebugPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
  local hero

  --AM leveling his vanilla-skill talent
  if abilityname == "antimage_counterspell" then
    hero = player:GetAssignedHero()
    local stack_count = hero:GetModifierStackCount("modifier_talent_lvl", hero)
    print(hero)
    print(stack_count)
    hero:SetModifierStackCount("modifier_talent_lvl", hero, stack_count + 1)
  end

  --Lifestealer leveling his vanilla-skill talent
  if abilityname == "life_stealer_infest" then
    hero = player:GetAssignedHero()
    local stack_count = hero:GetModifierStackCount("modifier_talent_lvl", hero)
    hero:SetModifierStackCount("modifier_talent_lvl", hero, stack_count + 1)
  end  
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
	--DebugPrint('[BAREBONES] OnAbilityChannelFinished')
	--DebugPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
	--DebugPrint("[BAREBONES] OnPlayerLevelUp")
	--PrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local level = keys.level

	local playerID
	local hero
	if player then
		playerID = player:GetPlayerID()
		hero = PlayerResource:GetAssignedHero(playerID)
	end

	if hero then
		-- Update hero gold bounty when a hero gains a level
		if USE_CUSTOM_HERO_GOLD_BOUNTY then
			local hero_level = hero:GetLevel() or level
			local hero_streak = hero:GetStreak()

			local gold_bounty
			if hero_streak > 2 then
				gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL + math.min((hero_streak-2)*HERO_KILL_GOLD_PER_STREAK,1000)
			else
				gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL
			end

			hero:SetMinimumGoldBounty(gold_bounty)
			hero:SetMaximumGoldBounty(gold_bounty)
		end

		-- Add a skill point when a hero levels
		if SKILL_POINTS_AT_EVERY_LEVEL then
			local levels_without_ability_point = {17, 19, 21, 22, 23, 24} -- on this levels you should get a skill point
			for i = 1, #levels_without_ability_point do
				if level == levels_without_ability_point[i] then
					local unspent_ability_points = hero:GetAbilityPoints()
					hero:SetAbilityPoints(unspent_ability_points+1)
				end
			end
		end
	end
end



-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
	--DebugPrint('[BAREBONES] OnLastHit')
	--DebugPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	--DebugPrint('[BAREBONES] OnTreeCut')
	--DebugPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
	--DebugPrint('[BAREBONES] OnRuneActivated')
	--DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune

	--[[ Rune Can be one of the following types
	DOTA_RUNE_DOUBLEDAMAGE
	DOTA_RUNE_HASTE
	DOTA_RUNE_HAUNTED
	DOTA_RUNE_ILLUSION
	DOTA_RUNE_INVISIBILITY
	DOTA_RUNE_BOUNTY
	DOTA_RUNE_MYSTERY
	DOTA_RUNE_RAPIER
	DOTA_RUNE_REGENERATION
	DOTA_RUNE_SPOOKY
	DOTA_RUNE_TURBO
	]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
	--DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
	--DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
	--DebugPrint('[BAREBONES] OnPlayerPickHero')
	--DebugPrintTable(keys)

	local heroClass = keys.hero
	local heroEntity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
	--DebugPrint('[BAREBONES] OnTeamKillCredit')
	--DebugPrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
	--DebugPrint( '[BAREBONES] OnEntityKilled Called' )
	--DebugPrintTable( keys )
	

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	-- The ability/item used to kill, or nil if not killed by an item/ability
	local killerAbility = nil

	if keys.entindex_inflictor ~= nil then
		killerAbility = EntIndexToHScript( keys.entindex_inflictor )
	end

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	-- Put code here to handle when an entity gets killed

	if killedUnit:IsRealHero() then
		GameRules:GetGameModeEntity():SetCustomDireScore(GetTeamHeroKills(DOTA_TEAM_BADGUYS))
	end
end


-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
	--DebugPrint("[BAREBONES] OnLastHit")
	--PrintTable(keys)

	local IsFirstBlood = keys.FirstBlood == 1
	local IsHeroKill = keys.HeroKill == 1
	local IsTowerKill = keys.TowerKill == 1

	-- Player ID that got a last hit
	local playerID = keys.PlayerID

	-- Killed unit (creep, hero, tower etc.)
	local killed_entity = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	--DebugPrint("[BAREBONES] OnTreeCut")
	--PrintTable(keys)

	-- Tree coordinates on the map
	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated(keys)
	--DebugPrint("[BAREBONES] OnRuneActivated")
	--PrintTable(keys)

	local playerID = keys.PlayerID
	local rune = keys.rune

	-- For Bounty Runes use BountyRuneFilter
	-- For modifying which runes spawn use RuneSpawnFilter
	-- This event can be used for adding more effects to existing runes.
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
	--DebugPrint("[BAREBONES] OnPlayerTakeTowerDamage")
	--PrintTable(keys)

	local playerID = keys.PlayerID
	local damage = keys.damage
end

-- A player picked or randomed a hero (this is happening before OnHeroInGame because OnHeroInGame has a timers delay).
function GameMode:OnPlayerPickHero(keys)
	--DebugPrint("[BAREBONES] OnPlayerPickHero")
	--PrintTable(keys)

	local hero_name = keys.hero
	local hero_entity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)

	Timers:CreateTimer(0.5, function()
		local playerID = hero_entity:GetPlayerID() -- or player:GetPlayerID() if player is not disconnected




		 --[[ Random Mechanic at Pick Phase
		 if PlayerResource:HasRandomed(playerID) then
				 
				hero_name:ModifyGold(200,false,DOTA_ModifyGold_Unspecified)
		 end ]] 




		if PlayerResource:IsFakeClient(playerID) then
			-- This is happening only for bots when they spawn for the first time or if they use custom hero-create spells (Custom Illusion spells)
		else
			if not PlayerResource.PlayerData[playerID] then
				PlayerResource.PlayerData[playerID] = {}
				--DebugPrint("[BAREBONES] PlayerResource's PlayerData for playerID "..playerID.." was not properly initialized.")
			end
			if PlayerResource.PlayerData[playerID].already_assigned_hero == true then
				-- This is happening only when players create new heroes with spells (Custom Illusion spells)
			else
				PlayerResource:AssignHero(playerID, hero_entity)
				PlayerResource.PlayerData[playerID].already_assigned_hero = true
			end
		end
	end)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
	--DebugPrint("[BAREBONES] OnTeamKillCredit")
	--PrintTable(keys)

	local killer_userID = keys.killer_userid
	local victim_userID = keys.victim_userid
	local streak = keys.herokills
	local killer_team = keys.teamnumber

	-- If you want to change assist gold or assist experience on hero death use OnEntityKilled or Damage Filter, not this
end

-- An entity died (an entity killed an entity)
function GameMode:OnEntityKilled(keys)
	--DebugPrint("[BAREBONES] An entity was killed.")
	--PrintTable(keys)

	-- The Unit that was Killed
	local killed_unit = EntIndexToHScript(keys.entindex_killed)

	-- The Killing entity
	local killer_unit = nil

	if keys.entindex_attacker ~= nil then
		killer_unit = EntIndexToHScript(keys.entindex_attacker)
	end

	-- The ability/item used to kill, or nil if not killed by an item/ability
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

	-- Killed Unit is a hero (not an illusion) and he is not reincarnating
	if killed_unit:IsRealHero() and (not killed_unit:IsReincarnating()) then

				--Calculate Gold Lost on Death
				local playerID = killed_unit:GetPlayerID()
				local herolvl = killed_unit:GetLevel()
				local deathcost = CUSTOM_DEATH_GOLD_COST[herolvl]

				--Modify Gold after Death
				killed_unit:ModifyGold(-deathcost, false, DOTA_ModifyGold_Death)

		-- Hero gold bounty update for the killer
		if USE_CUSTOM_HERO_GOLD_BOUNTY then
			if killer_unit:IsRealHero() then
				-- Get his killing streak
				local hero_streak = killer_unit:GetStreak()
				-- Get his level
				local hero_level = killer_unit:GetLevel()
				-- Adjust Gold bounty
				local gold_bounty
				if hero_streak > 2 then
					gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL + (hero_streak-2)*HERO_KILL_GOLD_PER_STREAK
				else
					gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL
				end

				killer_unit:SetMinimumGoldBounty(gold_bounty)
				killer_unit:SetMaximumGoldBounty(gold_bounty)
			end
		end

		-- Hero Respawn time configuration
		if ENABLE_HERO_RESPAWN then
			local killed_unit_level = killed_unit:GetLevel()

			-- Respawn time without buyback penalty (+25 sec)
			local respawn_time = 1
			if USE_CUSTOM_RESPAWN_TIMES then
				-- Get respawn time from the table that we defined
				respawn_time = CUSTOM_RESPAWN_TIME[killed_unit_level]



			else
				-- Get dota default respawn time
				respawn_time = killed_unit:GetRespawnTime()
			end

			-- Bloodstone reduction (bloodstone can't be in backpack)
			-- for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
				-- local item = killed_unit:GetItemInSlot(i)
				-- if item then
					-- if item:GetName() == "item_bloodstone" then
						-- local current_charges = item:GetCurrentCharges()
						-- local charges_before_death = math.ceil(current_charges*1.5)
						-- local reduction_per_charge = item:GetLevelSpecialValueFor("respawn_time_reduction", item:GetLevel() - 1)
						-- local respawn_reduction = charges_before_death*reduction_per_charge
						-- respawn_time = math.max(1, respawn_time-respawn_reduction)
						-- break -- break the for loop, to prevent multiple bloodstones granting respawn reduction
					-- end
				-- end
			-- end

			-- Reaper's Scythe respawn time increase
			if killing_ability then
				if killing_ability:GetAbilityName() == "necrolyte_reapers_scythe" then
					--DebugPrint("[BAREBONES] A hero was killed by a Necro Reaper's Scythe. Increasing respawn time!")
					local respawn_extra_time = killing_ability:GetLevelSpecialValueFor("respawn_constant", killing_ability:GetLevel() - 1)
					respawn_time = respawn_time + respawn_extra_time
				end
			end


			-- Killer is a neutral creep
			if killer_unit:IsNeutralUnitType() or killer_unit:IsAncient() then
				-- If a hero is killed by a neutral creep, respawn time can be modified here
				respawn_time = math.max(respawn_time,24)
			end

			if (killer_unit:IsTower() ) and (not (killer_unit:IsNeutralUnitType() or killer_unit:IsAncient())) then
			-- Put stuff here that you want to happen if a hero is killed by a creep, tower or fountain.
				if respawn_time < 25 then 
					respawn_time = respawn_time + 5
				else if respawn_time < 28 then 
					respawn_time = respawn_time + 3.8
						end
				end
			end

			if killer_unit:IsCreep() then
				respawn_time = respawn_time
			end

			-- Maximum Respawn Time
			if respawn_time > MAX_RESPAWN_TIME then
				--DebugPrint("Reducing respawn time of "..killed_unit:GetUnitName().." because it was too long.")
				respawn_time = MAX_RESPAWN_TIME
			end






			if not killed_unit:IsReincarnating() then
				killed_unit:SetTimeUntilRespawn(respawn_time)
			end

		end

		--Buyback Cooldown
		if CUSTOM_BUYBACK_COOLDOWN_ENABLED then
			PlayerResource:SetCustomBuybackCooldown(killed_unit:GetPlayerID(), CUSTOM_BUYBACK_COOLDOWN_TIME)
		end 

		-- Buyback old formula
		if CUSTOM_BUYBACK_COST_ENABLED then
			local victimlvl = killed_unit:GetLevel()
			local time = GameRules:GetGameTime()
			local bbcost = 120 + (time - PRE_GAME_TIME) * 0.25 + victimlvl * victimlvl * 1.5
			PlayerResource:SetCustomBuybackCost(killed_unit:GetPlayerID(), bbcost)
		end




		-- Killer is not a real hero but it killed a hero
		if killer_unit:IsTower() or killer_unit:IsCreep() then
			-- Put stuff here that you want to happen if a hero is killed by a creep, tower or fountain.
			local victimlvl = killed_unit:GetLevel()
			local time = GameRules:GetGameTime()
			local bbcost = 120 + (time - PRE_GAME_TIME) * 0.25 + victimlvl * victimlvl * 1.5
			PlayerResource:SetCustomBuybackCost(killed_unit:GetPlayerID(), bbcost)
		end


		-- When team hero kill limit is reached declare the winner
		if END_GAME_ON_KILLS and GetTeamHeroKills(killer_unit:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
			GameRules:SetGameWinner(killer_unit:GetTeam())
		end

		-- Setting top bar values
		if SHOW_KILLS_ON_TOPBAR then
			GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS))
			GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
		end
	end

	-- Ancient destruction detection (if the map doesn't have ancients with these names, this will never happen)
	if killed_unit:GetUnitName() == "npc_dota_badguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		GameRules:SetCustomVictoryMessage("#dota_post_game_radiant_victory")
		GameRules:SetCustomVictoryMessageDuration(POST_GAME_TIME)
	elseif killed_unit:GetUnitName() == "npc_dota_goodguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		GameRules:SetCustomVictoryMessage("#dota_post_game_dire_victory")
		GameRules:SetCustomVictoryMessageDuration(POST_GAME_TIME)
	end

	-- Remove dead non-hero units from selection -> bugged ability/cast bar
	if killed_unit:IsIllusion() or (killed_unit:IsControllableByAnyPlayer() and (not killed_unit:IsRealHero()) and (not killed_unit:IsCourier()) and (not killed_unit:IsClone())) and (not killed_unit:IsTempestDouble()) then
		local player = killed_unit:GetPlayerOwner()
		local playerID
		if player == nil then
			playerID = killed_unit:GetPlayerOwnerID()
		else
			playerID = player:GetPlayerID()
		end
		
		if Selection then
			-- Without Selection library this will return an error
			PlayerResource:RemoveFromSelection(playerID, killed_unit)
		end
	end
end




-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
	--DebugPrint('[BAREBONES] PlayerConnect')
	--DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	--DebugPrint('[BAREBONES] OnConnectFull')
	--DebugPrintTable(keys)
	
	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)
	
	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
	--DebugPrint('[BAREBONES] OnIllusionsCreated')
	--DebugPrintTable(keys)

	local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
	--DebugPrint('[BAREBONES] OnItemCombined')
	--DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end
	local player = PlayerResource:GetPlayer(plyID)

	-- The name of the item purchased
	local itemName = keys.itemname 
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
	--DebugPrint('[BAREBONES] OnAbilityCastBegins')
	--DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
	--DebugPrint('[BAREBONES] OnTowerKill')
	--DebugPrintTable(keys)

	local gold = keys.gold
	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
	--DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
	--DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.player_id)
	local success = (keys.success == 1)
	local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
	--DebugPrint('[BAREBONES] OnNPCGoalReached')
	--DebugPrintTable(keys)

	local goalEntity = EntIndexToHScript(keys.goal_entindex)
	local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
	local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
	local teamonly = keys.teamonly
	local userID = keys.userid
	local playerID = self.vUserIds[userID]:GetPlayerID()

	local text = keys.text
end

function GameMode:OnNPCSpawned(keys)
	-- Apply modifiers that makes units obey our armour formula and heroes not have cancer regen
	local npc = EntIndexToHScript(keys.entindex)

	if npc.first_spawn ~= true then
		npc.first_spawn = true

		if npc:GetUnitName() == "npc_dota_courier" then
			Timers:CreateTimer(function()
				if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
					return 1.0
				end

				for i = 0, 24 do
					local ability = npc:GetAbilityByIndex(i)
					if ability then
--						print(ability:GetAbilityName())
					end
				end

				for i = 0, npc:GetModifierCount() - 1 do
					local modifier = npc:GetModifierNameByIndex(i)

--					print(modifier)

					if modifier == "modifier_courier_passive_bonus" then
						npc:RemoveModifierByName("modifier_courier_passive_bonus")
						npc:AddNewModifier(npc, nil, "modifier_courier_passive_bonus_688", {})
						return nil
					end
				end

				return 1.0
			end)
		end

		npc:AddNewModifier(npc, nil, "modifier_common_custom_armor", {})

		if npc:IsHero() then
			npc:AddNewModifier(npc, nil, "modifier_nerf_cancer_regen", {})
			npc:AddNewModifier(npc, nil, "modifier_talent_lvl", {})
			npc:AddNewModifier(npc, nil, "modifier_spell_amp_int", {})
			npc:AddNewModifier(npc, nil, "modifier_bots_and_botsii", {})
			npc:AddNewModifier(npc, nil, "modifier_perc_mana_reg", {})
			npc:AddNewModifier(npc, nil, "modifier_aura_cosmetics", {})

			local particle_cast = {}
       particle_cast[0] = "particles/scepter_aura_blue.vpcf"
       particle_cast[1] = "particles/scepter_aura_teal.vpcf"
       particle_cast[2] = "particles/scepter_aura_purple.vpcf"
       particle_cast[3] = "particles/scepter_aura_yellow.vpcf"
       particle_cast[4] = "particles/scepter_aura_orange.vpcf"
       particle_cast[5] = "particles/scepter_aura_pink.vpcf"
       particle_cast[6] = "particles/scepter_aura_olive.vpcf"
       particle_cast[7] = "particles/scepter_aura_lightblue.vpcf"
       particle_cast[8] = "particles/scepter_aura_darkgreen.vpcf"
       particle_cast[9] = "particles/scepter_aura_brown.vpcf"

      local playercolor_ring = ParticleManager:CreateParticle( particle_cast[npc:GetPlayerID()], PATTACH_ABSORIGIN_FOLLOW, npc )
		end

		if (npc:IsTower() and npc:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then 
			self:GetParent():SetModel("models/props_structures/rock_golem/tower_radiant_rock_golem.vmdl")
			self:GetParent():SetOriginalModel("models/props_structures/rock_golem/tower_radiant_rock_golem.vmdl")
		elseif (npc:IsTower() and npc:GetTeamNumber() == DOTA_TEAM_BADGUYS) then 
			self:GetParent():SetModel("models/items/world/towers/ti10_dire_tower/ti10_dire_tower.vmdl")
			self:GetParent():SetOriginalModel("models/items/world/towers/ti10_dire_tower/ti10_dire_tower.vmdl")		
		end
	end

	--[[ Adjusting XP and Gold gain for lane creeps
		if npc:GetUnitName() == "npc_dota_creep_goodguys_ranged" or npc:GetUnitName() == "npc_dota_creep_badguys_ranged" then
			npc:SetDeathXP(41)
			npc:SetMinimumGoldBounty(42)
			npc:SetMaximumGoldBounty(48)

		end

		if npc:GetUnitName() == "npc_dota_creep_goodguys_melee" or npc:GetUnitName() == "npc_dota_creep_badguys_melee" then
			npc:SetDeathXP(62)
			npc:SetMinimumGoldBounty(38)
			npc:SetMaximumGoldBounty(48)
		end

		if npc:IsNeutralUnitType() then

			-- Revert Jungle XP nerf
			local old_xp_bounty = npc:GetDeathXP()
			local new_xp_bounty = math.floor(old_xp_bounty * 1.316)
			
			-- Set new xp bounty
			npc:SetDeathXP(new_xp_bounty)

			-- Revert Jungle Gold nerf
			local gold_min
			local gold_max

			gold_min = math.floor(npc:GetMinimumGoldBounty() * 1.316)
			gold_max = math.floor(npc:GetMaximumGoldBounty() * 1.316)

			npc:SetMinimumGoldBounty(gold_min)
			npc:SetMaximumGoldBounty(gold_max)

		end]]

end


-- Gold filter, can be used to modify how much gold player gains/loses
function GameMode:GoldFilter(keys)
	print(keys)

	local gold = keys.gold
	local playerID = keys.player_id_const
	local reason = keys.reason_const
	local reliable = keys.reliable

	-- Reasons:
	-- DOTA_ModifyGold_Unspecified = 0
	-- DOTA_ModifyGold_Death = 1
	-- DOTA_ModifyGold_Buyback = 2
	-- DOTA_ModifyGold_PurchaseConsumable = 3
	-- DOTA_ModifyGold_PurchaseItem = 4
	-- DOTA_ModifyGold_AbandonedRedistribute = 5
	-- DOTA_ModifyGold_SellItem = 6
	-- DOTA_ModifyGold_AbilityCost = 7
	-- DOTA_ModifyGold_CheatCommand = 8
	-- DOTA_ModifyGold_SelectionPenalty = 9
	-- DOTA_ModifyGold_GameTick = 10
	-- DOTA_ModifyGold_Building = 11
	-- DOTA_ModifyGold_HeroKill = 12
	-- DOTA_ModifyGold_CreepKill = 13
	-- DOTA_ModifyGold_RoshanKill = 14
	-- DOTA_ModifyGold_CourierKill = 15
	-- DOTA_ModifyGold_SharedGold = 16

	-- Disable all hero kill gold
	if DISABLE_ALL_GOLD_FROM_HERO_KILLS then
		if reason == DOTA_ModifyGold_HeroKill then
			return false
		end
	end

	if reason == DOTA_ModifyGold_CreepKill then

		return true
	end


	return true
end

--[[
-- Experience filter function
function GameMode:ExperienceFilter(keys)
	--PrintTable(keys)
	local xp = keys.experience
	local playerID = keys.player_id_const
	local reason = keys.reason_const

	-- Reasons:
	--DOTA_ModifyXP_Unspecified   0
	--DOTA_ModifyXP_HeroKill    1
	--DOTA_ModifyXP_CreepKill   2
	--DOTA_ModifyXP_RoshanKill    3

	--[[if reason == DOTA_ModifyXP_CreepKill then
		 if IsNeutralUnitType() or IsAncient() then 
			xp = GetDeathXP() * 1.25
			keys.experience = xp
		 end

		 if GetUnitName() == "npc_dota_creep_goodguys_ranged" or GetUnitName() == "npc_dota_creep_badguys_ranged" then
			xp = 41
			keys.experience = xp
		end

		return true
	end

	if reason == DOTA_ModifyXP_RoshanKill then
		local time = math.floor(GetElapsedTime() / 60)
		xp = math.min(1289 + time * 15, 1789)
		keys.experience = xp
		return true
	end  

	return true
end

-- Damage filter function
function GameMode:DamageFilter(keys)
	local attacker
	local victim
	if keys.entindex_attacker_const and keys.entindex_victim_const then
		attacker = EntIndexToHScript(keys.entindex_attacker_const)
		victim = EntIndexToHScript(keys.entindex_victim_const)
	else
		return false
	end

	-- Lack of entities handling (illusions error fix)
	if attacker:IsNull() or victim:IsNull() then
		return false
	end
	
	if keys.damage >= victim:GetHealth() then
		if victim:IsNeutralUnitType() then
			-- Adjust XP bounty
			local old_xp_bounty = victim:GetDeathXP()
			local new_xp_bounty = old_xp_bounty * 1.25
			
			-- Set new xp bounty
			victim:SetDeathXP(new_xp_bounty)
		end
		

		if victim:GetUnitName() == "npc_dota_creep_goodguys_ranged" or victim:GetUnitName() == "npc_dota_creep_badguys_ranged" then
			victim:SetDeathXP(41)
		end

		if victim:GetUnitName() == "npc_dota_creep_goodguys_melee" or victim:GetUnitName() == "npc_dota_creep_badguys_melee" then
			victim:SetDeathXP(62)
		end


	end
		
	return true

end]]