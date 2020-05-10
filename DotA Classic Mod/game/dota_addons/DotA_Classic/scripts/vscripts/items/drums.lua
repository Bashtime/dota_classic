item_drums = class({})

LinkLuaModifier("modifier_drums","items/drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drums_nospeed","items/drums", LUA_MODIFIER_MOTION_NONE)


function item_drums:GetIntrinsicModifierName()
	return "modifier_drums"
end


function item_drums:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor( "radius" )
	local nospeed_duration = self:GetSpecialValueFor( "nospeed_duration" )

	-- Find Units in Radius
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,ally in pairs(allies) do

		if not ally:HasModifier("modifier_drums_nospeed") then 

			-- Apply Speed buff
			ally:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_item_ancient_janggo_active", -- modifier name
			{ duration = duration } -- kv
			)
			
			-- Add No Speed Debuff
			ally:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_drums_nospeed", -- modifier name
			{ duration = nospeed_duration } -- kv
			)
		end
	end

	-- effects
	local sound_cast = "DOTA_Item.DoE.Activate"
	EmitSoundOn( sound_cast, caster )

end



-- NO SPEED DEBUFF
-- Preventing mass drums abuse ; similiar to Mekansm

modifier_drums_nospeed = class({})

function modifier_drums_nospeed:IsHidden()
	return false
end

function modifier_drums_nospeed:IsPurgable()
	return false
end

function modifier_drums_nospeed:IsDebuff()
	return true
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Drums Passive Bonuses Modifier

modifier_drums = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_drums:IsHidden()
	return true
end

function modifier_drums:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_drums:OnCreated( kv )
	-- references
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" ) -- special value
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" ) -- special value
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_mr" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" ) -- special value		

	local caster = self:GetParent() 

	-- Aura Visual 
	local particle_cast = "particles/items_fx/aura_endurance.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
end

function modifier_drums:OnRefresh( kv )

	-- references
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" ) -- special value
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" ) -- special value
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" ) -- special value
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" ) -- special value
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" ) -- special value	

	local caster = self:GetParent() 

	--if IsServer() then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_ancient_janggo", { duration = -1}) end
end

function modifier_drums:OnDestroy( kv )
	ParticleManager:DestroyParticle(self.effect_cast, true)
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

function modifier_drums:OnRemoved()
	local caster = self:GetParent()
	--if IsServer() then caster:RemoveModifierByName("modifier_speed_aura") end
	--if IsServer() then caster:RemoveModifierByName("modifier_item_ancient_janggo") end
end


function modifier_drums:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_drums:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_drums:GetModifierMagicalResistanceBonus()
	return self.bonus_mr
end

function modifier_drums:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_drums:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_drums:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_drums:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_drums:GetModifierBonusStats_Intellect()
	return self.bonus_int
end







---------------------------------------
-- AURA PART

local modifierClass = modifier_drums
local modifierName = 'modifier_drums'
LinkLuaModifier(modifierName, "items/drums", LUA_MODIFIER_MOTION_NONE)


modifier_drums_aura_buff = class({})
local buffModifierClass = modifier_drums_aura_buff
local buffModifierName = 'modifier_drums_aura_buff'
LinkLuaModifier(buffModifierName, "items/drums", LUA_MODIFIER_MOTION_NONE)

function modifierClass:IsAura()
    return true
end

function modifierClass:IsAuraActiveOnDeath()
    return false
end

function modifierClass:GetAuraRadius()
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )
    return radius
end

function modifierClass:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
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
    return buffModifierName
end

----------------
--ALLY BUFF--
----------------

function buffModifierClass:OnCreated()
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_aura_movement_speed" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "attack_speed_aura" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end


function buffModifierClass:GetModifierMoveSpeedBonus_Constant(params)
	return self.bonus_ms
end

function buffModifierClass:GetModifierAttackSpeedBonus_Constant(params)
	return self.bonus_as
end