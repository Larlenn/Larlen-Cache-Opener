local _, L = ...;

LarlenCacheOpener.option_buttons = {};
local testActive = false;
local isRefreshing = false; -- guard to stop sliders firing OnValueChanged during RefreshPanelValues

local directions = {
    {name = "Grow Right", value = "RIGHT"},
    {name = "Grow Left", value = "LEFT"},
    {name = "Grow Up", value = "UP"},
    {name = "Grow Down", value = "DOWN"}
}

-----------------------------------------
-- UI BUILDER HELPER FUNCTIONS
-----------------------------------------
local function CreateTitle(parent, text, x, y)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", x, y)
    title:SetText(text)
    title:SetTextColor(1.0, 0.82, 0.0)
    return title
end

local function CreateSectionHeader(parent, text, x, y)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", x, y)
    header:SetText(text)
    header:SetTextColor(1.0, 1.0, 1.0)
    return header
end

local function CreateSeparator(parent, yOffset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.15)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 15, yOffset)
    line:SetPoint("TOPRIGHT", -15, yOffset)
    return line
end

function LarlenCacheOpener:initializeOptions() 
    local panel = CreateFrame("Frame");
    panel.name = L["addon_name"];
    local category = Settings.RegisterCanvasLayoutCategory(panel, L["addon_name"]);
    LarlenCacheOpener.category = category; 
    Settings.RegisterAddOnCategory(category);

    -- Main Title
    CreateTitle(panel, L["addon_name"], 15, -15)

    local function ToggleTestIcons(count)
        LarlenCacheOpener:updateButtons() 
        if count > 0 then
            LarlenCacheOpener.frame:Show()
            local iconSize = LarlenCacheOpener:P("iconSize") or 38
            for i = 1, count do
                local btn = LarlenCacheOpener.buttons[i]
                btn:ClearAllPoints()
                btn:SetWidth(iconSize)
                btn:SetHeight(iconSize)
                
                local spacing = 2
                local align = LarlenCacheOpener:P("alignment") or "RIGHT"

                if align == "LEFT" then
                    if i == 1 then btn:SetPoint("RIGHT", LarlenCacheOpener.frame, "RIGHT", 0, 0)
                    else btn:SetPoint("RIGHT", LarlenCacheOpener.buttons[i-1], "LEFT", -spacing, 0) end
                elseif align == "UP" then
                    if i == 1 then btn:SetPoint("BOTTOM", LarlenCacheOpener.frame, "BOTTOM", 0, 0)
                    else btn:SetPoint("BOTTOM", LarlenCacheOpener.buttons[i-1], "TOP", 0, spacing) end
                elseif align == "DOWN" then
                    if i == 1 then btn:SetPoint("TOP", LarlenCacheOpener.frame, "TOP", 0, 0)
                    else btn:SetPoint("TOP", LarlenCacheOpener.buttons[i-1], "BOTTOM", 0, -spacing) end
                else 
                    if i == 1 then btn:SetPoint("LEFT", LarlenCacheOpener.frame, "LEFT", 0, 0)
                    else btn:SetPoint("LEFT", LarlenCacheOpener.buttons[i-1], "RIGHT", spacing, 0) end
                end

                btn.icon:SetTexture(132596)
                btn.countString:SetText("99")
                btn.texture:SetDesaturated(false)
                
                btn:SetAlpha(LarlenCacheOpener:P("alpha") or 1.0)
                if LarlenCacheOpener:P("showGlow") then LarlenCacheOpener:ShowGlow(btn) else LarlenCacheOpener:HideGlow(btn) end
                
                btn:Show()
            end
        end
    end

    -----------------------------------------
    -- LEFT COLUMN: GENERAL SETTINGS
    -----------------------------------------
    CreateSeparator(panel, -45)
    CreateSectionHeader(panel, "General Settings", 15, -55)

    local soundCb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    soundCb:SetPoint("TOPLEFT", 15, -80)
    soundCb.Text:SetText(" Play sound when an item appears")
    soundCb:HookScript("OnClick", function(self) LarlenCacheOpener:SetP("playSound", self:GetChecked()) end)

    local soundDropdownLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    soundDropdownLabel:SetPoint("TOPLEFT", 35, -115)
    soundDropdownLabel:SetText("Select Sound:")

    local soundDropdown = CreateFrame("Frame", "SCO_SoundDropdown", panel, "UIDropDownMenuTemplate")
    soundDropdown:SetPoint("TOPLEFT", 120, -110)
    UIDropDownMenu_SetWidth(soundDropdown, 130)

    UIDropDownMenu_Initialize(soundDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, sound in ipairs(LarlenCacheOpener.sounds) do
            info.text = sound.name
            info.arg1 = i
            info.func = function(self, arg1)
                UIDropDownMenu_SetText(soundDropdown, LarlenCacheOpener.sounds[arg1].name)
                LarlenCacheOpener:SetP("soundChoice", arg1)
                PlaySound(LarlenCacheOpener.sounds[arg1].id, "Master")
            end
            info.checked = (LarlenCacheOpener:P("soundChoice") == i)
            UIDropDownMenu_AddButton(info)
        end
    end)

    local combatCb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    combatCb:SetPoint("TOPLEFT", 15, -140)
    combatCb.Text:SetText(" Hide icons while in combat")
    combatCb:HookScript("OnClick", function(self)
        LarlenCacheOpener:SetP("hideInCombat", self:GetChecked())
        LarlenCacheOpener:UpdateCombatState()
    end)

    local minimapCb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    minimapCb:SetPoint("TOPLEFT", 15, -165)
    minimapCb.Text:SetText(" Show Minimap Icon")
    minimapCb:HookScript("OnClick", function(self)
        LarlenCacheOpener:SetP("showMinimap", self:GetChecked() == 1 or self:GetChecked() == true)
        LarlenCacheOpener:UpdateMinimapVisibility()
    end)

    local glowCb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    glowCb:SetPoint("TOPLEFT", 15, -190)
    glowCb.Text:SetText(" Show Action Button Glow")
    glowCb:HookScript("OnClick", function(self)
        LarlenCacheOpener:SetP("showGlow", self:GetChecked())
        if testActive then ToggleTestIcons(5) else LarlenCacheOpener:updateButtons() end
    end)

    -----------------------------------------
    -- LEFT COLUMN: APPEARANCE & POSITION
    -----------------------------------------
    CreateSeparator(panel, -230)
    CreateSectionHeader(panel, "Appearance & Position", 15, -240)

    -- Size Slider
    local sizeSlider = CreateFrame("Slider", "SCO_SizeSlider", panel, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT", 20, -280)
    sizeSlider:SetMinMaxValues(16, 64)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    _G["SCO_SizeSliderLow"]:SetText("16")
    _G["SCO_SizeSliderHigh"]:SetText("64")
    _G["SCO_SizeSliderText"]:SetText("Icon Size")
    
    local sizeInput = CreateFrame("EditBox", "SCO_SizeInput", panel, "InputBoxTemplate")
    sizeInput:SetSize(40, 20)
    sizeInput:SetPoint("LEFT", sizeSlider, "RIGHT", 15, 0)
    sizeInput:SetAutoFocus(false)
    sizeInput:SetNumeric(true)
    
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        LarlenCacheOpener:SetP("iconSize", val)
        LarlenCacheOpener.frame:SetHeight(val)
        sizeInput:SetText(tostring(val))
        if testActive then ToggleTestIcons(5) else LarlenCacheOpener:updateButtons() end
    end)

    sizeInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            val = math.max(16, math.min(64, val))
            sizeSlider:SetValue(val)
        end
        self:ClearFocus()
    end)
    sizeInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Direction Dropdown
    local alignDropdownLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alignDropdownLabel:SetPoint("TOPLEFT", 20, -320)
    alignDropdownLabel:SetText("Growth Direction:")

    local alignDropdown = CreateFrame("Frame", "SCO_AlignDropdown", panel, "UIDropDownMenuTemplate")
    alignDropdown:SetPoint("TOPLEFT", 120, -315)
    UIDropDownMenu_SetWidth(alignDropdown, 100)

    UIDropDownMenu_Initialize(alignDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, dir in ipairs(directions) do
            info.text = dir.name
            info.arg1 = dir.value
            info.func = function(self, arg1)
                UIDropDownMenu_SetText(alignDropdown, dir.name)
                LarlenCacheOpener:SetP("alignment", arg1)
                if testActive then ToggleTestIcons(5) else LarlenCacheOpener:updateButtons() end
            end
            info.checked = (LarlenCacheOpener:P("alignment") == dir.value)
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Alpha Slider
    local alphaSlider = CreateFrame("Slider", "SCO_AlphaSlider", panel, "OptionsSliderTemplate")
    alphaSlider:SetPoint("TOPLEFT", 20, -370)
    alphaSlider:SetMinMaxValues(10, 100)
    alphaSlider:SetValueStep(1)
    alphaSlider:SetObeyStepOnDrag(true)
    _G["SCO_AlphaSliderLow"]:SetText("10%")
    _G["SCO_AlphaSliderHigh"]:SetText("100%")
    _G["SCO_AlphaSliderText"]:SetText("Transparency (Alpha)")

    local alphaInput = CreateFrame("EditBox", "SCO_AlphaInput", panel, "InputBoxTemplate")
    alphaInput:SetSize(40, 20)
    alphaInput:SetPoint("LEFT", alphaSlider, "RIGHT", 15, 0)
    alphaInput:SetAutoFocus(false)
    alphaInput:SetNumeric(true)

    alphaSlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        LarlenCacheOpener:SetP("alpha", val / 100)
        alphaInput:SetText(tostring(val))
        if testActive then ToggleTestIcons(5) else LarlenCacheOpener:updateButtons() end
    end)

    alphaInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            val = math.max(10, math.min(100, val))
            alphaSlider:SetValue(val)
        end
        self:ClearFocus()
    end)
    alphaInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)


    -- X Slider
    local xSlider = CreateFrame("Slider", "SCO_XSlider", panel, "OptionsSliderTemplate")
    xSlider:SetPoint("TOPLEFT", 20, -420)
    xSlider:SetMinMaxValues(-1000, 1000)
    xSlider:SetValueStep(1)
    xSlider:SetObeyStepOnDrag(true)
    _G["SCO_XSliderLow"]:SetText("-1000")
    _G["SCO_XSliderHigh"]:SetText("1000")
    _G["SCO_XSliderText"]:SetText("X Position")
    
    local xInput = CreateFrame("EditBox", "SCO_XInput", panel, "InputBoxTemplate")
    xInput:SetSize(50, 20)
    xInput:SetPoint("LEFT", xSlider, "RIGHT", 15, 0)
    xInput:SetAutoFocus(false)
    
    xSlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        local p = LarlenCacheOpener:GetActiveProfile()
        if not p.position then p.position = {"CENTER", nil, "CENTER", 0, 0} end
        p.position[4] = val
        LarlenCacheOpener.frame:ClearAllPoints()
        LarlenCacheOpener.frame:SetPoint(p.position[1] or "CENTER", UIParent, p.position[3] or "CENTER", p.position[4], p.position[5] or 0)
        xInput:SetText(tostring(val))
    end)

    xInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then xSlider:SetValue(val) end
        self:ClearFocus()
    end)
    xInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Y Slider
    local ySlider = CreateFrame("Slider", "SCO_YSlider", panel, "OptionsSliderTemplate")
    ySlider:SetPoint("TOPLEFT", 20, -470)
    ySlider:SetMinMaxValues(-600, 600)
    ySlider:SetValueStep(1)
    ySlider:SetObeyStepOnDrag(true)
    _G["SCO_YSliderLow"]:SetText("-600")
    _G["SCO_YSliderHigh"]:SetText("600")
    _G["SCO_YSliderText"]:SetText("Y Position")

    local yInput = CreateFrame("EditBox", "SCO_YInput", panel, "InputBoxTemplate")
    yInput:SetSize(50, 20)
    yInput:SetPoint("LEFT", ySlider, "RIGHT", 15, 0)
    yInput:SetAutoFocus(false)

    ySlider:SetScript("OnValueChanged", function(self, value)
        if isRefreshing then return end
        local val = math.floor(value + 0.5)
        local p = LarlenCacheOpener:GetActiveProfile()
        if not p.position then p.position = {"CENTER", nil, "CENTER", 0, 0} end
        p.position[5] = val
        LarlenCacheOpener.frame:ClearAllPoints()
        LarlenCacheOpener.frame:SetPoint(p.position[1] or "CENTER", UIParent, p.position[3] or "CENTER", p.position[4] or 0, p.position[5])
        yInput:SetText(tostring(val))
    end)

    yInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then ySlider:SetValue(val) end
        self:ClearFocus()
    end)
    yInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Action Buttons
    local resetPosBtn = CreateFrame("Button", "SCO_ResetPosBtn", panel, "UIPanelButtonTemplate")
    resetPosBtn:SetPoint("LEFT", yInput, "RIGHT", 20, 0)
    resetPosBtn:SetSize(110, 25)
    resetPosBtn:SetText("Reset Position")
    resetPosBtn:SetScript("OnClick", function()
        local p = LarlenCacheOpener:GetActiveProfile()
        p.position = {"CENTER", nil, "CENTER", 0, 0}
        LarlenCacheOpener.frame:ClearAllPoints()
        LarlenCacheOpener.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        xSlider:SetValue(0)
        ySlider:SetValue(0)
    end)

    local testBtn = CreateFrame("Button", "SCO_TestButton", panel, "UIPanelButtonTemplate")
    testBtn:SetPoint("LEFT", resetPosBtn, "RIGHT", 10, 0)
    testBtn:SetSize(110, 25)
    testBtn:SetText("Test Icons")
    testBtn:SetScript("OnClick", function()
        testActive = not testActive
        if testActive then ToggleTestIcons(5) else ToggleTestIcons(0) end
    end)

    local lockCb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    lockCb:SetPoint("TOPLEFT", 15, -510)
    lockCb.Text:SetText(" Lock Position")
    lockCb:HookScript("OnClick", function(self)
        LarlenCacheOpener:SetP("locked", self:GetChecked())
    end)

    local moveHint = panel:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
    moveHint:SetPoint("TOPLEFT", 190, -515)
    moveHint:SetText("|cffffd100Tip:|r If unlocked, use Right-Click to drag and move icons freely.")

    -----------------------------------------
    -- RIGHT COLUMN: PROFILE MANAGEMENT
    -----------------------------------------
    CreateSeparator(panel, -45)
    CreateSectionHeader(panel, "Profiles", 350, -55)

    -- Profile dropdown row
    local profileDropdownLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileDropdownLabel:SetPoint("TOPLEFT", 350, -80)
    profileDropdownLabel:SetText("Active Profile:")

    local profileDropdown = CreateFrame("Frame", "SCO_ProfileDropdown", panel, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPLEFT", 428, -75)
    UIDropDownMenu_SetWidth(profileDropdown, 120)

    local function RebuildProfileDropdown()
        UIDropDownMenu_Initialize(profileDropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            local names = LarlenCacheOpener:GetProfileNames()
            local active = LarlenCacheOpenerDB and LarlenCacheOpenerDB.activeProfile or "Default"
            for _, name in ipairs(names) do
                info.text = name
                info.arg1 = name
                info.func = function(self, arg1)
                    UIDropDownMenu_SetText(profileDropdown, arg1)
                    LarlenCacheOpener:SwitchProfile(arg1)
                    if LarlenCacheOpener.RefreshOptionsPanelValues then
                        LarlenCacheOpener.RefreshOptionsPanelValues()
                    end
                end
                info.checked = (active == name)
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetText(profileDropdown, LarlenCacheOpenerDB and LarlenCacheOpenerDB.activeProfile or "Default")
    end

    -- Name input + New / Copy / Delete on one row
    local newProfileInput = CreateFrame("EditBox", "SCO_NewProfileInput", panel, "InputBoxTemplate")
    newProfileInput:SetSize(100, 20)
    newProfileInput:SetPoint("TOPLEFT", 355, -115)
    newProfileInput:SetAutoFocus(false)
    newProfileInput:SetMaxLetters(32)
    newProfileInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local newProfileBtn = CreateFrame("Button", "SCO_NewProfileBtn", panel, "UIPanelButtonTemplate")
    newProfileBtn:SetPoint("LEFT", newProfileInput, "RIGHT", 5, 0)
    newProfileBtn:SetSize(50, 22)
    newProfileBtn:SetText("New")
    newProfileBtn:SetScript("OnClick", function()
        local name = newProfileInput:GetText()
        if name and name ~= "" then
            if LarlenCacheOpener:CreateProfile(name, false) then
                LarlenCacheOpener:SwitchProfile(name)
                newProfileInput:SetText("")
                newProfileInput:ClearFocus()
                RebuildProfileDropdown()
                -- SwitchProfile already calls RefreshOptionsPanelValues
            end
        end
    end)

    local copyProfileBtn = CreateFrame("Button", "SCO_CopyProfileBtn", panel, "UIPanelButtonTemplate")
    copyProfileBtn:SetPoint("LEFT", newProfileBtn, "RIGHT", 4, 0)
    copyProfileBtn:SetSize(50, 22)
    copyProfileBtn:SetText("Copy")
    copyProfileBtn:SetScript("OnClick", function()
        local name = newProfileInput:GetText()
        if name and name ~= "" then
            if LarlenCacheOpener:CreateProfile(name, true) then
                LarlenCacheOpener:SwitchProfile(name)
                newProfileInput:SetText("")
                newProfileInput:ClearFocus()
                RebuildProfileDropdown()
                -- SwitchProfile already calls RefreshOptionsPanelValues
            end
        end
    end)

    local deleteProfileBtn = CreateFrame("Button", "SCO_DeleteProfileBtn", panel, "UIPanelButtonTemplate")
    deleteProfileBtn:SetPoint("LEFT", copyProfileBtn, "RIGHT", 4, 0)
    deleteProfileBtn:SetSize(55, 22)
    deleteProfileBtn:SetText("Delete")
    deleteProfileBtn:SetScript("OnClick", function()
        local active = LarlenCacheOpenerDB and LarlenCacheOpenerDB.activeProfile or "Default"
        if LarlenCacheOpener:DeleteProfile(active) then
            RebuildProfileDropdown()
            -- DeleteProfile calls SwitchProfile("Default") which calls RefreshOptionsPanelValues
        end
    end)

    -----------------------------------------
    -- RIGHT COLUMN: HIDDEN GROUPS
    -- y=-230 separator + y=-240 header matches "Appearance & Position" on the left
    -----------------------------------------
    CreateSeparator(panel, -230)
    CreateSectionHeader(panel, L["hidden_groups"], 350, -240)

    for i, name in ipairs(LarlenCacheOpener.group_ids_ordered) do
        local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 350, -245 + (-25*i))
        cb.Text:SetText(" " .. L[name])
        cb.group_id = name
        
        cb:HookScript("OnClick", function(_, btn, down)
            LarlenCacheOpener:GetActiveProfile().ignored_groups[name] = cb:GetChecked()
            LarlenCacheOpener:updateIgnoreItems()
            LarlenCacheOpener:updateButtons()
        end)
        LarlenCacheOpener.option_buttons[name] = cb
    end

    -----------------------------------------
    -- RIGHT COLUMN: CUSTOM ITEMS
    -----------------------------------------
    local customYOffset = -245 + (-25 * #LarlenCacheOpener.group_ids_ordered) - 30
    CreateSectionHeader(panel, "Custom Items", 350, customYOffset)

    local customDesc = panel:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
    customDesc:SetPoint("TOPLEFT", 350, customYOffset - 22)
    customDesc:SetText("Add or remove custom item IDs.")

    local customInput = CreateFrame("EditBox", "SCO_CustomInput", panel, "InputBoxTemplate")
    customInput:SetSize(80, 20)
    customInput:SetPoint("TOPLEFT", 355, customYOffset - 46)
    customInput:SetAutoFocus(false)
    customInput:SetNumeric(true)
    customInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local addBtn = CreateFrame("Button", "SCO_AddCustomBtn", panel, "UIPanelButtonTemplate")
    addBtn:SetPoint("LEFT", customInput, "RIGHT", 10, 0)
    addBtn:SetSize(55, 22)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local id = tonumber(customInput:GetText())
        if id then
            LarlenCacheOpener:GetActiveProfile().custom_items = LarlenCacheOpener:GetActiveProfile().custom_items or {}
            LarlenCacheOpener:GetActiveProfile().custom_items[id] = 1
            customInput:SetText("")
            customInput:ClearFocus()
            print("|cffffa500Larlen Cache Opener|r: |cff00ff00Added|r custom item ID", id)
            LarlenCacheOpener:updateButtons()
        end
    end)

    local removeBtn = CreateFrame("Button", "SCO_RemoveCustomBtn", panel, "UIPanelButtonTemplate")
    removeBtn:SetPoint("LEFT", addBtn, "RIGHT", 5, 0)
    removeBtn:SetSize(70, 22)
    removeBtn:SetText("Remove")
    removeBtn:SetScript("OnClick", function()
        local id = tonumber(customInput:GetText())
        local custom = LarlenCacheOpener:GetActiveProfile().custom_items
        if id and custom and custom[id] then
            custom[id] = nil
            customInput:SetText("")
            customInput:ClearFocus()
            print("|cffffa500Larlen Cache Opener|r: |cffff0000Removed|r custom item ID", id)
            LarlenCacheOpener:updateButtons()
        end
    end)

    -----------------------------------------
    -- INITIALIZE & SYNC VALUES
    -----------------------------------------
    local function RefreshPanelValues()
        if not LarlenCacheOpenerDB then return end
        isRefreshing = true
        local p = LarlenCacheOpener:GetActiveProfile()

        soundCb:SetChecked(p.playSound ~= false)
        combatCb:SetChecked(p.hideInCombat ~= false)
        minimapCb:SetChecked(p.showMinimap ~= false)
        glowCb:SetChecked(p.showGlow ~= false)
        lockCb:SetChecked(p.locked == true)
        
        local currentSoundIdx = p.soundChoice or 1
        if LarlenCacheOpener.sounds and LarlenCacheOpener.sounds[currentSoundIdx] then
            UIDropDownMenu_SetText(soundDropdown, LarlenCacheOpener.sounds[currentSoundIdx].name)
        end

        local currentAlign = p.alignment or "RIGHT"
        for _, dir in ipairs(directions) do
            if dir.value == currentAlign then
                UIDropDownMenu_SetText(alignDropdown, dir.name)
            end
        end

        sizeSlider:SetValue(p.iconSize or 38)
        sizeInput:SetText(tostring(p.iconSize or 38))

        local currentAlpha = math.floor((p.alpha or 1.0) * 100)
        alphaSlider:SetValue(currentAlpha)
        alphaInput:SetText(tostring(currentAlpha))

        if p.position and p.position[4] then
            xSlider:SetValue(p.position[4])
            xInput:SetText(tostring(math.floor(p.position[4] + 0.5)))
            ySlider:SetValue(p.position[5])
            yInput:SetText(tostring(math.floor(p.position[5] + 0.5)))
        else
            xSlider:SetValue(0)
            xInput:SetText("0")
            ySlider:SetValue(0)
            yInput:SetText("0")
        end

        for _, name in ipairs(LarlenCacheOpener.group_ids_ordered) do
            local isChecked = false
            if p.ignored_groups and p.ignored_groups[name] ~= nil then
                isChecked = p.ignored_groups[name]
            end
            if LarlenCacheOpener.option_buttons[name] then
                LarlenCacheOpener.option_buttons[name]:SetChecked(isChecked)
            end
        end

        if _G["SCO_ProfileDropdown"] then
            UIDropDownMenu_SetText(_G["SCO_ProfileDropdown"], LarlenCacheOpenerDB.activeProfile or "Default")
        end

        isRefreshing = false
    end
    -- Expose so SwitchProfile can call it
    LarlenCacheOpener.RefreshOptionsPanelValues = RefreshPanelValues

    panel:RegisterEvent("ADDON_LOADED")
    panel:SetScript("OnEvent", function(self, event, addonName)
        if addonName == "LarlenCacheOpener" then
            RefreshPanelValues()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)

    panel:HookScript("OnShow", function()
        RebuildProfileDropdown()
        RefreshPanelValues()
    end)
    panel:HookScript("OnHide", function()
        if testActive then
            testActive = false
            LarlenCacheOpener:updateButtons()
        end
    end)

    -- Footer text
    local text = panel:CreateFontString("ARTWORK", nil, "GameFontWhiteSmall")
    text:SetText(L["option_description"])
    text:SetPoint("BOTTOMLEFT", 15, 15)
    text:SetWidth(550)
    text:SetJustifyH("LEFT")
end

function LarlenCacheOpener:updateOptionCheckbox(group_id, state) 
    if (LarlenCacheOpener.option_buttons[group_id] ~= nil) then
        LarlenCacheOpener.option_buttons[group_id]:SetChecked(state);
    end
end 

L["hidden_groups"] = "Hidden Item Categories"
L["addon_name"] = "Larlen Cache Opener"
L["option_description"] = "Type /lco for commands.\n\n|cffffa500Credits: nerino1 (original Soulbind Cache Opener) & Tamuko (Continued).|r"