# Larlen Overload Tracker Changelog

## v1.0.3
- Fixed icon showing on cursor in cities when hovering over NPCs or other objects while having mining/herb charges ready.
- DF and TWW mining/herbalism modules now only trigger on actual overload-eligible nodes, same as Midnight always did.

## v1.0.2
- Fixed Lua errors caused by secret number taint from C_Spell.GetSpellCharges in certain dungeon encounters.

## v1.0.1
- Fixed Lua errors caused by Blizzard's secret string type on tooltip lines in certain dungeons.

## v1.0.0 - Initial Release
- Cursor-following icon that appears when mousing over an eligible overload node.
- Supports Mining, Herbalism, and Skinning for Dragonflight, The War Within, and Midnight.
- Midnight node detection via tooltip name lookup with full node name database.
- Skinning detection via tooltip type line and buff fallback.
- Charge counter displayed on icon when more than one charge is available.
- Per-module toggles to enable or disable each expansion and profession individually.
- Adjustable icon size, opacity, and cursor X/Y offset.
- Test Icon button to preview position live from the options panel.
- Minimap button with left-click to open options, right-click to hide.
- Combat-safe: options panel queues to open after combat ends.
- Zone and spell caching to keep the tooltip hot path allocation-free.

**Credits:** All original credit to **Markiv** for the Overload Reminder WeakAura that inspired this addon.
