local LOT = LarlenOverloadTracker
local isRefreshing = false

local PANEL_W   = 600
local COL_LEFT  = 15
local COL_DIV   = 290
local COL_RIGHT = 306

local function HLine(parent, x, y, width, alpha)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetColorTexture(1, 1, 1, alpha or 0.15)
    t:SetSize(width, 1)
    t:SetPoint("TOPLEFT", x, y)
end

local function VLine(parent, x, y, height)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetColorTexture(1, 1, 1, 0.10)
    t:SetSize(1, height)
    t:SetPoint("TOPLEFT", x, y)
end

local function SectionLabel(parent, text, x, y)
    local t = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    t:SetPoint("TOPLEFT", x, y)
    t:SetText(text)
    t:SetTextColor(1, 1, 1)
    return t
end

function LOT:InitializeOptions()
    local db = self.db

    local panel = CreateFrame("Frame")
    panel.name  = "Larlen Overload Tracker"
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Larlen Overload Tracker")
    LOT.category   = category
    Settings.RegisterAddOnCategory(category)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", COL_LEFT, -15)
    title:SetText("Larlen Overload Tracker")
    title:SetTextColor(1.0, 0.82, 0.0)

    HLine(panel, COL_LEFT, -44, PANEL_W - COL_LEFT * 2)

    VLine(panel, COL_DIV, -44, 520)

    local LEFT_W = COL_DIV - COL_LEFT - 10

    SectionLabel(panel, "General Settings", COL_LEFT, -56)

    local combatCb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    combatCb:SetPoint("TOPLEFT", COL_LEFT, -80)
    combatCb.Text:SetText(" Show icon while in combat")
    combatCb:HookScript("OnClick", function(self)
        db.showInCombat = self:GetChecked()
        if not db.showInCombat and InCombatLockdown() then LOT:HideIcon() end
    end)

    local minimapCb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    minimapCb:SetPoint("TOPLEFT", COL_LEFT, -108)
    minimapCb.Text:SetText(" Show Minimap icon")
    minimapCb:HookScript("OnClick", function(self)
        db.showMinimap = self:GetChecked()
        LOT:UpdateMinimapVisibility()
    end)

    HLine(panel, COL_LEFT, -144, LEFT_W)
    SectionLabel(panel, "Appearance", COL_LEFT, -154)

    local sizeSlider = CreateFrame("Slider", "LOT_SizeSlider", panel, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT", COL_LEFT + 5, -194)
    sizeSlider:SetMinMaxValues(16, 64)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    _G["LOT_SizeSliderLow"]:SetText("16")
    _G["LOT_SizeSliderHigh"]:SetText("64")
    _G["LOT_SizeSliderText"]:SetText("Icon Size")

    local sizeInput = CreateFrame("EditBox", "LOT_SizeInput", panel, "InputBoxTemplate")
    sizeInput:SetSize(42, 20)
    sizeInput:SetPoint("LEFT", sizeSlider, "RIGHT", 12, 0)
    sizeInput:SetAutoFocus(false)
    sizeInput:SetNumeric(true)

    sizeSlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        db.iconSize = val
        sizeInput:SetText(tostring(val))
        LOT:RefreshIcon()
    end)
    sizeInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then sizeSlider:SetValue(math.max(16, math.min(64, val))) end
        self:ClearFocus()
    end)
    sizeInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local alphaSlider = CreateFrame("Slider", "LOT_AlphaSlider", panel, "OptionsSliderTemplate")
    alphaSlider:SetPoint("TOPLEFT", COL_LEFT + 5, -248)
    alphaSlider:SetMinMaxValues(10, 100)
    alphaSlider:SetValueStep(1)
    alphaSlider:SetObeyStepOnDrag(true)
    _G["LOT_AlphaSliderLow"]:SetText("10%")
    _G["LOT_AlphaSliderHigh"]:SetText("100%")
    _G["LOT_AlphaSliderText"]:SetText("Opacity")

    local alphaInput = CreateFrame("EditBox", "LOT_AlphaInput", panel, "InputBoxTemplate")
    alphaInput:SetSize(42, 20)
    alphaInput:SetPoint("LEFT", alphaSlider, "RIGHT", 12, 0)
    alphaInput:SetAutoFocus(false)
    alphaInput:SetNumeric(true)

    alphaSlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        db.alpha = val / 100
        alphaInput:SetText(tostring(val))
        LOT:RefreshIcon()
    end)
    alphaInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then alphaSlider:SetValue(math.max(10, math.min(100, val))) end
        self:ClearFocus()
    end)
    alphaInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local offsetXSlider = CreateFrame("Slider", "LOT_OffsetXSlider", panel, "OptionsSliderTemplate")
    offsetXSlider:SetPoint("TOPLEFT", COL_LEFT + 5, -302)
    offsetXSlider:SetMinMaxValues(-150, 150)
    offsetXSlider:SetValueStep(1)
    offsetXSlider:SetObeyStepOnDrag(true)
    _G["LOT_OffsetXSliderLow"]:SetText("-150")
    _G["LOT_OffsetXSliderHigh"]:SetText("150")
    _G["LOT_OffsetXSliderText"]:SetText("Cursor Offset X")

    local offsetXInput = CreateFrame("EditBox", "LOT_OffsetXInput", panel, "InputBoxTemplate")
    offsetXInput:SetSize(42, 20)
    offsetXInput:SetPoint("LEFT", offsetXSlider, "RIGHT", 12, 0)
    offsetXInput:SetAutoFocus(false)
    offsetXInput:SetNumeric(false)

    offsetXSlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        db.offsetX = val
        offsetXInput:SetText(tostring(val))
    end)
    offsetXInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then offsetXSlider:SetValue(math.max(-150, math.min(150, val))) end
        self:ClearFocus()
    end)
    offsetXInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local offsetYSlider = CreateFrame("Slider", "LOT_OffsetYSlider", panel, "OptionsSliderTemplate")
    offsetYSlider:SetPoint("TOPLEFT", COL_LEFT + 5, -356)
    offsetYSlider:SetMinMaxValues(-150, 150)
    offsetYSlider:SetValueStep(1)
    offsetYSlider:SetObeyStepOnDrag(true)
    _G["LOT_OffsetYSliderLow"]:SetText("-150")
    _G["LOT_OffsetYSliderHigh"]:SetText("150")
    _G["LOT_OffsetYSliderText"]:SetText("Cursor Offset Y")

    local offsetYInput = CreateFrame("EditBox", "LOT_OffsetYInput", panel, "InputBoxTemplate")
    offsetYInput:SetSize(42, 20)
    offsetYInput:SetPoint("LEFT", offsetYSlider, "RIGHT", 12, 0)
    offsetYInput:SetAutoFocus(false)
    offsetYInput:SetNumeric(false)

    offsetYSlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        db.offsetY = val
        offsetYInput:SetText(tostring(val))
    end)
    offsetYInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then offsetYSlider:SetValue(math.max(-150, math.min(150, val))) end
        self:ClearFocus()
    end)
    offsetYInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetSize(120, 22)
    resetBtn:SetPoint("TOPLEFT", COL_LEFT + 5, -400)
    resetBtn:SetText("Reset Offset")
    resetBtn:SetScript("OnClick", function()
        db.offsetX = 0
        db.offsetY = 0
        offsetXSlider:SetValue(0)
        offsetYSlider:SetValue(0)
    end)

    local testBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testBtn:SetSize(120, 22)
    testBtn:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
    testBtn:SetText("Test Icon")
    local testActive = false
    testBtn:SetScript("OnClick", function()
        testActive = not testActive
        if testActive then
            testBtn:SetText("Stop Test")
            local mod = LOT.modules[1]
            for _, m in ipairs(LOT.modules) do
                if m._known and m._icon then mod = m; break end
            end
            LOT.iconFrame:SetSize(db.iconSize, db.iconSize)
            LOT.iconFrame:SetAlpha(db.alpha)
            LOT.iconFrame.tex:SetTexture(mod._icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            LOT.iconFrame.chargeLabel:Hide()
            LOT:RefreshIcon()
            LOT.iconFrame:Show()
        else
            testBtn:SetText("Test Icon")
            LOT:HideIcon()
        end
    end)
    panel:HookScript("OnHide", function()
        if testActive then
            testActive = false
            testBtn:SetText("Test Icon")
            LOT:HideIcon()
        end
    end)

    local RIGHT_W = PANEL_W - COL_RIGHT - COL_LEFT

    SectionLabel(panel, "Active Modules", COL_RIGHT, -56)

    local moduleGroups = {
        { header = "Dragonflight",   ids = {"mining_df",       "herb_df"} },
        { header = "The War Within", ids = {"mining_tww",      "herb_tww",      "skinning_tww"} },
        { header = "Midnight",       ids = {"mining_midnight", "herb_midnight", "skinning_midnight"} },
    }

    local shortName = {}
    for _, mod in ipairs(LOT.modules) do
        shortName[mod.id] = mod.label:match("^([^%(]+)"):trim()
    end

    LOT.moduleCbs = {}
    local y = -84

    for i, group in ipairs(moduleGroups) do
        if i > 1 then
            HLine(panel, COL_RIGHT + 4, y + 4, RIGHT_W - 8, 0.08)
            y = y - 12
        end

        local bg = panel:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(0.12, 0.10, 0.02, 0.7)
        bg:SetSize(RIGHT_W, 22)
        bg:SetPoint("TOPLEFT", COL_RIGHT, y)

        local hdr = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        hdr:SetPoint("TOPLEFT", COL_RIGHT + 6, y - 3)
        hdr:SetText(group.header)
        hdr:SetTextColor(1.0, 0.82, 0.0)
        y = y - 28

        for _, modID in ipairs(group.ids) do
            local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            cb:SetPoint("TOPLEFT", COL_RIGHT + 4, y)
            cb.Text:SetText(" " .. (shortName[modID] or modID))
            cb.moduleID = modID
            cb:HookScript("OnClick", function(self)
                db.modules[self.moduleID] = self:GetChecked()
            end)
            LOT.moduleCbs[modID] = cb
            y = y - 24
        end

        y = y - 6
    end

    local footer = panel:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
    footer:SetPoint("TOPLEFT", COL_LEFT, -560)
    footer:SetWidth(PANEL_W - COL_LEFT * 2)
    footer:SetJustifyH("LEFT")
    footer:SetText("Type /lot for commands.\nAddon inspired by WeakAura made by |cFF00FF7FMarkiv|r")

    local function Refresh()
        if not db then return end
        isRefreshing = true
        combatCb:SetChecked(db.showInCombat ~= false)
        minimapCb:SetChecked(db.showMinimap ~= false)
        sizeSlider:SetValue(db.iconSize or 32)
        sizeInput:SetText(tostring(db.iconSize or 32))
        local av = math.floor((db.alpha or 1.0) * 100)
        alphaSlider:SetValue(av)
        alphaInput:SetText(tostring(av))
        offsetXSlider:SetValue(db.offsetX or 0)
        offsetXInput:SetText(tostring(db.offsetX or 0))
        offsetYSlider:SetValue(db.offsetY or 0)
        offsetYInput:SetText(tostring(db.offsetY or 0))
        for modID, cb in pairs(LOT.moduleCbs) do
            cb:SetChecked(db.modules[modID] ~= false)
        end
        isRefreshing = false
    end

    LOT.RefreshOptionsPanelValues = Refresh
    panel:HookScript("OnShow", Refresh)
end

function LOT:InitializeMinimap()
    local db = self.db

    local ldbData = {
        type  = "launcher",
        label = "Larlen Overload Tracker",
        icon  = 4554453,
        OnClick = function(_, btn)
            if btn == "LeftButton" then
                LOT.OpenOptions()
            elseif btn == "RightButton" then
                db.showMinimap = false
                LOT:UpdateMinimapVisibility()
                print("|cFF00FF7FLarlen Overload Tracker|r: Minimap hidden. /lot minimap to restore.")
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("Larlen Overload Tracker", 1, 0.82, 0)
            tt:AddLine(" ")
            tt:AddLine("|cFF00FF7FLeft-Click|r Open settings", 1, 1, 1)
            tt:AddLine("|cFF00FF7FRight-Click|r Hide minimap button", 1, 1, 1)
            tt:AddLine("|cFF00FF7FDrag|r Move button", 1, 1, 1)
        end,
    }

    local lib = LibStub("LibDataBroker-1.1")
    local ldb = lib:GetDataObjectByName("LarlenOverloadTracker")
            or  lib:NewDataObject("LarlenOverloadTracker", ldbData)
    if ldb then
        ldb.OnClick       = ldbData.OnClick
        ldb.OnTooltipShow = ldbData.OnTooltipShow
        ldb.icon          = ldbData.icon
    end

    LOT.ldbi = LibStub("LibDBIcon-1.0")
    LOT.ldb  = ldb

    LarlenOverloadTrackerDB.minimapPos = LarlenOverloadTrackerDB.minimapPos or db.minimapPos or 225
    LarlenOverloadTrackerDB.hide       = not db.showMinimap

    C_Timer.After(0, function()
        if not LOT.ldbi:IsRegistered("LarlenOverloadTracker") then
            LOT.ldbi:Register("LarlenOverloadTracker", LOT.ldb, LarlenOverloadTrackerDB)
        end
        LOT:UpdateMinimapVisibility()
    end)
end

function LOT:UpdateMinimapVisibility()
    if not self.ldbi or not self.ldbi:IsRegistered("LarlenOverloadTracker") then return end
    if LOT.db.showMinimap ~= false then
        LarlenOverloadTrackerDB.hide = false
        self.ldbi:Show("LarlenOverloadTracker")
    else
        LarlenOverloadTrackerDB.hide = true
        self.ldbi:Hide("LarlenOverloadTracker")
    end
end
