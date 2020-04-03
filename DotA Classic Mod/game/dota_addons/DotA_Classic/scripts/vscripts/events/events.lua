require('events/combat_events')
require('events/npc_spawned/on_hero_spawned')
require('events/npc_spawned/on_unit_spawned')
require('events/on_entity_killed/on_hero_killed')

function GameMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		InitItemIds()
		GameMode:OnSetGameMode() -- setup gamemode rules
	elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		-- random hero if time out. not required with EnablePickRules but just in case
		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			if PlayerResource:IsValidPlayer(i) and not PlayerResource:HasSelectedHero(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
				PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
				PlayerResource:SetCanRepick(i, false)
			end
		end
	elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
		-- Create a timer to avoid lag spike entering pick screen
		Timers:CreateTimer(3.0, function()
			if USE_TEAM_COURIER == true then
				COURIER_TEAM = {}
				for i = 2, 3 do
					local pos = {}
					pos[2] = Entities:FindByClassname(nil, "info_courier_spawn_radiant")
					pos[3] = Entities:FindByClassname(nil, "info_courier_spawn_dire")

					if pos[i] then
						COURIER_TEAM[i] = CreateUnitByName("npc_dota_courier", pos[i]:GetAbsOrigin(), true, nil, nil, i)
						COURIER_TEAM[i]:AddNewModifier(COURIER_TEAM[i], nil, "modifier_courier_turbo", {})
						COURIER_TEAM[i]:RemoveModifierByName("modifier_magic_immune")
						COURIER_TEAM[i]:AddAbility("courier_movespeed"):SetLevel(1)
					end
				end
			end

			-- ONLY SHOW THE DEMO PANEL IF IT'S ACTUALLY DEMO MODE (lest people get the wrong idea with thinking other players can use these "hacks")
--			if IsInToolsMode() then
--				CustomGameEventManager:Send_ServerToAllClients("ShowDemoPanel", {})
--			end
		end)
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- gold earning through old tick time
		Timers:CreateTimer(function()
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME then return nil end

			for i = 0, PlayerResource:GetPlayerCount() - 1 do
				if PlayerResource:IsValidPlayerID(i) then
					PlayerResource:ModifyGold(i, 1, true, DOTA_ModifyGold_GameTick)
				end
			end

			return GOLD_TICK_TIME
		end)
	end
end

function GameMode:OnNPCSpawned(keys)
	GameMode:_OnNPCSpawned(keys)

	local npc = EntIndexToHScript(keys.entindex)

	if npc then
		if npc.first_spawn ~= true then
			npc:AddNewModifier(npc, nil, "modifier_common_custom_armor", {})
			npc:AddNewModifier(npc, nil, "modifier_nerf_cancer_regen", {})
			npc.first_spawn = true
		end

		if npc:IsCourier() then
			if npc.first_spawn ~= true then
				npc:AddAbility("courier_movespeed"):SetLevel(1)
				npc.first_spawn = true
			end

			return
		elseif npc:IsRealHero() or npc:IsFakeHero() or npc:IsClone() then
			if npc.first_spawn ~= true then
				npc.first_spawn = true

				-- Need a frame time to detect illusions
				Timers:CreateTimer(FrameTime(), function()
					GameMode:OnHeroFirstSpawn(npc)
				end)

				return
			end

			GameMode:OnHeroSpawned(npc)

			return
		else
			if npc.first_spawn ~= true then
				npc.first_spawn = true
				GameMode:OnUnitFirstSpawn(npc)

				return
			end

			GameMode:OnUnitSpawned(npc)

			return
		end
	end
end

function GameMode:OnDisconnect(keys)
	-- GetConnectionState values:
	-- 0 - no connection
	-- 1 - bot connected
	-- 2 - player connected
	-- 3 - bot/player disconnected.

	-- Typical keys:
	-- PlayerID: 2
	-- name: Zimberzimber
	-- networkid: [U:1:95496383]
	-- reason: 2
	-- splitscreenplayer: -1
	-- userid: 7
	-- xuid: 76561198055762111

	
end

-- An entity died
function GameMode:OnEntityKilled(keys)
	GameMode:_OnEntityKilled(keys)

	-- The Unit that was killed
	local killed_unit = EntIndexToHScript(keys.entindex_killed)

	-- The Killing entity
	local killer = nil

	if keys.entindex_attacker then
		killer = EntIndexToHScript(keys.entindex_attacker)
	end

	if killed_unit then
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

		-- Check if the dying unit was a player-controlled hero
		if killed_unit:IsRealHero() and killed_unit:GetPlayerID() then
			GameMode:OnHeroDeath(killer, killed_unit)

			return
		end
	end
end

-- This block won't work anymore because I changed the "IMBA_ABILITIES_IGNORE_CDR" variable and changed the logic in modifier_frantic
function GameMode:OnAbilityUsed(keys)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityname = keys.abilityname

end

function GameMode:OnPlayerLevelUp(keys)
	if not keys.player then return end

	local player = EntIndexToHScript(keys.player)
	local hero = player:GetAssignedHero()
	if hero == nil then
		return
	end
	local level = keys.level
	local hero_attribute = hero:GetPrimaryAttribute()
	if hero_attribute == nil or hero:IsFakeHero() then
		return
	end

	hero:SetCustomDeathXP(HERO_XP_BOUNTY_PER_LEVEL[level])

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

function GameMode:OnPlayerLearnedAbility(keys)
	local player = EntIndexToHScript(keys.player)
	local hero = player:GetAssignedHero()
	local abilityname = keys.abilityname

end

--[[
function GameMode:PlayerConnect(keys)

end
--]]

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	local entIndex = keys.index + 1
	local ply = EntIndexToHScript(entIndex)
	local playerID = ply:GetPlayerID()

	ReconnectPlayer(playerID)
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
	local teamonly = keys.teamonly
	local userID = keys.userid
	--	local playerID = self.vUserIds[userID]:GetPlayerID()

	local text = keys.text

	local steamid = tostring(PlayerResource:GetSteamID(keys.playerid))

	-- This Handler is only for commands, ends the function if first character is not "-"
	if not (string.byte(text) == 45) then
		return nil
	end

	local caster = PlayerResource:GetPlayer(keys.playerid):GetAssignedHero()

	for str in string.gmatch(text, "%S+") do
		if IsInToolsMode() or GameRules:IsCheatMode() then
			if str == "-replaceherowith" then
				text = string.gsub(text, str, "")
				text = string.gsub(text, " ", "")
				if PlayerResource:GetSelectedHeroName(caster:GetPlayerID()) ~= "npc_dota_hero_" .. text then
					if caster.companion then
						caster.companion:ForceKill(false)
						caster.companion = nil
					end

					if IMBA_PICK_SCREEN == true then
						PrecacheUnitByNameAsync("npc_dota_hero_" .. text, function()
							HeroSelection:GiveStartingHero(caster:GetPlayerID(), "npc_dota_hero_" .. text, true)
						end)
					else
						local old_hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerID())
						PrecacheUnitByNameAsync("npc_dota_hero_" .. text, function()
							PlayerResource:ReplaceHeroWith(caster:GetPlayerID(), "npc_dota_hero_" .. text, 0, 0)

							Timers:CreateTimer(1.0, function()
								if old_hero then
									UTIL_Remove(old_hero)
								end
							end)
						end)
					end
				end
			end
		end
	end
end

-- TODO: FORMAT THIS GARBAGE
function GameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	if GameRules:IsGamePaused() then
		return 1
	end

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		-- Make courier controllable, repeat every second to avoid uncontrollable issues
		if COURIER_TEAM and IsValidEntity(COURIER_TEAM[hero:GetTeamNumber()]) then
			if COURIER_TEAM[hero:GetTeamNumber()] and not COURIER_TEAM[hero:GetTeamNumber()]:IsControllableByAnyPlayer() then
				COURIER_TEAM[hero:GetTeamNumber()]:SetControllableByPlayer(hero:GetPlayerID(), true)
			end
		end
	end

	return 1
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)

	-- Typical keys:
	-- herokills: 6
	-- killer_userid: 0
	-- splitscreenplayer: -1
	-- teamnumber: 2
	-- victim_userid: 7
	-- killer id will be -1 in case of a non-player owned killer (e.g. neutrals, towers, etc.)

	local killer_id = keys.killer_userid
	local victim_id = keys.victim_userid
	local killer_team = keys.teamnumber
	local nTeamKills = keys.herokills

end

-- A rune was activated by a player
function GameMode:OnRuneActivated(keys)
--	local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()

end
