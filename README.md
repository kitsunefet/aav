AAV Cata Classic - Atrox Arena Viewer

===

**Cata Classic**
This is a ressurection of Atrox Arena Viewer to work with Cata Classic. The original addon uses some WoW API that is not available to Cata Classic, the features using the unavailable API have been reworked/replaced (if possible) or removed.

===

**AAV** is an arena replay addon, that lets you record or even broadcast arena matches. These arena matches can be viewed within WoW, while doing your daily quests, raids or just idling in Dalaran. It's optimized to run in very good-performance.

If you ever wanted to analyze your arena matches, why you died on that particular time on that particular match against that particular game and what skill could have been used, then AAV is a gem for you! Or if you want to follow your guildmates while they're doing arena, just hop in to their broadcast and watch their play.

Features
---
* record, replay, delete arena matches
* broadcast arena matches to guild mates
* see used skills
* casting bar
* cooldown bar
* interrupts (school locks)
* target system
* health and mana tracking
* change game speed in replay
* minimap icon menu
* match statistics (damage/healing done, ratings)

Limitation
---
**AAV** is like a graphical and interactive combatlog, that parses every action in the arena. However, it's not possible to keep track of the positionings. Who knows, maybe Blizzard opens up their API to make coordination gathering available in arena; this would make AAV more workable.

Slash Commands
---
* **/play [number]** - plays a given match.
* **/delete [number]** - deletes a give match.
* **/record** - whether a match will be recorded.
* **/broadcast** - enable/disable broadcasting.
* **/lookup** - lists all available broadcasts.
* **/connect [name]** - connects to the broadcast with the given name.

Known Bugs
---
* crowd control timers overlap with existing timers (good visible by Heroism)
* in rare cases stealth classes are not visible at all
* during broadcasting the icon and healthbar of combatants may switch places in rare cases and the buff and debuf bar doesn't fit
* interrupts do not always show ("X") on interrupted spell in play match window
* sometimes while in arena a LUA error keeps popping up every second, has something to do with spell auras. need to analyze further
* skirmish games are not recorded properly while broadcasting at the same time

Ideas for further improvement (volunteers are very welcome to create pull requests)
---
* detect talent spec by skills that are only available for specific specs (e.g. ice barrier = frost mage)
* show the duration of buffs/debuffs on targets (currently only done for CC spells)

Possible features that are currently not planned to be implemented:
---
* add pets
* track pet spells, e.g. felhunter devour magic, hunterpet intimidation
=> both would require even more data to be saved so we could only keep a small number of matches saved in total because of technical limitations.

FAQ
---
**How much Memory does the addon use?**

The addon is optimized for high-performance and as few memory usage as possible. Due to these requirements the player uses in play less than 1 MB memory. An average match takes up from 60 ~ 180kb, depends on heavy usage of spells and events (warlocks and resto druids do their job pretty well!). Matches can be deleted to free memory if needed.

**Why do matches disappear automatically?**
There is a technical limitation on how much data the addon can save (technically speaking: 2^18 keys can be loaded from a table in a function in LUA).
The recently added feature to show the number of stacks on buffs and debuffs requires a lot more data to be saved, so this limit is reached a lot faster than before.
To prevent losing all match data at once when exceeding that limit, there is now a maximum number of matched that is kept and older matches get deleted automatically. Currently, this is set to 50 matches.
Depending on length and type of matches (how much spells were cast, auras applied, refreshed etc.), this may even need to be reduced further in the future.

**Does it hurt my FPS rate?**

Not at all. From the stated requirements in the first question the addon is designed for high-performance and you won't notice any FPS loss.

**Does my ping increase while broadcasting?**

Not at all as well. The sent data is small and won't delay your latency. Additionally a sending mechanism takes care of the sending behaviour so you will never burst in sending data.

**Isn't it possible to disconnect when sending too much data?**

Yes, it is possible, but in AAV a sending mechanism takes care of all outgoing data. Rather sending all data at once, it apportions the big load of data over a certain time, that prevents from being disconnected.

**Where is the match data stored to?**

World of Warcraft\WTF\<your account>\SavedVariables\aav.lua

**I don't record/broadcast any combat events anymore, only Healthbar and Mana changes, why?**

This happens when your combat log and any addons that use the COMBAT_LOG_EVENT_UNFILTERED event (like AAV or afflicted) get screwed up due to massive glitched spam (courtesy of Blizzard). If you're familiar with the /run CombatLogClearEntries() command, that's being fired on every frame update, then you should be fine. Otherwise type /run ReloadUI() or relog will solve this problem. The incomplete match data that have been recorded under the bug cannot be fixed to show other events than Health's or Mana's.

**The damage in the score board doesn't match with my recount's, why?**

In the current version pets are completely disabled, means, their damage and contribution doesn't count yet.

**CREDITS**
---
Shoutout to the OG addon author [zwacky](https://twitter.com/zwacky) for creating such a wonderful WoW Arena PvP Addon! It really helped me blame my teammates a lot of times ;)
Further credits go to [skeledurr](https://github.com/Skeledurr/aav) for doing a lot of preparation work to make this workable since TBC Classic.
Thanks [Nookyx](https://github.com/Nookyx) for fixes and maintaining addon during WotLK.