-- Editors:
--     AtroCty,  04.07.2017
--	   Bashtime, 28.01.2020
--	   Credits: Cykada, EmberCookies, dota2MODcommunity

local LinkedModifiers = {}
-------------------------------------------
--        MANA BREAK
-------------------------------------------
-- Hidden Modifiers:

MergeTables(LinkedModifiers,{
	["modifier_am_mana_break_passive"] = LUA_MODIFIER_MOTION_NONE,
})

am_mana_break = am_mana_break or class({})

function am_mana_break:GetAbilityTextureName()
	return "antimage_mana_break"
end

function am_mana_break:GetIntrinsicModifierName()
	return "modifier_am_mana_break_passive"
end

-- Mana break modifier
modifier_am_mana_break_passive = modifier_am_mana_break_passive or class({})

function modifier_am_mana_break_passive:IsHidden()
	return true
end

function modifier_am_mana_break_passive:IsPurgable()
	return false
end

function modifier_am_mana_break_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT
	}
end

function modifier_am_mana_break_passive:OnCreated()
	if IsServer() then
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.damage_per_burn = self.ability:GetSpecialValueFor("damage_per_burn")
		self.base_mana_burn = self.ability:GetSpecialValueFor("base_mana_burn")
		self.illusions_efficiency_pct = self.ability:GetSpecialValueFor("illusions_efficiency_pct")
	end
end

function modifier_am_mana_break_passive:OnRefresh()
	if IsServer() then
		self:OnCreated()
	end
end

