item_diffu_blade_2 = class({})
LinkLuaModifier( "modifier_diffu_purge_passive", "items/diffu_blade_2", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_diffu_purge_active", "items/diffu_blade_2", LUA_MODIFIER_MOTION_NONE )

function item_diffu_blade_2:GetIntrinsicModifierName()
	return "modifier_diffu_purge_passive"
end

function item_diffu_blade_2:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	return behav
end


--------------------------------------------------------------------------------
-- Ability Start
function item_diffu_blade_2:OnSpellStart()
	
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local purge_duration = self:GetSpecialValueFor("purge_slow_duration")
	local root_duration = self:GetSpecialValueFor("purge_root_duration")

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
			"modifier_diffu_purge_active", -- modifier name
			{ duration = purge_duration } -- kv
		)
		target:Purge(true, false, false, false, false)		
	end

	-- effects
	local sound_cast = "DOTA_Item.DiffusalBlade.Activate"
	EmitSoundOn( sound_cast, target )
end






----------------------------------------------------------------
----------------------------------------------------------------
---- Diffusal Blade Active Purge effect

modifier_diffu_purge_active = class({})

-- Classifications
function modifier_diffu_purge_active:IsHidden()
	return false
end

function modifier_diffu_purge_active:IsDebuff()
	return true
end

function modifier_diffu_purge_active:IsStunDebuff()
	return false
end

function modifier_diffu_purge_active:IsPurgable()
	return true
end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_diffu_purge_active:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_STATE_ROOTED,
	}
	return funcs
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_diffu_purge_active:OnCreated( kv )

	--if IsServer() then

	-- references
	self.slow = {-100, -80, -60, -40, -20, 0}
	self.victim = self:GetParent()
	self.validtargetfordamage = ( self.victim:IsSummoned() or (self.victim:IsIllusion() or self.victim:IsDominated())) 
	self.i = 1

  if IsServer() then
	local damage = self:GetParent():GetMaxHealth() * self:GetAbility():GetSpecialValueFor( "playerunit_percentage_damage" ) / 100
	local ticks = self:GetAbility():GetSpecialValueFor( "purge_rate" )
	local duration = self:GetAbility():GetSpecialValueFor( "purge_slow_duration" )
	local interval = duration / ticks

		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
	
		-- apply damage
		if self.validtargetfordamage then
			ApplyDamage( self.damageTable )
		end
  
		-- Start interval
		self:StartIntervalThink( interval )
		self:OnIntervalThink()
  end		
	--end

end

function modifier_diffu_purge_active:OnRefresh( kv )
	-- update value
	self.slow = {-100, -80, -60, -40, -20, 0}
	self.i = 1

	local damage = self:GetParent():GetMaxHealth() * self:GetAbility():GetSpecialValueFor( "playerunit_percentage_damage" ) / 100
	
	if IsServer() then
		self.damageTable.damage = damage
	end

	-- apply damage
	if self.validtarget then
		ApplyDamage( self.damageTable )
	end
end

	function modifier_diffu_purge_active:GetModifierMoveSpeedBonus_Percentage()
		return self.slow[self.i]
	end

	function modifier_diffu_purge_active:GetModifierAttackSpeedBonus_Constant()
		return self.slow[self.i]
	end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_diffu_purge_active:OnIntervalThink()
	local ticks = self:GetAbility():GetSpecialValueFor( "purge_rate" )
	--local decrease_over_time = 100 / ticks
	
	--if self.slow == nil then self.slow = 0 end

	--self.slow = -100 + (decrease_over_time * self.i)
	self.i = self.i + 1
	--self:SetStackCount(self.i)

	if self.i > (ticks + 1) then self:Destroy() end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_diffu_purge_active:CheckState()
		if self.i == nil then self.i = 0 end

		if ( not self:GetParent():IsHero() and self.i < 3) then
			local state = {
				[MODIFIER_STATE_ROOTED] = true,
			}
			return state
		else 
			local state = {
				[MODIFIER_STATE_ROOTED] = false,
			}
			return state
		end
end


--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_diffu_purge_active:GetEffectName()
	return "particles/generic_gameplay/generic_purge.vpcf"
end

function modifier_diffu_purge_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end







--------------------------------------------------------------
--------------------------------------------------------------
-- Diffu Blade Stat Bonuses and feedback mechanic

modifier_diffu_purge_passive = class({})

