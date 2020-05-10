item_echo_sabre_classic = class({})
local itemClass = item_echo_sabre_classic


modifier_echo_sabre_classic = class({})
local modifierClass = modifier_echo_sabre_classic
local modifierName = 'modifier_echo_sabre_classic'
LinkLuaModifier(modifierName, "items/echo_sabre_classic", LUA_MODIFIER_MOTION_NONE)


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
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )

	local caster = self:GetParent() 

	if IsServer() then
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_echo_sabre", { duration = -1})
	end
end


function modifierClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifierClass:OnDestroy()
	local caster = self:GetParent() 

	if IsServer() then
	caster:RemoveModifierByName("modifier_item_echo_sabre")
	end
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifierClass:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
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

function modifierClass:GetModifierBonusStats_Strength()
	return self.bonus_str
end