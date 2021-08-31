-- Author: Bashtime
-- Date: 22/08/2021

item_coq = item_coq or class({})
modifier_coq = modifier_coq or class({})
modifier_coq_aura = modifier_coq_aura or class({})
modifier_coq_active = modifier_coq_active or class({})

LinkLuaModifier("modifier_coq", "items/coq", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_coq_aura", "items/coq", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_coq_active", "items/coq", LUA_MODIFIER_MOTION_NONE)

function item_coq:OnSpellStart()
	self:GetCaster():EmitSound("DOTA_Item.BladeMail.Activate")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_coq_active", {duration = self:GetSpecialValueFor("duration")})
end

function item_coq:GetIntrinsicModifierName()
	return "modifier_coq"
end

function modifier_coq:IsHidden()		return true end
function modifier_coq:IsPurgable()		return false end
function modifier_coq:RemoveOnDeath()	return false end
function modifier_coq:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_coq:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	self.bonus_damage		= self:GetAbility():GetSpecialValueFor("bonus_dmg")
	self.bonus_armor		= self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.bonus_intellect	= self:GetAbility():GetSpecialValueFor("bonus_int")

	self.return_damage = self:GetAbility():GetSpecialValueFor("passive_return_dmg")
	self.return_damage_pct = self:GetAbility():GetSpecialValueFor("passive_return_pct")

	--self.particle = ParticleManager:CreateParticle( "particles/cloak_of_flames.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
end

function modifier_coq:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return decFuncs
end

function modifier_coq:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_coq:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_coq:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_coq:OnTakeDamage(params)
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




--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_coq:GetEffectName()
	return "particles/cloak_of_flames.vpcf"
end

--[[
function modifier_coq:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
]]


-------------------
--Aura Settings
function modifier_coq:IsAura()
	return true
end

function modifier_coq:IsAuraActiveOnDeath()
	return false
end
	--Who is affected ?
	function modifier_coq:GetAuraSearchTeam()
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	end

	function modifier_coq:GetAuraSearchType()
		return (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC)
	end

	function modifier_coq:GetAuraSearchFlags()
		return DOTA_UNIT_TARGET_FLAG_NONE
	end

function modifier_coq:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_coq:GetModifierAura()
	return "modifier_coq_aura"
end


-----------------
-- Burn Mechanic
function modifier_coq_aura:OnCreated()
	self.burn = self:GetAbility():GetSpecialValueFor("burn")
	self.illu_burn = self:GetAbility():GetSpecialValueFor("illu_burn")
	self:StartIntervalThink(0.5)
end

function modifier_coq_aura:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():IsIllusion() and not self:GetParent():IsMagicImmune() then
			-- Apply damage
			local damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.illu_burn * 0.5,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
			}

			ApplyDamage(damageTable)
			return
		end
	

		if not self:GetCaster():IsIllusion() and not self:GetParent():IsMagicImmune() then
			-- Apply damage
			local damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.burn * 0.5,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
			}
			ApplyDamage(damageTable)
			return
		end
	end
end


--------------------------------
-- Carapace of Qaldin ACTIVE MODIFIER --
--------------------------------

function modifier_coq_active:IsPurgable() return false end

function modifier_coq_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_coq_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_coq_active:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}
	return decFuncs
end

function modifier_coq_active:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
end

function modifier_coq_active:OnDestroy()
	if not IsServer() then return end	
	self:GetParent():EmitSound("DOTA_Item.BladeMail.Deactivate")
end

function modifier_coq_active:OnTakeDamage(keys)
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
