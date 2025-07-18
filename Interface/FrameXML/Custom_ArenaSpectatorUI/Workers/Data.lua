ezSpectator_DataWorker = {}
ezSpectator_DataWorker.__index = ezSpectator_DataWorker

local CROWD_CONTROL_PRIORITY = {
	ROOT = 1,
	SILENCE = 2,
	CROWD_CONTROL = 3,
	STUN = 4,
	IMMUNITY = 5,
}

function ezSpectator_DataWorker:Create()
    local self = {}
    setmetatable(self, ezSpectator_DataWorker)

    self.TournamentStages = {
        ['G'] = ARENA_SPECTATOR_GROUP_STAGE,
        ['U'] = ARENA_SPECTATOR_TOP_MESH,
        ['L'] = ARENA_SPECTATOR_BOTTOM_MESH,
        ['T'] = ARENA_SPECTATOR_3_PLACE_MATCH,
        ['F'] = ARENA_SPECTATOR_FINAL_MATCH
    }

    self.ClassTextEng = {
        'WARRIOR',
        'PALADIN',
        'HUNTER',
        'ROGUE',
        'PRIEST',
        'DEATHKNIGHT',
        'SHAMAN',
        'MAGE',
        'WARLOCK',
        '',
        'DRUID',
    }

    self.ClassIconOffset = {
        {0, 0.25, 0, 0.25},
        {0, 0.25, 0.5, 0.75},
        {0, 0.25, 0.25, 0.5},
        {0.49609375, 0.7421875, 0, 0.25},
        {0.49609375, 0.7421875, 0.25, 0.5},
        {0.25, 0.49609375, 0.5, 0.75},
        {0.25, 0.49609375, 0.25, 0.5},
        {0.25, 0.49609375, 0, 0.25},
        {0.7421875, 0.98828125, 0.25, 0.5},
        {},
        {0.7421875, 0.98828125, 0, 0.25}
    }

    self.Trinkets = {
        [65547] = 120,
        [42292] = 120,
        [59752] = 120,
        [7744] = 45
    }

    self.DebuffList = {
        [0] = 'none',
        [1] = 'magic',
        [2] = 'curse',
        [3] = 'disease',
        [4] = 'poison'
    }

    self.DebuffColor = {
        ['none'] = {r = 0.80, g = 0, b = 0},
        ['magic'] = {r = 0.20, g = 0.60, b = 1.00},
        ['curse'] = {r = 0.60, g = 0.00, b = 1.00},
        ['disease'] = {r = 0.60, g = 0.40, b = 0},
        ['poison'] = {r = 0.00, g = 0.60, b = 0}
    }

    self.CastInfo = {
		[Enum.ArenaSpectator.CastType.Range] = {r = 1, g = 1, b = 0, Text = CANCELED, IsProgressMode = false},
		[Enum.ArenaSpectator.CastType.LOS] = {r = 1, g = 1, b = 0, Text = CANCELED, IsProgressMode = false},
		[Enum.ArenaSpectator.CastType.Success] = {r = 0, g = 1, b = 0, Text = SUCCESSFULLY, IsProgressMode = false},
		[Enum.ArenaSpectator.CastType.Cancel] = {r = 1, g = 1, b = 0, Text = CANCELED, IsProgressMode = false},
		[Enum.ArenaSpectator.CastType.Interrupt] = {r = 1, g = 0, b = 0, Text = INTERRUPTED, IsProgressMode = false},
		[Enum.ArenaSpectator.CastType.Casting] = {r = 0, g = 1, b = 1, Text = nil, IsProgressMode = true}
    }

    self.PowerInfo = {
        -- mana
        [0] = {r = 0, g = 0.5, b = 1, AnimationStartSpeed = 0, AnimationProgress = 10},
        -- rage
        [1] = {r = 1, g = 0, b = 0, AnimationStartSpeed = 5, AnimationProgress = 1},
        -- energy
        [3] = {r = 1, g = 1, b = 0, AnimationStartSpeed = 5, AnimationProgress = 1},
        -- runic power
        [6] = {r = 0, g = 1, b = 1, AnimationStartSpeed = 5, AnimationProgress = 1}
    }

	self.CrowdControlPriority = {
		-- Death Knight
		[47481] = CROWD_CONTROL_PRIORITY.STUN,			-- Gnaw (Ghoul)
		[51209] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Hungering Cold
		[47476] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Strangulate
		-- Druid
		[8983]	= CROWD_CONTROL_PRIORITY.STUN,			-- Bash (also Shaman Spirit Wolf ability)
		[33786] = CROWD_CONTROL_PRIORITY.STUN,			-- Cyclone
		[18658] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Hibernate (works against Druids in most forms and Shamans using Ghost Wolf)
		[49802] = CROWD_CONTROL_PRIORITY.STUN,			-- Maim
		[49803] = CROWD_CONTROL_PRIORITY.STUN,			-- Pounce
		[53308] = CROWD_CONTROL_PRIORITY.ROOT,			-- Entangling Roots
		[53313] = CROWD_CONTROL_PRIORITY.ROOT,			-- Entangling Roots (Nature's Grasp)
		[45334] = CROWD_CONTROL_PRIORITY.ROOT,			-- Feral Charge Effect (immobilize with interrupt [spell lockout, not silence])
		-- Hunter
		[60210] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Freezing Arrow Effect
		[14309] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Freezing Trap Effect
		[24394] = CROWD_CONTROL_PRIORITY.STUN,			-- Intimidation
		[14327] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Scare Beast (works against Druids in most forms and Shamans using Ghost Wolf)
		[19503] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Scatter Shot
		[49012] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Wyvern Sting
		[34490] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Silencing Shot
		[53359] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Chimera Shot - Scorpid
		[19306] = CROWD_CONTROL_PRIORITY.ROOT,			-- Counterattack
		[64804] = CROWD_CONTROL_PRIORITY.ROOT,			-- Entrapment
		-- Hunter Pets
		[53568] = CROWD_CONTROL_PRIORITY.STUN,			-- Sonic Blast (Bat)
		[53543] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Snatch (Bird of Prey)
		[53548] = CROWD_CONTROL_PRIORITY.ROOT,			-- Pin (Crab)
		[53562] = CROWD_CONTROL_PRIORITY.STUN,			-- Ravage (Ravager)
		[55509] = CROWD_CONTROL_PRIORITY.ROOT,			-- Venom Web Spray (Silithid)
		[4167]	= CROWD_CONTROL_PRIORITY.ROOT,			-- Web (Spider)
		-- Mage
		[44572] = CROWD_CONTROL_PRIORITY.STUN,			-- Deep Freeze
		[31661] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Dragon's Breath
		[12355] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Impact
		[12826] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Polymorph
		[55021] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Silenced - Improved Counterspell
		[64346] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Fiery Payback
		[33395] = CROWD_CONTROL_PRIORITY.ROOT,			-- Freeze (Water Elemental)
		[42917] = CROWD_CONTROL_PRIORITY.ROOT,			-- Frost Nova
		[12494] = CROWD_CONTROL_PRIORITY.ROOT,			-- Frostbite
		[55080] = CROWD_CONTROL_PRIORITY.ROOT,			-- Shattered Barrier
		-- Paladin
		[10308] = CROWD_CONTROL_PRIORITY.STUN,			-- Hammer of Justice
		[48817] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Holy Wrath (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
		[20066] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Repentance
		[20170] = CROWD_CONTROL_PRIORITY.STUN,			-- Stun (Seal of Justice proc)
		[10326] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Turn Evil (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
		[63529] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Shield of the Templar
		-- Priest
		[605]	= CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Mind Control
		[64044] = CROWD_CONTROL_PRIORITY.STUN,			-- Psychic Horror
		[10890] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Psychic Scream
		[10955] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Shackle Undead (works against Death Knights using Lichborne)
		[15487] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Silence
		[64058] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Psychic Horror (duplicate debuff names not allowed atm, need to figure out how to support this later)
		-- Rogue
		[2094]	= CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Blind
		[1833]	= CROWD_CONTROL_PRIORITY.STUN,			-- Cheap Shot
		[1776]	= CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Gouge
		[8643]	= CROWD_CONTROL_PRIORITY.STUN,			-- Kidney Shot
		[51724] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Sap
		[1330]	= CROWD_CONTROL_PRIORITY.SILENCE,		-- Garrote - Silence
		[18425] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Silenced - Improved Kick
		[51722] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Dismantle
		-- Shaman
		[39796] = CROWD_CONTROL_PRIORITY.STUN,			-- Stoneclaw Stun
		[51514] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Hex (although effectively a silence+disarm effect, it is conventionally thought of as a AURA_TYPE.CROWD_CONTROL, plus you can trinket out of it)
		[64695] = CROWD_CONTROL_PRIORITY.ROOT,			-- Earthgrab (Storm, Earth and Fire)
		[63685] = CROWD_CONTROL_PRIORITY.ROOT,			-- Freeze (Frozen Power)
		-- Warlock
		[18647] = CROWD_CONTROL_PRIORITY.STUN,			-- Banish (works against Warlocks using Metamorphasis and Druids using Tree Form)
		[47860] = CROWD_CONTROL_PRIORITY.STUN,			-- Death Coil
		[6215]	= CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Fear
		[17928] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Howl of Terror
		[6358]	= CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Seduction (Succubus)
		[47847] = CROWD_CONTROL_PRIORITY.STUN,			-- Shadowfury
		[24259] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Spell Lock (Felhunter)
		-- Warrior
		[7922]	= CROWD_CONTROL_PRIORITY.STUN,			-- Charge Stun
		[12809] = CROWD_CONTROL_PRIORITY.STUN,			-- Concussion Blow
		[20253] = CROWD_CONTROL_PRIORITY.STUN,			-- Intercept (also Warlock Felguard ability)
		[20511] = CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Intimidating Shout
		[5246]	= CROWD_CONTROL_PRIORITY.CROWD_CONTROL,	-- Intimidating Shout
		[12798] = CROWD_CONTROL_PRIORITY.STUN,			-- Revenge Stun
		[46968] = CROWD_CONTROL_PRIORITY.STUN,			-- Shockwave
		[18498] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Silenced - Gag Order
		[676]	= CROWD_CONTROL_PRIORITY.SILENCE,		-- Disarm
		[58373] = CROWD_CONTROL_PRIORITY.ROOT,			-- Glyph of Hamstring
		[23694] = CROWD_CONTROL_PRIORITY.ROOT,			-- Improved Hamstring
		-- Other
		[20549] = CROWD_CONTROL_PRIORITY.STUN,			-- War Stomp
		[28730] = CROWD_CONTROL_PRIORITY.SILENCE,		-- Arcane Torrent
		-- Immunities
		[46924] = CROWD_CONTROL_PRIORITY.IMMUNITY,		-- Bladestorm (Warrior)
		[642]	= CROWD_CONTROL_PRIORITY.IMMUNITY,		-- Divine Shield (Paladin)
		[45438] = CROWD_CONTROL_PRIORITY.IMMUNITY,		-- Ice Block (Mage)
		[34471] = CROWD_CONTROL_PRIORITY.IMMUNITY,		-- The Beast Within (Hunter)
		[12051] = CROWD_CONTROL_PRIORITY.IMMUNITY,		-- Evocation (Mage)
		[47585] = CROWD_CONTROL_PRIORITY.IMMUNITY		-- Dispersion (Priest)
	}

	self.AuraCooldown = {
		[31616] = 30,
		[45182] = 60,
	}

	self.AuraBlockList = {
	--[[
		[63944] = true,	-- Новая надежда
		[63514] = true,	-- Улучшенная аура благочестия
		[67480] = true,	-- Благословение неприкосновенности
		[61922] = true,	-- Спринт (лишнее)
		[48936] = true,	-- Благословение мудрости
		[20217] = true,	-- Благословение королей
		[48161] = true,	-- Слово силы стойкость
		[48169] = true,	-- Защита от темной магии
		[48073] = true,	-- Божественный дух
		[36563] = true,	-- Шаг сквозь тень (лишнее)
		[25898] = true,	-- Великое благословение королей
		[48074] = true,	-- Молитва духа
		[48162] = true,	-- Молитва стойкости
		[48170] = true,	-- Молитва защиты от темной магии
		[28878] = true,	-- Боевой дух (Дреней)
		[68066] = true,	-- Снижение урона (эффект)
		[48934] = true,	-- Благословение мудрости
		[48469] = true,	-- Знак дикой природы
		[48470] = true,	-- Дар дикой природы
		[54833] = true,	-- Символ озарения
		[61261] = true,	-- Власть льда (лишнее)
		[49772] = true,	-- Власть нечестивости (лишнее)
		[67016] = true,	-- Настой севера
		[48422] = true,	-- Искусный оборотень
		[34123] = true,	-- Древо жизни (аура)
		[63622] = true,	-- Великая власть нечестивости (лишнее)
		[57340] = true,	-- Пассивка танка
		[72968] = true,	-- Ленточка прелести
		[63510] = true,	-- Улучшенная аура сосредоточенности (эффект таланта)
		[53651] = true,	-- Частица света (триггер)
	--]]
		-- technical
		[32727] = true,
		[317903] = true,
	}

	self.CastBlacklist = {
		[320423] = true,
	}

	self.CooldownBlacklist = {
		[71] = true,
		[818] = true,
		[1784] = true,
		[2457] = true,
		[2458] = true,
		[5118] = true,
		[7384] = true,
		[13159] = true,
		[13161] = true,
		[13163] = true,
		[14183] = true,
		[15473] = true,
		[20271] = true,
		[27044] = true,
		[27138] = true,
		[30161] = true,
		[34074] = true,
		[35395] = true,
		[42931] = true,
		[47486] = true,
		[47488] = true,
		[49071] = true,
		[52150] = true,
		[57653] = true,
		[58887] = true,
		[59637] = true,
		[61411] = true,
		[61847] = true,
		[63619] = true,
		[71909] = true,
	}

    return self
end

function ezSpectator_DataWorker:SafeTexCoord(Value)
    if Value > 1 then
        Value = 1
    end

    if Value < 0 or Value ~= Value then
        Value = 0
    end

    return Value
end

function ezSpectator_DataWorker:SecondsToTime(Value, IsShort)
    if Value then
        local Time = math.floor(Value)

        if IsShort then
            return string.format('%.1d:%.2d', Time / 60 % 60, Time % 60)
        else
            return string.format('%.2d:%.2d', Time / 60 % 60, Time % 60)
        end
    else
        return ''
    end
end