-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:_InitGameMode()
	if GameMode._reentrantCheck then
		return
	end

	-- Setup rules
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )

	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetHeroSelectPenaltyTime( SELECT_PENALTY_TIME )
	GameRules:SetPreGameTime( PRE_GAME_TIME)
	GameRules:SetPostGameTime( POST_GAME_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:GetGameModeEntity():SetBountyRuneSpawnInterval(BOUNTY_RUNE_SPAWN_TIME)
	GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
	GameRules:SetStrategyTime(0.0)
	GameRules:SetShowcaseTime(0.0)
	GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride( "item_courier" )

	GameRules:SetUseCustomHeroXPValues( USE_CUSTOM_XP_VALUES )
	GameRules:SetGoldPerTick(GOLD_PER_TICK)
	GameRules:SetGoldTickTime(GOLD_TICK_TIME)
	GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )

	GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
	GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )

	GameRules:SetCustomGameEndDelay( GAME_END_DELAY )
	GameRules:SetCustomVictoryMessageDuration( VICTORY_MESSAGE_DURATION )
	GameRules:SetStartingGold( STARTING_GOLD )

	if SKIP_TEAM_SETUP then
		GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
		GameRules:LockCustomGameSetupTeamAssignment( true )
		GameRules:EnableCustomGameSetupAutoLaunch( true )
	else
		GameRules:SetCustomGameSetupAutoLaunchDelay( AUTO_LAUNCH_DELAY )
		GameRules:LockCustomGameSetupTeamAssignment( LOCK_TEAM_SETUP )
		GameRules:EnableCustomGameSetupAutoLaunch( ENABLE_AUTO_LAUNCH )
	end


	-- This is multiteam configuration stuff
	if USE_AUTOMATIC_PLAYERS_PER_TEAM then
		local num = math.floor(10 / MAX_NUMBER_OF_TEAMS)
		local count = 0
		for team,number in pairs(TEAM_COLORS) do
			if count >= MAX_NUMBER_OF_TEAMS then
				GameRules:SetCustomGameTeamMaxPlayers(team, 0)
			else
				GameRules:SetCustomGameTeamMaxPlayers(team, num)
			end
			count = count + 1
		end
	else
		local count = 0
		for team,number in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
			if count >= MAX_NUMBER_OF_TEAMS then
				GameRules:SetCustomGameTeamMaxPlayers(team, 0)
			else
				GameRules:SetCustomGameTeamMaxPlayers(team, number)
			end
			count = count + 1
		end
	end

	if USE_CUSTOM_TEAM_COLORS then
		for team,color in pairs(TEAM_COLORS) do
			SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
		end
	end
	DebugPrint('[BAREBONES] GameRules set')

	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(b_USE_MULTIPLE_COURIERS)

	--InitLogFile( "log/barebones.txt","")

	-- Event Hooks
	-- All of these events can potentially be fired by the game, though only the uncommented ones have had
	-- Functions supplied for them.  If you are interested in the other events, you can uncomment the
	-- ListenToGameEvent line and add a function to handle the event
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(GameMode, 'OnPlayerLevelUp'), self)
	ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(GameMode, 'OnAbilityChannelFinished'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(GameMode, 'OnPlayerLearnedAbility'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, '_OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, '_OnConnectFull'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(GameMode, 'OnDisconnect'), self)
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(GameMode, 'OnItemPurchased'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GameMode, 'OnItemPickedUp'), self)
	ListenToGameEvent('last_hit', Dynamic_Wrap(GameMode, 'OnLastHit'), self)
	ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(GameMode, 'OnNonPlayerUsedAbility'), self)
	ListenToGameEvent('player_changename', Dynamic_Wrap(GameMode, 'OnPlayerChangedName'), self)
	ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(GameMode, 'OnRuneActivated'), self)
	ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(GameMode, 'OnPlayerTakeTowerDamage'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(GameMode, 'OnTreeCut'), self)
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(GameMode, 'OnEntityHurt'), self)
	ListenToGameEvent('player_connect', Dynamic_Wrap(GameMode, 'PlayerConnect'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameMode, 'OnAbilityUsed'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, '_OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, '_OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPlayerPickHero'), self)
	ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(GameMode, 'OnTeamKillCredit'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'OnPlayerReconnect'), self)

	ListenToGameEvent("dota_illusions_created", Dynamic_Wrap(GameMode, 'OnIllusionsCreated'), self)
	ListenToGameEvent("dota_item_combined", Dynamic_Wrap(GameMode, 'OnItemCombined'), self)
	ListenToGameEvent("dota_player_begin_cast", Dynamic_Wrap(GameMode, 'OnAbilityCastBegins'), self)
	ListenToGameEvent("dota_tower_kill", Dynamic_Wrap(GameMode, 'OnTowerKill'), self)
	ListenToGameEvent("dota_player_selected_custom_team", Dynamic_Wrap(GameMode, 'OnPlayerSelectedCustomTeam'), self)
	ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap(GameMode, 'OnNPCGoalReached'), self)

	ListenToGameEvent("player_chat", Dynamic_Wrap(GameMode, 'OnPlayerChat'), self)
	
	--ListenToGameEvent("dota_tutorial_shop_toggled", Dynamic_Wrap(GameMode, 'OnShopToggled'), self)

	--ListenToGameEvent('player_spawn', Dynamic_Wrap(GameMode, 'OnPlayerSpawn'), self)
	--ListenToGameEvent('dota_unit_event', Dynamic_Wrap(GameMode, 'OnDotaUnitEvent'), self)
	--ListenToGameEvent('nommed_tree', Dynamic_Wrap(GameMode, 'OnPlayerAteTree'), self)
	--ListenToGameEvent('player_completed_game', Dynamic_Wrap(GameMode, 'OnPlayerCompletedGame'), self)
	--ListenToGameEvent('dota_match_done', Dynamic_Wrap(GameMode, 'OnDotaMatchDone'), self)
	--ListenToGameEvent('dota_combatlog', Dynamic_Wrap(GameMode, 'OnCombatLogEvent'), self)
	--ListenToGameEvent('dota_player_killed', Dynamic_Wrap(GameMode, 'OnPlayerKilled'), self)
	--ListenToGameEvent('player_team', Dynamic_Wrap(GameMode, 'OnPlayerTeam'), self)

	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(
    function(ctx, event)
      local item = EntIndexToHScript(event.item_entindex_const)
      local unitPickUpIndex = event.inventory_parent_entindex_const
      local unit = EntIndexToHScript(unitPickUpIndex)

      --remove ordinary TPs and replace 'em
      if item:GetAbilityName() == "item_tpscroll" and unit ~= nil then
        --[[local pos = unit:GetAbsOrigin()
        local drop = CreateItemOnPositionSync( pos, item )
        local pos_launch = pos+RandomVector(RandomFloat(40,70))
        item:LaunchLoot(false, 250, 0.75, pos_launch) ]]
        unit:RemoveItem(item)
        local new_item = CreateItem("item_tp", unit, unit)
        unit:AddItem(new_item)
        if unit.bFirstTP == nil then
          new_item:EndCooldown()
          unit.bFirstTP = false
        end
        return true
      end

      local tier_1_item_names = {
        "item_keen_optic_classic", 
        "item_nether_shawl_classic", 
        "item_grove_bow_classic", 
        "item_broom_handle_classic", 
        "item_faded_broach_classic",
      }

      for i=1, #tier_1_item_names do
        if item:GetName() == tier_1_item_names[i] and item:GetPurchaser() ~= unit then
          if unit:GetUnitName() ~= "npc_dota_courier" then
            local new_item = CreateItem(tier_1_item_names[i], unit, unit)
            unit:RemoveItem(item)
            unit:AddItem(new_item)
            new_item:StartCooldown(0.02) --Prevent Full Gold abuse
            return false
          end
        end
      end
      

      --[[this event is broken in dota, so calling it from here instead
      if item.OnItemEquipped ~= nil then
        item:OnItemEquipped(item)
      end]]

      return true
    end, self)

	--[[This block is only used for testing events handling in the event that Valve adds more in the future
	Convars:RegisterCommand('events_test', function()
			GameMode:StartEventTest()
		end, "events test", 0)]]

	local spew = 0
	if BAREBONES_DEBUG_SPEW then
		spew = 1
	end
	Convars:RegisterConvar('barebones_spew', tostring(spew), 'Set to 1 to start spewing barebones debug info.  Set to 0 to disable.', 0)

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '^0+','')
	math.randomseed(tonumber(timeTxt))

	-- Initialized tables for tracking state
	self.bSeenWaitForPlayers = false
	self.vUserIds = {}

	DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
	GameMode._reentrantCheck = true
	GameMode:InitGameMode()
	GameMode._reentrantCheck = false
