item_qb = class({})
LinkLuaModifier( "modifier_qb_passive", "items/qb_classic", LUA_MODIFIER_MOTION_NONE )

function item_qb:GetIntrinsicModifierName()
	return "modifier_qb_passive"
end

------------------------------------------------------------------------------
--- Custom Filter

function item_qb:CastFilterResultTarget( hTarget )

	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local name = hTarget:GetUnitName()

	if ( (name == "npc_dota_observer_wards") or (name == "npc_dota_sentry_wards") ) then
		local casterteam = self:GetCaster():GetTeamNumber()
		local wardteam = hTarget:GetTeamNumber()

		if casterteam == wardteam then return UF_FAIL_CUSTOM end
		return UF_SUCCESS
	end

	if ( (name == "npc_dota_techies_stasis_trap") or (name == "npc_dota_techies_remote_mine") ) then
		local casterteam = self:GetCaster():GetTeamNumber()
		local wardteam = hTarget:GetTeamNumber()

		if casterteam == wardteam then return UF_FAIL_CUSTOM end
		return UF_SUCCESS
	end

	return UF_FAIL_CUSTOM
end

--------------------------------------------------------------------------------

function item_qb:GetCustomCastErrorTarget( hTarget )

	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "#dota_hud_error_qb"
end


--------------------------------------------------------------------------------
-- Ability Start
function item_qb:OnSpellStart()
	
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.isTree = target:IsInstance(CDOTA_MapTree) --Checks if the target is a tree
		

	-- load data
	local treekill_cd = self:GetSpecialValueFor("alternative_cooldown")
	local pct = self:GetSpecialValueFor("creep_damage_pct")
	local anc_pct = self:GetSpecialValueFor("anc_pct")
	
	if (not self.isTree) then

		--Kill obs
		local name = target:GetUnitName()  

		if ( (name == "npc_dota_observer_wards") or (name == "npc_dota_sentry_wards") ) then 
			target:Kill(self, caster)

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end


		--Fuck Techies
		local name = target:GetUnitName()  

		if ( (name == "npc_dota_techies_stasis_trap") or (name == "npc_dota_techies_remote_mine") ) then 
			target:Kill(self, caster)

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end

	end

	-- CutDown trees
	if self.isTree then
		if target:IsStanding() then 
			local teamnumber = target:GetTeamNumber()
			target:CutDownRegrowAfter(TREE_REGROW_TIME, teamnumber)

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end
	end

	return
end



--------------------------------------------------------------
--------------------------------------------------------------
-- QB quell passive

modifier_qb_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_qb_passive:IsHidden()
	return true
end

function modifier_qb_passive:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_qb_passive:OnCreated( kv )

	-- references
	self.dmg = self:GetAbility():GetSpecialValueFor( "damage_bonus" ) -- special value
	self.dmg_range = self:GetAbility():GetSpecialValueFor( "damage_bonus_ranged" ) -- special value

end

function modifier_qb_passive:OnRefresh( kv )

	-- references
	self.dmg = self:GetAbility():GetSpecialValueFor( "damage_bonus" ) -- special value
	self.dmg_range = self:GetAbility():GetSpecialValueFor( "damage_bonus_ranged" ) -- special value

end

function modifier_qb_passive:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_qb_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_qb_passive:GetModifierProcAttack_BonusDamage_Physical( params )

	if IsServer() then
		
		local attacker = self:GetParent()

		local target = params.target
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then

			if attacker:IsIllusion() then
				return 0 
			end

			if attacker:IsRangedAttacker() then
				return self.dmg_range			
			end

			return self.dmg
		end

		return 0
	end
end
