modifier_courier_hp_armor = modifier_courier_hp_armor or class({})

function modifier_courier_hp_armor:IsHidden() return false end
function modifier_courier_hp_armor:IsPurgable() return false end
function modifier_courier_hp_armor:IsPurgeException() return false end
function modifier_courier_hp_armor:RemoveOnDeath() return false end

function modifier_courier_hp_armor:DeclareFunctions() return {
	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
} end

function modifier_courier_hp_armor:OnCreated()
	self.hp_bonus = 10
	self.armor = 15
end

function modifier_courier_hp_armor:OnIntervalThink()
	
end

function modifier_courier_hp_armor:GetModifierExtraHealthBonus()
	--local current_minutes = math.floor(GameRules:GetDOTATime(false, false) / 60)
	return self.hp_bonus
end

function modifier_courier_hp_armor:GetModifierPhysicalArmorBonus()
		return self.armor
end

--LinkLuaModifier("modifier_courier_hp_armor", "components/modifiers/couriers/modifier_courier_passive_bonus_688", LUA_MODIFIER_MOTION_NONE)