item_sr = class({})

LinkLuaModifier("modifier_sr","items/soul_ring", LUA_MODIFIER_MOTION_NONE)

function item_sr:GetIntrinsicModifierName()
	return "modifier_sr"
end

function item_sr:OnSpellStart()

	local caster = self:GetCaster()

	--Calculate New Hp
	local hp = caster:GetHealth()
	local hp_cost = self:GetSpecialValueFor( "health_sacrifice" )
	local new_hp = math.max(hp - hp_cost, 1)
	caster:SetHealth(new_hp)

	--Add mana buff
	local duration = self:GetSpecialValueFor( "duration" )
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_item_soul_ring_buff", -- modifier name
		{ duration = duration } -- kv
	)

	--Sound effects
	local sound_cast = "DOTA_Item.SoulRing.Activate"
	EmitSoundOn( sound_cast, caster )
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Vlads Passive Bonuses Modifier

modifier_sr = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sr:IsHidden()
	return true
end

function modifier_sr:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sr:OnCreated( kv )

	-- references
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value

end

function modifier_sr:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sr:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}

	return funcs
end

function modifier_sr:GetModifierConstantHealthRegen()
	return self.bonus_regen
end

function modifier_sr:GetModifierBonusStats_Strength()
	return self.bonus_str
end

