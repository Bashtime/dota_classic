-- From moddota discord
modifier_common_custom_armor = class({})

function modifier_common_custom_armor:IsPurgable()
    return false
end

function modifier_common_custom_armor:IsHidden()
    return true
end

function modifier_common_custom_armor:RemoveOnDeath()
    return false
end

function modifier_common_custom_armor:IsPermanent()
    return true
end

function modifier_common_custom_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE 
    }
end

-- Only run on server, so that the client sees unmodified armor
if IsServer() then
    -- Remove all of the unit's actual armour
    function modifier_common_custom_armor:GetModifierPhysicalArmorBonus()
        if (self.checkArmor) then
            return 0
        else
            self.checkArmor = true
            local armor = self:GetParent():GetPhysicalArmorValue()
            self.checkArmor = false

            return armor * -1
        end
    end

    -- Recalculates incoming damage based on armour
    function modifier_common_custom_armor:GetModifierIncomingPhysicalDamage_Percentage()
        self.checkArmor = true
        local armor = self:GetParent():GetPhysicalArmorValue()
        self.checkArmor = false
        local physicalResistance = 0.06*armor/(1+0.06*math.abs(armor)) * 100
        --print("common_custom_armor.lua | Physical resistance of: "..tostring(physicalResistance).." for unit with: "..tostring(armor).." armor")
        return -physicalResistance
    end
end