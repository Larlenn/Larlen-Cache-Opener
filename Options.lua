local _, L = ...;

LarlenCacheOpener.option_buttons = {};

local testActive = false
local profileNameInput = ""

local function NotifyChange()
    LibStub("AceConfigRegistry-3.0"):NotifyChange("LarlenCacheOpener")
end

local function GetP(key)      return LarlenCacheOpener:P(key) end
local function SetP(key, val) LarlenCacheOpener:SetP(key, val) end

-----------------------------------------
-- Custom Items Popup Window
-----------------------------------------
local ACCENT  = { 1.00, 0.65, 0.00 }
local WHITE   = { 1.00, 1.00, 1.00 }
local DIM     = { 0.38, 0.38, 0.42 }
local BTN_BG  = { 0.08, 0.08, 0.12, 1 }
local BTN_HOV = { 0.14, 0.14, 0.20, 1 }
local ROW_H   = 26

local FLAT_BD = {
    bgFile   = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1, tile = true, tileSize = 8,
    insets   = { left=1, right=1, top=1, bottom=1 },
}

local _ci_uid = 0
local function N(b) _ci_uid = _ci_uid + 1; return ("LCO_CI_%s%d"):format(b, _ci_uid) end

local function MakeBtn(parent, label, w, h)
    local b = CreateFrame("Button", N("B"), parent, "BackdropTemplate")
    b:SetSize(w or 80, h or ROW_H)
    b:SetBackdrop(FLAT_BD)
    b:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
    b:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("CENTER"); fs:SetText(label or ""); fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    b:SetScript("OnEnter", function(s)
        s:SetBackdropColor(BTN_HOV[1], BTN_HOV[2], BTN_HOV[3], BTN_HOV[4])
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
        fs:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    end)
    b:SetScript("OnLeave", function(s)
        s:SetBackdropColor(BTN_BG[1], BTN_BG[2], BTN_BG[3], BTN_BG[4])
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
        fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    end)
    return b
end

local customWin = nil
local blacklistWin = nil

