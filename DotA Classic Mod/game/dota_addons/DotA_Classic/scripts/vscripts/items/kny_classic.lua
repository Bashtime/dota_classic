item_kny_classic = class({})

LinkLuaModifier("modifier_kny_classic","items/kny_classic", LUA_MODIFIER_MOTION_NONE)

function item_kny_classic:GetIntrinsicModifierName()
	return "modifier_kny_classic"
end




-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Kaya and Yasha Passive Bonuses Modifier

modifier_kny_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_kny_classic:IsHidden()
	return true
end

function modifier_kny_classic:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_kny_classic:OnCreated( kv )

	-- references
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value

	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value

	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed_percent_bonus" ) -- special value

end

function modifier_kny_classic:OnRefresh( kv )

	-- references
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value

	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value

	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed_percent_bonus" ) -- special value

end

function modifier_kny_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_kny_classic:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_kny_classic:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,

		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,		
	}

	return funcs
end


function modifier_kny_classic:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_kny_classic:GetModifierPercentageManacost()
	return self.manacost_reduction
end

function modifier_kny_classic:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end


function modifier_kny_classic:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_kny_classic:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_kny_classic:GetModifierMoveSpeedBonus_Percentage_Unique()
	return self.bonus_ms
end
