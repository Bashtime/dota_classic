-- AXE ONE-MAN ARMY Modifier

modifier_axe_one = class({})

function modifier_axe_one:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_axe_one:IsHidden()
	return true
end

function modifier_axe_one:IsPurgable()
	return false
end

function modifier_axe_one:RemoveOnDeath() 
	return false 
end


function modifier_axe_one:GetModifierMoveSpeedBonus_Constant(params)
	return self:GetAbility():GetSpecialValueFor("bonus_ms");
end

function modifier_axe_one:GetModifierConstantHealthRegen(params)
	return self:GetAbility():GetSpecialValueFor("bonus_reg");
end

function modifier_axe_one:GetModifierAttackSpeedBonus_Constant(params)
	return self:GetAbility():GetSpecialValueFor("bonus_as");
end