local function BuildCustomItemsWindow()
    if customWin then return end

    local WIN_W = 460
    local WIN_H = 540
    local LIST_H  = 220
    local ITEM_ROW = 28
    local PAD = 12

    local win = CreateFrame("Frame", "LCO_CustomItemsWindow", UIParent, "BackdropTemplate")
    win:SetSize(WIN_W, WIN_H)
    win:SetPoint("CENTER", UIParent, "CENTER", 340, 0)
    win:SetBackdrop(FLAT_BD)
    win:SetBackdropColor(0.06, 0.06, 0.09, 0.97)
    win:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.60)
    win:SetFrameStrata("DIALOG")
    win:SetMovable(true)
    win:EnableMouse(true)
    win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", win.StartMoving)
    win:SetScript("OnDragStop",  win.StopMovingOrSizing)
    win:SetClampedToScreen(true)
    win:Hide()
    tinsert(UISpecialFrames, "LCO_CustomItemsWindow")

    local titleFS = win:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleFS:SetPoint("TOPLEFT", win, PAD, -10)
    titleFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    titleFS:SetText("Custom Items")

    local titleLine = win:CreateTexture(nil, "ARTWORK")
    titleLine:SetHeight(1)
    titleLine:SetPoint("TOPLEFT",  win, PAD,      -30)
    titleLine:SetPoint("TOPRIGHT", win, -PAD - 28, -30)
    titleLine:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)

    local closeBtn = CreateFrame("Button", N("X"), win, "BackdropTemplate")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", win, -4, -4)
    closeBtn:SetBackdrop(FLAT_BD)
    closeBtn:SetBackdropColor(0.10, 0.10, 0.14, 1)
    closeBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    local xFS = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    xFS:SetPoint("CENTER"); xFS:SetText("×"); xFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    closeBtn:SetScript("OnClick", function() win:Hide() end)
    closeBtn:SetScript("OnEnter", function(s)
        s:SetBackdropColor(0.22, 0.08, 0.08, 1)
        s:SetBackdropBorderColor(0.90, 0.30, 0.30, 0.80)
        xFS:SetTextColor(1, 0.4, 0.4, 1)
    end)
    closeBtn:SetScript("OnLeave", function(s)
        s:SetBackdropColor(0.10, 0.10, 0.14, 1)
        s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
        xFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    end)

    local subFS = win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subFS:SetPoint("TOPLEFT", win, PAD, -36)
    subFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    subFS:SetText("Track additional items not in the built-in database.")

    local sf = CreateFrame("ScrollFrame", N("SF"), win, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",     win, PAD,      -50)
    sf:SetPoint("BOTTOMRIGHT", win, -PAD - 18, PAD)

    local CONTENT_W = WIN_W - PAD * 2 - 18 - 4
    local content = CreateFrame("Frame", N("CH"), sf)
    content:SetWidth(CONTENT_W)
    sf:SetScrollChild(content)

    local yOff = 0
    local searchStr  = ""
    local pendingID  = nil
    local pendingData = nil
    local RebuildList

    local addCont = CreateFrame("Frame", N("ADC"), content, "BackdropTemplate")
    addCont:SetHeight(ROW_H)
    addCont:SetPoint("TOPLEFT",  content, 0,         yOff)
    addCont:SetPoint("TOPRIGHT", content, -74,       yOff)
    addCont:SetBackdrop(FLAT_BD)
    addCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)

    local addPlaceholder = addCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addPlaceholder:SetPoint("LEFT", addCont, 8, 0)
    addPlaceholder:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    addPlaceholder:SetText("Drag an item here or type an item ID...")

    local addEB = CreateFrame("EditBox", N("AEB"), addCont)
    addEB:SetPoint("LEFT",  addCont,  8, 0)
    addEB:SetPoint("RIGHT", addCont, -8, 0)
    addEB:SetHeight(ROW_H - 4)
    addEB:SetAutoFocus(false)
    addEB:SetFontObject("GameFontNormal")
    addEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    addEB:SetMaxLetters(200)
    addEB:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)

    local addBtn = MakeBtn(content, "Add", 66, ROW_H)
    addBtn:SetPoint("TOPLEFT", addCont, "TOPRIGHT", 4, 0)

    yOff = yOff - ROW_H - 4

    local prevCont = CreateFrame("Button", N("PRC"), content, "BackdropTemplate")
    prevCont:SetHeight(ROW_H)
    prevCont:SetPoint("TOPLEFT",  content, 0, yOff)
    prevCont:SetPoint("TOPRIGHT", content, 0, yOff)
    prevCont:SetBackdrop(FLAT_BD)
    prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0)
    prevCont:SetBackdropBorderColor(0, 0, 0, 0)
    prevCont:EnableMouse(true)

    local prevIcon = prevCont:CreateTexture(nil, "ARTWORK")
    prevIcon:SetSize(20, 20)
    prevIcon:SetPoint("LEFT", prevCont, 5, 0)
    prevIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    prevIcon:Hide()

    local prevNameFS = prevCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prevNameFS:SetPoint("LEFT",  prevIcon, "RIGHT", 5, 0)
    prevNameFS:SetPoint("RIGHT", prevCont, -5, 0)
    prevNameFS:SetJustifyH("LEFT"); prevNameFS:SetWordWrap(false)

    yOff = yOff - ROW_H - 4

    local listCont = CreateFrame("Frame", N("LC"), content, "BackdropTemplate")
    listCont:SetHeight(LIST_H)
    listCont:SetPoint("TOPLEFT",  content, 0, yOff)
    listCont:SetPoint("TOPRIGHT", content, 0, yOff)
    listCont:SetBackdrop(FLAT_BD)
    listCont:SetBackdropColor(0.04, 0.04, 0.06, 1)
    listCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.20)

    yOff = yOff - LIST_H - 4

    local listSF = CreateFrame("ScrollFrame", N("LSF"), listCont, "UIPanelScrollFrameTemplate")
    listSF:SetPoint("TOPLEFT",     listCont,  3,  -3)
    listSF:SetPoint("BOTTOMRIGHT", listCont, -22,  3)

    local listContent = CreateFrame("Frame", N("CT"), listSF)
    listSF:SetScrollChild(listContent)

    local emptyFS = listCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyFS:SetPoint("CENTER", listCont, 0, 0)
    emptyFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    emptyFS:Hide()

    local activeRows = {}
    local rowPool    = {}

    local function GetOrMakeRow()
        local r = table.remove(rowPool)
        if r then r:Show(); return r end

        r = CreateFrame("Frame", nil, listContent, "BackdropTemplate")
        r:SetHeight(ITEM_ROW); r:SetBackdrop(FLAT_BD)

        local icon = r:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20); icon:SetPoint("LEFT", r, 6, 0)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        r._icon = icon

        local hover = CreateFrame("Frame", nil, r)
        hover:SetAllPoints(r); hover:SetFrameLevel(r:GetFrameLevel() + 1); hover:EnableMouse(true)
        hover:SetScript("OnEnter", function()
            if r._tooltipLink then
                GameTooltip:SetOwner(r, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(r._tooltipLink)
                GameTooltip:Show()
            end
            r:SetBackdropColor(ACCENT[1]*0.15, ACCENT[2]*0.08, ACCENT[3]*0.02, 1)
        end)
        hover:SetScript("OnLeave", function()
            GameTooltip:Hide()
            r:SetBackdropColor(r._bgR or 0.04, r._bgG or 0.04, r._bgB or 0.06, 0.90)
        end)

        local nameFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameFS:SetPoint("LEFT",  icon, "RIGHT", 5, 0)
        nameFS:SetPoint("RIGHT", r, "RIGHT", -76, 0)
        nameFS:SetJustifyH("LEFT"); nameFS:SetWordWrap(false)
        r._name = nameFS

        local idFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        idFS:SetPoint("RIGHT", r, -76, 0); idFS:SetJustifyH("RIGHT")
        idFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
        r._idFS = idFS

        local removeBtn = MakeBtn(r, "Remove", 66, ITEM_ROW - 6)
        removeBtn:SetPoint("RIGHT", r, -4, 0)
        removeBtn:SetFrameLevel(r:GetFrameLevel() + 5)
        r._removeBtn = removeBtn
        return r
    end

    local function RecycleRow(r)
        r:Hide(); r:ClearAllPoints()
        r._removeBtn:SetScript("OnClick", nil)
        r._tooltipLink = nil
        table.insert(rowPool, r)
    end

    RebuildList = function()
        for _, r in ipairs(activeRows) do RecycleRow(r) end
        wipe(activeRows)

        local custom = LarlenCacheOpener:GetActiveProfile().custom_items
        if not custom or not next(custom) then
            emptyFS:SetText("No custom items added.")
            emptyFS:Show(); listContent:SetHeight(LIST_H - 6); return
        end

        local items = {}
        local lo = searchStr:lower()
        for id, _ in pairs(custom) do
            local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
            name = name or ("Item " .. tostring(id))
            if lo == "" or name:lower():find(lo, 1, true) then
                items[#items + 1] = { id = id, name = name, icon = icon }
            end
        end

        if #items == 0 then
            emptyFS:SetText(lo ~= "" and ("No results for \"" .. searchStr .. "\".") or "No custom items added.")
            emptyFS:Show(); listContent:SetHeight(LIST_H - 6); return
        end

        emptyFS:Hide()
        table.sort(items, function(a, b) return a.name:lower() < b.name:lower() end)

        local cw = listSF:GetWidth()
        if cw <= 0 then cw = CONTENT_W - 26 end
        listContent:SetWidth(cw)

        local y = 0
        for i, item in ipairs(items) do
            local r = GetOrMakeRow()
            r:SetParent(listContent); r:SetWidth(cw)
            r:SetPoint("TOPLEFT", listContent, 0, y)

            local even = (i % 2 == 0)
            local br, bg, bb = even and 0.06 or 0.04, even and 0.06 or 0.04, even and 0.09 or 0.06
            r._bgR, r._bgG, r._bgB = br, bg, bb
            r:SetBackdropColor(br, bg, bb, 0.90)
            r:SetBackdropBorderColor(0, 0, 0, 0)
            r._icon:SetTexture(item.icon or 134400)
            r._name:SetText(item.name)
            r._idFS:SetText("|cff555560ID " .. tostring(item.id) .. "|r")
            r._tooltipLink = "item:" .. tostring(item.id)

            local capturedID = item.id
            r._removeBtn:SetScript("OnClick", function()
                LarlenCacheOpener:GetActiveProfile().custom_items[capturedID] = nil
                LarlenCacheOpener:updateButtons()
                print("|cffffa500Larlen Cache Opener|r: |cffff0000Removed|r custom item ID", capturedID)
                RebuildList()
            end)

            y = y - ITEM_ROW
            activeRows[#activeRows + 1] = r
        end
        listContent:SetHeight(math.max(math.abs(y), 1))
    end

    local searchCont = CreateFrame("Frame", N("SC"), content, "BackdropTemplate")
    searchCont:SetHeight(ROW_H)
    searchCont:SetPoint("TOPLEFT",  content, 0, yOff)
    searchCont:SetPoint("TOPRIGHT", content, 0, yOff)
    searchCont:SetBackdrop(FLAT_BD)
    searchCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)

    local searchPlaceholder = searchCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchPlaceholder:SetPoint("LEFT", searchCont, 8, 0)
    searchPlaceholder:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    searchPlaceholder:SetText("Search custom items...")

    local searchEB = CreateFrame("EditBox", N("SEB"), searchCont)
    searchEB:SetPoint("LEFT",  searchCont,  8, 0)
    searchEB:SetPoint("RIGHT", searchCont, -8, 0)
    searchEB:SetHeight(ROW_H - 4)
    searchEB:SetAutoFocus(false)
    searchEB:SetFontObject("GameFontNormal")
    searchEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    searchEB:SetMaxLetters(100)
    searchEB:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)

    yOff = yOff - ROW_H
    content:SetHeight(math.abs(yOff) + 10)

    local function SetPreview(itemID, name, icon, rarity, link, isError)
        if isError then
            prevIcon:Hide()
            prevNameFS:SetText("|cffff4444" .. (name or "Invalid item or ID") .. "|r")
            prevCont:SetBackdropColor(0.10, 0.04, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.60, 0.10, 0.10, 0.40)
            pendingID = nil; pendingData = nil
        elseif itemID then
            prevIcon:SetTexture(icon or 134400); prevIcon:Show()
            local _, _, _, hex = C_Item.GetItemQualityColor(rarity or 1)
            local cc = hex and ("|c" .. hex) or "|cffffffff"
            prevNameFS:SetText(cc .. (name or "Unknown") .. "|r  |cff555560(ID " .. tostring(itemID) .. ")|r")
            prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40)
            pendingID = itemID
            pendingData = { name = name, icon = icon }
        else
            prevIcon:Hide(); prevNameFS:SetText("")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0)
            prevCont:SetBackdropBorderColor(0, 0, 0, 0)
            pendingID = nil; pendingData = nil
        end
    end

    local function TryParseInput(text)
        if not text or text:gsub("%s", "") == "" then SetPreview(nil); return end
        local itemID = tonumber(text:match("item:(%d+)")) or tonumber(text:match("^%s*(%d+)%s*$"))
        if not itemID then
            SetPreview(nil, "Not a valid item link or item ID.", nil, nil, nil, true); return
        end
        local name, link, rarity, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
        if name then
            SetPreview(itemID, name, icon, rarity, link)
        else
            prevIcon:Hide()
            prevNameFS:SetText("|cff888888Loading item data...|r")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0.60)
            prevCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
            pendingID = nil; pendingData = nil
            local captured = itemID
            C_Timer.After(0.4, function()
                local cur = addEB:GetText()
                local curID = tonumber(cur:match("item:(%d+)")) or tonumber(cur:match("^%s*(%d+)%s*$"))
                if curID ~= captured then return end
                local n, l, r2, _, _, _, _, _, _, ic = C_Item.GetItemInfo(captured)
                if n then SetPreview(captured, n, ic, r2, l)
                else SetPreview(nil, "Item not found (ID: " .. tostring(captured) .. ").", nil, nil, nil, true) end
            end)
        end
    end

    local function CommitAdd()
        if not pendingID or not pendingData then return end
        if LarlenCacheOpener:IsInMainDB(pendingID) then
            SetPreview(nil, "Item ID " .. pendingID .. " is already in the built-in database.", nil, nil, nil, true)
            return
        end
        LarlenCacheOpener:GetActiveProfile().custom_items = LarlenCacheOpener:GetActiveProfile().custom_items or {}
        LarlenCacheOpener:GetActiveProfile().custom_items[pendingID] = 1
        LarlenCacheOpener:updateButtons()
        print("|cffffa500Larlen Cache Opener|r: |cff00ff00Added|r custom item ID", pendingID)
        addEB:SetText(""); addPlaceholder:Show(); SetPreview(nil)
        searchStr = ""; searchEB:SetText(""); searchPlaceholder:Show()
        RebuildList()
    end

    addEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText()
        addPlaceholder:SetShown(t == "")
        TryParseInput(t)
    end)
    addEB:SetScript("OnEnterPressed", CommitAdd)
    local function HandleDrop(self)
        local dtype, id = GetCursorInfo()
        if dtype == "item" then
            local _, link = C_Item.GetItemInfo(id)
            if link then self:SetText(link); TryParseInput(link) end
            ClearCursor()
        end
    end
    addEB:SetScript("OnReceiveDrag", HandleDrop)
    addEB:SetScript("OnMouseDown",   HandleDrop)
    addEB:SetScript("OnEditFocusGained", function()
        addPlaceholder:Hide()
        addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    end)
    addEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then addPlaceholder:Show() end
        addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    end)

    addBtn:SetScript("OnClick", CommitAdd)

    prevCont:SetScript("OnClick", function() if pendingID then CommitAdd() end end)
    prevCont:SetScript("OnEnter", function()
        if pendingID then
            prevCont:SetBackdropColor(0.08, 0.12, 0.04, 0.90)
            prevCont:SetBackdropBorderColor(0.15, 0.60, 0.10, 0.60)
            GameTooltip:SetOwner(prevCont, "ANCHOR_TOP")
            GameTooltip:SetText("|cff44ff44Click to add custom item|r", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    prevCont:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if pendingID then
            prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80)
            prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40)
        end
    end)

    searchEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText()
        searchStr = t; searchPlaceholder:SetShown(t == "")
        RebuildList()
    end)
    searchEB:SetScript("OnEditFocusGained", function()
        searchPlaceholder:Hide()
        searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.70)
    end)
    searchEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then searchPlaceholder:Show() end
        searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    end)

    win._rebuild = RebuildList
    customWin = win
    C_Timer.After(0, RebuildList)
