-- Creator:
-- 	AltiV - February 23rd, 2019

LinkLuaModifier("modifier_atos_debuff", "items/atos.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_atos", "items/atos.lua", LUA_MODIFIER_MOTION_NONE)

item_atos				= class({})
modifier_atos_debuff	= class({})
modifier_atos			= class({})

----------------------
-- ROD OF ATOS BASE --
----------------------

function item_atos:GetIntrinsicModifierName()
	return "modifier_atos"
end

function item_atos:OnSpellStart()
	self.caster		= self:GetCaster()
	
	-- AbilitySpecials
	self.duration				=	self:GetSpecialValueFor("duration")
	self.tooltip_range			=	self:GetSpecialValueFor("tooltip_range")
	self.projectile_speed		=	self:GetSpecialValueFor("projectile_speed")

	if not IsServer() then return end
	
	local caster_location	= self.caster:GetAbsOrigin()
	local target			= self:GetCursorTarget()
		
	-- Play the cast sound
	self.caster:EmitSound("DOTA_Item.RodOfAtos.Cast")

	-- Only the upgraded version with enough charges gets Curtain Fire Shooting (also no tempest doubles allowed cause anti-fun)
	 
		local projectile =
				{
					Target 				= target,
					Source 				= self.caster,
					Ability 			= self,
					EffectName 			= "particles/items2_fx/rod_of_atos_attack.vpcf",
					iMoveSpeed			= self.projectile_speed,
					vSourceLoc 			= caster_location,
					bDrawsOnMinimap 	= false,
					bDodgeable 			= true,
					bIsAttack 			= false,
					bVisibleToEnemies 	= true,
					bReplaceExisting 	= false,
					flExpireTime 		= GameRules:GetGameTime() + 20,
					bProvidesVision 	= false,
				}
				
			ProjectileManager:CreateTrackingProjectile(projectile)
		
		return 
end

function item_atos:OnProjectileHit(target, location)
	if not IsServer() then return end
	
	-- Check if a valid target has been hit
	if target and not target:IsMagicImmune() then
	
			-- Check for Linken's / Lotus Orb
			if target:TriggerSpellAbsorb(self) then return nil end
		
		-- Otherwise, play the sound...
		target:EmitSound("DOTA_Item.RodOfAtos.Target")
		
		-- ...and apply the Cripple modifier.
		target:AddNewModifier(self.caster, self, "modifier_atos_debuff", {duration = self.duration * (1 - target:GetStatusResistance())})
	end
end

---------------------------------
-- ROD OF ATOS DEBUFF MODIFIER --
---------------------------------

function modifier_atos_debuff:GetEffectName()
	return "particles/items2_fx/rod_of_atos.vpcf"
end

function modifier_atos_debuff:CheckState(keys)
	return {
		[MODIFIER_STATE_ROOTED] = true
	}
end

--------------------------
-- ROD OF ATOS MODIFIER --
--------------------------

function modifier_atos:IsHidden() return true end
function modifier_atos:IsPurgable() return false end
function modifier_atos:RemoveOnDeath() return false end
function modifier_atos:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_atos:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
end

function modifier_atos:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end

function modifier_atos:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_intellect")
	end
end

function modifier_atos:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_strength")
	end
end

function modifier_atos:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_agility")
	end
end