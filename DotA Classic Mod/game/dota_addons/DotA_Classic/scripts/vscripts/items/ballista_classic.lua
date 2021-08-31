item_ballista_classic = class({})

LinkLuaModifier("modifier_ballista_classic_passive","items/ballista_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned","items/ballista_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ballista_classic_motion","items/ballista_classic", LUA_MODIFIER_MOTION_NONE)

function item_ballista_classic:GetIntrinsicModifierName()
	return "modifier_ballista_classic_passive"
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Ballista Passive Bonuses Modifier
modifier_ballista_classic_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ballista_classic_passive:IsHidden()
	return true
end

function modifier_ballista_classic_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ballista_classic_passive:OnCreated( kv )

	-- references
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "base_attack_range" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value	
	self.stun_chance = self:GetAbility():GetSpecialValueFor( "stun_chance" ) -- special value
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" ) -- special value
	self.stun_damage = self:GetAbility():GetSpecialValueFor( "stun_damage" ) -- special value
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as_passive" ) -- special value
	self.speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" ) -- special value

	self.chance = 16 --Pseudo Random Value for 35% chance
	self.cvalue = 16 --Pseudo Random Value for 35% chance

	self.knockback_duration = self:GetAbility():GetSpecialValueFor( "knockback_duration" ) -- special value

	--local caster = self:GetParent() 
	--if (IsServer() and caster:IsRangedAttacker()) then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_ballista", { duration = -1}) end 
end

function modifier_ballista_classic_passive:OnRefresh( kv )

	-- references
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "base_attack_range" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agility" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value	
	self.stun_chance = self:GetAbility():GetSpecialValueFor( "stun_chance" ) -- special value
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" ) -- special value
	self.stun_damage = self:GetAbility():GetSpecialValueFor( "stun_damage" ) -- special value
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as_passive" ) -- special value
	self.speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" ) -- special value

	--local caster = self:GetParent() 
	--if (IsServer() and caster:IsRangedAttacker()) then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_ballista", { duration = -1}) end 

end

function modifier_ballista_classic_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_ballista_classic_passive:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,

		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,

		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,

	}

	return funcs
end


function modifier_ballista_classic_passive:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_ballista_classic_passive:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_ballista_classic_passive:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_ballista_classic_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_ballista_classic_passive:GetModifierAttackRangeBonusUnique()
	local attacker = self:GetParent()
	if attacker:IsRangedAttacker() then return self.bonus_range end
	return 0
end

function modifier_ballista_classic_passive:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_ballista_classic_passive:GetModifierProjectileSpeedBonus()
	return self:GetAbility():GetSpecialValueFor( "projectile_speed" )
end


function modifier_ballista_classic_passive:GetModifierProcAttack_BonusDamage_Pure( params )

		local attacker = self:GetParent()
		local target = params.target
				
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then
			if self.chance > RandomInt(1, 100) and (not attacker:IsIllusion()) and attacker:IsRangedAttacker() then
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_generic_stunned", { duration = self.stun_duration})

					-- effects
					local sound_cast = "Hero_Sniper.AssassinateDamage"
					EmitSoundOn( sound_cast, target )
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, self.stun_damage, nil)
				
				if not target:IsMagicImmune() then
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_ballista_classic_motion", {duration = self.knockback_duration})
				end 

				self.chance = self.cvalue
				return self.stun_damage	
			end
			self.chance = self.chance + self.cvalue
			return 0
		end

	return 0
end

------------------------------
-- PASSIVE KNOCKBACK MODIFIER
------------------------------
modifier_ballista_classic_motion = class({})

