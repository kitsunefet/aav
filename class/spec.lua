-- credits: ArenaStats
AAV_Spec = {}
AAV_Spec.__index = AAV_Spec

AAV_Spec.specTable = {}
AAV_Spec.specSpells = {
    [55050] = "Blood",         -- Heart Strike
    [55233] = "Blood",         -- Vampiric Blood
    [49028] = "Blood",         -- Dancing Rune Weapon
    [53138] = "Blood",         -- Abomination's Might
    [77513] = "Blood",         -- Blood Shield
    [77535] = "Blood",         -- Blood Shield
    [49222] = "Blood",         -- Bone Shield
    [53137] = "Blood",         -- Abomination's Might
    [79893] = "Blood",         -- Bloodworm
    [96171] = "Blood",         -- Will of the Necropolis
    [81162] = "Blood",         -- Will of the Necropolis
    [48982] = "Blood",         -- Rune Tap
    [49143] = "Frost",         -- Frost Strike
    [50435] = "Frost",         -- Chilblains
    [50434] = "Frost",         -- Chilblains
    [51271] = "Frost",         -- Pillar of Frost
    [49203] = "Frost",         -- Hungering Cold
    [49184] = "Frost",         -- Howling Blast
    [55610] = "Frost",         -- Improved Icy Talons
    [51124] = "Frost",         -- Killing Machine
    [55090] = "Unholy",        -- Scourge Strike
    [65142] = "Unholy",        -- Ebon Plague
    [51052] = "Unholy",        -- Anti-Magic Zone
    [49206] = "Unholy",        -- Summon Gargoyle
    [66803] = "Unholy",        -- Desolation
    [66802] = "Unholy",        -- Desolation
    [66801] = "Unholy",        -- Desolation
    [66800] = "Unholy",        -- Desolation
    [63583] = "Unholy",        -- Desolation
    [49194] = "Unholy",        -- Unholy Blight (debuff)
    [51460] = "Unholy",        -- Runic Corruption
    [49016] = "Unholy",        -- Unholy Frenzy
    [91342] = "Unholy",        -- Shadow Infusion
    [63560] = "Unholy",        -- Dark Transformation
    --
    [24858] = "Balance",       -- Moonkin Form
    [50516] = "Balance",       -- Typhoon
    [61391] = "Balance",       -- Typoon Dazed (Debuff)
    [48505] = "Balance",       -- Starfall
    [48391] = "Balance",       -- Owlkin Frenzy
    [48517] = "Balance",       -- Eclipse Solar
    [48518] = "Balance",       -- Eclipse Lunar
    [60433] = "Balance",       -- Earth and Moon
    [33831] = "Balance",       -- Force of Nature
    [24907] = "Balance",       -- Moonkin Aura
    [93402] = "Balance",       -- Sunfire (cast)
    [93400] = "Balance",       -- Shooting Stars
    [81006] = "Balance",       -- Lunar Shower
    [81288] = "Balance",       -- Fungal Growth (debuff)
    [81281] = "Balance",       -- Fungal Growth (debuff)
    [78675] = "Balance",       -- Solar Beam
    [24932] = "Feral",         -- Leader of the Pack
    [58180] = "Feral",         -- Infected Wounds
    [58179] = "Feral",         -- Infected Wounds
    [48566] = "Feral",         -- Mangle (Cat)
    [48564] = "Feral",         -- Mangle (Bear)
    [33876] = "Feral",         -- Debuff Mangle
    [33878] = "Feral",         -- Mangle (debuff)
    [50334] = "Feral",         -- Berserk (Bear)
    [81016] = "Feral",         -- Stampede
    [81022] = "Feral",         -- Stampede
    [81017] = "Feral",         -- Stampede
    [81021] = "Feral",         -- Stampede
    [51185] = "Feral",         -- King of the Jungle
    [61336] = "Feral",         -- Survival Instincts
    [80313] = "Feral",         -- Pulverize
    [49377] = "Feral",         -- Feral Charge (cast)
    [33891] = "Rdru",   -- Tree of Life
    [48438] = "Rdru",   -- Wild Growth
    [18562] = "Rdru",   -- Swiftmend
    [45283] = "Rdru",   -- R3
    [45282] = "Rdru",   -- R2
    [45281] = "Rdru",   -- R1
    [48504] = "Rdru",   -- Living Seed
    [17116] = "Rdru",   -- Nature's Swiftness
    [81093] = "Rdru",   -- Fury of Stormrage
    [81262] = "Rdru",   -- Efflorescence
    --
    [19574] = "BeastMastery",  -- Bestial Wrath
    [53257] = "BeastMastery",  -- Cobra Strikes
    [34471] = "BeastMastery",  -- Beast within
    [75447] = "BeastMastery",  -- Ferocious Inspiration
    [19577] = "BeastMastery",  -- Intimidation
    [94006] = "BeastMastery",  -- Killing Streak R1
    [94007] = "BeastMastery",  -- Killing Streak R2
    [82692] = "BeastMastery",  -- Focus Fire
    [82726] = "BeastMastery",  -- Fervor
    [19506] = "Marksmanship",  -- Trueshot Aura
    [53209] = "Marksmanship",  -- Chimera Shot
    [34490] = "Marksmanship",  -- Silencing Shot
    [53220] = "Marksmanship",  -- Improved Steady Shot
    [19434] = "Marksmanship",  -- Aimed Shot
    [88691] = "Marksmanship",  -- Marked for Death
    [83559] = "Marksmanship",  -- Posthaste
    [82925] = "Marksmanship",  -- Ready, Set, Aim...
    [23989] = "Marksmanship",  -- Readiness
    [82897] = "Marksmanship",  -- Resistance is Futile!
    [82921] = "Marksmanship",  -- Bombardment
    [413848] = "Marksmanship", -- Piercing Shots (debuff)
    [63468] = "Marksmanship",  -- Piercing Shots (debuff)
    [35101] = "Marksmanship",  -- Concussive Barrage (debuff)
    [19386] = "Survival",      -- Wyvern Sting
    [63672] = "Survival",      -- Black Arrow (debuff)
    [3674] = "Survival",       -- Black Arrow
    [53301] = "Survival",      -- Explosive Shot
    [34837] = "Survival",      -- Rank 5 Master Tactician
    [34836] = "Survival",      -- Rank 4 Master Tactician
    [34835] = "Survival",      -- Rank 3 Master Tactician
    [34834] = "Survival",      -- Rank 2 Master Tactician
    [34833] = "Survival",      -- Rank 1 Master Tactician
    [64420] = "Survival",      -- Sniper Training R3
    [64419] = "Survival",      -- Sniper Training R2
    [64418] = "Survival",      -- Sniper Training R1
    [19306] = "Survival",      -- Counterattack
    [56453] = "Survival",      -- Lock and Load
    [53290] = "Survival",      -- Hunting Party
    --
    [31589] = "Arcane",        -- Slow
    [44425] = "Arcane",        -- Arcane Barrage
    [12042] = "Arcane",        -- Arcane Power
    [44413] = "Arcane",        -- Incanter's Absorption
    [83098] = "Arcane",        -- Improved Mana Gem
    [54646] = "Arcane",        -- Focus Magic
    [57531] = "Arcane",        -- Arcane Potency
    [57529] = "Arcane",        -- Arcane Potency
    [12043] = "Arcane",        -- Presence of Mind
    [82930] = "Arcane",        -- Arcane Tactics
    [44457] = "Fire",          -- Living Bomb
    [31661] = "Fire",          -- Dragon's Breath
    [83853] = "Fire",          -- Combustion (debuff)
    [48108] = "Fire",          -- Hot Streak
    [64346] = "Fire",          -- Fiery Payback
    [54741] = "Fire",          -- Firestarter
    [11366] = "Fire",          -- Pyroblast
    [83582] = "Fire",          -- Pyromaniac
    [22959] = "Fire",          -- Critical Mass
    [11113] = "Fire",          -- Blast Wave
    [87023] = "Fire",          -- Cauterize
    [11426] = "Frostmage",         -- Ice Barrier
    [44572] = "Frostmage",         -- Deep Freeze
    [31687] = "Frostmage",         -- Summon Water Elemental
    [55080] = "Frostmage",         -- Shattered Barrier (R1)
    [83073] = "Frostmage",         -- Shattered Barrier (R2)
    [57761] = "Frostmage",         -- Brain Freeze
    [92283] = "Frostmage",         -- Frostfire Orb
    [44544] = "Frostmage",         -- Fingers of Frost
    [12472] = "Frostmage",         -- Icy Veins
    [11958] = "Frostmage",         -- Cold Snap
    [63095] = "Frostmage",         -- Ice Barrier (Glyph)
    --
    [20473] = "Holypal",          -- Holy Shock
    [53563] = "Holypal",          -- Beacon of Light
    [31842] = "Holypal",          -- Divine Favor
    [54149] = "Holypal",          -- Infusion of Light
    [85222] = "Holypal",          -- Light of Dawn
    [31821] = "Holypal",          -- Aura Mastery
    [85497] = "Holypal",          -- Speed of Light
    [88819] = "Holypal",          -- Daybreak
    [85509] = "Holypal",          -- Denounce
    [20925] = "Ppal",    -- Holy Shield
    [31935] = "Ppal",    -- Avenger's Shield
    [53595] = "Ppal",    -- Hammer of the Righteous
    [68055] = "Ppal",    -- Judgements of the Just
    [20132] = "Ppal",    -- Redoubt
    [20131] = "Ppal",    -- Redoubt
    [20128] = "Ppal",    -- Redoubt
    [31850] = "Ppal",    -- Ardent Defender
    [63529] = "Ppal",    -- Dazed - Avenger's Shield (debuff)
    [85416] = "Ppal",    -- Grand Crusader
    [53600] = "Ppal",    -- Shield of the Righteous
    [20177] = "Ppal",    -- Reckoning
    [85433] = "Ppal",    -- Sacred Duty
    [70940] = "Ppal",    -- Divine Guardian
    [26017] = "Ppal",    -- Vindication (debuff)
    [35395] = "Retribution",   -- Crusader Strike
    [53385] = "Retribution",   -- Divine Storm
    [20066] = "Retribution",   -- Repentance
    [59578] = "Retribution",   -- The Art of War
    [85256] = "Retribution",   -- Templar's Verdict
    [85696] = "Retribution",   -- Zealotry
    [87173] = "Retribution",   -- Long Arm of the Law
    [96263] = "Retribution",   -- Sacred Shield
    [85673] = "Retribution",   -- Word of Glory
    --
    [10060] = "Discipline",    -- Power Infusion
    [33206] = "Discipline",    -- Pain Suppression
    [47758] = "Discipline",    -- Penance
    [47757] = "Discipline",    -- Penance
    [45242] = "Discipline",    -- Focused Will
    [45241] = "Discipline",    -- Focused Will
    [47753] = "Discipline",    -- Divine Aegis
    [47930] = "Discipline",    -- Grace (R1)
    [77613] = "Discipline",    -- Grace (R2)
    [59889] = "Discipline",    -- Borrowed Time
    [59888] = "Discipline",    -- Borrowed Time
    [59887] = "Discipline",    -- Borrowed Time
    [89485] = "Discipline",    -- Inner Focus
    [62618] = "Discipline",    -- Power Word: Barrier
    [96267] = "Discipline",    -- Strength of Soul
    [96266] = "Discipline",    -- Strength of Soul
    [81751] = "Discipline",    -- Attonement (Heal)
    [34861] = "Holy",          -- Circle of Healing
    [724] = "Holy",            -- Lightwell
    [7001] = "Holy",           -- Lightwell Heal
    [33143] = "Holy",          -- Blessed Resilience
    [65081] = "Holy",          -- Body and Soul
    [64128] = "Holy",          -- Body and Soul
    [63735] = "Holy",          -- Serendipity
    [63731] = "Holy",          -- Serendipity
    [47788] = "Holy",          -- Guardian Spirit
    [27827] = "Holy",          -- Spirit of Redemption
    [14751] = "Holy",          -- Chakra
    [81206] = "Holy",          -- Chakra: Sanctuary
    [81209] = "Holy",          -- Chakra: Chastise
    [81208] = "Holy",          -- Chakra: Serenity
    [89912] = "Holy",          -- Chakra: Flow
    [88625] = "Holy",          -- Chastise (cast)
    [15473] = "Shadow",        -- Shadowform
    [15407] = "Shadow",        -- Mind Flay
    [34914] = "Shadow",        -- Vampiric Touch
    [33198] = "Shadow",        -- Misery
    [33197] = "Shadow",        -- Misery
    [33196] = "Shadow",        -- Misery
    [64044] = "Shadow",        -- Psychic Horror
    [47585] = "Shadow",        -- Dispersion
    [15286] = "Shadow",        -- Vampiric Embrace
    [15487] = "Shadow",        -- Silence
    [77487] = "Shadow",        -- Shadow orb
    [81292] = "Shadow",        -- Mind Melt
    [87532] = "Shadow",        -- Shadowy Apparition
    [49868] = "Shadow",        -- Mind Quickening
    [87204] = "Shadow",        -- Sin and Punishment (Horror)
    --
    [1329] = "Assassination",  -- Mutilate
    [58427] = "Assassination", -- Overkill (buff after stealth)
    [58426] = "Assassination", -- Overkill
    [60177] = "Assassination", -- Hunger For Blood
    [52910] = "Assassination", -- Turn the Tables
    [52915] = "Assassination", -- Turn the Tables
    [52914] = "Assassination", -- Turn the Tables
    [14177] = "Assassination", -- Cold Blood
    [79140] = "Assassination", -- Vendetta
    [93068] = "Assassination", -- Master Poisoner
    [13750] = "Combat",        -- Adrenaline Rush
    [51690] = "Combat",        -- Killing Spree
    [58683] = "Combat",        -- Savage Combat
    [58684] = "Combat",        -- Savage Combat
    [13877] = "Combat",        -- Blade Flurry
    [31125] = "Combat",        -- Blade Twisting (debuff)
    [84748] = "Combat",        -- Bandith's Guile (debuff)
    [51680] = "Combat",        -- Throwing Specialization
    [84617] = "Combat",        -- Revealing Strike
    [84745] = "Combat",        -- Shallow Insight
    [36554] = "Subtlety",      -- Shadowstep
    [36563] = "Subtlety",      -- Shadowstep
    [51713] = "Subtlety",      -- Shadow Dance
    [14183] = "Subtlety",      -- Premeditation
    [51693] = "Subtlety",      -- Waylay
    [31666] = "Subtlety",      -- Master of Subtlety
    [16511] = "Subtlety",      -- Hemorrhage
    [51698] = "Subtlety",      -- Honor Among Thieves
    [51701] = "Subtlety",      -- Honor Among Thieves
    [45182] = "Subtlety",      -- Cheat Death
    [14185] = "Subtlety",      -- Preparation
    --
    [77746] = "Elemental",     -- Totem Wrath
    [51490] = "Elemental",     -- Thunderstorm
    [16166] = "Elemental",     -- Elemental Mastery
    [51470] = "Elemental",     -- Elemental Oath (R2)
    [51466] = "Elemental",     -- Elemental Oath (R1)
    [61882] = "Elemental",     -- Knockdown
    [16246] = "Elemental",     -- Clearcasting
    [51480] = "Elemental",     -- Lava Flows R1
    [51481] = "Elemental",     -- Lava Flows
    [51482] = "Elemental",     -- Lava Flows
    [65264] = "Elemental",     -- Lava Flows
    [17364] = "Enhancement",   -- Stormstrike
    [60103] = "Enhancement",   -- Lava Lash
    [30823] = "Enhancement",   -- Shamanistic Rage
    [53817] = "Enhancement",   -- Maelstrom Weapon
    [51533] = "Enhancement",   -- Feral Spirit
    [97620] = "Enhancement",   -- Seasoned Winds (Nature, buff)
    [97619] = "Enhancement",   -- SW (Frost)
    [97621] = "Enhancement",   -- SW (Arcane)
    [97622] = "Enhancement",   -- SW (Shadow)
    [97618] = "Enhancement",   -- SW (Fire)
    [63685] = "Enhancement",   -- Freeze (debuff)
    [974] = "Restoration",     -- Earth Shield
    [61295] = "Restoration",   -- Riptide
    [51886] = "Restoration",   -- Cleanse Spirit
    [16190] = "Restoration",   -- Mana Tide Totem
    [53390] = "Restoration",   -- Tidal Waves
    [31616] = "Restoration",   -- Nature's Guardian
    [16236] = "Restoration",   -- Ancestral Fortitude (buff)
    [16188] = "Restoration",   -- Nature's Swiftness
    [98008] = "Restoration",   -- Soul Link Totem
    [51564] = "Restoration",   -- Tidal Waves
    [51562] = "Restoration",   -- Tidal Waves
    [51563] = "Restoration",   -- Tidal Waves
    [105284] = "Restoration",  -- Ancestral Vigor
    [51945] = "Restoration",   -- Earthliving
    [52752] = "Restoration",   -- Ancestral Awakening (SPELL_HEAL)
    --
    [30108] = "Affliction",  -- Unstable Affliction
    [48181] = "Affliction",  -- Haunt
    [64371] = "Affliction",  -- Eradication (R3)
    [64370] = "Affliction",  -- Eradication (R2)
    [64368] = "Affliction",  -- Eradication (R1)
    [18223] = "Affliction",  -- Curse of Exhaustion (cast)
    [86121] = "Affliction",  -- Soul Swap (cast)
    [17941] = "Affliction",  -- Shadow Trance (buff)
    [31117] = "Affliction",  -- Unstable Affliction (Silence)
    [60947] = "Affliction",  -- Nightmare (debuff)
    [32386] = "Affliction",  -- Shadow Embrace (debuff)
    [47193] = "Demonology",  -- Demonic Empowerment
    [63167] = "Demonology",  -- Decimation (R2)
    [63165] = "Demonology",  -- Decimation (R1)
    [30146] = "Demonology",  -- Summon Felguard
    [47241] = "Demonology",  -- Metamorphosis Buff
    [59672] = "Demonology",  -- Metamorphosis Cast
    [53646] = "Demonology",  -- Demonic Pact (buff)
    [71521] = "Demonology",  -- Hand of Gul'dan
    [47383] = "Demonology",  -- Molten Core (buff)
    [84740] = "Demonology",  -- Demonic Knowledge
    [17962] = "Destruction", -- Conflagrate
    [30283] = "Destruction", -- Shadowfury
    [50796] = "Destruction", -- Chaos bolt
    [54277] = "Destruction", -- Backdraft
    [54276] = "Destruction", -- Backdraft
    [54274] = "Destruction", -- Backdraft
    [34936] = "Destruction", -- Backlash
    [85383] = "Destruction", -- Improved Soulfire (buff)
    [17877] = "Destruction", -- Shadowburn (cast)
    [29341] = "Destruction", -- Shadowburn (buff)
    [79621] = "Destruction", -- burning ember (debuff)
    [91711] = "Destruction", -- Nether Ward (buff)
    [54375] = "Destruction", -- Nether Protection (Nature)
    [54372] = "Destruction", -- NP (Frost)
    [54371] = "Destruction", -- NP (Fire)
    [54370] = "Destruction", -- NP (Holy)
    [54374] = "Destruction", -- NP (Shadow)
    [54373] = "Destruction", -- NP (Arcane)
    [47283] = "Destruction", -- Empowered Imp (buff)
    [80240] = "Destruction", -- Bane of Havoc (cast/debuff)
    --
    [12294] = "Arms",        -- Mortal strike
    [46924] = "Arms",        -- Bladestorm
    [29842] = "Arms",        -- Second Wind (R2)
    [29841] = "Arms",        -- Second Wind (R1)
    [65156] = "Arms",        -- Juggernaut (buff)
    [64976] = "Arms",        -- Juggernaut
    [52437] = "Arms",        -- Sudden Death
    [46857] = "Arms",        -- Trauma (debuff)
    [60503] = "Arms",        -- Taste for Blood
    [23694] = "Arms",        -- Improved Harmstring
    [85730] = "Arms",        -- Deadly Calm
    [30070] = "Arms",        -- Blood Frenzy (debuff)
    [84584] = "Arms",        -- Slaughter
    [57518] = "Arms",        -- Enrage
    [85388] = "Arms",        -- Throwdown
    [23881] = "Fury",        -- Bloodthirst
    [12966] = "Fury",        -- Flurry
    [12292] = "Fury",        -- Death Wish
    [12880] = "Fury",        -- Enrage
    [85386] = "Fury",        -- Die by the Sword
    [85288] = "Fury",        -- Raging Blow
    [29801] = "Fury",        -- Rampage
    [60970] = "Fury",        -- Heroic Fury
    [56112] = "Fury",        -- Furious Attacks
    [85738] = "Fury",        -- Meat Cleaver
    [46916] = "Fury",        -- Bloodsurge (aura)
    [20243] = "Protection",  -- Devastate
    [46968] = "Protection",  -- Shockwave
    [50720] = "Protection",  -- Vigilance
    [46947] = "Protection",  -- Safeguard (R2)
    [46946] = "Protection",  -- Safeguard (R1)
    [12976] = "Protection",  -- Last Stand (buff)
    [57514] = "Protection",  -- Enrage (buff)
    [46945] = "Protection",  -- Safeguard (cast)
    [50227] = "Protection",  -- Sword and board (buff)
    [12809] = "Protection",  -- Concussion blow (debuff)
}

