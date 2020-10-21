
	item_silver_edge_classic = class({})
	local itemClass = item_silver_edge_classic

	--Active Bonuses Modifier
	modifier_silver_active = class({})
	local buffModifierClass = modifier_silver_active
	local buffModifierName = 'modifier_silver_active'
	LinkLuaModifier(buffModifierName, "items/silver_edge", LUA_MODIFIER_MOTION_NONE)	


	--Passive instrinsic Bonus Modifier
	modifier_silver_edge_passive = class({})
	local modifierClass = modifier_silver_edge_passive
	local modifierName = 'modifier_silver_edge_passive'
	LinkLuaModifier(modifierName, "items/silver_edge", LUA_MODIFIER_MOTION_NONE)


		--Usual Settings
		function itemClass:GetIntrinsicModifierName()
			return modifierName
		end

		function modifierClass:IsHidden()
			return true
		end

		function modifierClass:IsPurgable()
			return false
		end

		function modifierClass:RemoveOnDeath()
    		return false
		end

		function modifierClass:GetAttributes()
			return MODIFIER_ATTRIBUTE_MULTIPLE
		end


--Casting
function itemClass:OnSpellStart()
	local dur = self:GetSpecialValueFor("windwalk_duration")
	local caster = self:GetCaster()

	local sound_cast = "DOTA_Item.InvisibilitySword.Activate"

	-- Create Sound
	EmitSoundOn( sound_cast, caster )

	-- Invis Buff	
	caster:AddNewModifier(caster, self, buffModifierName, { duration = dur })
	
end

-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	local caster = self:GetParent() 

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" )

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_all" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_all" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_all" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "fixed_health_regen" )
	self.hp_reg_perc = self:GetAbility():GetSpecialValueFor( "health_regen_rate" )
	self.hp_reg_amp = self:GetAbility():GetSpecialValueFor( "hp_regen_amp" )	
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )

	self.evasion = self:GetAbility():GetSpecialValueFor( "bonus_evasion" )
end




			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					--MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
					--MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

					MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

					MODIFIER_PROPERTY_HEALTH_BONUS,
					MODIFIER_PROPERTY_MANA_BONUS,
					MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
					MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,					
					MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

					--Add more stuff below
					MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
					MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
					MODIFIER_EVENT_ON_TAKEDAMAGE,
					MODIFIER_PROPERTY_EVASION_CONSTANT,
				}

				return funcs
			end

			function modifierClass:GetModifierEvasion_Constant()
				local caster = self:GetParent()
				if caster:HasModifier(buffModifierName) then return end			
				return self.evasion
			end

				--DMG; ARMOR; MS; AS; MR
				function modifierClass:GetModifierPreAttack_BonusDamage()
					return self.bonus_dmg
				end

				function modifierClass:GetModifierPhysicalArmorBonus()
					return self.bonus_armor
				end

				function modifierClass:GetModifierMoveSpeedBonus_Constant()
					return self.bonus_ms
				end

				function modifierClass:GetModifierAttackSpeedBonus_Constant()
					return self.bonus_as
				end

				function modifierClass:GetModifierMagicalResistanceBonus()
					return self.bonus_mr
				end



				--STR; AGI; INT
				function modifierClass:GetModifierBonusStats_Strength()
					return self.bonus_str
				end

				function modifierClass:GetModifierBonusStats_Agility()
					return self.bonus_agi
				end

				function modifierClass:GetModifierBonusStats_Intellect()
					return self.bonus_int
				end



				--HP; MANA; REG
				function modifierClass:GetModifierHealthBonus()
					return self.bonus_hp
				end

				function modifierClass:GetModifierManaBonus()
					return self.bonus_mana
				end

				function modifierClass:GetModifierConstantHealthRegen()
					return self.hp_reg
				end

				function modifierClass:GetModifierConstantManaRegen()
					local caster = self:GetParent()
					local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
					local regen = self.mana_reg / 100 * int * 0.05
					return regen
				end

				function modifierClass:GetModifierHealthRegenPercentage()
					local k = self:GetStackCount()
					if k == 0 then
						return self.hp_reg_perc
					end
					return
				end				


--#########################
--## Active modifier here
--#########################

function buffModifierClass:OnCreated()
	--References
	local caster = self:GetParent()
	self.phase_ms = self:GetAbility():GetSpecialValueFor( "windwalk_movement_speed" )
	self.i = 0

		--effects
	self:StartIntervalThink(0.05)
