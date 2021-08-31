-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  if GameMode._reentrantCheck then
    return
  end

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    --Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    GameMode:PostLoadPrecache()
    GameMode:OnAllPlayersLoaded()

    if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
      for i=0,9 do
        if PlayerResource:IsValidPlayer(i) then
          local color = TEAM_COLORS[PlayerResource:GetTeam(i)]
          PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
        end
      end
    end
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end

  GameMode._reentrantCheck = true
  GameMode:OnGameRulesStateChange(keys)
  GameMode._reentrantCheck = false
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:_OnNPCSpawned(keys)
  if GameMode._reentrantCheck then
    return
  end

  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    GameMode:OnHeroInGame(npc)
  end

  GameMode._reentrantCheck = true
  GameMode:OnNPCSpawned(keys)
  GameMode._reentrantCheck = false
end

-- An entity died
function GameMode:_OnEntityKilled( keys )
  if GameMode._reentrantCheck then
    return
  end

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then 
    DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( killerEntity:GetTeam() )
    end

    --PlayerResource:GetTeamKills
    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
    end
  end

  GameMode._reentrantCheck = true
  GameMode:OnEntityKilled( keys )
  GameMode._reentrantCheck = false
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  if GameMode._reentrantCheck then
    return
  end

  GameMode:_CaptureGameMode()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  local userID = keys.userid

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply

	GameMode._reentrantCheck = true
	GameMode:OnConnectFull( keys )
	GameMode._reentrantCheck = false
end




--###################################
-------------------------------------
-- Stuff from the old event down here
-------------------------------------
--###################################


--Skill Points at every level

function GameMode:OnPlayerLevelUp(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level

  local playerID
  local hero

  if player then
    playerID = player:GetPlayerID()
    hero = PlayerResource:GetAssignedHero(playerID)
  end

  	if hero then
 
    	-- Update hero gold bounty when a hero gains a level, Unnecessary when we work with filters?
    	--[[if USE_CUSTOM_HERO_GOLD_BOUNTY then
      		local hero_level = hero:GetLevel() or level
      		local hero_streak = hero:GetStreak()
      		local gold_bounty
      		
      		if hero_streak > 2 then
        		gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL + math.min((hero_streak-2) * HERO_KILL_GOLD_PER_STREAK,1000)
      		else
        		gold_bounty = HERO_KILL_GOLD_BASE + hero_level * HERO_KILL_GOLD_PER_LEVEL
      		end

      		hero:SetMinimumGoldBounty(gold_bounty)
      		hero:SetMaximumGoldBounty(gold_bounty)
    	end]]

    	--[[ Add a skill point when a hero levels OUTDATED
    	if SKILL_POINTS_AT_EVERY_LEVEL then
      		local levels_without_ability_point = {17, 19, 21, 22, 23, 24} -- on this levels you should get a skill point
      			for i = 1, #levels_without_ability_point do
        			if level == levels_without_ability_point[i] then
          				local unspent_ability_points = hero:GetAbilityPoints()
          				hero:SetAbilityPoints(unspent_ability_points+1)
        			end
      			end
    	end
      ]]
    end
end



-- 6.88 Armor Calculation and nerfed regen being closer to pre 7.00 era

function GameMode:OnNPCSpawned(keys)
  -- Apply modifiers that makes units obey our armour formula and heroes not have cancer regen
  local npc = EntIndexToHScript(keys.entindex)

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
