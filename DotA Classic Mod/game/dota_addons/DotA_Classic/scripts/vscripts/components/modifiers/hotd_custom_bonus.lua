-- 1st Modding Project by Bashtime
modifier_hotd_custom_bonus = class({})

function modifier_hotd_custom_bonus:IsPurgable()
    return false
end

function modifier_hotd_custom_bonus:IsHidden()
    return true
end

function modifier_hotd_custom_bonus:RemoveOnDeath()
    return false
end

function modifier_hotd_custom_bonus:IsPermanent()
    return true
end

function modifier_hotd_custom_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

	-- Modifier Effects
	function modifier_hotd_custom_bonus:DeclareFunctions()

		local funcs = {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				}

		return funcs
	end

function modifier_hotd_custom_bonus:OnCreated()
	self:StartIntervalThink(0.2)
	self.dmg = 9
	self.armor = 5
end


function modifier_hotd_custom_bonus:OnIntervalThink()
	local caster = self:GetParent()
	local k = 0

	if not IsServer() then return end   
	for i=0, 5 do
        local item = caster:GetItemInSlot(i)

        if item then
          	if (item:GetName() == "item_helm_of_the_dominator") then
           		k = k + 1
           	end
        end
    end

    if k ~= self:GetStackCount() then self:SetStackCount(k) end
end


function modifier_hotd_custom_bonus:GetModifierPreAttack_BonusDamage()
	local stacks = self:GetStackCount()
	return self.dmg * stacks
end

function modifier_hotd_custom_bonus:GetModifierPhysicalArmorBonus()
	local stacks = self:GetStackCount()
	return self.armor * stacks
end


