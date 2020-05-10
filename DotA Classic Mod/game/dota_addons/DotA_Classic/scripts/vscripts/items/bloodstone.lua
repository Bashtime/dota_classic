--Class Definitions

	item_bloodstone_classic = class({})
	local itemClass = item_bloodstone_classic

	--Passive instrinsic Bonus Modifier
	modifier_bloodstone_classic = class({})
	local modifierClass = modifier_bloodstone_classic
	local modifierName = 'modifier_bloodstone_classic'
	LinkLuaModifier(modifierName, "items/bloodstone", LUA_MODIFIER_MOTION_NONE)


	--BS Maxcharges Counter: Aura Hack
	modifier_bs_mana_amp_and_max_charges = class({})
	LinkLuaModifier("modifier_bs_mana_amp_and_max_charges", "items/bloodstone", LUA_MODIFIER_MOTION_NONE)

	local buffModifierClass = modifier_bs_mana_amp_and_max_charges
	local buffModifierName = 'modifier_bs_mana_amp_and_max_charges'	

	function buffModifierClass:IsHidden()
		return true
	end
	
	function buffModifierClass:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_HERO_KILLED,
			MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
				}
		return funcs
	end

	function buffModifierClass:OnHeroKilled( params )

		local caster = self:GetParent()
		local killer = params.attacker
		local victim = params.target

		--Chargeloss for deaths
		if victim == caster and not caster:IsReincarnating() then
			local max_charges = 0

			for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
				local item = caster:GetItemInSlot(i)
				if item then
					if (item:GetName() == "item_bloodstone_classic") then
						max_charges = math.max(max_charges, item:GetCurrentCharges())
					end
				end	
			end

			local time_per_charge = self:GetAbility():GetSpecialValueFor("respawn_time_per_charge")	
			local time_base = self:GetAbility():GetSpecialValueFor("respawn_time")

			Timers:CreateTimer(0.05, function()
				--Respawntime manipulation
				local old_time = caster:GetTimeUntilRespawn()
				local new_time = math.max(1, old_time - max_charges * time_per_charge - time_base)
				caster:SetTimeUntilRespawn(new_time)							
			end)
		end
	end

	--MP Regen amp
	function buffModifierClass:GetModifierMPRegenAmplify_Percentage()
		local caster = self:GetParent()
		if caster:HasModifier(modifierName) then
			return self:GetAbility():GetSpecialValueFor( "mana_amp" )
		else
			return 0
		end
	end


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

			function modifierClass:GetAuraDuration()
				return 0.05
			end


--Active Part
function itemClass:OnSpellStart()
	local caster = self:GetCaster()
	caster:Kill(self, caster)
end


-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	local caster = self:GetParent() 

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_dmg" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
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


	self.mana_amp = self:GetAbility():GetSpecialValueFor( "mana_amp" )

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

					MODIFIER_EVENT_ON_HERO_KILLED,
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

				function modifierClass:GetModifierMoveSpeedBonus_Constant()
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
					local caster = self:GetParent()
					local charges = self:GetAbility():GetCurrentCharges()
					local hp_per_charge = self:GetAbility():GetSpecialValueFor("hp_per_charge")					
					return charges * hp_per_charge +self.hp_reg
				end

				function modifierClass:GetModifierConstantManaRegen()
					local caster = self:GetParent()
					local charges = self:GetAbility():GetCurrentCharges()
					local mp_per_charge = self:GetAbility():GetSpecialValueFor("mp_per_charge")
					return charges * mp_per_charge + self.mana_reg
				end




				--Charges
				function modifierClass:OnHeroKilled( params )

					local caster = self:GetParent()
					local killer = params.attacker
					local victim = params.target

					--Chargeloss for deaths
					if victim == caster and not caster:IsReincarnating() then
						local charges_loss = self:GetAbility():GetSpecialValueFor("death_charges")
						local charges_b4 = self:GetAbility():GetCurrentCharges()
						local charges_after = math.max(charges_b4 - charges_loss, 0)

						Timers:CreateTimer(0.09, function()
							self:GetAbility():SetCurrentCharges( charges_after )						
						end)

						return
					end

					--Chargegains for kills
					if killer == caster then
						local charges_gain = self:GetAbility():GetSpecialValueFor("kill_charges")
						local charges_b4 = self:GetAbility():GetCurrentCharges()
						local charges_after = charges_b4 + charges_gain

						--kill charge logic; only highest slot gains charges
						for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        					local item = caster:GetItemInSlot(i)
        					if item then
           						if (item:GetName() == "item_bloodstone_classic") then
           							local isThisBS = (item == self:GetAbility())

           							if not isThisBS then
           								break
           							else
										self:GetAbility():SetCurrentCharges( charges_after )
           							end
           						end
           					end
           				end

						return
					end


					-- Chargegains for assists
					-- Find Bloodstone owners around the victim

					local radius = self:GetAbility():GetSpecialValueFor("charge_range")
					local center = victim:GetOrigin()

					local killers_nearby = FindUnitsInRadius(
						victim:GetTeamNumber(),	-- int, your team number
						center,	-- point, center point
						nil,	-- handle, cacheUnit. (not known)
						radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
						DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
						DOTA_UNIT_TARGET_HERO,	-- int, type filter
						0,	-- int, flag filter
						0,	-- int, order filter
						false	-- bool, can grow cache
					)

					for _,killer in pairs(killers_nearby) do

						if killer == caster then
							local charges_gain = self:GetAbility():GetSpecialValueFor("kill_charges")
							local charges_b4 = self:GetAbility():GetCurrentCharges()
							local charges_after = charges_b4 + charges_gain

							--kill charge logic; only highest slot gains charges
							for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        						local item = caster:GetItemInSlot(i)
        						if item then
           							if (item:GetName() == "item_bloodstone_classic") then
           								local isThisBS = (item == self:GetAbility())

           								if not isThisBS then
           									break
           								else
											self:GetAbility():SetCurrentCharges( charges_after )
           								end
           							end
           						end
           					end

							return
						end
					end
				end				