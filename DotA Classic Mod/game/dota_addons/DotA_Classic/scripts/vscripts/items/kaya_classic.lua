item_kaya_classic = class({})

LinkLuaModifier("modifier_kaya_classic","items/kaya_classic", LUA_MODIFIER_MOTION_NONE)

function item_kaya_classic:GetIntrinsicModifierName()
	return "modifier_kaya_classic"
end



-- Yasha Bonuses Modifier
modifier_kaya_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_kaya_classic:IsHidden()
	return true
end

function modifier_kaya_classic:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_kaya_classic:OnCreated( kv )

	--if IsServer() then 

	-- references
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value

	--end

end

function modifier_kaya_classic:OnRefresh( kv )

	--if IsServer() then 

	-- references
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value

	--end
end


function modifier_kaya_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_kaya_classic:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_kaya_classic:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_CASTER,
	}

	return funcs
end

function modifier_kaya_classic:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_kaya_classic:GetModifierPercentageManacost()
	return self.manacost_reduction
end

function modifier_kaya_classic:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

--[[function modifier_kaya_classic:GetModifierStatusResistanceCaster()
	return -100
end]]

