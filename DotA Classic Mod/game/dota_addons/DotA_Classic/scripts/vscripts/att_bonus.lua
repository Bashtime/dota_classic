att_bonus = class({})
LinkLuaModifier("modifier_att_bonus", LUA_MODIFIER_MOTION_NONE)

function att_bonus:OnUpgrade()
	local caster = self:GetCaster();
	caster:AddNewModifier(caster, self, "modifier_att_bonus", {duration = -1});
end

--function att_bonus:GetIntrinsicModifierName()
--	return "modifier_att_bonus"
--end