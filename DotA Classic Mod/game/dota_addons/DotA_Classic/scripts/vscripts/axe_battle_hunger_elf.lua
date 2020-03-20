axe_battle_hunger_elf = class({})
LinkLuaModifier( "modifier_axe_battle_hunger_elf", "modifier_axe_battle_hunger_elf", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_battle_hunger_elf_debuff", "modifier_axe_battle_hunger_elf_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function axe_battle_hunger_elf:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_axe_battle_hunger_elf_debuff", -- modifier name
		{ duration = duration } -- kv
	)

	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_axe_battle_hunger_elf", -- modifier name
		{ duration = duration } -- kv
	)

	-- effects
	local sound_cast = "Hero_Axe.Battle_Hunger"
	EmitSoundOn( sound_cast, target )
end
