LinkLuaModifier("modifier_blademail", "items/blademail", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blademail_active", "items/blademail", LUA_MODIFIER_MOTION_NONE)

item_blademail				= class({})
modifier_blademail			= class({})
modifier_blademail_active	= class({})

---------------------
-- BLADE MAIL BASE --
---------------------

function item_blademail:OnSpellStart()
	self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_blademail_active", {duration = self:GetSpecialValueFor("duration")})
end

function item_blademail:GetIntrinsicModifierName()
	return "modifier_blademail"
end

---------------------------------
-- BLADE MAIL PASSIVE MODIFIER --
---------------------------------

function modifier_blademail:IsHidden()		return true end
function modifier_blademail:IsPurgable()		return false end
function modifier_blademail:RemoveOnDeath()	return false end
function modifier_blademail:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_blademail:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	self.bonus_damage		= self:GetAbility():GetSpecialValueFor("bonus_dmg")
	self.bonus_armor		= self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.bonus_intellect	= self:GetAbility():GetSpecialValueFor("bonus_int")

	self.return_damage = self:GetAbility():GetSpecialValueFor("passive_return_dmg")
	self.return_damage_pct = self:GetAbility():GetSpecialValueFor("passive_return_pct")
end

function modifier_blademail:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return decFuncs
end

function modifier_blademail:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_blademail:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_blademail:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_blademail:OnTakeDamage(params)
	if not IsServer() then return end

	if params.unit == self:GetParent() and not params.attacker:IsBuilding() and params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and params.damage_type == 1 then
		local returndamage = self.return_damage + (params.damage / 100 * self.return_damage_pct)
		ApplyDamage({
			victim = params.attacker,
			attacker = params.unit,
			damage = returndamage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		})
	end
end

--------------------------------
-- BLADE MAIL ACTIVE MODIFIER --
--------------------------------

function modifier_blademail_active:IsPurgable() return false end

function modifier_blademail_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_blademail_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_blademail_active:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return decFuncs
end

function modifier_blademail_active:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
end

function modifier_blademail_active:OnDestroy()
	if not IsServer() then return end	
	self:GetParent():EmitSound("DOTA_Item.BladeMail.Deactivate")
end

function modifier_blademail_active:OnTakeDamage(keys)
	if not IsServer() then return end
	
	local attacker = keys.attacker
	local target = keys.unit
	local original_damage = keys.original_damage
	local damage_type = keys.damage_type
	local damage_flags = keys.damage_flags

	if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		if not keys.unit:IsOther() then
			EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())
		
			local damageTable = {
				victim			= keys.attacker,
				damage			= keys.original_damage,
				damage_type		= keys.damage_type,
				damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= self:GetParent(),
				ability			= self:GetAbility()
			}
			
			local reflectDamage = ApplyDamage(damageTable)
		end
	end
end
