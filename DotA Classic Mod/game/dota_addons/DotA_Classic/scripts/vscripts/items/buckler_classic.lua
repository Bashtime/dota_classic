item_buckler_classic = class({})

LinkLuaModifier("modifier_buckler_classic","items/buckler_classic", LUA_MODIFIER_MOTION_NONE)

function item_buckler_classic:GetIntrinsicModifierName()
	return "modifier_buckler_classic"
end

function item_buckler_classic:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_mekansm_aura") then return "item_classic_buckler" end
	return "item_imba_buckler"
end




-----------------------------------------------------------------
-----------------------------------------------------------------
--- Active PART

function item_buckler_classic:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local active_duration = self:GetSpecialValueFor( "active_duration" )
	local radius = self:GetSpecialValueFor( "active_radius" )

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
			
			if ally == caster then
				-- Add No Heal Debuff
				ally:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_buckler_active", -- modifier name
				{ duration = active_duration } -- kv
			)
			end

			if ( ( not ally:IsControllableByAnyPlayer() ) and ally:IsCreep()) then
				-- Add No Heal Debuff
				ally:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_buckler_active", -- modifier name
				{ duration = active_duration } -- kv
			)
			end
	end

	-- effects
	local sound_cast = "DOTA_Item.Buckler.Activate"
	EmitSoundOn( sound_cast, caster )

end


		modifier_buckler_active = class({})
		local modifierAClass = modifier_buckler_active
		LinkLuaModifier("modifier_buckler_active", "items/buckler_classic", LUA_MODIFIER_MOTION_NONE)

		function modifierAClass:IsHidden()
			return false
		end

		function modifierAClass:IsPurgable()
			return true
		end

		function modifierAClass:RemoveOnDeath()
    		return true
		end


		function modifierAClass:DeclareFunctions()
			local funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			}
			return funcs
		end

			function modifierAClass:GetModifierPhysicalArmorBonus()
				return self:GetAbility():GetSpecialValueFor("active_armor")
			end



		--[[function modifierAClass:PlayEffects( caster )
			-- Get Resources
			local particle_cast = "particles/items_fx/buckler.vpcf"
			--local sound_cast = "DOTA_Item.PhaseBoots.Activate"

			-- Create Particle
			caster.buckler_particle2 = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		end


		function modifierAClass:OnDestroy()

			local caster = self:GetParent()

			--effects
			ParticleManager:DestroyParticle(caster.buckler_particle2,false)
			ParticleManager:ReleaseParticleIndex( caster.buckler_particle2 )
		end

		]]













-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Buckler Passive Bonuses Modifier
modifier_buckler_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_buckler_classic:IsHidden()
	return true
end

function modifier_buckler_classic:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_buckler_classic:OnCreated( kv )

	local caster = self:GetParent()
	--effects
	--self:PlayEffects( caster )

	-- references
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" ) -- special value
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) -- special value


end

function modifier_buckler_classic:OnRefresh( kv )

	-- references
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" ) -- special value
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) -- special value
	
end

function modifier_buckler_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_buckler_classic:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end




function modifier_buckler_classic:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_buckler_classic:GetModifierBonusStats_Strength()
	return self.bonus_all_stats
end

function modifier_buckler_classic:GetModifierBonusStats_Intellect()
	return self.bonus_all_stats
end

function modifier_buckler_classic:GetModifierBonusStats_Agility()
	return self.bonus_all_stats
end


---------------------------------------
-- AURA PART

local modifierClass = modifier_buckler_classic
local modifierName = 'modifier_buckler_classic'
LinkLuaModifier(modifierName, "items/buckler_classic", LUA_MODIFIER_MOTION_NONE)


modifier_buckler_aura = class({})
local buffModifierClass = modifier_buckler_aura
local buffModifierName = 'modifier_buckler_aura'
LinkLuaModifier(buffModifierName, "items/buckler_classic", LUA_MODIFIER_MOTION_NONE)

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
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifierClass:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

function modifierClass:RemoveOnDeath()
    return false
end

function modifierClass:GetModifierAura()
    return buffModifierName
end



--[[ Aura Visual
function modifierClass:PlayEffects( caster )

		local caster = self:GetParent()

		-- Get Resources
		local particle_cast = "particles/items_fx/buckler.vpcf"
		--local sound_cast = "DOTA_Item.PhaseBoots.Activate"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		--EmitSoundOn( sound_cast, caster )
end]]










----------------
-- ALLY BUFF  --
----------------

function buffModifierClass:OnCreated()

	--effects
	local caster = self:GetParent()
	self:PlayEffects( caster )

	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "aoe_armor" )
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function buffModifierClass:GetModifierPhysicalArmorBonus()
	local npc = self:GetParent()
	if npc:HasModifier("modifier_mekansm_aura") then return 0 end
	return self.bonus_armor
end



-- Aura Visual
function buffModifierClass:PlayEffects( caster )

		-- Get Resources
		local particle_cast = "particles/items_fx/buckler.vpcf"
		--local sound_cast = "DOTA_Item.PhaseBoots.Activate"

		-- Create Particle
		caster.buckler_particle = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		
		-- Create Sound
		--EmitSoundOn( sound_cast, caster )
end


function buffModifierClass:OnDestroy()

	local caster = self:GetParent()

	--effects
	ParticleManager:DestroyParticle(caster.buckler_particle,false)
	ParticleManager:ReleaseParticleIndex( caster.buckler_particle )
end





