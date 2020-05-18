item_iron_classic = class({})
LinkLuaModifier( "modifier_iron_passive", "items/iron_classic", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_iron_armor", "items/iron_classic", LUA_MODIFIER_MOTION_NONE )

function item_iron_classic:GetIntrinsicModifierName()
	return "modifier_iron_armor"
end

function item_iron_classic:OnCreated()

	self.cd = self:GetSpecialValueFor("normal_cooldown")

end


function item_iron_classic:GetCastRange(_, hTarget)
	--First parameter is location, I guess it might be relevant for point-target abilities

	--local isTree = target:IsInstance(CDOTA_MapTree) --Checks if the target is a tree
	if hTarget then
		local stillTree = (hTarget:GetClassname() == "dota_temp_tree") --Checks if the target is a temporary tree
		if not stillTree then
			return self:GetSpecialValueFor("cast_range_ward")
		end
	end
	return self:GetSpecialValueFor("quelling_range_tooltip")
end


------------------------------------------------------------------------------
--- Custom Filter

function item_iron_classic:CastFilterResultTarget( hTarget )

	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local name = hTarget:GetUnitName()

	if ( (name == "npc_dota_observer_wards") or (name == "npc_dota_sentry_wards") ) then
		local casterteam = self:GetCaster():GetTeamNumber()
		local wardteam = hTarget:GetTeamNumber()

		if casterteam == wardteam then return UF_FAIL_CUSTOM end
		self.cd = self:GetSpecialValueFor("alternative_cooldown")
		return UF_SUCCESS
	end


	if ( (name == "npc_dota_techies_stasis_trap") or (name == "npc_dota_techies_remote_mine") ) then
		local casterteam = self:GetCaster():GetTeamNumber()
		local wardteam = hTarget:GetTeamNumber()

		if casterteam == wardteam then return UF_FAIL_CUSTOM end
		self.cd = self:GetSpecialValueFor("alternative_cooldown")
		return UF_SUCCESS
	end


	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber() )

	if nResult ~= UF_SUCCESS then
		return nResult
	end

	self.cd = self:GetSpecialValueFor("normal_cooldown")



	return UF_SUCCESS
end

--------------------------------------------------------------------------------

function item_iron_classic:GetCustomCastErrorTarget( hTarget )

	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return "#dota_hud_error_wards"
end


--------------------------------------------------------------------------------
-- CD based on target

function item_iron_classic:GetCooldown( nLevel )
	return self.cd
end



--------------------------------------------------------------------------------
-- Ability Start
function item_iron_classic:OnSpellStart()
	
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	print(target)

	


	self.isTree = target:IsInstance(CDOTA_MapTree) --Checks if the target is a tree
		

	-- load data
	local treekill_cd = self:GetSpecialValueFor("alternative_cooldown")
	local pct = self:GetSpecialValueFor("creep_damage_pct")
	local anc_pct = self:GetSpecialValueFor("anc_pct")
	
	if (not self.isTree) then

		local stillTree = (target:GetClassname() == "dota_temp_tree") --Checks again if it's still a tree, LOL
		
		if stillTree then 					
				--local teamnumber = target:GetTeamNumber()
				--target:CutDown(teamnumber)	--Cannot cutdown these trees, OK

				--Let's try to murder them
				target:Kill()

				self.cd = self:GetSpecialValueFor("alternative_cooldown")
				self:EndCooldown()
				self:StartCooldown(self.cd)
				self.cd = self:GetSpecialValueFor("normal_cooldown")

				-- effects
				local sound_cast = "DOTA_Item.QuellingBlade.Activate"
				EmitSoundOn( sound_cast, target )
		
				return
		end



		-- cancel if linken
		if target:TriggerSpellAbsorb( self ) then return end
	
		--Damage Units
		local current_hp = target:GetHealth()
		local damage = current_hp * pct / 100

		if target:IsAncient() then damage = current_hp * anc_pct / 100  end

		self.damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self, --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}

		ApplyDamage(self.damageTable)

		-- effects
		local sound_cast = "DOTA_Item.IronTalon.Activate"
		EmitSoundOn( sound_cast, target )
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE  , target, damage, nil)

		--Kill obs
		local name = target:GetUnitName()  

		if ( (name == "npc_dota_observer_wards") or (name == "npc_dota_sentry_wards") ) then 
			target:Kill(self, caster)

			self.cd = self:GetSpecialValueFor("alternative_cooldown")
			self:EndCooldown()
			self:StartCooldown(self.cd)
			self.cd = self:GetSpecialValueFor("normal_cooldown")
			

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end


		--Fuck Techies
		local name = target:GetUnitName()  

		if ( (name == "npc_dota_techies_stasis_trap") or (name == "npc_dota_techies_remote_mine") ) then 
			target:Kill(self, caster)


			self.cd = self:GetSpecialValueFor("alternative_cooldown")
			self:EndCooldown()
			self:StartCooldown(self.cd)
			self.cd = self:GetSpecialValueFor("normal_cooldown")
			

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end

	end

	-- CutDown trees
	if self.isTree then
		if target:IsStanding() then 
			local teamnumber = target:GetTeamNumber()
			target:CutDownRegrowAfter(TREE_REGROW_TIME, teamnumber)

			self.cd = self:GetSpecialValueFor("alternative_cooldown")
			self:EndCooldown()
			self:StartCooldown(self.cd)
			self.cd = self:GetSpecialValueFor("normal_cooldown")

			-- effects
			local sound_cast = "DOTA_Item.QuellingBlade.Activate"
			EmitSoundOn( sound_cast, target )
		
			return
		end
	end

	return
