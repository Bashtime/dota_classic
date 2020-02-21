--Credits go to Darkonius

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