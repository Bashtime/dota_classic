base_ability = class({})

--[[SKILL SLOTS--
DOTA_Q_SLOT = 0
DOTA_W_SLOT = 1
DOTA_E_SLOT = 2
DOTA_D_SLOT = 3
DOTA_F_SLOT = 4
DOTA_R_SLOT = 5
]]


function base_ability:GetCooldownBase(level)
    error('Define GetCooldownBase(level) and not GetCooldown(level)')
end

function base_ability:GetCooldown(level)
    local hero = self:GetCaster()
    local index = self:GetAbilitySlot()
    local flat = 0
    local pct = 1
    local min = 0
    local max = 1000
    if index == DOTA_Q_SLOT then
        flat = hero:GetModifierStackCount("modifier_q_flat_cooldown_modifier", hero)
        pct = hero:GetModifierStackCount("modifier_q_pct_cooldown_modifier", hero)
        min = hero:GetModifierStackCount("modifier_q_min_cooldown_modifier", hero)
        max = hero:GetModifierStackCount("modifier_q_max_cooldown_modifier", hero)
    elseif index == DOTA_W_SLOT then
        flat = hero:GetModifierStackCount("modifier_w_flat_cooldown_modifier", hero)
        pct = hero:GetModifierStackCount("modifier_w_pct_cooldown_modifier", hero)
        min = hero:GetModifierStackCount("modifier_w_min_cooldown_modifier", hero)
        max = hero:GetModifierStackCount("modifier_w_max_cooldown_modifier", hero)
    elseif index == DOTA_E_SLOT then
        flat = hero:GetModifierStackCount("modifier_e_flat_cooldown_modifier", hero)
        pct = hero:GetModifierStackCount("modifier_e_pct_cooldown_modifier", hero)
        min = hero:GetModifierStackCount("modifier_e_min_cooldown_modifier", hero)
        max = hero:GetModifierStackCount("modifier_e_max_cooldown_modifier", hero)
    elseif index == DOTA_R_SLOT then
        flat = hero:GetModifierStackCount("modifier_r_flat_cooldown_modifier", hero)
        pct = hero:GetModifierStackCount("modifier_r_pct_cooldown_modifier", hero)
        min = hero:GetModifierStackCount("modifier_r_min_cooldown_modifier", hero)
        max = hero:GetModifierStackCount("modifier_r_max_cooldown_modifier", hero)
    end
    local cooldown = math.min(math.max((self:GetCooldownBase(level) + flat / 100) * (pct / 10000), min / 100), max / 100)
    return cooldown
end




function base_ability:GetCooldown(level)

    local hero = self:GetCaster()
    local index = self:GetAbilitySlot()
    local flat = 0

    if index == DOTA_Q_SLOT then
        flat = hero:GetModifierStackCount("modifier_q_flat_cooldown_modifier", hero)
    end

    local cooldown = self:GetCooldownBase(level) - ( (flat - 1) * 0.5 )
    return cooldown
end
