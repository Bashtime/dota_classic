--elf because Credits go to Elfansoer, special thanks also to sanctus animus, ark120202, and others from ModDotaDiscord

am_blink_elf = class({})

--------------------------------------------------------------------------------
-- Ability Start
function am_blink_elf:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()

	-- load data
	local max_range = self:GetSpecialValueFor("blink_range")

	-- purity of will range bonus 
	local purity_of_will = caster:FindAbilityByName("antimage_counterspell") 
	local purity_lvl 

	if purity_of_will ~= nil then
		purity_lvl = purity_of_will:GetLevel()
	end

	if purity_lvl ~= nil then
		-- adapt max max_range
		local rangebonus = self:GetLevelSpecialValueFor("bonus_range", purity_lvl)
		max_range = max_range + rangebonus
	end


	-- determine target position
	local direction = (point - origin)
	if direction:Length2D() > max_range then
		direction = direction:Normalized() * max_range
	end

	-- teleport
	FindClearSpaceForUnit( caster, origin + direction, true )

	-- Play effects
	self:PlayEffects( origin, direction )
end

--------------------------------------------------------------------------------
function am_blink_elf:PlayEffects( origin, direction )
	-- Get Resources
	local particle_cast_a = "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf"
	local sound_cast_a = "Hero_Antimage.Blink_out"

	local particle_cast_b = "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf"
	local sound_cast_b = "Hero_Antimage.Blink_in"

	-- At original position
	local effect_cast_a = ParticleManager:CreateParticle( particle_cast_a, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_a, 0, origin )
	ParticleManager:SetParticleControlForward( effect_cast_a, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_a )
	EmitSoundOnLocationWithCaster( origin, sound_cast_a, self:GetCaster() )

	-- At original position
	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast_b, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized() )
	ParticleManager:ReleaseParticleIndex( effect_cast_b )
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast_b, self:GetCaster() )
end


-- Purity of Will reducing cooldown
function am_blink_elf:GetCooldown(nLevel)

	local caster = self:GetCaster()
	local lvl = self:GetLevel() - 1

	-- purity of will cooldown manipulation preparation
	local purity_of_will = caster:FindAbilityByName("antimage_counterspell") 
	local purity_lvl 

	if purity_of_will ~= nil then
		purity_lvl = purity_of_will:GetLevel()
	end

	-- calculate new cd
	local new_cd = self.BaseClass.GetCooldown( self, lvl )

	if purity_lvl ~= nil then
		-- adapt cd
		local blink_cd_red = self:GetLevelSpecialValueFor("cd_reduction", purity_lvl)
		local new_cd = self.BaseClass.GetCooldown( self, lvl ) - blink_cd_red

		return new_cd
	else
		return new_cd
	end
end


-- Purity of Will reducing cast point
function am_blink_elf:GetCastPoint()
    local caster = self:GetCaster()
    local cp_reduction = 0
    local purity_of_will = caster:FindAbilityByName("antimage_counterspell") 
    local purity_lvl
    if purity_of_will ~= nil then
        purity_lvl = purity_of_will:GetLevel()
    end
        
    if purity_lvl ~= nil then
        cp_reduction = self:GetLevelSpecialValueFor("cp_reduction", purity_lvl)
    end
    return self.BaseClass.GetCastPoint(self) - cp_reduction
end



