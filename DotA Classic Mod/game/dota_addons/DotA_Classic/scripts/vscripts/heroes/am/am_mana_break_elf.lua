-- Test
-- Bashtime, 28.04.2020


am_mana_break_elf = class({})
local abilityClass = am_mana_break_elf
local abilityName = 'am_mana_break_elf'

modifier_am_mana_break = class({})
local modifierClass = modifier_am_mana_break
local modifierName = 'modifier_am_mana_break'
LinkLuaModifier( modifierName, "heroes/am/am_mana_break_elf", LUA_MODIFIER_MOTION_NONE )



function abilityClass:GetIntrinsicModifierName()
	return modifierName
end


--------------------------------------------------------------------------------
-- Passive Modifier

function modifierClass:IsHidden()
	return true
end

function modifierClass:IsPurgable()
	return false
end


	------------------------------------------
	-- Initializations
	function modifierClass:OnCreated( kv )
		-- references
		self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" ) -- special value
		self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
		self.illu_efficency = self:GetAbility():GetSpecialValueFor( "illusion_percentage" ) / 100 -- special value
		self.mana_burn = 0
	end

	--------------------------------------------
	-- Modifier Effects
	function modifierClass:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_EVENT_ON_ATTACK_START,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
		return funcs
	end

	function modifierClass:OnAttackStart( params )

		local attacker = self:GetParent()

		if ((not attacker:PassivesDisabled()) and params.attacker == attacker) then

			self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" )	

			-- purity of will percentage mana burn bonus 
			local talent_lvl = attacker:GetModifierStackCount("modifier_talent_lvl", attacker) 






			local target = params.target
			local result = UnitFilter(
				target,	-- Target Filter
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
				DOTA_UNIT_TARGET_FLAG_MANA_ONLY,	-- Unit Flag
				self:GetParent():GetTeamNumber()	-- Team reference
				)
	
			if result == UF_SUCCESS then

				self.mana_burn =  math.min( target:GetMana(), self.mana_break )

				if talent_lvl ~= 0 then	
					local purity_of_will = attacker:FindAbilityByName("antimage_counterspell") 
					local purity_lvl = talent_lvl - 1
				
					-- add percentage mana burn
					local percbonus = purity_of_will:GetLevelSpecialValueFor("mana_burn_perc", purity_lvl)

					local new_mana_burn = self.mana_break + (percbonus * target:GetMaxMana() / 100) 
					self.mana_burn = math.min(target:GetMana(), new_mana_burn )
				end

				if attacker:IsIllusion() then
					local purity_of_will = attacker:FindAbilityByName("antimage_counterspell") 
					local purity_lvl 

					if purity_of_will ~= nil then
						purity_lvl = purity_of_will:GetLevel() - 1
					end
		
					if purity_lvl ~= nil then
						-- add percentage mana burn
						local percbonus = purity_of_will:GetLevelSpecialValueFor("mana_burn_perc", purity_lvl) / 2
						local new_mana_burn = self.mana_break + (percbonus * target:GetMaxMana() / 100) 
						self.mana_burn = math.min(target:GetMana(), new_mana_burn )
					end
				end

				return
			else
				self.mana_burn = 0
			end
		end
	end


	function modifierClass:GetModifierPreAttack_BonusDamage()
		return self.mana_burn * self.mana_damage_pct
	end

	function modifierClass:OnAttackLanded( params )
		local attacker = self:GetParent()
		local target = params.target

		if params.attacker == attacker then 
			local result = UnitFilter(
				target,	-- Target Filter
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
				DOTA_UNIT_TARGET_FLAG_MANA_ONLY,	-- Unit Flag
				self:GetParent():GetTeamNumber()	-- Team reference
				)
			if result == UF_SUCCESS then
				target:ReduceMana( self.mana_burn )

				self:PlayEffects( target )

				if attacker:IsIllusion() then
					local illudamage = {
                		victim = target,
                		attacker = attacker,
                		damage = self.mana_burn * self.illu_efficency * self.mana_damage_pct,
                		damage_type = DAMAGE_TYPE_PHYSICAL,
                		ability = self:GetAbility(),
                		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            			}
            		ApplyDamage( illudamage )	
            	end
            end
        end
	end

	function modifierClass:PlayEffects( target )
		-- Get Resources
		local particle_cast = "particles/generic_gameplay/generic_manaburn.vpcf"
		local sound_cast = "Hero_Antimage.ManaBreak"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		EmitSoundOn( sound_cast, target )
	end









--[[ Editors:
--     AtroCty,  04.07.2017
--	   Bashtime, 28.01.2020
--	   Credits: Elfansoer, Cykada, EmberCookies, Silaah, Perry, the whole dota2MODcommunity

am_mana_break_elf = class({})
LinkLuaModifier( "modifier_am_mana_break_elf", "heroes/am/am_mana_break_elf", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function am_mana_break_elf:GetIntrinsicModifierName()
	return "modifier_am_mana_break_elf"
end








modifier_am_mana_break_elf = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_am_mana_break_elf:IsHidden()
	return true
end

function modifier_am_mana_break_elf:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_am_mana_break_elf:OnCreated( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" ) -- special value
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
	self.illu_efficency = self:GetAbility():GetSpecialValueFor( "illusion_percentage" ) / 100 -- special value
end

function modifier_am_mana_break_elf:OnRefresh( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" ) -- special value
	self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
	self.illu_efficency = self:GetAbility():GetSpecialValueFor( "illusion_percentage" ) / 100 -- special value
end

function modifier_am_mana_break_elf:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_am_mana_break_elf:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_am_mana_break_elf:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		
		local attacker = self:GetParent()

		-- purity of will range bonus 
		local purity_of_will = attacker:FindAbilityByName("antimage_counterspell") 
		local purity_lvl 

		if purity_of_will ~= nil then
			purity_lvl = purity_of_will:GetLevel() - 1
		end


		local target = params.target
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MANA_ONLY,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then
			local mana_burn =  math.min( target:GetMana(), self.mana_break )

			if purity_lvl ~= nil then
				-- add percentage mana burn
				local percbonus = purity_of_will:GetLevelSpecialValueFor("mana_burn_perc", purity_lvl)

				if attacker:IsIllusion() then
					percbonus = percbonus / 2
				end

				local new_mana_burn = self.mana_break + (percbonus * target:GetMaxMana() / 100) 
				mana_burn = math.min(target:GetMana(), new_mana_burn )
			end

			target:ReduceMana( mana_burn )

			self:PlayEffects( target )

			if attacker:IsIllusion() then
				local illudamage = {
                	victim = target,
                	attacker = attacker,
                	damage = mana_burn * self.illu_efficency * self.mana_damage_pct,
                	damage_type = DAMAGE_TYPE_PHYSICAL,
                	ability = self:GetAbility(),
                	damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
            	}
            	ApplyDamage( illudamage )	
            end

			return mana_burn * self.mana_damage_pct
		end

	end
end


function modifier_am_mana_break_elf:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/generic_gameplay/generic_manaburn.vpcf"
	local sound_cast = "Hero_Antimage.ManaBreak"

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		-- Create Sound
		EmitSoundOn( sound_cast, target )
end]]