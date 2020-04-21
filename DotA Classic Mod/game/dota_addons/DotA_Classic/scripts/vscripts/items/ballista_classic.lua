item_ballista_classic = class({})

LinkLuaModifier("modifier_ballista_classic_passive","items/ballista_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned","items/ballista_classic", LUA_MODIFIER_MOTION_NONE)

function item_ballista_classic:GetIntrinsicModifierName()
	return "modifier_ballista_classic_passive"
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Ballista Passive Bonuses Modifier
modifier_ballista_classic_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ballista_classic_passive:IsHidden()
	return true
end

function modifier_ballista_classic_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ballista_classic_passive:OnCreated( kv )

	-- references
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "base_attack_range" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value	
	self.stun_chance = self:GetAbility():GetSpecialValueFor( "stun_chance" ) -- special value
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" ) -- special value
	self.stun_damage = self:GetAbility():GetSpecialValueFor( "stun_damage" ) -- special value
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as_passive" ) -- special value
	self.speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" ) -- special value

	local caster = self:GetParent() 
	if (IsServer() and caster:IsRangedAttacker()) then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_ballista", { duration = -1}) end 
	
end

function modifier_ballista_classic_passive:OnRefresh( kv )

	-- references
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "base_attack_range" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value	
	self.stun_chance = self:GetAbility():GetSpecialValueFor( "stun_chance" ) -- special value
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" ) -- special value
	self.stun_damage = self:GetAbility():GetSpecialValueFor( "stun_damage" ) -- special value
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as_passive" ) -- special value
	self.speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" ) -- special value

	local caster = self:GetParent() 
	if (IsServer() and caster:IsRangedAttacker()) then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_ballista", { duration = -1}) end 

end

function modifier_ballista_classic_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ballista_classic_passive:OnDestroy( kv )
	local caster = self:GetParent()
	if IsServer() then caster:RemoveModifierByName("modifier_item_ballista") end
end

function modifier_ballista_classic_passive:OnRemoved()
	local caster = self:GetParent()
	if IsServer() then caster:RemoveModifierByName("modifier_item_ballista") end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ballista_classic_passive:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,

		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,

		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,

	}

	return funcs
end


function modifier_ballista_classic_passive:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_ballista_classic_passive:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_ballista_classic_passive:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_ballista_classic_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_ballista_classic_passive:GetModifierAttackRangeBonusUnique()
	local attacker = self:GetParent()
	if attacker:IsRangedAttacker() then return self.bonus_range end
	return 0
end

function modifier_ballista_classic_passive:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_ballista_classic_passive:GetModifierProjectileSpeedBonus()
	return self:GetAbility():GetSpecialValueFor( "projectile_speed" )
end


function modifier_ballista_classic_passive:GetModifierProcAttack_BonusDamage_Pure( params )

		local attacker = self:GetParent()
		local target = params.target
		local stun_success = RandomInt(1, 100)

		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then
			if (stun_success <= self.stun_chance and ( not attacker:IsIllusion() )) then
				
				if attacker:IsRangedAttacker() then
					target:AddNewModifier(attacker, self:GetAbility(), "modifier_generic_stunned", { duration = self.stun_duration})

					-- effects
					local sound_cast = "Hero_Sniper.AssassinateDamage"
					EmitSoundOn( sound_cast, target )
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, self.stun_damage, nil)

					return self.stun_damage
				end
			end
		end

	return 0
end






----------------------------
----------------------------
--Stun effect modifier

modifier_generic_stunned = class({})

--------------------------------------------------------------------------------

function modifier_generic_stunned:IsDebuff()
	return true
end

function modifier_generic_stunned:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_generic_stunned:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_generic_stunned:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_generic_stunned:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function modifier_generic_stunned:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_generic_stunned:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------

