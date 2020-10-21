
	item_hot = class({})
	local itemClass = item_hot

	--Passive instrinsic Bonus Modifier
	modifier_hot = class({})
	local modifierClass = modifier_hot
	local modifierName = 'modifier_hot'
	LinkLuaModifier(modifierName, "items/hot", LUA_MODIFIER_MOTION_NONE)


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
	self:StartIntervalThink(0.08)	
end


function modifierClass:OnIntervalThink()
	local cd = self:GetAbility():GetCooldownTime()
	if cd == 0 then self:SetStackCount(0) end
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
					MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,					
					MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

					--Add more stuff below
					MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
					MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
					MODIFIER_EVENT_ON_TAKEDAMAGE,
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

				function modifierClass:GetModifierHealthRegenPercentage()
					local k = self:GetStackCount()
					if k == 0 then
						return self.hp_reg_perc
					end
					return
				end				

--[[function modifierClass:GetModifierHPRegenAmplify_Percentage()
	return self.hp_regen_amp
end

	function modifierClass:GetModifierHealAmplify_PercentageTarget()
	-- Amplifies heals your unit receives as a target from healing spells
	return self.hp_regen_amp
end]]


function modifierClass:OnTakeDamage( params )
	if IsServer() then
		
		local victim = self:GetParent()

		if params.unit == victim 
			and (params.attacker:IsHero() or params.attacker:GetUnitName() == "npc_dota_roshan")
		then
			if victim:IsRangedAttacker() then
				self:GetAbility():StartCooldown(7)
			else
				self:GetAbility():StartCooldown(5)
			end

			local k = self:GetStackCount()
			if k == 0 then self:SetStackCount(1) end
		end
	end
end
