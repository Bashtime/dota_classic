modifier_am_mana_break_elf = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_am_mana_break_elf:IsHidden()
	return true
end

function modifier_am_mana_break_elf:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_am_mana_break_elf:OnCreated( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" ) -- special value
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
	self.illu_efficency = self:GetAbility():GetSpecialValueFor( "illusion_percentage" ) / 100 -- special value
end

function modifier_am_mana_break_elf:OnRefresh( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" ) -- special value
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
	self.illu_efficency = self:GetAbility():GetSpecialValueFor( "illusion_percentage" ) / 100 -- special value
end

function modifier_am_mana_break_elf:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_am_mana_break_elf:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_am_mana_break_elf:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		
		local attacker = self:GetParent()

		-- purity of will range bonus 
		local purity_of_will = attacker:FindAbilityByName("antimage_counterspell") 
		local purity_lvl 

		if purity_of_will ~= nil then
			purity_lvl = purity_of_will:GetLevel() - 1
		end


		local target = params.target
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MANA_ONLY,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then
			local mana_burn =  math.min( target:GetMana(), self.mana_break )

			if purity_lvl ~= nil then
				-- add percentage mana burn
				local percbonus = purity_of_will:GetLevelSpecialValueFor("mana_burn_perc", purity_lvl)

				if attacker:IsIllusion() then
					percbonus = percbonus / 2
				end

				local new_mana_burn = self.mana_break + (percbonus * target:GetMaxMana() / 100) 
				mana_burn = math.min(target:GetMana(), new_mana_burn )
			end

			target:ReduceMana( mana_burn )

			self:PlayEffects( target )

			if attacker:IsIllusion() then
				local illudamage = {
                	victim = target,
                	attacker = attacker,
                	damage = mana_burn * self.illu_efficency * self.mana_damage_pct,
                	damage_type = DAMAGE_TYPE_PHYSICAL,
                	ability = self:GetAbility(),
                	damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            	}
            	ApplyDamage( illudamage )	
            end

			return mana_burn * self.mana_damage_pct
		end

	end
end


function modifier_am_mana_break_elf:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/generic_gameplay/generic_manaburn.vpcf"
	local sound_cast = "Hero_Antimage.ManaBreak"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		EmitSoundOn( sound_cast, target )
end