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
	MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
--	MODIFIER_PROPERTY_MODEL_CHANGE,
} end

function modifier_courier_passive_bonus_688:OnCreated()
	self.base_movespeed = 230
	self.bonus_movespeed_per_min = 15
	self.max_movespeed = 425
	self.hp_bonus = 100

	self.interval = {}
	self.interval[0] = 210 -- 3:30 (Flying Courier)
	self.interval[1] = 420 -- 7:00 (Speed Courier)
	self.interval[2] = 720 -- 12:00 (Shield Courier)

	if not IsServer() then return end

	self.base_model = self:GetParent():GetModelName()
	self:GetParent():SetBaseMoveSpeed(self.base_movespeed)
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_courier_bottle_slow", {})
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_courier_passive_bonus_health_688", {})
	self:StartIntervalThink(self.interval[self:GetStackCount()])
end

function modifier_courier_passive_bonus_688:OnIntervalThink()
	self:SetStackCount(self:GetStackCount() + 1)

	if self:GetStackCount() == 1 then
		print("Flying Courier!")
		self:GetParent():SetModel("models/props_gameplay/donkey_wings.vmdl")
		self:GetParent():SetOriginalModel("models/props_gameplay/donkey_wings.vmdl")
		self:GetParent():SetBaseMaxHealth(100)
		self.hp_bonus = 25
	end

	if self:GetStackCount() == 2 then
		print("Burst Courier!")
		self.hp_bonus = 50
		self:GetParent():SetBaseMaxHealth(125)
		if self:GetParent():FindAbilityByName("courier_burst") then
			self:GetParent():FindAbilityByName("courier_burst"):SetLevel(1)
		end
	end

	if self:GetStackCount() == 3 then
		print("Shield Courier!")
		self:GetParent():SetBaseMaxHealth(150)
		self.hp_bonus = 75
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


function modifier_courier_passive_bonus_688:GetVisualZDelta()
	if self:GetStackCount() >= 1 then
		return 260
	end

	return 0
end

function modifier_courier_passive_bonus_688:GetModifierIgnoreMovespeedLimit()
	if self:GetParent():HasModifier("modifier_courier_burst") then
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

function modifier_courier_bottle_slow:GetModifierExtraHealthBonus() return self.hp_bonus end

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

LinkLuaModifier("modifier_courier_passive_bonus_health_688", "components/modifiers/couriers/modifier_courier_passive_bonus_688", LUA_MODIFIER_MOTION_NONE)

modifier_courier_passive_bonus_health_688 = modifier_courier_passive_bonus_health_688 or class({})

function modifier_courier_passive_bonus_health_688:IsHidden() return not IsInToolsMode() end
function modifier_courier_passive_bonus_health_688:IsPurgable() return false end
function modifier_courier_passive_bonus_health_688:IsPurgeException() return false end
function modifier_courier_passive_bonus_health_688:RemoveOnDeath() return false end

function modifier_courier_passive_bonus_health_688:OnCreated()
	if not IsServer() then return end

	self.game_started = false
	self.tick_time = 60.0
	self.health_bonus = 10

	local current_time = GameRules:GetDOTATime(false, false)
	local minutes = math.floor(current_time / self.tick_time)
	local delay = current_time - (self.tick_time * minutes)

	print(60.0 - delay)

	self:StartIntervalThink(60 - delay)
end

function modifier_courier_passive_bonus_health_688:OnIntervalThink()
	print("Tick now!")

	if self.game_started == false then
		self.game_started = true
		self:StartIntervalThink(self.tick_time)
	end

	local new_health = self:GetParent():GetMaxHealth() + self.health_bonus
	self:GetParent():SetCreatureHealth(new_health, true)
end
