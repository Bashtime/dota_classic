item_holy_locket_classic = class({})

LinkLuaModifier("modifier_holy_locket_classic_passive","items/holy_locket_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_regenlifesteal_increase","items/holy_locket_classic", LUA_MODIFIER_MOTION_NONE)

function item_holy_locket_classic:GetIntrinsicModifierName()
	return "modifier_holy_locket_classic_passive"
end

function item_holy_locket_classic:OnCreated()

	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_regenlifesteal_increase", {duration = -1})	
	
end


function item_holy_locket_classic:OnRefresh()

	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_regenlifesteal_increase", {duration = -1})	
	
end




function item_holy_locket_classic:OnDestroy()

	if IsServer() then
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_regenlifesteal_increase")
	end

end

function item_holy_locket_classic:OnRemoved()

	if IsServer() then
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_regenlifesteal_increase")
	end

end




---------------------------------------
---------------------------------------
-- Magic Wand Logic



function item_holy_locket_classic:OnSpellStart(keys)

end









---------------------------------------
---------------------------------------
-- Locket Non-Stackable Bonuses


modifier_regenlifesteal_increase = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_regenlifesteal_increase:IsHidden()
	return true
end

function modifier_regenlifesteal_increase:IsPurgable()
	return false
end

function modifier_regenlifesteal_increase:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_regenlifesteal_increase:OnCreated( kv )

	-- references 
	self.regenlifesteal_increase = self:GetAbility():GetSpecialValueFor( "regen_and_lifesteal_increase" )
	self.heal_increase = self:GetAbility():GetSpecialValueFor( "heal_increase" ) 

end


function modifier_regenlifesteal_increase:OnRemoved()

end


function modifier_regenlifesteal_increase:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_regenlifesteal_increase:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,

	}

	return funcs
end


function modifier_regenlifesteal_increase:GetModifierLifestealRegenAmplify_Percentage()
	--return self.regenlifesteal_increase
	return 0
end

function modifier_regenlifesteal_increase:GetModifierHPRegenAmplify_Percentage()
	return self.regenlifesteal_increase
end

function modifier_regenlifesteal_increase:GetModifierHealAmplify_PercentageSource()

	--Amplifies heals your unit provides as a source
	return self.heal_increase
end

function modifier_regenlifesteal_increase:GetModifierHealAmplify_PercentageTarget()

	-- Amplifies heals your unit receives as a target from healing spells
	--return self.heal_increase
	return 0
end







---------------------------------------------------------------
------ Stackable passive item bonuses

-- Locket Bonuses Modifier
modifier_holy_locket_classic_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_holy_locket_classic_passive:IsHidden()
	return true
end

function modifier_holy_locket_classic_passive:IsPurgable()
	return false
end

function modifier_holy_locket_classic_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_holy_locket_classic_passive:OnCreated( kv )

	-- references
	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_health" ) 
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" ) 
	self.heal_increase = self:GetAbility():GetSpecialValueFor( "heal_increase" ) 
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) 
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" ) 
	self.status_increase = self:GetAbility():GetSpecialValueFor( "status_resistance_increase" ) 
	self.bonus_regen = self:GetAbility():GetSpecialValueFor( "health_regen" ) 

	if IsServer() then
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_regenlifesteal_increase", {duration = -1})	
	end

end

function modifier_holy_locket_classic_passive:OnRefresh( kv )

	-- references
	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_health" ) 
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" ) 
	self.heal_increase = self:GetAbility():GetSpecialValueFor( "heal_increase" ) 
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) 
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" ) 
	self.status_increase = self:GetAbility():GetSpecialValueFor( "status_resistance_increase" ) 
	self.bonus_regen = self:GetAbility():GetSpecialValueFor( "health_regen" ) 

	if IsServer() then
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_regenlifesteal_increase", {duration = -1})	
	end

end


function modifier_holy_locket_classic_passive:OnDestroy( kv )

	if IsServer() then
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_regenlifesteal_increase")
	end
end


function modifier_holy_locket_classic_passive:OnRemoved( kv )

	if IsServer() then
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_regenlifesteal_increase")
	end
end


function modifier_holy_locket_classic_passive:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,

	}

	return funcs
end

--------------------------------------------------------------------------------
-- Modifier Effects

function modifier_holy_locket_classic_passive:GetModifierBonusStats_Agility()
	return self.bonus_all_stats
end

function modifier_holy_locket_classic_passive:GetModifierBonusStats_Strength()
	return self.bonus_all_stats
end

function modifier_holy_locket_classic_passive:GetModifierBonusStats_Intellect()
	return self.bonus_all_stats
end


function modifier_holy_locket_classic_passive:GetModifierStatusResistanceStacking()
	return self.status_increase
end

function modifier_holy_locket_classic_passive:GetModifierMagicalResistanceBonus()
	return self.bonus_mr
end

function modifier_holy_locket_classic_passive:GetModifierConstantHealthRegen()
	return self.bonus_regen
end

function modifier_holy_locket_classic_passive:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_holy_locket_classic_passive:GetModifierManaBonus()
	return self.bonus_mana
end

