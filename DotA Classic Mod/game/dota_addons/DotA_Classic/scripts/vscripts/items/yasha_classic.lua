item_yasha_classic = class({})

LinkLuaModifier("modifier_yasha_classic","items/yasha_classic", LUA_MODIFIER_MOTION_NONE)

function item_yasha_classic:GetIntrinsicModifierName()
	return "modifier_yasha_classic"
end



-- Yasha Bonuses Modifier
modifier_yasha_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_yasha_classic:IsHidden()
	return true
end

function modifier_yasha_classic:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_yasha_classic:OnCreated( kv )
	-- references
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed_percent_bonus" ) -- special value
end


function modifier_yasha_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_yasha_classic:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_yasha_classic:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
	}

	return funcs
end

function modifier_yasha_classic:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_yasha_classic:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_yasha_classic:GetModifierMoveSpeedBonus_Percentage_Unique()
	return self.bonus_ms
end