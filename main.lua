
Snitch_CC = LibStub('AceAddon-3.0'):NewAddon('Snitch_CC', 'AceEvent-3.0', 'AceTimer-3.0')

Snitch_CC.auras = {}

Snitch_CC.trackableAuras = {
	[118]    = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph
	[12824]  = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph (Rank 2)
	[12825]  = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph (Rank 3)
	[12826]  = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph (Rank 4)
	[61305]  = 'Interface\\Icons\\Achievement_Halloween_Cat_01',        -- Polymorph (Black Cat)
	[277792] = 'Interface\\Icons\\Inv_Bee_Default',                     -- Polymorph (Bumblebee)
	[277787] = 'Interface\\Icons\\Inv_Pet_Direhorn',                    -- Polymorph (Direhorn)
	[321395] = 'Interface\\Icons\\Inv_RatMount',                        -- Polymorph (Mawrat)
	[161354] = 'Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey',    -- Polymorph (Monkey)
	[161372] = 'Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey',    -- Polymorph (Monkey)
	[161372] = 'Interface\\Icons\\Inv_Pet_Peacock_Gold',                -- Polymorph (Peacock)
	[161355] = 'Interface\\Icons\\Inv_Misc_PenguinPet',                 -- Polymorph (Penguin)
	[28272]  = 'Interface\\Icons\\Spell_Magic_PolymorphPig',            -- Polymorph (Pig)
	[161353] = 'Interface\\Icons\\Inv_Pet_BabyBlizzardBear',            -- Polymorph (Polar Bear Cub)
	[126819] = 'Interface\\Icons\\Inv_Pet_Porcupine',                   -- Polymorph (Porcupine)
	[61721]  = 'Interface\\Icons\\Spell_Magic_PolymorphRabbit',         -- Polymorph (Rabbit)
	[61025]  = 'Interface\\Icons\\Spell_Nature_GuardianWard',           -- Polymorph (Serpent)
	[61780]  = 'Interface\\Icons\\Achievement_WorldEvent_Thanksgiving', -- Polymorph (Turkey)
	[28271]  = 'Interface\\Icons\\Ability_Hunter_Pet_Turtle',           -- Polymorph (Turtle)
--	[219393] = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- [Crittermorph] Polymorph
--	[219407] = 'Interface\\Icons\\Achievement_Halloween_Cat_01',        -- [Crittermorph] Polymorph (Black Cat)
--	[277793] = 'Interface\\Icons\\Inv_Bee_Default',                     -- [Crittermorph] Polymorph (Bumblebee)
--	[277788] = 'Interface\\Icons\\Inv_Pet_Direhorn',                    -- [Crittermorph] Polymorph (Direhorn)
--	[219406] = 'Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey',    -- [Crittermorph] Polymorph (Monkey)
--	[219403] = 'Interface\\Icons\\Spell_Magic_PolymorphPig',            -- [Crittermorph] Polymorph (Pig)
--	[219401] = 'Interface\\Icons\\Inv_Pet_Porcupine',                   -- [Crittermorph] Polymorph (Porcupine)
--	[219398] = 'Interface\\Icons\\Ability_Hunter_Pet_Turtle',           -- [Crittermorph] Polymorph (Turtle)

	[51514]  = 'Interface\\Icons\\Spell_Shaman_Hex',                 -- Hex
	[76780]  = 'Interface\\Icons\\Spell_Shaman_BindElemental',       -- Bind Elemental
	[9484]   = 'Interface\\Icons\\Spell_Nature_Slow',                -- Shackle Undead
	[8122]   = 'Interface\\Icons\\Spell_Shadow_PsychicScream',       -- Psychic Scream
	[605]    = 'Interface\\Icons\\Spell_Shadow_ShadowWordDominate',  -- Mind Control
	[2637]   = 'Interface\\Icons\\Spell_Nature_Sleep',               -- Hibernate
	[6770]   = 'Interface\\Icons\\Ability_Sap',                      -- Sap
	[3355]   = 'Interface\\Icons\\Spell_Frost_ChainsOfIce',          -- Freezing Trap
	[19386]  = 'Interface\\Icons\\Inv_Spear_02',                     -- Wyvern Sting
	[1513]   = 'Interface\\Icons\\Ability_Druid_Cower',              -- Scare Beast
	[710]    = 'Interface\\Icons\\Spell_Shadow_Cripple',             -- Banish
	[5782]   = 'Interface\\Icons\\Spell_Shadow_Possession',          -- Fear
	[6358]   = 'Interface\\Icons\\Spell_Shadow_MindSteal',           -- Seduction
	[20066]  = 'Interface\\Icons\\Spell_Holy_PrayerOfHealing',       -- Repentance
	[10326]  = 'Interface\\Icons\\Spell_Holy_TurnUndead',            -- Turn Evil
	[1098]   = 'Interface\\Icons\\Spell_Shadow_EnslaveDemon',        -- Enslave Demon
	[339]    = 'Interface\\Icons\\Spell_Nature_StrangleVines',       -- Entangling Roots
	[115078] = 'Interface\\Icons\\Ability_Monk_Paralysis',           -- Paralysis
	[217832] = 'Interface\\Icons\\Ability_DemonHunter_Imprison',     -- Imprison
}