end



--------------------------------------------------------------
--------------------------------------------------------------
-- Iron Talon stats bonuses and quell passive

modifier_iron_passive = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_iron_passive:IsHidden()
	return true
end

function modifier_iron_passive:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_iron_passive:OnCreated( kv )

	-- references
	self.dmg = self:GetAbility():GetSpecialValueFor( "damage_bonus" ) -- special value
	self.dmg_range = self:GetAbility():GetSpecialValueFor( "damage_bonus_ranged" ) -- special value
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" ) -- special value

end

function modifier_iron_passive:OnRefresh( kv )

	-- references
	self.dmg = self:GetAbility():GetSpecialValueFor( "damage_bonus" ) -- special value
	self.dmg_range = self:GetAbility():GetSpecialValueFor( "damage_bonus_ranged" ) -- special value
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" ) -- special value

end

function modifier_iron_passive:OnDestroy( kv )

end


--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_iron_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_iron_passive:GetModifierProcAttack_BonusDamage_Physical( params )

	if IsServer() then
		
		local attacker = self:GetParent()

		local target = params.target
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_NONE,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then

			if attacker:IsIllusion() then
				return 0 
			end

			if attacker:IsRangedAttacker() then
				return self.dmg_range			
			end

			return self.dmg
		end

		return 0
	end
end



-- Armor Bonus

modifier_iron_armor = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_iron_armor:IsHidden()
	return true
end

function modifier_iron_armor:IsPurgable()
	return false
end

function modifier_iron_armor:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_iron_armor:OnCreated( kv )

	-- references
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" ) -- special value
	local caster = self:GetParent()
	
	if IsServer() then caster:AddNewModifier(caster, self:GetAbility(), "modifier_iron_passive", { duration = -1}) end
end

function modifier_iron_armor:OnRefresh( kv )

	-- references
	self.bonus_armor = self:GetAbility():GetSpecialValueFor( "bonus_armor" ) -- special value

	local caster = self:GetParent()
	if IsServer() then caster:AddNewModifier(caster, self:GetAbility(), "modifier_iron_passive", { duration = -1}) end

end

function modifier_iron_armor:OnDestroy( kv )
	local caster = self:GetParent()
	if IsServer() then caster:RemoveModifierByName("modifier_iron_passive") end
end

function modifier_iron_armor:OnRemoved()
	local caster = self:GetParent()
	if IsServer() then caster:RemoveModifierByName("modifier_iron_passive") end
end



--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_iron_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_iron_armor:GetModifierPhysicalArmorBonus(params)
	return self.bonus_armor;
end






