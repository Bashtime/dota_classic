	item_silver_edge_classic = class({})
	local itemClass = item_silver_edge_classic

	--Active Bonuses Modifier
	modifier_silver_active = class({})
	local buffModifierClass = modifier_silver_active
	local buffModifierName = 'modifier_silver_active'
	LinkLuaModifier(buffModifierName, "items/silver_edge", LUA_MODIFIER_MOTION_NONE)	

		--Active Debuff Modifier
		modifier_silver_debuff = class({})
		local debuffModifierClass = modifier_silver_debuff
		local debuffModifierName = 'modifier_silver_debuff'
		LinkLuaModifier(debuffModifierName, "items/silver_edge", LUA_MODIFIER_MOTION_NONE)

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
	local caster = self:GetCaster()
	local sound_cast = "DOTA_Item.InvisibilitySword.Activate"
	-- Create Sound
	EmitSoundOn( sound_cast, caster )

	local particle_invis_start = "particles/generic_hero_status/status_invisibility_start.vpcf"

	-- Ability parameters
	local dur  =   self:GetSpecialValueFor("invis_duration")
	local fade_time =   self:GetSpecialValueFor("invis_fade_time")

	-- Wait for the fade time to end, then emit the invisibility effect and apply the invis modifier
	Timers:CreateTimer(fade_time, function()
		local particle_invis_start_fx = ParticleManager:CreateParticle(particle_invis_start, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_invis_start_fx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_invis_start_fx)

		caster:AddNewModifier(caster, self, buffModifierName, { duration = dur })
	end)
end


-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()
	local caster = self:GetParent() 

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_all" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_all" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_all" )
end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,

					MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
				}

				return funcs
			end

				--DMG; ARMOR; MS; AS; MR
				function modifierClass:GetModifierPreAttack_BonusDamage()
					return self.bonus_dmg
				end

				function modifierClass:GetModifierAttackSpeedBonus_Constant()
					return self.bonus_as
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
			


--#########################
--## Active modifier here
--#########################

function buffModifierClass:OnCreated()
	--References
	self.phase_ms = self:GetAbility():GetSpecialValueFor( "invis_ms_pct" )
	self.invis_dmg = self:GetAbility():GetSpecialValueFor("invis_damage")
end

		function buffModifierClass:IsHidden() return false end
		function buffModifierClass:IsPurgable() return false end
		function buffModifierClass:RemoveOnDeath() return true end


function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_STATE_CANNOT_MISS,
		MODIFIER_STATE_INVISIBLE,
		MODIFIER_STATE_NO_UNIT_COLLISION,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ATTACK_START,
	}
	return funcs
end

function buffModifierClass:GetModifierPreAttack_BonusDamage()
	if IsServer() then
		return self.invis_dmg
	end
end

function buffModifierClass:GetModifierMoveSpeedBonus_Percentage()
	return self.phase_ms
end

function buffModifierClass:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_CANNOT_MISS] = true -- Attack out of invis cannot miss.
	}
end 

function buffModifierClass:OnAttackStart(keys)
	if keys.target:IsBuilding() then 
		self.invis_dmg = 0 
	else
		self.invis_dmg = self:GetAbility():GetSpecialValueFor("invis_damage")
	end
end

--Buff Removal Conditions
function buffModifierClass:OnAbilityExecuted( keys )
	if IsServer() then
		local parent =	self:GetParent()
		-- Remove the invis on cast
		if keys.unit == parent then
			self:Destroy()
		end
	end
end

function buffModifierClass:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then

			local ability 			=	self:GetAbility()
			
			-- Ability paramaters
			local break_duration		= ability:GetSpecialValueFor("backstab_duration")

			-- Give the main target the break modifier
			if not (params.target:IsBuilding() or params.target:IsMagicImmune()) then
				params.target:AddNewModifier(self:GetParent(), ability, debuffModifierName, {duration = break_duration * (1 - params.target:GetStatusResistance())})
			end

			-- Emit custom sound effect
			self:GetParent():EmitSound("Item.SilverEdgeInvisAttack")

			self:Destroy()
		end
	end
end

function buffModifierClass:GetModifierInvisibilityLevel()
	return 1
end

function buffModifierClass:GetPriority()
	return MODIFIER_PRIORITY_NORMAL
end


---------------------------------------------
--- BREAK DEBUFF MODIFIER 
---------------------------------------------

-- Modifier properties
function debuffModifierClass:IsDebuff() return true end
function debuffModifierClass:IsHidden() return false end
function debuffModifierClass:IsPurgable() return false end

-- Turnrate slow
function debuffModifierClass:OnCreated()
	if not self:GetAbility() then self:Destroy() return end

	local attack_particle	=	"particles/items3_fx/silver_edge.vpcf"
	self.damage_reduction	=	self:GetAbility():GetSpecialValueFor("backstab_reduction")
	self.heal_reduction		=	self:GetAbility():GetSpecialValueFor("backstab_heal_reduction") * (-1)
	self.turnrate 			=	self:GetAbility():GetSpecialValueFor("turnrate_slow")

	-- Emit custom slash particle
	self.particle_fx = ParticleManager:CreateParticle(attack_particle, PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(self.particle_fx, 0, self:GetParent():GetAbsOrigin())
end

function debuffModifierClass:OnDestroy()
	ParticleManager:DestroyParticle(self.particle_fx, false)
	ParticleManager:ReleaseParticleIndex(self.particle_fx)
end

function debuffModifierClass:CheckState()
	return {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}
end

function debuffModifierClass:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		--MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		--MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}
end

function debuffModifierClass:GetModifierTotalDamageOutgoing_Percentage()
	return self.damage_reduction
end

function debuffModifierClass:GetModifierHealAmplify_PercentageTarget()
	return self.heal_reduction
end

function debuffModifierClass:GetModifierHPRegenAmplify_Percentage()
	return self.heal_reduction
end

function debuffModifierClass:GetModifierTurnRate_Percentage() return self.turnrate end
