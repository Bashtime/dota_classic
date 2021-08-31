-- Creator: Shush
-- Date: 27/5/2020

--------------------
-- BLACK KING BAR --
--------------------

LinkLuaModifier("modifier_bkb", "items/bkb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bkb_buff", "items/bkb", LUA_MODIFIER_MOTION_NONE)

item_bkb = item_bkb or class({})

function item_bkb:GetIntrinsicModifierName()
    return "modifier_bkb"
end

function item_bkb:OnSpellStart()
    -- Ability properties
    local caster = self:GetCaster()
    local ability = self
    local sound_cast = "DOTA_Item.BlackKingBar.Activate"
    
    -- Ability specials
    local duration = ability:GetSpecialValueFor("duration")
    local max_level = ability:GetSpecialValueFor("max_level")

    -- Level up the item if relevant
    if ability:GetLevel() < max_level then
        ability:SetLevel(ability:GetLevel() + 1)

        -- Set level on the caster
        caster.bkb_current_level = ability:GetLevel()        
    end

    -- Play cast sound
    EmitSoundOn(sound_cast, caster)

    -- Apply basic dispel
    caster:Purge(false, true, false, false, false)

    -- Remove ethereal abilities
    for _, modifier_name in pairs(GetEtherealAbilities()) do
        if caster:HasModifier(modifier_name) then
            caster:RemoveModifierByName(modifier_name)
        end
    end

    -- Give caster the buff
    caster:AddNewModifier(caster, ability, "modifier_bkb_buff", {duration = duration})
end


---------------------------------------
-- INTRINSIC BLACK KING BAR MODIFIER --
---------------------------------------

modifier_bkb = modifier_bkb or class({})

function modifier_bkb:IsHidden() return true end
function modifier_bkb:IsPurgable() return false end
function modifier_bkb:RemoveOnDeath() return false end
function modifier_bkb:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_bkb:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

    -- Ability properties    
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    -- Ability specials
    self.bonus_strength = self.ability:GetSpecialValueFor("bonus_strength")
    self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")    

    -- Set the item's level according to the caster, if any
    if IsServer() then
        if self.caster.bkb_current_level and self.ability then
            if self.caster.bkb_current_level ~= self.ability:GetLevel() then
               self.ability:SetLevel(self.caster.bkb_current_level)
            end
        end
    end
end

function modifier_bkb:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                      MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}

    return decFuncs
end

function modifier_bkb:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_bkb:GetModifierBonusStats_Strength()
    return self.bonus_strength
end

----------------------------------
-- BLACK KING BAR BUFF MODIFIER --
----------------------------------

modifier_bkb_buff = modifier_bkb_buff or class({})

function modifier_bkb_buff:IsHidden() return false end
function modifier_bkb_buff:IsPurgable() return false end
function modifier_bkb_buff:IsDebuff() return false end

function modifier_bkb_buff:GetEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_bkb_buff:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

    -- Ability properties
    self.ability = self:GetAbility()

    -- Ability specials
    self.model_scale = self.ability:GetSpecialValueFor("model_scale")
end


function modifier_bkb_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_bkb_buff:CheckState()
    local state = {[MODIFIER_STATE_MAGIC_IMMUNE] = true}

    return state
end

function modifier_bkb_buff:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_bkb_buff:GetModifierModelScale()
    return self.model_scale
end