LinkLuaModifier("modifier_item_meme_hammer", "items/meme_hammer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_meme_hammer_burn", "items/meme_hammer.lua", LUA_MODIFIER_MOTION_NONE)

item_meme_hammer					= class({})
modifier_item_meme_hammer		= class({})
modifier_item_meme_hammer_burn	= class({})

------------------------
-- METEOR HAMMER BASE --
------------------------

function item_meme_hammer:GetIntrinsicModifierName()
	return "modifier_item_meme_hammer"
end

function item_meme_hammer:GetAOERadius()
	return self:GetSpecialValueFor("impact_radius")
end

function item_meme_hammer:OnSpellStart()
	self.caster		= self:GetCaster()
	
	-- AbilitySpecials
	self.burn_dps_buildings			=	self:GetSpecialValueFor("burn_dps_buildings")
	self.burn_dps_units				=	self:GetSpecialValueFor("burn_dps_units")
	self.burn_duration				=	self:GetSpecialValueFor("burn_duration")
	self.stun_duration				=	self:GetSpecialValueFor("stun_duration")
	self.burn_interval				=	self:GetSpecialValueFor("burn_interval")
	self.land_time					=	self:GetSpecialValueFor("land_time")
	self.impact_radius				=	self:GetSpecialValueFor("impact_radius")
	self.max_duration				=	self:GetSpecialValueFor("max_duration")
	self.impact_damage_buildings	=	self:GetSpecialValueFor("impact_damage_buildings")
	self.impact_damage_units		=	self:GetSpecialValueFor("impact_damage_units")


	self.targetFlag = DOTA_UNIT_TARGET_FLAG_NONE
	--[[ Nice Coding Example
	if self:GetLevel() >= 4 then
		self.targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	else
		self.targetFlag = DOTA_UNIT_TARGET_FLAG_NONE
	end
	]]

	if not IsServer() then return end

	local position	= self:GetCursorPosition()
	
	-- Play the channel sound
	self.caster:EmitSound("DOTA_Item.MeteorHammer.Channel")
	
	-- Create FOWViwer for caster team on position
	-- Looks like vision duration isn't explicitly in ability KVs
	AddFOWViewer(self.caster:GetTeam(), position, self.impact_radius, 3.8, false)

	-- Impact location particles
	self.particle	= ParticleManager:CreateParticleForTeam("particles/items4_fx/meteor_hammer_aoe.vpcf", PATTACH_WORLDORIGIN, self.caster, self.caster:GetTeam())
	ParticleManager:SetParticleControl(self.particle, 0, position)
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.impact_radius, 1, 1))
	
	-- Caster location particles
	self.particle2	= ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)

	self.caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end

function item_meme_hammer:OnChannelFinish(bInterrupted)
	if not IsServer() then return end

	self.position = self:GetCursorPosition()

	self.caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

	if bInterrupted then
		self.caster:StopSound("DOTA_Item.MeteorHammer.Channel")
	
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:DestroyParticle(self.particle2, true)
	else
		self.caster:EmitSound("DOTA_Item.MeteorHammer.Cast")
	
		self.particle3	= ParticleManager:CreateParticle("particles/items4_fx/meteor_hammer_spell.vpcf", PATTACH_WORLDORIGIN, self.caster)
		ParticleManager:SetParticleControl(self.particle3, 0, self.position + Vector(0, 0, 1000)) -- 1000 feels kinda arbitrary but it also feels correct
		ParticleManager:SetParticleControl(self.particle3, 1, self.position)
		ParticleManager:SetParticleControl(self.particle3, 2, Vector(self.land_time, 0, 0))
		ParticleManager:ReleaseParticleIndex(self.particle3)
		
		Timers:CreateTimer(self.land_time, function()
			if not self:IsNull() then
				GridNav:DestroyTreesAroundPoint(self.position, self.impact_radius, true)
			
				EmitSoundOnLocationWithCaster(self.position, "DOTA_Item.MeteorHammer.Impact", self.caster)
			
				local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.position, nil, self.impact_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC, self.targetFlag, FIND_ANY_ORDER, false)
				
				for _, enemy in pairs(enemies) do
					enemy:EmitSound("DOTA_Item.MeteorHammer.Damage")
				
					-- Debuffs come first, then damage
					enemy:AddNewModifier(self.caster, self, "modifier_stunned", {duration = self.stun_duration * (1 - enemy:GetStatusResistance())})
					enemy:AddNewModifier(self.caster, self, "modifier_item_meme_hammer_burn", {duration = self.burn_duration})
					
					local impactDamage = self.impact_damage_units
					
					if enemy:IsBuilding() then
						impactDamage = self.impact_damage_buildings
					end
					
					local damageTable = {
						victim 			= enemy,
						damage 			= impactDamage,
						damage_type		= DAMAGE_TYPE_MAGICAL,
						damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
						attacker 		= self.caster,
						ability 		= self
					}
									
					ApplyDamage(damageTable)
				end
			end
		end)
	end
	
	ParticleManager:ReleaseParticleIndex(self.particle)
	ParticleManager:ReleaseParticleIndex(self.particle2)
