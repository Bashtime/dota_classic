item_vlads_classic = class({})

LinkLuaModifier("modifier_vlads_classic","items/vlads_classic", LUA_MODIFIER_MOTION_NONE)

function item_vlads_classic:GetIntrinsicModifierName()
	return "modifier_vlads_classic"
end

function item_vlads_classic:OnSpellStart()

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

modifier_vlads_classic = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_vlads_classic:IsHidden()
	return true
end

function modifier_vlads_classic:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_vlads_classic:OnCreated( kv )

	-- references
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value

	local caster = self:GetParent() 
	if IsServer() then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_vladmir", { duration = -1}) end

	--Aura visual
	local particle_cast = "particles/aura_vlads_classic.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )	

end

function modifier_vlads_classic:OnRefresh( kv )

	-- references
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_strength" ) -- special value
	self.bonus_regen = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) -- special value
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" ) -- special value

	local caster = self:GetParent() 
	if IsServer() then caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_vladmir", { duration = -1}) end

end

function modifier_vlads_classic:OnDestroy( kv )
	local caster = self:GetParent()
	if IsServer() then caster:RemoveModifierByName("modifier_item_vladmir") end
	ParticleManager:DestroyParticle(self.effect_cast, true)
	ParticleManager:ReleaseParticleIndex( self.effect_cast )	
end

function modifier_vlads_classic:OnRemoved()
	local caster = self:GetParent()
	if IsServer() then caster:RemoveModifierByName("modifier_item_vladmir") end
end

function modifier_vlads_classic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_vlads_classic:DeclareFunctions()

	local funcs = {

		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

function modifier_vlads_classic:GetModifierConstantHealthRegen()
	return self.bonus_regen
end

function modifier_vlads_classic:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_vlads_classic:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
end