end

local function OpenCustomItemsWindow()
    if not customWin then BuildCustomItemsWindow() end
    if customWin:IsShown() then
        customWin:Hide()
    else
        customWin:Show()
        if customWin._rebuild then customWin._rebuild() end
    end
end

local function BuildBlacklistWindow()
    if blacklistWin then return end

    local WIN_W = 460
    local WIN_H = 540
    local LIST_H   = 220
    local ITEM_ROW = 28
    local PAD = 12

    local win = CreateFrame("Frame", "LCO_BlacklistWindow", UIParent, "BackdropTemplate")
    win:SetSize(WIN_W, WIN_H)
    win:SetPoint("CENTER", UIParent, "CENTER", 340, 0)
    win:SetBackdrop(FLAT_BD)
    win:SetBackdropColor(0.06, 0.06, 0.09, 0.97)
    win:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.60)
    win:SetFrameStrata("DIALOG")
    win:SetMovable(true); win:EnableMouse(true); win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", win.StartMoving)
    win:SetScript("OnDragStop",  win.StopMovingOrSizing)
    win:SetClampedToScreen(true)
    win:Hide()
    tinsert(UISpecialFrames, "LCO_BlacklistWindow")

    local titleFS = win:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleFS:SetPoint("TOPLEFT", win, PAD, -10)
    titleFS:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    titleFS:SetText("Item Blacklist")

    local titleLine = win:CreateTexture(nil, "ARTWORK")
    titleLine:SetHeight(1)
    titleLine:SetPoint("TOPLEFT",  win, PAD,      -30)
    titleLine:SetPoint("TOPRIGHT", win, -PAD - 28, -30)
    titleLine:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)

    local closeBtn = CreateFrame("Button", N("BLX"), win, "BackdropTemplate")
    closeBtn:SetSize(24, 24); closeBtn:SetPoint("TOPRIGHT", win, -4, -4)
    closeBtn:SetBackdrop(FLAT_BD)
    closeBtn:SetBackdropColor(0.10, 0.10, 0.14, 1)
    closeBtn:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    local xFS = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    xFS:SetPoint("CENTER"); xFS:SetText("×"); xFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    closeBtn:SetScript("OnClick", function() win:Hide() end)
    closeBtn:SetScript("OnEnter", function(s)
        s:SetBackdropColor(0.22, 0.08, 0.08, 1); s:SetBackdropBorderColor(0.90, 0.30, 0.30, 0.80)
        xFS:SetTextColor(1, 0.4, 0.4, 1)
    end)
    closeBtn:SetScript("OnLeave", function(s)
        s:SetBackdropColor(0.10, 0.10, 0.14, 1); s:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
        xFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    end)

    local subFS = win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subFS:SetPoint("TOPLEFT", win, PAD, -36)
    subFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    subFS:SetText("Blacklisted items will never appear in your icon bar.")

    local sf = CreateFrame("ScrollFrame", N("BLSF"), win, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",     win, PAD,      -50)
    sf:SetPoint("BOTTOMRIGHT", win, -PAD - 18, PAD)

    local CONTENT_W = WIN_W - PAD * 2 - 18 - 4
    local content = CreateFrame("Frame", N("BLCH"), sf)
    content:SetWidth(CONTENT_W)
    sf:SetScrollChild(content)

    local yOff = 0
    local searchStr  = ""
    local pendingID  = nil
    local pendingData = nil
    local RebuildBlacklist

    local addCont = CreateFrame("Frame", N("BLADC"), content, "BackdropTemplate")
    addCont:SetHeight(ROW_H)
    addCont:SetPoint("TOPLEFT",  content, 0,   yOff)
    addCont:SetPoint("TOPRIGHT", content, -74, yOff)
    addCont:SetBackdrop(FLAT_BD)
    addCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)

    local addPlaceholder = addCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addPlaceholder:SetPoint("LEFT", addCont, 8, 0)
    addPlaceholder:SetTextColor(DIM[1], DIM[2], DIM[3], 1)
    addPlaceholder:SetText("Drag an item here or type an item ID...")

    local addEB = CreateFrame("EditBox", N("BLAEB"), addCont)
    addEB:SetPoint("LEFT",  addCont,  8, 0); addEB:SetPoint("RIGHT", addCont, -8, 0)
    addEB:SetHeight(ROW_H - 4); addEB:SetAutoFocus(false); addEB:SetFontObject("GameFontNormal")
    addEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1); addEB:SetMaxLetters(200)
    addEB:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)

    local addBtn = MakeBtn(content, "Add", 66, ROW_H)
    addBtn:SetPoint("TOPLEFT", addCont, "TOPRIGHT", 4, 0)

    yOff = yOff - ROW_H - 4

    local prevCont = CreateFrame("Button", N("BLPRC"), content, "BackdropTemplate")
    prevCont:SetHeight(ROW_H)
    prevCont:SetPoint("TOPLEFT",  content, 0, yOff); prevCont:SetPoint("TOPRIGHT", content, 0, yOff)
    prevCont:SetBackdrop(FLAT_BD); prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0)
    prevCont:SetBackdropBorderColor(0, 0, 0, 0); prevCont:EnableMouse(true)

    local prevIcon = prevCont:CreateTexture(nil, "ARTWORK")
    prevIcon:SetSize(20, 20); prevIcon:SetPoint("LEFT", prevCont, 5, 0)
    prevIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93); prevIcon:Hide()

    local prevNameFS = prevCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prevNameFS:SetPoint("LEFT", prevIcon, "RIGHT", 5, 0); prevNameFS:SetPoint("RIGHT", prevCont, -5, 0)
    prevNameFS:SetJustifyH("LEFT"); prevNameFS:SetWordWrap(false)

    yOff = yOff - ROW_H - 4

    local listCont = CreateFrame("Frame", N("BLLC"), content, "BackdropTemplate")
    listCont:SetHeight(LIST_H)
    listCont:SetPoint("TOPLEFT",  content, 0, yOff); listCont:SetPoint("TOPRIGHT", content, 0, yOff)
    listCont:SetBackdrop(FLAT_BD); listCont:SetBackdropColor(0.04, 0.04, 0.06, 1)
    listCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.20)

    yOff = yOff - LIST_H - 4

    local listSF = CreateFrame("ScrollFrame", N("BLLSF"), listCont, "UIPanelScrollFrameTemplate")
    listSF:SetPoint("TOPLEFT",     listCont,  3,  -3); listSF:SetPoint("BOTTOMRIGHT", listCont, -22,  3)

    local listContent = CreateFrame("Frame", N("BLCT"), listSF)
    listSF:SetScrollChild(listContent)

    local emptyFS = listCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyFS:SetPoint("CENTER", listCont, 0, 0); emptyFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1); emptyFS:Hide()

    local activeRows = {}
    local rowPool    = {}

    local function GetOrMakeRow()
        local r = table.remove(rowPool)
        if r then r:Show(); return r end
        r = CreateFrame("Frame", nil, listContent, "BackdropTemplate")
        r:SetHeight(ITEM_ROW); r:SetBackdrop(FLAT_BD)
        local icon = r:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20); icon:SetPoint("LEFT", r, 6, 0); icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        r._icon = icon
        local hover = CreateFrame("Frame", nil, r)
        hover:SetAllPoints(r); hover:SetFrameLevel(r:GetFrameLevel() + 1); hover:EnableMouse(true)
        hover:SetScript("OnEnter", function()
            if r._tooltipLink then
                GameTooltip:SetOwner(r, "ANCHOR_RIGHT"); GameTooltip:SetHyperlink(r._tooltipLink); GameTooltip:Show()
            end
            r:SetBackdropColor(ACCENT[1]*0.15, ACCENT[2]*0.08, ACCENT[3]*0.02, 1)
        end)
        hover:SetScript("OnLeave", function()
            GameTooltip:Hide()
            r:SetBackdropColor(r._bgR or 0.04, r._bgG or 0.04, r._bgB or 0.06, 0.90)
        end)
        local nameFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameFS:SetPoint("LEFT", icon, "RIGHT", 5, 0); nameFS:SetPoint("RIGHT", r, "RIGHT", -76, 0)
        nameFS:SetJustifyH("LEFT"); nameFS:SetWordWrap(false); r._name = nameFS
        local idFS = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        idFS:SetPoint("RIGHT", r, -76, 0); idFS:SetJustifyH("RIGHT")
        idFS:SetTextColor(DIM[1], DIM[2], DIM[3], 1); r._idFS = idFS
        local removeBtn = MakeBtn(r, "Unignore", 66, ITEM_ROW - 6)
        removeBtn:SetPoint("RIGHT", r, -4, 0); removeBtn:SetFrameLevel(r:GetFrameLevel() + 5)
        r._removeBtn = removeBtn
        return r
    end

    local function RecycleRow(r)
        r:Hide(); r:ClearAllPoints(); r._removeBtn:SetScript("OnClick", nil)
        r._tooltipLink = nil; table.insert(rowPool, r)
    end

    RebuildBlacklist = function()
        for _, r in ipairs(activeRows) do RecycleRow(r) end
        wipe(activeRows)
        local ignored = LarlenCacheOpener:GetActiveProfile().ignored_items
        if not ignored or not next(ignored) then
            emptyFS:SetText("No items blacklisted."); emptyFS:Show()
            listContent:SetHeight(LIST_H - 6); return
        end
        local items = {}
        local lo = searchStr:lower()
        for id, blacklisted in pairs(ignored) do
            if blacklisted then
                local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
                name = name or ("Item " .. tostring(id))
                if lo == "" or name:lower():find(lo, 1, true) then
                    items[#items + 1] = { id = id, name = name, icon = icon }
                end
            end
        end
        if #items == 0 then
            emptyFS:SetText(lo ~= "" and ("No results for \"" .. searchStr .. "\".")  or "No items blacklisted.")
            emptyFS:Show(); listContent:SetHeight(LIST_H - 6); return
        end
        emptyFS:Hide()
        table.sort(items, function(a, b) return a.name:lower() < b.name:lower() end)
        local cw = listSF:GetWidth()
        if cw <= 0 then cw = CONTENT_W - 26 end
        listContent:SetWidth(cw)
        local y = 0
        for i, item in ipairs(items) do
            local r = GetOrMakeRow()
            r:SetParent(listContent); r:SetWidth(cw); r:SetPoint("TOPLEFT", listContent, 0, y)
            local even = (i % 2 == 0)
            local br, bg, bb = even and 0.06 or 0.04, even and 0.06 or 0.04, even and 0.09 or 0.06
            r._bgR, r._bgG, r._bgB = br, bg, bb
            r:SetBackdropColor(br, bg, bb, 0.90); r:SetBackdropBorderColor(0, 0, 0, 0)
            r._icon:SetTexture(item.icon or 134400); r._name:SetText(item.name)
            r._idFS:SetText("|cff555560ID " .. tostring(item.id) .. "|r")
            r._tooltipLink = "item:" .. tostring(item.id)
            local capturedID = item.id
            r._removeBtn:SetScript("OnClick", function()
                LarlenCacheOpener:GetActiveProfile().ignored_items[capturedID] = false
                LarlenCacheOpener:updateIgnoreItems(); LarlenCacheOpener:updateButtons()
                print("|cffffa500Larlen Cache Opener|r: |cff00ff00Un-ignoring|r item ID", capturedID)
                RebuildBlacklist()
            end)
            y = y - ITEM_ROW; activeRows[#activeRows + 1] = r
        end
        listContent:SetHeight(math.max(math.abs(y), 1))
    end

    local searchCont = CreateFrame("Frame", N("BLSC"), content, "BackdropTemplate")
    searchCont:SetHeight(ROW_H)
    searchCont:SetPoint("TOPLEFT",  content, 0, yOff); searchCont:SetPoint("TOPRIGHT", content, 0, yOff)
    searchCont:SetBackdrop(FLAT_BD); searchCont:SetBackdropColor(0.06, 0.06, 0.09, 1)
    searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)

    local searchPlaceholder = searchCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchPlaceholder:SetPoint("LEFT", searchCont, 8, 0)
    searchPlaceholder:SetTextColor(DIM[1], DIM[2], DIM[3], 1); searchPlaceholder:SetText("Search blacklisted items...")

    local searchEB = CreateFrame("EditBox", N("BLSEB"), searchCont)
    searchEB:SetPoint("LEFT",  searchCont,  8, 0); searchEB:SetPoint("RIGHT", searchCont, -8, 0)
    searchEB:SetHeight(ROW_H - 4); searchEB:SetAutoFocus(false); searchEB:SetFontObject("GameFontNormal")
    searchEB:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1); searchEB:SetMaxLetters(100)
    searchEB:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)

    yOff = yOff - ROW_H
    content:SetHeight(math.abs(yOff) + 10)

    local function SetPreview(itemID, name, icon, rarity, link, isError)
        if isError then
            prevIcon:Hide(); prevNameFS:SetText("|cffff4444" .. (name or "Invalid item or ID") .. "|r")
            prevCont:SetBackdropColor(0.10, 0.04, 0.04, 0.80); prevCont:SetBackdropBorderColor(0.60, 0.10, 0.10, 0.40)
            pendingID = nil; pendingData = nil
        elseif itemID then
            prevIcon:SetTexture(icon or 134400); prevIcon:Show()
            local _, _, _, hex = C_Item.GetItemQualityColor(rarity or 1)
            local cc = hex and ("|c" .. hex) or "|cffffffff"
            prevNameFS:SetText(cc .. (name or "Unknown") .. "|r  |cff555560(ID " .. tostring(itemID) .. ")|r")
            prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80); prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40)
            pendingID = itemID; pendingData = { name = name, icon = icon }
        else
            prevIcon:Hide(); prevNameFS:SetText("")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0); prevCont:SetBackdropBorderColor(0, 0, 0, 0)
            pendingID = nil; pendingData = nil
        end
    end

    local function TryParseInput(text)
        if not text or text:gsub("%s", "") == "" then SetPreview(nil); return end
        local itemID = tonumber(text:match("item:(%d+)")) or tonumber(text:match("^%s*(%d+)%s*$"))
        if not itemID then SetPreview(nil, "Not a valid item link or item ID.", nil, nil, nil, true); return end
        local name, link, rarity, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
        if name then
            SetPreview(itemID, name, icon, rarity, link)
        else
            prevIcon:Hide(); prevNameFS:SetText("|cff888888Loading item data...|r")
            prevCont:SetBackdropColor(0.04, 0.04, 0.06, 0.60); prevCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.25)
            pendingID = nil; pendingData = nil
            local captured = itemID
            C_Timer.After(0.4, function()
                local cur = addEB:GetText()
                local curID = tonumber(cur:match("item:(%d+)")) or tonumber(cur:match("^%s*(%d+)%s*$"))
                if curID ~= captured then return end
                local n, l, r2, _, _, _, _, _, _, ic = C_Item.GetItemInfo(captured)
                if n then SetPreview(captured, n, ic, r2, l)
                else SetPreview(nil, "Item not found (ID: " .. tostring(captured) .. ").", nil, nil, nil, true) end
            end)
        end
    end

    local function CommitAdd()
        if not pendingID or not pendingData then return end
        LarlenCacheOpener:GetActiveProfile().ignored_items[pendingID] = true
        LarlenCacheOpener:updateIgnoreItems(); LarlenCacheOpener:updateButtons()
        print("|cffffa500Larlen Cache Opener|r: |cffff0000Ignoring|r item ID", pendingID)
        addEB:SetText(""); addPlaceholder:Show(); SetPreview(nil)
        searchStr = ""; searchEB:SetText(""); searchPlaceholder:Show()
        RebuildBlacklist()
    end

    addEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText(); addPlaceholder:SetShown(t == ""); TryParseInput(t)
    end)
    addEB:SetScript("OnEnterPressed", CommitAdd)
    local function HandleDrop(self)
        local dtype, id = GetCursorInfo()
        if dtype == "item" then
            local _, link = C_Item.GetItemInfo(id)
            if link then self:SetText(link); TryParseInput(link) end
            ClearCursor()
        end
    end
    addEB:SetScript("OnReceiveDrag", HandleDrop); addEB:SetScript("OnMouseDown", HandleDrop)
    addEB:SetScript("OnEditFocusGained", function()
        addPlaceholder:Hide(); addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.90)
    end)
    addEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then addPlaceholder:Show() end
        addCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.45)
    end)
    addBtn:SetScript("OnClick", CommitAdd)
    prevCont:SetScript("OnClick", function() if pendingID then CommitAdd() end end)
    prevCont:SetScript("OnEnter", function()
        if pendingID then
            prevCont:SetBackdropColor(0.08, 0.12, 0.04, 0.90); prevCont:SetBackdropBorderColor(0.15, 0.60, 0.10, 0.60)
            GameTooltip:SetOwner(prevCont, "ANCHOR_TOP"); GameTooltip:SetText("|cffff4444Click to blacklist item|r", 1, 1, 1, 1, true); GameTooltip:Show()
        end
    end)
    prevCont:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if pendingID then prevCont:SetBackdropColor(0.04, 0.08, 0.04, 0.80); prevCont:SetBackdropBorderColor(0.10, 0.50, 0.10, 0.40) end
    end)
    searchEB:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local t = self:GetText(); searchStr = t; searchPlaceholder:SetShown(t == ""); RebuildBlacklist()
    end)
    searchEB:SetScript("OnEditFocusGained", function()
        searchPlaceholder:Hide(); searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.70)
    end)
    searchEB:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then searchPlaceholder:Show() end
        searchCont:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    end)

    win._rebuild = RebuildBlacklist
    blacklistWin = win
    C_Timer.After(0, RebuildBlacklist)
