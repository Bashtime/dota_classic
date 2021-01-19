if DISABLE_ALL_GOLD_FROM_HERO_KILLS == false then return end

GoldSystem = GoldSystem or class({})
GoldSystem.first_blood = false
GoldSystem.first_blood_bonus_gold = 150
GoldSystem.gold_multiplier = 100
GoldSystem.hero_kill_base_gold_bounty = 110
GoldSystem.max_hero_kill_streak = 15
GoldSystem.assist_gold_range = 1300

ListenToGameEvent('entity_killed', function(keys)
	local victim = EntIndexToHScript(keys.entindex_killed)
	if not victim then return end

	local killer = nil

	if keys.entindex_attacker then
		killer = EntIndexToHScript(keys.entindex_attacker)
	end

	if not killer or killer and not IsValidEntity(killer) then return end

	if killer:IsRealHero() and victim:IsRealHero() then
		GoldSystem:OnHeroDeath(killer, victim)
	end
end, nil)

function GoldSystem:OnHeroDeath(killer, victim)
	print("OnHeroDeath:", victim:IsReincarnating())
	if victim:IsReincarnating() then return end

--	local custom_gold_bonus = tonumber(CustomNetTables:GetTableValue("game_options", "bounty_multiplier")["1"])
	local custom_gold_bonus = GoldSystem.gold_multiplier
	local base_gold_bounty = GoldSystem.hero_kill_base_gold_bounty * (custom_gold_bonus / 100)
	local level_difference = victim:GetLevel() - killer:GetLevel()
	local level_bonus = custom_gold_bonus * math.max(level_difference, 0)
	if not victim.killstreak then victim.killstreak = 0 end
	local kill_streak_with_limit = math.min(victim.killstreak, GoldSystem.max_hero_kill_streak)
	local streak_bonus = custom_gold_bonus * math.sqrt(kill_streak_with_limit) * kill_streak_with_limit
	local kill_gold = math.floor(base_gold_bounty + level_bonus + streak_bonus)

	if not killer:IsRealHero() then
		if killer:GetMainControllingPlayer() ~= -1 then
			if PlayerResource.GetPlayer then
				if PlayerResource:GetPlayer(killer:GetMainControllingPlayer()) then
					if PlayerResource:GetPlayer(killer:GetMainControllingPlayer()):GetAssignedHero() then
						killer = PlayerResource:GetPlayer(killer:GetMainControllingPlayer()):GetAssignedHero()
					end
				end
			end
		end
	end

	if killer:IsRealHero() then
		if not killer.killstreak then killer.killstreak = 0 end
		killer.killstreak = killer.killstreak + 1

		if killer == victim then
--			CombatEvents("kill", "hero_suicide", victim)

			return
		elseif killer:IsRealHero() and killer:GetTeamNumber() == victim:GetTeamNumber() then
--			CombatEvents("kill", "hero_deny_hero", victim, killer)

			return
		end

		if GoldSystem.first_blood == false then
			GoldSystem.first_blood = true
			kill_gold = kill_gold + GoldSystem.first_blood_bonus_gold
		end

		local victim_team_networth = 0

		for _, hero in pairs(HeroList:GetAllHeroes()) do
			if hero:GetTeamNumber() == victim:GetTeamNumber() then
				victim_team_networth = victim_team_networth + hero:GetNetworth()
			end
		end

		local average_victim_team_networth = victim_team_networth / PlayerResource:GetPlayerCountForTeam(victim:GetTeamNumber())
		local assisters = FindUnitsInRadius(killer:GetTeamNumber(), victim:GetAbsOrigin(), nil, GoldSystem.assist_gold_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)

		local aoe_gold_for_player = 0
		for _, assister in pairs(assisters) do
			local base_aoe_gold = 1000 / #assisters
			local networth_bonus = math.max(average_victim_team_networth - assister:GetNetworth(), 0) * 0.05
			aoe_gold_for_player = math.floor(base_aoe_gold + networth_bonus)

			print(base_aoe_gold)
			print(networth_bonus)
			print(aoe_gold_for_player)

			if assister:IsAlive() and assister:IsRealHero() then
				if assister == killer then
					SendOverheadEventMessage(killer:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, victim, kill_gold + aoe_gold_for_player, nil)
					killer:ModifyGold(kill_gold + aoe_gold_for_player, true, DOTA_ModifyGold_HeroKill)
				else
					SendOverheadEventMessage(assister:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, victim, aoe_gold_for_player, nil)
					assister:ModifyGold(aoe_gold_for_player, true, DOTA_ModifyGold_HeroKill)
				end
			end
		end

		print(base_gold_bounty)
		print(level_bonus)
		print(streak_bonus)
		print(kill_gold)
		print(aoe_gold_for_player)

--		CombatEvents("kill", "hero_kill", victim, killer, kill_gold + aoe_gold_for_player)
	else
		if killer:GetTeamNumber() == 4 then
--			CombatEvents("kill", "neutrals_kill_hero", victim)

			return
		end

		local victim_attacker_count = victim:GetNumAttackers()

--		print("Attackers: "..victim_attacker_count)
		if victim_attacker_count == 0 then
			-- If there's no attackers and the hero didn't suicided or denied himself, grant gold to the enemy team
			for _, hero in pairs(HeroList:GetAllHeroes()) do
				if not hero == victim and not hero:IsFakeHero() then
--					print(kill_gold / PlayerResource:GetPlayerCountForTeam(hero:GetTeamNumber()), kill_gold)
					SendOverheadEventMessage(hero:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, victim, kill_gold / PlayerResource:GetPlayerCountForTeam(hero:GetTeamNumber()), nil)
					hero:ModifyGold(kill_gold / PlayerResource:GetPlayerCountForTeam(hero:GetTeamNumber()), true, DOTA_ModifyGold_HeroKill)
				end
			end
		else
			-- if there are assisters but no killer (e.g: dead by tower) then grant gold to assisters
			for _, attacker in pairs(HeroList:GetAllHeroes()) do
				for i = 0, victim_attacker_count -1 do
					if attacker:GetPlayerID() == victim:GetAttacker(i) and not attacker:IsFakeHero() then
--						print("Attacker:", attacker:GetUnitName())
--						print("Gold:", kill_gold / victim_attacker_count, kill_gold)
						SendOverheadEventMessage(attacker:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, victim, kill_gold / victim_attacker_count, nil)
						attacker:ModifyGold(kill_gold / victim_attacker_count, true, DOTA_ModifyGold_HeroKill)
					end
				end
			end
		end
	end

	victim.killstreak = 0
end
