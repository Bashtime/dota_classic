--Class Definitions

	item_greaves_classic = class({})
	local itemClass = item_greaves_classic

	--Active Bonuses Modifier
	modifier_greaves_active = class({})
	local modifierAClass = modifier_greaves_active
	local modifierAName = 'modifier_greaves_active'
	LinkLuaModifier(modifierAName, "items/greaves_classic", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_greaves = class({})
	local modifierClass = modifier_greaves
	local modifierName = 'modifier_greaves'
	LinkLuaModifier(modifierName, "items/greaves_classic", LUA_MODIFIER_MOTION_NONE)

	--Aura Bonuses Modifier
	modifier_greaves_aura = class({})
	local buffModifierClass = modifier_greaves_aura
	local buffModifierName = 'modifier_greaves_aura'
	LinkLuaModifier(buffModifierName, "items/greaves_classic", LUA_MODIFIER_MOTION_NONE)

	--Aura Modifier Bonus effect (for UI purposes)
	modifier_greaves_aura_bonus = class({})
	local auraBonusClass = modifier_greaves_aura_bonus
	local auraBonusName = 'modifier_greaves_aura_bonus'
	LinkLuaModifier(auraBonusName, "items/greaves_classic", LUA_MODIFIER_MOTION_NONE)

	function auraBonusClass:IsHidden()
		return true
	end



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
			return MODIFIER_ATTRIBUTE_NONE
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
				local radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
    			return radius
			end

			function modifierClass:GetModifierAura()
    			return buffModifierName
			end			




--Casting
function itemClass:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local radius = self:GetSpecialValueFor( "replenish_radius" )
	local active_mana = self:GetSpecialValueFor( "replenish_mana" )
	local heal_amount = self:GetSpecialValueFor("replenish_health")
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

		--Purge the caster; remove debuffs
		if ally == caster then caster:Purge(false, true, false, false, false) end

		-- KOTOL, GIVE ME MANA!
		ally:GiveMana(active_mana)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, ally, active_mana, nil)

		-- Add Active Armor Buff
			ally:AddNewModifier(
			caster, -- player source
			self, -- ability source
			modifierAName, -- modifier name
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

			heal_amount = self:GetSpecialValueFor("replenish_health")

			-- Add No Heal Debuff
			ally:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_item_mekansm_noheal", -- modifier name
			{ duration = noheal_duration } -- kv
			)
		end

		-- Get Resources
		local particle_cast = "particles/items_fx/arcane_boots_recipient.vpcf"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:ReleaseParticleIndex( effect_cast )
	end

	-- effects
	local sound_cast = "Item.GuardianGreaves.Activate"
	EmitSoundOn( sound_cast, caster )

	local particle_cast = "particles/items_fx/arcane_boots.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	particle_cast = "particles/items2_fx/mekanism.vpcf"
	effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end





		---------------------------------------
		--Active Modifier here

		modifier_greaves_active = class({})
		local modifierAClass = modifier_greaves_active
		LinkLuaModifier("modifier_greaves_active", "items/greaves_classic", LUA_MODIFIER_MOTION_NONE)

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
	self.bonus_dmg_range = self:GetAbility():GetSpecialValueFor( "bonus_dmg_range" )	
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.bonus_armor_range = self:GetAbility():GetSpecialValueFor( "bonus_armor_range" )
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
					local caster = self:GetParent()
					if caster:HasModifier("modifier_tranquil") then return 0 end
					if caster:HasModifier("modifier_item_boots_of_travel") then return 0 end
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
--## Aura modifier here
--#########################

function buffModifierClass:OnCreated()

	self.aoe_armor = self:GetAbility():GetSpecialValueFor( "aura_armor" )
	self.aoe_armor_bonus = self:GetAbility():GetSpecialValueFor( "aura_armor_bonus" )
	self.aoe_armor_normal = self.aoe_armor

	self.aoe_reg = self:GetAbility():GetSpecialValueFor( "aura_health_regen" )	
	self.aoe_reg_bonus = self:GetAbility():GetSpecialValueFor( "aura_health_regen_bonus" )
	self.aoe_reg_normal = self.aoe_reg
	
	self.threshold = self:GetAbility():GetSpecialValueFor( "aura_bonus_threshold" ) / 100

	local caster = self:GetParent()
	if caster:IsHero() then self:StartIntervalThink(0.2) end				
end

		function buffModifierClass:IsHidden()
			return false
		end

		function buffModifierClass:IsPurgable()
			return true
		end

		function buffModifierClass:RemoveOnDeath()
    		return true
		end


function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function buffModifierClass:OnIntervalThink()

	if IsClient() then return end
	local hero = self:GetParent()
	local hp_ratio = hero:GetHealth() / hero:GetMaxHealth()
		
	if hp_ratio <= self.threshold then 
		if not hero:HasModifier(auraBonusName) then
			hero:AddNewModifier(hero, self:GetAbility(), auraBonusName , { duration = -1})
		end
	else
		if hero:HasModifier(auraBonusName) then
			hero:RemoveModifierByName(auraBonusName)
		end
	end
end

function buffModifierClass:GetModifierPhysicalArmorBonus()
	if self:GetParent():HasModifier(auraBonusName) then return self.aoe_armor_bonus end
	return self.aoe_armor_normal
end

function buffModifierClass:GetModifierConstantHealthRegen()
	if self:GetParent():HasModifier(auraBonusName) then return self.aoe_reg_bonus end
	return self.aoe_reg
end


function buffModifierClass:OnDestroy()
	if self:GetParent():HasModifier(auraBonusName) then self:GetParent():RemoveModifierByName(auraBonusName) end
end




--#########################
--## Active Modifier here
--#########################

function modifierAClass:OnCreated()

	--Common References
	self.active_armor = self:GetAbility():GetSpecialValueFor( "heal_armor" )
end

function modifierAClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifierAClass:GetModifierPhysicalArmorBonus()
	return self.active_armor
end