end

local function OpenBlacklistWindow()
    if not blacklistWin then BuildBlacklistWindow() end
    if blacklistWin:IsShown() then
        blacklistWin:Hide()
    else
        blacklistWin:Show()
        if blacklistWin._rebuild then blacklistWin._rebuild() end
    end
end

-----------------------------------------
-- AceConfig Options Table
-----------------------------------------
local function BuildOptions()
    local soundValues = {}
    for i, s in ipairs(LarlenCacheOpener.sounds) do soundValues[i] = s.name end

    local alignValues = { RIGHT="Grow Right", LEFT="Grow Left", UP="Grow Up", DOWN="Grow Down" }

    local function GetProfileNames()
        local t = {}
        for _, n in ipairs(LarlenCacheOpener:GetProfileNames()) do t[n] = n end
        return t
    end

    local function GetGroupToggles()
        local args = {}
        for i, name in ipairs(LarlenCacheOpener.group_ids_ordered) do
            local n = name
            args["group_" .. n] = {
                order = i, type = "toggle", name = L[n] or n,
                get   = function()
                    local ig = LarlenCacheOpener:GetActiveProfile().ignored_groups
                    return ig and ig[n] == true
                end,
                set   = function(_, v)
                    LarlenCacheOpener:GetActiveProfile().ignored_groups[n] = v
                    LarlenCacheOpener:updateIgnoreItems()
                    LarlenCacheOpener:updateButtons()
                end,
            }
        end
        return args
    end

    return {
        name = "Larlen Cache Opener", type = "group",
        args = {
            generalHeader = { order=1, type="header", name="General Settings" },
            playSound = {
                order=2, type="toggle", name="Play sound when an item appears",
                get=function() return GetP("playSound") end,
                set=function(_, v) SetP("playSound", v) end,
            },
            soundChoice = {
                order=3, type="select", name="Select Sound", values=soundValues,
                get=function() return GetP("soundChoice") or 1 end,
                set=function(_, v) SetP("soundChoice", v); PlaySound(LarlenCacheOpener.sounds[v].id, "Master") end,
            },
            hideInCombat = {
                order=4, type="toggle", name="Hide icons while in combat",
                get=function() return GetP("hideInCombat") end,
                set=function(_, v) SetP("hideInCombat", v); LarlenCacheOpener:UpdateCombatState() end,
            },
            showMinimap = {
                order=5, type="toggle", name="Show Minimap Icon",
                get=function() return GetP("showMinimap") ~= false end,
                set=function(_, v) SetP("showMinimap", v); LarlenCacheOpener:UpdateMinimapVisibility() end,
            },
            showGlow = {
                order=6, type="toggle", name="Show Action Button Glow",
                get=function() return GetP("showGlow") end,
                set=function(_, v) SetP("showGlow", v); if testActive then LarlenCacheOpener:ShowTestIcons(5) else LarlenCacheOpener:updateButtons() end end,
            },

            appearanceHeader = { order=10, type="header", name="Appearance & Position" },
            iconSize = {
                order=11, type="range", name="Icon Size", min=16, max=64, step=1,
                get=function() return GetP("iconSize") or 36 end,
                set=function(_, v) SetP("iconSize", v); if testActive then LarlenCacheOpener:ShowTestIcons(5) else LarlenCacheOpener:updateButtons() end end,
            },
            alignment = {
                order=12, type="select", name="Growth Direction", values=alignValues,
                get=function() return GetP("alignment") or "RIGHT" end,
                set=function(_, v) SetP("alignment", v); if testActive then LarlenCacheOpener:ShowTestIcons(5) else LarlenCacheOpener:updateButtons() end end,
            },
            alpha = {
                order=13, type="range", name="Transparency", min=10, max=100, step=1,
                get=function() return math.floor((GetP("alpha") or 1.0) * 100 + 0.5) end,
                set=function(_, v) SetP("alpha", v/100); if testActive then LarlenCacheOpener:ShowTestIcons(5) else LarlenCacheOpener:updateButtons() end end,
            },
            xPos = {
                order=14, type="range", name="X Position", desc="Offset from center. 0 = center.", min=-960, max=960, step=1,
                get=function()
                    local pos = LarlenCacheOpener:GetActiveProfile().position
                    return pos and pos[4] and math.floor(pos[4] - GetScreenWidth()/2 + 0.5) or 0
                end,
                set=function(_, v)
                    local p = LarlenCacheOpener:GetActiveProfile()
                    if not p.position then p.position = {"BOTTOMLEFT",nil,"BOTTOMLEFT",GetScreenWidth()/2,GetScreenHeight()/2} end
                    p.position[4] = GetScreenWidth()/2 + v
                    LarlenCacheOpener:updateButtons()
                end,
            },
            yPos = {
                order=15, type="range", name="Y Position", desc="Offset from center. 0 = center.", min=-540, max=540, step=1,
                get=function()
                    local pos = LarlenCacheOpener:GetActiveProfile().position
                    return pos and pos[5] and math.floor(pos[5] - GetScreenHeight()/2 + 0.5) or 0
                end,
                set=function(_, v)
                    local p = LarlenCacheOpener:GetActiveProfile()
                    if not p.position then p.position = {"BOTTOMLEFT",nil,"BOTTOMLEFT",GetScreenWidth()/2,GetScreenHeight()/2} end
                    p.position[5] = GetScreenHeight()/2 + v
                    LarlenCacheOpener:updateButtons()
                end,
            },
            resetPosition = {
                order=16, type="execute", name="Reset Position",
                func=function()
                    local p = LarlenCacheOpener:GetActiveProfile()
                    p.position = {"BOTTOMLEFT",nil,"BOTTOMLEFT",GetScreenWidth()/2,GetScreenHeight()/2}
                    if testActive then LarlenCacheOpener:ShowTestIcons(5) else LarlenCacheOpener:updateButtons() end
                    NotifyChange()
                end,
            },
            testIcons = {
                order=17, type="execute",
                name=function() return testActive and "Hide Test Icons" or "Test Icons" end,
                func=function()
                    testActive = not testActive
                    if testActive then LarlenCacheOpener:ShowTestIcons(5) else LarlenCacheOpener:updateButtons() end
                    NotifyChange()
                end,
            },
            locked = {
                order=18, type="toggle", name="Lock Position",
                get=function() return GetP("locked") end,
                set=function(_, v) SetP("locked", v) end,
            },

            profileHeader = { order=20, type="header", name="Profiles" },
            activeProfile = {
                order=21, type="select", name="Active Profile", values=GetProfileNames,
                get=function() return LarlenCacheOpenerProfiles and LarlenCacheOpenerProfiles.activeProfile or "Default" end,
                set=function(_, v) LarlenCacheOpener:SwitchProfile(v); NotifyChange() end,
            },
            profileName = {
                order=22, type="input", name="Add New Profile",
                desc="Type a name and press Enter to create a new blank profile.",
                get=function() return profileNameInput end,
                set=function(_, v)
                    profileNameInput = v
                    if profileNameInput ~= "" then
                        if LarlenCacheOpener:CreateProfile(profileNameInput, false) then
                            LarlenCacheOpener:SwitchProfile(profileNameInput)
                            profileNameInput = ""; NotifyChange()
                        end
                    end
                end,
            },
            copyProfile = {
                order=24, type="execute", name="Copy",
                func=function()
                    if profileNameInput ~= "" then
                        if LarlenCacheOpener:CreateProfile(profileNameInput, true) then
                            LarlenCacheOpener:SwitchProfile(profileNameInput)
                            profileNameInput = ""; NotifyChange()
                        end
                    end
                end,
            },
            deleteProfile = {
                order=25, type="execute", name="Delete Active Profile",
                func=function()
                    local active = LarlenCacheOpenerProfiles and LarlenCacheOpenerProfiles.activeProfile or "Default"
                    LarlenCacheOpener:DeleteProfile(active); NotifyChange()
                end,
            },

            categoriesHeader = { order=30, type="header", name="Hidden Item Categories" },
            categories = {
                order=31, type="group", name="Categories", inline=true,
                args=GetGroupToggles(),
            },

            customHeader = { order=40, type="header", name="Custom Items" },
            customDesc = {
                order=41, type="description",
                name="Add or remove custom item IDs not in the built-in database.",
            },
            openCustomItems = {
                order=42, type="execute", name="Manage Custom Items",
                desc="Open the custom items window to add, remove, and search custom item IDs.",
                func=function() OpenCustomItemsWindow() end,
            },

            blacklistHeader = { order=50, type="header", name="Item Blacklist" },
            blacklistDesc = {
                order=51, type="description",
                name="Blacklisted items will never appear in your icon bar. You can also Shift+Right-Click any icon to instantly blacklist it.",
            },
            openBlacklist = {
                order=52, type="execute", name="Manage Blacklist",
                desc="Open the blacklist window to add, remove, and search ignored items.",
                func=function() OpenBlacklistWindow() end,
            },

            creditsHeader = { order=60, type="header", name="Credits" },
            creditsDesc = {
                order=61, type="description",
                name="Type /lco for commands.\n\n|cffffa500Massive thanks and all original credit to nerino1 (Soulbind Cache Opener) and Tamuko (Soulbind Cache Opener Continued) for creating the amazing foundation this addon is built upon.|r",
            },
        },
    }
