am_purity = class({})
LinkLuaModifier("modifier_am_purity", LUA_MODIFIER_MOTION_NONE)

function am_purity:OnUpgrade()
	local caster = self:GetCaster();
	caster:AddNewModifier(caster, self, "modifier_am_purity", {duration = -1});
end

--function att_bonus:GetIntrinsicModifierName()
--	return "modifier_att_bonus"
--end