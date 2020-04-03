-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
modifier_axe_berserkers_call_elf = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_berserkers_call_elf:IsHidden()
	return false
end

function modifier_axe_berserkers_call_elf:IsDebuff()
	return false
end

function modifier_axe_berserkers_call_elf:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_axe_berserkers_call_elf:OnCreated( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
end

function modifier_axe_berserkers_call_elf:OnRefresh( kv )
	-- references
	self.armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
end

function modifier_axe_berserkers_call_elf:OnRemoved()
end

function modifier_axe_berserkers_call_elf:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_axe_berserkers_call_elf:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_axe_berserkers_call_elf:GetModifierPhysicalArmorBonus()
	return self.armor
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_axe_berserkers_call_elf:GetEffectName()
	return "particles/units/heroes/hero_axe/axe_beserkers_call.vpcf"
end

function modifier_axe_berserkers_call_elf:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
