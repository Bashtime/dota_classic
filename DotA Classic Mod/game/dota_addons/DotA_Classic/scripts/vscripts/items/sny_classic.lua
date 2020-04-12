item_sny_classic = class({})

LinkLuaModifier("modifier_sny_classic","items/sny_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sny_maim","items/sny_classic", LUA_MODIFIER_MOTION_NONE)



function item_sny_classic:GetIntrinsicModifierName()
	return "modifier_sny_classic"
end



-- SnY Bonuses Modifier
modifier_sny_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sny_classic:IsHidden()
	return true
end

function modifier_sny_classic:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_sny_classic:OnCreated( kv )

	-- references
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed_percent_bonus" ) -- special value

	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.maim_chance = self:GetAbility():GetSpecialValueFor( "maim_chance" ) -- special value
	self.maim_duration = self:GetAbility():GetSpecialValueFor( "maim_duration" ) -- special value

end

function modifier_sny_classic:OnRefresh( kv )

	-- references
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed_percent_bonus" ) -- special value

	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.maim_chance = self:GetAbility():GetSpecialValueFor( "maim_chance" ) -- special value
	self.maim_duration = self:GetAbility():GetSpecialValueFor( "maim_duration" ) -- special value

end


function modifier_sny_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_sny_classic:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sny_classic:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,

		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_sny_classic:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_sny_classic:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_sny_classic:GetModifierMoveSpeedBonus_Percentage_Unique()
	return self.bonus_ms
end




function modifier_sny_classic:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_sny_classic:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end

function modifier_sny_classic:GetModifierProcAttack_BonusDamage_Physical( params )

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
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_sny_maim", { duration = self.maim_duration})

				-- effects
				local sound_cast = "DOTA_Item.Maim"
				EmitSoundOn( sound_cast, target )
			end
		end

	return 0
end





---------------------------------------------------------------------
---------------------------------------------------------------------
-- SnY Maim Debuff

modifier_sny_maim = class({})

-- Classifications
function modifier_sny_maim:IsHidden()
	return false
end

function modifier_sny_maim:IsDebuff()
	return true
end

function modifier_sny_maim:IsStunDebuff()
	return false
end

function modifier_sny_maim:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sny_maim:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_sny_maim:OnCreated( kv )
	
	-- references
	self.caster = self:GetCaster()
	self.maim_slow_ms = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement" ) -- special value
	self.maim_slow_ms_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement_range" ) -- special value
	self.maim_slow_atk = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack" ) -- special value
	self.maim_slow_atk_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack_range" ) -- special value


end

function modifier_sny_maim:OnRefresh( kv )

	-- references
	self.caster = self:GetCaster()
	self.maim_slow_ms = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement" ) -- special value
	self.maim_slow_ms_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement_range" ) -- special value
	self.maim_slow_atk = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack" ) -- special value
	self.maim_slow_atk_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack_range" ) -- special value

end

function modifier_sny_maim:GetModifierMoveSpeedBonus_Percentage()

	if self.caster:IsRangedAttacker() then 
		return self.maim_slow_ms_range
	else
		return self.maim_slow_ms
	end 

end

function modifier_sny_maim:GetModifierAttackSpeedBonus_Constant()

	if self.caster:IsRangedAttacker() then 
		return self.maim_slow_atk_range
	else
		return self.maim_slow_atk
	end 
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_sny_maim:GetEffectName()
	return "particles/items2_fx/sange_maim_d.vpcf"
end

function modifier_sny_maim:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



