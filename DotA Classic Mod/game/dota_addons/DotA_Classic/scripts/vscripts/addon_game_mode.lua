require('internal/util')
require('gamemode')

function Precache( context )
	LinkLuaModifier("modifier_common_custom_armor", "components/modifiers/common_custom_armor.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_nerf_cancer_regen", "components/modifiers/nerf_cancer_regen.lua", LUA_MODIFIER_MOTION_NONE)

--	PrecacheResource("particle_folder", "particles/econ/items/pudge/pudge_arcana", context)

--	PrecacheModel("models/items/pudge/arcana/pudge_arcana_base.vmdl", context)

--	PrecacheResource("particle", "particles/econ/events/ti8/blink_dagger_ti8_start_lvl2.vpcf", context)

--	PrecacheResource("soundfile", "soundevents/diretide_soundevents.vsndevts", context) -- Hellion
end

function Activate()
	print("Activate()")
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
end
