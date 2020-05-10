-- 1st Modding Project by Bashtime
modifier_bkb_mr = class({})

function modifier_bkb_mr:IsPurgable()
    return false
end

function modifier_bkb_mr:IsHidden()
    return true
end

function modifier_bkb_mr:RemoveOnDeath()
    return false
end

function modifier_bkb_mr:IsPermanent()
    return true
end

function modifier_bkb_mr:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function modifier_bkb_mr:OnCreated()

end

	-- Modifier Effects
	function modifier_bkb_mr:DeclareFunctions()

		local funcs = {
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
				}

		return funcs
	end

		function modifier_bkb_mr:GetModifierMagicalResistanceBonus()
			local caster = self:GetParent()
			local stack_count = self:GetStackCount()
			local mr = (stack_count - 5) * 20
			if caster:HasModifier("modifier_black_king_bar_immune") then
				return mr
			end
			return 0 
		end
