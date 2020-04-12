am_purity = class({})
LinkLuaModifier("modifier_am_purity", LUA_MODIFIER_MOTION_NONE)

function am_purity:OnUpgrade()
	local caster = self:GetCaster()
	local lvl = self:GetLevel()
	
	local illus_from_blink = caster:FindAbilityByName("special_bonus_unique_antimage_5")

	if lvl > 3 then 
		illus_from_blink:SetLevel(1)
	end

	--local blinklesscd = caster:FindAbilityByName("special_bonus_unique_antimage")

  	--bonusrangeblink:SetLevel(lvl)
  	--blinklesscd:SetLevel(lvl)
	--caster:AddNewModifier(caster, self, "modifier_am_purity", {duration = -1});
end

--function att_bonus:GetIntrinsicModifierName()
--	return "modifier_att_bonus"
--end