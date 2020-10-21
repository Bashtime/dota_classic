ListenToGameEvent('game_rules_state_change', function(keys)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		for i = 1, #BOUNTY_RUNE_POSITIONS do
			local pos = BOUNTY_RUNE_POSITIONS[i]

			local bounty_rune_spawner = Entities:CreateByClassname("dota_item_rune_spawner_bounty")
			bounty_rune_spawner:SetOrigin(GetGroundPosition(pos, bounty_rune_spawner))
			bounty_rune_spawner:SetModel("models/props_gameplay/rune_point001.vmdl")
		end
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- May or may not be laggy at some point, worth a check
		Timers:CreateTimer(function()
			--check if there are runes to remove
			local rune_count = 0

			for _, rune_location in pairs(Entities:FindAllByName("dota_item_rune_spawner")) do
				for _, ent in pairs(Entities:FindAllInSphere(rune_location:GetAbsOrigin(), 100)) do
					if ent:GetClassname() == "dota_item_rune" then
						rune_count = rune_count + 1

						if rune_count > 1 then
							UTIL_Remove(ent)
						end
					end
				end
			end

			if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
				return nil
			else
				return FrameTime()
			end
		end)

		Timers:CreateTimer(function()
			for i = 1, #BOUNTY_RUNE_POSITIONS do
				local pos = BOUNTY_RUNE_POSITIONS[i]

				for i = 1, 2 do
					AddFOWViewer(i, pos, 30.0, FrameTime(), true)
				end
			end

			return BOUNTY_RUNE_SPAWN_TIME
		end)
	end
end, nil)
