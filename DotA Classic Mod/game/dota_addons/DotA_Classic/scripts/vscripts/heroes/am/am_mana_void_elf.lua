--Credits go to Elfansoer; Edited by Bashtime

am_mana_void_elf = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "heroes/am/am_mana_void_elf", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- AOE Radius
function am_mana_void_elf:GetAOERadius()
	return self:GetSpecialValueFor( "mana_void_aoe_radius" )
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function am_mana_void_elf:OnAbilityPhaseStart( kv )
	local target = self:GetCursorTarget()
	self:PlayEffects1( true )

	return true -- if success
end
function am_mana_void_elf:OnAbilityPhaseInterrupted()
	self:PlayEffects1( false )
end

--------------------------------------------------------------------------------
-- Ability Start
function am_mana_void_elf:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if got linken
	if target == nil or target:IsInvulnerable() or target:TriggerSpellAbsorb( self ) then
		return
	end

	-- load data
	local mana_damage_pct = self:GetSpecialValueFor("mana_void_damage_per_mana")
	local mana_stun = self:GetSpecialValueFor("mana_void_ministun")
	local radius = self:GetSpecialValueFor( "mana_void_aoe_radius" )

	-- Add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = mana_stun } -- kv
	)

	-- Get damage value
	local mana_damage_pct = (target:GetMaxMana() - target:GetMana()) * mana_damage_pct

	-- Apply Damage	 
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = mana_damage_pct,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Find Units in Radius
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end

	-- Play Effects
	self:PlayEffects2( target, radius )
end
--------------------------------------------------------------------------------
function am_mana_void_elf:PlayEffects1( bStart )
	local sound_cast = "Hero_Antimage.ManaVoidCast"

	if bStart then
		self.target = self:GetCursorTarget()
		EmitSoundOn( sound_cast, self.target )
	else
		StopSoundOn(sound_cast, self.target)
		self.target = nil
	end
end

function am_mana_void_elf:PlayEffects2( target, radius )
	-- Get Resources
	local particle_target = "particles/units/heroes/hero_antimage/antimage_manavoid.vpcf"
	local sound_target = "Hero_Antimage.ManaVoid"

	-- Create Particle
	-- local effect_target = ParticleManager:CreateParticle( particle_target, PATTACH_POINT_FOLLOW, target )
	local effect_target = assert(loadfile("rubick_spell_steal_lua_arcana"))(self, particle_target, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_target, 1, Vector( radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_target )

	-- Create Sound
	EmitSoundOn( sound_target, target )
end


-- Purity of Will reducing cooldown
function am_mana_void_elf:GetCooldown(nLevel)

	if IsServer() then

	local caster = self:GetCaster()
	local lvl = self:GetLevel() - 1

	-- purity of will cooldown manipulation preparation
	local purity_of_will = caster:FindAbilityByName("antimage_counterspell") 
	local purity_lvl 

	if purity_of_will ~= nil then
		purity_lvl = purity_of_will:GetLevel() - 1
	end

	-- calculate new cd
	local new_cd = self.BaseClass.GetCooldown( self, lvl )

	if purity_lvl ~= nil then
		-- adapt cd
		local void_cd_reduction = purity_of_will:GetLevelSpecialValueFor("void_cd_red", purity_lvl)
		local new_cd = self.BaseClass.GetCooldown( self, lvl ) - void_cd_reduction

		return new_cd
	else
		return new_cd
	end

	end

end




----------------------------
----------------------------
--Stun effect modifier

modifier_generic_stunned_lua = class({})

--------------------------------------------------------------------------------

function modifier_generic_stunned_lua:IsDebuff()
	return true
end

function modifier_generic_stunned_lua:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_generic_stunned_lua:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_generic_stunned_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_generic_stunned_lua:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function modifier_generic_stunned_lua:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_generic_stunned_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------



