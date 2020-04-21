item_spell_prism_classic = class({})
local itemClass = item_spell_prism_classic


modifier_spellprism = class({})
local modifierClass = modifier_spellprism
local modifierName = 'modifier_spellprism'
LinkLuaModifier(modifierName, "items/spell_prism_classic", LUA_MODIFIER_MOTION_NONE)


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
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" ) -- special value

	--self:StartIntervalThink(0.2)

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
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}

	return funcs
end






function modifierClass:OnIntervalThink()

end

function modifierClass:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end



function modifierClass:GetModifierPercentageCooldown()
	return self.cdr
end
