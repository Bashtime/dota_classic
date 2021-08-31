	item_bfury_classic = class({})
	local itemClass = item_bfury_classic

	--Passive instrinsic Bonus Modifier
	modifier_bfury_classic = class({})
	local modifierClass = modifier_bfury_classic
	local modifierName = 'modifier_bfury_classic'
	LinkLuaModifier(modifierName, "items/bfury_classic", LUA_MODIFIER_MOTION_NONE)

	--Quell Bonus Damage Modifier Aura hack
	modifier_bfquell_effect = class({})
	local buffModifierClass = modifier_bfquell_effect
	local buffModifierName = 'modifier_bfquell_effect'
	LinkLuaModifier(buffModifierName, "items/bfury_classic", LUA_MODIFIER_MOTION_NONE)


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





------------------------------------------------------------------------------
--- Custom Filter

function itemClass:CastFilterResultTarget( hTarget )

	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local name = hTarget:GetUnitName()

	if ( (name == "npc_dota_observer_wards") or (name == "npc_dota_sentry_wards") ) then
		local casterteam = self:GetCaster():GetTeamNumber()
		local wardteam = hTarget:GetTeamNumber()

		if casterteam == wardteam then return UF_FAIL_CUSTOM end
		return UF_SUCCESS
	end

	if ( (name == "npc_dota_techies_stasis_trap") or (name == "npc_dota_techies_remote_mine") ) then
		local casterteam = self:GetCaster():GetTeamNumber()
		local wardteam = hTarget:GetTeamNumber()

		if casterteam == wardteam then return UF_FAIL_CUSTOM end
		return UF_SUCCESS
	end

	return UF_FAIL_CUSTOM
end

--------------------------------------------------------------------------------

function itemClass:GetCustomCastErrorTarget( hTarget )

	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "#dota_hud_error_qb"
end



-----------------------------------------------------------------
-- Different Cast Ranges for Trees and Wards

function itemClass:GetCastRange(_, hTarget)
	--First parameter is location, I guess it might be relevant for point-target abilities

	--local isTree = target:IsInstance(CDOTA_MapTree) --Checks if the target is a tree
	if hTarget then
		local stillTree = (hTarget:GetClassname() == "dota_temp_tree") --Checks if the target is a temporary tree
		if not stillTree then
			return self:GetSpecialValueFor("cast_range_ward")
		end
	end
		return self:GetSpecialValueFor("cast_range_tree")
end


--------------------------------------------------------------------------------
-- Ability Start
function itemClass:OnSpellStart()
	
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.isTree = target:IsInstance(CDOTA_MapTree) --Checks if the target is a tree
		

	-- load data
	local treekill_cd = self:GetSpecialValueFor("alternative_cooldown")
	
	if (not self.isTree) then


		--Kill Temporary trees
		local stillTree = (target:GetClassname() == "dota_temp_tree") --Checks again if it's still a tree, LOL
		
		if stillTree then 					
			target:Kill()

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )

			return
		end


		--Kill obs
		local name = target:GetUnitName()  

		if ( (name == "npc_dota_observer_wards") or (name == "npc_dota_sentry_wards") ) then 
			target:Kill(self, caster)

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end


		--Fuck Techies
		local name = target:GetUnitName()  

		if ( (name == "npc_dota_techies_stasis_trap") or (name == "npc_dota_techies_remote_mine") ) then 
			target:Kill(self, caster)

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end
	end

	-- CutDown trees
	if self.isTree then
		if target:IsStanding() then 
			local teamnumber = target:GetTeamNumber()
			target:CutDownRegrowAfter(TREE_REGROW_TIME, teamnumber)

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end
	end

	return
end



--------------------------------------------------------------
--------------------------------------------------------------
-- Bfury quell passive

--------------------------------------------------------------------------------
-- Initializations
function modifierClass:OnCreated( kv )
	-- references
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.hp_reg = self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,		
	}

	return funcs
end

function modifierClass:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg
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



-------------------------
--Custom Cleave Mechanic

