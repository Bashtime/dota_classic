


-------------------------------------------
--       BLINK
-------------------------------------------

am_blink = am_blink or class({})

function am_blink:GetAbilityTextureName()
	return "antimage_blink"
end

function am_blink:IsNetherWardStealable() return false end

-- Purity of Will reducing cast point
function am_blink:OnAbilityPhaseStart()
	if IsServer() then
		local caster = self:GetCaster()
		local has_purity = caster:HasAbility("am_purity")

		if ( has_purity ) and (not self.cast_point) then
			self.cast_point = true
			local cast_point = self:GetCastPoint()
			local cp_red = caster:FindAbilityByName("am_purity"):GetSpecialValueFor("blink_castpoint_reduction")
			cast_point = cast_point - cp_red
			self:SetOverrideCastPoint(cast_point)
		end
		return true
	end
end


-- Purity of Will modifying CD and CastRange
function am_blink:GetCooldown( nLevel )
	
	-- Check Purity of Will Level to reduce CD
	local has_purity = self:GetCaster():HasAbility("am_purity")

	if has_purity then
		local blink_cd_red = self:GetCaster():FindAbilityByName("am_purity"):GetSpecialValueFor("blink_cooldown_reduction") 
		return self.BaseClass.GetCooldown( self, nLevel ) - blink_cd_red
	else
		return self.BaseClass.GetCooldown( self, nLevel )
	end
end

function am_blink:OnSpellStart()
	if IsServer() then

		-- Declare variables
		local caster = self:GetCaster()
		local caster_position = caster:GetAbsOrigin()
		local target_point = self:GetCursorPosition()
		local distance = target_point - caster_position
		local cast_range = caster:GetAbility():GetSpecialValueFor("blink_range")

		-- Check and apply Purity Range Bonus, Rework!
		if caster:HasAbility("am_purity") then
			local cast_range_bonus = caster:FindAbilityByName("am_purity"):GetSpecialValueFor("blink_range_adjust")
			cast_range = cast_range + cast_range_bonus
		end

		-- Range-check
		if distance:Length2D() > cast_range then
			target_point = caster_position + (target_point - caster_position):Normalized() * cast_range
		end

		-- Disjointing everything
		ProjectileManager:ProjectileDodge(caster)

		-- Blink particles/sound on starting point
		local blink_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:ReleaseParticleIndex(blink_pfx)
		caster:EmitSound("Hero_Antimage.Blink_out")

		-- Adding an extreme small timer for the particles, else they will only appear at the dest
		Timers:CreateTimer(0.01, function()
			-- Move hero
			caster:SetAbsOrigin(target_point)
			FindClearSpaceForUnit(caster, target_point, true)

			-- Create Particle/sound on end-point
			local blink_end_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:ReleaseParticleIndex(blink_end_pfx)
			caster:EmitSound("Hero_Antimage.Blink_in")
		end)
	end
end

function am_blink:IsHiddenWhenStolen()
	return false
end