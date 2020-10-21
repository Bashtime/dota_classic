--Class Definitions

	item_ac = class({})
	local itemClass = item_ac

	--Aura Bonuses Modifier
	modifier_ac_aura = class({})
	local buffModifierClass = modifier_ac_aura
	local buffModifierName = 'modifier_ac_aura'
	LinkLuaModifier(buffModifierName, "items/ac", LUA_MODIFIER_MOTION_NONE)	

	--Aura Debuff Modifier
	modifier_ac_aura_neg = class({}) 
	local debuffModifierClass = modifier_ac_aura_neg
	local debuffModifierName = 'modifier_ac_aura_neg'
	LinkLuaModifier(debuffModifierName, "items/ac", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_ac = class({})
	local modifierClass = modifier_ac
	local modifierName = 'modifier_ac'
	LinkLuaModifier(modifierName, "items/ac", LUA_MODIFIER_MOTION_NONE)

	--Passive instrinsic Bonus Modifier
	modifier_ac2 = class({})
	local modifierClass2 = modifier_ac2
	local modifierName2 = 'modifier_ac2'
	LinkLuaModifier(modifierName2, "items/ac", LUA_MODIFIER_MOTION_NONE)






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
					return DOTA_UNIT_TARGET_ALL
				end

				function modifierClass:GetAuraSearchFlags()
    				return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
				end

			function modifierClass:GetAuraRadius()
				return self.radius
			end

			function modifierClass:GetModifierAura()
    			return buffModifierName
			end



------ Negative Aura Part

		--Usual Settings
		function modifierClass2:IsHidden()		return true 	end

		function modifierClass2:IsPurgable()	return false 	end

		function modifierClass2:RemoveOnDeath() return false 	end

		function modifierClass2:GetAttributes()	return MODIFIER_ATTRIBUTE_NONE	end


			--Optional Aura Settings
			function modifierClass2:IsAura()	return true 	end

			function modifierClass2:IsAuraActiveOnDeath() 	return false 	end

				--Who is affected ?
				function modifierClass2:GetAuraSearchTeam()
    				return DOTA_UNIT_TARGET_TEAM_ENEMY
				end

				function modifierClass2:GetAuraSearchType()
					return DOTA_UNIT_TARGET_ALL
				end

				function modifierClass2:GetAuraSearchFlags()
    				return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
				end

			function modifierClass2:GetAuraRadius()
				return self.radius
			end

			function modifierClass2:GetModifierAura()
    			return debuffModifierName
			end

function modifierClass2:OnCreated()
	-- common references (Worst Case: Some Nil-values)
	self.radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
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


	self.radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )

	-- Aura Visual 
	local particle_cast = "particles/aura_assault_classic.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

	if IsServer() then
		caster:AddNewModifier(caster, self:GetAbility(), modifierName2, { duration = -1})
	end	
end

function modifierClass:OnDestroy()
	local caster = self:GetParent()
	if IsServer() then
		caster:RemoveModifierByName(modifierName2)
	end
	ParticleManager:DestroyParticle(self.effect_cast, true)
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
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
	self.aoe_as = self:GetAbility():GetSpecialValueFor( "aura_as" )
	self.aoe_armor = self:GetAbility():GetSpecialValueFor( "aura_positive_armor" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function buffModifierClass:GetModifierPhysicalArmorBonus()
	return self.aoe_armor
end

function buffModifierClass:GetModifierAttackSpeedBonus_Constant()
	return self.aoe_as
end


--Enemy Aura2
function debuffModifierClass:OnCreated()
	--Common References
	self.aoe_armor = self:GetAbility():GetSpecialValueFor( "aura_negative_armor" )
end

function debuffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function debuffModifierClass:GetModifierPhysicalArmorBonus()
	return self.aoe_armor
end
