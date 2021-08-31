-- Creator:
-- 	Bashtime - 30.08.2021

LinkLuaModifier("modifier_nullifier", "items/nullifier_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nullifier_dispel_and_mute", "items/nullifier_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nullifier_spell_reduction", "items/nullifier_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nullifier_slow", "items/nullifier_classic", LUA_MODIFIER_MOTION_NONE)

item_nullifier_classic				= class({})

modifier_nullifier					= class({})
modifier_nullifier_dispel_and_mute	= modifier_nullifier_mute or class({})
modifier_nullifier_slow				= class({})

local itemClass 		= item_nullifier_classic
local modifierClass 	= modifier_nullifier
local debuff_main 		= modifier_nullifier_dispel_and_mute
local debuff_subsidiary = modifier_nullifier_slow
local aura_effect		= modifier_nullifier_spell_reduction

--------------------
-- NULLIFIER BASE --
--------------------

function itemClass:GetIntrinsicModifierName()
	return "modifier_nullifier"
end

function itemClass:OnSpellStart()
	-- This is just to save the variable so Shudder doesn't affect the direct target (yes I know it still messes up if you refresh and cast again while projectile is already flying)
	self.target	= self:GetCursorTarget()
	
	-- Play the cast sound
	self:GetCaster():EmitSound("DOTA_Item.Nullifier.Cast")

	local effectName = "particles/items4_fx/nullifier_proj.vpcf"
	
	-- Create the projectile
	local projectile =
		{
			Target 				= self:GetCursorTarget(),
			Source 				= self:GetCaster(),
			Ability 			= self,
			EffectName 			= effectName,
			iMoveSpeed			= self:GetSpecialValueFor("projectile_speed"),
			vSourceLoc 			= self:GetCaster():GetAbsOrigin(),
			bDrawsOnMinimap 	= false,
			bDodgeable 			= true,
			bIsAttack 			= false,
			bVisibleToEnemies 	= true,
			bReplaceExisting 	= false,
			flExpireTime 		= GameRules:GetGameTime() + 10,
			bProvidesVision 	= false,
		}
		
	ProjectileManager:CreateTrackingProjectile(projectile)
end

function itemClass:OnProjectileHit(target, location)
	-- Check if a valid target has been hit
	if target and not target:IsMagicImmune() then
			-- Check for Linken's / Lotus Orb
		if target:TriggerSpellAbsorb(self) then return nil end

		-- Otherwise, play the sound...
		target:EmitSound("DOTA_Item.Nullifier.Target")
		
		-- ..and apply the purge, mute modifier, and slow modifier
		target:Purge(true, false, false, false, false)
		
		target:AddNewModifier(self:GetCaster(), self, "modifier_nullifier_dispel_and_mute", {duration = self:GetSpecialValueFor("mute_duration") * (1 - target:GetStatusResistance())})
	end
	
end

------------------------
-- NULLIFIER MODIFIER --
------------------------

function modifierClassIsHidden()		return true end
function modifierClassIsPurgable()		return false end
function modifierClassRemoveOnDeath()	return false end
function modifierClassGetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifierClassOnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	-- AbilitySpecials
	self.bonus_damage	=	self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.bonus_armor	=	self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.bonus_regen	=	self:GetAbility():GetSpecialValueFor("bonus_regen")
end

function modifierClassDeclareFunctions()
    return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS, 
		MODIFIER_PROPERTY_MANA_BONUS 
    }
end

function modifierClassGetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifierClassGetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifierClassGetModifierConstantHealthRegen()
	return self.bonus_regen
end

-----------------------------
-- NULLIFIER MUTE MODIFIER --
-----------------------------

function debuff_main:IsPurgable() return false end
function debuff_main:IsPurgeException() return false end

function debuff_main:GetEffectName()
	return "particles/items4_fx/nullifier_mute_debuff.vpcf"
end

function debuff_main:GetStatusEffectName()
	return "particles/status_fx/status_effect_nullifier.vpcf"
end

function debuff_main:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	self.level	= self:GetAbility():GetLevel()
	self.isMuted = true
	self.initial_mute = self:GetAbility():GetSpecialValueFor("mute_on_impact")

	Timers:CreateTimer(self.initial_mute, function() self.isMuted = false end)

	if self:GetAbility() then
		self.slow_interval_duration = self:GetAbility():GetSpecialValueFor("slow_interval_duration")
	else
		self:Destroy()
		return
	end

	if not IsServer() then return end

	local overhead_particle = "particles/items4_fx/nullifier_mute.vpcf"
	local overhead_particle = ParticleManager:CreateParticle(overhead_particle, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	self:AddParticle(overhead_particle, false, false, -1, false, false)
	
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_nullifier_slow", {duration = self.initial_mute * (1 - self:GetParent():GetStatusResistance())})
end

function debuff_main:CheckState()
	if IsServer() then
		self:GetParent():Purge(true, false, false, false, false)
	end
end

function debuff_main:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_STATE_MUTED
    }
