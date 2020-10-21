--Class Definitions

	item_mirror_classic = class({})
	local itemClass = item_mirror_classic

	--Passive instrinsic Bonus Modifier
	modifier_mirror = class({})
	local modifierClass = modifier_mirror
	local modifierName = 'modifier_mirror'
	LinkLuaModifier(modifierName, "items/mirror_classic", LUA_MODIFIER_MOTION_NONE)


		--Usual Settings
		function itemClass:GetIntrinsicModifierName()
			return modifierName
		end

		function modifierClass:IsHidden()
			return true
		end

		function modifierClass:IsPurgable()
			return false
		end

		function modifierClass:RemoveOnDeath()
    		return false
		end

		function modifierClass:GetAttributes()
			return MODIFIER_ATTRIBUTE_MULTIPLE
		end


--Active Part
function itemClass:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local blockCD = self:GetSpecialValueFor( "block_cooldown" )

	self:StartCooldown( blockCD )
	target:AddNewModifier(caster, self, "modifier_item_sphere_target", { duration = blockCD})

	-- effects
	local sound_cast = "DOTA_Item.LinkensSphere.Target"
	EmitSoundOn( sound_cast, target )
end


function itemClass:GetCooldown()
	return self:GetSpecialValueFor( "block_cooldown" )
end




-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	local caster = self:GetParent() 

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" )

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_all" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_all" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_all" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	

	if IsServer() then
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_mirror_shield", { duration = -1})
	end

end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
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

					--Add more stuff below

				}

				return funcs
			end


				--DMG; ARMOR; MS; AS; MR
				function modifierClass:GetModifierPreAttack_BonusDamage()
					return self.bonus_dmg
				end

				function modifierClass:GetModifierPhysicalArmorBonus()
					return self.bonus_armor
				end

				function modifierClass:GetModifierMoveSpeedBonus_Constant()
					return self.bonus_ms
				end

				function modifierClass:GetModifierAttackSpeedBonus_Constant()
					return self.bonus_as
				end

				function modifierClass:GetModifierMagicalResistanceBonus()
					return self.bonus_mr
				end



				--STR; AGI; INT
				function modifierClass:GetModifierBonusStats_Strength()
					return self.bonus_str
				end

				function modifierClass:GetModifierBonusStats_Agility()
					return self.bonus_agi
				end

				function modifierClass:GetModifierBonusStats_Intellect()
					return self.bonus_int
				end



				--HP; MANA; REG
				function modifierClass:GetModifierHealthBonus()
					return self.bonus_hp
				end

				function modifierClass:GetModifierManaBonus()
					return self.bonus_mana
				end

				function modifierClass:GetModifierConstantHealthRegen()
					return self.hp_reg
				end

				function modifierClass:GetModifierConstantManaRegen()
					local caster = self:GetParent()
					local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
					local regen = self.mana_reg / 100 * int * 0.05
					return regen
				end


function modifierClass:OnDestroy()
	local caster = self:GetParent() 

	if IsServer() then
	caster:RemoveModifierByName("modifier_item_mirror_shield")
	end
end






