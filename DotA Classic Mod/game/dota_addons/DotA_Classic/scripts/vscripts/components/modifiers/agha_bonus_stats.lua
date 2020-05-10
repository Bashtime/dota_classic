-- 1st Modding Project by Bashtime
modifier_agha_bonus_stats = class({})

function modifier_agha_bonus_stats:IsPurgable()
    return false
end

function modifier_agha_bonus_stats:IsHidden()
    return true
end

function modifier_agha_bonus_stats:RemoveOnDeath()
    return false
end

function modifier_agha_bonus_stats:IsPermanent()
    return true
end

function modifier_agha_bonus_stats:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

	-- Modifier Effects
	function modifier_agha_bonus_stats:DeclareFunctions()

		local funcs = {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
				}

		return funcs
	end


function modifier_agha_bonus_stats:GetModifierBonusStats_Agility()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_item_ultimate_scepter_consumed") then return 7
	else return 0
	end
end

function modifier_agha_bonus_stats:GetModifierBonusStats_Strength()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_item_ultimate_scepter_consumed") then return 7
	else return 0
	end
end

function modifier_agha_bonus_stats:GetModifierBonusStats_Intellect()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_item_ultimate_scepter_consumed") then return 7
	else return 0
	end
end
