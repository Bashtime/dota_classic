axe_one = class({})
LinkLuaModifier("modifier_axe_one", LUA_MODIFIER_MOTION_NONE)

function axe_one:OnUpgrade()
	local caster = self:GetCaster()
	--[[local lvl = self:GetLevel()
	
	local illus_from_blink = caster:FindAbilityByName("special_bonus_unique_antimage_5")

	if lvl > 3 then 
		illus_from_blink:SetLevel(1)
	end

	local blinklesscd = caster:FindAbilityByName("special_bonus_unique_antimage")

  	bonusrangeblink:SetLevel(lvl)
  	blinklesscd:SetLevel(lvl)]]
	caster:AddNewModifier(caster, self, "modifier_axe_one", {duration = -1});
end

function axe_one:GetIntrinsicModifierName()
	return "modifier_axe_one"
end