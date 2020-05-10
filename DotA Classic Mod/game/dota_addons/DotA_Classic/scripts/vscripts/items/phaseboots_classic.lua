--Class Definitions

	item_phaseboots_classic = class({})
	local itemClass = item_phaseboots_classic

	--Active Bonuses Modifier
	modifier_phase_active = class({})
	local buffModifierClass = modifier_phase_active
	local buffModifierName = 'modifier_phase_active'
	LinkLuaModifier(buffModifierName, "items/phaseboots_classic", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_phase = class({})
	local modifierClass = modifier_phase
	local modifierName = 'modifier_phase'
	LinkLuaModifier(modifierName, "items/phaseboots_classic", LUA_MODIFIER_MOTION_NONE)


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


--Casting
function itemClass:OnSpellStart()
	local dur = self:GetSpecialValueFor("phase_duration")
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, buffModifierName, { duration = dur })
end


function buffModifierClass:PlayEffects( caster )

		-- Get Resources
		local particle_cast = "particles/econ/events/ti6/phase_boots_ti6.vpcf"
		local sound_cast = "DOTA_Item.PhaseBoots.Activate"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		EmitSoundOn( sound_cast, caster )
end







--Change Ability Icon
function itemClass:GetAbilityTextureName()
	if self:GetCaster():IsRangedAttacker() then return "item_phase_range" end
	return "item_phase_boots"
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

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )

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
					if self:GetParent():IsRangedAttacker() then return self.bonus_dmg_range end
					return self.bonus_dmg
				end

				function modifierClass:GetModifierPhysicalArmorBonus()
					if self:GetParent():IsRangedAttacker() then return self.bonus_armor_range end
					return self.bonus_armor
				end

				function modifierClass:GetModifierMoveSpeedBonus_Constant()
					local caster = self:GetParent()
					if caster:HasModifier("modifier_tranquil") then return 0 end
					if caster:HasModifier("modifier_item_power_treads") then return 0 end
					if caster:HasModifier("modifier_item_boots_of_travel") then return 0 end
					if caster:HasModifier("modifier_mboots") then return 0 end
					if caster:HasModifier("modifier_greaves") then return 0 end
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
--## Active modifier here
--#########################

function buffModifierClass:OnCreated()
	--References
	local caster = self:GetParent()
	self.phase_ms = self:GetAbility():GetSpecialValueFor( "phase_ms" )
	self.phase_ms_range = self:GetAbility():GetSpecialValueFor( "phase_ms_range" )

	self.turn = self:GetAbility():GetSpecialValueFor( "bonus_turnrate" )
	self.turn_range = self:GetAbility():GetSpecialValueFor( "bonus_turnrate_range" )

		--effects
	self:PlayEffects( caster )

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
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_STATE_NO_UNIT_COLLISION,
	}
	return funcs
end

function buffModifierClass:GetModifierTurnRate_Percentage()
	if self:GetParent():IsRangedAttacker() then return self.turn_range end
	return self.turn
end

function buffModifierClass:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():IsRangedAttacker() then return self.phase_ms_range end
	return self.phase_ms
end

function buffModifierClass:CheckState()
	local state = {
				[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				}
	return state	
end




--Visuals

--------------------------------------------------------------------------------
-- Graphics & Animations
function buffModifierClass:GetEffectName()
	return "particles/econ/events/ti6/phase_boots_ti6.vpcf"
end

function buffModifierClass:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end