function modifier_ballista_classic_motion:IsDebuff() return true end
function modifier_ballista_classic_motion:IsHidden() return true end
-- function modifier_ballista_classic_motion:IsPurgable() return false end
function modifier_ballista_classic_motion:IsStunDebuff() return false end
function modifier_ballista_classic_motion:IsMotionController()  return true end
function modifier_ballista_classic_motion:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_ballista_classic_motion:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_legion_commander_duel") or self:GetParent():HasModifier("modifier_enigma_black_hole_pull") or self:GetParent():HasModifier("modifier_faceless_void_chronosphere_freeze") then
		self:Destroy()
		return
	end

	self.knockback_distance = self:GetAbility():GetSpecialValueFor( "knockback_distance" ) -- special value
	self.pfx = ParticleManager:CreateParticle("particles/items_fx/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:StartIntervalThink(FrameTime())

	self.angle = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
	self.distance = self.knockback_distance / ( self:GetDuration() / FrameTime())
end

function modifier_ballista_classic_motion:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_ballista_classic_motion:OnIntervalThink()
	--[[ Remove force if conflicting
	if not self:CheckMotionControllers() then
		self:Destroy()
		return
	end]]
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_ballista_classic_motion:HorizontalMotion(unit, time)
	if not IsServer() then return end
	
	-- Mars' Arena of Blood exception
	if self:GetParent():HasModifier("modifier_mars_arena_of_blood_leash") and self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner() and (self:GetParent():GetAbsOrigin() - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner():GetAbsOrigin()):Length2D() >= self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("radius") - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("width") then
		self:Destroy()
		return
	end
	
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 100, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end



----------------------------
----------------------------
--Stun effect modifier

modifier_generic_stunned = class({})

--------------------------------------------------------------------------------

function modifier_generic_stunned:IsDebuff()
	return true
end

function modifier_generic_stunned:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_generic_stunned:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_generic_stunned:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_generic_stunned:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function modifier_generic_stunned:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_generic_stunned:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------




-- Author: MouJiaoZi
-- Date: 2017/12/02 

---------------------------------------------
--		item_ballista Force Staff Active from Dota IMBA
---------------------------------------------

LinkLuaModifier("modifier_forcestaff_active", "items/ballista_classic", LUA_MODIFIER_MOTION_NONE)

function item_ballista_classic:CastFilterResultTarget(target)
	if self:GetCaster() == target or target:HasModifier("modifier_gyrocopter_homing_missile") then
		return UF_SUCCESS
	else
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CUSTOM, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
	end
end

function item_ballista_classic:GetCastRange(location, target)
	if not target or target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return self.BaseClass.GetCastRange(self, location, target)
	else
		return self:GetSpecialValueFor("cast_range_enemy")
	end
end

function item_ballista_classic:OnSpellStart()
	if not IsServer() then return end
	local ability = self
	local target = self:GetCursorTarget()

	-- If the target possesses a ready Linken's Sphere, do nothing
	if target:TriggerSpellAbsorb(ability) then
		return nil
	end
	
	EmitSoundOn("DOTA_Item.ForceStaff.Activate", target)
	target:AddNewModifier(self:GetCaster(), ability, "modifier_forcestaff_active", {duration = ability:GetSpecialValueFor("push_duration")})
end


---------------------------------------
--------  ACTIVE BUFF -----------------
---------------------------------------

modifier_forcestaff_active = class({})

function modifier_forcestaff_active:IsDebuff() return false end
function modifier_forcestaff_active:IsHidden() return true end
-- function modifier_forcestaff_active:IsPurgable() return false end
function modifier_forcestaff_active:IsStunDebuff() return false end
function modifier_forcestaff_active:IsMotionController()  return true end
function modifier_forcestaff_active:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_forcestaff_active:IgnoreTenacity()	return true end

function modifier_forcestaff_active:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_legion_commander_duel") or self:GetParent():HasModifier("modifier_enigma_black_hole_pull") or self:GetParent():HasModifier("modifier_faceless_void_chronosphere_freeze") then
		self:Destroy()
		return
	end

	self.pfx = ParticleManager:CreateParticle("particles/items_fx/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	self.angle = self:GetParent():GetForwardVector():Normalized()
	self.distance = self:GetAbility():GetSpecialValueFor("push_length") / ( self:GetDuration() / FrameTime())
end

function modifier_forcestaff_active:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_forcestaff_active:OnIntervalThink()
	--[[ Remove force if conflicting
	if not self:CheckMotionControllers() then
		self:Destroy()
		return
	end]]
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_forcestaff_active:HorizontalMotion(unit, time)
	if not IsServer() then return end
	
	-- Mars' Arena of Blood exception
	if self:GetParent():HasModifier("modifier_mars_arena_of_blood_leash") and self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner() and (self:GetParent():GetAbsOrigin() - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner():GetAbsOrigin()):Length2D() >= self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("radius") - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("width") then
		self:Destroy()
		return
	end
	
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 100, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end




---------------------------------------------
--[[		item_imba_hurricane_pike
---------------------------------------------
item_imba_hurricane_pike = item_imba_hurricane_pike or class({})

LinkLuaModifier("modifier_item_imba_hurricane_pike", "components/items/item_force_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_hurricane_pike_unique", "components/items/item_force_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_hurricane_pike_force_ally", "components/items/item_force_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_hurricane_pike_force_enemy", "components/items/item_force_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_hurricane_pike_force_self", "components/items/item_force_staff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_hurricane_pike_attack_speed", "components/items/item_force_staff", LUA_MODIFIER_MOTION_NONE)

function item_imba_hurricane_pike:GetIntrinsicModifierName()
	return "modifier_item_imba_hurricane_pike"
end

function item_imba_hurricane_pike:CastFilterResultTarget(target)
	if self:GetCaster() == target or target:HasModifier("modifier_imba_gyrocopter_homing_missile") then
		return UF_SUCCESS
	else
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CUSTOM, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, self:GetCaster():GetTeamNumber())
	end
end

function item_imba_hurricane_pike:GetCastRange(location, target)
	if not target or target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return self.BaseClass.GetCastRange(self, location, target)
	else
		return self:GetSpecialValueFor("cast_range_enemy")
	end
end

function item_imba_hurricane_pike:OnSpellStart()
	if not IsServer() then return end
	local ability = self
	local target = self:GetCursorTarget()
	local duration = 0.4

	if self:GetCaster():GetTeamNumber() == target:GetTeamNumber() then
		EmitSoundOn("DOTA_Item.ForceStaff.Activate", target)
		target:AddNewModifier(self:GetCaster(), ability, "modifier_item_imba_hurricane_pike_force_ally", {duration = duration })
	else
		-- If the target possesses a ready Linken's Sphere, do nothing
		if target:TriggerSpellAbsorb(ability) then
			return nil
		end
	
		target:AddNewModifier(self:GetCaster(), ability, "modifier_item_imba_hurricane_pike_force_enemy", {duration = duration})
		self:GetCaster():AddNewModifier(target, ability, "modifier_item_imba_hurricane_pike_force_self", {duration = duration})
		local buff = self:GetCaster():AddNewModifier(self:GetCaster(), ability, "modifier_item_imba_hurricane_pike_attack_speed", {duration = ability:GetSpecialValueFor("range_duration")})
		buff.target = target
		buff:SetStackCount(ability:GetSpecialValueFor("max_attacks"))
		EmitSoundOn("DOTA_Item.ForceStaff.Activate", target)
		EmitSoundOn("DOTA_Item.ForceStaff.Activate", self:GetCaster())
		
		if self:GetCaster():IsRangedAttacker() then
			local startAttack = {
				UnitIndex = self:GetCaster():entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex(),}
			ExecuteOrderFromTable(startAttack)
		end
	end
end

modifier_item_imba_hurricane_pike = modifier_item_imba_hurricane_pike or class({})

function modifier_item_imba_hurricane_pike:IsHidden()		return true end
function modifier_item_imba_hurricane_pike:IsPurgable()		return false end
function modifier_item_imba_hurricane_pike:RemoveOnDeath()	return false end
function modifier_item_imba_hurricane_pike:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_imba_hurricane_pike:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_imba_hurricane_pike_unique") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_imba_hurricane_pike_unique", {})
		end
	end

	self:StartIntervalThink(1.0)
end

function modifier_item_imba_hurricane_pike:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_item_imba_hurricane_pike") then
			parent:RemoveModifierByName("modifier_item_imba_hurricane_pike_unique")
		end
	end
end

function modifier_item_imba_hurricane_pike:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_item_imba_hurricane_pike:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_imba_hurricane_pike:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_imba_hurricane_pike:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_imba_hurricane_pike:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

modifier_item_imba_hurricane_pike_unique = modifier_item_imba_hurricane_pike_unique or class({})

function modifier_item_imba_hurricane_pike_unique:IsHidden() return true end
function modifier_item_imba_hurricane_pike_unique:IsPurgable() return false end
function modifier_item_imba_hurricane_pike_unique:IsDebuff() return false end
function modifier_item_imba_hurricane_pike_unique:RemoveOnDeath() return false end

function modifier_item_imba_hurricane_pike_unique:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
end

function modifier_item_imba_hurricane_pike_unique:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self:GetAbility():GetSpecialValueFor("base_attack_range")
	end
end


modifier_item_imba_hurricane_pike_force_ally = modifier_item_imba_hurricane_pike_force_ally or class({})

function modifier_item_imba_hurricane_pike_force_ally:IsDebuff() return false end
function modifier_item_imba_hurricane_pike_force_ally:IsHidden() return true end
function modifier_item_imba_hurricane_pike_force_ally:IsPurgable() return false end
function modifier_item_imba_hurricane_pike_force_ally:IsStunDebuff() return false end
function modifier_item_imba_hurricane_pike_force_ally:IsMotionController()  return true end
function modifier_item_imba_hurricane_pike_force_ally:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_item_imba_hurricane_pike_force_ally:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if not IsServer() then return end

	if self:GetParent():HasModifier("modifier_legion_commander_duel") or self:GetParent():HasModifier("modifier_imba_enigma_black_hole") or self:GetParent():HasModifier("modifier_imba_faceless_void_chronosphere_handler") then
		self:Destroy()
		return
	end
	
	self.pfx = ParticleManager:CreateParticle("particles/items_fx/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	self.angle = self:GetParent():GetForwardVector():Normalized()
	self.distance = self:GetAbility():GetSpecialValueFor("push_length") / ( self:GetDuration() / FrameTime())
end

function modifier_item_imba_hurricane_pike_force_ally:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_item_imba_hurricane_pike_force_ally:OnIntervalThink()
	-- Remove force if conflicting
	if not self:CheckMotionControllers() then
		self:Destroy()
		return
	end
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_item_imba_hurricane_pike_force_ally:HorizontalMotion(unit, time)
	if not IsServer() then return end
	
	-- Mars' Arena of Blood exception
	if self:GetParent():HasModifier("modifier_mars_arena_of_blood_leash") and self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner() and (self:GetParent():GetAbsOrigin() - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner():GetAbsOrigin()):Length2D() >= self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("radius") - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("width") then
		self:Destroy()
		return
	end
	
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end

modifier_item_imba_hurricane_pike_force_enemy = modifier_item_imba_hurricane_pike_force_enemy or class({})
modifier_item_imba_hurricane_pike_force_self = modifier_item_imba_hurricane_pike_force_self or class({})

function modifier_item_imba_hurricane_pike_force_enemy:IsDebuff() return true end
function modifier_item_imba_hurricane_pike_force_enemy:IsHidden() return true end
-- function modifier_item_imba_hurricane_pike_force_enemy:IsPurgable() return false end
function modifier_item_imba_hurricane_pike_force_enemy:IsStunDebuff() return false end
function modifier_item_imba_hurricane_pike_force_enemy:IsMotionController()  return true end
function modifier_item_imba_hurricane_pike_force_enemy:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_item_imba_hurricane_pike_force_enemy:IgnoreTenacity()	return true end

function modifier_item_imba_hurricane_pike_force_enemy:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if not IsServer() then return end

	self.pfx = ParticleManager:CreateParticle("particles/items_fx/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	self.angle = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
	self.distance = self:GetAbility():GetSpecialValueFor("enemy_length") / ( self:GetDuration() / FrameTime())
end

function modifier_item_imba_hurricane_pike_force_enemy:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_item_imba_hurricane_pike_force_enemy:OnIntervalThink()
	-- Remove force if conflicting
	if not self:CheckMotionControllers() then
		self:Destroy()
		return
	end
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_item_imba_hurricane_pike_force_enemy:HorizontalMotion(unit, time)
	if not IsServer() then return end
	
	-- Mars' Arena of Blood exception
	if self:GetParent():HasModifier("modifier_mars_arena_of_blood_leash") and self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner() and (self:GetParent():GetAbsOrigin() - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner():GetAbsOrigin()):Length2D() >= self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("radius") - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("width") then
		self:Destroy()
		return
	end
	
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end

function modifier_item_imba_hurricane_pike_force_self:IsDebuff() return false end
function modifier_item_imba_hurricane_pike_force_self:IsHidden() return true end
-- function modifier_item_imba_hurricane_pike_force_self:IsPurgable() return false end
function modifier_item_imba_hurricane_pike_force_self:IsStunDebuff() return false end
function modifier_item_imba_hurricane_pike_force_self:IgnoreTenacity() return true end
function modifier_item_imba_hurricane_pike_force_self:IsMotionController()  return true end
function modifier_item_imba_hurricane_pike_force_self:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_item_imba_hurricane_pike_force_self:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if not IsServer() then return end

	self.pfx = ParticleManager:CreateParticle("particles/items_fx/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	self.angle = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
	self.distance = self:GetAbility():GetSpecialValueFor("enemy_length") / ( self:GetDuration() / FrameTime())
end

function modifier_item_imba_hurricane_pike_force_self:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_item_imba_hurricane_pike_force_self:OnIntervalThink()
	-- Remove force if conflicting
	if not self:CheckMotionControllers() then
		self:Destroy()
		return
	end
	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_item_imba_hurricane_pike_force_self:HorizontalMotion(unit, time)
	if not IsServer() then return end
	
	-- Mars' Arena of Blood exception
	if self:GetParent():HasModifier("modifier_mars_arena_of_blood_leash") and self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner() and (self:GetParent():GetAbsOrigin() - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAuraOwner():GetAbsOrigin()):Length2D() >= self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("radius") - self:GetParent():FindModifierByName("modifier_mars_arena_of_blood_leash"):GetAbility():GetSpecialValueFor("width") then
		self:Destroy()
		return
	end
	
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end

modifier_item_imba_hurricane_pike_attack_speed = modifier_item_imba_hurricane_pike_attack_speed or class({})

function modifier_item_imba_hurricane_pike_attack_speed:IsDebuff() return false end
function modifier_item_imba_hurricane_pike_attack_speed:IsHidden() return false end
function modifier_item_imba_hurricane_pike_attack_speed:IsPurgable() return true end
function modifier_item_imba_hurricane_pike_attack_speed:IsStunDebuff() return false end
function modifier_item_imba_hurricane_pike_attack_speed:IgnoreTenacity() return true end

function modifier_item_imba_hurricane_pike_attack_speed:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	if not IsServer() then return end
	self.as = 0
	self.ar = 0
	self:StartIntervalThink(FrameTime())
end

function modifier_item_imba_hurricane_pike_attack_speed:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():GetAttackTarget() == self.target then
		self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
		if self:GetParent():IsRangedAttacker() then
			self.ar = 999999
		end
	else
		self.as = 0
		self.ar = 0
	end
end

function modifier_item_imba_hurricane_pike_attack_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
end

function modifier_item_imba_hurricane_pike_attack_speed:GetModifierAttackSpeedBonus_Constant()
	if not IsServer() then return end
	return self.as
end

function modifier_item_imba_hurricane_pike_attack_speed:GetModifierAttackRangeBonus()
	if not IsServer() then return end
	return self.ar
end

function modifier_item_imba_hurricane_pike_attack_speed:OnAttack( keys )
	if not IsServer() then return end
	if keys.target == self.target and keys.attacker == self:GetParent() then
		if self:GetStackCount() > 1 then
			self:DecrementStackCount()
		else
			self:Destroy()
		end
	end
end

function modifier_item_imba_hurricane_pike_attack_speed:OnOrder( keys )
	if not IsServer() then return end
	
	if keys.target == self.target and keys.unit == self:GetParent() and keys.order_type == 4 then
		if self:GetParent():IsRangedAttacker() then
			self.ar = 999999
		end
		
		self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

]]