item_trident_classic = class({})

LinkLuaModifier("modifier_trident_classic","items/trident_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_trident_maim","items/trident_classic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_trident_slow_debuff","items/trident_classic", LUA_MODIFIER_MOTION_NONE)

function item_trident_classic:GetIntrinsicModifierName()
	return "modifier_trident_classic"
end





-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Trident Passive Bonuses Modifier
modifier_trident_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_trident_classic:IsHidden()
	return true
end

function modifier_trident_classic:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_trident_classic:OnCreated( kv )

	-- references
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) -- special value
	self.maim_chance = self:GetAbility():GetSpecialValueFor( "maim_chance" ) -- special value
	self.maim_duration = self:GetAbility():GetSpecialValueFor( "maim_duration" ) -- special value

	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" ) -- special value
	self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_amp" ) -- special value

	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" ) -- special value
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "movement_speed_percent_bonus" ) -- special value

	self.frost_duration = self:GetAbility():GetSpecialValueFor( "frost_slow_duration" )
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" )
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "bonus_range" )

end

function modifier_trident_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_trident_classic:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_trident_classic:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,

		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,

		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,

		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,		
	}

	return funcs
end


function modifier_trident_classic:GetModifierBonusStats_Strength()
	return self.bonus_all_stats
end

function modifier_trident_classic:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end

function modifier_trident_classic:GetModifierProcAttack_BonusDamage_Physical( params )

		local attacker = self:GetParent()
		local target = params.target
		local maim_success = RandomInt(1, 100)

		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then
			if (maim_success <= self.maim_chance and ( not attacker:IsIllusion() )) then
				target:AddNewModifier(attacker, self:GetAbility(), "modifier_trident_maim", { duration = self.maim_duration})

				-- effects
				local sound_cast = "DOTA_Item.Maim"
				EmitSoundOn( sound_cast, target )
			end
		end

	return 0
end



function modifier_trident_classic:GetModifierBonusStats_Intellect()
	return self.bonus_all_stats
end

function modifier_trident_classic:GetModifierPercentageManacost()
	return self.manacost_reduction
end

function modifier_trident_classic:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_trident_classic:GetModifierPercentageCooldown()
	return self.cdr
end



function modifier_trident_classic:GetModifierBonusStats_Agility()
	return self.bonus_all_stats
end

function modifier_trident_classic:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_trident_classic:GetModifierMoveSpeedBonus_Percentage_Unique()
	return self.bonus_ms
end

--Extra: Bonus Attack Range
function modifier_trident_classic:GetModifierAttackRangeBonusUnique()
	local caster = self:GetParent()
	if not caster:IsRangedAttacker() then return self.bonus_range end
end		





--------------------------------------------------------------------
--------------------------------------------------------------------
-- Trident slow 

function modifier_trident_classic:OnAttackLanded( keys )

	if not IsServer() then return end

	local attacker = keys.attacker
	local target = keys.target

	if target == self:GetParent() then
		attacker:AddNewModifier(target, self:GetAbility(), "modifier_trident_slow_debuff", { duration = self.frost_duration })
	end
end


-----------------------------------------------
-- Modifier for the slow

modifier_trident_slow_debuff = class({})

-- Classifications
function modifier_trident_slow_debuff:IsHidden()
	return false
end

function modifier_trident_slow_debuff:IsDebuff()
	return true
end

function modifier_trident_slow_debuff:IsStunDebuff()
	return false
end

function modifier_trident_slow_debuff:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_trident_slow_debuff:DeclareFunctions()
	local funcs = {

		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_trident_slow_debuff:OnCreated( kv )
	
	-- references
	self.frost_neg = self:GetAbility():GetSpecialValueFor( "frost_heal_negation" )
	self.frost_slow = self:GetAbility():GetSpecialValueFor( "frost_slow" )

	-- effects
	local target = self:GetParent()
	local sound_cast = "Hero_Ancient_Apparition.IceBlastRelease.Tick"
	EmitSoundOn( sound_cast, target )

end

function modifier_trident_slow_debuff:OnRefresh( kv )

	-- references
	self.frost_neg = self:GetAbility():GetSpecialValueFor( "frost_heal_negation" )
	self.frost_slow = self:GetAbility():GetSpecialValueFor( "frost_slow" )

	-- effects
	local target = self:GetParent()	
	local sound_cast = "Hero_Ancient_Apparition.IceBlastRelease.Tick"
	EmitSoundOn( sound_cast, target )

end


function modifier_trident_slow_debuff:GetModifierHealAmplify_PercentageTarget()
	--Amplifies heals your unit provides as a source
	return -self.frost_neg
end


function modifier_trident_slow_debuff:GetModifierHPRegenAmplify_Percentage()
	--Amplifies heals your unit provides as a source
	return -self.frost_neg
end


function modifier_trident_slow_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self.frost_slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_trident_slow_debuff:GetEffectName()
	return "particles/status_fx/status_effect_iceblast.vpcf"
end

function modifier_trident_slow_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end






















---------------------------------------------------------------------
---------------------------------------------------------------------
-- Trident Maim Debuff

modifier_trident_maim = class({})

-- Classifications
function modifier_trident_maim:IsHidden()
	return false
end

function modifier_trident_maim:IsDebuff()
	return true
end

function modifier_trident_maim:IsStunDebuff()
	return false
end

function modifier_trident_maim:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_trident_maim:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_trident_maim:OnCreated( kv )
	
	-- references
	self.caster = self:GetCaster()
	self.maim_slow_ms = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement" ) -- special value
	self.maim_slow_ms_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement_range" ) -- special value
	self.maim_slow_atk = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack" ) -- special value
	self.maim_slow_atk_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack_range" ) -- special value


end

function modifier_trident_maim:OnRefresh( kv )

	-- references
	self.caster = self:GetCaster()
	self.maim_slow_ms = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement" ) -- special value
	self.maim_slow_ms_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_movement_range" ) -- special value
	self.maim_slow_atk = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack" ) -- special value
	self.maim_slow_atk_range = -self:GetAbility():GetSpecialValueFor( "maim_slow_attack_range" ) -- special value

end

function modifier_trident_maim:GetModifierMoveSpeedBonus_Percentage()

	if self.caster:IsRangedAttacker() then 
		return self.maim_slow_ms_range
	else
		return self.maim_slow_ms
	end 

end

function modifier_trident_maim:GetModifierAttackSpeedBonus_Constant()

	if self.caster:IsRangedAttacker() then 
		return self.maim_slow_atk_range
	else
		return self.maim_slow_atk
	end 
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_trident_maim:GetEffectName()
	return "particles/items2_fx/sange_maim_d.vpcf"
end

function modifier_trident_maim:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