function modifier_am_mana_break_passive:OnAttackStart(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.target
		local has_purity = attacker:HasAbility("am_purity")


		-- If caster has break, do nothing
		if attacker:PassivesDisabled() then
			return nil
		end

		-- If the target is an item, do nothing
		if target:IsItemContainer() then
			return nil
		end

		-- If there isn't a valid target, do nothing
		if target:GetMaxMana() == 0 or target:IsMagicImmune() then
			return nil
		end

		-- Only apply on caster attacking enemies
		if self.parent == attacker and target:GetTeamNumber() ~= self.parent:GetTeamNumber() then

			-- Calculate mana to burn, considering "Purity of Will" Level
			local target_mana_burn = target:GetMana()
			 
			
			if has_purity then

				local percentage_mana_burn = target:GetMaxMana() * self:FindAbilityByName("am_purity"):GetSpecialValueFor("manabreak_perc_adjust") * 0.01
				local overall_mana_burn = self.base_mana_burn + percentage_mana_burn

				if (target_mana_burn > overall_mana_burn) then
					target_mana_burn = overall_mana_burn
				
				else if (target_mana_burn > self.base_mana_burn) then target_mana_burn = self.base_mana_burn
					 end
				end
				
			if self:GetParent():IsIllusion() then
				target_mana_burn = target_mana_burn * self:GetAbility():GetSpecialValueFor("illusion_percentage") * 0.01
			end

						-- Decide how much damage should be added
			self.add_damage = target_mana_burn * self.damage_per_burn

		end
	end
end


function modifier_am_mana_break_passive:OnAttackLanded(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.target

		-- If target has break, do nothing
		if attacker:PassivesDisabled() then
			return nil
		end

		-- If there isn't a valid target, do nothing
		if target:GetMaxMana() == 0 or target:IsMagicImmune() then
			return nil
		end

		-- Only apply on caster attacking enemies
		if self.parent == attacker and target:GetTeamNumber() ~= self.parent:GetTeamNumber() then

			-- Play sound
			target:EmitSound("Hero_Antimage.ManaBreak")

			-- Add hit particle effects
			local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex(manaburn_pfx)

			-- Check if Purity of Will is learned, then Calculate and burn mana
			local target_mana_burn = target:GetMana()


			if has_purity then

				local percentage_mana_burn = target:GetMaxMana() * self:FindAbilityByName("am_purity"):GetSpecialValueFor("manabreak_perc_adjust") * 0.01
				local overall_mana_burn = self.base_mana_burn + percentage_mana_burn

				if (target_mana_burn > overall_mana_burn) then
					target_mana_burn = overall_mana_burn

				else if (target_mana_burn > self.base_mana_burn) then target_mana_burn = self.base_mana_burn
					 end
				end
						
				if self:GetParent():IsIllusion() then
					target_mana_burn = target_mana_burn * self:GetAbility():GetSpecialValueFor("illusion_percentage") * 0.01
				end

			target:ReduceMana(target_mana_burn)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, target_mana_burn, nil)

			-- If the target is magic immune, this is it for us.
			if target:IsMagicImmune() then
				return nil
			end

			
		end
	end
end

function modifier_am_mana_break_passive:GetModifierPreAttack_BonusDamage(params)
	if IsServer() then
		return self.add_damage
	end
end

-------------------------------------------
--       BLINK
-------------------------------------------

am_blink = am_blink or class({})
MergeTables(LinkedModifiers,{})

function am_blink:GetAbilityTextureName()
	return "antimage_blink"
end

function am_blink:IsNetherWardStealable() return false end

-- Purity of Will reducing cast point
function am_blink:OnAbilityPhaseStart()
	if IsServer() then
		local caster = self:GetCaster()
		local has_purity = caster:HasAbility("am_purity")

		if ( has_purity ) and (not self.cast_point) then
			self.cast_point = true
			local cast_point = self:GetCastPoint()
			local cp_red = caster:FindAbilityByName("am_purity"):GetSpecialValueFor("blink_castpoint_reduction")
			cast_point = cast_point - cp_red
			self:SetOverrideCastPoint(cast_point)
		end
		return true
	end
end



-- Purity of Will modifying CD and CastRange
function am_blink:GetCooldown( nLevel )
	
	-- Check Purity of Will Level to reduce CD
	local has_purity = self:GetCaster():HasAbility("am_purity")

	if has_purity then
		local blink_cd_red = self:GetCaster():FindAbilityByName("am_purity"):GetSpecialValueFor("blink_cooldown_reduction") 
		return self.BaseClass.GetCooldown( self, nLevel ) - blink_cd_red
	else
		return self.BaseClass.GetCooldown( self, nLevel )
	end
end

function am_blink:OnSpellStart()
	if IsServer() then

		-- Declare variables
		local caster = self:GetCaster()
		local caster_position = caster:GetAbsOrigin()
		local target_point = self:GetCursorPosition()
		local distance = target_point - caster_position
		local cast_range = caster:GetAbility():GetSpecialValueFor("blink_range")

		-- Check and apply Purity Range Bonus
		if caster:HasAbility("am_purity") then
			local cast_range_bonus = caster:FindAbilityByName("am_purity"):GetSpecialValueFor("blink_range_adjust")
			cast_range = cast_range + cast_range_bonus
		end

		-- Range-check
		if distance:Length2D() > cast_range then
			target_point = caster_position + (target_point - caster_position):Normalized() * cast_range
		end

		-- Disjointing everything
		ProjectileManager:ProjectileDodge(caster)

		-- Blink particles/sound on starting point
		local blink_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:ReleaseParticleIndex(blink_pfx)
		caster:EmitSound("Hero_Antimage.Blink_out")

		-- Adding an extreme small timer for the particles, else they will only appear at the dest
		Timers:CreateTimer(0.01, function()
			-- Move hero
			caster:SetAbsOrigin(target_point)
			FindClearSpaceForUnit(caster, target_point, true)

			-- Create Particle/sound on end-point
			local blink_end_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:ReleaseParticleIndex(blink_end_pfx)
			caster:EmitSound("Hero_Antimage.Blink_in")
end

function am_blink:IsHiddenWhenStolen()
	return false
end


-------------------------------------------
--      SPELL SHIELD
-------------------------------------------

-- Visible Modifiers:
MergeTables(LinkedModifiers,{
	["modifier_am_spellshield_buff_reflect"] = LUA_MODIFIER_MOTION_NONE,
	["modifier_am_spellshield_scepter_ready"] = LUA_MODIFIER_MOTION_NONE,
	["modifier_am_spellshield_scepter_recharge"] = LUA_MODIFIER_MOTION_NONE,
})

-- Hidden Modifiers:
MergeTables(LinkedModifiers,{
	["modifier_am_spellshield_buff_passive"] = LUA_MODIFIER_MOTION_NONE,
})

am_spellshield = am_spellshield or class({})

function am_spellshield:GetAbilityTextureName()
	return "antimage_spell_shield"
end

function am_spellshield:GetBehavior()
	local has_purity = self:GetCaster():HasAbility("am_purity")

	if has_purity then
		local pur_lvl = self:GetCaster():FindAbilityByName("am_purity"):GetLevel()
		if pur_lvl > 1 then return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
		end
	end

	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

-- Declare active skill + visuals
function am_spellshield:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local active_modifier = "modifier_am_spellshield_buff_reflect"
		self.duration = ability:GetSpecialValueFor("active_duration")

		-- Start skill cooldown.
		caster:AddNewModifier(caster, ability, active_modifier, {duration = self.duration})

		-- Run visual + sound
		local shield_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(shield_pfx)
		caster:EmitSound("Hero_Antimage.Counterspell.Cast")
		
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
	end
end

-- Magic resistence modifier
function am_spellshield:GetIntrinsicModifierName()
	return "modifier_am_spellshield_buff_passive"
end

function am_spellshield:GetCooldown( nLevel )
	return self.BaseClass.GetCooldown( self, nLevel )
end

function am_spellshield:IsHiddenWhenStolen()
	return false
end

function SpellReflect(parent, params)
	-- If some spells shouldn't be reflected, enter it into this spell-list
	local exception_spell =
		{
		["rubick_spell_steal"] = true,
		["imba_alchemist_greevils_greed"] = true,
		["imba_alchemist_unstable_concoction"] = true,
		["imba_disruptor_glimpse"] = true,
		["legion_commander_duel"] = true,
		["imba_phantom_assassin_phantom_strike"] = true,
		["phantom_assassin_phantom_strike"] = true,
		["imba_riki_blink_strike"] = true,
		["riki_blink_strike"] = true,
		["imba_rubick_spellsteal"] = true,
		["morphling_replicate"]	= true
	}

	local reflected_spell_name = params.ability:GetAbilityName()
	local target = params.ability:GetCaster()

	-- Does not reflect allies' projectiles for any reason
	if target:GetTeamNumber() == parent:GetTeamNumber() then
		return nil
	end

	-- FOR NOW, UNTIL LOTUS ORB IS DONE
	-- Do not reflect spells if the target has Lotus Orb on, otherwise the game will die hard.
	if target:HasModifier("modifier_item_lotus_orb_active") then
		return nil
	end

	-- I guess all spells need to have a reflected boolean for the lotus interaction to work properly 

	if ( not exception_spell[reflected_spell_name] ) and (not target:HasModifier("modifier_am_spellshield_buff_reflect")) then

		-- If this is a reflected ability, do nothing
		if params.ability.spell_shield_reflect then
			return nil
		end

		local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(reflect_pfx)

		local old_spell = false
		for _,hSpell in pairs(parent.tOldSpells) do
			if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
				old_spell = true
				break
			end
		end
		if old_spell then
			ability = parent:FindAbilityByName(reflected_spell_name)
		else
			ability = parent:AddAbility(reflected_spell_name)
			ability:SetStolen(true)
			ability:SetHidden(true)

			-- Tag ability as a reflection ability
			ability.spell_shield_reflect = true

			-- Modifier counter, and add it into the old-spell list
			ability:SetRefCountsModifiers(true)
			table.insert(parent.tOldSpells, ability)
		end

		ability:SetLevel(params.ability:GetLevel())
		-- Set target & fire spell
		parent:SetCursorCastTarget(target)
		ability:OnSpellStart()
		target:EmitSound("Hero_Antimage.Counterspell.Target")
		
		-- This isn't considered vanilla behavior, but at minimum it should resolve any lingering channeled abilities...
		if ability.OnChannelFinish then
			ability:OnChannelFinish(false)
		end	
	end

	return false
end

function SpellAbsorb(parent, params)
	if params.ability:GetCaster():GetTeamNumber() == parent:GetTeamNumber() then
		return nil
	end

	local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex(reflect_pfx)
	
	return 1
end

modifier_am_spellshield_buff_passive = modifier_am_spellshield_buff_passive or class({})

function modifier_am_spellshield_buff_passive:IsHidden()
	return true
end

function modifier_am_spellshield_buff_passive:IsDebuff()
	return false
end

function modifier_am_spellshield_buff_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_REFLECT_SPELL
	}
end

function modifier_am_spellshield_buff_passive:OnCreated()

	if IsServer() then
		self.duration = self:GetAbility():GetSpecialValueFor("active_duration")
		self.spellshield_max_distance = self:GetAbility():GetSpecialValueFor("spellshield_max_distance")
		self.internal_cooldown = self:GetAbility():GetSpecialValueFor("internal_cooldown")
		self.modifier_ready = "modifier_am_spellshield_scepter_ready"
		self.modifier_recharge = "modifier_am_spellshield_scepter_recharge"

		-- Add the scepter modifier
		if not self:GetParent():HasModifier(self.modifier_ready) then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), self.modifier_ready, {})
		end

		self:GetParent().tOldSpells = {}

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_am_spellshield_buff_passive:OnRefresh()
	self:OnCreated()
