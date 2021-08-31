--Class Definitions

	item_mboots_classic = class({})
	local itemClass = item_mboots_classic

	--Active Bonuses Modifier
	modifier_mboots_active = class({})
	local buffModifierClass = modifier_mboots_active
	local buffModifierName = 'modifier_mboots_active'
	LinkLuaModifier(buffModifierName, "items/mboots_classic", LUA_MODIFIER_MOTION_NONE)	

	--Passive instrinsic Bonus Modifier
	modifier_mboots = class({})
	local modifierClass = modifier_mboots
	local modifierName = 'modifier_mboots'
	LinkLuaModifier(modifierName, "items/mboots_classic", LUA_MODIFIER_MOTION_NONE)


		--Usual Settings
		function itemClass:GetIntrinsicModifierName()
			return modifierName
		end

		function modifierClass:IsHidden()
			return true
		end

		function modifierClass:IsPurgable()
			return false
		end

		function modifierClass:RemoveOnDeath()
    		return false
		end

		function modifierClass:GetAttributes()
			return MODIFIER_ATTRIBUTE_NONE
		end


--Casting
function itemClass:OnSpellStart()

	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local radius = self:GetSpecialValueFor( "radius" )
	local active_mana = self:GetSpecialValueFor( "active_mana" )

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

		ally:GiveMana(active_mana)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, ally, active_mana, nil)

		-- Get Resources
		local particle_cast = "particles/items_fx/arcane_boots_recipient.vpcf"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:ReleaseParticleIndex( effect_cast )
	end

	-- effects
	local sound_cast = "DOTA_Item.ArcaneBoots.Activate"
	EmitSoundOn( sound_cast, caster )

	-- Get Resources
	local particle_cast = "particles/items_fx/arcane_boots.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end




-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_dmg_range = self:GetAbility():GetSpecialValueFor( "bonus_dmg_range" )	
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.bonus_armor_range = self:GetAbility():GetSpecialValueFor( "bonus_armor_range" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" )

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	

	-- Extra references


	--Stuff for Visual
	--self:SetStackCount(1)
end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

					MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

					MODIFIER_PROPERTY_HEALTH_BONUS,
					MODIFIER_PROPERTY_MANA_BONUS,
					MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
					MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

					--Add more stuff below

				}

				return funcs
			end


				--DMG; ARMOR; MS; AS; MR
				function modifierClass:GetModifierPreAttack_BonusDamage()
					if self:GetParent():IsRangedAttacker() then return self.bonus_dmg_range end
					return self.bonus_dmg
				end

				function modifierClass:GetModifierPhysicalArmorBonus()
					if self:GetParent():IsRangedAttacker() then return self.bonus_armor_range end
					return self.bonus_armor
				end

				function modifierClass:GetModifierMoveSpeedBonus_Special_Boots()
					--Useless now
					--[[
					local caster = self:GetParent()
					if caster:HasModifier("modifier_tranquil") then return 0 end
					if caster:HasModifier("modifier_item_boots_of_travel") then return 0 end
					if caster:HasModifier("modifier_greaves") then return 0 end
					if caster:HasModifier("modifier_treads_of_ermacor") then return 0 end
					if caster:HasModifier("modifier_spider_legs_classic") then return 0 end	
					]]				
					return self.bonus_ms
				end

				function modifierClass:GetModifierAttackSpeedBonus_Constant()
					return self.bonus_as
				end

				function modifierClass:GetModifierMagicalResistanceBonus()
					return self.bonus_mr
				end



				--STR; AGI; INT
				function modifierClass:GetModifierBonusStats_Strength()
					return self.bonus_str
				end

				function modifierClass:GetModifierBonusStats_Agility()
					return self.bonus_agi
				end

				function modifierClass:GetModifierBonusStats_Intellect()
					return self.bonus_int
				end



				--HP; MANA; REG
				function modifierClass:GetModifierHealthBonus()
					return self.bonus_hp
				end

				function modifierClass:GetModifierManaBonus()
					return self.bonus_mana
				end

				function modifierClass:GetModifierConstantHealthRegen()
					return self.hp_reg
				end

				function modifierClass:GetModifierConstantManaRegen()
					return self.mana_reg
				end




--#########################
--## Active modifier here
--#########################

function buffModifierClass:OnCreated()
	--References
	local caster = self:GetParent()


		--effects
	self:PlayEffects( caster )

end

		function buffModifierClass:IsHidden()
			return false
		end

		function buffModifierClass:IsPurgable()
			return true
		end

		function buffModifierClass:RemoveOnDeath()
    		return true
		end


function buffModifierClass:DeclareFunctions()
	local funcs = {

	}
	return funcs
end

function buffModifierClass:GetModifierManaBonus()
	if self:GetParent():IsRangedAttacker() then return self.turn_range end
	return self.turn
end






--Visuals

--------------------------------------------------------------------------------
--[[ Graphics & Animations
function buffModifierClass:GetEffectName()
	return "particles/econ/events/ti6/phase_boots_ti6.vpcf"
end

function buffModifierClass:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end]]