end

		function buffModifierClass:IsHidden()
			return false
		end

		function buffModifierClass:IsPurgable()
			return false
		end

		function buffModifierClass:RemoveOnDeath()
    		return true
		end


function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_STATE_CANNOT_MISS,
		MODIFIER_STATE_INVISIBLE,
		MODIFIER_STATE_NO_UNIT_COLLISION,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_START,
	}
	return funcs
end

function buffModifierClass:GetModifierPreAttack_BonusDamage()
	if IsServer() then
		return self:GetAbility():GetSpecialValueFor("windwalk_bonus_damage")
	end
end

function buffModifierClass:GetModifierMoveSpeedBonus_Percentage()
	return self.phase_ms
end


function buffModifierClass:CheckState()
	local fade_time = self:GetAbility():GetSpecialValueFor("windwalk_fade_time")

	if self.i < fade_time then
		local state = {
			[MODIFIER_STATE_CANNOT_MISS] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true
		}
		return state
	else
		local caster = self:GetParent()
		caster:AddNewModifier(caster, self, "modifier_invisible", { duration = dur })
		local state = {
			[MODIFIER_STATE_CANNOT_MISS] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			--[MODIFIER_STATE_INVISIBLE] = true,
		}
		return state		
	end
end 

function buffModifierClass:OnIntervalThink()
	self.i = self.i + 0.05
end

--[[function buffModifierClass:PlayEffects( caster )

		-- Get Resources
		local particle_cast = "particles/generic_hero_status/status_invisibility_start.vpcf"
		local sound_cast = "DOTA_Item.Butterfly"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, caster )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		
end]]

--Visuals
--------------------------------------------------------------------------------
-- Graphics & Animations

function buffModifierClass:GetEffectName()
	return "particles/generic_hero_status/status_invisibility_start.vpcf"
end

function buffModifierClass:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



--Buff Removal Conditions
function buffModifierClass:OnAbilityStart(params)
	self:Destroy()
end

function buffModifierClass:OnAttackLanded(params)
	self:Destroy()
end








--[[





---------------------------------
----         ACTIVE          ----
---------------------------------
item_imba_silver_edge = class({})
LinkLuaModifier("modifier_item_imba_silver_edge_passive", "components/items/item_silver_edge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_silver_edge_invis", "components/items/item_silver_edge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_silver_edge_invis_flying_disabled", "components/items/item_silver_edge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_silver_edge_invis_panic_debuff", "components/items/item_silver_edge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_silver_edge_invis_break_debuff", "components/items/item_silver_edge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_silver_edge_invis_attack_cleave_particle", "components/items/item_silver_edge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_echo_rapier_haste", "components/items/item_echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_echo_rapier_debuff_slow", "components/items/item_echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)

function item_imba_silver_edge:OnSpellStart()
	-- Ability properties
	local caster    =   self:GetCaster()
	local particle_invis_start = "particles/generic_hero_status/status_invisibility_start.vpcf"
	-- Ability parameters
	local duration  =   self:GetSpecialValueFor("invis_duration")
	local fade_time =   self:GetSpecialValueFor("invis_fade_time")

	-- Play cast sound
	EmitSoundOn("DOTA_Item.InvisibilitySword.Activate", caster)

	-- Wait for the fade time to end, then emit the invisibility effect and apply the invis modifier
	Timers:CreateTimer(fade_time, function()
		local particle_invis_start_fx = ParticleManager:CreateParticle(particle_invis_start, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_invis_start_fx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_invis_start_fx)

		caster:AddNewModifier(caster, self, "modifier_item_imba_silver_edge_invis", {duration = duration})
	end)
end

function item_imba_silver_edge:GetIntrinsicModifierName()
	return "modifier_item_imba_silver_edge_passive"
end


---------------------
--- INVIS MODIFIER
---------------------
modifier_item_imba_silver_edge_invis = modifier_item_imba_silver_edge_invis or class({})

-- Modifier properties
function modifier_item_imba_silver_edge_invis:IsDebuff() return false end
function modifier_item_imba_silver_edge_invis:IsHidden() return false end
function modifier_item_imba_silver_edge_invis:IsPurgable() return false end

function modifier_item_imba_silver_edge_invis:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.shadow_rip_damage	= self:GetAbility():GetSpecialValueFor("shadow_rip_damage")
	self.bonus_movespeed        =   self:GetAbility():GetSpecialValueFor("invis_ms_pct")
	self.bonus_attack_damage    =   self:GetAbility():GetSpecialValueFor("invis_damage")
	
	-- Start flying if has not taken damage recently
	if IsServer() then
		if not self:GetParent():FindModifierByName("modifier_item_imba_silver_edge_invis_flying_disabled") then
			self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
		end
	end
end

function modifier_item_imba_silver_edge_invis:OnDestroy()
	if IsServer() then
		if not self:GetParent():FindModifierByName("modifier_silver_edge_invis_flying_disabled") then
			-- Remove flying movement
			self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
			-- Destroy trees to not get stuck
			GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 175, false)
			-- Find a clear space to stand on
			ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 64)
		end
	end
end

-- Phase invis and flying bonuses
function modifier_item_imba_silver_edge_invis:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_CANNOT_MISS] = true -- Attack out of invis cannot miss.
	}