end

function modifier_am_spellshield_buff_passive:GetModifierMagicalResistanceBonus(params)
	if not self:GetParent():PassivesDisabled() then
		return self:GetAbility():GetAbilitySpecialValueFor("magic_resistance")
	end
end

function modifier_am_spellshield_buff_passive:GetReflectSpell( params )
	if IsServer() then
		local parent = self:GetParent()
		if parent:HasScepter() and parent:IsRealHero() and not self:GetParent():HasModifier(self.modifier_recharge) then
			if not self:GetParent():PassivesDisabled() then

				--If the targets are too far apart, do nothing
				local distance = (parent:GetAbsOrigin() - params.ability:GetCaster():GetAbsOrigin()):Length2D()
				  if distance > self.spellshield_max_distance then
					 return nil
				  end

				-- Apply the spell reflect
				return SpellReflect(parent, params)
			end
		end
	end
end

function modifier_am_spellshield_buff_passive:GetAbsorbSpell( params )
	if IsServer() then
		local parent = self:GetParent()
		 if parent:HasScepter() and parent:IsRealHero() and not self:GetParent():HasModifier(self.modifier_recharge) then
			if not self:GetParent():PassivesDisabled() then

				-- Start the internal recharge modifier
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), self.modifier_recharge, {duration = self.internal_cooldown})

				-- Apply Spell Absorption
				return SpellAbsorb(parent, params)
			end
		end
		
		return false
	end
