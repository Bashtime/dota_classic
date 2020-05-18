--elf because Credits go to Elfansoer, special thanks also to sanctus animus, ark120202, and others from ModDotaDiscord

am_blink_elf = class({})





modifier_am_blink_phased = class({})
LinkLuaModifier("modifier_am_blink_phased", "heroes/am/am_blink_elf", LUA_MODIFIER_MOTION_NONE)

	-- Modifier Effects
	function modifier_am_blink_phased:DeclareFunctions()

		local funcs = {
			MODIFIER_STATE_NO_UNIT_COLLISION,
				}

		return funcs
	end

	function modifier_am_blink_phased:CheckState()
		local state = {
				[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				}
		return state
	end

	function modifier_am_blink_phased:IsHidden()
		return true
	end

--Showing Blink Range as AoE Circle
function am_blink_elf:GetAOERadius()
	local caster = self:GetCaster()
	local range = self:GetSpecialValueFor("blink_range")
	local bonus_cr_talent = 0
		
	local bonus_cr_item = caster:GetCastRangeBonus()
	if bonus_cr_item == nil then bonus_cr_item = 0 end

	local talent_lvl = caster:GetModifierStackCount("modifier_talent_lvl", caster) 
	if talent_lvl ~= 0 then
		bonus_cr = {80, 150, 240, 350}
		bonus_cr_talent = bonus_cr[talent_lvl] 
	end

	return range + bonus_cr_item + bonus_cr_talent
end

--------------------------------------------------------------------------------
-- Ability Start
function am_blink_elf:OnSpellStart()

	if IsServer() then

	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()

	local range_enhancement = caster:GetCastRangeBonus()

	if range_enhancement == nil then range_enhancement = 0 end

	-- load data
	local max_range = self:GetSpecialValueFor("blink_range")
	

	-- purity of will range bonus 
	local talent_lvl = caster:GetModifierStackCount("modifier_talent_lvl", caster) 

	if talent_lvl ~= 0 then
		-- adapt max max_range
		local rangebonus = self:GetLevelSpecialValueFor("bonus_range", talent_lvl)
		max_range = max_range + rangebonus
	end

	-- Bonus range from Bonus Castrange effects
	max_range = max_range + range_enhancement


	-- determine target position
	local direction = (point - origin)
	if direction:Length2D() > max_range then
		direction = direction:Normalized() * max_range
	end

	-- teleport
	FindClearSpaceForUnit( caster, origin + direction, true )

	--Create illusions on max Talent
	if talent_lvl == 4 then
		CreateIllusions(
			caster, --owner
			caster, --hero to copy
			{
				outgoing_damage = -60,		--outgoing damage
				incoming_damage = 350, 		--incoming damage
				bounty_base = 50,			--bounty base
				bounty_growth = 0,				--bounty growth
				outgoing_damage_structure = -60,		--outgoing damage structure
				outgoing_damage_roshan = -60,
				duration = 2
			},
			1, --#illusions
			caster:GetHullRadius(), --padding??
			false,	--mixing positions?
			true	--find clear space; why not?
			)
		caster:AddNewModifier(caster, self, "modifier_am_blink_phased", { duration = 0.55})
	end

	-- Play effects
	self:PlayEffects( origin, direction )

	-- Disjointing everything
	ProjectileManager:ProjectileDodge(caster)

	end
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
	local blink_cd = self:GetSpecialValueFor("blink_cd")

	if IsServer() then
		-- purity of will cooldown manipulation preparation
		local purity_of_will = caster:FindAbilityByName("antimage_counterspell") 
		local purity_lvl 

		if purity_of_will ~= nil then
			purity_lvl = purity_of_will:GetLevel()

			--Test succesful
			local buff = caster:FindModifierByName("modifier_talent_lvl")
			local charges = buff:GetStackCount()
			if charges < purity_lvl then buff:SetStackCount(purity_lvl) end
		end
	end

	local flat = caster:GetModifierStackCount("modifier_talent_lvl", caster)

	local cooldown = blink_cd

	if flat > 0 then cooldown = blink_cd - ( (flat - 1) * 0.5 ) end
    
    return cooldown

end


-- Purity of Will reducing cast point
function am_blink_elf:GetCastPoint()

	if IsServer() then

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
end


