att_bonus = class({})

LinkLuaModifier("modifier_att_bonus", "att_bonus", LUA_MODIFIER_MOTION_NONE)

function att_bonus:OnUpgrade()
	local caster = self:GetCaster();

	caster:AddNewModifier(caster, self, "modifier_att_bonus", {duration = -1});


	local current_hp_after_upgrade = caster:GetHealth()
	local max_hp = caster:GetMaxHealth()
	local current_hp_percentage = current_hp_after_upgrade / max_hp
	local current_hp_before_upgrade = current_hp_percentage * (max_hp - 3 * 19)
	local new_hp = math.min( current_hp_before_upgrade + 3 * 19 , max_hp )


	local current_mana_after_upgrade = caster:GetMana()
	local max_mana = caster:GetMaxMana()
	local current_mana_percentage = current_mana_after_upgrade / max_mana
	local current_mana_before_upgrade = current_mana_percentage * (max_mana - 3 * 13)
	local new_mana = math.min( current_mana_before_upgrade + 3 * 13 , max_mana )

	--Leveling Attribute Bonus increases HP and Mana by flat amount instead  

	local new_mana = math.min( current_mana_before_upgrade + 3 * 13 , max_mana )

	caster:SetHealth( new_hp )
	caster:SetMana( new_mana )

end

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