end

function modifier_am_spellshield_buff_passive:OnDestroy()
	-- If for some reason this modifier is destroyed (Rubick losing it, for instance), remove the scepter modifier
	if IsServer() then
		if self:GetParent():HasModifier(self.modifier_ready) then
			self:GetParent():RemoveModifierByName(self.modifier_ready)
		end
	end
end

-- Reflect modifier
-- Biggest thanks to Yunten !
modifier_am_spellshield_buff_reflect = modifier_am_spellshield_buff_reflect or class({})

function modifier_am_spellshield_buff_reflect:IsHidden()
	return false
end

function modifier_am_spellshield_buff_reflect:IsDebuff()
	return false
end

function modifier_am_spellshield_buff_reflect:IsPurgable()
	return false
end

function modifier_am_spellshield_buff_reflect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_REFLECT_SPELL
	}
end

-- Initialize old-spell-checker
function modifier_am_spellshield_buff_reflect:OnCreated( params )
	if IsServer() then
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_counter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		
		-- Random numbers
		ParticleManager:SetParticleControl(self.particle, 1, Vector(150, 150, 150))
	end
end

function modifier_am_spellshield_buff_reflect:GetReflectSpell( params )
	return SpellReflect(self:GetParent(), params)
end

function modifier_am_spellshield_buff_reflect:GetAbsorbSpell( params )
	return SpellAbsorb(self:GetParent(), params)
