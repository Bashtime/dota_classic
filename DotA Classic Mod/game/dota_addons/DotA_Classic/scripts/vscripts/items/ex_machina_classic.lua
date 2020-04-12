item_ex_machina_classic = class({})

LinkLuaModifier("modifier_ex_machina_classic","items/ex_machina_classic", LUA_MODIFIER_MOTION_NONE)

function item_ex_machina_classic:GetIntrinsicModifierName()
	return "modifier_ex_machina_classic"
end



-- Yasha Bonuses Modifier
modifier_ex_machina_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ex_machina_classic:IsHidden()
	return true
end

function modifier_ex_machina_classic:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_ex_machina_classic:OnCreated( kv )

	--if IsServer() then 

	-- references
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value
	self.debuff_amp = -self:GetAbility():GetSpecialValueFor( "debuff_amp" ) -- special value
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" ) -- special value
	self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" ) -- special value
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "cast_range_bonus" ) -- special value




end

function modifier_ex_machina_classic:OnRefresh( kv )

	--if IsServer() then 

	-- references
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value
	self.debuff_amp = -self:GetAbility():GetSpecialValueFor( "debuff_amp" ) -- special value
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" ) -- special value
	self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" ) -- special value
	print(self.bonus_mana_regen)
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "cast_range_bonus" ) -- special value

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
		MODIFIER_PROPERTY_STATUS_RESISTANCE_CASTER,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
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

function modifier_ex_machina_classic:GetModifierStatusResistanceCaster()
	return self.debuff_amp
end

function modifier_ex_machina_classic:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_ex_machina_classic:GetModifierConstantManaRegen()
	return self.bonus_mana_regen
end

function modifier_ex_machina_classic:GetModifierCastRangeBonus()
	return self.bonus_range
end