end

-----------------------------------------
-- Test Icons
-----------------------------------------
function LarlenCacheOpener:ShowTestIcons(count)
    self:updateButtons()
    if count <= 0 then return end
    local iconSize = self:P("iconSize") or 36
    local spacing  = 2
    local align    = self:P("alignment") or "RIGHT"
    if align == "RIGHT" or align == "LEFT" then
        self.frame:SetWidth(count * iconSize + (count - 1) * spacing)
        self.frame:SetHeight(iconSize)
    else
        self.frame:SetWidth(iconSize)
        self.frame:SetHeight(count * iconSize + (count - 1) * spacing)
    end
    local pos = self:GetActiveProfile().position
    local b1x = pos and pos[4] or (GetScreenWidth() / 2)
    local b1y = pos and pos[5] or (GetScreenHeight() / 2)
    self.frame:ClearAllPoints()
    if     align == "RIGHT" then self.frame:SetPoint("LEFT",   UIParent, "BOTTOMLEFT", b1x - iconSize/2, b1y)
    elseif align == "LEFT"  then self.frame:SetPoint("RIGHT",  UIParent, "BOTTOMLEFT", b1x + iconSize/2, b1y)
    elseif align == "DOWN"  then self.frame:SetPoint("TOP",    UIParent, "BOTTOMLEFT", b1x, b1y + iconSize/2)
    else                         self.frame:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", b1x, b1y - iconSize/2) end
    self.frame:Show()
    for i = 1, count do
        local btn = self.buttons[i]
        btn:ClearAllPoints(); btn:SetWidth(iconSize); btn:SetHeight(iconSize)
        if     align == "LEFT" then
            if i==1 then btn:SetPoint("RIGHT",  self.frame,        "RIGHT",  0, 0)
            else         btn:SetPoint("RIGHT",  self.buttons[i-1], "LEFT",  -spacing, 0) end
        elseif align == "UP" then
            if i==1 then btn:SetPoint("BOTTOM", self.frame,        "BOTTOM", 0, 0)
            else         btn:SetPoint("BOTTOM", self.buttons[i-1], "TOP",    0, spacing) end
        elseif align == "DOWN" then
            if i==1 then btn:SetPoint("TOP",    self.frame,        "TOP",    0, 0)
            else         btn:SetPoint("TOP",    self.buttons[i-1], "BOTTOM", 0, -spacing) end
        else
            if i==1 then btn:SetPoint("LEFT",   self.frame,        "LEFT",   0, 0)
            else         btn:SetPoint("LEFT",   self.buttons[i-1], "RIGHT",  spacing, 0) end
        end
        btn.icon:SetTexture(132596); btn.countString:SetText("99"); btn.texture:SetDesaturated(false)
        btn:SetAlpha(self:P("alpha") or 1.0)
        if self:P("showGlow") then self:ShowGlow(btn) else self:HideGlow(btn) end
        btn:Show()
    end
end

-----------------------------------------
-- Register & Open
-----------------------------------------
function LarlenCacheOpener:initializeOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("LarlenCacheOpener", BuildOptions)
    local ACD = LibStub("AceConfigDialog-3.0")
    ACD:AddToBlizOptions("LarlenCacheOpener", "Larlen Cache Opener")
    ACD:SetDefaultSize("LarlenCacheOpener", 680, 600)
end

function LarlenCacheOpener:OpenOptions()
    LibStub("AceConfigDialog-3.0"):Open("LarlenCacheOpener")
end

function LarlenCacheOpener:RefreshOptionsPanelValues()
    LibStub("AceConfigRegistry-3.0"):NotifyChange("LarlenCacheOpener")
end

function LarlenCacheOpener:updateOptionCheckbox(group_id, state)
    if LarlenCacheOpener.option_buttons[group_id] ~= nil then
        LarlenCacheOpener.option_buttons[group_id]:SetChecked(state)
    end
end

L["hidden_groups"]      = "Hidden Item Categories"
L["addon_name"]         = "Larlen Cache Opener"
L["option_description"] = "Type /lco for commands.\n\n|cffffa500Credits: nerino1 (original Soulbind Cache Opener) & Tamuko (Continued).|r"
