--Class Definitions

	item_oc_classic = class({})
	local itemClass = item_oc_classic

	--Passive instrinsic Bonus Modifier
	modifier_oc_classic = class({})
	local modifierClass = modifier_oc_classic
	local modifierName = 'modifier_oc_classic'
	LinkLuaModifier(modifierName, "items/oc_classic", LUA_MODIFIER_MOTION_NONE)

	--Active Bonuses Modifier
	modifier_oc_active = class({})
	local buffModifierClass = modifier_oc_active
	local buffModifierName = 'modifier_oc_active'
	LinkLuaModifier(buffModifierName, "items/oc_classic", LUA_MODIFIER_MOTION_NONE)		


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


--Active Part
function itemClass:OnSpellStart()

	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, buffModifierName, { duration = self:GetSpecialValueFor( "active_duration" )})

	-- effects
	local sound_cast = "DOTA_Item.Bloodstone.Cast"
	EmitSoundOn( sound_cast, caster )
end


function itemClass:OnCreated()
	self.just_created = true
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

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_health" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" )
	self.manacost_perc = self:GetAbility():GetSpecialValueFor( "mana_cost_percentage" )

	self:StartIntervalThink(0.12)
end

		--Percentage Manacost
		function modifierClass:OnIntervalThink()
			local caster = self:GetParent()
			local max_mana = caster:GetMaxMana()
			local mana_cost = math.ceil(max_mana * self.manacost_perc / 100)

			self:SetStackCount(mana_cost)
		end

		function itemClass:GetManaCost()
			local k
			k = self:GetCaster():GetModifierStackCount(modifierName, self:GetCaster())
			return k
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
					MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
					MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
					MODIFIER_EVENT_ON_TAKEDAMAGE,					
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
					local caster = self:GetParent()
					local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
					local regen = self.mana_reg / 100 * int * 0.05
					return regen
				end


			--Cdr and Mcr
			function modifierClass:GetModifierPercentageManacost()
				return self.manacost_reduction
			end

			function modifierClass:GetModifierPercentageCooldown()
				return self.cdr
			end				


			--Spell lifesteal mechanic
			function modifierClass:OnTakeDamage( params )

				local attacker = self:GetParent()
				local target = params.unit

				if params.attacker == attacker 
					and params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL
				then
					local particle_cast = "particles/items3_fx/octarine_core_lifesteal.vpcf"
					local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, attacker )
					ParticleManager:ReleaseParticleIndex( effect_cast )

					local flHeal = params.damage * self:GetAbility():GetSpecialValueFor( "creep_lifesteal" ) / 100

					if target:IsRealHero() then
						flHeal = params.damage * self:GetAbility():GetSpecialValueFor( "hero_lifesteal" ) / 100
					end

					attacker:Heal(flHeal, attacker)
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, flHeal, nil)
				end
			end 				


--Active Buff
function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
	return funcs
end

function buffModifierClass:OnCreated()
	local caster = self:GetParent()
	self.regen = caster:GetModifierStackCount(modifierName, caster) / self:GetAbility():GetSpecialValueFor("active_duration")

end

function buffModifierClass:GetModifierConstantHealthRegen()
	return self.regen
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function buffModifierClass:GetEffectName()
	return "particles/items_fx/bloodstone_heal.vpcf"
end

function buffModifierClass:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


