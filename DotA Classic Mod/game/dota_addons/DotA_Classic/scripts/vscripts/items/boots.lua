--Class Definitions

	item_boots_old = class({})
	local itemClass = item_boots_old

	--Passive instrinsic Bonus Modifier
	modifier_boots = class({})
	local modifierClass = modifier_boots
	local modifierName = 'modifier_boots'
	LinkLuaModifier(modifierName, "items/boots", LUA_MODIFIER_MOTION_NONE)

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


-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE ,

				}

				return funcs
			end

			function modifierClass:GetModifierMoveSpeedBonus_Special_Boots()
					--Useless now 
					--[[
					local caster = self:GetParent()
					if caster:HasModifier("modifier_tranquil") then return 0 end
					if caster:HasModifier("modifier_phase") then return 0 end
					if caster:HasModifier("modifier_item_power_treads") then return 0 end
					if caster:HasModifier("modifier_item_boots_of_travel") then return 0 end
					if caster:HasModifier("modifier_mboots") then return 0 end
					if caster:HasModifier("modifier_greaves") then return 0 end
					if caster:HasModifier("modifier_treads_of_ermacor") then return 0 end
					if caster:HasModifier("modifier_spider_legs_classic") then return 0 end
					]]
					return self.bonus_ms
			end		