item_spell_prism_classic = class({})
local itemClass = item_spell_prism_classic


modifier_spellprism = class({})
local modifierClass = modifier_spellprism
local modifierName = 'modifier_spellprism'
LinkLuaModifier(modifierName, "items/spell_prism_classic", LUA_MODIFIER_MOTION_NONE)


function itemClass:GetIntrinsicModifierName()
	return modifierName
end


--------------------------------------------------------------------------------
-- Classifications
function modifierClass:IsHidden()
	return true
end

function modifierClass:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifierClass:OnCreated( kv )

	-- references
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" ) -- special value
	self.cdr = self:GetAbility():GetSpecialValueFor( "cdr" ) -- special value
	self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" )

	--self:StartIntervalThink(0.2)

end


function modifierClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifierClass:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifierClass:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,		
	}

	return funcs
end


			--Spell lifesteal mechanic
			function modifierClass:OnTakeDamage( params )

				local attacker = self:GetParent()
				local target = params.unit

				if params.attacker == attacker 
					and params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL
				then
					local particle_cast = "particles/items3_fx/octarine_core_lifesteal.vpcf"
					local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, attacker )
					ParticleManager:ReleaseParticleIndex( effect_cast )

					local flHeal = params.damage * self:GetAbility():GetSpecialValueFor( "creep_lifesteal" ) / 100

					if target:IsRealHero() then
						flHeal = params.damage * self:GetAbility():GetSpecialValueFor( "hero_lifesteal" ) / 100
					end

					attacker:Heal(flHeal, attacker)
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, flHeal, nil)
				end
			end 





function modifierClass:OnIntervalThink()

end

function modifierClass:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
	local regen = self.mana_reg / 100 * int * 0.05
	return regen
end

function modifierClass:GetModifierPercentageManacost()
	return self.manacost_reduction
end

function modifierClass:GetModifierPercentageCooldown()
	return self.cdr
end

