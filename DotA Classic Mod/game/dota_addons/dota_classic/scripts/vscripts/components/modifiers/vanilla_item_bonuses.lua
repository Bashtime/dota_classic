-- 1st Modding Project by Bashtime
modifier_vanilla_item_bonuses = class({})
local modifierClass = modifier_vanilla_item_bonuses
local modifierName = 'modifier_vanilla_item_bonuses'

function modifierClass:IsPurgable()
    return false
end

function modifierClass:IsHidden()
    return true
end

function modifierClass:RemoveOnDeath()
    return false
end

function modifierClass:IsPermanent()
    return true
end

function modifierClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

	-- Modifier Effects
	function modifierClass:DeclareFunctions()

		local funcs = {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
				}

		return funcs
	end


function modifierClass:GetModifierBonusStats_Agility()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_item_ultimate_scepter_consumed") then return 7
	else return 0
	end
end

function modifierClass:GetModifierBonusStats_Strength()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_item_ultimate_scepter_consumed") then return 7
	else return 0
	end
end

function modifierClass:GetModifierBonusStats_Intellect()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_item_ultimate_scepter_consumed") then return 7
	else return 0
	end
end
