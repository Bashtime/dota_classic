-- By Bashtime, 08.05.2020

modifier_aura_cosmetics = class({})

local genericModifierClass = modifier_aura_cosmetics





function genericModifierClass:IsPurgable()
    return false
end

function genericModifierClass:IsHidden()
    return true
end

function genericModifierClass:RemoveOnDeath()
    return false
end

function genericModifierClass:IsPermanent()
    return true
end

function genericModifierClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end


function genericModifierClass:OnCreated()

	--Booleans checking if aura item is equipped
	self.bAc = false
	self.bShiva = false
	self.bDominator = false
	self.bVessel = false
	self.bHeaddress = false
	self.bPipe = false

	self:StartIntervalThink(0.2)
end


function genericModifierClass:OnIntervalThink()

	local caster = self:GetParent()

	--Assault effect
	if caster:HasModifier("modifier_item_assault") and not self.bAc then
		local particle_cast = "particles/aura_assault_classic.vpcf"
		self.ac_effect = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		self.bAc = true
	end		

	--Assault removal
	if not caster:HasModifier("modifier_item_assault") and self.bAc then
		self.bAc = false
		ParticleManager:DestroyParticle(self.ac_effect, false)
		ParticleManager:ReleaseParticleIndex( self.ac_effect )
	end		


	--Shiva effect
	if caster:HasModifier("modifier_item_shivas_guard") and not self.bShiva then
		local particle_cast = "particles/items_fx/aura_shivas.vpcf"
		self.shiva_effect = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		self.bShiva = true
	end		

	--Shiva removal
	if not caster:HasModifier("modifier_item_shivas_guard") and self.bShiva then
		self.bShiva = false
		ParticleManager:DestroyParticle(self.shiva_effect, false)
		ParticleManager:ReleaseParticleIndex( self.shiva_effect )
	end		


	--Dominator effect
	if caster:HasModifier("modifier_item_helm_of_the_dominator") and not self.bDominator then
		local particle_cast = "particles/dominator_aura.vpcf"
		self.domi_effect = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		self.bDominator = true
	end		

	--Dominator removal
	if not caster:HasModifier("modifier_item_helm_of_the_dominator") and self.bDominator then
		self.bDominator = false
		ParticleManager:DestroyParticle(self.domi_effect, false)
		ParticleManager:ReleaseParticleIndex( self.domi_effect )
	end		


	--Vessel effect
	if caster:HasModifier("modifier_item_spirit_vessel") and not self.bVessel then
		--local particle_cast = "particles/vessel_aura.vpcf"
		local particle_cast = "particles/econ/events/ti4/radiant_fountain_regen_ti4.vpcf"
		self.vessel_effect = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		self.bVessel = true
	end		

	--Vessel removal
	if not caster:HasModifier("modifier_item_spirit_vessel") and self.bVessel then
		self.bVessel = false
		ParticleManager:DestroyParticle(self.vessel_effect, false)
		ParticleManager:ReleaseParticleIndex( self.vessel_effect )
	end	


	--Headdress effect
	if ( caster:HasModifier("modifier_item_headdress") or caster:HasModifier("modifier_mekansm_classic") or caster:HasModifier("modifier_greaves") ) 
	  and not self.bHeaddress then
		--local particle_cast = "particles/vessel_aura.vpcf"
		local particle_cast = "particles/headdress.vpcf"
		self.headdress_effect = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
		self.bHeaddress = true
	end		

	--Headdress removal
	if not ( caster:HasModifier("modifier_item_headdress") or caster:HasModifier("modifier_mekansm_classic") or caster:HasModifier("modifier_greaves") ) 
	  and self.bHeaddress then
		self.bHeaddress = false
		ParticleManager:DestroyParticle(self.headdress_effect, false)
		ParticleManager:ReleaseParticleIndex( self.headdress_effect )
	end	


	--Pipe effect
	if caster:HasModifier("modifier_item_pipe") and not self.bPipe then
		--local particle_cast = "particles/vessel_aura.vpcf"
		if IsClient() then
			local particle_cast = "particles/aura_pipe.vpcf"
			self.pipe_effect = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
			self.bPipe = true
		end
	end		

	--Pipe removal
	if not caster:HasModifier("modifier_item_pipe") and self.bPipe then
		if IsClient() then 
			self.bPipe = false
			ParticleManager:DestroyParticle(self.pipe_effect, false)
			ParticleManager:ReleaseParticleIndex( self.pipe_effect )
		end
	end	

end



