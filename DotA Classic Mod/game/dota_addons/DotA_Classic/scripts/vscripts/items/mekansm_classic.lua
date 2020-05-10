--Class Definitions

	item_mekansm_classic = class({})
	local itemClass = item_mekansm_classic

	--Aura Bonuses Modifier
	modifier_mekansm_aura = class({})
	local buffModifierClass = modifier_mekansm_aura
	local buffModifierName = 'modifier_mekansm_aura'
	LinkLuaModifier(buffModifierName, "items/mekansm_classic", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_mekansm_classic = class({})
	local modifierClass = modifier_mekansm_classic
	local modifierName = 'modifier_mekansm_classic'
	LinkLuaModifier(modifierName, "items/mekansm_classic", LUA_MODIFIER_MOTION_NONE)


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


			--Optional Aura Settings
			function modifierClass:IsAura()
    			return true
			end

			function modifierClass:IsAuraActiveOnDeath()
    			return false
			end
				--Who is affected ?
				function modifierClass:GetAuraSearchTeam()
    				return DOTA_UNIT_TARGET_TEAM_FRIENDLY
				end

				function modifierClass:GetAuraSearchType()
					return (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC)
				end

				function modifierClass:GetAuraSearchFlags()
    				return DOTA_UNIT_TARGET_FLAG_NONE
				end

			function modifierClass:GetAuraRadius()
				local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    			return radius
			end

			function modifierClass:GetModifierAura()
    			return buffModifierName
			end




--Active item part

function itemClass:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local heal_amount = self:GetSpecialValueFor("heal_amount")
	local radius = self:GetSpecialValueFor( "heal_radius" )
	local noheal_duration = self:GetSpecialValueFor( "noheal_debuff" )
	local active_duration = self:GetSpecialValueFor( "active_duration" )

	-- Find Units in Radius
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,ally in pairs(allies) do

		-- Add Armor Buff
			ally:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_mekansm_active", -- modifier name
			{ duration = active_duration } -- kv
		)

		if not ally:HasModifier("modifier_item_mekansm_noheal") then 
			
			if ally == caster then
			 ally:Heal(heal_amount, caster) 
			 SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, heal_amount, nil)
			end

			-- Nice, Valve! Your Heal Amp stat is useless on custom spells, thanks! Fix below!
			if ally ~= caster then 
				if caster:HasModifier("modifier_holy_locket_classic_passive") then
					heal_amount = heal_amount * 1.25
				end 
				ally:Heal(heal_amount, caster) 
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, heal_amount, nil)
			end

			-- effects
			local sound_target = "DOTA_Item.Mekansm.Target"
			EmitSoundOn( sound_target, ally )



			heal_amount = self:GetSpecialValueFor("heal_amount")

			-- Add No Heal Debuff
			ally:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_item_mekansm_noheal", -- modifier name
			{ duration = noheal_duration } -- kv
			)
		end
	end

	-- effects
	local sound_cast = "DOTA_Item.Mekansm.Activate"
	EmitSoundOn( sound_cast, caster )

	-- Get Resources
	local particle_cast = "particles/items2_fx/mekanism.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )

end




---------------------------------------
--Active Modifier here

		modifier_mekansm_active = class({})
		local modifierAClass = modifier_mekansm_active
		LinkLuaModifier("modifier_mekansm_active", "items/mekansm_classic", LUA_MODIFIER_MOTION_NONE)

		function modifierAClass:IsHidden()
			return false
		end

		function modifierAClass:IsPurgable()
			return true
		end

		function modifierAClass:RemoveOnDeath()
    		return true
		end


		function modifierAClass:DeclareFunctions()
			local funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			}
			return funcs
		end

			function modifierAClass:GetModifierPhysicalArmorBonus()
				return self:GetAbility():GetSpecialValueFor("heal_armor")
			end




--------------------------------------------------------------------------------
-- Graphics & Animations
function modifierAClass:GetEffectName()
	return "particles/econ/events/ti7/mekanism_recipient_ti7.vpcf"
end

function modifierAClass:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end







-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" )

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	

	-- Extra references

	--Stuff for Visual
	--self:SetStackCount(1)
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
					return self.mana_reg
				end




--#########################
--## Aura Stuff starts here
--#########################

function buffModifierClass:OnCreated()

	--Common References
	self.aoe_reg = self:GetAbility():GetSpecialValueFor( "aura_health_regen" )
	self.aoe_armor = self:GetAbility():GetSpecialValueFor( "bonus_aoe_armor" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function buffModifierClass:GetModifierPhysicalArmorBonus()
	return self.aoe_armor
end

function buffModifierClass:GetModifierConstantHealthRegen()
	return self.aoe_reg
end