--[[ Author: EarthSalamander
-- Date: 19/08/2020


----------------------------------
--          LOTUS ORB           --
----------------------------------

item_imba_lotus_orb = item_imba_lotus_orb or class({})

LinkLuaModifier("modifier_item_imba_lotus_orb_passive", "components/items/item_lotus_orb.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_lotus_orb_active", "components/items/item_lotus_orb.lua", LUA_MODIFIER_MOTION_NONE)

function item_imba_lotus_orb:GetIntrinsicModifierName()
	return "modifier_item_imba_lotus_orb_passive"
end

function item_imba_lotus_orb:OnSpellStart()
	if not IsServer() then return end

	-- use vanilla modifier, and add another modifier to handle abilities not being reflected properly
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_imba_lotus_orb_active", {duration = self:GetSpecialValueFor("active_duration")})
end

modifier_item_imba_lotus_orb_passive = modifier_item_imba_lotus_orb_passive or class({})

function modifier_item_imba_lotus_orb_passive:IsHidden()		return true end
function modifier_item_imba_lotus_orb_passive:IsPurgable()		return false end
function modifier_item_imba_lotus_orb_passive:RemoveOnDeath()	return false end
function modifier_item_imba_lotus_orb_passive:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_imba_lotus_orb_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_item_imba_lotus_orb_passive:OnCreated()
	if not IsServer() then return end

	self:GetParent().tOldSpells = {}

	self:StartIntervalThink(FrameTime())
end

-- Deleting old abilities
-- This is bound to the passive modifier, so this is constantly on!
function modifier_item_imba_lotus_orb_passive:OnIntervalThink()
	for i = #self:GetParent().tOldSpells, 1, -1 do
		local hSpell = self:GetParent().tOldSpells[i]

		if hSpell:NumModifiersUsingAbility() == 0 and not hSpell:IsChanneling() then
			hSpell:RemoveSelf()
			table.remove(self:GetParent().tOldSpells,i)
		end
	end
end

function modifier_item_imba_lotus_orb_passive:GetModifierConstantHealthRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	end
end

function modifier_item_imba_lotus_orb_passive:GetModifierManaBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_mana")
	end
end

function modifier_item_imba_lotus_orb_passive:GetModifierConstantManaRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	end
end

function modifier_item_imba_lotus_orb_passive:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_armor")
	end
end

-- Reflect modifier
-- Biggest thanks to Yunten !
modifier_item_imba_lotus_orb_active = modifier_item_imba_lotus_orb_active or class({})

function modifier_item_imba_lotus_orb_active:IsPurgable() return false end
function modifier_item_imba_lotus_orb_active:IsPurgeException() return false end

function modifier_item_imba_lotus_orb_active:DeclareFunctions() return {
	MODIFIER_PROPERTY_ABSORB_SPELL,
	MODIFIER_PROPERTY_REFLECT_SPELL,
} end

function modifier_item_imba_lotus_orb_active:OnCreated(params)
	if not IsServer() then return end

	local shield_pfx = "particles/items3_fx/lotus_orb_shield.vpcf"
	self.reflect_pfx = "particles/items3_fx/lotus_orb_reflect.vpcf"
	local cast_sound = "Item.LotusOrb.Target"
	self.reflect_sound = ""

	if params.shield_pfx then shield_pfx = params.shield_pfx end
	if params.cast_sound then cast_sound = params.cast_sound end
	if params.reflect_pfx then self.reflect_pfx = params.reflect_pfx end

	self.pfx = ParticleManager:CreateParticle(shield_pfx, PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

	-- Random numbers
--	ParticleManager:SetParticleControl(self.particle, 1, Vector(150, 150, 150))

	self:GetCaster():EmitSound(cast_sound)
end

function modifier_item_imba_lotus_orb_active:GetAbsorbSpell(params)
	if params.ability then
		print("Ability absorbed:", params.ability:GetAbilityName())
	end

	if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return nil
	end

	self:GetCaster():EmitSound("Item.LotusOrb.Activate")

	if self:GetParent():HasAbility("imba_antimage_spell_shield") then
		-- IMBAfication: Trading Places
		if self:GetAbility() and self:GetAbility():GetAutoCastState() and params.ability:GetCaster() and params.ability:GetCaster():IsAlive() then
			local modifier_holder_position	= self:GetParent():GetAbsOrigin()
			local caster_position			= params.ability:GetCaster():GetAbsOrigin()
		
			FindClearSpaceForUnit(self:GetParent(), caster_position, true)
			FindClearSpaceForUnit(params.ability:GetCaster(), modifier_holder_position, true)
		
			local blink_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:ReleaseParticleIndex(blink_1)
			self:GetParent():EmitSound("Hero_Antimage.Blink_out")

			local blink_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, params.ability:GetCaster())
			ParticleManager:ReleaseParticleIndex(blink_2)
			params.ability:GetCaster():EmitSound("Hero_Antimage.Blink_out")

			params.ability:GetCaster():EmitSound("Hero_Antimage.Counterspell.Target")
		end
	end
	
	return 1
end

function modifier_item_imba_lotus_orb_active:GetReflectSpell(params)
	-- If some spells shouldn't be reflected, enter it into this spell-list
	local exception_spell = {
		["rubick_spell_steal"] = true,
		["imba_alchemist_greevils_greed"] = true,
		["imba_alchemist_unstable_concoction"] = true,
		["imba_disruptor_glimpse"] = true,
		["legion_commander_duel"] = true,
		["imba_phantom_assassin_phantom_strike"] = true,
		["phantom_assassin_phantom_strike"] = true,
		["imba_riki_blink_strike"] = true,
		["riki_blink_strike"] = true,
		["imba_rubick_spellsteal"] = true,
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

function modifier_item_imba_lotus_orb_active:OnRemoved()
	if not IsServer() then return end

	self:GetCaster():EmitSound("Item.LotusOrb.Destroy")

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

]]