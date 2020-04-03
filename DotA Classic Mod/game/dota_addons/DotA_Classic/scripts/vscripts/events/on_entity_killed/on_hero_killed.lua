function GameMode:OnHeroDeath(killer, victim)
	-- Buyback parameters
	local player_id = victim:GetPlayerID()
	local hero_level = victim:GetLevel()
	local game_time = GameRules:GetDOTATime(false, true)

	local hero = victim
	if victim:IsClone() then
		hero = victim:GetCloneSource()
	end

	-- Killed Unit is a hero (not an illusion) and he is not reincarnating
	if not victim:IsReincarnating() then
		--Calculate Gold Lost on Death
		local playerID = victim:GetPlayerID()
		local herolvl = victim:GetLevel()
		local deathcost = CUSTOM_DEATH_GOLD_COST[herolvl]

		--Modify Gold after Death
		victim:ModifyGold(-deathcost, false, DOTA_ModifyGold_Death)

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
			local victim_level = victim:GetLevel()

			-- Respawn time without buyback penalty (+25 sec)
			local respawn_time = 1
			if USE_CUSTOM_RESPAWN_TIMES then
				-- Get respawn time from the table that we defined
				respawn_time = CUSTOM_RESPAWN_TIME[victim_level]
			else
				-- Get dota default respawn time
				respawn_time = victim:GetRespawnTime()
			end

			-- Bloodstone reduction (bloodstone can't be in backpack)
			-- for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
				-- local item = victim:GetItemInSlot(i)
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
				--DebugPrint("Reducing respawn time of "..victim:GetUnitName().." because it was too long.")
				respawn_time = MAX_RESPAWN_TIME
			end

			if not victim:IsReincarnating() then
				victim:SetTimeUntilRespawn(respawn_time)
			end
		end

		--Buyback Cooldown
		if CUSTOM_BUYBACK_COOLDOWN_ENABLED then
			PlayerResource:SetCustomBuybackCooldown(victim:GetPlayerID(), CUSTOM_BUYBACK_COOLDOWN_TIME)
		end 

		-- Buyback old formula
		if CUSTOM_BUYBACK_COST_ENABLED then
			local victimlvl = victim:GetLevel()
			local time = GameRules:GetGameTime()
			local bbcost = 150 + (time - PRE_GAME_TIME) * 0.25 + victimlvl * victimlvl * 1.5
			PlayerResource:SetCustomBuybackCost(victim:GetPlayerID(), bbcost)
		end

		-- Killer is not a real hero but it killed a hero
		if killer_unit:IsTower() or killer_unit:IsCreep() then
			-- Put stuff here that you want to happen if a hero is killed by a creep, tower or fountain.
			local victimlvl = victim:GetLevel()
			local time = GameRules:GetGameTime()
			local bbcost = 150 + (time - PRE_GAME_TIME) * 0.25 + victimlvl * victimlvl * 1.5
			PlayerResource:SetCustomBuybackCost(victim:GetPlayerID(), bbcost)
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
end
