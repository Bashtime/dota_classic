item_kns_classic = class({})

LinkLuaModifier("modifier_kns_classic","items/kns_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kns_maim","items/kns_classic", LUA_MODIFIER_MOTION_NONE)

function item_kns_classic:GetIntrinsicModifierName()
	return "modifier_kns_classic"
end




-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Kaya and Sange Passive Bonuses Modifier

modifier_kns_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_kns_classic:IsHidden()
	return true
end

function modifier_kns_classic:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_kns_classic:OnCreated( kv )

	-- references
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value
	self.bonus_strength = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.maim_chance = self:GetAbility():GetSpecialValueFor( "maim_chance" ) -- special value
	self.maim_duration = self:GetAbility():GetSpecialValueFor( "maim_duration" ) -- special value

	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" ) -- special value

end

function modifier_kns_classic:OnRefresh( kv )

	-- references
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) -- special value
	self.maim_chance = self:GetAbility():GetSpecialValueFor( "maim_chance" ) -- special value
	self.maim_duration = self:GetAbility():GetSpecialValueFor( "maim_duration" ) -- special value

	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" ) -- special value

end

function modifier_kns_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_kns_classic:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_kns_classic:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,

		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,		
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}

	return funcs
end


function modifier_kns_classic:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_kns_classic:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end

function modifier_kns_classic:GetModifierProcAttack_BonusDamage_Physical( params )

		local attacker = self:GetParent()
		local target = params.target
		local maim_success = RandomInt(1, 100)

		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then
			if (maim_success <= self.maim_chance and ( not attacker:IsIllusion() )) then
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_kns_maim", { duration = self.maim_duration})

				-- effects
				local sound_cast = "DOTA_Item.Maim"
				EmitSoundOn( sound_cast, target )
			end
		end

	return 0
end



function modifier_kns_classic:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_kns_classic:GetModifierPercentageManacost()
	return self.manacost_reduction
end

function modifier_kns_classic:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_kns_classic:GetModifierPercentageCooldown()
	return self.cdr
end




---------------------------------------------------------------------
---------------------------------------------------------------------
-- KnS Maim Debuff

modifier_kns_maim = class({})

-- Classifications
function modifier_kns_maim:IsHidden()
	return false
end

function modifier_kns_maim:IsDebuff()
	return true
end

function modifier_kns_maim:IsStunDebuff()
	return false
end

function modifier_kns_maim:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_kns_maim:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_kns_maim:OnCreated( kv )
	
	-- references
	self.caster = self:GetCaster()
	self.maim_slow_ms = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement" ) -- special value
	self.maim_slow_ms_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement_range" ) -- special value
	self.maim_slow_atk = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack" ) -- special value
	self.maim_slow_atk_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack_range" ) -- special value


end

function modifier_kns_maim:OnRefresh( kv )

	-- references
	self.caster = self:GetCaster()
	self.maim_slow_ms = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement" ) -- special value
	self.maim_slow_ms_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement_range" ) -- special value
	self.maim_slow_atk = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack" ) -- special value
	self.maim_slow_atk_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack_range" ) -- special value

end

function modifier_kns_maim:GetModifierMoveSpeedBonus_Percentage()

	if self.caster:IsRangedAttacker() then 
		return self.maim_slow_ms_range
	else
		return self.maim_slow_ms
	end 

end

function modifier_kns_maim:GetModifierAttackSpeedBonus_Constant()

	if self.caster:IsRangedAttacker() then 
		return self.maim_slow_atk_range
	else
		return self.maim_slow_atk
	end 
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_kns_maim:GetEffectName()
	return "particles/items2_fx/sange_maim_d.vpcf"
end

function modifier_kns_maim:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