function Snitch_CC:OnEnable()
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end


function Snitch_CC:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()
	if (eventType == 'SPELL_AURA_APPLIED' or eventType == 'SPELL_AURA_REFRESH') and self.trackableAuras[spellId] then
		if (UnitInRaid(sourceName)) or sourceName == UnitName('player') then
			local aura = {
				auraGUID = spellId .. destGUID, -- a unique identifier for this aura occurance
				sourceGUID = sourceGUID,
				sourceName = sourceName,
				destGUID = destGUID,
				destName = destName,
				spellId = spellId,
				spellName = spellName,
				texture = self.trackableAuras[spellId],
				timestamp = GetTime(),
			}
			self:AuraApplied(aura)
		end
	end
	-- watch for damage on our polymorph and record whoever breaks
	local damageEventTypes = {
		['SWING_DAMAGE'] = true,
		['RANGE_DAMAGE'] = true,
		['SPELL_DAMAGE'] = true,
		['SPELL_PERIODIC_DAMAGE'] = true,
		['SPELL_BUILDING_DAMAGE'] = true,
		['ENVIRONMENTAL_DAMAGE'] = true,
		['DAMAGE_SPLIT'] = true,
		['DAMAGE_SHIELD'] = true,
	}
	if self.watchForBreakers and self.watchForBreakers > 0 and damageEventTypes[eventType] then
		self:AuraBroken(destGUID, sourceName, eventType == 'SWING_DAMAGE' and 'Melee' or spellName)
	end
	-- watch for our polymorph to dissipate
	if eventType == 'SPELL_AURA_REMOVED' then
		if self.trackableAuras[spellId] then
			self:AuraRemoved(destGUID, spellId)
		end
	end
end

function Snitch_CC:AuraApplied(aura)
	--print('Snitch_CC:AuraApplied', aura.destGUID, aura.spellId)
	local index = self:UnitHasAura(aura.destGUID, aura.spellId)
	if index then
		table.remove(self.auras, index)
	end
	table.insert(self.auras, aura)
end

function Snitch_CC:AuraRemoved(destGUID, spellId)
	--print('Snitch_CC:AuraRemoved', destGUID, spellId)
	local index, aura = self:UnitHasAura(destGUID, spellId)
	if index then
		-- we only need to watch damage in the combat logs during the brief moment the timer is up
		-- the flag must be a counter as it's possible that multiple timers are up at once
		self.watchForBreakers = self.watchForBreakers and self.watchForBreakers + 1 or 1
		-- delay removal of the aura so we can check who the breaker was
		self:ScheduleTimer(function()
			Snitch_CC.watchForBreakers = Snitch_CC.watchForBreakers - 1
			table.remove(Snitch_CC.auras, index)
			Snitch_CC:CC_REMOVED(aura)
		end, 0.1)
	end
end

function Snitch_CC:AuraBroken(destGUID, breakerName, breakerReason)
	--print('Snitch_CC:AuraBroken', destGUID, breakerName, breakerReason)
	for index, aura in ipairs(self.auras) do
		if aura.destGUID == destGUID then
			self.auras[index].breakerName = breakerName
			self.auras[index].breakerReason = breakerReason
		end
	end
end

function Snitch_CC:UnitHasAura(destGUID, spellId)
	for index, aura in ipairs(self.auras) do
		if aura.destGUID == destGUID and aura.spellId == spellId then
			return index, aura
		end
	end
end

function Snitch_CC:CC_REMOVED(aura)
	local message = aura.spellName .. ' has broken'
	if aura.breakerName then
		message = string.format('%s broken by %s (%s)', aura.spellName, aura.breakerName, aura.breakerReason)
	end
	self:ShowRaidWarning(message)
	print(string.format('%s %s', date("%X"), message))
end

function Snitch_CC:ShowRaidWarning(message)
	RaidBossEmoteFrame.slot1:Hide()
	RaidNotice_AddMessage(RaidBossEmoteFrame, message, color or ChatTypeInfo["RAID_BOSS_EMOTE"])
end