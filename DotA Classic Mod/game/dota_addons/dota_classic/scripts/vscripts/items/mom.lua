--Class Definitions

	item_mom = class({})
	local itemClass = item_mom

	--Passive instrinsic Bonus Modifier
	modifier_mom_passive = class({})
	local modifierClass = modifier_mom_passive
	local modifierName = 'modifier_mom_passive'
	LinkLuaModifier(modifierName, "items/mom", LUA_MODIFIER_MOTION_NONE)

	--Active Modifier from Casting
	modifier_mom_active = class({})
	local modifierClassBuff = modifier_mom_active
	local modifierNameBuff = 'modifier_mom_active'
	LinkLuaModifier(modifierNameBuff, "items/mom", LUA_MODIFIER_MOTION_NONE)	

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
	local dur = self:GetSpecialValueFor("berserk_dur")
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, modifierNameBuff, { duration = dur })

	-- effects
	local sound_cast = "DOTA_Item.MaskOfMadness.Activate"
	EmitSoundOn( sound_cast, caster )	
end

-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal_percent" )

end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_EVENT_ON_TAKEDAMAGE,
				}

				return funcs
			end

			function modifierClass:OnTakeDamage( params )

				if IsServer() then
					
					local attacker = self:GetParent()
			
					if params.attacker == attacker 
						and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK
						and attacker:GetHealth() > 0
						--and attacker:IsRealHero()  
					then
						local damage = params.damage
						local target = params.unit
						local flHeal = params.damage * self.lifesteal / 100
			
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

				function modifierClass:PlayEffects(target)
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
	
				--DMG; AS
				function modifierClass:GetModifierPreAttack_BonusDamage()
					return self.bonus_dmg
				end

				function modifierClass:GetModifierAttackSpeedBonus_Constant()
					return self.bonus_as
				end

-----------------------------------------
--Active Modifier Stuff starts here

--Usual Settings
function modifierClassBuff:IsHidden()
	return false
end

function modifierClassBuff:IsPurgable()
	return true
end

function modifierClassBuff:RemoveOnDeath()
	return true
end

function modifierClassBuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function modifierClassBuff:OnCreated()

	self.berserk_ms = self:GetAbility():GetSpecialValueFor( "berserk_ms" )
	self.berserk_as = self:GetAbility():GetSpecialValueFor( "berserk_as" )
	self.berserk_inc_dmg = self:GetAbility():GetSpecialValueFor( "berserk_inc_dmg" )

end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClassBuff:DeclareFunctions()
				local funcs = {
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					--MODIFIER_PROPERTY_EVENT_ON_TAKEDAMAGE,
					MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
				}
				return funcs
			end

				function modifierClassBuff:GetModifierAttackSpeedBonus_Constant()
					return self.berserk_as
				end

				function modifierClassBuff:GetModifierMoveSpeedBonus_Percentage()
					return self.berserk_ms
				end

				function modifierClassBuff:GetModifierIncomingDamage_Percentage()
					return 1+self.berserk_inc_dmg/100
				end


--Visuals
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifierClassBuff:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end

function modifierClassBuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

