ezSpectator_DataWorker = {}
ezSpectator_DataWorker.__index = ezSpectator_DataWorker

--noinspection LuaOverlyLongMethod
function ezSpectator_DataWorker:Create()
    local self = {}
    setmetatable(self, ezSpectator_DataWorker)

    self.Version = {
        ['Major'] = 1,
        ['Minor'] = 1,
        ['Build'] = 15,
        ['Revision'] = 187
    }

    self.NamePlateLevel = 0

    self.ViewpointAlpha = 0.33
    self.ViewpointNameplateAlpha = 0.50

    self.EnrageStartAt = 480
    self.EnrageStackInterval = 30
    self.EnrageStackMax = 10

    self.TimeWarnings = {
        [300] = '5_minute_warning',
        [180] = '3_minutes_remain',
        [120] = '2_minutes_remain',
        [60] = '1_minute_remains',
        [30] = '30_seconds_remain',
        [20] = '20_seconds',
        [10] = 'ten',
        [9] = 'nine',
        [8] = 'eight',
        [7] = 'seven',
        [6] = 'six',
        [5] = 'five',
        [4] = 'four',
        [3] = 'three',
        [2] = 'two',
        [1] = 'one'
    }

    self.TournamentStages = {
        ['G'] = ARENA_SPECTATOR_GROUP_STAGE,
        ['U'] = ARENA_SPECTATOR_TOP_MESH,
        ['L'] = ARENA_SPECTATOR_BOTTOM_MESH,
        ['T'] = ARENA_SPECTATOR_3_PLACE_MATCH,
        ['F'] = ARENA_SPECTATOR_FINAL_MATCH
    }

    self.MatchEndings = {
        ['DEFAULT'] = {
            'EndOfRound',
            'SKAARJannihilation',
            'SKAARJbloodbath',
            'SKAARJerradication',
            'SKAARJextermination',
            'SKAARJslaughter',
            'SKAARJtermination'
        }
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

    self.ClassTreeInfo = {
        --Воин
        {{WARRIOR_SPEC_ARMS_TITLE, '2098', false}, {WARRIOR_SPEC_FURY_TITLE, '41368', false}, {WARRIOR_SPEC_PROTECTION_TITLE, '71', false}},
        --Паладин
        {{PALADIN_SPEC_HOLY_TITLE, '18984', true}, {PALADIN_SPEC_PROTECTION_TITLE, '52442', false}, {PALADIN_SPEC_RETRIBUTION_TITLE, '13008', false}},
        --Охотник
        {{HUNTER_SPEC_BEASTMASTERY_TITLE, '1515', false}, {HUNTER_SPEC_MARKSMANSHIP_TITLE, '58434', false}, {HUNTER_SPEC_SURVIVAL_TITLE, '37413', false}},
        --Разбойник
        {{ROGUE_SPEC_ASSASSINATION_TITLE, '2098', false}, {ROGUE_SPEC_COMBAT_TITLE, '53', false}, {ROGUE_SPEC_SUBTLETY_TITLE, '19885', false}},
        --Жрец
        {{PRIEST_SPEC_DISCIPLINE_TITLE, '34020', true}, {PRIEST_SPEC_HOLY_TITLE, '18984', true}, {PRIEST_SPEC_SHADOW_TITLE, '589', false}},
        --Рыцарь смерти
        {{DEATHKNIGHT_SPEC_BLOOD_TITLE, '48263', false}, {DEATHKNIGHT_SPEC_FROST_TITLE, '48266', false}, {DEATHKNIGHT_SPEC_UNHOLY_TITLE, '48265', false}},
        --Шаман
        {{SHAMAN_SPEC_ELEMENTAL_TITLE, '41265', false}, {SHAMAN_SPEC_ENHANCEMENT_TITLE, '324', false}, {SHAMAN_SPEC_RESTORATION_TITLE, '48700', true}},
        --Маг
        {{MAGE_SPEC_ARCANE_TITLE, '32848', false}, {MAGE_SPEC_FIRE_TITLE, '38066', false}, {MAGE_SPEC_FROST_TITLE, '10737', false}},
        --Чернокнижник
        {{WARLOCK_AFFLICTION_TITLE, '23127', false}, {WARLOCK_DEMONOLOGY_TITLE, '13166', false}, {WARLOCK_DESTRUCTION_TITLE, '39273', false}},
        --Blizzard sucks
        {{'', ''}, {'', ''}, {'', ''}},
        --Друид
        {{DRUID_BALANCE_TITLE, '8921', false}, {DRUID_FERAL_TITLE, '40794', false}, {DRUID_RESTORATION_TITLE, '43422', true}}
    }

    self.SpellFunctor = {}
    self.SpellFunctor.RESET_COOLDOWN = 1

    self.ClassSpellInfo = {
        --Воин
        {

        },
        --Паладин
        {

        },
        --Охотник
        {
            --Готовность (Стрельба)
            [23989] = {
                functor = self.SpellFunctor.RESET_COOLDOWN,
                params = {19263, 34490, 53271, 19503, 60192, 49012}
            }
        },
        --Разбойник
        {
            --Подготовка (Скрытность)
            [14185] = {
                functor = self.SpellFunctor.RESET_COOLDOWN,
                params = {26889}
            }
        },
        --Жрец
        {

        },
        --Рыцарь смерти
        {

        },
        --Шаман
        {

        },
        --Маг
        {

        },
        --Чернокнижник
        {

        },
        --Blizzard sucks
        {},
        --Друид
        {

        }
    }

    self.Trinkets = {
        [65547] = 120,
        [42292] = 120,
        [59752] = 120,
        [7744] = 45
    }

    self.ClickIconOffset = {
        {'Eye_Normal', 0.21875, 0.7890625, 0.21875, 0.7890625, 18},
        {'Eye_Stroked', 0.21875, 0.7890625, 0.21875, 0.7890625, 18},
        {'Logout', 0.25, 0.7578125, 0.25, 0.7578125, 14},
        {'Refresh', 0.25, 0.7578125, 0.25, 0.7578125, 10},
        {'Plus', 0, 1, 0, 1, 10},
        {'exit', 0, 1, 0, 1, 10},
        {'report', 0, 1, 0, 1, 10},
        {'settings', 0, 1, 0, 1, 10},
        {'share', 0, 1, 0, 1, 12},
        {'backward', 0, 1, 0, 1, 12},
        {'forward', 0, 1, 0, 1, 12},
        {'pause', 0, 1, 0, 1, 12},
        {'play', 0, 1, 0, 1, 12},
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

    self.CAST_SUCCESS = 99997
    self.CastInfo = {
        --range
        [99995] = {r = 1, g = 1, b = 0, Text = CANCELED, IsProgressMode = false},
        --los
        [99996] = {r = 1, g = 1, b = 0, Text = CANCELED, IsProgressMode = false},
        --success
        [self.CAST_SUCCESS] = {r = 0, g = 1, b = 0, Text = SUCCESSFULLY, IsProgressMode = false},
        --canceled
        [99998] = {r = 1, g = 1, b = 0, Text = CANCELED, IsProgressMode = false},
        --interrupt
        [99999] = {r = 1, g = 0, b = 0, Text = INTERRUPTED, IsProgressMode = false},
        --casting
        [100000] = {r = 0, g = 1, b = 1, Text = nil, IsProgressMode = true}
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

    self.AuraRootEffect = 1
    self.AuraSilenceEffect = 2
    self.AuraCrowdControlEffect = 3
    self.AuraStunEffect = 4
    self.AuraImmunitylEffect = 5

    self.BLOCK_ALWAYS = 1
    self.DETAILED_VIEW = 2
    self.AuraBlockList = {
        --Новая надежда
        [63944] = true,
        --Улучшенная аура благочестия
        [63514] = true,
        --Благословение неприкосновенности
        [67480] = true,
        --Спринт (лишнее)
        [61922] = true,
        --Благословение мудрости
        [48936] = true,
        --Благословение королей
        [20217] = true,
        --Слово силы стойкость
        [48161] = true,
        --Защита от темной магии
        [48169] = true,
        --Божественный дух
        [48073] = true,
        --Шаг сквозь тень (лишнее)
        [36563] = true,
        --Великое благословение королей
        [25898] = true,
        --Молитва духа
        [48074] = true,
        --Молитва стойкости
        [48162] = true,
        --Молитва защиты от темной магии
        [48170] = true,
        --Боевой дух (Дреней)
        [28878] = true,
        --Снижение урона (эффект)
        [68066] = true,
        --Благословение мудрости
        [48934] = true,
        --Знак дикой природы
        [48469] = true,
        --Дар дикой природы
        [48470] = true,
        --Символ озарения
        [54833] = true,
        --Власть льда (лишнее)
        [61261] = true,
        --В3ласть нечестивости (лишнее)
        [49772] = true,
        --Настой севера
        [67016] = true,
        --Искусный оборотень
        [48422] = true,
        --Древо жизни (аура)
        [34123] = true,
        --Великая власть нечестивости (лишнее)
        [63622] = true,
        --Пассивка танка
        [57340] = true,
        --Ленточка прелести
        [72968] = true,
        --Улучшенная аура сосредоточенности (эффект таланта)
        [63510] = true,
        --Частица света (триггер)
        [53651] = true
    }

    self.ControlList = {
        -- Death Knight
        [47481] = self.AuraStunEffect,            -- Gnaw (Ghoul)
        [51209] = self.AuraCrowdControlEffect,    -- Hungering Cold
        [47476] = self.AuraSilenceEffect,        -- Strangulate
        -- Druid
        [8983]  = self.AuraStunEffect,            -- Bash (also Shaman Spirit Wolf ability)
        [33786] = self.AuraStunEffect,            -- Cyclone
        [18658] = self.AuraCrowdControlEffect,    -- Hibernate (works against Druids in most forms and Shamans using Ghost Wolf)
        [49802] = self.AuraStunEffect,            -- Maim
        [49803] = self.AuraStunEffect,            -- Pounce
        [53308] = self.AuraRootEffect,            -- Entangling Roots
        [53313] = self.AuraRootEffect,            -- Entangling Roots (Nature's Grasp)
        [45334] = self.AuraRootEffect,            -- Feral Charge Effect (immobilize with interrupt [spell lockout, not silence])
        -- Hunter
        [60210] = self.AuraCrowdControlEffect,    -- Freezing Arrow Effect
        [14309] = self.AuraCrowdControlEffect,    -- Freezing Trap Effect
        [24394] = self.AuraStunEffect,            -- Intimidation
        [14327] = self.AuraCrowdControlEffect,    -- Scare Beast (works against Druids in most forms and Shamans using Ghost Wolf)
        [19503] = self.AuraCrowdControlEffect,    -- Scatter Shot
        [49012] = self.AuraCrowdControlEffect,    -- Wyvern Sting
        [34490] = self.AuraSilenceEffect,        -- Silencing Shot
        [53359] = self.AuraSilenceEffect,        -- Chimera Shot - Scorpid
        [19306] = self.AuraRootEffect,            -- Counterattack
        [64804] = self.AuraRootEffect,            -- Entrapment
        -- Hunter Pets
        [53568] = self.AuraStunEffect,            -- Sonic Blast (Bat)
        [53543] = self.AuraSilenceEffect,        -- Snatch (Bird of Prey)
        [53548] = self.AuraRootEffect,            -- Pin (Crab)
        [53562] = self.AuraStunEffect,            -- Ravage (Ravager)
        [55509] = self.AuraRootEffect,            -- Venom Web Spray (Silithid)
        [4167]  = self.AuraRootEffect,            -- Web (Spider)
        -- Mage
        [44572] = self.AuraStunEffect,            -- Deep Freeze
        [31661] = self.AuraCrowdControlEffect,    -- Dragon's Breath
        [12355] = self.AuraCrowdControlEffect,    -- Impact
        [12826] = self.AuraCrowdControlEffect,    -- Polymorph
        [55021] = self.AuraSilenceEffect,        -- Silenced - Improved Counterspell
        [64346] = self.AuraSilenceEffect,        -- Fiery Payback
        [33395] = self.AuraRootEffect,            -- Freeze (Water Elemental)
        [42917] = self.AuraRootEffect,            -- Frost Nova
        [12494] = self.AuraRootEffect,            -- Frostbite
        [55080] = self.AuraRootEffect,            -- Shattered Barrier
        -- Paladin
        [10308] = self.AuraStunEffect,            -- Hammer of Justice
        [48817] = self.AuraCrowdControlEffect,    -- Holy Wrath (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
        [20066] = self.AuraCrowdControlEffect,    -- Repentance
        [20170] = self.AuraStunEffect,            -- Stun (Seal of Justice proc)
        [10326] = self.AuraCrowdControlEffect,    -- Turn Evil (works against Warlocks using Metamorphasis and Death Knights using Lichborne)
        [63529] = self.AuraSilenceEffect,        -- Shield of the Templar
        -- Priest
        [605]   = self.AuraCrowdControlEffect,    -- Mind Control
        [64044] = self.AuraStunEffect,            -- Psychic Horror
        [10890] = self.AuraCrowdControlEffect,    -- Psychic Scream
        [10955] = self.AuraCrowdControlEffect,    -- Shackle Undead (works against Death Knights using Lichborne)
        [15487] = self.AuraSilenceEffect,        -- Silence
        [64058] = self.AuraSilenceEffect,        -- Psychic Horror (duplicate debuff names not allowed atm, need to figure out how to support this later)
        -- Rogue
        [2094]  = self.AuraCrowdControlEffect,    -- Blind
        [1833]  = self.AuraStunEffect,            -- Cheap Shot
        [1776]  = self.AuraCrowdControlEffect,    -- Gouge
        [8643]  = self.AuraStunEffect,            -- Kidney Shot
        [51724] = self.AuraCrowdControlEffect,    -- Sap
        [1330]  = self.AuraSilenceEffect,        -- Garrote - Silence
        [18425] = self.AuraSilenceEffect,        -- Silenced - Improved Kick
        [51722] = self.AuraSilenceEffect,        -- Dismantle
        -- Shaman
        [39796] = self.AuraStunEffect,            -- Stoneclaw Stun
        [51514] = self.AuraCrowdControlEffect,    -- Hex (although effectively a silence+disarm effect, it is conventionally thought of as a self.AuraCrowdControlEffect, plus you can trinket out of it)
        [64695] = self.AuraRootEffect,            -- Earthgrab (Storm, Earth and Fire)
        [63685] = self.AuraRootEffect,            -- Freeze (Frozen Power)
        -- Warlock
        [18647] = self.AuraStunEffect,            -- Banish (works against Warlocks using Metamorphasis and Druids using Tree Form)
        [47860] = self.AuraStunEffect,            -- Death Coil
        [6215]  = self.AuraCrowdControlEffect,    -- Fear
        [17928] = self.AuraCrowdControlEffect,    -- Howl of Terror
        [6358]  = self.AuraCrowdControlEffect,    -- Seduction (Succubus)
        [47847] = self.AuraStunEffect,            -- Shadowfury
        [24259] = self.AuraSilenceEffect,        -- Spell Lock (Felhunter)
        -- Warrior
        [7922]  = self.AuraStunEffect,            -- Charge Stun
        [12809] = self.AuraStunEffect,            -- Concussion Blow
        [20253] = self.AuraStunEffect,            -- Intercept (also Warlock Felguard ability)
        [20511] = self.AuraCrowdControlEffect,    -- Intimidating Shout
        [5246]  = self.AuraCrowdControlEffect,    -- Intimidating Shout
        [12798] = self.AuraStunEffect,            -- Revenge Stun
        [46968] = self.AuraStunEffect,            -- Shockwave
        [18498] = self.AuraSilenceEffect,        -- Silenced - Gag Order
        [676]   = self.AuraSilenceEffect,        -- Disarm
        [58373] = self.AuraRootEffect,            -- Glyph of Hamstring
        [23694] = self.AuraRootEffect,            -- Improved Hamstring
        -- Other
        [20549] = self.AuraStunEffect,            -- War Stomp
        [28730] = self.AuraSilenceEffect,        -- Arcane Torrent
        -- Immunities
        [46924] = self.AuraImmunitylEffect,        -- Bladestorm (Warrior)
        [642]   = self.AuraImmunitylEffect,        -- Divine Shield (Paladin)
        [45438] = self.AuraImmunitylEffect,        -- Ice Block (Mage)
        [34471] = self.AuraImmunitylEffect,        -- The Beast Within (Hunter)
        [12051] = self.AuraImmunitylEffect,        -- Evocation (Mage)
        [47585] = self.AuraImmunitylEffect        -- Dispersion (Priest)
    }

    -- Список игроков, чьи ники будут отображаться "особенно"
    self.PinkList = {
    }

    self.ClientLocale = GetLocale()
    self.Strings = {
        ['ruRU'] = {
            ['GOSSIP_SPECTATOR_TEXT'] = 'GOSSIP_SPECTATOR_TEXT',
            ['GOSSIP_SPECTATOR_SUBSCRIBE'] = 'GOSSIP_SPECTATOR_SUBSCRIBE',
            ['GOSSIP_SPECTATOR_UNSUBSCRIBE'] = 'GOSSIP_SPECTATOR_UNSUBSCRIBE',
        }
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



function ezSpectator_DataWorker:SafeSize(Value)
    --if Value < 0 then
    --    Value = 0
    --end

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



function ezSpectator_DataWorker:GetString(Value)
    if self.Strings[self.ClientLocale] and self.Strings[self.ClientLocale][Value] then
        return self.Strings[self.ClientLocale][Value]
    else
        return ''
    end
end