item_echo_sabre_classic = class({})
local itemClass = item_echo_sabre_classic

modifier_echo_sabre_classic = class({})
local modifierClass = modifier_echo_sabre_classic
local modifierName = 'modifier_echo_sabre_classic'
LinkLuaModifier(modifierName, "items/echo_sabre_classic", LUA_MODIFIER_MOTION_NONE)

modifier_echo_sabre_slow = modifier_echo_sabre_slow or class({})
local debuffModifierClass = modifier_echo_sabre_slow
local debuffModifierName = 'modifier_echo_sabre_slow'
LinkLuaModifier(debuffModifierName, "items/echo_sabre_classic", LUA_MODIFIER_MOTION_NONE)

function itemClass:GetIntrinsicModifierName()
	return modifierName
end

--------------------------------------------------------------------------------
-- Classifications
function modifierClass:IsHidden() return true end
function modifierClass:IsPurgable() return false end
function modifierClass:IsPurgeException() return false end
function modifierClass:IsStunDebuff() return false end
function modifierClass:RemoveOnDeath() return false end

--------------------------------------------------------------------------------
-- Initializations
function modifierClass:OnCreated( kv )
	-- references
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" ) -- special value
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.max_hits = self:GetAbility():GetSpecialValueFor( "max_hits" )
	self.as_buff = 0
	self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	self.buff_apply = true
	
	self:StartIntervalThink(0.12)
end

function modifierClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifierClass:OnIntervalThink()
-- Runs when the think interval occurs.
if IsServer() then
	local parent = self:GetParent()
	-- Change item if hero becomes melee or ranged
	if parent:IsRangedAttacker() and self:GetAbility():GetAbilityName() == "item_echo_sabre_classic" then
		local item = self:GetAbility()
		local current_cd = item:GetCooldownTime()
		local abuse_prevention = 0.05
		local oldItemSlot = item:GetItemSlot()	

			parent:RemoveItem(item)
			local new_item = CreateItem("item_reverb_rapier_classic", parent, parent)
			parent:AddItem(new_item)	  
			new_item:StartCooldown(math.max(current_cd,abuse_prevention)) 
			local newItemSlot = new_item:GetItemSlot()
			if newItemSlot ~= oldItemSlot then parent:SwapItems( newItemSlot, oldItemSlot ) end

		return
	end

	if not parent:IsRangedAttacker() and self:GetAbility():GetAbilityName() == "item_reverb_rapier_classic" then
		local item = self:GetAbility()
		local current_cd = item:GetCooldownTime()
		local abuse_prevention = 0.05
		local oldItemSlot = item:GetItemSlot()	

			parent:RemoveItem(item)
			local new_item = CreateItem("item_echo_sabre_classic", parent, parent)
			parent:AddItem(new_item)	  
			new_item:StartCooldown(math.max(current_cd,abuse_prevention)) 
			local newItemSlot = new_item:GetItemSlot()
			if newItemSlot ~= oldItemSlot then parent:SwapItems( newItemSlot, oldItemSlot ) end
		
		return
	end
end	
end




--------------------------------------------------------------------------------
-- Modifier Effects
function modifierClass:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end


function modifierClass:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end


function modifierClass:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end

function modifierClass:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as + self.as_buff
end

function modifierClass:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifierClass:GetModifierBonusStats_Strength()
	return self.bonus_str
end

--[[
function modifierClass:OnAbilityExecuted(keys)
	if IsServer() then
		-- Change item if hero becomes melee or ranged
		if keys.unit == self:GetParent() then
			Timers:CreateTimer(0.4, function()
			if keys.unit:IsRangedAttacker() and self:GetAbility():GetAbilityName() == "item_echo_sabre_classic" then
				local item = self:GetAbility()
				local current_cd = item:GetCooldownTime()
				local abuse_prevention = 0.1

				Timers:CreateTimer(2*FrameTime(), function()
					keys.unit:RemoveItem(item)
					local new_item = CreateItem("item_reverb_rapier_classic", keys.unit, keys.unit)
					keys.unit:AddItem(new_item)	  
					new_item:StartCooldown(math.max(current_cd,abuse_prevention))
					
				end)
				return
			end

			if not keys.unit:IsRangedAttacker() and self:GetAbility():GetAbilityName() == "item_reverb_rapier_classic" then
				local item = self:GetAbility()
				local current_cd = item:GetCooldownTime()
				local abuse_prevention = 0.1

				Timers:CreateTimer(2*FrameTime(), function()
					keys.unit:RemoveItem(item)
					local new_item = CreateItem("item_echo_sabre_classic", keys.unit, keys.unit)
					keys.unit:AddItem(new_item)	  
					new_item:StartCooldown(math.max(current_cd,abuse_prevention))
				end)
			end
			end)
		end
	end	
end
]]


function modifierClass:OnAttack(keys)
	if IsServer() then
		if self:GetParent() == keys.attacker then 
			local item = self:GetAbility()
			if item:IsCooldownReady() then
				self.buff_apply = true
				self.window = self:GetParent():GetBaseAttackTime() / 6 + 0.1
				--print(self.window)
				Timers:CreateTimer(self.window, function()
					self.buff_apply = false
				end)
				self:SetStackCount(self.max_hits)
				item:StartCooldown(item:GetEffectiveCooldown(item:GetLevel()))
				self.as_buff = self:GetAbility():GetSpecialValueFor("as_buff")

				if not (keys.attacker:IsRangedAttacker() or keys.target:IsBuilding() or keys.target:IsMagicImmune()) then
					keys.target:AddNewModifier(self:GetParent(), item, debuffModifierName, {duration = self.slow_duration * (1 - keys.target:GetStatusResistance())})
				end
			end


			if self.buff_apply and not (keys.attacker:IsRangedAttacker() or keys.target:IsBuilding() or keys.target:IsMagicImmune()) then
				keys.target:AddNewModifier(self:GetParent(), item, debuffModifierName, {duration = self.slow_duration * (1 - keys.target:GetStatusResistance())})
			end
			

			local charges = self:GetStackCount()
			if charges > 0 then 
				self.as_buff = self:GetAbility():GetSpecialValueFor("as_buff")
				self:SetStackCount(charges-1) 
			else
				self.as_buff = 0
			end
		end
	end
end

--------------------
--- DEBUFF HERE

function debuffModifierClass:IsDebuff() return true end
function debuffModifierClass:IsHidden() return false end
function debuffModifierClass:IsPurgable() return true end
function debuffModifierClass:GetAttributes() return MODIFIER_ATTRIBUTE_NONE end

-------------------------------------------
function debuffModifierClass:OnCreated()
	--if IsServer() then
		local item = self:GetAbility()
		if not item then self:Destroy() end
		self.as_slow = item:GetSpecialValueFor("attack_speed_slow") * (-1)
		self.ms_slow = item:GetSpecialValueFor("movement_slow") * (-1)
	--end
end

function debuffModifierClass:OnRefresh()
	self:OnCreated()
end

function debuffModifierClass:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function debuffModifierClass:GetModifierAttackSpeedBonus_Constant()
	return self.as_slow
end

function debuffModifierClass:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

--- SAME STUFF FOR REVERB RAPIER
item_reverb_rapier_classic = item_reverb_rapier_classic or class({})

function item_reverb_rapier_classic:GetIntrinsicModifierName()
	return modifierName
end