--------------------------------------------------------------------------------
-- Classifications

	modifier_diffu_purge_passive = class({})
	local modifierClass = modifier_diffu_purge_passive
	local modifierName = 'modifier_diffu_purge_passive'

	--Feedback Modifier Aura hack
	modifier_diffu_manaburn = class({})
	local buffModifierClass = modifier_diffu_manaburn
	local buffModifierName = 'modifier_diffu_manaburn'
	LinkLuaModifier(buffModifierName, "items/diffu_blade_2", LUA_MODIFIER_MOTION_NONE)	

function modifier_diffu_purge_passive:IsHidden()
	return true
end

function modifier_diffu_purge_passive:IsPurgable()
	return false
end

function modifier_diffu_purge_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


			--Optional Aura Settings
			function modifierClass:IsAura()
    			return true
			end

			function modifierClass:IsAuraActiveOnDeath()
    			return false
			end
				--Who is affected ?
				function modifierClass:GetAuraSearchTeam()
    				return DOTA_UNIT_TARGET_TEAM_FRIENDLY
				end

				function modifierClass:GetAuraSearchType()
					return DOTA_UNIT_TARGET_HERO
				end

				function modifierClass:GetAuraSearchFlags()
    				return DOTA_UNIT_TARGET_FLAG_NONE
				end

			function modifierClass:GetAuraRadius()
				return 1
			end

			function modifierClass:GetModifierAura()
    			return buffModifierName
			end	

			function buffModifierClass:IsHidden()
				return true
			end




--------------------------------------------------------------------------------
--Stacking Modifier Effects

function modifier_diffu_purge_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end

function modifier_diffu_purge_passive:GetModifierBonusStats_Agility(params)
	return self:GetAbility():GetSpecialValueFor("bonus_agility");
end

function modifier_diffu_purge_passive:GetModifierBonusStats_Intellect(params)
	return self:GetAbility():GetSpecialValueFor("bonus_intellect");
end




------------------------------------------
--Feedback Mechanic

--------------------------------------------------------------------------------
-- Initializations
function buffModifierClass:OnCreated( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "feedback_mana_burn" ) -- special value
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
	self.burn_melee_illu = self:GetAbility():GetSpecialValueFor( "feedback_mana_burn_illusion_melee" ) -- special value
	self.burn_ranged_illu = self:GetAbility():GetSpecialValueFor( "feedback_mana_burn_illusion_ranged" ) -- special value
end

function buffModifierClass:OnRefresh( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "feedback_mana_burn" ) -- special value
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
	self.burn_melee_illu = self:GetAbility():GetSpecialValueFor( "feedback_mana_burn_illusion_melee" ) -- special value
	self.burn_ranged_illu = self:GetAbility():GetSpecialValueFor( "feedback_mana_burn_illusion_ranged" ) -- special value
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
	return funcs
end

function buffModifierClass:GetModifierProcAttack_BonusDamage_Physical( params )

	if IsServer() then
		
		local attacker = self:GetParent()

		local target = params.target
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MANA_ONLY,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then

			local mana_burn =  math.min( target:GetMana(), self.mana_break )
			if attacker:HasModifier("modifier_item_diffusal_blade") then
				mana_burn = math.min( target:GetMana(), 10 )
			end

			if attacker:IsIllusion() then

				if attacker:IsRangedAttacker() then
					mana_burn =  math.min( target:GetMana(), self.burn_ranged_illu )
					if attacker:HasModifier("modifier_item_diffusal_blade") then
						mana_burn = math.min( target:GetMana(), 2 )
					end
				else
					mana_burn =  math.min( target:GetMana(), self.burn_melee_illu )
					if attacker:HasModifier("modifier_item_diffusal_blade") then
						mana_burn = math.min( target:GetMana(), 4 )
					end					
				end
			end

			target:ReduceMana( mana_burn )

			self:PlayEffects( target )

			if attacker:IsIllusion() then
				local illudamage = {
                	victim = target,
                	attacker = attacker,
                	damage = mana_burn * self.mana_damage_pct,
                	damage_type = DAMAGE_TYPE_PHYSICAL,
                	ability = self:GetAbility(),
                	damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            	}
            	ApplyDamage( illudamage )	
            end

			return mana_burn * self.mana_damage_pct
		end

	end
end

function buffModifierClass:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/generic_gameplay/generic_manaburn.vpcf"
	local sound_cast = "Hero_Antimage.ManaBreak"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		EmitSoundOn( sound_cast, target )
end