end

function modifier_item_imba_silver_edge_invis:GetPriority()
	return MODIFIER_PRIORITY_NORMAL
end

-- Damage and movespeed bonuses
function modifier_item_imba_silver_edge_invis:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		-- Breaking invis handlers
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_item_imba_silver_edge_invis:GetModifierMoveSpeedBonus_Percentage() return self.bonus_movespeed end

function modifier_item_imba_silver_edge_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_item_imba_silver_edge_invis:OnAttackLanded(params)
	if IsServer() then

		if params.attacker == self:GetParent() then

			local ability 			=	self:GetAbility()
			local attack_particle	=	"particles/item/silver_edge/imba_silver_edge.vpcf"
			local initial_pos
			-- Ability paramaters
			local cleave_damage		 	= ability:GetSpecialValueFor("shadow_rip_damage")
			local cleave_radius_start 	= ability:GetSpecialValueFor("shadow_rip_start_width")
			local cleave_radius_end 	= ability:GetSpecialValueFor("shadow_rip_end_width")
			local cleave_distance 		= ability:GetSpecialValueFor("shadow_rip_distance")
			local panic_duration		= ability:GetSpecialValueFor("panic_duration")
			local break_duration		= ability:GetSpecialValueFor("main_debuff_duration")

			-- Teleport ranged attackers to make the affect go from the target's vector
			if self:GetParent():IsRangedAttacker() then

				initial_pos 	= self:GetParent():GetAbsOrigin()
				local target_pos 	= params.target:GetAbsOrigin()

				-- Offset is necessary, because cleave from Battlefury doesn't work (in any direction) if you are exactly on top of the target unit
				local offset = 100 --dotameters (default melee range is 150 dotameters)

				-- Find the distance vector (distance, but as a vector rather than Length2D)
				-- z is 0 to prevent any wonkiness due to height differences, we'll use the targets height, unmodified
				local distance_vector = Vector(target_pos.x - initial_pos.x, target_pos.y - initial_pos.y, 0)
				-- Normalize it, so the offset can be applied to x/y components, proportionally
				distance_vector = distance_vector:Normalized()

				-- Offset the caster 100 units in front of the target
				target_pos.x = target_pos.x - offset * distance_vector.x
				target_pos.y = target_pos.y - offset * distance_vector.y

				self:GetParent():SetAbsOrigin(target_pos)

				-- Give the dummy which direction to look at
				local direction = (CalculateDirection(params.target, self:GetParent()))

				-- Create a particle for the cleave effect for ranged heroes
				CreateModifierThinker(self:GetParent(), ability, "modifier_item_imba_silver_edge_invis_attack_cleave_particle",
					{duration =1, direction_x = direction.x, direction_y = direction.y, direction_z = direction.z}, target_pos, self:GetParent():GetTeamNumber(), false)
				--end
			else
				-- Do Cleave particle for melee heroes
				local cleave_particle 		= "particles/item/silver_edge/silver_edge_shadow_rip.vpcf"	-- Badass custom shit
				local particle_fx = ParticleManager:CreateParticle(cleave_particle, PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(particle_fx, 0, self:GetParent():GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle_fx)
			end

			-- Find units hit by the cleave (amazing custom function from funcs.lua)
			local enemies = FindUnitsInCone(self:GetParent():GetTeamNumber(),
				CalculateDirection(params.target, self:GetParent()),
				self:GetParent():GetAbsOrigin(),
				cleave_radius_start,
				cleave_radius_end,
				cleave_distance,
				nil,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
				0,
				FIND_ANY_ORDER,
				false)

			-- Damage each unit hit by the cleave and give them the panic modifier
			for _,enemy in pairs(enemies) do
				local damager = self:GetParent()

				ApplyDamage(({victim = enemy,
					attacker = damager,
					ability = ability,
					damage = cleave_damage,
					damage_type = DAMAGE_TYPE_PURE}))

				enemy:AddNewModifier(self:GetParent(), ability, "modifier_item_imba_silver_edge_invis_panic_debuff", {duration = panic_duration * (1 - enemy:GetStatusResistance())})
			end

			-- Give the main target a different, longer modifier
			params.target:AddNewModifier(self:GetParent(), ability, "modifier_item_imba_silver_edge_invis_break_debuff", {duration = break_duration * (1 - params.target:GetStatusResistance())})

			-- Emit custom sound effect
			self:GetParent():EmitSound("Imba.SilverEdgeInvisAttack")

			-- Emit custom slash particle
			local particle_fx = ParticleManager:CreateParticle(attack_particle, PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(particle_fx, 0, params.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_fx)

			-- Teleport ranged attackers to make the affect go from the target's vector
			if self:GetParent():IsRangedAttacker() then
				self:GetParent():SetAbsOrigin(initial_pos)
			end

			-- Remove the invis on attack
			self:Destroy()
			--end
		end
	end
end

function modifier_item_imba_silver_edge_invis:OnAbilityExecuted( keys )
	if IsServer() then
		local parent =	self:GetParent()
		-- Remove the invis on cast
		if keys.unit == parent then
			self:Destroy()
		end
	end
end

function modifier_item_imba_silver_edge_invis:OnTooltip()
	return self.shadow_rip_damage
end

----------------------------------
--- STACKABLE PASSIVE MODIFIER ---
----------------------------------
modifier_item_imba_silver_edge_passive = modifier_item_imba_silver_edge_passive or class({})

-- Modifier properties
function modifier_item_imba_silver_edge_passive:IsHidden()		return true end
function modifier_item_imba_silver_edge_passive:IsPurgable()	return false end
function modifier_item_imba_silver_edge_passive:RemoveOnDeath() return false end
function modifier_item_imba_silver_edge_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_imba_silver_edge_passive:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() return end
        self.echo_ready = true
    end

	self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")

	-- Ability parameters
	if self:GetParent():IsHero() and self:GetAbility() then
		self:CheckUnique(true)
	end
end

-- Attack speed, damage and stat bonuses
function modifier_item_imba_silver_edge_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,            -- Flying disabler handler
		MODIFIER_EVENT_ON_ATTACK,
	}
end

function modifier_item_imba_silver_edge_passive:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_item_imba_silver_edge_passive:GetModifierAttackSpeedBonus_Constant()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end

function modifier_item_imba_silver_edge_passive:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifier_item_imba_silver_edge_passive:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifier_item_imba_silver_edge_passive:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
	end
end

function modifier_item_imba_silver_edge_passive:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			local parent            =   self:GetParent()
			local disable_duration  =   self:GetAbility():GetSpecialValueFor("invis_flying_damage_disable_duration")

			if params.attacker:IsHeroDamage(params.damage) then
				-- Disable flying
				parent:AddNewModifier(parent, self, "modifier_item_imba_silver_edge_invis_flying_disabled", {duration = disable_duration})
			end
		end
	end
end

function modifier_item_imba_silver_edge_passive:OnAttack(keys)
	local item = self:GetAbility()
	local parent = self:GetParent()

	if keys.attacker == parent and item and not parent:IsIllusion() and parent:FindAllModifiersByName(self:GetName())[1] == self then
		if not parent:IsRangedAttacker() then 
			if self.echo_ready == true and not keys.no_attack_cooldown then
				self.echo_ready = false
				self:StartIntervalThink(GetItemKV("item_imba_echo_sabre", "AbilityCooldown"))
				parent:AddNewModifier(parent, item, "modifier_imba_echo_rapier_haste", {})

				if not keys.target:IsBuilding() and not keys.target:IsOther() then
					keys.target:AddNewModifier(parent, self:GetAbility(), "modifier_imba_echo_rapier_debuff_slow", {duration = self.slow_duration})
				end
			end
		end

		if parent:HasModifier("modifier_imba_echo_rapier_haste") and (not parent:HasAbility("imba_slark_essence_shift") or parent:FindAbilityByName("imba_slark_essence_shift"):GetCooldownTime() < parent:FindAbilityByName("imba_slark_essence_shift"):GetEffectiveCooldown(parent:FindAbilityByName("imba_slark_essence_shift"):GetLevel())) then
			local mod = parent:FindModifierByName("modifier_imba_echo_rapier_haste")
			mod:DecrementStackCount()
			if mod:GetStackCount() < 1 then
				mod:Destroy()
			end
		end
	end
end

function modifier_item_imba_silver_edge_passive:OnIntervalThink()
	self:StartIntervalThink(-1)
	self.echo_ready = true
end

--- Flying disabler handler
modifier_item_imba_silver_edge_invis_flying_disabled = modifier_item_imba_silver_edge_invis_flying_disabled or class({})

-- Modifier properties
function modifier_item_imba_silver_edge_invis_flying_disabled:IsDebuff() return false end
function modifier_item_imba_silver_edge_invis_flying_disabled:IsHidden() return true end
function modifier_item_imba_silver_edge_invis_flying_disabled:IsPurgable() return false end

function modifier_item_imba_silver_edge_invis_flying_disabled:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		-- flying disabled
		self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)

		-- Destroy trees to not get stuck
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 175, false)
		-- Find a clear space to stand on
		ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 64)
	end
