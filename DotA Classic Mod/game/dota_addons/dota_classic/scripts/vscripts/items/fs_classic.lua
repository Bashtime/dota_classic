item_fs_classic = class({})

LinkLuaModifier("modifier_fs_classic_passive","items/fs_classic", LUA_MODIFIER_MOTION_NONE)

function item_fs_classic:GetIntrinsicModifierName()
	return "modifier_fs_classic_passive"
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- fs Passive Bonuses Modifier
modifier_fs_classic_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_fs_classic_passive:IsHidden()
	return true
end

function modifier_fs_classic_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_fs_classic_passive:OnCreated()
	-- references
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) -- special value
	self.regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value	
end

function modifier_fs_classic_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_fs_classic_passive:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}

	return funcs
end


function modifier_fs_classic_passive:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_fs_classic_passive:GetModifierConstantHealthRegen()
	return self.regen
end


-- Author: MouJiaoZi
-- Date: 2017/12/02 

---------------------------------------------
-- Force Staff Active from Dota IMBA
---------------------------------------------
LinkLuaModifier("modifier_forcestaff_active", "items/ballista_classic", LUA_MODIFIER_MOTION_NONE)

function item_fs_classic:CastFilterResultTarget(target)
	if self:GetCaster() == target or target:HasModifier("modifier_gyrocopter_homing_missile") then
		return UF_SUCCESS
	else
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CUSTOM, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
	end
end

function item_fs_classic:OnSpellStart()
	if not IsServer() then return end
	local ability = self
	local target = self:GetCursorTarget()

	-- If the target possesses a ready Linken's Sphere, do nothing
	if target:TriggerSpellAbsorb(ability) then
		return nil
	end
	
	EmitSoundOn("DOTA_Item.ForceStaff.Activate", target)
	target:AddNewModifier(self:GetCaster(), ability, "modifier_forcestaff_active", {duration = ability:GetSpecialValueFor("push_duration")})
end