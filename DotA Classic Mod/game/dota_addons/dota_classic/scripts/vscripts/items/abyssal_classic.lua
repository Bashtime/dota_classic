-- Author: Shush
-- Date: 29/07/2016

-- Editor: AltiV; Bashtime
-- Date: 22/03/2020, and times before

item_abyssal_classic = item_abyssal_classic or class({})

LinkLuaModifier("modifier_abyssal_classic", "items/abyssal_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_classic_internal_cd", "items/abyssal_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssal_classic_bash", "items/abyssal_classic", LUA_MODIFIER_MOTION_NONE)

function item_abyssal_classic:GetIntrinsicModifierName()
	return "modifier_abyssal_classic"
end

function item_abyssal_classic:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local sound_cast = "DOTA_Item.AbyssalBlade.Activate"    
	local particle_abyssal = "particles/items_fx/abyssal_blade.vpcf"
	local modifier_bash = "modifier_abyssal_classic_bash"
	--local modifier_break = "modifier_abyssal_classic_skull_break"

	-- Ability specials
	local active_stun_duration = ability:GetSpecialValueFor("stun_duration")

	-- Play cast sound
	EmitSoundOn(sound_cast, target)
	
	-- If the target possesses a ready Linken's Sphere, do nothing
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if target:TriggerSpellAbsorb(ability) then
			return nil
		end
	end

	-- This isn't the right particle but I don't want to spend forever looking for this when there are a million other changes to work on
	local blink_start_particle = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(blink_start_particle)
	
	FindClearSpaceForUnit(caster, target:GetAbsOrigin() - caster:GetForwardVector() * 56, false)
	
	local blink_end_particle = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(blink_end_particle)

	-- Add particle effect
	local particle_abyssal_fx = ParticleManager:CreateParticle(particle_abyssal, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_abyssal_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_abyssal_fx)

	local physicalResistance = target:FindModifierByName( "modifier_common_custom_armor" ):GetModifierIncomingPhysicalDamage_Percentage() / 100
	local reduced_damage = self:GetSpecialValueFor("bash_chance_damage") * (1+physicalResistance)

	-- Apply damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = reduced_damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self,
	}

	ApplyDamage(damageTable)

	if target:IsAlive() then
		-- Stun and break the target for the duration
		target:AddNewModifier(caster, ability, modifier_bash, {duration = active_stun_duration * (1 - target:GetStatusResistance())})
	end
end


-- Modifier (stackable, grants stats bonuses)
modifier_abyssal_classic = modifier_abyssal_classic or class({})

function modifier_abyssal_classic:IsHidden()			return true end
function modifier_abyssal_classic:IsPurgable()		return false end
function modifier_abyssal_classic:RemoveOnDeath()	return false end
function modifier_abyssal_classic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_abyssal_classic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_abyssal_classic:OnCreated()
	self.stunchance_range_cvalue = 15 --Cvalue for PRD 10% Stun Chance
	self.stunchance_range = self.stunchance_range_cvalue

	self.stunchance_melee_cvalue = 85 --Cvalue for PRD 25% Stun Chance
	self.stunchance_melee = self.stunchance_range_cvalue 
end

function modifier_abyssal_classic:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_strength")
	end
end

function modifier_abyssal_classic:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_abyssal_classic:GetModifierHealthBonus()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_health")
	end
end

function modifier_abyssal_classic:GetModifierConstantHealthRegen()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
	end
end

function modifier_abyssal_classic:GetModifierPhysical_ConstantBlock()
	local block_chance = self:GetAbility():GetSpecialValueFor("block_chance") 
	if self:GetAbility() and RandomInt(1, 100) <= block_chance then
		if not self:GetParent():IsRangedAttacker() then
			return self:GetAbility():GetSpecialValueFor("block_damage_melee")
		else
			return self:GetAbility():GetSpecialValueFor("block_damage_ranged")
		end
	end
end

function modifier_abyssal_classic:OnAttack(keys)
	if self:GetAbility() and
	keys.attacker == self:GetParent() and
	not keys.attacker:IsIllusion() and
	not keys.target:IsBuilding() and
	not keys.target:IsOther() and
	not keys.attacker:HasModifier("modifier_abyssal_classic_internal_cd") then
		if self:GetParent():IsRangedAttacker() then
			if RandomInt(1,1000) <= self.stunchance_range then
				self.bash_proc = true
				self.stunchance_range = self.stunchance_range_cvalue
			else
				self.stunchance_range = self.stunchance_range + self.stunchance_range_cvalue
			end
		else
			if RandomInt(1,1000) <= self.stunchance_melee then
				self.bash_proc = true
				self.stunchance_melee = self.stunchance_melee_cvalue
			else
				self.stunchance_melee = self.stunchance_melee + self.stunchance_melee_cvalue
			end
		end
	end
end

function modifier_abyssal_classic:OnAttackLanded(keys)
	if self:GetAbility() and keys.attacker == self:GetParent() and self.bash_proc then
		self.bash_proc = false

		-- Make the ability go into an internal cooldown
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_abyssal_classic_internal_cd", {duration = self:GetAbility():GetSpecialValueFor("internal_bash_cd")})

		-- If the attacker is one of the forbidden heroes, do not proc the bash
		--if IMBA_DISABLED_SKULL_BASHER == nil or not IMBA_DISABLED_SKULL_BASHER[keys.attacker:GetUnitName()] then
			keys.target:EmitSound("DOTA_Item.SkullBasher")
			
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abyssal_classic_bash", {duration = self:GetAbility():GetSpecialValueFor("bash_duration") * (1 - keys.target:GetStatusResistance())})
		--end

		local physicalResistance = keys.target:FindModifierByName( "modifier_common_custom_armor" ):GetModifierIncomingPhysicalDamage_Percentage() / 100
		local reduced_damage = self:GetAbility():GetSpecialValueFor("bash_chance_damage") * (1+physicalResistance)
	
		-- Apply damage
		local damageTable = {
			victim = keys.target,
			attacker = self:GetCaster(),
			damage = reduced_damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(),
		}

		ApplyDamage(damageTable)
	end
end

-- Bash modifier
modifier_abyssal_classic_bash = modifier_abyssal_classic_bash or class({})

function modifier_abyssal_classic_bash:IsHidden() return false end
function modifier_abyssal_classic_bash:IsPurgeException() return true end
function modifier_abyssal_classic_bash:IsStunDebuff() return true end

function modifier_abyssal_classic_bash:CheckState()
   return {[MODIFIER_STATE_STUNNED] = true} 
end

function modifier_abyssal_classic_bash:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_abyssal_classic_bash:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_abyssal_classic_bash:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_abyssal_classic_bash:GetOverrideAnimation()
	return ACT_DOTA_DISABLED 
end

-- Modifier responsible for being an internal CD
modifier_abyssal_classic_internal_cd = modifier_abyssal_classic_internal_cd or class({})

--function modifier_abyssal_classic_internal_cd:IgnoreTenacity()	return true end
function modifier_abyssal_classic_internal_cd:IsPurgable() 		return false end
function modifier_abyssal_classic_internal_cd:IsDebuff() 		return true end
function modifier_abyssal_classic_internal_cd:RemoveOnDeath()	return false end