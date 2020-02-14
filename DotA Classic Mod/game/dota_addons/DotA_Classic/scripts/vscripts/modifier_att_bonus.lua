-- Attribute Bonus Modifier

modifier_att_bonus = class({})

function modifier_att_bonus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_att_bonus:IsHidden()
	return true
end

function modifier_att_bonus:IsPurgable()
	return false
end

function modifier_att_bonus:RemoveOnDeath() 
	return false 
end


function modifier_att_bonus:GetModifierBonusStats_Strength(params)
	return self:GetAbility():GetSpecialValueFor("plus_stats");
end

function modifier_att_bonus:GetModifierBonusStats_Agility(params)
	return self:GetAbility():GetSpecialValueFor("plus_stats");
end

function modifier_att_bonus:GetModifierBonusStats_Intellect(params)
	return self:GetAbility():GetSpecialValueFor("plus_stats");
end

