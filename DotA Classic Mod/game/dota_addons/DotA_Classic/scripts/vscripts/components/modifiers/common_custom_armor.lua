-- From moddota discord
modifier_common_custom_armor = class({})

function modifier_common_custom_armor:IsPurgable()
    return false
end

function modifier_common_custom_armor:IsHidden()
    return true
end

function modifier_common_custom_armor:RemoveOnDeath()
    return false
end

function modifier_common_custom_armor:IsPermanent()
    return true
end

function modifier_common_custom_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
        MODIFIER_STATE_BLOCK_DISABLED,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
end

-- Only run on server, so that the client sees unmodified armor
if IsServer() then
    -- Remove all of the unit's actual armour
    function modifier_common_custom_armor:GetModifierPhysicalArmorBonus()
        if (self.checkArmor) then
            return 0
        else
            self.checkArmor = true
            local armor = self:GetParent():GetPhysicalArmorValue(false)
            self.checkArmor = false

            return armor * -1
        end
    end

    -- Recalculates incoming damage based on armour
    function modifier_common_custom_armor:GetModifierIncomingPhysicalDamage_Percentage()
        self.checkArmor = true
        local armor = self:GetParent():GetPhysicalArmorValue(false)
        self.checkArmor = false
        local physicalResistance = 0.06*armor/(1+0.06*math.abs(armor)) * 100
        --print("common_custom_armor.lua | Physical resistance of: "..tostring(physicalResistance).." for unit with: "..tostring(armor).." armor")
        return -physicalResistance
    end

    -- Disable all kind of Damage Block to disable innate melee damage block
    function modifier_common_custom_armor:CheckState(keys)
        return {[MODIFIER_STATE_BLOCK_DISABLED] = true}
    end

    --Reconstruct Damage Block
    function modifier_common_custom_armor:GetModifierTotal_ConstantBlock(keys)

        --Checking for Ranged Blocks
        if keys.target:IsRangedAttacker() and keys.target:IsHero() and keys.damage_type == DAMAGE_TYPE_PHYSICAL and keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK  then --Blocking for ranged heroes
            --actual_damage_post_block = (keys.original_damage - block) * reduction_quotient = keys.damage - block * reduction_quotient
            local reduction_quotient = keys.damage / keys.original_damage

            --Ranged Block for Crimson Active
			if keys.target:HasModifier("modifier_item_crimson_guard_extra") then --Crimson Active
                local block = 60
            
				if keys.original_damage < block then
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil)
                    return keys.original_damage 
				else
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)	
                    return block * reduction_quotient
				end
            end
			
            --Ranged Block for Vangbased Items
			if ((keys.target:HasModifier("modifier_item_crimson_guard") or keys.target:HasModifier("modifier_item_vanguard")) or keys.target:HasModifier("modifier_item_abyssal_blade")) then
                local vangcounter = 0 
                local block = 35

				for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
					local item = keys.target:GetItemInSlot(i)
   					if item then
   						if ( ((item:GetName() == "item_vanguard") or (item:GetName() == "item_crimson_guard")) or item:GetName() == "item_abyssal_blade" ) then
       						vangcounter = vangcounter + 1
   						end
   					end
				end
           		
                local blockChance = (0.5 ^ vangcounter)
				if RandomFloat(0, 1) > blockChance then
					if keys.original_damage < block then
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                        return keys.original_damage 
					else
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                        return block * reduction_quotient	
					end
                end
            end 

            --Ranged Block for PMS
            if keys.target:HasModifier("modifier_item_poor_mans_shield") then
                local block = 10
                if keys.attacker:IsHero() then
				    if keys.original_damage < block then
					    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                        return keys.original_damage
				    else
					    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                        return block * reduction_quotient	
				    end
                else
                    local pmscounter = 0 
                    for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
                        local item = keys.target:GetItemInSlot(i)
                        if item then
                            if item:GetName() == "item_pms" then
                                pmscounter = pmscounter + 1
                            end
                        end
                    end
                       
                    local blockChance = (0.47 ^ pmscounter)
                    if RandomFloat(0, 1) > blockChance then
                        if keys.original_damage < block then
	    					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                            return keys.original_damage
			    		else
				    		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                            return block * reduction_quotient	
					    end
                    end
                end
            end

            --Ranged Block Stout
			if keys.target:HasModifier("modifier_item_stout_shield") then
				local stoutcounter = 0
                local block = 8

				for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
					local item = keys.target:GetItemInSlot(i)
					if item then
						if item:GetName() == "item_stout_shield" then
				    		stoutcounter = stoutcounter + 1
						end
					end
				end	

          		local blockChance = (0.5 ^ stoutcounter)
				if RandomFloat(0, 1) > blockChance then --Range	Reduction for Stout
					if keys.original_damage < block then
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                        return keys.original_damage
					else
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)	
                        return block * reduction_quotient
					end
                end
            end

            return 
        end

        --Checking for Melee Blocks
        if not keys.target:IsRangedAttacker() and keys.target:IsHero() and keys.damage_type == DAMAGE_TYPE_PHYSICAL and keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK  then --Blocking for melee heroes
            --actual_damage_post_block = (keys.original_damage - block) * reduction_quotient = keys.damage - block * reduction_quotient
            local reduction_quotient = keys.damage / keys.original_damage

            --Melee Block for Vangbased Items
            if ((keys.target:HasModifier("modifier_item_crimson_guard") or keys.target:HasModifier("modifier_item_vanguard")) or keys.target:HasModifier("modifier_item_abyssal_blade")) then
                local vangcounter = 0 
                local block = 70

                for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
                local item = keys.target:GetItemInSlot(i)
                   if item then
                       if ( ((item:GetName() == "item_vanguard") or (item:GetName() == "item_crimson_guard")) or item:GetName() == "item_abyssal_blade" ) then
                           vangcounter = vangcounter + 1
                       end
                   end
                end
               
                local blockChance = (0.5 ^ vangcounter)
                if RandomFloat(0, 1) > blockChance then
                    if keys.original_damage < block then
                        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                        return keys.original_damage 
                    else
                        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                        return block * reduction_quotient	
                    end
                end
            end

            --Melee Block for Crimson Active
			if keys.target:HasModifier("modifier_item_crimson_guard_extra") then --Crimson Active
                local block = 60
            
				if keys.original_damage < block then
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil)
                    return keys.original_damage 
				else
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)	
                    return block * reduction_quotient
				end
            end

            --Tide Kraken Shell Block Logic
            if keys.target:HasModifier("modifier_tidehunter_kraken_shell") then
                local kraken_block = keys.target:FindModifierByName("modifier_tidehunter_kraken_shell"):GetAbility():GetSpecialValueFor("damage_reduction")

                if kraken_block > 20 then
                    if keys.original_damage < kraken_block then
                        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil)
                        return keys.original_damage 
                    else
                        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, kraken_block, nil)	
                        return kraken_block * reduction_quotient
                    end 
                elseif keys.target:HasModifier("modifier_item_poor_mans_shield") then
                    local block = 20
                    if keys.attacker:IsHero() then
                        if keys.original_damage < block then
                            SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                            return keys.original_damage
                        else
                            SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                            return block * reduction_quotient	
                        end
                    else --Check PMS Creep Block Chance
                        local pmscounter = 0 
                        for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
                            local item = keys.target:GetItemInSlot(i)
                            if item then
                                if item:GetName() == "item_pms" then
                                    pmscounter = pmscounter + 1
                                end
                            end
                        end
                               
                        local blockChance = (0.47 ^ pmscounter)
                        if RandomFloat(0, 1) > blockChance then
                            if keys.original_damage < block then
                                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                                return keys.original_damage
                            else
                                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                                return block * reduction_quotient	
                            end
                        else --no PMS but Kraken Block
                            if keys.original_damage < kraken_block then
                                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil)
                                return keys.original_damage 
                            else
                                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, kraken_block, nil)	
                                return kraken_block * reduction_quotient
                            end 
                        end
                    end
                end
            end

            -- PMS for non-Tide Melee heroes
            if keys.target:HasModifier("modifier_item_poor_mans_shield") then
                local block = 20
                if keys.attacker:IsHero() then
				    if keys.original_damage < block then
					    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                        return keys.original_damage
				    else
					    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                        return block * reduction_quotient	
				    end
                else
                    local pmscounter = 0 
                    for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
                        local item = keys.target:GetItemInSlot(i)
                        if item then
                            if item:GetName() == "item_pms" then
                                pmscounter = pmscounter + 1
                            end
                        end
                    end
                       
                    local blockChance = (0.47 ^ pmscounter)
                    if RandomFloat(0, 1) > blockChance then
                        if keys.original_damage < block then
	    					SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                            return keys.original_damage
			    		else
				    		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)
                            return block * reduction_quotient	
					    end
                    end
                end
            end

            --Melee Block Stout
			if keys.target:HasModifier("modifier_item_stout_shield") then
				local stoutcounter = 0
                local block = 16

				for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
					local item = keys.target:GetItemInSlot(i)
					if item then
						if item:GetName() == "item_stout_shield" then
				    		stoutcounter = stoutcounter + 1
						end
					end
				end	

          		local blockChance = (0.5 ^ stoutcounter)
				if RandomFloat(0, 1) > blockChance then 
					if keys.original_damage < block then
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, keys.original_damage, nil) 
                        return keys.original_damage
					else
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, keys.target, block, nil)	
                        return block * reduction_quotient
					end
                end
            end

            return 
        end            
    end
end