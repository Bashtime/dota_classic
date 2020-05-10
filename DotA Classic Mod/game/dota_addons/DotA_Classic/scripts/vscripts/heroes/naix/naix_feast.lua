--	Created by Bashtime, 29.04.2020


naix_feast = class({})
local abilityClass = naix_feast
local abilityName = 'naix_feast'

modifier_naix_feast = class({})
local modifierClass = modifier_naix_feast
local modifierName = 'modifier_naix_feast'
LinkLuaModifier( modifierName, "heroes/naix/naix_feast", LUA_MODIFIER_MOTION_NONE )


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


	--------------------------------------------
	-- Modifier Effects
	function modifierClass:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
		}
		return funcs
	end

	function modifierClass:OnTakeDamage( params )



		if IsServer() and (not self:GetParent():PassivesDisabled()) then
		
			local attacker = self:GetParent()

			if params.attacker == attacker 
				and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK
				and attacker:GetHealth() > 0
				and attacker:IsRealHero()  
			then
				local damage = params.damage
				local target = params.unit
				local flHeal = params.damage * self:GetAbility():GetSpecialValueFor( "lifesteal" ) / 100

				local result = UnitFilter(
						target,	-- Target Filter
						DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
						DOTA_UNIT_TARGET_FLAG_NONE,	-- Unit Flag
						self:GetParent():GetTeamNumber()	-- Team reference
						)
	
				if result == UF_SUCCESS then
					attacker:Heal(flHeal, attacker)
					self:PlayEffects( attacker )
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, flHeal, nil)
				end
			end
		end
	end


	function modifierClass:PlayEffects( target )
		-- Get Resources
		local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"
		--local sound_cast = "Hero_Antimage.ManaBreak"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, target )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		--EmitSoundOn( sound_cast, target )
	end

