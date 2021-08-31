--Class Definitions

	item_headdress_classic = class({})
	local itemClass = item_headdress_classic

	--Aura Bonuses Modifier
	modifier_headdress_aura = class({})
	local buffModifierClass = modifier_headdress_aura
	local buffModifierName = 'modifier_headdress_aura'
	LinkLuaModifier(buffModifierName, "items/headdress_classic", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_headdress_classic = class({})
	local modifierClass = modifier_headdress_classic
	local modifierName = 'modifier_headdress_classic'
	LinkLuaModifier(modifierName, "items/headdress_classic", LUA_MODIFIER_MOTION_NONE)


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

-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

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
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function buffModifierClass:GetModifierConstantHealthRegen()
	return self.aoe_reg
end