end

-- Deleting old abilities (?)
-- This is bound to the passive modifier, so this is constantly on!  WHAT IS THIS THING DOING?
function modifier_am_spellshield_buff_passive:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=#caster.tOldSpells,1,-1 do
			local hSpell = caster.tOldSpells[i]
			if hSpell:NumModifiersUsingAbility() == 0 and not hSpell:IsChanneling() then
				hSpell:RemoveSelf()
				table.remove(caster.tOldSpells,i)
			end
		end
	end
end

function modifier_am_spellshield_buff_reflect:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end


-- Scepter block Ready modifier
modifier_am_spellshield_scepter_ready = modifier_am_spellshield_scepter_ready or class({})

function modifier_am_spellshield_scepter_ready:IsHidden()
	-- If the caster doesn't have scepter, hide
	if not self:GetParent():HasScepter() then
		return true
	end

	-- If the caster is recharging its scepter reflect, hide
	if self:GetParent():HasModifier("modifier_am_spellshield_scepter_recharge") then
		return true
	end

	-- Otherwise, show normally
	return false
end

function modifier_am_spellshield_scepter_ready:IsPurgable() return false end
function modifier_am_spellshield_scepter_ready:IsDebuff() return false end
function modifier_am_spellshield_scepter_ready:RemoveOnDeath() return false end


-- Scepter block recharge modifier
modifier_am_spellshield_scepter_recharge = modifier_am_spellshield_scepter_recharge or class({})

function modifier_am_spellshield_scepter_recharge:IsHidden()
	-- If the caster doesn't has scepter, hide it
	if not self:GetParent():HasScepter() then
		return true
	end

	return false
end

function modifier_am_spellshield_scepter_recharge:IsPurgable() return false end
function modifier_am_spellshield_scepter_recharge:IsDebuff() return true end
function modifier_am_spellshield_scepter_recharge:RemoveOnDeath() return false end


--TO DO: I want Spellshield change behavior from passive to 
--active by learning purity of will lvl 2, or reduce its Manacost as a bandaid solution
--Active Duration will be influenced by purity, CD by spellshield level  


-------------------------------------------
--      MANA VOID
-------------------------------------------

am_mana_void = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "components/abilities/heroes/hero_antimage", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- AOE Radius
function am_mana_void:GetAOERadius()
	return self:GetSpecialValueFor( "mana_void_aoe_radius" )
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function am_mana_void:OnAbilityPhaseStart( kv )
	local target = self:GetCursorTarget()
	self:PlayEffects1( true )

	return true -- if success
end
function am_mana_void:OnAbilityPhaseInterrupted()
	self:PlayEffects1( false )
end

--------------------------------------------------------------------------------
-- Ability Start
function am_mana_void:OnSpellStart()
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

	-- Purity of Will reducing cooldown
	function am_mana_void:GetCooldown( nLevel )
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	local caster = self:GetCaster()
	
		if caster:HasAbility("am_purity") then
			local void_cd_red = caster:FindAbilityByName("am_purity"):GetSpecialValueFor("void_cd_reduction")
			cooldown = cooldown - void_cd_red
		end

	return cooldown
	end
end

--------------------------------------------------------------------------------
function am_mana_void:PlayEffects1( bStart )
	local sound_cast = "Hero_Antimage.ManaVoidCast"

	if bStart then
		self.target = self:GetCursorTarget()
		EmitSoundOn( sound_cast, self.target )
	else
		StopSoundOn(sound_cast, self.target)
		self.target = nil
	end
end

function am_mana_void:PlayEffects2( target, radius )
	-- Get Resources
	local particle_target = "particles/units/heroes/hero_antimage/antimage_manavoid.vpcf"
	local sound_target = "Hero_Antimage.ManaVoid"

	-- Create Particle
	-- local effect_target = ParticleManager:CreateParticle( particle_target, PATTACH_POINT_FOLLOW, target )
	local effect_target = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_target, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_target, 1, Vector( radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_target )

	-- Create Sound
	EmitSoundOn( sound_target, target )
end



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