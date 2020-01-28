LinkLuaModifier("modifier_att_bonus", LUA_MODIFIER_MOTION_NONE)

att_bonus = class({})

function att_bonus:GetIntrinsicModifierName()
	return "modifier_att_bonus"
end

modifier_att_bonus = class({})

function modifier_att_bonus:DeclareFunctions()
	local	att_array = {

	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS;
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS;
	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS;
	}

	return att_array
end


function modifier_att_bonus:GetModifierBonusStats_Strength(params)
	return self:GetAbility():GetSpecialValueFor("special_one");
end

function modifier_att_bonus:GetModifierBonusStats_Agility(params)
	return self:GetAbility():GetSpecialValueFor("special_one");
end

function modifier_att_bonus:GetModifierBonusStats_Intellect(params)
	return self:GetAbility():GetSpecialValueFor("special_one");
end

--[[
"DOTAAbilities"
{
	"Version"	"1"


	//===============================
	// Generic: Attribute Bonus
	//===============================

	"att_bonus"
	{
	"BaseClass"		"ability_lua"
	"ScriptFile"		"att_bonus"
	"AbilityBehavior"	"DOTA_ABILITY_BEHAVIOR_PASSIVE"
	"FightRecapLevel"	"1"
	"MaxLevel"		"6"


	"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"special_one"			"3 6 9 12 16 20"
			}
		}
	}
}
--]]
