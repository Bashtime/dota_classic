--	Created by Bashtime, 01.05.2020

naix_rage = class({})
local abilityClass = naix_rage
local abilityName = 'naix_rage'


modifier_naix_rage = class({})
local modifierClass = modifier_naix_rage
local modifierName = 'modifier_naix_rage'
LinkLuaModifier( modifierName, "heroes/naix/naix_rage", LUA_MODIFIER_MOTION_NONE )


function abilityClass:OnCreated()
	self.dur = self:GetSpecialValueFor("rage_duration")
end

function abilityClass:OnUpgrade()
	self.dur = self:GetSpecialValueFor("rage_duration")
end

function abilityClass:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()	

	-- Get Resources
	local sound_cast = "DOTA_Item.BlackKingBar.Activate"
	--local sound_cast2 = "Hero_LifeStealer.Rage"
	-- Create Sound
	EmitSoundOn( sound_cast, caster )
	--EmitSoundOn( sound_cast2, caster )


	caster:Purge(false, true, false, false, false)
	caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			modifierName, -- modifier name
			{ duration = self.dur } -- kv
		)

end



--------------------------------------------------------------------------------
-- Passive Modifier

function modifierClass:IsHidden()
	return false
end

function modifierClass:IsPurgable()
	return false
end

	----------------------------------
	--	Modifier Effects
	----------------------------------

	function modifierClass:OnCreated()
		local caster = self:GetParent()
		self.dmg = self:GetAbility():GetSpecialValueFor( "rage_damage" )
		--local particle_cast = "particles/units/heroes/hero_life_stealer/life_stealer_rage_bkb01.vpcf"
		local rage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    	ParticleManager:SetParticleControlEnt(rage_particle, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    	self:AddParticle(rage_particle, false, false, -1, true, false)
	end

	function modifierClass:OnRefresh()
		self.dmg = self:GetAbility():GetSpecialValueFor( "rage_damage" )
	end

	function modifierClass:DeclareFunctions()
		local funcs = {
			MODIFIER_STATE_MAGIC_IMMUNE,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_EVENT_ON_ATTACK_START,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		}
		return funcs
	end

	function modifierClass:CheckState()
		local state = {
				[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			}
		return state		
	end


	function modifierClass:OnAttackStart( params )

		local attacker = self:GetParent()

		if params.attacker == attacker then

			local target = params.target
			local result = UnitFilter(
				target,	-- Target Filter
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
				DOTA_UNIT_TARGET_FLAG_NONE,	-- Unit Flag
				self:GetParent():GetTeamNumber()	-- Team reference
				)
	
			if result == UF_SUCCESS then

				local enemy_hp = target:GetHealth()
				self.damage = enemy_hp * self.dmg / 100
			else
				self.damage = 0
			end
		end
	end

	function modifierClass:GetModifierPreAttack_BonusDamage()
		return self.damage
	end

	function modifierClass:GetModifierAttackRangeBonus()
		return self:GetAbility():GetSpecialValueFor("bonus_range")
	end

	function modifierClass:GetModifierModelScale()
		return self:GetAbility():GetSpecialValueFor("scaling")
	end

	--------------------------------------------------------------------------------
	-- Graphics & Animations
	function modifierClass:GetEffectName()
		return "particles/units/heroes/hero_life_stealer/life_stealer_rage_bkb01.vpcf"
	end

	function modifierClass:GetEffectAttachType()
		return PATTACH_ABSORIGIN_FOLLOW
	end


