--	Created by Bashtime, 29.04.2020


naix_rotten_teeth = class({})
local abilityClass = naix_rotten_teeth
local abilityName = 'naix_rotten_teeth'

modifier_naix_rotten_teeth = class({})
local modifierClass = modifier_naix_rotten_teeth
local modifierName = 'modifier_naix_rotten_teeth'
LinkLuaModifier( modifierName, "heroes/naix/naix_rotten_teeth", LUA_MODIFIER_MOTION_NONE )

--Slow Debuff
modifier_naix_rotten_teeth_slow = class({})
local debuffModifierClass = modifier_naix_rotten_teeth_slow
local debuffModifierName = 'modifier_naix_rotten_teeth_slow'
LinkLuaModifier( debuffModifierName, "heroes/naix/naix_rotten_teeth", LUA_MODIFIER_MOTION_NONE )


function abilityClass:GetIntrinsicModifierName()
	return modifierName
end

--------------------------------------------------------------------------------
-- Passive Modifier

function modifierClass:IsHidden()
	return true
end

function modifierClass:IsPurgable()
	return false
end

	----------------------------------
	--	Modifier Effects
	----------------------------------

	function modifierClass:OnCreated()
		self.dur = self:GetAbility():GetSpecialValueFor("slow_duration")
	end

	function modifierClass:OnRefresh()
		self.dur = self:GetAbility():GetSpecialValueFor("slow_duration")
	end


	function modifierClass:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
		return funcs
	end

	function modifierClass:OnAttackLanded(params)

		if (not self:GetParent():PassivesDisabled()) then
		
			local attacker = self:GetParent()
			

			if params.attacker == attacker then
				self:PlayEffects( params.target )		
				params.target:AddNewModifier(attacker, self:GetAbility(), debuffModifierName, { duration = self.dur })
			end
		end
	end


	function modifierClass:PlayEffects( target )
		-- Get Resources
		local particle_cast = "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds_impact_slash_splatter.vpcf"
		--local sound_cast = "Hero_LifeStealer.OpenWounds"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		EmitSoundOn( sound_cast, target )
	end



-------------------------------
-- Debuff Slow Modifier

function debuffModifierClass:IsHidden()
	return false
end

function debuffModifierClass:IsPurgable()
	return true
end

function debuffModifierClass:IsDebuff()
	return true
end

	function debuffModifierClass:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		}
		return funcs
	end

		function debuffModifierClass:GetModifierMoveSpeedBonus_Percentage()
			return -self:GetAbility():GetSpecialValueFor("ms_slow")
		end


	-- Damage Part
	function debuffModifierClass:OnCreated()

		local dps = self:GetAbility():GetSpecialValueFor("dps") / self:GetAbility():GetSpecialValueFor("ticks_per_sec")
		local ticks = 1 / self:GetAbility():GetSpecialValueFor("ticks_per_sec")

		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = dps,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
		self:StartIntervalThink(ticks)
		self:OnIntervalThink()
	end

	function debuffModifierClass:OnRefresh()

		local dps = self:GetAbility():GetSpecialValueFor("dps") / self:GetAbility():GetSpecialValueFor("ticks_per_sec")

		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = dps,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
	end


	function debuffModifierClass:OnIntervalThink()
		if IsServer() then
			ApplyDamage(self.damageTable)
		end
	end