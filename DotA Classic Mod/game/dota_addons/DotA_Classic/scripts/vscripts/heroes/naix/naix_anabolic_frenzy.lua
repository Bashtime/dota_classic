--	Created by Bashtime, 29.04.2020

naix_anabolic_frenzy = class({})
local abilityClass = naix_anabolic_frenzy
local abilityName = 'naix_anabolic_frenzy'

modifier_naix_anabolic_frenzy = class({})
local modifierClass = modifier_naix_anabolic_frenzy
local modifierName = 'modifier_naix_anabolic_frenzy'
LinkLuaModifier( modifierName, "heroes/naix/naix_anabolic_frenzy", LUA_MODIFIER_MOTION_NONE )


function abilityClass:GetIntrinsicModifierName()
	return modifierName
end


--Change Behavior when getting talent levels
function abilityClass:GetBehavior()
	local caster = self:GetCaster()
	local talent_lvl = caster:GetModifierStackCount("modifier_talent_lvl", caster)

	if talent_lvl == 0 then 
		return DOTA_ABILITY_BEHAVIOR_PASSIVE  
	else
		return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function abilityClass:GetCooldown()
	local caster = self:GetCaster()
	local talent_lvl = caster:GetModifierStackCount("modifier_talent_lvl", caster)

	if talent_lvl == 0 then 
		return 0  
	else
		return 50 - talent_lvl * 10
	end
end

function abilityClass:GetManaCost()
	local caster = self:GetCaster()
	local talent_lvl = caster:GetModifierStackCount("modifier_talent_lvl", caster)

	if talent_lvl == 0 then 
		return 0  
	else
		return 70 - talent_lvl * 10
	end
end











--------------------------------------------------------------------------------
-- Passive Modifier

function modifierClass:IsHidden()
	return true
end

function modifierClass:IsPurgable()
	return false
end

	----------------------------------
	--	Modifier Effects
	----------------------------------

	function modifierClass:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		}
		return funcs
	end

		function modifierClass:GetModifierMoveSpeedBonus_Percentage()
			if (not self:GetParent():PassivesDisabled()) then
				return self:GetAbility():GetSpecialValueFor("bonus_ms")
			end
		end

		function modifierClass:GetModifierAttackSpeedBonus_Constant()
			if (not self:GetParent():PassivesDisabled()) then
				return self:GetAbility():GetSpecialValueFor("bonus_as")
			end
		end

