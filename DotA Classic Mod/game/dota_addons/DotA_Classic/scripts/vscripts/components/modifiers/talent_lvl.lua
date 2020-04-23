-- 1st Modding Project by Bashtime
modifier_talent_lvl = class({})

function modifier_talent_lvl:IsPurgable()
    return false
end

function modifier_talent_lvl:IsHidden()
    return true
end

function modifier_talent_lvl:RemoveOnDeath()
    return false
end

function modifier_talent_lvl:IsPermanent()
    return true
end

function modifier_talent_lvl:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end


function modifier_talent_lvl:OnCreated()
	self:SetStackCount(0)
end