end

function modifier_item_imba_silver_edge_invis_flying_disabled:OnDestroy()
	if IsServer() then
		-- flying enabled
		if self:GetParent():FindModifierByName("modifier_item_imba_silver_edge_invis") then
			self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
		end
	end
end

-----------------------------
--- PANIC DEBUFF MODIFIER
-----------------------------
modifier_item_imba_silver_edge_invis_panic_debuff = modifier_item_imba_silver_edge_invis_panic_debuff or class({})

-- Modifier properties
function modifier_item_imba_silver_edge_invis_panic_debuff:IsDebuff() return true end
function modifier_item_imba_silver_edge_invis_panic_debuff:IsHidden() return false end
function modifier_item_imba_silver_edge_invis_panic_debuff:IsPurgable() return true end

-- Turnrate slow
function modifier_item_imba_silver_edge_invis_panic_debuff:OnCreated()
	if not self:GetAbility() then self:Destroy() return end

	local ability   =   self:GetAbility()

	self.turnrate   		= ability:GetSpecialValueFor("panic_turnrate_slow")
	self.damage_reduction	= ability:GetSpecialValueFor("panic_damage_reduction")
end

function modifier_item_imba_silver_edge_invis_panic_debuff:CheckState()
	return {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}
end

function modifier_item_imba_silver_edge_invis_panic_debuff:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_item_imba_silver_edge_invis_panic_debuff:GetModifierTurnRate_Percentage() return self.turnrate end
function modifier_item_imba_silver_edge_invis_panic_debuff:GetModifierTotalDamageOutgoing_Percentage() return self.damage_reduction end

