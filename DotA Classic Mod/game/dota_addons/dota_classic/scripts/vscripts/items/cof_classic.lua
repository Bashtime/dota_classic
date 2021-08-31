-- Author: Bashtime
-- Date: 21/08/2021

item_cof_classic = item_cof_classic or class({})
modifier_cof_classic = modifier_cof_classic or class({})
modifier_cof_classic_aura = modifier_cof_classic_aura or class({})

LinkLuaModifier("modifier_cof_classic", "items/cof_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cof_classic_aura", "items/cof_classic", LUA_MODIFIER_MOTION_NONE)


function item_cof_classic:GetIntrinsicModifierName()
	return "modifier_cof_classic"
end

function modifier_cof_classic:IsHidden()		return true end
function modifier_cof_classic:IsPurgable()		return false end
function modifier_cof_classic:RemoveOnDeath()	return false end
function modifier_cof_classic:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_cof_classic:DeclareFunctions()
	return {

	}
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_cof_classic:GetEffectName()
	--return "particles/cloak_of_flames.vpcf"
end

--[[
function modifier_cof_classic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
]]

function modifier_cof_classic:OnCreated()
	--self.particle = ParticleManager:CreateParticle( "particles/cloak_of_flames.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
end




-------------------
--Aura Settings
function modifier_cof_classic:IsAura()
	return true
end

function modifier_cof_classic:IsAuraActiveOnDeath()
	return false
end
	--Who is affected ?
	function modifier_cof_classic:GetAuraSearchTeam()
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	end

	function modifier_cof_classic:GetAuraSearchType()
		return (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC)
	end

	function modifier_cof_classic:GetAuraSearchFlags()
		return DOTA_UNIT_TARGET_FLAG_NONE
	end

function modifier_cof_classic:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_cof_classic:GetModifierAura()
	return "modifier_cof_classic_aura"
end




-----------------
-- Burn Mechanic
function modifier_cof_classic_aura:OnCreated()
	self.burn = self:GetAbility():GetSpecialValueFor("burn")
	self.illu_burn = self:GetAbility():GetSpecialValueFor("illu_burn")
	self:StartIntervalThink(0.5)

	--[[if IsServer() then
		self.particle = ParticleManager:CreateParticle("particles/items2_fx/radiance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle, 1, self:GetCaster():GetAbsOrigin())
	end ]]
end

function modifier_cof_classic_aura:OnIntervalThink()
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

--[[
function modifier_cof_classic_aura:OnDestroy()
	if IsServer() then
		-- Destroy particle
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end
]]