end

function debuff_main:OnAttackLanded(keys)
	if not IsServer() then return end
	
	if keys.target == self:GetParent() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_nullifier_slow", {duration = self.slow_interval_duration * (1 - self:GetParent():GetStatusResistance())})
	end	
end

function debuff_main:CheckState()
	return {
		[MODIFIER_STATE_MUTED] = true
	}
end

-----------------------------
-- NULLIFIER SLOW MODIFIER --
-----------------------------

function debuff_subsidiary:GetStatusEffectName()
	return "particles/status_fx/status_effect_nullifier_slow.vpcf"
end

function debuff_subsidiary:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	self.slow_pct	= 0
	
	if self:GetAbility() then
		self.slow_pct	= self:GetAbility():GetSpecialValueFor("slow_pct") * (-1)
	end
	
	if not IsServer() then return end
	
	self:GetParent():EmitSound("DOTA_Item.Nullifier.Slow")
end

function debuff_subsidiary:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

-- Based on vanilla testing, the 100% slow modifier applies but doesn't slow if the item doesn't exist (i.e. you destroy it)
function debuff_subsidiary:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_pct
end


--[[
LinkLuaModifier("modifier_moc_debuff", "items/moc.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moc_buff", "items/moc.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moc", "items/moc.lua", LUA_MODIFIER_MOTION_NONE)


item_moc				= class({})
modifier_moc_debuff		= class({})
modifier_moc_buff		= class({})
modifier_moc			= class({})

-------------------------------
-- MEDALLION OF COURAGE BASE --
-------------------------------

function item_moc:GetIntrinsicModifierName()
	return "modifier_moc"
end

function item_moc:OnSpellStart()
		
	-- AbilitySpecials
	self.duration				=	self:GetSpecialValueFor("duration")

	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	--Apply Buff or Debuff
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if not target:IsMagicImmune() then
			target:AddNewModifier(caster, self, "modifier_moc_debuff", {duration = self.duration * (1 - target:GetStatusResistance())})
		end
	else
		target:AddNewModifier(caster, self, "modifier_moc_buff", {duration = self.duration })
	end

	caster:AddNewModifier(caster, self, "modifier_moc_debuff", {duration = self.duration })
	-- Play the cast sound
	caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate") 
	target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
end

------------------------------------------------------------------------------
--- Custom Filter

function item_moc:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end
	if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and hTarget:IsMagicImmune() then return UF_FAIL_CUSTOM end
end

--------------------------------------------------------------------------------

function item_moc:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end
	if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and hTarget:IsMagicImmune() then return "#dota_hud_error_moc"
end


---------------------------------
-- MEDALLION DEBUFF MODIFIER --
---------------------------------

function modifier_moc_debuff:GetEffectName()
	return "particles/items2_fx/medallion_of_courage.vpcf"
end

function modifier_moc_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_moc_debuff:IsDebuff()
	return true
end

function modifier_moc_debuff:OnCreated()
	self.armor_reduction		=	self:GetAbility():GetSpecialValueFor("armor_reduction")
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
end

function modifier_moc_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_moc_debuff:GetModifierPhysicalArmorBonus()
	return -self.armor_reduction
end
---------------------------------
-- MEDALLION BUFF MODIFIER --
---------------------------------

function modifier_moc_buff:GetEffectName()
	return "particles/items2_fx/medallion_of_courage_friend.vpcf"
end

function modifier_moc_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_moc_buff:OnCreated()
	self.armor_reduction		=	self:GetAbility():GetSpecialValueFor("armor_reduction")
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
end

function modifier_moc_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_moc_buff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end

--------------------------
 -- Medallion MODIFIER --
--------------------------

function modifier_moc:IsHidden() return true end
function modifier_moc:IsPurgable() return false end
function modifier_moc:RemoveOnDeath() return false end
function modifier_moc:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_moc:OnCreated()
	self.bonus_armor			=	self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.mana_reg				=	self:GetAbility():GetSpecialValueFor("mana_reg")

	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
end

function modifier_moc:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_moc:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_moc:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end