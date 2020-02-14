-- Attribute Bonus Modifier

modifier_am_purity = class({})

function modifier_am_purity:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_am_purity:IsHidden()
	return true
end

function modifier_am_purity:IsPurgable()
	return false
end

function modifier_am_purity:RemoveOnDeath() 
	return false 
end


function modifier_am_purity:GetModifierBonusStats_Strength(params)
	return self:GetAbility():GetSpecialValueFor("blink_range_adjust");
end

function modifier_am_purity:GetModifierBonusStats_Agility(params)
	return self:GetAbility():GetSpecialValueFor("blink_range_adjust");
end

function modifier_am_purity:GetModifierBonusStats_Intellect(params)
	return self:GetAbility():GetSpecialValueFor("blink_range_adjust");
end

