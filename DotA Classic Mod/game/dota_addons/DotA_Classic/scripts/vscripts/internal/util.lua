function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
			local value = t[v]

			if type(value) == "table" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..":")
				PrintTable (value, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
				else
					print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				end
			end
		end
	end
end

function MergeTables( t1, t2 )
	for name,info in pairs(t2) do
		t1[name] = info
	end
end

-- Copy shallow copy given input
function ShallowCopy(orig)
	local copy = {}
	for orig_key, orig_value in pairs(orig) do
		copy[orig_key] = orig_value
	end
	return copy
end

-- TODO: Maybe this is laggy, format it later
function InitItemIds()
	GameMode.itemIDs = {}
	for k,v in pairs(KeyValues.ItemKV) do
		if type(v) == "table" and v.ID then
			GameMode.itemIDs[v.ID] = k
		end
	end
end

-- Yahnich's calculate distance and direction functions
function CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end

function GetReductionFromArmor(armor)
	return ( 0.052 * armor ) / ( 0.9 + 0.048 * armor)
end

function CalculateReductionFromArmor_Percentage(armorOffset, armor)
	return -GetReductionFromArmor(armor) + GetReductionFromArmor(armorOffset)
end

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	return direction
end

function DisplayError(playerID, message)
	local player = PlayerResource:GetPlayer(playerID)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message=message})
	end
end

-- TODO: FORMAT THIS SHIT
function ReconnectPlayer(player_id)
	if not player_id then player_id = 0 end
	if player_id == "test_reconnect" then player_id = 0 end

--	print("Player is reconnecting:", player_id)

	-- Reinitialize the player's pick screen panorama, if necessary
	Timers:CreateTimer(function()
--		print(PlayerResource:GetSelectedHeroEntity(player_id))

		if PlayerResource:GetSelectedHeroEntity(player_id) then
			if IMBA_PICK_SCREEN == true then
				CustomGameEventManager:Send_ServerToAllClients("player_reconnected", {PlayerID = player_id, PickedHeroes = HeroSelection.picked_heroes, pickState = pick_state, repickState = repick_state})
			end

			local hero = PlayerResource:GetSelectedHeroEntity(player_id)

			if IMBA_PICK_SCREEN == true then
				if PICKING_SCREEN_OVER == true then
					if hero:GetUnitName() == FORCE_PICKED_HERO then
						print('Giving player ' .. player_id .. ' a random hero! (reconnected)')
						local random_hero = HeroSelection:RandomHero()
						print("Random Hero:", random_hero)
						HeroSelection:GiveStartingHero(player_id, random_hero, true)
					end
				end
			end
		else
--			print("Not fully reconnected yet:", player_id)
			return 0.1
		end
	end)

	-- If this is a reconnect from abandonment due to a long disconnect, remove the abandon state
	if PlayerResource:GetHasAbandonedDueToLongDisconnect(player_id) then
		local player_name = PlayerResource:GetPlayerName(player_id)
		local hero = PlayerResource:GetPlayer(player_id):GetAssignedHero()
		local hero_name = hero:GetUnitName()
		local line_duration = 7
		Notifications:BottomToAll({hero = hero_name, duration = line_duration})
		Notifications:BottomToAll({text = player_name.." ", duration = line_duration, continue = true})
		Notifications:BottomToAll({text = "#imba_player_reconnect_message", duration = line_duration, style = {color = "DodgerBlue"}, continue = true})

		-- Stop redistributing gold to allies, if applicable (Valve handle this now)
--		PlayerResource:StopAbandonGoldRedistribution(player_id)
	end
end

-- Turns a table of entity handles into entindex string separated by commas.
function TableToStringCommaEnt(table)	
	local string = ""
	local first_value = true

	for _,handle in pairs(table) do
		if first_value then
			string = string..tostring(handle:entindex())	
			first_value = false
		else
			string = string..","
			string = string..tostring(handle:entindex())	
		end		
	end

	return string
end

-- Turns an entindex string into a table and returns a table of handles.
-- Separator can only be a space (" ") or a comma (",").
function StringToTableEnt(string, separator)
	local gmatch_sign

	if separator == " " then
		gmatch_sign = "%S+"
	elseif separator == "," then
		gmatch_sign = "([^,]+)"
	end

	local return_table = {}
	for str in string.gmatch(string, gmatch_sign) do 		
		local handle = EntIndexToHScript(tonumber(str))
		table.insert(return_table, handle)
	end	

	return return_table
end

function StoreCurrentDayCycle()	
	Timers:CreateTimer(function()		
		-- Get current daytime cycle
		local is_day = GameRules:IsDaytime()		

		-- Set in the table
		CustomNetTables:SetTableValue("game_options", "isdaytime", {is_day = is_day} )

		-- Repeat
		return 0.5
	end)	
end

function IsDaytime()
	if CustomNetTables:GetTableValue("game_options", "isdaytime") then
		if CustomNetTables:GetTableValue("game_options", "isdaytime").is_day then  
			local is_day = CustomNetTables:GetTableValue("game_options", "isdaytime").is_day  

			if is_day == 1 then
				return true
			else
				return false
			end
		end
	end

	return true   
end
