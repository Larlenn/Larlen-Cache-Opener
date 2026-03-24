LarlenOverloadTracker = {}
local LOT = LarlenOverloadTracker

local defaultDB = {
    iconSize     = 32,
    alpha        = 1.0,
    showInCombat = true,
    showMinimap  = true,
    minimapPos   = 225,
    offsetX      = 0,
    offsetY      = 0,
    modules = {
        mining_df         = true,
        herb_df           = true,
        mining_tww        = true,
        herb_tww          = true,
        skinning_tww      = true,
        mining_midnight   = true,
        herb_midnight     = true,
        skinning_midnight = true,
    },
}

LOT.modules = {
    {
        id           = "mining_df",
        label        = "Mining (Dragonflight)",
        spellID      = 388213,
        continentIDs = {1978},
        nodeNames = {
            "Hardened Serevite Deposit",      "Hardened Draconium Deposit",
            "Titan-Touched Serevite Deposit",  "Titan-Touched Draconium Deposit",
            "Infurious Serevite Deposit",      "Infurious Draconium Deposit",
            "Molten Serevite Deposit",         "Molten Draconium Deposit",
            "Primal Serevite Deposit",         "Primal Draconium Deposit",
            "Metamorphic Serevite Deposit",    "Metamorphic Draconium Deposit",
            "Living Serevite Deposit",         "Living Draconium Deposit",
        },
    },
    {
        id           = "herb_df",
        label        = "Herbalism (Dragonflight)",
        spellID      = 390392,
        continentIDs = {1978},
        nodeNames = {
            "Windswept Hochenblume",      "Windswept Bubble Poppy",      "Windswept Saxifrage",      "Windswept Writhebark",
            "Titan-Touched Hochenblume",  "Titan-Touched Bubble Poppy",  "Titan-Touched Saxifrage",  "Titan-Touched Writhebark",
            "Infurious Hochenblume",      "Infurious Bubble Poppy",      "Infurious Saxifrage",      "Infurious Writhebark",
            "Decayed Hochenblume",        "Decayed Bubble Poppy",        "Decayed Saxifrage",        "Decayed Writhebark",
            "Frigid Hochenblume",         "Frigid Bubble Poppy",         "Frigid Saxifrage",         "Frigid Writhebark",
            "Lambent Hochenblume",        "Lambent Bubble Poppy",        "Lambent Saxifrage",        "Lambent Writhebark",
            "Overgrown Hochenblume",      "Overgrown Bubble Poppy",      "Overgrown Saxifrage",      "Overgrown Writhebark",
        },
    },
    {
        id           = "mining_tww",
        label        = "Mining (The War Within)",
        spellID      = 423394,
        continentIDs = {2274, 2214},
        nodeNames = {
            "Crystallized Bismuth",   "Crystallized Aqirite",   "Crystallized Ironclaw",
            "Weeping Bismuth",        "Weeping Aqirite",        "Weeping Ironclaw",
            "EZ-Mine Bismuth",        "EZ-Mine Aqirite",        "EZ-Mine Ironclaw",
            "Webbed Ore Deposit",
        },
    },
    {
        id           = "herb_tww",
        label        = "Herbalism (The War Within)",
        spellID      = 423395,
        continentIDs = {2274, 2214},
        nodeNames = {
            "Crystallized Blessing Blossom", "Crystallized Luredrop", "Crystallized Mycobloom", "Crystallized Orbinid", "Crystallized Arathor's Spear",
            "Altered Blessing Blossom",      "Altered Luredrop",      "Altered Mycobloom",      "Altered Orbinid",      "Altered Arathor's Spear",
            "Sporefused Blessing Blossom",   "Sporefused Luredrop",   "Sporefused Mycobloom",   "Sporefused Orbinid",   "Sporefused Arathor's Spear",
            "Irradiated Blessing Blossom",   "Irradiated Luredrop",   "Irradiated Mycobloom",   "Irradiated Orbinid",   "Irradiated Arathor's Spear",
        },
    },
    {
        id           = "skinning_tww",
        label        = "Skinning (The War Within)",
        spellID      = 440977,
        buffID       = 440977,
        continentIDs = {2274, 2214},
        isSkinning   = true,
    },
    {
        id           = "mining_midnight",
        label        = "Mining (Midnight)",
        spellID      = 1225392,
        continentIDs = {2393, 2395, 2413, 2405, 2444, 2437},
        nodeNames = {
            "Rich Refulgent Copper", "Refulgent Copper Seam",
            "Lightfused Refulgent Copper", "Primal Refulgent Copper",
            "Wild Refulgent Copper", "Voidbound Refulgent Copper",
            "Rich Umbral Tin", "Umbral Tin Seam",
            "Primal Umbral Tin", "Wild Umbral Tin",
            "Voidbound Umbral Tin", "Lightfused Umbral Tin",
            "Rich Brilliant Silver", "Brilliant Silver Seam",
            "Primal Brilliant Silver", "Wild Brilliant Silver",
            "Voidbound Brilliant Silver", "Lightfused Brilliant Silver",
        },
    },
    {
        id           = "herb_midnight",
        label        = "Herbalism (Midnight)",
        spellID      = 1223014,
        continentIDs = {2393, 2395, 2413, 2405, 2444, 2437},
        nodeNames = {
            "Lightfused Argentleaf", "Wild Argentleaf",
            "Primal Argentleaf",     "Voidbound Argentleaf",
            "Lightfused Mana Lily",  "Wild Mana Lily",
            "Primal Mana Lily",      "Voidbound Mana Lily",
            "Lightfused Azeroot",    "Wild Azeroot",
            "Primal Azeroot",        "Voidbound Azeroot",
            "Lightfused Sanguithorn","Wild Sanguithorn",
            "Primal Sanguithorn",    "Voidbound Sanguithorn",
            "Lightfused Tranquility Bloom", "Wild Tranquility Bloom",
            "Primal Tranquility Bloom",     "Voidbound Tranquility Bloom",
        },
    },
    {
        id           = "skinning_midnight",
        label        = "Skinning (Midnight)",
        spellID      = 1223388,
        buffID       = 1223388,
        continentIDs = {2393, 2395, 2413, 2405, 2444, 2437},
        isSkinning   = true,
    },
}
for _, mod in ipairs(LOT.modules) do
    if mod.nodeNames then
        local t = {}
        for _, name in ipairs(mod.nodeNames) do t[name] = true end
        mod.nameLookup = t
        mod.nodeNames  = nil
    end
