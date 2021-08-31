-- Creator:
-- 	Bashtime - 22.08.2021

LinkLuaModifier("modifier_moc_debuff", "items/moc.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moc_buff", "items/moc.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moc", "items/moc.lua", LUA_MODIFIER_MOTION_NONE)


item_moc				= class({})
modifier_moc_debuff		= class({})
modifier_moc_buff		= class({})
modifier_moc			= class({})

-------------------------------
-- MEDALLION OF COURAGE BASE --
-------------------------------

function item_moc:GetIntrinsicModifierName()
	return "modifier_moc"
end

function item_moc:OnSpellStart()
		
	-- AbilitySpecials
	self.duration				=	self:GetSpecialValueFor("duration")

	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	--Apply Buff or Debuff
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if not target:IsMagicImmune() then
			target:AddNewModifier(caster, self, "modifier_moc_debuff", {duration = self.duration * (1 - target:GetStatusResistance())})
		end
	else
		target:AddNewModifier(caster, self, "modifier_moc_buff", {duration = self.duration })
	end

	caster:AddNewModifier(caster, self, "modifier_moc_debuff", {duration = self.duration })
	-- Play the cast sound
	caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate") 
	target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
end

------------------------------------------------------------------------------
--- Custom Filter

function item_moc:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end
	if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and hTarget:IsMagicImmune() then return UF_FAIL_CUSTOM end
end

--------------------------------------------------------------------------------

function item_moc:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end
	if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and hTarget:IsMagicImmune() then return "#dota_hud_error_moc"
end


---------------------------------
-- MEDALLION DEBUFF MODIFIER --
---------------------------------

function modifier_moc_debuff:GetEffectName()
	return "particles/items2_fx/medallion_of_courage.vpcf"
end

function modifier_moc_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_moc_debuff:IsDebuff()
	return true
end

function modifier_moc_debuff:OnCreated()
	self.armor_reduction		=	self:GetAbility():GetSpecialValueFor("armor_reduction")
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
end

function modifier_moc_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_moc_debuff:GetModifierPhysicalArmorBonus()
	return -self.armor_reduction
end
---------------------------------
-- MEDALLION BUFF MODIFIER --
---------------------------------

function modifier_moc_buff:GetEffectName()
	return "particles/items2_fx/medallion_of_courage_friend.vpcf"
end

function modifier_moc_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_moc_buff:OnCreated()
	self.armor_reduction		=	self:GetAbility():GetSpecialValueFor("armor_reduction")
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
end

function modifier_moc_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_moc_buff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end

--------------------------
 -- Medallion MODIFIER --
--------------------------

function modifier_moc:IsHidden() return true end
function modifier_moc:IsPurgable() return false end
function modifier_moc:RemoveOnDeath() return false end
function modifier_moc:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_moc:OnCreated()
	self.bonus_armor			=	self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.mana_reg				=	self:GetAbility():GetSpecialValueFor("mana_reg")

	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
end

function modifier_moc:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_moc:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_moc:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end