-- Particle
function modifier_item_imba_silver_edge_invis_panic_debuff:GetEffectName()
	return "particles/item/silver_edge/silver_edge_panic_debuff.vpcf"
end

function modifier_item_imba_silver_edge_invis_panic_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

---------------------------------------------
--- BREAK DEBUFF MODIFIER (main target only)
---------------------------------------------
modifier_item_imba_silver_edge_invis_break_debuff = modifier_item_imba_silver_edge_invis_break_debuff or class({})

-- Modifier properties
function modifier_item_imba_silver_edge_invis_break_debuff:IsDebuff() return true end
function modifier_item_imba_silver_edge_invis_break_debuff:IsHidden() return false end
function modifier_item_imba_silver_edge_invis_break_debuff:IsPurgable() return false end

-- Turnrate slow
function modifier_item_imba_silver_edge_invis_break_debuff:OnCreated()
	if not self:GetAbility() then self:Destroy() return end

	self.damage_reduction	=	self:GetAbility():GetSpecialValueFor("panic_damage_reduction")
	self.heal_reduction		=	self:GetAbility():GetSpecialValueFor("heal_reduction") * (-1)

end

function modifier_item_imba_silver_edge_invis_break_debuff:CheckState()
	return {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}
end

function modifier_item_imba_silver_edge_invis_break_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_item_imba_silver_edge_invis_break_debuff:GetModifierTotalDamageOutgoing_Percentage()
	-- Wait until the other debuff is over to reduce damage (to prevent them stacking)
	if self:GetParent():HasModifier("modifier_item_imba_silver_edge_invis_panic_debuff") then
		return 0
	else
		return self.damage_reduction
	end
end

function modifier_item_imba_silver_edge_invis_break_debuff:GetModifierHealAmplify_PercentageTarget()
	return self.heal_reduction
end

function modifier_item_imba_silver_edge_invis_break_debuff:GetModifierHPRegenAmplify_Percentage()
	return self.heal_reduction
end

