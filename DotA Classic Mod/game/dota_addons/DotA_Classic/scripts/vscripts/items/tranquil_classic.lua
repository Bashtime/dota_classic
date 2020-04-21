--Class Definitions

	item_tranquil_classic = class({})
	local itemClass = item_tranquil_classic

	--[[Boots Special
	local bootsModifierClass = modifier_boots
	local bootsModifierName = 'modifier_boots'
	LinkLuaModifier(bootsModifierName, "items/boots", LUA_MODIFIER_MOTION_NONE)]]


	--Active Bonuses Modifier
	modifier_tranquil_active = class({})
	local buffModifierClass = modifier_tranquil_active
	local buffModifierName = 'modifier_tranquil_active'
	LinkLuaModifier(buffModifierName, "items/tranquil_classic", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_tranquil = class({})
	local modifierClass = modifier_tranquil
	local modifierName = 'modifier_tranquil'
	LinkLuaModifier(modifierName, "items/tranquil_classic", LUA_MODIFIER_MOTION_NONE)


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
function modifierClass:OnAttackLanded( keys )

	if not IsServer() then return end
	local break_time = self:GetAbility():GetSpecialValueFor("break_time")
	local attacker = keys.attacker
	local target = keys.target
	local caster = self:GetParent()

	if attacker == caster then
		
		if target:IsHero() then
			attacker:AddNewModifier(caster, self:GetAbility(), buffModifierName, {duration = break_time})
			self:GetAbility():StartCooldown(break_time)
		end
	end


	if target == self:GetParent() then
		target:AddNewModifier(target, self:GetAbility(), buffModifierName, { duration = break_time })
		self:GetAbility():StartCooldown(break_time)
	end




end



--Change Ability Icon
function itemClass:GetAbilityTextureName()
	if self:GetCaster():HasModifier(buffModifierName) then return "item_tranquil_broken" end
	return "item_tranquil_boots"
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

	local caster = self:GetParent()
	--
	if caster:IsIllusion() then caster:AddNewModifier(caster, self:GetAbility(), buffModifierName, {duration = -1}) end

end



function modifierClass:OnDestroy()
	--local caster = self:GetParent()
	--caster:RemoveModifierByName(buffModifierName)	
end	

function modifierClass:OnRemoved()
	--local caster = self:GetParent()
	--caster:RemoveModifierByName(buffModifierName)	
end	
	



			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
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
					MODIFIER_EVENT_ON_ATTACK_LANDED,
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
					if caster:HasModifier("modifier_bot") then return 0 end
					if caster:HasModifier("modifier_botsii") then return 0 end
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
	self.minus_ms = -self:GetAbility():GetSpecialValueFor( "minus_ms" )
	self.minus_reg = -self:GetAbility():GetSpecialValueFor( "minus_reg" )
end

		function buffModifierClass:IsHidden()
			return true
		end

		function buffModifierClass:IsPurgable()
			return true
		end

		function buffModifierClass:RemoveOnDeath()
    		return true
		end


function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function buffModifierClass:GetModifierConstantHealthRegen()
	return self.minus_reg
end

function buffModifierClass:GetModifierMoveSpeedBonus_Constant()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_greaves") then return -25 end
	return self.minus_ms
end

