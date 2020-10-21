-- 1st Modding Project by Bashtime
modifier_nerf_cancer_regen = class({})

function modifier_nerf_cancer_regen:IsPurgable()
    return false
end

function modifier_nerf_cancer_regen:IsHidden()
    return true
end

function modifier_nerf_cancer_regen:RemoveOnDeath()
    return false
end

function modifier_nerf_cancer_regen:IsPermanent()
    return true
end

function modifier_nerf_cancer_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_nerf_cancer_regen:GetModifierConstantHealthRegen()
        owner = self:GetParent()
        if owner:IsHero() then
            local nerf_bat = self:GetParent():GetStrength()
            return nerf_bat * (-0.05)
        end
end
