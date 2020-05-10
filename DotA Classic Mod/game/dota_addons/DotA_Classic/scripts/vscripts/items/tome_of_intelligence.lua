--Class Definitions

	item_tome_of_intelligence = class({})
	local itemClass = item_tome_of_intelligence

	--Passive Bonus Modifier
	modifier_tome_int = class({})
	local modifierClass = modifier_tome_int
	local modifierName = 'modifier_tome_int'
	LinkLuaModifier(modifierName, "items/tome_of_intelligence", LUA_MODIFIER_MOTION_NONE)

	--Passive Bonus Modifier
	modifier_update_int = class({})
	local updateModClass = modifier_update_int
	local updateModName = 'modifier_update_int'
	LinkLuaModifier(updateModName, "items/tome_of_intelligence", LUA_MODIFIER_MOTION_NONE)

	function updateModClass:GetTexture()
		return "item_book_of_intelligence"
	end

	function updateModClass:IsHidden()
		return false
	end

	function updateModClass:OnCreated()
				
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

	local caster = self:GetCaster()
	local int_per_use = self:GetSpecialValueFor("int_per_use")

	caster:AddNewModifier(caster, self, modifierName, { duration = -1})

	--Tooltip Cosmetic
	if not caster:HasModifier(updateModName) then 
		caster:AddNewModifier(caster, self, updateModName, { duration = -1, int = int_per_use})
		caster:SetModifierStackCount(updateModName, caster, 1)
	else
		local k = caster:GetModifierStackCount(updateModName, caster)
		caster:SetModifierStackCount(updateModName, caster, k + 1)
	end

	-- effects
	local sound_cast = "DOTA_Item.TomeOfKnowledge"
	EmitSoundOn( sound_cast, caster )

	--Remove Item from Inventory or decrease charges
	local charges = self:GetCurrentCharges()
	if charges == 1 then 
		caster:RemoveItem(self)
		return
	end

	self:SetCurrentCharges(charges -1)
end




-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	local caster = self:GetParent() 

	-- common references (Worst Case: Some Nil-values)
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "int_per_use" )

end


--[[function modifierClass:OnIntervalThink()

	if IsServer() then
		local caster = self:GetParent() 
		local update_str = self:GetStackCount()

		if self.bonus_str ~= update_str then
			self.bonus_str = update_str
		end 
	end

end]]











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
					--[[local caster = self:GetParent()
					k = self:GetStackCount() * ]]
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



