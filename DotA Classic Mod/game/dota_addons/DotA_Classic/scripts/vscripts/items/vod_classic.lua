--Class Definitions

	item_vod_classic = class({})
	local itemClass = item_vod_classic

	--Debuff modifier
	modifier_vod_classic_debuff = class({})
	local debuffModClass = modifier_vod_classic_debuff
	local debuffModName = 'modifier_vod_classic_debuff'
	LinkLuaModifier(debuffModName, "items/vod_classic", LUA_MODIFIER_MOTION_NONE)

	--Aura Bonuses Modifier
	modifier_vod_aura = class({})
	local buffModifierClass = modifier_vod_aura
	local buffModifierName = 'modifier_vod_aura'
	LinkLuaModifier(buffModifierName, "items/vod_classic", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_vod = class({})
	local modifierClass = modifier_vod
	local modifierName = 'modifier_vod'
	LinkLuaModifier(modifierName, "items/vod_classic", LUA_MODIFIER_MOTION_NONE)


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
					return DOTA_UNIT_TARGET_HERO
				end

				function modifierClass:GetAuraSearchFlags()
    				return DOTA_UNIT_TARGET_FLAG_NONE
				end

			function modifierClass:GetAuraRadius()
				local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    			return radius
			end

			function modifierClass:GetModifierAura()
    			return buffModifierName
			end


------------------------------------------
--Active Spellpart

--------------------------------------------------------------------------------
-- AOE Radius
function itemClass:GetAOERadius()
	return self:GetSpecialValueFor( "debuff_radius" )
end

function itemClass:OnSpellStart()

	local sound_cast = "DOTA_Item.VeilofDiscord.Activate"

	-- preparations
	local caster = self:GetCaster()
	local center = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor( "debuff_radius" )
	local dur = self:GetSpecialValueFor("resist_debuff_duration")

	-- Create Sound
	EmitSoundOnLocationWithCaster( center, sound_cast, caster )


	-- Visual effect
	local particle_cast = "particles/items2_fx/veil_of_discord.vpcf"
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, center )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )


	-- Find Units in Radius
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		center,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		--enemy:AddNewModifier(caster, self, debuffModName, { duration = dur })
		enemy:AddNewModifier(caster, self, "modifier_item_veil_of_discord_debuff", { duration = dur })	
	end	
end



------------------------------------------
--Debuff Modifier

function debuffModClass:OnCreated()
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" )
end

	-------------------------------------------------------------------
	-- Modifier Effects
	function debuffModClass:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
		return funcs
	end


	function debuffModClass:OnTakeDamage( params )
		if params.attacker == self:GetCaster() then
			for k,v in pairs(params) do
				print(k,v)
			end
		end

		if IsServer() then
			if params.unit == self:GetParent() 
				and params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL
			then
				--[[local damage = params.original_damage * self.spell_amp / 100
				local dmgtype = params.damage_type

				print("---Variables---")
				print(damage)
				print(dmgtype)

				local damageTable = {
						victim = self:GetParent(),
						attacker = params.attacker,
						damage = damage,
						ability = self:GetAbility(), --Optional.
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						damage_type = params.damage_type
					}
				ApplyDamage(damageTable)]]
			end
		end
	end

	--[[function debuffModClass:GetModifierIncomingDamage_Percentage( kv )
		for k,v in pairs(kv) do
			print(k,v)
		end

		if kv.damage_type == DOTA_DAMAGE_CATEGORY_SPELL then
			return self.spell_amp
		end
	end	]]

function debuffModClass:GetEffectName()
	return "particles/items2_fx/veil_of_discord_debuff.vpcf"
end

function debuffModClass:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


--[[function jimmys_clone_man_1:GetModifierIncomingDamage_Percentage( params )
    if params.target == self:GetParent() then  
        ApplyDamage({damage = params.damage, damage_type = params.damage_type, ability = self:GetAbility(), attacker = params.attacker, victim = self:GetCaster(), damage_flags = DOTA_DAMAGE_FLAG_REFLECTION})
        return -100
    end
    return
end]]




-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" )

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	

	-- Aura Visual 
	local particle_cast = "particles/ti7_veil_aura.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
end

function modifierClass:OnDestroy()
	ParticleManager:DestroyParticle(self.effect_cast, true)
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

					MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

					MODIFIER_PROPERTY_HEALTH_BONUS,
					MODIFIER_PROPERTY_MANA_BONUS,
					MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
					MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

					--Add more stuff below
				}

				return funcs
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
					return self.mana_reg
				end


--#########################
--## Aura Stuff starts here
--#########################

function buffModifierClass:OnCreated()
	--Common References
	self.spell_amp_aura = self:GetAbility():GetSpecialValueFor( "spell_amp_aura" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
	return funcs
end

function buffModifierClass:GetModifierSpellAmplify_Percentage()
	return self.spell_amp_aura
end
