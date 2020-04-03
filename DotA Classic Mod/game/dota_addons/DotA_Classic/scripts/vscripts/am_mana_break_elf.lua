-- Editors:
--     AtroCty,  04.07.2017
--	   Bashtime, 28.01.2020
--	   Credits: Elfansoer, Cykada, EmberCookies, Silaah, Perry, the whole dota2MODcommunity

am_mana_break_elf = class({})
LinkLuaModifier( "modifier_am_mana_break_elf", "modifier_am_mana_break_elf", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function am_mana_break_elf:GetIntrinsicModifierName()
	return "modifier_am_mana_break_elf"
end

