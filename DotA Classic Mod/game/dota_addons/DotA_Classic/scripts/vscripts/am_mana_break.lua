-- Editors:
--     AtroCty,  04.07.2017
--	   Bashtime, 28.01.2020
--	   Credits: Cykada, EmberCookies, Silaah, Perry, the whole dota2MODcommunity

local LinkedModifiers = {}
-------------------------------------------
--        MANA BREAK
-------------------------------------------
-- Hidden Modifiers:

am_mana_break = class({})

function am_mana_break:GetAbilityTextureName()
	return "antimage_mana_break"
end

function am_mana_break:GetIntrinsicModifierName()
	return "modifier_am_mana_break_passive"
end

-- Mana break modifier
modifier_am_mana_break_passive = modifier_am_mana_break_passive or class({})

function modifier_am_mana_break_passive:IsHidden()
	return true
end

function modifier_am_mana_break_passive:IsPurgable()
	return false
end

function modifier_am_mana_break_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT
	}
end

function modifier_am_mana_break_passive:OnCreated()
	if IsServer() then
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.damage_per_burn = self.ability:GetSpecialValueFor("damage_per_burn")
		self.base_mana_burn = self.ability:GetSpecialValueFor("base_mana_burn")
		self.illusions_efficiency_pct = self.ability:GetSpecialValueFor("illusions_efficiency_pct")
	end
end

function modifier_am_mana_break_passive:OnRefresh()
	if IsServer() then
		self:OnCreated()
	end
end

function modifier_am_mana_break_passive:OnAttackStart(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.target

		
		local has_purity = attacker:HasAbility("am_purity")


		-- If caster has break, do nothing
		if attacker:PassivesDisabled() then
			return nil
		end

		-- If the target is an item, do nothing
		if target:IsItemContainer() then
			return nil
		end

		-- If there isn't a valid target, do nothing
		if target:GetMaxMana() == 0 or target:IsMagicImmune() then
			return nil
		end

		-- Only apply on caster attacking enemies
		if self.parent == attacker and target:GetTeamNumber() ~= self.parent:GetTeamNumber() then

			-- Calculate mana to burn, considering "Purity of Will" Level
			local target_mana_burn = target:GetMana()
			 
			if has_purity then

				local percentage_mana_burn = target:GetMaxMana() * self:FindAbilityByName("am_purity"):GetSpecialValueFor("manabreak_perc_adjust") * 0.01
				local overall_mana_burn = self.base_mana_burn + percentage_mana_burn

					if (target_mana_burn > overall_mana_burn) then
						target_mana_burn = overall_mana_burn
				
					else if (target_mana_burn > self.base_mana_burn) then target_mana_burn = self.base_mana_burn
					 	end
					end
			end

			if self:GetParent():IsIllusion() then
				target_mana_burn = target_mana_burn * self:GetAbility():GetSpecialValueFor("illusion_percentage") * 0.01
			end

						-- Decide how much damage should be added
			self.add_damage = target_mana_burn * self.damage_per_burn
		end
	end
end


function modifier_am_mana_break_passive:OnAttackLanded(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.target

		-- If target has break, do nothing
		if attacker:PassivesDisabled() then
			return nil
		end

		-- If there isn't a valid target, do nothing
		if target:GetMaxMana() == 0 or target:IsMagicImmune() then
			return nil
		end

		-- Only apply on caster attacking enemies
		if self.parent == attacker and target:GetTeamNumber() ~= self.parent:GetTeamNumber() then

			-- Play sound
			target:EmitSound("Hero_Antimage.ManaBreak")

			-- Add hit particle effects
			local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(manaburn_pfx, 0, target:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex(manaburn_pfx)

			-- Check if Purity of Will is learned, then Calculate and burn mana
			local target_mana_burn = target:GetMana()


			--if has_purity then

				-- local percentage_mana_burn = target:GetMaxMana() * self:FindAbilityByName("am_purity"):GetSpecialValueFor("manabreak_perc_adjust") * 0.01
				-- local overall_mana_burn = self.base_mana_burn + percentage_mana_burn

				--if (target_mana_burn > overall_mana_burn) then
				--	target_mana_burn = overall_mana_burn

					if (target_mana_burn > self.base_mana_burn) then target_mana_burn = self.base_mana_burn
				 	end
				--end
						
				if self:GetParent():IsIllusion() then
					target_mana_burn = target_mana_burn * self:GetAbility():GetSpecialValueFor("illusion_percentage") * 0.01
				end


				target:ReduceMana(target_mana_burn)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, target_mana_burn, nil)

			-- If the target is magic immune, this is it for us.
				if target:IsMagicImmune() then
					return nil
				end
			--end
		end
	end
end

function modifier_am_mana_break_passive:GetModifierPreAttack_BonusDamage(params)
	if IsServer() then
		return self.add_damage
	end
end