function modifierClass:OnAttackLanded( keys )

	if not IsServer() then return end

	local attacker = keys.attacker
	local target = keys.target

	if ( attacker == self:GetParent() and (not attacker:IsRangedAttacker()) ) then

		if ( (not target:IsTower()) and (not attacker:IsIllusion()) ) then
			local damageDealt = keys.damage

			local cleaveDamage = damageDealt * self:GetAbility():GetSpecialValueFor( "cleave_damage_percent" ) / 100

			local cleaveDamageStoutRange = math.max(0 , cleaveDamage -8)
			local cleaveDamageStoutMelee = math.max(0 , cleaveDamage -16)

			local cleaveDamagePMSRange = math.max(0 , cleaveDamage -10)
			local cleaveDamagePMSMelee = math.max(0 , cleaveDamage -20)

			local cleaveDamageVangRange = math.max(0 , cleaveDamage - 35)
			local cleaveDamageVangMelee = math.max(0 , cleaveDamage - 70)			

			local cleaveDamageCrimson = math.max(0 , cleaveDamage - 60)


			--Define Bfury AoE Center
			local attackerPos = attacker:GetOrigin()
			local targetPos = target:GetOrigin()

			local radius = self:GetAbility():GetSpecialValueFor( "cleave_radius" )
			local direction =	(targetPos - attackerPos)
					direction = direction:Normalized() * radius
			local center = (attackerPos + direction)

			--Prepare DamageTable for CleaveAttack
			local damageTable = {
				nil,
				attacker = attacker,
				nil,
				damage_type = DAMAGE_TYPE_PURE,
				ability = self:GetAbility(), --Optional.
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
				}


			-- Find Units in the Bfury AoE
			local enemies = FindUnitsInRadius(
				attacker:GetTeamNumber(),	-- int, your team number
				center,	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
				)

			for _,enemy in pairs(enemies) do

				if enemy ~= target then

					--Complicated Damage Block Mechanic
					if enemy:IsRangedAttacker() then --Blocking for ranged heroes

						if enemy:HasModifier("modifier_item_crimson_guard_extra") then --Crimson Active

							if cleaveDamage < 60 then
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
							else
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 60, nil)	
							end

							damageTable.victim = enemy
							damageTable.damage = cleaveDamageCrimson
							ApplyDamage(damageTable)
						
						elseif ((enemy:HasModifier("modifier_item_crimson_guard") or enemy:HasModifier("modifier_item_vanguard")) or enemy:HasModifier("modifier_item_abyssal_blade") ) then

							local vangcounter = 0 
							for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        						local item = enemy:GetItemInSlot(i)
        						if item then
           							if ( ((item:GetName() == "item_vanguard") or (item:GetName() == "item_crimson_guard")) or item:GetName() == "item_abyssal_blade" ) then
           							vangcounter = vangcounter + 1
           							end
           						end
           					end
           					local blockChance = (0.5 ^ vangcounter)

							if RandomFloat(0, 1) > blockChance then
								if cleaveDamage < 35 then
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
								else
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 35, nil)	
								end

								damageTable.victim = enemy
								damageTable.damage = cleaveDamageVangRange
								ApplyDamage(damageTable)

								elseif enemy:HasModifier("modifier_item_poor_mans_shield") then --Range	Reduction for PMS when Vang didnt proc

									if cleaveDamage < 10 then
										SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
									else
										SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 10, nil)	
									end

									damageTable.victim = enemy
									damageTable.damage = cleaveDamagePMSRange
									ApplyDamage(damageTable)

								elseif enemy:HasModifier("modifier_item_stout_shield") then --Range	Reduction for Stout when Vang didnt proc
									local stoutcounter = 0

									for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        								local item = enemy:GetItemInSlot(i)
 
        								if item then
           									if item:GetName() == "item_stout_shield" then
           										stoutcounter = stoutcounter + 1
           									end
           								end
           							end	

          							local blockChance = (0.5 ^ stoutcounter)
									if RandomFloat(0, 1) > blockChance then --Range	Reduction for Stout

										if cleaveDamage < 8 then
											SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
										else
											SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 8, nil)	
										end

										damageTable.victim = enemy
										damageTable.damage = cleaveDamageStoutRange
										ApplyDamage(damageTable)
 									else 	--Ranged but no block item triggered
										damageTable.victim = enemy
										damageTable.damage = cleaveDamage
										ApplyDamage(damageTable) 							
									end
 							else 	--Ranged but vang didnt trigger
								damageTable.victim = enemy
								damageTable.damage = cleaveDamage
								ApplyDamage(damageTable) 							
							end



						elseif enemy:HasModifier("modifier_item_poor_mans_shield") then --Range	Reduction for PMS

							if cleaveDamage < 10 then
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
							else
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 10, nil)	
							end

								damageTable.victim = enemy
								damageTable.damage = cleaveDamagePMSRange
								ApplyDamage(damageTable)

						elseif enemy:HasModifier("modifier_item_stout_shield") then --Range Reduction for Stout
							local stoutcounter = 0

							for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        						local item = enemy:GetItemInSlot(i)
 
        						if item then
           							if item:GetName() == "item_stout_shield" then
           								stoutcounter = stoutcounter + 1
           							end
           						end
           					end	

          					local blockChance = (0.5 ^ stoutcounter)
							if RandomFloat(0, 1) > blockChance then --Range	Reduction for Stout

								if cleaveDamageStoutRange < 8 then
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamageStoutRange, nil) 
								else
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 8, nil)	
								end

								damageTable.victim = enemy
								damageTable.damage = cleaveDamageStoutRange
								ApplyDamage(damageTable)

 							else 
								damageTable.victim = enemy
								damageTable.damage = cleaveDamage
								ApplyDamage(damageTable) 							
							end
 							
 						else 
								damageTable.victim = enemy
								damageTable.damage = cleaveDamage
								ApplyDamage(damageTable) 							
						end



					else 		--Melee Blocks
						if ((enemy:HasModifier("modifier_item_crimson_guard") or enemy:HasModifier("modifier_item_vanguard")) or enemy:HasModifier("modifier_item_abyssal_blade") ) then

							local vangcounter = 0 
							for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        						local item = enemy:GetItemInSlot(i)
        						if item then
           							if ( ((item:GetName() == "item_vanguard") or (item:GetName() == "item_crimson_guard")) or item:GetName() == "item_abyssal_blade" ) then
           							vangcounter = vangcounter + 1
           							end
           						end
           					end
           					local blockChance = (0.5 ^ vangcounter)

							if RandomFloat(0, 1) > blockChance then --Vangblock succesful
								if cleaveDamage < 70 then
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
								else
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 70, nil)	
								end

								damageTable.victim = enemy
								damageTable.damage = cleaveDamageVangMelee
								ApplyDamage(damageTable)

								--Check for further Damage blocks when Vanguard failed
								elseif enemy:HasModifier("modifier_item_crimson_guard_extra") then --Melee Reduction for Crimson when Vang didnt proc

									if cleaveDamage < 60 then
										SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
									else
										SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 60, nil)	
									end

									damageTable.victim = enemy
									damageTable.damage = cleaveDamageCrimson
									ApplyDamage(damageTable)

								elseif enemy:HasModifier("modifier_item_poor_mans_shield") then --Melee	Reduction for PMS when Vang didnt proc

									if cleaveDamage < 20 then
										SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
									else
										SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 20, nil)	
									end

									damageTable.victim = enemy
									damageTable.damage = cleaveDamagePMSMelee
									ApplyDamage(damageTable)

								elseif enemy:HasModifier("modifier_item_stout_shield") then --Melee	Reduction for Stout when Vang didnt proc
									local stoutcounter = 0

									for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        								local item = enemy:GetItemInSlot(i)
 
        								if item then
           									if item:GetName() == "item_stout_shield" then
           										stoutcounter = stoutcounter + 1
           									end
           								end
           							end	

          							local blockChance = (0.5 ^ stoutcounter)
									if RandomFloat(0, 1) > blockChance then --Melee	Reduction for Stout succesful

										if cleaveDamage < 16 then
											SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
										else
											SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 16, nil)	
										end

										damageTable.victim = enemy
										damageTable.damage = cleaveDamageStoutMelee
										ApplyDamage(damageTable)
 									else 	--Melee but no block item triggered
										damageTable.victim = enemy
										damageTable.damage = cleaveDamage
										ApplyDamage(damageTable) 							
									end
 							else 	--Melee but vang didnt trigger
								damageTable.victim = enemy
								damageTable.damage = cleaveDamage
								ApplyDamage(damageTable) 							
							end

						elseif enemy:HasModifier("modifier_item_crimson_guard_extra") then --Crimson Active

							if cleaveDamage < 60 then
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
							else
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 60, nil)	
							end

							damageTable.victim = enemy
							damageTable.damage = cleaveDamageCrimson
							ApplyDamage(damageTable)

						elseif enemy:HasModifier("modifier_item_poor_mans_shield") then --Melee	Reduction for PMS, with no bigger Block effects/items

							if cleaveDamage < 20 then
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
							else
								SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 20, nil)	
							end

								damageTable.victim = enemy
								damageTable.damage = cleaveDamagePMSMelee
								ApplyDamage(damageTable)

						elseif enemy:HasModifier("modifier_item_stout_shield") then --Melee Reduction for Stout
							local stoutcounter = 0

							for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        						local item = enemy:GetItemInSlot(i)
 
        						if item then
           							if item:GetName() == "item_stout_shield" then
           								stoutcounter = stoutcounter + 1
           							end
           						end
           					end	

          					local blockChance = (0.5 ^ stoutcounter)
							if RandomFloat(0, 1) > blockChance then --Melee	Reduction for Stout succesful

								if cleaveDamage < 16 then
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, cleaveDamage, nil) 
								else
									SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, enemy, 16, nil)	
								end

								damageTable.victim = enemy
								damageTable.damage = cleaveDamageStoutMelee
								ApplyDamage(damageTable)

 							else --Stout Not succesful
								damageTable.victim = enemy
								damageTable.damage = cleaveDamage
								ApplyDamage(damageTable) 							
							end
 							
 						else --No damage block items for melee units
								damageTable.victim = enemy
								damageTable.damage = cleaveDamage
								ApplyDamage(damageTable) 							
						end --every case for damage block
					end --Damage dealt to every target
				end --every valid target
			end --Loop end
		end --valid cleave attack circumstances
	end --valid cleave attacker
