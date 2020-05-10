item_oblivion_staff_classic = class({})
local itemClass = item_oblivion_staff_classic


modifier_oblivion_classic = class({})
local modifierClass = modifier_oblivion_classic
local modifierName = 'modifier_oblivion_classic'
LinkLuaModifier(modifierName, "items/oblivion_staff_classic", LUA_MODIFIER_MOTION_NONE)


function itemClass:GetIntrinsicModifierName()
	return modifierName
end


--------------------------------------------------------------------------------
-- Classifications
function modifierClass:IsHidden()
	return true
end

function modifierClass:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifierClass:OnCreated( kv )
	-- references
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" ) -- special value
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )

end


function modifierClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifierClass:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifierClass:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end


function modifierClass:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end


function modifierClass:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end


function modifierClass:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end


function modifierClass:GetModifierBonusStats_Intellect()
	return self.bonus_int
end