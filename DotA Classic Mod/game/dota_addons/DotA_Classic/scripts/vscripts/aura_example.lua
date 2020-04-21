modifier_arcane_cascade_hat = class(npc_base_modifier, nil, npc_base_modifier)

local modifierClass = modifier_arcane_cascade_hat
local modifierName = 'modifier_arcane_cascade_hat'
LinkLuaModifier(modifierName, "items/lua/helm/arcane_cascade_hat", LUA_MODIFIER_MOTION_NONE)

modifier_arcane_cascade_hat_debuff = class(npc_base_modifier, nil, npc_base_modifier)
local debuffModifierClass = modifier_arcane_cascade_hat_debuff
local debuffModifierName = 'modifier_arcane_cascade_hat_debuff'
LinkLuaModifier(debuffModifierName, "items/lua/helm/arcane_cascade_hat", LUA_MODIFIER_MOTION_NONE)

function modifierClass:IsAura()
    return true
end

function modifierClass:IsAuraActiveOnDeath()
    return false
end

function modifierClass:GetAuraRadius()
    return ARCANE_CASCADE_RANGE
end

function modifierClass:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifierClass:GetAuraSearchType()
    return (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC)
end

function modifierClass:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifierClass:RemoveOnDeath()
    return false
end

function modifierClass:GetModifierAura()
    return debuffModifierName
end

----------------
--ENEMY DEBUFF--
----------------
function debuffModifierClass:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(ARCANE_CASCADE_TICKRATE)
end

function debuffModifierClass:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local target = self:GetParent()
    local ability = self:GetAbility()
    if ability.damage then
        --print("Damage: "..ability.damage)
        local damage = ability.damage
        Filters:ApplyItemDamage(target, caster.hero, damage, DAMAGE_TYPE_MAGICAL, ability, RPC_ELEMENT_ARCANE, RPC_ELEMENT_NONE)
    end
end