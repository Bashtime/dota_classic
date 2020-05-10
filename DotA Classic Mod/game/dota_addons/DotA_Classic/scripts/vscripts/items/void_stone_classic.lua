item_void_stone_classic = class({})
local itemClass = item_void_stone_classic


modifier_void_classic = class({})
local modifierClass = modifier_void_classic
local modifierName = 'modifier_void_classic'
LinkLuaModifier(modifierName, "items/void_stone_classic", LUA_MODIFIER_MOTION_NONE)


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
	}

	return funcs
end


function modifierClass:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end

