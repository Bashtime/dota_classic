-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)

  local newState = GameRules:State_Get()
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)

  local npc = EntIndexToHScript(keys.entindex)
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
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)

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
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DebugPrintTable(keys) 
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

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
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  --DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  --DebugPrintTable(keys)

  --[[for k,v in pairs(keys) do
    print(k,v)
  end]]

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
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  for k,v in pairs(keys) do
    print(keys)
  end

  local player = EntIndexToHScript(keys.player)
  local level = keys.level

  local hero = EntIndexToHScript(keys.hero_entindex)

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

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

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
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )
  DebugPrintTable( keys )
  

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
end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

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
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

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