function modifier_item_imba_silver_edge_invis_break_debuff:OnTooltip()
	return self.heal_reduction
end

-- function modifier_item_imba_silver_edge_invis_break_debuff:Custom_AllHealAmplify_Percentage()
	-- return self.heal_reduction
-- end

--- PARTICLE FOR RANGED CLEAVE
modifier_item_imba_silver_edge_invis_attack_cleave_particle = modifier_item_imba_silver_edge_invis_attack_cleave_particle or class({})

-- Modifier properties
function modifier_item_imba_silver_edge_invis_attack_cleave_particle:IsDebuff() return false end
function modifier_item_imba_silver_edge_invis_attack_cleave_particle:IsHidden() return true end
function modifier_item_imba_silver_edge_invis_attack_cleave_particle:IsPurgable() return false end

function modifier_item_imba_silver_edge_invis_attack_cleave_particle:OnCreated(params)
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	if IsServer() then
		-- Make the dummy face towards the target for the cleave effect particle
		local direction = Vector(params.direction_x, params.direction_y, params.direction_z)
		self:GetParent():SetForwardVector(direction)

		-- Emit cleave particle
		local cleave_particle 		= "particles/item/silver_edge/silver_edge_shadow_rip.vpcf"	-- Badass custom shit
		local particle_fx = ParticleManager:CreateParticle(cleave_particle, PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle_fx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_fx)

	end
end

function modifier_item_imba_silver_edge_invis_attack_cleave_particle:OnDestroy()
	if IsServer() then
		self:GetParent():ForceKill(false)
	end
end




