--Class Definitions

	item_pt_classic = class({})
	local itemClass = item_pt_classic

	--Counter
	modifier_pt_counter = class({})
	local stacksClass = modifier_pt_counter
	local stacksName = 'modifier_pt_counter'
	LinkLuaModifier(stacksName, "items/pt_classic", LUA_MODIFIER_MOTION_NONE)


	--Counter not enough: 3 different modifiers 
	modifier_str_boots = class({})
	local strClass = modifier_str_boots
	local strName = 'modifier_str_boots'
	LinkLuaModifier(strName, "items/pt_classic", LUA_MODIFIER_MOTION_NONE)	

		function strClass:IsHidden()
			return true
		end

	modifier_agi_boots = class({})
	local agiClass = modifier_agi_boots
	local agiName = 'modifier_agi_boots'
	LinkLuaModifier(agiName, "items/pt_classic", LUA_MODIFIER_MOTION_NONE)	

		function agiClass:IsHidden()
			return true
		end

	modifier_int_boots = class({})
	local intClass = modifier_int_boots
	local intName = 'modifier_int_boots'
	LinkLuaModifier(intName, "items/pt_classic", LUA_MODIFIER_MOTION_NONE)	

		function intClass:IsHidden()
			return true
		end

	--Passive instrinsic Bonus Modifier
	modifier_pt = class({})
	local modifierClass = modifier_pt
	local modifierName = 'modifier_pt'
	LinkLuaModifier(modifierName, "items/pt_classic", LUA_MODIFIER_MOTION_NONE)


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



		function stacksClass:IsHidden()
			return true
		end



--Change Ability Icon
function itemClass:GetAbilityTextureName()

	local caster = self:GetCaster()

	if caster:HasModifier(stacksName) then 
		local k = caster:GetModifierStackCount(stacksName, caster)

		if k == 0 then return "item_power_treads_str" end
		if k == 1 then return "item_power_treads_agi" end
		if k == 2 then return "item_power_treads_int" end
	end
	
	return "item_power_treads"
end




function itemClass:OnToggle()

	local caster = self:GetCaster()
	local k = caster:GetModifierStackCount(stacksName, caster)
	k = (k+2) % 3

	caster:SetModifierStackCount(stacksName, caster, k)

	if k == 0 then 
		caster:AddNewModifier(caster, self, strName, {duration=-1}) 
		if caster:HasModifier(agiName) then caster:RemoveModifierByName(agiName) end
	end


	if k == 1 then 
		caster:AddNewModifier(caster, self, agiName, {duration=-1}) 
		if caster:HasModifier(intName) then caster:RemoveModifierByName(intName) end
	end


	if k == 2 then 
		caster:AddNewModifier(caster, self, intName, {duration=-1}) 
		if caster:HasModifier(strName) then caster:RemoveModifierByName(strName) end
	end

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

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "selected_att" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "selected_att" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "selected_att" )
	self.selected = self:GetAbility():GetSpecialValueFor( "selected_att" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	

	local caster = self:GetParent()

	if IsServer() then

	if ( caster:IsHero() and (not caster:IsIllusion()) ) then 
		
		local att = caster:GetPrimaryAttribute() 

		if not caster:HasModifier(stacksName) then
			caster:AddNewModifier(caster, self:GetAbility(), stacksName, {duration = -1}) 
			caster:SetModifierStackCount(stacksName, caster, att) 
		end

		self.i = caster:GetModifierStackCount(stacksName, caster)
	end

	if caster:IsIllusion() then 
		local owner = caster:GetPlayerOwner()
		local hero = owner:GetAssignedHero()
		self.i = caster:GetModifierStackCount(stacksName, hero) 

		caster:AddNewModifier(caster, self:GetAbility(), stacksName, {duration = -1}) 
		caster:SetModifierStackCount(stacksName, caster, self.i)	
	end

	if self.i == 0 then caster:AddNewModifier(caster, self, strName, {duration = -1}) end
	if self.i == 1 then caster:AddNewModifier(caster, self, agiName, {duration = -1}) end
	if self.i == 2 then caster:AddNewModifier(caster, self, intName, {duration = -1}) end

	end
end


function modifierClass:OnDestroy()

end	

function modifierClass:OnRemoved()

end	
	
			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT_POWER_TREADS,
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
					return self.bonus_dmg
				end

				function modifierClass:GetModifierPhysicalArmorBonus()
					return self.bonus_armor
				end

				function modifierClass:GetModifierMoveSpeedBonus_Constant()
					local caster = self:GetParent()
					if caster:HasModifier("modifier_bot") then return 0 end
					if caster:HasModifier("modifier_botsii") then return 0 end
					if caster:HasModifier("modifier_tranquil") then return 0 end
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
					if self:GetParent():HasModifier(strName) then return self.bonus_str end
				end

				function modifierClass:GetModifierBonusStats_Agility()
					if self:GetParent():HasModifier(agiName) then return self.bonus_agi end
				end

				function modifierClass:GetModifierBonusStats_Intellect()
					if self:GetParent():HasModifier(intName) then return self.bonus_int end
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
