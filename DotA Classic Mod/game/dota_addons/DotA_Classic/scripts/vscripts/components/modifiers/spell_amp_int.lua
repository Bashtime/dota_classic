-- 1st Modding Project by Bashtime
modifier_spell_amp_int = class({})

function modifier_spell_amp_int:IsPurgable()
    return false
end

function modifier_spell_amp_int:IsHidden()
    return true
end

function modifier_spell_amp_int:RemoveOnDeath()
    return false
end

function modifier_spell_amp_int:IsPermanent()
    return true
end

function modifier_spell_amp_int:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end


function modifier_spell_amp_int:OnCreated()
	self:StartIntervalThink(0.2)
end


function modifier_spell_amp_int:OnIntervalThink()
	local caster = self:GetParent()
	local int = caster:GetIntellect()
	self:SetStackCount(int)

	self.spell_amp = int / 16
end


function modifier_spell_amp_int:DeclareFunctions()
	local funcs = {
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		  }

	return funcs	
end	


function modifier_spell_amp_int:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end