dusa_purge = class({})
LinkLuaModifier( "modifier_dusa_purge", "heroes/medusa/dusa_purge", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function dusa_purge:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	local team_caster = caster:GetTeamNumber()
	local team_target = target:GetTeamNumber()

	if team_target == team_caster then
		target:Purge(false, true, false, false, false)
	else
	-- add modifier
		target:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_dusa_purge", -- modifier name
			{ duration = duration } -- kv
		)
		target:Purge(true, false, false, false, false)		
	end

	-- effects
	local sound_cast = "DOTA_Item.DiffusalBlade.Activate"
	EmitSoundOn( sound_cast, target )
end






--------------------------------------
--------------------------------------
-- Purge Slow Effect

modifier_dusa_purge = class({})

-- Classifications
function modifier_dusa_purge:IsHidden()
	return false
end

function modifier_dusa_purge:IsDebuff()
	return true
end

function modifier_dusa_purge:IsStunDebuff()
	return false
end

function modifier_dusa_purge:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_dusa_purge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_dusa_purge:OnCreated( kv )
	-- references
	self.slow = -100
	self.victim = self:GetParent()
	self.validtarget = ( ( self.victim:IsSummoned() and (not self.victim:IsHero()) ) or self.victim:IsIllusion() )
	self.i = 0
	--self:SetStackCount(self.i)

	local damage = self:GetAbility():GetSpecialValueFor( "summon_damage" )
	local ticks = self:GetAbility():GetSpecialValueFor( "purge_rate" )
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local interval = duration / ticks

		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
	
		-- apply damage
		if self.validtarget then
			ApplyDamage( self.damageTable )
		end
	
		-- Start interval
		self:StartIntervalThink( interval )
		self:OnIntervalThink()
	
end

function modifier_dusa_purge:OnRefresh( kv )
	-- update value
	self.slow = -100
	self.i = 0
	--self:SetStackCount(self.i)

	local damage = self:GetAbility():GetSpecialValueFor( "summon_damage" )
	
	if IsServer() then
		self.damageTable.damage = damage
	end

	-- apply damage
	if self.validtarget then
		ApplyDamage( self.damageTable )
	end
end

	function modifier_dusa_purge:GetModifierMoveSpeedBonus_Percentage()
		return self.slow
	end

	function modifier_dusa_purge:GetModifierAttackSpeedBonus_Constant()
		return self.slow
	end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_dusa_purge:OnIntervalThink()
	local ticks = self:GetAbility():GetSpecialValueFor( "purge_rate" )
	local decrease_over_time = 100 / ticks
	
	if self.slow == nil then self.slow = 0 end

	self.slow = -100 + (decrease_over_time * self.i)
	self.i = self.i + 1
	--self:SetStackCount(self.i)
	
	if self.i > ticks then self:Destroy() end


end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_dusa_purge:GetEffectName()
	return "particles/generic_gameplay/generic_purge.vpcf"
end

function modifier_dusa_purge:GetEffectAttachType()
	return PATTACH_ABS_ORIGIN
end