end

local iconFrame
local db
local SKINNABLE_TAG
local lastShownMod
local lastCX, lastCY
local function RebuildZoneCache()
    local mapID = C_Map.GetBestMapForUnit("player")
    for _, mod in ipairs(LOT.modules) do
        if not mod.continentIDs then
            mod._inZone = true
        else
            local found   = false
            local current = mapID
            local visited = {}
            while current and not visited[current] do
                visited[current] = true
                for _, cID in ipairs(mod.continentIDs) do
                    if current == cID then found = true; break end
                end
                if found then break end
                local info = C_Map.GetMapInfo(current)
                current = info and info.parentMapID
            end
            mod._inZone = found
        end
    end
end

local function RebuildSpellCache()
    local known = C_Spell.IsSpellKnown
        and function(id) return C_Spell.IsSpellKnown(id) or C_Spell.IsSpellKnown(id, true) end
        or  function(id) return IsSpellKnown(id) or IsSpellKnown(id, true) end
    for _, mod in ipairs(LOT.modules) do
        mod._known = known(mod.spellID)
        if mod._known then
            local tex = C_Spell.GetSpellTexture(mod.spellID)
            mod._icon = tex
        end
    end
end

local function GetReadyCharges(id)
    local info = C_Spell.GetSpellCharges(id)
    if info then return (info.currentCharges or 1), (info.maxCharges or 1) end
    local cd = C_Spell.GetSpellCooldown(id)
    if cd and cd.duration and cd.duration > 0 then return 0, 1 end
    return 1, 1
end

local function HasBuff(id)
    return C_UnitAuras.GetPlayerAuraBySpellID(id) ~= nil
end

local function SkinnableText()
    local locale = GetLocale()
    if     locale == "deDE" then return "Hautbar"
    elseif locale == "esES" then return "Desollable"
    elseif locale == "frFR" then return "Depecable"
    else                         return "Skinnable"
    end
end

local function CreateIconFrame()
    local f = CreateFrame("Frame", "LarlenOverloadTrackerIcon", UIParent)
    f:SetFrameStrata("TOOLTIP")
    f:SetSize(db.iconSize, db.iconSize)
    f:Hide()

    local bg = f:CreateTexture(nil, "BORDER")
    bg:SetColorTexture(0, 0, 0, 1)
    bg:SetPoint("TOPLEFT",     f, "TOPLEFT",     -1,  1)
    bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",  1, -1)
    bg:SetDrawLayer("BORDER", -1)

    f.tex = f:CreateTexture(nil, "ARTWORK")
    f.tex:SetAllPoints()
    f.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    f.chargeLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.chargeLabel:SetPoint("BOTTOMRIGHT", 0, 0)
    f.chargeLabel:SetTextColor(1, 1, 1, 1)
    f.chargeLabel:Hide()

    return f
end

local function PositionIcon()
    local cx, cy = GetCursorPosition()
    local scale  = UIParent:GetEffectiveScale()
    iconFrame:ClearAllPoints()
    iconFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx / scale + 40 + db.offsetX, cy / scale - 40 + db.offsetY)
end

local function ShowIcon(mod, charges, maxCharges)
    if not mod._icon then return end
    if mod ~= lastShownMod then
        iconFrame:SetSize(db.iconSize, db.iconSize)
        iconFrame:SetAlpha(db.alpha)
        iconFrame.tex:SetTexture(mod._icon)
        lastShownMod = mod
    end
    PositionIcon()
    if maxCharges and maxCharges > 1 and charges > 1 then
        iconFrame.chargeLabel:SetText(charges)
        iconFrame.chargeLabel:Show()
    else
        iconFrame.chargeLabel:Hide()
    end
    iconFrame:Show()
