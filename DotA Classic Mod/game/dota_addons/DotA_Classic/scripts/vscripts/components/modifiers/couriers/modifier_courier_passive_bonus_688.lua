modifier_courier_passive_bonus_688 = modifier_courier_passive_bonus_688 or class({})

function modifier_courier_passive_bonus_688:IsHidden() return true end
function modifier_courier_passive_bonus_688:IsPurgable() return false end
function modifier_courier_passive_bonus_688:IsPurgeException() return false end
function modifier_courier_passive_bonus_688:RemoveOnDeath() return false end

function modifier_courier_passive_bonus_688:CheckState()
	local states = {}

	if self:GetStackCount() >= 1 then
		states[MODIFIER_STATE_FLYING] = true
	end

	return states
end

function modifier_courier_passive_bonus_688:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	MODIFIER_PROPERTY_HEALTH_BONUS,
	MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
--	MODIFIER_PROPERTY_MODEL_CHANGE,
} end

function modifier_courier_passive_bonus_688:OnCreated()
	self.base_movespeed = 230
	self.bonus_movespeed_per_min = 15
	self.max_movespeed = 425
	self.hp_bonus = 80

	self.interval = {}
	self.interval[0] = 210 -- 3:30 (Flying Courier)
	self.interval[1] = 420 -- 7:00 (Speed Courier)
	self.interval[2] = 720 -- 12:00 (Shield Courier)

	if not IsServer() then return end

	self.base_model = self:GetParent():GetModelName()
	self:GetParent():SetBaseMoveSpeed(self.base_movespeed)
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_courier_bottle_slow", {})
	self:StartIntervalThink(self.interval[self:GetStackCount()])
end

function modifier_courier_passive_bonus_688:OnIntervalThink()
	self:SetStackCount(self:GetStackCount() + 1)

	if self:GetStackCount() == 1 then
		print("Flying Courier!")
		self:GetParent():SetModel("models/props_gameplay/donkey_wings.vmdl")
		self:GetParent():SetOriginalModel("models/props_gameplay/donkey_wings.vmdl")
		self:GetParent():SetHealth(110)
	end

	if self:GetStackCount() == 2 then
		print("Burst Courier!")
		if self:GetParent():FindAbilityByName("courier_burst") then
			self:GetParent():FindAbilityByName("courier_burst"):SetLevel(1)
		end
	end

	if self:GetStackCount() == 3 then
		print("Shield Courier!")
		if self:GetParent():FindAbilityByName("courier_shield") then
			self:GetParent():FindAbilityByName("courier_shield"):SetLevel(1)
		end
	end

	if self.interval[self:GetStackCount()] then
		self:StartIntervalThink(self.interval[self:GetStackCount()] - self.interval[self:GetStackCount() - 1])
	else
		self:StartIntervalThink(-1)
	end
end

function modifier_courier_passive_bonus_688:GetModifierMoveSpeedBonus_Constant()
	local current_minutes = math.floor(GameRules:GetDOTATime(false, false) / 60)
	local new_speed = math.min(self.bonus_movespeed_per_min * (current_minutes - 0), self.max_movespeed - self.base_movespeed)

	return new_speed
end

function modifier_courier_passive_bonus_688:GetModifierHealthBonus()
	if self:GetStackCount() >= 1 then
		print("Bonus HP")
		return self.hp_bonus
	end

	return 0
end

function modifier_courier_passive_bonus_688:GetVisualZDelta()
	if self:GetStackCount() >= 1 then
		return 260
	end

	return 0
end

function modifier_courier_passive_bonus_688:GetModifierIgnoreMovespeedLimit()
	if self:GetParent():HasModifier("modifier_courier_burst") then
		print("true")
		return 1

	end

	return 0
end


LinkLuaModifier("modifier_courier_bottle_slow", "components/modifiers/couriers/modifier_courier_passive_bonus_688", LUA_MODIFIER_MOTION_NONE)

modifier_courier_bottle_slow = modifier_courier_bottle_slow or class({})

function modifier_courier_bottle_slow:IsHidden() return true end
function modifier_courier_bottle_slow:IsPurgable() return false end
function modifier_courier_bottle_slow:IsPurgeException() return false end
function modifier_courier_bottle_slow:RemoveOnDeath() return false end

function modifier_courier_bottle_slow:DeclareFunctions() return {
	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
} end

function modifier_courier_bottle_slow:OnInventoryContentsChanged()
	if not IsServer() then return end

	if self:GetParent():HasItemInInventory("item_bottle") then
		print("Carrying bottle!")
		self:SetStackCount(self:GetParent():FindItemInInventory("item_bottle"):GetCurrentCharges())
		print("Charges:", self:GetStackCount())
	end
end

function modifier_courier_bottle_slow:GetModifierMoveSpeedBonus_Percentage()
	if self:GetStackCount() > 0 then
		return 0 --(self:GetStackCount() * (100 / 3)) * (-1)
	end

	return 0
end

function modifier_courier_bottle_slow:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.3)
end

--Bottle Refill Mechanic
function modifier_courier_bottle_slow:OnIntervalThink()
	if self:GetParent():HasItemInInventory("item_bottle") and self:GetParent():HasModifier("modifier_fountain_aura_buff") then
		for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
          
          local item = self:GetParent():GetItemInSlot(i)

          if item then
          --Only add charges to the first Locket
            if (item:GetName() == "item_bottle") then
              local k = item:GetCurrentCharges()

              if k<3 then
                item:SetCurrentCharges(3)
              end
            end
          end
        end
	end

	self:StartIntervalThink(0.3)
end	

