item_vlads_classic = class({})

LinkLuaModifier("modifier_vlads_classic","items/vlads_classic", LUA_MODIFIER_MOTION_NONE)

function item_vlads_classic:GetIntrinsicModifierName()
	return "modifier_vlads_classic"
end

function item_vlads_classic:OnSpellStart()

	local caster = self:GetCaster()

	--Calculate New Hp
	local hp = caster:GetHealth()
	local hp_cost = self:GetSpecialValueFor( "health_sacrifice" )
	local new_hp = math.max(hp - hp_cost, 1)
	caster:SetHealth(new_hp)

	--Add mana buff
	local duration = self:GetSpecialValueFor( "duration" )
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_item_soul_ring_buff", -- modifier name
		{ duration = duration } -- kv
	)

	--Sound effects
	local sound_cast = "DOTA_Item.SoulRing.Activate"
	EmitSoundOn( sound_cast, caster )

end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Vlads Passive Bonuses Modifier

modifier_vlads_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_vlads_classic:IsHidden()
	return true
end

function modifier_vlads_classic:IsPurgable()
	return false
end

		--Aura Bonuses Modifier
		modifier_vlads_aura = class({})
		local buffModifierClass = modifier_vlads_aura
		local buffModifierName = 'modifier_vlads_aura'
		LinkLuaModifier(buffModifierName, "items/vlads_classic", LUA_MODIFIER_MOTION_NONE)	

		local modifierClass = modifier_vlads_classic
		local modifierName = 'modifier_vlads_classic'

			--Optional Aura Settings
			function modifierClass:IsAura()
    			return true
			end

			function modifierClass:IsAuraActiveOnDeath()
    			return false
			end
				--Who is affected ?
				function modifierClass:GetAuraSearchTeam()
    				return DOTA_UNIT_TARGET_TEAM_FRIENDLY
				end

				function modifierClass:GetAuraSearchType()
					return (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC)
				end

				function modifierClass:GetAuraSearchFlags()
    				return DOTA_UNIT_TARGET_FLAG_NONE
				end

			function modifierClass:GetAuraRadius()
				local radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
    			return radius
			end

			function modifierClass:GetModifierAura()
    			return buffModifierName
			end




--------------------------------------------------------------------------------
-- Initializations
function modifier_vlads_classic:OnCreated( kv )

	-- references
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value

	local caster = self:GetParent() 
	--if IsServer() then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_vladmir", { duration = -1}) end

	--Aura visual
	local particle_cast = "particles/aura_vlads_classic.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )	
end

function modifier_vlads_classic:OnRefresh( kv )

	-- references
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value

	local caster = self:GetParent() 
	--if IsServer() then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_vladmir", { duration = -1}) end

end

function modifier_vlads_classic:OnDestroy( kv )
	local caster = self:GetParent()
	--if IsServer() then caster:RemoveModifierByName("modifier_item_vladmir") end
	ParticleManager:DestroyParticle(self.effect_cast, true)
	ParticleManager:ReleaseParticleIndex( self.effect_cast )	
end

function modifier_vlads_classic:OnRemoved()
	local caster = self:GetParent()
	--if IsServer() then caster:RemoveModifierByName("modifier_item_vladmir") end
end

function modifier_vlads_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_vlads_classic:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

function modifier_vlads_classic:GetModifierConstantHealthRegen()
	return self.bonus_regen
end

function modifier_vlads_classic:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_vlads_classic:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end



--#########################
--## Aura Stuff starts here
--#########################

function buffModifierClass:OnCreated()

	--Common References
	self.aoe_reg = self:GetAbility():GetSpecialValueFor( "mana_regen_aura" )
	self.aoe_armor = self:GetAbility():GetSpecialValueFor( "armor_aura" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function buffModifierClass:GetModifierPhysicalArmorBonus()
	return self.aoe_armor
end

function buffModifierClass:GetModifierConstantManaRegen()
	return self.aoe_reg
end

function buffModifierClass:OnTakeDamage( params )

	if IsServer() then
		
		local attacker = self:GetParent()

		if params.attacker == attacker 
			and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK
			and attacker:GetHealth() > 0
			--and attacker:IsRealHero()  
		then
			local damage = params.damage
			local target = params.unit
			local flHeal = params.damage * self:GetAbility():GetSpecialValueFor( "vampiric_aura" ) / 100

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
				if attacker:IsRealHero() then
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, flHeal, nil)
				end
			end
		end
	end
end


	function buffModifierClass:PlayEffects( target )
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

