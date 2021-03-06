-- Editors:
--

-- Author: EarthSalamander
-- Date: 19/08/2020


----------------------------------
--          LOTUS ORB           --
----------------------------------

item_mirror_classic = item_mirror_classic or class({})

LinkLuaModifier("modifier_item_mirror_classic_passive", "items/mirror_classic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mirror_classic_active", "items/mirror_classic.lua", LUA_MODIFIER_MOTION_NONE)

function item_mirror_classic:GetIntrinsicModifierName()
	return "modifier_item_mirror_classic_passive"
end

function item_mirror_classic:OnSpellStart()
	if not IsServer() then return end

	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_mirror_classic_active", {duration = self:GetSpecialValueFor("active_duration")})
end

modifier_item_mirror_classic_passive = modifier_item_mirror_classic_passive or class({})

function modifier_item_mirror_classic_passive:IsHidden()		return true end
function modifier_item_mirror_classic_passive:IsPurgable()		return false end
function modifier_item_mirror_classic_passive:RemoveOnDeath()	return false end
function modifier_item_mirror_classic_passive:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_mirror_classic_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_item_mirror_classic_passive:OnCreated()
	self.bonus_all = self:GetAbility():GetSpecialValueFor("bonus_all")
	self.mana_reg = self:GetAbility():GetSpecialValueFor("mana_reg")

	if not IsServer() then return end

	self:GetParent().tOldSpells = {}

	self:StartIntervalThink(FrameTime())
end

-- Deleting old abilities
-- This is bound to the passive modifier, so this is constantly on!
function modifier_item_mirror_classic_passive:OnIntervalThink()
	for i = #self:GetParent().tOldSpells, 1, -1 do
		local hSpell = self:GetParent().tOldSpells[i]

		if hSpell:NumModifiersUsingAbility() == 0 and not hSpell:IsChanneling() then
			hSpell:RemoveSelf()
			table.remove(self:GetParent().tOldSpells,i)
		end
	end
end

function modifier_item_mirror_classic_passive:DeclareFunctions() return {
	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

	MODIFIER_PROPERTY_HEALTH_BONUS,
	MODIFIER_PROPERTY_MANA_BONUS,
	MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
} end

--DMG; ARMOR; MS; AS; MR
function modifier_item_mirror_classic_passive:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end

function modifier_item_mirror_classic_passive:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_item_mirror_classic_passive:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_item_mirror_classic_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_item_mirror_classic_passive:GetModifierMagicalResistanceBonus()
	return self.bonus_mr
end



--STR; AGI; INT
function modifier_item_mirror_classic_passive:GetModifierBonusStats_Strength()
	return self.bonus_all
end

function modifier_item_mirror_classic_passive:GetModifierBonusStats_Agility()
	return self.bonus_all
end

function modifier_item_mirror_classic_passive:GetModifierBonusStats_Intellect()
	return self.bonus_all
end



--HP; MANA; REG
function modifier_item_mirror_classic_passive:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_mirror_classic_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_mirror_classic_passive:GetModifierConstantHealthRegen()
	return self.hp_reg
end

function modifier_item_mirror_classic_passive:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end

modifier_item_mirror_classic_active = modifier_item_mirror_classic_active or class({})

function modifier_item_mirror_classic_active:IsPurgable() return false end
function modifier_item_mirror_classic_active:IsPurgeException() return false end

function modifier_item_mirror_classic_active:DeclareFunctions() return {
	MODIFIER_PROPERTY_ABSORB_SPELL,
	MODIFIER_PROPERTY_REFLECT_SPELL,
} end

function modifier_item_mirror_classic_active:OnCreated(params)
	if not IsServer() then return end

	local shield_pfx = "particles/items3_fx/lotus_orb_shield.vpcf"
	self.reflect_pfx = "particles/items3_fx/lotus_orb_reflect.vpcf"
	local cast_sound = "Item.LotusOrb.Target"
	self.reflect_sound = ""

	if params.shield_pfx then shield_pfx = params.shield_pfx end
	if params.cast_sound then cast_sound = params.cast_sound end
	if params.reflect_pfx then self.reflect_pfx = params.reflect_pfx end

	self:GetParent():Purge(false, true, false, false, false)

	self.pfx = ParticleManager:CreateParticle(shield_pfx, PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

	-- Random numbers
--	ParticleManager:SetParticleControl(self.particle, 1, Vector(150, 150, 150))

	self:GetCaster():EmitSound(cast_sound)
end

function modifier_item_mirror_classic_active:GetAbsorbSpell(params)
	if self:GetAbility():GetAbilityName() == "item_mirror_classic" then
		return nil
	end

	if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return nil
	end

	self:GetCaster():EmitSound("Item.LotusOrb.Activate")
	
	return 1
end

function modifier_item_mirror_classic_active:GetReflectSpell(params)
	-- If some spells shouldn't be reflected, enter it into this spell-list
	local exception_spell = {
		["rubick_spell_steal"] = true,
		["alchemist_unstable_concoction"] = true,
		["disruptor_glimpse"] = true,
		["legion_commander_duel"] = true,
		["phantom_assassin_phantom_strike"] = true,
		["morphling_replicate"]	= true
	}

	local reflected_spell_name = params.ability:GetAbilityName()
	local target = params.ability:GetCaster()

	-- Does not reflect allies' projectiles for any reason
	if target:GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return nil
	end

	if ( not exception_spell[reflected_spell_name] ) and (not target:HasModifier("modifier_imba_spell_shield_buff_reflect")) then
		-- If this is a reflected ability, do nothing
		if params.ability.spell_shield_reflect then
			return nil
		end

		local pfx = ParticleManager:CreateParticle(self.reflect_pfx, PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)

--		local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
--		ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetOrigin(), true)
--		ParticleManager:ReleaseParticleIndex(reflect_pfx)

		local old_spell = false

		for _,hSpell in pairs(self:GetParent().tOldSpells) do
			if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
				old_spell = true
				break
			end
		end

		if old_spell then
			ability = self:GetParent():FindAbilityByName(reflected_spell_name)
		else
			ability = self:GetParent():AddAbility(reflected_spell_name)
			ability:SetStolen(true)
			ability:SetHidden(true)

			-- Tag ability as a reflection ability
			ability.spell_shield_reflect = true

			-- Modifier counter, and add it into the old-spell list
			ability:SetRefCountsModifiers(true)
			table.insert(self:GetParent().tOldSpells, ability)
		end

		ability:SetLevel(params.ability:GetLevel())
		-- Set target & fire spell
		self:GetParent():SetCursorCastTarget(target)

		if ability:GetToggleState() then
			ability:ToggleAbility()
		end

		ability:OnSpellStart()

		-- This isn't considered vanilla behavior, but at minimum it should resolve any lingering channeled abilities...
		if ability.OnChannelFinish then
			ability:OnChannelFinish(false)
		end	
	end

	return false
end

function modifier_item_mirror_classic_active:OnRemoved()
	if not IsServer() then return end

	self:GetCaster():EmitSound("Item.LotusOrb.Destroy")

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end
