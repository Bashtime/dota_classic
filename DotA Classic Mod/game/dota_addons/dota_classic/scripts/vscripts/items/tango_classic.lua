item_tango_classic = class({})


	modifier_tango_active = class({})
	local modifierClass = modifier_tango_active
	local modifierName = 'modifier_tango_active'
	LinkLuaModifier(modifierName, "items/tango_classic", LUA_MODIFIER_MOTION_NONE)


-----------------------------------------------------------------
-- Different Cast Ranges

function item_tango_classic:GetCastRange(_, hTarget)
	--First parameter is location, I guess it might be relevant for point-target abilities

	--local isTree = target:IsInstance(CDOTA_MapTree) --Checks if the target is a tree
	if hTarget then
		local stillTree = (hTarget:GetClassname() == "dota_temp_tree") --Checks if the target is a temporary tree
		if not stillTree then
			return self:GetSpecialValueFor("ally_range")
		end
	end
	return self:GetSpecialValueFor("tree_range")
end

------------------------------------------------------------------------------
--- Custom Filter

function item_tango_classic:CastFilterResultTarget( hTarget )

	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local casterteam = self:GetCaster():GetTeamNumber()
	local targetteam = hTarget:GetTeamNumber()

	if casterteam == targetteam and hTarget:IsRealHero() then return UF_SUCCESS end

	return UF_FAIL_CUSTOM
end

--------------------------------------------------------------------------------

function item_tango_classic:GetCustomCastErrorTarget( hTarget )

	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "#dota_hud_error_tango"
end


--------------------------------------------------------------------------------
-- Ability Start
function item_tango_classic:OnSpellStart()

	local item = self
	local charges_b4 = item:GetCurrentCharges()
	self.dur = self:GetSpecialValueFor("buff_duration")
	
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.isTree = target:IsInstance(CDOTA_MapTree) --Checks if the target is a tree
		
	if (not self.isTree) then

		--Kill Temporary trees
		local stillTree = (target:GetClassname() == "dota_temp_tree") --Checks again if it's still a tree, LOL
		
		if stillTree then 					
			target:Kill()
			caster:AddNewModifier(caster, self, modifierName, {duration = 2*self.dur})
						
			-- effects
			local sound_cast = "DOTA_Item.Tango.Activate"
			EmitSoundOn( sound_cast, target )

			--Charge decrease
			if charges_b4 == 1 then caster:RemoveItem(item) else
				item:SetCurrentCharges(charges_b4-1)
			end

			return
		else
		-- Share Mechanic
				local purchaser = item:GetPurchaser()
				local new_item = CreateItem("item_tango_classic", target, purchaser)
					  new_item:SetCurrentCharges(1)
        		target:AddItem(new_item)
        		

			--Charge decrease
			if charges_b4 == 1 then caster:RemoveItem(item) else
				item:SetCurrentCharges(charges_b4-1)
			end  

		  --[[for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
        	local allyitem = target:GetItemInSlot(i)

        	if allyitem then
            	if (allyitem:GetName() == "item_tango_classic") then
              		local k = allyitem:GetCurrentCharges()
              		allyitem:SetCurrentCharges(k+1)
               		return
            	end
        	end ]]

        		return
    	  --end
		end
	end

	-- CutDown trees
	if self.isTree then
		if target:IsStanding() then 
			local teamnumber = target:GetTeamNumber()
			target:CutDownRegrowAfter(TREE_REGROW_TIME, teamnumber)

			caster:AddNewModifier(caster, self, modifierName, {duration = self.dur})

			-- effects
			local sound_cast = "DOTA_Item.Tango.Activate"
			EmitSoundOn( sound_cast, target )

			--Charge decrease
			if charges_b4 == 1 then caster:RemoveItem(item) else
				item:SetCurrentCharges(charges_b4-1)
			end

			return
		end
	end

	return
end


function modifierClass:OnCreated()

	local caster = self:GetParent() 
	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )

end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,

					--Add more stuff below
				}

				return funcs
			end

				function modifierClass:GetModifierConstantHealthRegen()
					return self.hp_reg
				end

function modifierClass:IsPurgable()
	return false
end

function modifierClass:IsStackable()
	return false
end
