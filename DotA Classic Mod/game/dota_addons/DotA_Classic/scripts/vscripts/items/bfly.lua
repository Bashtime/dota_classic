
	item_bfly = class({})
	local itemClass = item_bfly

	--Active Bonuses Modifier
	modifier_bfly_active = class({})
	local buffModifierClass = modifier_bfly_active
	local buffModifierName = 'modifier_bfly_active'
	LinkLuaModifier(buffModifierName, "items/bfly", LUA_MODIFIER_MOTION_NONE)	


	--Passive instrinsic Bonus Modifier
	modifier_bfly = class({})
	local modifierClass = modifier_bfly
	local modifierName = 'modifier_bfly'
	LinkLuaModifier(modifierName, "items/bfly", LUA_MODIFIER_MOTION_NONE)


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


--Casting
function itemClass:OnSpellStart()
	local dur = self:GetSpecialValueFor("flutter_duration")
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, buffModifierName, { duration = dur })
end


function buffModifierClass:PlayEffects( caster )

		-- Get Resources
		local particle_cast = "particles/econ/events/ti8/phase_boots_ti8.vpcf"
		local sound_cast = "DOTA_Item.Butterfly"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, caster )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		EmitSoundOn( sound_cast, caster )
end

--Visuals

--------------------------------------------------------------------------------
-- Graphics & Animations
function buffModifierClass:GetEffectName()
	return "particles/econ/events/ti8/phase_boots_ti8.vpcf"
end

function buffModifierClass:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
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

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "fixed_health_regen" )
	self.hp_reg_perc = self:GetAbility():GetSpecialValueFor( "health_regen_rate" )
	self.hp_reg_amp = self:GetAbility():GetSpecialValueFor( "hp_regen_amp" )	
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )

	self.evasion = self:GetAbility():GetSpecialValueFor( "bonus_evasion" )
end




			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					--MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
					--MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

					MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

					MODIFIER_PROPERTY_HEALTH_BONUS,
					MODIFIER_PROPERTY_MANA_BONUS,
					MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
					MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,					
					MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

					--Add more stuff below
					MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
					MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
					MODIFIER_EVENT_ON_TAKEDAMAGE,
					MODIFIER_PROPERTY_EVASION_CONSTANT,
				}

				return funcs
			end

			function modifierClass:GetModifierEvasion_Constant()
				local caster = self:GetParent()
				if caster:HasModifier(buffModifierName) then return end			
				return self.evasion
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

				function modifierClass:GetModifierHealthRegenPercentage()
					local k = self:GetStackCount()
					if k == 0 then
						return self.hp_reg_perc
					end
					return
				end				


--#########################
--## Active modifier here
--#########################

function buffModifierClass:OnCreated()
	--References
	local caster = self:GetParent()
	self.phase_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )

		--effects
	self:PlayEffects( caster )
end

		function buffModifierClass:IsHidden()
			return false
		end

		function buffModifierClass:IsPurgable()
			return false
		end

		function buffModifierClass:RemoveOnDeath()
    		return true
		end


function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function buffModifierClass:GetModifierMoveSpeedBonus_Percentage()
	return self.phase_ms
end

