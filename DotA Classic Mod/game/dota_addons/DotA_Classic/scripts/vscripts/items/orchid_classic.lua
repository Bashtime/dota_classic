--Class Definitions

	item_orchid_classic = class({})
	local itemClass = item_orchid_classic

	--Passive instrinsic Bonus Modifier
	modifier_orchid_classic = class({})
	local modifierClass = modifier_orchid_classic
	local modifierName = 'modifier_orchid_classic'
	LinkLuaModifier(modifierName, "items/orchid_classic", LUA_MODIFIER_MOTION_NONE)

	--Active Item Modifier
	modifier_orchid_classic_debuff = class({})
	local modifierBuff = modifier_orchid_classic_debuff
	local buffName = 'modifier_orchid_classic_debuff'
	LinkLuaModifier(buffName, "items/orchid_classic", LUA_MODIFIER_MOTION_NONE)

	modifier_orchid_dispel_check = class({})
	LinkLuaModifier("modifier_orchid_dispel_check", "items/orchid_classic", LUA_MODIFIER_MOTION_NONE)

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


--Casting
function itemClass:OnSpellStart()
	
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self.dur = self:GetSpecialValueFor("silence_duration") * (1 - target:GetStatusResistance())

	-- If the target possesses a ready Linken's Sphere, do nothing
	if target:GetTeam() ~= self:GetCaster():GetTeam() then
		if target:TriggerSpellAbsorb(self) then
			return nil
		end
	end

	-- If the target is magic immune (Lotus Orb/Anti Mage), do nothing
	if target:IsMagicImmune() then
		return nil
	end

	-- Play the cast sound
	target:EmitSound("DOTA_Item.Orchid.Activate")

	-- Apply the Orchid debuff
	target:AddNewModifier(caster, self, buffName , {duration = self.dur})
	target:AddNewModifier(caster, self, "modifier_orchid_dispel_check" , {duration = self.dur - 0.05})
	
end


---------------------------------------------------------
--	Orchid active Check for Dispels
---------------------------------------------------------

function modifier_orchid_dispel_check:IsHidden() return true end
function modifier_orchid_dispel_check:IsDebuff() return true end
function modifier_orchid_dispel_check:IsPurgable() return false end


---------------------------------------------------------
--	Orchid active debuff
---------------------------------------------------------

function modifierBuff:IsHidden() return false end
function modifierBuff:IsDebuff() return true end
function modifierBuff:IsPurgable() return true end

-- Modifier particle
function modifierBuff:GetEffectName()
	return "particles/items2_fx/orchid.vpcf"
end

function modifierBuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

-- Reset damage storage tracking, track debuff parameters to prevent errors if the item is unequipped
function modifierBuff:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	if IsServer() then
		local owner = self:GetParent()
		owner.orchid_damage_storage = owner.orchid_damage_storage or 0
		self.damage_factor = self:GetAbility():GetSpecialValueFor("silence_damage_percent")
	end
end

-- Declare modifier events/properties
function modifierBuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

-- Declare modifier states
function modifierBuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true
	}
end

-- Track damage taken
function modifierBuff:OnTakeDamage(keys)
	if IsServer() then
		local owner = self:GetParent()
		local target = keys.unit

		-- If this unit is the one suffering damage, store it
		if owner == target then
			owner.orchid_damage_storage = owner.orchid_damage_storage + keys.damage
		end
	end
end

-- When the debuff ends, deal damage
function modifierBuff:OnDestroy()
	if IsServer() then

		-- Parameters
		local owner = self:GetParent()
		local ability = self:GetAbility()
		local caster = ability:GetCaster()

		-- If dispelled, the Dispel Check Modifier didn't expire before.
		if owner:HasModifier( "modifier_orchid_dispel_check" ) then 
			-- Clear damage taken variable
			self:GetParent().orchid_damage_storage = nil
			return
		end
		
		--if modifierBuff:GetElapsedTime() == modifierBuff:GetAbility().dur then

			-- If damage was taken, play the effect and damage the owner
			if owner.orchid_damage_storage > 0 then

				-- Calculate and deal damage
				local damage = owner.orchid_damage_storage * self.damage_factor * 0.01
				ApplyDamage({attacker = caster, victim = owner, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

				-- Fire damage particle
				local orchid_end_pfx = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_OVERHEAD_FOLLOW, owner)
				ParticleManager:SetParticleControl(orchid_end_pfx, 0, owner:GetAbsOrigin())
				ParticleManager:SetParticleControl(orchid_end_pfx, 1, Vector(100, 0, 0))
				ParticleManager:ReleaseParticleIndex(orchid_end_pfx)
			end
		--end

		-- Clear damage taken variable
		self:GetParent().orchid_damage_storage = nil
	end
end



-----------------------------------------
--Passive Modifier Stuff starts here

function modifierClass:OnCreated()

	-- common references (Worst Case: Some Nil-values)
	self.bonus_dmg = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" )
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_ms" )
	self.bonus_as = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.bonus_mr = self:GetAbility():GetSpecialValueFor( "bonus_mr" )

	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
	self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_intellect" )

	self.bonus_hp = self:GetAbility():GetSpecialValueFor( "bonus_hp" )
	self.bonus_mana = self:GetAbility():GetSpecialValueFor( "bonus_mana" )

	self.hp_reg = self:GetAbility():GetSpecialValueFor( "hp_reg" )
	self.mana_reg = self:GetAbility():GetSpecialValueFor( "mana_reg" )	

end

			--------------------------------------------------------------------------------
			-- Modifier Effects
			function modifierClass:DeclareFunctions()

				local funcs = {

					--The Usual Modifiers
					MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

					MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

					MODIFIER_PROPERTY_HEALTH_BONUS,
					MODIFIER_PROPERTY_MANA_BONUS,
					MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
					MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,


				}

				return funcs
			end


				--DMG; ARMOR; MS; AS; MR
				function modifierClass:GetModifierPreAttack_BonusDamage()
					return self.bonus_dmg
				end

				function modifierClass:GetModifierPhysicalArmorBonus()
					return self.bonus_armor
				end

				function modifierClass:GetModifierMoveSpeedBonus_Constant()
					return self.bonus_ms
				end

				function modifierClass:GetModifierAttackSpeedBonus_Constant()
					return self.bonus_as
				end

				function modifierClass:GetModifierMagicalResistanceBonus()
					return self.bonus_mr
				end



				--STR; AGI; INT
				function modifierClass:GetModifierBonusStats_Strength()
					return self.bonus_str
				end

				function modifierClass:GetModifierBonusStats_Agility()
					return self.bonus_agi
				end

				function modifierClass:GetModifierBonusStats_Intellect()
					return self.bonus_int
				end



				--HP; MANA; REG
				function modifierClass:GetModifierHealthBonus()
					return self.bonus_hp
				end

				function modifierClass:GetModifierManaBonus()
					return self.bonus_mana
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



