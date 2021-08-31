item_ex_machina_classic = class({})

		--Aura Bonuses Modifier
		modifier_ex_machina_aura = class({})
		local buffModifierClass = modifier_ex_machina_aura
		local buffModifierName = 'modifier_ex_machina_aura'
		LinkLuaModifier(buffModifierName, "items/ex_machina_classic", LUA_MODIFIER_MOTION_NONE)	

		-- Ex Machina Bonuses Modifier
		modifier_ex_machina_classic = class({})
		local modifierClass = modifier_ex_machina_classic
		local modifierName = 'modifier_ex_machina_classic'
		LinkLuaModifier("modifier_ex_machina_classic","items/ex_machina_classic", LUA_MODIFIER_MOTION_NONE)

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
				return self:GetAbility():GetSpecialValueFor( "aura_radius" )
			end

			function modifierClass:GetModifierAura()
    			return buffModifierName
			end



function item_ex_machina_classic:GetIntrinsicModifierName()
	return "modifier_ex_machina_classic"
end




--------------------------------------------------------------------------------
-- Classifications / Passive Effects
function modifier_ex_machina_classic:IsHidden()
	return true
end

function modifier_ex_machina_classic:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_ex_machina_classic:OnCreated( kv )

	-- references
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" ) -- special value
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" ) -- special value
	self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" ) -- special value
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "cast_range_bonus" ) -- special value
	self.hp_reg = self:GetAbility():GetSpecialValueFor( "bonus_hp_regen" ) -- special value

end


function modifier_ex_machina_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_ex_machina_classic:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects

function modifier_ex_machina_classic:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,

	}

	return funcs
end

function modifier_ex_machina_classic:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_ex_machina_classic:GetModifierPercentageManacost()
	return self.manacost_reduction
end

function modifier_ex_machina_classic:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_ex_machina_classic:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_ex_machina_classic:GetModifierManaBonus()
	return self.bonus_mana
end


function modifier_ex_machina_classic:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.bonus_mana_regen / 100 * int * 0.05
	return regen
end




function modifier_ex_machina_classic:GetModifierCastRangeBonus()
	return self.bonus_range
end

function modifier_ex_machina_classic:GetModifierConstantHealthRegen()
	return self.hp_reg
end


--#########################
--## Aura Stuff starts here
--#########################

function buffModifierClass:OnCreated()

	--Common References
	self.aoe_cr_bonus = self:GetAbility():GetSpecialValueFor( "aura_cast_range" )
	self.aoe_ar_bonus = self:GetAbility():GetSpecialValueFor( "aura_attack_range" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

function buffModifierClass:GetModifierCastRangeBonusStacking()
	--if self:GetParent():HasModifier("modifier_keen_classic") then 
	--	return self.aoe_cr_bonus - 80
	--end
	return self.aoe_cr_bonus
end

function buffModifierClass:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() and self:GetParent():IsHero() then return self.aoe_ar_bonus end
	return 0
end