end

---------------------------------
-- METEOR HAMMER BURN MODIFIER --
---------------------------------

function modifier_item_meme_hammer_burn:GetEffectName()
	return "particles/items4_fx/meteor_hammer_spell_debuff.vpcf"
end

-- Meteor Hammer burn is NOT affected by status resistance (this is vanilla)
function modifier_item_meme_hammer_burn:IgnoreTenacity()
	return true
end

function modifier_item_meme_hammer_burn:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_meme_hammer_burn:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	if self.ability == nil then return end
	
	-- AbilitySpecials
	self.burn_dps_buildings			=	self.ability:GetSpecialValueFor("burn_dps_buildings")
	self.burn_dps_units				=	self.ability:GetSpecialValueFor("burn_dps_units")
	self.burn_duration				=	self.ability:GetSpecialValueFor("burn_duration")
	self.stun_duration				=	self.ability:GetSpecialValueFor("stun_duration")
	self.burn_interval				=	self.ability:GetSpecialValueFor("burn_interval")
	self.land_time					=	self.ability:GetSpecialValueFor("land_time")
	self.impact_radius				=	self.ability:GetSpecialValueFor("impact_radius")
	self.max_duration				=	self.ability:GetSpecialValueFor("max_duration")
	self.impact_damage_buildings	=	self.ability:GetSpecialValueFor("impact_damage_buildings")
	self.impact_damage_units		=	self.ability:GetSpecialValueFor("impact_damage_units")
	
	-- Initialize table of units that would be affected by the modifier for "radiation" check
	self.affectedUnits				= {}
	
	table.insert(self.affectedUnits, self.parent)
	
	-- Change DPS based on whether the unit is a standard enemy or building
	self.burn_dps					= self.burn_dps_units
	
	if self.parent:IsBuilding() then
		self.burn_dps	= self.burn_dps_buildings
	end
	
	self.damageTable				= {
										victim 			= self.parent,
										damage 			= self.burn_dps,
										damage_type		= DAMAGE_TYPE_MAGICAL,
										damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
										attacker 		= self.caster,
										ability 		= self.ability
									}
	
	if not IsServer() then return end

	self:StartIntervalThink(self.burn_interval)
end

function modifier_item_meme_hammer_burn:OnIntervalThink()
	if not IsServer() then return end
				
	ApplyDamage(self.damageTable)
	
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self.parent, self.burn_dps, nil)
	
end

function modifier_item_meme_hammer_burn:CheckState()
	local state = {}
	
	-- Level 2 and above applies Break
	if self ~= nil and self.ability ~= nil and not self.ability:IsNull() and self.ability:GetLevel() >= 2 then
		state = {
			[MODIFIER_STATE_PASSIVES_DISABLED] = true
		}
	end

	return state
end

----------------------------
-- METEOR HAMMER MODIFIER --
----------------------------

function modifier_item_meme_hammer:IsHidden()			return true end
function modifier_item_meme_hammer:IsPurgable()		return false end
function modifier_item_meme_hammer:RemoveOnDeath()	return false end
function modifier_item_meme_hammer:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_meme_hammer:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	if self.ability == nil then return end
	
	-- AbilitySpecials
	self.bonus_strength				=	self.ability:GetSpecialValueFor("bonus_str")
	self.bonus_intellect			=	self.ability:GetSpecialValueFor("bonus_int")
	self.bonus_health_regen			=	self.ability:GetSpecialValueFor("bonus_health_regen")
	self.mana_reg			=	self.ability:GetSpecialValueFor("mana_reg")
end

function modifier_item_meme_hammer:DeclareFunctions()
    local decFuncs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
	
    return decFuncs
end

function modifier_item_meme_hammer:GetModifierBonusStats_Strength()
	return self.bonus_strength	
end

function modifier_item_meme_hammer:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_item_meme_hammer:GetModifierConstantHealthRegen()
	return self.bonus_health_regen
end

function modifier_item_meme_hammer:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end