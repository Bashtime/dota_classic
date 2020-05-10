--Class Definitions

	item_euls2 = class({})
	local itemClass = item_euls2

	--Passive instrinsic Bonus Modifier
	modifier_euls2 = class({})
	local modifierClass = modifier_euls2
	local modifierName = 'modifier_euls2'
	LinkLuaModifier(modifierName, "items/euls2", LUA_MODIFIER_MOTION_NONE)

	--Euls MS Modifier Aura hack
	modifier_euls_ms2 = class({})
	local buffModifierClass = modifier_euls_ms2
	local buffModifierName = 'modifier_euls_ms2'
	LinkLuaModifier(buffModifierName, "items/euls2", LUA_MODIFIER_MOTION_NONE)	

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

-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	local caster = self:GetParent() 

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )

	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_as" )
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" )

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	

end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
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
					return self.bonus_dmg
				end

				function modifierClass:GetModifierPhysicalArmorBonus()
					return self.bonus_armor
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
					local caster = self:GetParent()
					local int = caster:GetModifierStackCount("modifier_spell_amp_int", caster)
					local regen = self.mana_reg / 100 * int * 0.05
					return regen
				end


--Euls MS specifications
function buffModifierClass:OnCreated()
	--Reference
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" ) -- special value

	self:StartIntervalThink(0.3)
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return funcs
end


function buffModifierClass:GetModifierMoveSpeedBonus_Constant()
	if self:GetParent():HasModifier(modifierName) then return self.bonus_ms end
	return 0
end

function buffModifierClass:IsHidden()
	return true
end





------------------------------------------------------------------------------
--- Custom Filter

function itemClass:CastFilterResultTarget( hTarget )

	local target = hTarget
	local caster = self:GetCaster()

	local team_caster = caster:GetTeamNumber()
	local team_target = target:GetTeamNumber()

	if caster == target then 
		return UF_SUCCESS
	end

	if ( (team_caster == team_target) and (target:IsMagicImmune()) ) then
		return UF_FAIL_MAGIC_IMMUNE_ALLY
	end

	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, team_caster )

	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end


--Active Part
function itemClass:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	--[[ Add CD on Euls Lvl 1
	for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
        local item = caster:GetItemInSlot(i)
 		if item then
         	if item:GetName() == "item_euls" then
           		item:StartCooldown(cd)
           	end
        end
    end	]]		

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	local team_caster = caster:GetTeamNumber()
	local team_target = target:GetTeamNumber()

	if team_target == team_caster then
		target:Purge(false, true, false, false, false)
	else
		target:Purge(true, false, false, false, false)
	end	
	target:AddNewModifier(caster, self, "modifier_eul_cyclone", { duration = self:GetSpecialValueFor( "cyclone_duration" )})

	-- effects
	local sound_cast = "DOTA_Item.Cyclone.Activate"
	EmitSoundOn( sound_cast, target )
end

