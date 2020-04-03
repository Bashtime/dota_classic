local PlayerResource = CDOTA_PlayerResource
PlayerResource.PlayerData = {}

-- Initializes a player's data
ListenToGameEvent('npc_spawned', function(event)
	local npc = EntIndexToHScript(event.entindex)

	if npc.GetPlayerID and npc:GetPlayerID() >= 0 and not PlayerResource.PlayerData[npc:GetPlayerID()] then
		PlayerResource.PlayerData[npc:GetPlayerID()] = {}
		PlayerResource.PlayerData[npc:GetPlayerID()]["has_abandoned_due_to_long_disconnect"] = false
--		PlayerResource.PlayerData[npc:GetPlayerID()]["distribute_gold_to_allies"] = false -- not used atm
--		PlayerResource.PlayerData[npc:GetPlayerID()]["has_repicked"] = false -- not used atm
--		print("player data set up for player with ID "..npc:GetPlayerID())
	end
end, nil)

function PlayerResource:IsImbaPlayer(player_id)
	if self.PlayerData[player_id] then
		return true
	else
		return false
	end
end

-- Set a player's abandonment due to long disconnect status
function PlayerResource:SetHasAbandonedDueToLongDisconnect(player_id, state)
	if self:IsImbaPlayer(player_id) then
		self.PlayerData[player_id]["has_abandoned_due_to_long_disconnect"] = state
--		print("Set player "..player_id.." 's abandon due to long disconnect state as "..tostring(state))
	end
end

-- Fetch a player's abandonment due to long disconnect status
function PlayerResource:GetHasAbandonedDueToLongDisconnect(player_id)
	if self:IsImbaPlayer(player_id) then
		return self.PlayerData[player_id]["has_abandoned_due_to_long_disconnect"]
	else
		return false
	end
end
