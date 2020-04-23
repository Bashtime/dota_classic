axe_one = class({})
LinkLuaModifier("modifier_axe_one", "axe_one", LUA_MODIFIER_MOTION_NONE)

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



-----------------------------------
-----------------------------------
-- AXE ONE-MAN ARMY Modifier

modifier_axe_one = class({})

function modifier_axe_one:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_axe_one:IsHidden()
	return true
end

function modifier_axe_one:IsPurgable()
	return false
end

function modifier_axe_one:RemoveOnDeath() 
	return false 
end


function modifier_axe_one:GetModifierMoveSpeedBonus_Constant(params)
	return self:GetAbility():GetSpecialValueFor("bonus_ms");
end

function modifier_axe_one:GetModifierConstantHealthRegen(params)
	return self:GetAbility():GetSpecialValueFor("bonus_reg");
end

function modifier_axe_one:GetModifierAttackSpeedBonus_Constant(params)
	return self:GetAbility():GetSpecialValueFor("bonus_as");
end