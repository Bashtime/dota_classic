-- first time a real hero spawn
function GameMode:OnHeroFirstSpawn(hero)
	if not hero or hero:IsNull() then return end

	if hero:IsIllusion() then
		return
	end -- Illusions will not be affected by scripts written under this line
	
	if hero == nil or hero:IsFakeHero() then return end

	-- These lines will create an item and add it to the player, effectively ensuring they start with the item
	local item = CreateItem("item_bfury", hero, hero)
	hero:AddItem(item)
  
	local playerID = hero:GetPlayerID()    

	if PlayerResource:HasRandomed(playerID) then
		Timers:CreateTimer(0.1, function()
			local mango = hero:FindItemInInventory("item_enchanted_mango")
			local faerie = hero:FindItemInInventory("item_faerie_fire")
			print(mango)
			print(faerie)

			if mango ~= nil then 
				hero:RemoveItem(mango)
			end

			if faerie ~= nil then 
				hero:RemoveItem(faerie)
			end
		end)

		hero:ModifyGold(200,false,DOTA_ModifyGold_Unspecified)
	end

	Timers:CreateTimer(0.1, function()
		local tp = hero:FindItemInInventory("item_tpscroll")

		if tp then
			hero:RemoveItem(tp)
		end
	end)

	hero.picked = true
end

-- everytime a real hero respawn
function GameMode:OnHeroSpawned(hero)

end