-- Shared visible modifiers
LinkLuaModifier("modifier_imba_echo_rapier_haste", "components/items/item_echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_echo_rapier_debuff_slow", "components/items/item_echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
-------------------------------------------
--				ECHO SABRE
-------------------------------------------
LinkLuaModifier("modifier_imba_echo_sabre", "components/items/item_echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_echo_sabre_passive", "components/items/item_echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
-------------------------------------------
item_imba_echo_sabre = item_imba_echo_sabre or class({})
-------------------------------------------
function item_imba_echo_sabre:GetIntrinsicModifierName()
	return "modifier_imba_echo_sabre_passive"
end

function item_imba_echo_sabre:GetAbilityTextureName()
	return "custom/imba_echo_sabre"
end

modifier_imba_echo_sabre = modifier_imba_echo_sabre or class({})

function modifier_imba_echo_sabre:IsPurgable()		return false end
function modifier_imba_echo_sabre:RemoveOnDeath()	return false end
function modifier_imba_echo_sabre:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_echo_sabre:IsHidden() return true end

function modifier_imba_echo_sabre:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	local item = self:GetAbility()
	self.parent = self:GetParent()
	if self.parent:IsHero() and item then
		self.bonus_intellect = item:GetSpecialValueFor("bonus_intellect")
		self.bonus_strength = item:GetSpecialValueFor("bonus_strength")
		self.bonus_attack_speed = item:GetSpecialValueFor("bonus_attack_speed")
		self.bonus_damage = item:GetSpecialValueFor("bonus_damage")
		self.bonus_mana_regen = item:GetSpecialValueFor("bonus_mana_regen")
		self.slow_duration = item:GetSpecialValueFor("slow_duration")
	end
end

function modifier_imba_echo_sabre:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_imba_echo_sabre:OnAttack(keys)
	local item = self:GetAbility()
	local parent = self:GetParent()
	
	if keys.attacker == parent and item and not parent:IsIllusion() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self and not self:GetParent():HasItemInInventory("item_imba_reverb_rapier") then
		if not parent:IsRangedAttacker() then 
			if item:IsCooldownReady() and not keys.no_attack_cooldown then
				item:UseResources(false,false,true)
				parent:AddNewModifier(parent, item, "modifier_imba_echo_rapier_haste", {})
				if not keys.target:IsBuilding() and not keys.target:IsOther() then
					keys.target:AddNewModifier(self.parent, self:GetAbility(), "modifier_imba_echo_rapier_debuff_slow", {duration = self.slow_duration})
				end
			end
		end
		
		if parent:HasModifier("modifier_imba_echo_rapier_haste") and (not parent:HasAbility("imba_slark_essence_shift") or parent:FindAbilityByName("imba_slark_essence_shift"):GetCooldownTime() < parent:FindAbilityByName("imba_slark_essence_shift"):GetEffectiveCooldown(parent:FindAbilityByName("imba_slark_essence_shift"):GetLevel())) then
			local mod = parent:FindModifierByName("modifier_imba_echo_rapier_haste")
			mod:DecrementStackCount()
			if mod:GetStackCount() < 1 then
				mod:Destroy()
			end
		end
	end
end

function modifier_imba_echo_sabre:OnRemoved()
	if not IsServer() then return end
	if (self:GetParent():FindModifierByName("modifier_imba_echo_rapier_haste")) then
		self:GetParent():FindModifierByName("modifier_imba_echo_rapier_haste"):Destroy()
	end
end

-------------------------------------------
modifier_imba_echo_sabre_passive = modifier_imba_echo_sabre_passive or class({})

function modifier_imba_echo_sabre_passive:IsHidden()		return true end
function modifier_imba_echo_sabre_passive:IsPurgable()		return false end
function modifier_imba_echo_sabre_passive:RemoveOnDeath()	return false end
function modifier_imba_echo_sabre_passive:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_echo_sabre_passive:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() return end

		self.echo_modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_echo_sabre", {})
	end

	local item = self:GetAbility()
	self.parent = self:GetParent()
	if self.parent:IsHero() and item then
		self.bonus_intellect = item:GetSpecialValueFor("bonus_intellect")
		self.bonus_strength = item:GetSpecialValueFor("bonus_strength")
		self.bonus_attack_speed = item:GetSpecialValueFor("bonus_attack_speed")
		self.bonus_damage = item:GetSpecialValueFor("bonus_damage")
		self.bonus_mana_regen = item:GetSpecialValueFor("bonus_mana_regen")
		self.slow_duration = item:GetSpecialValueFor("slow_duration")
	end
end

function modifier_imba_echo_sabre_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
end

function modifier_imba_echo_sabre_passive:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_imba_echo_sabre_passive:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_imba_echo_sabre_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_imba_echo_sabre_passive:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_imba_echo_sabre_passive:GetModifierConstantManaRegen()
	return self.bonus_mana_regen
end

function modifier_imba_echo_sabre_passive:OnRemoved()
	if not IsServer() then return end

	if self.echo_modifier then
		self.echo_modifier:Destroy()
	end
end

-------------------------------------------
--				REVERB RAPIER
-------------------------------------------
LinkLuaModifier("modifier_imba_reverb_rapier_passive", "components/items/item_echo_sabre.lua", LUA_MODIFIER_MOTION_NONE)
-------------------------------------------
item_imba_reverb_rapier = item_imba_reverb_rapier or class({})
-------------------------------------------
function item_imba_reverb_rapier:GetIntrinsicModifierName()
	return "modifier_imba_reverb_rapier_passive"
end

function item_imba_reverb_rapier:GetAbilityTextureName()
	return "custom/imba_reverb_rapier"
end

-------------------------------------------
modifier_imba_reverb_rapier_passive = modifier_imba_reverb_rapier_passive or class({})

function modifier_imba_reverb_rapier_passive:IsHidden()		return true end
function modifier_imba_reverb_rapier_passive:IsPurgable()		return false end
function modifier_imba_reverb_rapier_passive:RemoveOnDeath()	return false end
function modifier_imba_reverb_rapier_passive:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_reverb_rapier_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_imba_reverb_rapier_passive:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	local item = self:GetAbility()
	self.parent = self:GetParent()
	if self.parent:IsHero() and item then
		self.bonus_intellect = item:GetSpecialValueFor("bonus_intellect")
		self.bonus_strength = item:GetSpecialValueFor("bonus_strength")
		self.bonus_attack_speed = item:GetSpecialValueFor("bonus_attack_speed")
		self.bonus_damage = item:GetSpecialValueFor("bonus_damage")
		self.bonus_mana_regen = item:GetSpecialValueFor("bonus_mana_regen")
		self.slow_duration = item:GetSpecialValueFor("slow_duration")
	end
end

function modifier_imba_reverb_rapier_passive:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_imba_reverb_rapier_passive:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_imba_reverb_rapier_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_imba_reverb_rapier_passive:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_imba_reverb_rapier_passive:GetModifierConstantManaRegen()
	return self.bonus_mana_regen
end

function modifier_imba_reverb_rapier_passive:OnAttack(keys)
	local item = self:GetAbility()
	local parent = self:GetParent()
	
	if keys.attacker == parent and item and not parent:IsIllusion() and self:GetParent():FindAllModifiersByName(self:GetName())[1] == self then
		if not parent:IsRangedAttacker() then 
			if item:IsCooldownReady() and not keys.no_attack_cooldown then
				item:UseResources(false,false,true)
				parent:AddNewModifier(parent, item, "modifier_imba_echo_rapier_haste", {})
				if not keys.target:IsBuilding() and not keys.target:IsOther() then
					keys.target:AddNewModifier(self.parent, self:GetAbility(), "modifier_imba_echo_rapier_debuff_slow", {duration = self.slow_duration})
				end
			end
		end
			
		if parent:HasModifier("modifier_imba_echo_rapier_haste") and (not parent:HasAbility("imba_slark_essence_shift") or parent:FindAbilityByName("imba_slark_essence_shift"):GetCooldownTime() < parent:FindAbilityByName("imba_slark_essence_shift"):GetEffectiveCooldown(parent:FindAbilityByName("imba_slark_essence_shift"):GetLevel())) then
			local mod = parent:FindModifierByName("modifier_imba_echo_rapier_haste")
			mod:DecrementStackCount()
			if mod:GetStackCount() < 1 then
				mod:Destroy()
			end
		end
	end
end

function modifier_imba_reverb_rapier_passive:OnRemoved()
	if not IsServer() then return end
	if (self:GetParent():FindModifierByName("modifier_imba_echo_rapier_haste")) then
		self:GetParent():FindModifierByName("modifier_imba_echo_rapier_haste"):Destroy()
	end
end

-------------------------------------------
modifier_imba_echo_rapier_haste = modifier_imba_echo_rapier_haste or class({})
function modifier_imba_echo_rapier_haste:IsDebuff() return false end
function modifier_imba_echo_rapier_haste:IsHidden() return true end
function modifier_imba_echo_rapier_haste:IsPurgable() return false end
function modifier_imba_echo_rapier_haste:IsPurgeException() return false end
function modifier_imba_echo_rapier_haste:IsStunDebuff() return false end
function modifier_imba_echo_rapier_haste:RemoveOnDeath() return true end
-------------------------------------------

function modifier_imba_echo_rapier_haste:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	local item = self:GetAbility()
	self.parent = self:GetParent()
	if item then
		self.slow_duration = item:GetSpecialValueFor("slow_duration")
		local current_speed = self.parent:GetIncreasedAttackSpeed()
		if item:GetName() == "item_imba_reverb_rapier" then
			current_speed = current_speed * 3
		else
			current_speed = current_speed * 2
		end
		local max_hits = item:GetSpecialValueFor("max_hits")
		self:SetStackCount(max_hits)
		self.attack_speed_buff = math.max(item:GetSpecialValueFor("attack_speed_buff"), current_speed)
	end
end

function modifier_imba_echo_rapier_haste:OnRefresh()
	self:OnCreated()
end

function modifier_imba_echo_rapier_haste:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_imba_echo_rapier_haste:OnAttack(keys)
	if self.parent == keys.attacker and not keys.target:IsBuilding() and not keys.target:IsOther() then
		keys.target:AddNewModifier(self.parent, self:GetAbility(), "modifier_imba_echo_rapier_debuff_slow", {duration = self.slow_duration * (1 - keys.target:GetStatusResistance())})
	end
end

function modifier_imba_echo_rapier_haste:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_buff
end
-------------------------------------------
modifier_imba_echo_rapier_debuff_slow = modifier_imba_echo_rapier_debuff_slow or class({})
function modifier_imba_echo_rapier_debuff_slow:IsDebuff() return true end
function modifier_imba_echo_rapier_debuff_slow:IsHidden() return false end
function modifier_imba_echo_rapier_debuff_slow:IsPurgable() return true end
function modifier_imba_echo_rapier_debuff_slow:IsStunDebuff() return false end
function modifier_imba_echo_rapier_debuff_slow:RemoveOnDeath() return true end
-------------------------------------------

function modifier_imba_echo_rapier_debuff_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_imba_echo_rapier_debuff_slow:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
	
	local item = self:GetAbility()
	if item then
		self.movement_slow = item:GetSpecialValueFor("movement_slow") * (-1)
		self.attack_speed_slow = item:GetSpecialValueFor("attack_speed_slow") * (-1)
	end
end

function modifier_imba_echo_rapier_debuff_slow:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_slow
end

function modifier_imba_echo_rapier_debuff_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_slow
end

function modifier_imba_echo_rapier_debuff_slow:GetTexture()
	if self:GetAbility():GetName() == "item_imba_reverb_rapier" then
		return "custom/imba_reverb_rapier"
	else
		return "custom/imba_echo_sabre"
	end
end

]]