end

function LOT:HideIcon()
    if iconFrame then
        lastShownMod = nil
        iconFrame:Hide()
    end
end

local function OnTooltipUpdate(_, arg1)
    if arg1 == 0 then LOT:HideIcon(); return end
    if not db.showInCombat and InCombatLockdown() then LOT:HideIcon(); return end

    for _, mod in ipairs(LOT.modules) do
        if mod._known and mod._inZone and db.modules[mod.id] ~= false then
            local ok, triggered = pcall(function()
                if mod.isSkinning then
                    local str = GameTooltipTextLeft4 and GameTooltipTextLeft4:GetText()
                    if str == SKINNABLE_TAG then
                        local charges = GetReadyCharges(mod.spellID)
                        if charges >= 1 or HasBuff(mod.buffID) then
                            ShowIcon(mod, charges, 1)
                            return true
                        end
                    end
                elseif mod.nameLookup then
                    local str = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
                    if rawget(mod.nameLookup, str) then
                        local charges, maxCharges = GetReadyCharges(mod.spellID)
                        if charges >= 1 then
                            ShowIcon(mod, charges, maxCharges)
                            return true
                        end
                    end
                end
            end)
            if ok and triggered then return end
        end
    end

    LOT:HideIcon()
end
local trackFrame = CreateFrame("Frame")
trackFrame:Hide()
trackFrame:SetScript("OnUpdate", function()
    if not (iconFrame and iconFrame:IsShown()) then return end
    local cx, cy = GetCursorPosition()
    if cx == lastCX and cy == lastCY then return end
    lastCX, lastCY = cx, cy
    PositionIcon()
end)

local pendingOpenOptions = false

function LOT.OpenOptions()
    if InCombatLockdown() then
        pendingOpenOptions = true
        print("|cFF00FF7FLarlen Overload Tracker|r: Options will open when combat ends.")
    elseif LOT.category then
        Settings.OpenToCategory(LOT.category.ID)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= "LarlenOverloadTracker" then return end
        LarlenOverloadTrackerDB = LarlenOverloadTrackerDB or {}
        db     = LarlenOverloadTrackerDB
        LOT.db = db
        for k, v in pairs(defaultDB) do
            if type(v) ~= "table" and db[k] == nil then db[k] = v end
        end
        if not db.modules then db.modules = {} end
        for k, v in pairs(defaultDB.modules) do
            if db.modules[k] == nil then db.modules[k] = v end
        end

    elseif event == "PLAYER_LOGIN" then
        SKINNABLE_TAG = SkinnableText()
        iconFrame     = CreateIconFrame()
        LOT.iconFrame = iconFrame
        RebuildSpellCache()
        RebuildZoneCache()

        local tooltipFrame = CreateFrame("Frame")
        tooltipFrame:RegisterEvent("WORLD_CURSOR_TOOLTIP_UPDATE")
        tooltipFrame:SetScript("OnEvent", OnTooltipUpdate)

        trackFrame:Show()
        LOT:InitializeOptions()
        LOT:InitializeMinimap()
        print("|cFF00FF7FLarlen Overload Tracker|r loaded. Type |cFFFFFF00/lot|r for options.")

    elseif event == "ZONE_CHANGED_NEW_AREA" then
        RebuildZoneCache()

    elseif event == "SPELLS_CHANGED" then
        RebuildSpellCache()

    elseif event == "PLAYER_REGEN_DISABLED" then
        if db and not db.showInCombat then LOT:HideIcon() end

    elseif event == "PLAYER_REGEN_ENABLED" then
        if pendingOpenOptions and LOT.category then
            pendingOpenOptions = false
            Settings.OpenToCategory(LOT.category.ID)
        end
    end
end)

function LOT:RefreshIcon()
    if not iconFrame then return end
    lastShownMod = nil
    iconFrame:SetSize(db.iconSize, db.iconSize)
    iconFrame:SetAlpha(db.alpha)
end

SLASH_LARLENOVERLOADTRACKER1 = "/lot"
SLASH_LARLENOVERLOADTRACKER2 = "/larlenoverloadtracker"

SlashCmdList["LARLENOVERLOADTRACKER"] = function(msg)
    msg = (msg or ""):lower():trim()
    if msg == "" then
        LOT.OpenOptions()
    elseif msg == "minimap" then
        db.showMinimap = not db.showMinimap
        LOT:UpdateMinimapVisibility()
        print("|cFF00FF7FLarlen Overload Tracker|r: Minimap " .. (db.showMinimap and "|cFF00FF00shown|r" or "|cFFFF4444hidden|r") .. ".")
    elseif msg == "reset" then
        LarlenOverloadTrackerDB = nil
        ReloadUI()
    else
        print("|cFF00FF7FLarlen Overload Tracker|r: /lot, /lot minimap, /lot reset")
    end
end

function LarlenOverloadTracker_OnCompartmentClick()
    LOT.OpenOptions()
end