end --end of function



--Quell specifications
function buffModifierClass:OnCreated()
	--Reference
	self.dmg = self:GetAbility():GetSpecialValueFor( "quelling_bonus" ) -- special value
end

function buffModifierClass:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
	}
	return funcs
end



function buffModifierClass:OnAttackStart( params )
	local attacker = self:GetParent()
	local victim = params.target

	local sameTeam = (attacker:GetTeamNumber() == victim:GetTeamNumber())

	if params.attacker == attacker then

	if sameTeam then 
		self.dmg = 0

		return
	end	
	
	if victim:IsIllusion() then 
		self.dmg = self:GetAbility():GetSpecialValueFor( "quelling_bonus_illus" )

		return
	end

	if ( victim:IsHero() or victim:IsTower() ) then 
		self.dmg = 0

		return
	end	

	if attacker:IsRangedAttacker() then 
		self.dmg = self:GetAbility():GetSpecialValueFor( "quelling_bonus_ranged" )

		return
	end

		self.dmg = self:GetAbility():GetSpecialValueFor( "quelling_bonus" )

	end
end

function buffModifierClass:GetModifierBaseDamageOutgoing_Percentage( params )
	if IsServer() then --Hides the bonus damage in the UI
		if self:GetParent():HasModifier(modifierName) then return self.dmg end
		return 0
	end
end

function buffModifierClass:IsHidden()
	return true
end