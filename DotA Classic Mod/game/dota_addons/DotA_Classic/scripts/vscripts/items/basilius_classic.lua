item_ring_of_basilius_classic = class({})
LinkLuaModifier("modifier_basilius","items/basilius_classic", LUA_MODIFIER_MOTION_NONE)


function item_ring_of_basilius_classic:GetIntrinsicModifierName()
	return "modifier_basilius"
end

-------------------------
--Visual for Toggle

--Toggling
function item_ring_of_basilius_classic:OnToggle()
	--local test = self:GetToggleState()
	--print(test)
end

function item_ring_of_basilius_classic:GetAbilityTextureName()
	local inactive = self:GetToggleState()

	if inactive then return "item_rob_inactive" end
	return "item_ring_of_basilius" 

end



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Basilius Passive Bonuses Modifier

modifier_basilius = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_basilius:IsHidden()
	return true
end

function modifier_basilius:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_basilius:OnCreated( kv )
	-- references
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value
end

function modifier_basilius:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_basilius:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

function modifier_basilius:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end


---------------------------------------
-- AURA PART

local modifierClass = modifier_basilius
local modifierName = 'modifier_basilius'
LinkLuaModifier(modifierName, "items/basilius_classic", LUA_MODIFIER_MOTION_NONE)


modifier_basilius_aura = class({})
local buffModifierClass = modifier_basilius_aura
local buffModifierName = 'modifier_basilius_aura'
LinkLuaModifier(buffModifierName, "items/basilius_classic", LUA_MODIFIER_MOTION_NONE)

function modifierClass:IsAura()
    return true
end

function modifierClass:IsAuraActiveOnDeath()
    return false
end

function modifierClass:GetAuraRadius()
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    return radius
end

function modifierClass:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifierClass:GetAuraSearchType()
	--For Toggle
	if self:GetAbility():GetToggleState() then  
		return DOTA_UNIT_TARGET_HERO
	end 

	return (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC)
end

function modifierClass:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifierClass:RemoveOnDeath()
    return false
end

function modifierClass:GetModifierAura()
    return buffModifierName
end

----------------
--ALLY BUFF--
----------------

function buffModifierClass:OnCreated()
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "aura_mana_regen" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "aura_bonus_armor" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

function buffModifierClass:GetModifierPhysicalArmorBonus()
	local npc = self:GetParent()
	if npc:HasModifier("modifier_aquila_aura") then return 0 end
	return self.bonus_armor
end

function buffModifierClass:GetModifierConstantManaRegen()
	local npc = self:GetParent()
	if npc:HasModifier("modifier_aquila_aura") then return 0 end
	return self.mana_reg
end