end

mode = nil

-- This function is called as the first player loads and sets up the GameMode parameters
function GameMode:_CaptureGameMode()
	if mode == nil then
		-- Set GameMode parameters
		mode = GameRules:GetGameModeEntity()        
		mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
		mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
		mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
		mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
		mode:SetBuybackEnabled( BUYBACK_ENABLED )
		mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
		mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
		mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
		mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

		mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
		mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

		mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
		mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
		mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )

		mode:SetAlwaysShowPlayerInventory( SHOW_ONLY_PLAYER_INVENTORY )
		mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
		if FORCE_PICKED_HERO ~= nil then
			mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
		end
		mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
		mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
		mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
		mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
		mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
		mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED )
		mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
		mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )

		for rune, spawn in pairs(ENABLED_RUNES) do
			mode:SetRuneEnabled(rune, spawn)
		end

		mode:SetUnseenFogOfWarEnabled( USE_UNSEEN_FOG_OF_WAR )

		mode:SetDaynightCycleDisabled( DISABLE_DAY_NIGHT_CYCLE )
		mode:SetKillingSpreeAnnouncerDisabled( DISABLE_KILLING_SPREE_ANNOUNCER )
		mode:SetStickyItemDisabled( DISABLE_STICKY_ITEM )

		self:OnFirstPlayerLoaded()
	end

	-- Apply a modifier that makes units obey our armour formula
	LinkLuaModifier("modifier_common_custom_armor", "components/modifiers/common_custom_armor.lua", LUA_MODIFIER_MOTION_NONE)

	-- Apply a modifier that makes STR HP REGEN obey our will. Current Valve Constant does nothing. Fuck that cancer
	LinkLuaModifier("modifier_nerf_cancer_regen", "components/modifiers/nerf_cancer_regen.lua", LUA_MODIFIER_MOTION_NONE)

	-- Apply a modifier that allows us to keep track of the Talent lvl
	LinkLuaModifier("modifier_talent_lvl", "components/modifiers/talent_lvl.lua", LUA_MODIFIER_MOTION_NONE) 

	-- Apply a modifier that allows us to give Spell Amp and calculate mana regen
	LinkLuaModifier("modifier_spell_amp_int", "components/modifiers/spell_amp_int", LUA_MODIFIER_MOTION_NONE) 

	-- Apply a modifier that allows us to give BKB decreasing Magic Resistance
	LinkLuaModifier("modifier_bkb_mr", "components/modifiers/bkb_mr", LUA_MODIFIER_MOTION_NONE) 

	-- Apply a modifier that gives Bonus stats when agha is consumed
	LinkLuaModifier("modifier_agha_bonus_stats", "components/modifiers/agha_bonus_stats", LUA_MODIFIER_MOTION_NONE) 

	--Account for Bonuses that are not in Vanilla HotD
	LinkLuaModifier("modifier_hotd_custom_bonus", "components/modifiers/hotd_custom_bonus", LUA_MODIFIER_MOTION_NONE)

	--Cosmetic Effects when equipping Aura items
	LinkLuaModifier("modifier_aura_cosmetics", "components/modifiers/aura_cosmetics", LUA_MODIFIER_MOTION_NONE)
end
