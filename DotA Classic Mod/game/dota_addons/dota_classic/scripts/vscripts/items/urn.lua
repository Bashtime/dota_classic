-- Creator: Bashtime, 28.08.2021

item_urn			= class({})
modifier_urn		= class({})
modifier_urn_heal	= class({})
modifier_urn_damage	= class({})

local itemClass = item_urn

local modifierClass = modifier_urn
local debuffModifierClass = modifier_urn_heal
local buffModifierClass = modifier_urn_damage

local modifierName = 'modifier_urn'
local debuffModifierName = 'modifier_urn_damage'
local buffModifierName = 'modifier_urn_heal'

LinkLuaModifier(modifierName, "items/urn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(debuffModifierName, "items/urn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(buffModifierName, "items/urn.lua", LUA_MODIFIER_MOTION_NONE)

-------------------------
-- URN OF SHADOWS BASE --
-------------------------

function itemClass:GetIntrinsicModifierName()
	return modifierName
end

function itemClass:OnSpellStart()
	-- This is to prevent Ogre Magi's vanilla Multicast from working with vessel
	if self:GetPurchaseTime() == -1 then return end

	self.caster		= self:GetCaster()
	self.duration	= self:GetSpecialValueFor("duration")

	--Reduce Charges	
	self:SetCurrentCharges(math.max(self:GetCurrentCharges() - 1, 0))
	self.target	= self:GetCursorTarget()
	
	-- Play the cast sound
	self.caster:EmitSound("DOTA_Item.SpiritVessel.Cast")

	-- Emit the cast particles
	self.particle	= ParticleManager:CreateParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(self.particle, 1, self.target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(self.particle)

	-- Check if target is an ally or an enemy
	local vesselSound		= "DOTA_Item.SpiritVessel.Target.Enemy"
	local vesselModifier	= debuffModifierName
	
	if self.target:GetTeam() == self.caster:GetTeam() then
		vesselSound		= "DOTA_Item.SpiritVessel.Target.Ally"
		vesselModifier	= buffModifierName
	end

	self.target:EmitSound(vesselSound)
	self.target:AddNewModifier(self.caster, self, vesselModifier, {duration = self.duration})
end

---------------------------------
-- SPIRIT VESSEL HEAL MODIFIER --
---------------------------------

function buffModifierClass:GetEffectName()
	return "particles/items4_fx/spirit_vessel_heal.vpcf"
end

function buffModifierClass:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	-- AbilitySpecials
	self.soul_radius				=	self.ability:GetSpecialValueFor("soul_radius")
	self.soul_initial_charge		=	self.ability:GetSpecialValueFor("soul_initial_charge")
	self.soul_additional_charges	=	self.ability:GetSpecialValueFor("soul_additional_charges")
	self.soul_heal_amount			=	self.ability:GetSpecialValueFor("soul_heal_amount")
	self.soul_damage_amount			=	self.ability:GetSpecialValueFor("soul_damage_amount")
	self.duration					=	self.ability:GetSpecialValueFor("duration")
	self.soul_release_range_tooltip	=	self.ability:GetSpecialValueFor("soul_release_range_tooltip")
	self.hp_regen_reduction_enemy	=	self.ability:GetSpecialValueFor("hp_regen_reduction_enemy")
	self.enemy_hp_drain				=	self.ability:GetSpecialValueFor("enemy_hp_drain")
	
	if not IsServer() then return end
	
	-- Overrides Urn of Shadows modifier
	if self.parent:HasModifier("modifier_imba_urn_of_shadows_active_ally") then
		self.parent:FindModifierByName("modifier_imba_urn_of_shadows_active_ally"):Destroy()
	end
end

function buffModifierClass:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function buffModifierClass:GetModifierConstantHealthRegen()
	return self.soul_heal_amount
end

-- Remove heal on any non-self player or rosh based damage
function buffModifierClass:OnTakeDamage(keys)
	if not IsServer() then return end
	
	if keys.unit == self.parent and keys.attacker ~= self.parent and (keys.attacker:IsConsideredHero() or keys.attacker:IsRoshan()) and keys.damage > 0 then
		self:Destroy()
	end
end

-----------------------------------
-- SPIRIT VESSEL DAMAGE MODIFIER --
-----------------------------------

function debuffModifierName:IsDebuff()	return true end

function debuffModifierName:GetEffectName()
	return "particles/items4_fx/spirit_vessel_damage.vpcf"
end

function debuffModifierName:OnCreated(params)
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	if params and params.curse_stack then
		self:SetStackCount(params.curse_stack)
	end
	
	-- AbilitySpecials
	self.soul_radius				= self.ability:GetSpecialValueFor("soul_radius")
	self.soul_initial_charge		= self.ability:GetSpecialValueFor("soul_initial_charge")
	self.soul_additional_charges	= self.ability:GetSpecialValueFor("soul_additional_charges")
	self.soul_heal_amount			= self.ability:GetSpecialValueFor("soul_heal_amount")
	self.soul_damage_amount			= self.ability:GetSpecialValueFor("soul_damage_amount") 
	self.duration					= self.ability:GetSpecialValueFor("duration")
	self.soul_release_range_tooltip	= self.ability:GetSpecialValueFor("soul_release_range_tooltip")

	self.hp_regen_reduction_enemy	= self.ability:GetSpecialValueFor("hp_regen_reduction_enemy") * (-1)
	self.enemy_hp_drain				= self.ability:GetSpecialValueFor("enemy_hp_drain") 
	
	if not IsServer() then return end
	
	-- Overrides Urn of Shadows modifier
	if self.parent:HasModifier("modifier_imba_urn_of_shadows_active_enemy") then
		self.parent:FindModifierByName("modifier_imba_urn_of_shadows_active_enemy"):Destroy()
	end
	
	-- Applies damage every second
	self:StartIntervalThink(1)
end

-- This is mostly just to recalculate who the caster is for damage ownership
function debuffModifierName:OnRefresh()
	self:OnCreated()
end

function debuffModifierName:OnIntervalThink()
	if not IsServer() then return end
	
	-- Applies flat damage and damage based on current HP in one instance
	local damageTableHP = {
		victim 			= self.parent,
		damage 			= self.soul_damage_amount + (self.parent:GetHealth() * (self.enemy_hp_drain / 100)),
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self.caster,
		ability 		= self.ability
	}
	
	ApplyDamage(damageTableHP)
end

function debuffModifierName:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function debuffModifierName:GetModifierHealAmplify_PercentageTarget()
	return self.hp_regen_reduction_enemy
end

function debuffModifierName:GetModifierHPRegenAmplify_Percentage()
	return self.hp_regen_reduction_enemy
end

function debuffModifierName:OnTooltip()
	return self.hp_regen_reduction_enemy
end

----------------------------
-- SPIRIT VESSEL MODIFIER --
----------------------------

function modifierClass:IsHidden() return true end
function modifierClass:IsPurgable() return false end
function modifierClass:RemoveOnDeath() return false end
function modifierClass:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifierClass:OnCreated()
	self.bonus_health				= self.ability:GetSpecialValueFor("bonus_health")
	self.bonus_ms					= self.ability:GetSpecialValueFor("bonus_movement_speed")
	self.mana_reg					= self.ability:GetSpecialValueFor("bonus_mana_regen")
	self.bonus_all					= self.ability:GetSpecialValueFor("bonus_all_stats")
end

function modifierClass:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		--MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_DEATH
    }
end

function modifierClass:GetModifierHealthBonus()
	if self:GetAbility() then
		return self.bonus_health
	end
end

function modifierClass:GetModifierMoveSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	end
end

function modifierClass:GetModifierConstantManaRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	end
end

function modifierClass:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifierClass:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifierClass:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifierClass:GetModifierPhysicalArmorBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_armor")
	end
end


function modifierClass:OnDeath(keys)
	-- First check: Is the unit within capture range and an enemy and not reincarnating?
	if self:GetAbility() and keys.unit:IsRealHero() and self:GetCaster():IsRealHero() and self:GetCaster():GetTeam() ~= keys.unit:GetTeam() and (not keys.unit.IsReincarnating or (keys.unit.IsReincarnating and not keys.unit:IsReincarnating())) and self:GetCaster():IsAlive() and (self:GetCaster():GetAbsOrigin() - keys.unit:GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("soul_radius") then
	
		-- Second check: Is there no one closer than the item owner that also has a Spirit Vessel?
		local nearbyAllies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), keys.unit:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("soul_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)
		
		for _, ally in pairs(nearbyAllies) do
			-- If the check reaches the item owner then break out of loop and continue checks
			if ally == self:GetCaster() then
				break
			-- If anyone closer has the same item, the owner of this item will not get any charges
			elseif ally:HasItemInInventory(self:GetAbility():GetName()) then
				return
			end
		end
		
		-- If the parent has multiple Spirit Vessels, only apply the charge gain to the first one
		if self == self:GetCaster():FindAllModifiersByName(modifierName)[1] then
			for itemSlot = 0, 5 do
				local item = self:GetCaster():GetItemInSlot(itemSlot)
			
				if item and item:GetName() == self:GetAbility():GetName() then
					-- 2 charges if current count is 0, 1 charge otherwise
					if item:GetCurrentCharges() == 0 then
						item:SetCurrentCharges(item:GetCurrentCharges() + self:GetAbility():GetSpecialValueFor("soul_initial_charge"))
					else
						item:SetCurrentCharges(item:GetCurrentCharges() + self:GetAbility():GetSpecialValueFor("soul_additional_charges"))
					end
					
					-- Don't continue checking for any other Spirit Vessels cause it only adds to one
					break
				end
			end
		end	
	end
end