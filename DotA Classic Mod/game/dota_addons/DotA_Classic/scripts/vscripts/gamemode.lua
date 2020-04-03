if GameMode == nil then
	_G.GameMode = class({})
end

-- clientside KV loading
require('addon_init')

if IsInToolsMode() then -- might lag a bit and backend to get errors not working yet
	require('internal/eventtest')
end

require('libraries/adv_log') -- be careful! this library can hide lua errors in rare cases

require('settings')
require('libraries/keyvalues')
require('libraries/notifications')
require('libraries/player')
require('libraries/player_resource')
require('libraries/timers')

require('internal/gamemode')
require('internal/events')

require('components/courier/init')

require('events/events')
require('filters')

-- Use this function as much as possible over the regular Precache (this is Async Precache)
function GameMode:PostLoadPrecache()
	
end

function GameMode:OnFirstPlayerLoaded()
	
end

function GameMode:OnAllPlayersLoaded()
	-- Setup filters
	GameRules:GetGameModeEntity():SetHealingFilter( Dynamic_Wrap(GameMode, "HealingFilter"), self )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, "DamageFilter"), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "GoldFilter"), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, "ExperienceFilter"), self)
	GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode, "ModifierFilter"), self)
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(GameMode, "ItemAddedFilter"), self)
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(GameMode, "BountyRuneFilter"), self)
	GameRules:GetGameModeEntity():SetThink("OnThink", self, 1)
	GameRules:GetGameModeEntity():SetPauseEnabled(not IMBA_PICK_SCREEN)
	
	GameRules:GetGameModeEntity():SetRuneSpawnFilter(Dynamic_Wrap(GameMode, "RuneSpawnFilter"), self)

	if IsInToolsMode() then
		Convars:RegisterCommand('events_test', function() GameMode:StartEventTest() end, "events test", FCVAR_CHEAT)
	end
end

-- CAREFUL, FOR REASONS THIS FUNCTION IS ALWAYS CALLED TWICE
function GameMode:InitGameMode()
	self:_InitGameMode()
end

-- Set up fountain regen
function GameMode:SetupFountains()
--[[

	local fountainEntities = Entities:FindAllByClassname("ent_dota_fountain")
	for _, fountainEnt in pairs(fountainEntities) do
		fountainEnt:AddNewModifier(fountainEnt, fountainEnt, "modifier_fountain_aura_lua", {})
		fountainEnt:AddAbility("imba_fountain_danger_zone"):SetLevel(1)

		-- remove vanilla fountain healing
		if fountainEnt:HasModifier("modifier_fountain_aura") then
			fountainEnt:RemoveModifierByName("modifier_fountain_aura")
			fountainEnt:AddNewModifier(fountainEnt, nil, "modifier_fountain_aura_lua", {})
		end
	end
--]]
end