function AAV_Spec:getSpecSpells()
    return specSpells
end

function AAV_Spec:ScanUnitBuffs(unit)
    for n = 1, 30 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, n, "HELPFUL")

        if (not auraData) then
            break
        end

        if (not auraData.name) then
            break
        end

        local spellId = auraData.spellId
        local unitCaster = auraData.sourceUnit

        if AAV_Spec.specSpells[spellId] and unitCaster then -- Check for auras that detect a spec
            local unitPet = string.gsub(unit, "%d$", "pet%1")
            if UnitIsUnit(unit, unitCaster) or UnitIsUnit(unitPet, unitCaster) then
                AAV_Spec:OnSpecDetected(UnitGUID(unitCaster), AAV_Spec.specSpells[spellId])
            end
        end
    end
end

function AAV_Spec:OnSpecDetected(UnitGUID, spec)
    local existingPlayer = AAV_Spec.specTable[UnitGUID]

    if existingPlayer then
        return
    end

    AAV_Spec.specTable[UnitGUID] = spec
    --print(UnitGUID .. " " .. spec)
end

function AAV_Spec:GetSpecOrDefault(UnitGUID)
    if not UnitGUID then
        return "nospec"
    end

    local detectedSpec = AAV_Spec.specTable[UnitGUID]

    if detectedSpec then
        return detectedSpec
    end

    return "nospec"
end