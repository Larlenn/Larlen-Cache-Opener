local debug = false;
local maxButtons = 20;

local addonName, L = ...; 

LarlenCacheOpener.sounds = {
    {name = "Ding", id = SOUNDKIT.AUCTION_WINDOW_OPEN},
    {name = "Loot", id = SOUNDKIT.UI_EPICLOOT_TOAST},     
    {name = "Raid Warning", id = SOUNDKIT.RAID_WARNING},    
    {name = "Ready Check", id = SOUNDKIT.READY_CHECK},     
    {name = "Map Ping", id = SOUNDKIT.MAP_PING},        
    {name = "Quest Complete", id = SOUNDKIT.IG_QUEST_LIST_COMPLETE},
    {name = "Level Up", id = SOUNDKIT.LEVEL_UP},
    {name = "Whisper", id = SOUNDKIT.TELL_MESSAGE},
    {name = "Air Horn (PvP)", id = SOUNDKIT.PVP_FLAG_TAKEN},
    {name = "Boss Whisper", id = SOUNDKIT.UI_RAID_BOSS_WHISPER_WARNING},
    {name = "Alarm Clock", id = SOUNDKIT.ALARM_CLOCK_WARNING_3},
    {name = "LFG Chime", id = SOUNDKIT.LFG_ROLE_CHECK},
    {name = "Fel Reaver Roar", id = SOUNDKIT.FEL_REAVER_AGGRO}
}
LarlenCacheOpener.currentlyShown = {};
LarlenCacheOpener.isInitialized = false;

------------------------------------------------
-- PROFILE SYSTEM
------------------------------------------------

local defaultProfileData = {
    ["enable"]        = true,
    ["alignment"]     = "RIGHT",
    ["ignored_items"] = {},
    ["ignored_groups"]= {},
    ["custom_items"]  = {},
    ["iconSize"]      = 36,
    ["playSound"]     = false,
    ["soundChoice"]   = 1,
    ["hideInCombat"]  = true,
    ["showMinimap"]   = true,
    ["minimapPos"]    = 225,
    ["showGlow"]      = false,
    ["alpha"]         = 1.0,
    ["locked"]        = false,
    ["position"]      = nil,
}

local function CopyProfileData(src)
    local t = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            local sub = {}
            for k2, v2 in pairs(v) do sub[k2] = v2 end
            t[k] = sub
        else
            t[k] = v
        end
    end
    return t
end

function LarlenCacheOpener:GetActiveProfile()
    local profileName = (LarlenCacheOpenerProfiles and LarlenCacheOpenerProfiles.activeProfile) or "Default"
    if not LarlenCacheOpenerProfiles or not LarlenCacheOpenerProfiles.profiles then
        return CopyProfileData(defaultProfileData)
    end
    if not LarlenCacheOpenerProfiles.profiles[profileName] then
        LarlenCacheOpenerProfiles.profiles[profileName] = CopyProfileData(defaultProfileData)
    end
    return LarlenCacheOpenerProfiles.profiles[profileName]
end

function LarlenCacheOpener:P(key)
    return self:GetActiveProfile()[key]
end

function LarlenCacheOpener:SetP(key, value)
    self:GetActiveProfile()[key] = value
end

function LarlenCacheOpener:SwitchProfile(name)
    LarlenCacheOpenerProfiles.profiles = LarlenCacheOpenerProfiles.profiles or {}
    if not LarlenCacheOpenerProfiles.profiles[name] then
        LarlenCacheOpenerProfiles.profiles[name] = CopyProfileData(defaultProfileData)
    end
    LarlenCacheOpenerProfiles.activeProfile = name
    self:updateIgnoreItems()
    self:UpdateCombatState()
    self:UpdateMinimapPosition()
    self:UpdateMinimapVisibility()
    self:updateButtons()
    if LarlenCacheOpener.RefreshOptionsPanelValues then
        LarlenCacheOpener.RefreshOptionsPanelValues()
    end
    print("|cffffa500Larlen Cache Opener|r: Switched to profile |cffffd100" .. name .. "|r")
end

function LarlenCacheOpener:CreateProfile(name, copyFromCurrent)
    LarlenCacheOpenerProfiles.profiles = LarlenCacheOpenerProfiles.profiles or {}
    if LarlenCacheOpenerProfiles.profiles[name] then
        print("|cffffa500Larlen Cache Opener|r: Profile |cffffd100" .. name .. "|r already exists.")
        return false
    end
    if copyFromCurrent then
        LarlenCacheOpenerProfiles.profiles[name] = CopyProfileData(self:GetActiveProfile())
    else
        LarlenCacheOpenerProfiles.profiles[name] = CopyProfileData(defaultProfileData)
    end
    print("|cffffa500Larlen Cache Opener|r: Created profile |cffffd100" .. name .. "|r")
    return true
end

function LarlenCacheOpener:DeleteProfile(name)
    if name == "Default" then
        print("|cffffa500Larlen Cache Opener|r: Cannot delete the Default profile.")
        return false
    end
    if LarlenCacheOpenerProfiles.profiles and LarlenCacheOpenerProfiles.profiles[name] then
        LarlenCacheOpenerProfiles.profiles[name] = nil
        print("|cffffa500Larlen Cache Opener|r: Deleted profile |cffffd100" .. name .. "|r")
        if LarlenCacheOpenerProfiles.activeProfile == name then
            self:SwitchProfile("Default")
        end
        return true
    end
    print("|cffffa500Larlen Cache Opener|r: Profile |cffffd100" .. name .. "|r not found.")
    return false
end

function LarlenCacheOpener:GetProfileNames()
    local names = {"Default"}
    if LarlenCacheOpenerProfiles and LarlenCacheOpenerProfiles.profiles then
        for k in pairs(LarlenCacheOpenerProfiles.profiles) do
            if k ~= "Default" then
                table.insert(names, k)
            end
        end
    end
    return names
end

function LarlenCacheOpener:ShowGlow(btn)
    if not btn.scocGlow then
        btn.scocGlow = btn:CreateTexture(nil, "OVERLAY")
        btn.scocGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
        btn.scocGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
        btn.scocGlow:SetPoint("CENTER")
        btn.scocGlow:SetSize(btn:GetWidth() * 1.4, btn:GetHeight() * 1.4)
        btn.scocGlow:SetBlendMode("ADD")
    end
    btn.scocGlow:Show()
end

function LarlenCacheOpener:HideGlow(btn)
    if btn.scocGlow then
        btn.scocGlow:Hide()
    end
end

function LarlenCacheOpener:updateButtons()
    if self.isDragging then return end
    if debug == true then print("Testing", "4 - updateButtons Called") end
    
    local newShown = {}
    local shouldPlaySound = false
    self.previous = 0;
    
    for i = 1, maxButtons do
        if debug == true then print("Testing", "4 - Hiding button " .. i) end
        LarlenCacheOpener.buttons[i]:Hide();
        LarlenCacheOpener.buttons[i]:SetText("");
        self:HideGlow(LarlenCacheOpener.buttons[i]);
    end
    
    for i = 1, #self.items do
        if debug == true then print("Testing", "5 - self.items loop") end
        local wasPrevious = self.previous
        self:updateButton(self.items[i], LarlenCacheOpener.buttons[self.previous + 1]);
        
        if self.previous > wasPrevious then
            local id = self.items[i].id
            newShown[id] = true
            if not self.currentlyShown[id] then
                shouldPlaySound = true
            end
        end
    end

    local custom_items = self:P("custom_items")
    if custom_items then
        for custom_id, custom_minCount in pairs(custom_items) do
            local wasPrevious = self.previous
            self:updateButton({id = custom_id, minCount = custom_minCount}, LarlenCacheOpener.buttons[self.previous + 1]);

            if self.previous > wasPrevious then
                newShown[custom_id] = true
                if not self.currentlyShown[custom_id] then
                    shouldPlaySound = true
                end
            end
        end
    end

    if shouldPlaySound and self.isInitialized and self:P("playSound") then
        local soundIdx = self:P("soundChoice") or 1
        if LarlenCacheOpener.sounds[soundIdx] then
            PlaySound(LarlenCacheOpener.sounds[soundIdx].id, "Master")
        end
    end

    self.currentlyShown = newShown
    self.isInitialized = true

    local iconSize = self:P("iconSize") or 36
    local spacing = 2
    local count = self.previous
    local align = self:P("alignment") or "RIGHT"
    if count > 0 then
        if align == "RIGHT" or align == "LEFT" then
            self.frame:SetWidth(count * iconSize + (count - 1) * spacing)
            self.frame:SetHeight(iconSize)
        else -- UP or DOWN
            self.frame:SetWidth(iconSize)
            self.frame:SetHeight(count * iconSize + (count - 1) * spacing)
        end

        local pos = self:GetActiveProfile().position
        local isize = self:P("iconSize") or 36
        local b1x = pos and pos[4] or (GetScreenWidth() / 2)
        local b1y = pos and pos[5] or (GetScreenHeight() / 2)
        local fw = self.frame:GetWidth()
        local fh = self.frame:GetHeight()
        self.frame:ClearAllPoints()
        if align == "RIGHT" then
            self.frame:SetPoint("LEFT", UIParent, "BOTTOMLEFT", b1x - isize/2, b1y)
        elseif align == "LEFT" then
            self.frame:SetPoint("RIGHT", UIParent, "BOTTOMLEFT", b1x + isize/2, b1y)
        elseif align == "DOWN" then
            self.frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", b1x, b1y + isize/2)
        else -- UP
            self.frame:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", b1x, b1y - isize/2)
        end
    end
end

function LarlenCacheOpener:updateButton(currItem, btn)
    local id = currItem.id;
    local count = C_Item.GetItemCount(id);
    local btn_number = self.previous + 1;

    if (count >= currItem.minCount and not self:P("ignored_items")[id] and not LarlenCacheOpener.group_ignored_items[id] and self.previous < maxButtons) then
        
        local iconSize = self:P("iconSize") or 38;
        btn:SetWidth(iconSize);
        btn:SetHeight(iconSize);

        btn:ClearAllPoints();
        local spacing = 2
        local align = self:P("alignment") or "RIGHT"

        if align == "LEFT" then
            if self.previous == 0 then
                btn:SetPoint("RIGHT", self.frame, "RIGHT", 0, 0);
            else
                btn:SetPoint("RIGHT", self.buttons[self.previous], "LEFT", -spacing, 0);
            end
        elseif align == "UP" then
            if self.previous == 0 then
                btn:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 0);
            else
                btn:SetPoint("BOTTOM", self.buttons[self.previous], "TOP", 0, spacing);
            end
        elseif align == "DOWN" then
            if self.previous == 0 then
                btn:SetPoint("TOP", self.frame, "TOP", 0, 0);
            else
                btn:SetPoint("TOP", self.buttons[self.previous], "BOTTOM", 0, -spacing);
            end
        else -- RIGHT (Default)
            if self.previous == 0 then
                btn:SetPoint("LEFT", self.frame, "LEFT", 0, 0);
            else
                btn:SetPoint("LEFT", self.buttons[self.previous], "RIGHT", spacing, 0);
            end
        end

        self.previous = btn_number;
        btn.countString:SetText(format("%d",count));
        btn.texture:SetDesaturated(false);
        
        btn:SetAttribute("type", "macro");
        btn:SetAttribute("macrotext", format("/use [nomod:shift] item:%d", id));
        btn:RegisterForDrag("RightButton");

        btn.icon:SetTexture(C_Item.GetItemIconByID(id));
        btn.texture = btn.icon;
        btn.texture:SetAllPoints(btn);
        btn.id = id;
        
        btn:SetAlpha(self:P("alpha") or 1.0)
        
        if self:P("showGlow") then
            self:ShowGlow(btn)
        else
            self:HideGlow(btn)
        end

        if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "ButtonShow") end end
        btn:Show();
    end
end

function LarlenCacheOpener:createButton(btn,id)
    if debug == true then print("Testing", "7 - createButton Called") end
    btn:Hide();
    btn.id = id;
    btn:SetWidth(38);
    btn:SetHeight(38);
    btn:SetClampedToScreen(true);
    btn:EnableMouse(true);
    btn:SetMovable(true);
    

    
    btn:SetScript("OnDragStart", function(self)
        if not LarlenCacheOpener:P("locked") then
            LarlenCacheOpener.isDragging = true
            self:GetParent():StartMoving()
        end
    end)

    btn:SetScript("OnDragStop", function(self)
        if not LarlenCacheOpener:P("locked") then
            local f = self:GetParent()
            f:StopMovingOrSizing()
            f:SetUserPlaced(false)

            local align = LarlenCacheOpener:P("alignment") or "RIGHT"
            local isize = LarlenCacheOpener:P("iconSize") or 36
            local fw = f:GetWidth()
            local fh = f:GetHeight()
            local b1x, b1y

            if align == "RIGHT" then
                b1x = f:GetLeft() + isize/2
                b1y = f:GetBottom() + fh/2
            elseif align == "LEFT" then
                b1x = f:GetRight() - isize/2
                b1y = f:GetBottom() + fh/2
            elseif align == "DOWN" then
                b1x = f:GetLeft() + fw/2
                b1y = f:GetTop() - isize/2
            else -- UP
                b1x = f:GetLeft() + fw/2
                b1y = f:GetBottom() + isize/2
            end

            LarlenCacheOpener:GetActiveProfile().position = {"BOTTOMLEFT", nil, "BOTTOMLEFT", b1x, b1y}
            f:ClearAllPoints()
            if align == "RIGHT" then
                f:SetPoint("LEFT", UIParent, "BOTTOMLEFT", b1x - isize/2, b1y)
            elseif align == "LEFT" then
                f:SetPoint("RIGHT", UIParent, "BOTTOMLEFT", b1x + isize/2, b1y)
            elseif align == "DOWN" then
                f:SetPoint("TOP", UIParent, "BOTTOMLEFT", b1x, b1y + isize/2)
            else -- UP
                f:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", b1x, b1y - isize/2)
            end

            LarlenCacheOpener.isDragging = false

            if _G["SCO_XSlider"] and _G["SCO_XSlider"]:IsVisible() then
                local xOff = math.floor(b1x - GetScreenWidth()/2 + 0.5)
                local yOff = math.floor(b1y - GetScreenHeight()/2 + 0.5)
                _G["SCO_XSlider"]:SetValue(xOff)
                _G["SCO_XInput"]:SetText(tostring(xOff))
                _G["SCO_YSlider"]:SetValue(yOff)
                _G["SCO_YInput"]:SetText(tostring(yOff))
            end
        end
    end)

    btn:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp");
    btn:SetAttribute("type", "macro");
    btn:SetAttribute("macrotext", format("/use [nomod:shift] item:%d",id));
    btn:RegisterForDrag("RightButton");
    
    btn.countString = btn:CreateFontString(btn:GetName().."Count", "OVERLAY", "NumberFontNormal");
    btn.countString:SetPoint("BOTTOMRIGHT", btn, -0, 2);
    btn.countString:SetJustifyH("RIGHT");
    btn.icon = btn:CreateTexture(nil,"BACKGROUND");
    btn.icon:SetTexture(C_Item.GetItemIconByID(id) or 134400);
    btn.texture = btn.icon;
    btn.texture:SetAllPoints(btn);
    
    btn:HookScript("OnClick", function(self, button)
        if button == "RightButton" and IsShiftKeyDown() then
            LarlenCacheOpener:GetActiveProfile().ignored_items[self.id] = true;
            LarlenCacheOpener:updateIgnoreItems();
            LarlenCacheOpener:updateButtons();
            print("|cffffa500Larlen Cache Opener|r: Permanently ignored item ID", self.id);
        end
    end);
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self,"ANCHOR_TOP");
        GameTooltip:SetItemByID(format("%d",btn.id));
        GameTooltip:SetClampedToScreen(true);
        GameTooltip:Show();
      end);
    btn:SetScript("OnLeave",GameTooltip_Hide);
 end

function LarlenCacheOpener:UpdateCombatState()
    if self:P("hideInCombat") then
        RegisterStateDriver(self.frame, "visibility", "[combat] hide; show")
    else
        UnregisterStateDriver(self.frame, "visibility")
        self.frame:Show()
    end
end

function LarlenCacheOpener:UpdateMinimapVisibility()
    if not self.ldbi or not self.ldbi:IsRegistered("LarlenCacheOpener") then return end
    if self:P("showMinimap") ~= false then
        LarlenCacheOpenerDB.hide = false
        self.ldbi:Show("LarlenCacheOpener")
    else
        LarlenCacheOpenerDB.hide = true
        self.ldbi:Hide("LarlenCacheOpener")
    end
end
function LarlenCacheOpener:UpdateMinimapPosition()
end

function LarlenCacheOpener:reset()
    if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "8 - Reset Called") end end
    local profileName = LarlenCacheOpenerProfiles and LarlenCacheOpenerProfiles.activeProfile or "Default"
    LarlenCacheOpenerProfiles.profiles = LarlenCacheOpenerProfiles.profiles or {}
    LarlenCacheOpenerProfiles.profiles[profileName] = CopyProfileData(defaultProfileData)
    self:GetActiveProfile().position = nil;
    self:UpdateCombatState();
    self:UpdateMinimapPosition();
    self:UpdateMinimapVisibility();
    self:OnEvent("UPDATE");
end

function LarlenCacheOpener:resetPosition() 
    self:GetActiveProfile().position = nil;
    self:OnEvent("UPDATE");
end

function resetAll() 
    local profileName = LarlenCacheOpenerProfiles and LarlenCacheOpenerProfiles.activeProfile or "Default"
    LarlenCacheOpenerProfiles.profiles = LarlenCacheOpenerProfiles.profiles or {}
    LarlenCacheOpenerProfiles.profiles[profileName] = CopyProfileData(defaultProfileData)
    LarlenCacheOpener:UpdateCombatState();
    LarlenCacheOpener:UpdateMinimapPosition();
    LarlenCacheOpener:UpdateMinimapVisibility();
    LarlenCacheOpener:OnEvent("UPDATE");
end

function LarlenCacheOpener:AddButton()
    if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "2 - Add Button Called") end end
    if not InCombatLockdown() then
        self.frame:Show();
    end
    if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "3 - Frame Shown") end end
    LarlenCacheOpener:updateButtons();
end

function LarlenCacheOpener:updateIgnoreItems() 
    LarlenCacheOpener.group_ignored_items = {};
    local ignored_groups = LarlenCacheOpener:GetActiveProfile().ignored_groups
    if not ignored_groups then return end
    for gn, bl in pairs(ignored_groups) do
        if bl then
            LarlenCacheOpener:updateIgnoreItemsForOneGroup(gn);
        end
    end
end

function LarlenCacheOpener:updateIgnoreItemsForOneGroup(group_name) 
    local groupIds = LarlenCacheOpener.groups[group_name];
    if (groupIds ~= nil) then 
        for i, id in ipairs(groupIds) do
            LarlenCacheOpener.group_ignored_items[id] = true;
        end
    end
end

function LarlenCacheOpener:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...;
        if loadedAddon ~= addonName then return end

        if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "0 - Addon Loaded") end end
        self.frame:UnregisterEvent("ADDON_LOADED");


        LarlenCacheOpenerDB = LarlenCacheOpenerDB or {}


        LarlenCacheOpenerProfiles = LarlenCacheOpenerProfiles or {}
        LarlenCacheOpenerProfiles.profiles = LarlenCacheOpenerProfiles.profiles or {}


        if LarlenCacheOpenerDB.activeProfile ~= nil and LarlenCacheOpenerProfiles.activeProfile == nil then
            LarlenCacheOpenerProfiles.activeProfile = LarlenCacheOpenerDB.activeProfile
            LarlenCacheOpenerDB.activeProfile = nil
        end


        if LarlenCacheOpenerProfiles.activeProfile == nil then
            LarlenCacheOpenerProfiles.activeProfile = "Default"
        end


        if not LarlenCacheOpenerProfiles.profiles["Default"] then
            LarlenCacheOpenerProfiles.profiles["Default"] = CopyProfileData(defaultProfileData)
        end


        local activeProfile = LarlenCacheOpenerProfiles.activeProfile
        if not LarlenCacheOpenerProfiles.profiles[activeProfile] then
            LarlenCacheOpenerProfiles.profiles[activeProfile] = CopyProfileData(defaultProfileData)
        end


        if LarlenCacheOpenerDB.alignment ~= nil then
            local p = LarlenCacheOpenerProfiles.profiles["Default"]
            local fields = {"enable","alignment","ignored_items","ignored_groups","custom_items",
                            "iconSize","playSound","soundChoice","hideInCombat","showMinimap",
                            "minimapPos","showGlow","alpha","locked"}
            for _, f in ipairs(fields) do
                if LarlenCacheOpenerDB[f] ~= nil then
                    p[f] = LarlenCacheOpenerDB[f]
                    LarlenCacheOpenerDB[f] = nil
                end
            end
            print("|cffffa500Larlen Cache Opener|r: Migrated existing settings to the Default profile.")
        end


        local p = self:GetActiveProfile()
        if p.ignored_items == nil then p.ignored_items = {} end
        if p.ignored_groups == nil then p.ignored_groups = {} end
        if p.custom_items == nil then p.custom_items = {} end
        if p.iconSize == nil then p.iconSize = 36 end
        if p.playSound == nil then p.playSound = false end
        if p.soundChoice == nil then p.soundChoice = 1 end
        if p.alignment == nil then p.alignment = "RIGHT" end
        if p.hideInCombat == nil then p.hideInCombat = true end
        if p.showMinimap == nil then p.showMinimap = true end
        if p.minimapPos == nil then p.minimapPos = 225 end
        if p.showGlow == nil then p.showGlow = false end
        if p.alpha == nil then p.alpha = 1.0 end
        if p.locked == nil then p.locked = false end

        LarlenCacheOpener.updateIgnoreItems();
        LarlenCacheOpener.initializeOptions();
        LarlenCacheOpener:UpdateCombatState();


        if not LarlenCacheOpenerDB.minimapPos then
            LarlenCacheOpenerDB.minimapPos = 225
        end
        LarlenCacheOpenerDB.hide = not LarlenCacheOpener:P("showMinimap")
        C_Timer.After(0, function()
            if not LarlenCacheOpener.ldbi:IsRegistered("LarlenCacheOpener") then
                LarlenCacheOpener.ldbi:Register("LarlenCacheOpener", LarlenCacheOpener.ldb, LarlenCacheOpenerDB)
            end
            LarlenCacheOpener:UpdateMinimapVisibility()
        end)
    end

    if event == "PLAYER_LOGIN" then
        if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "9 - Player Login Event") end end
        self.frame:UnregisterEvent("PLAYER_LOGIN");
    end
    if UnitAffectingCombat("player") then
        if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "10 - Player is in Combat") end end
        return
    end
    if debug == true then if DLAPI then DLAPI.DebugLog("Testing", "1 - Event Called") end end
    LarlenCacheOpener:AddButton();
end

------------------------------------------------
-- Slash Commands
------------------------------------------------
local function slashHandler(msg)
    msg = msg:lower() or "";
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
    
    if (cmd == "ignore") then
        LarlenCacheOpener:GetActiveProfile().ignored_items[tonumber(args)] = true;
        LarlenCacheOpener:updateIgnoreItems();
        LarlenCacheOpener:updateButtons();
        print("|cffffa500Larlen Cache Opener|r: |cffff0000Ignoring|r item ID", args);

    elseif (cmd == "unignore") then
        LarlenCacheOpener:GetActiveProfile().ignored_items[tonumber(args)] = false;
        LarlenCacheOpener:updateIgnoreItems();
        LarlenCacheOpener:updateButtons();
        print("|cffffa500Larlen Cache Opener|r: |cff00ff00Un-ignoring|r item ID", args);

    elseif (cmd == "add") then
        local id = tonumber(args)
        if id then
            LarlenCacheOpener:GetActiveProfile().custom_items = LarlenCacheOpener:GetActiveProfile().custom_items or {}
            LarlenCacheOpener:GetActiveProfile().custom_items[id] = 1;
            LarlenCacheOpener:updateButtons();
            print("|cffffa500Larlen Cache Opener|r: |cff00ff00Added|r custom item ID", id);
        else
            print("|cffffa500Larlen Cache Opener|r: Invalid Item ID. Usage: /lco add <id>");
        end

    elseif (cmd == "remove") then
        local id = tonumber(args)
        local custom = LarlenCacheOpener:GetActiveProfile().custom_items
        if id and custom and custom[id] then
            custom[id] = nil;
            LarlenCacheOpener:updateButtons();
            print("|cffffa500Larlen Cache Opener|r: |cffff0000Removed|r custom item ID", id);
        else
            print("|cffffa500Larlen Cache Opener|r: Custom item ID not found or invalid.");
        end

    elseif (cmd == "ignoregroup") then
        LarlenCacheOpener:GetActiveProfile().ignored_groups[args] = true;
        LarlenCacheOpener:updateIgnoreItems();
        LarlenCacheOpener:updateButtons();
        LarlenCacheOpener:updateOptionCheckbox(args, true);
        print("|cffffa500Larlen Cache Opener|r: |cffff0000Ignoring|r group", args);

    elseif (cmd == "unignoregroup") then
        LarlenCacheOpener:GetActiveProfile().ignored_groups[args] = false;
        LarlenCacheOpener:updateIgnoreItems();
        LarlenCacheOpener:updateButtons();
        LarlenCacheOpener:updateOptionCheckbox(args, false);
        print("|cffffa500Larlen Cache Opener|r: |cff00ff00Un-ignoring|r group", args);

    elseif (cmd == "options") then
        if LarlenCacheOpener.category then
            Settings.OpenToCategory(LarlenCacheOpener.category.ID);
        else
            print("|cffffa500Larlen Cache Opener|r: Options not ready yet, please wait.");
        end

    elseif (cmd == "minimap") then
        LarlenCacheOpener:SetP("showMinimap", not LarlenCacheOpener:P("showMinimap"));
        LarlenCacheOpener:UpdateMinimapVisibility();
        print("|cffffa500Larlen Cache Opener|r: Minimap icon is now " .. (LarlenCacheOpener:P("showMinimap") and "|cff00ff00Shown|r" or "|cffff0000Hidden|r"));

    elseif (cmd == "profile") then
        local subcmd, subargs = string.match(args, "(%S+)%s*(.*)")
        subcmd = subcmd and subcmd:lower() or ""
        if subcmd == "list" then
            local names = LarlenCacheOpener:GetProfileNames()
            local active = LarlenCacheOpenerProfiles.activeProfile or "Default"
            print("|cffffa500Larlen Cache Opener|r: Profiles:")
            for _, n in ipairs(names) do
                if n == active then
                    print("  |cff00ff00>> " .. n .. " (active)|r")
                else
                    print("  |cffffd100" .. n .. "|r")
                end
            end
        elseif subcmd == "use" and subargs ~= "" then
            LarlenCacheOpener:SwitchProfile(subargs)
        elseif subcmd == "new" and subargs ~= "" then
            if LarlenCacheOpener:CreateProfile(subargs, false) then
                LarlenCacheOpener:SwitchProfile(subargs)
            end
        elseif subcmd == "copy" and subargs ~= "" then
            if LarlenCacheOpener:CreateProfile(subargs, true) then
                LarlenCacheOpener:SwitchProfile(subargs)
            end
        elseif subcmd == "delete" and subargs ~= "" then
            LarlenCacheOpener:DeleteProfile(subargs)
        else
            print("|cffffa500Larlen Cache Opener|r: Profile commands:")
            print("  |cffffa500/lco profile list|r - List all profiles")
            print("  |cffffa500/lco profile use <name>|r - Switch to a profile")
            print("  |cffffa500/lco profile new <name>|r - Create a new blank profile")
            print("  |cffffa500/lco profile copy <name>|r - Copy current profile to new name")
            print("  |cffffa500/lco profile delete <name>|r - Delete a profile")
        end

    elseif (msg == "reset") then
        print("|cffffa500Larlen Cache Opener|r: Resetting all settings and position.");
        LarlenCacheOpener:reset();
    else
        local groups_id_list_string = ""
        for i, name in ipairs(LarlenCacheOpener.group_ids_ordered) do
            groups_id_list_string = groups_id_list_string .. "|cffffd100" .. name .. "|r ";
        end
        
        print("|cffffa500--- Larlen Cache Opener Help ---|r");
        print("  |cffffa500/lco ignore <id>|r - Blacklists an existing item so it stops appearing");
        print("  |cffffa500/lco unignore <id>|r - Removes an item from your blacklist");
        print("  |cffffa500/lco add <id>|r - Adds a custom item ID to track");
        print("  |cffffa500/lco remove <id>|r - Removes a custom item ID");
        print("  |cffffa500/lco ignoregroup <name>|r - Blacklists a whole category");
        print("  |cffffa500/lco unignoregroup <name>|r - Removes a category from blacklist");
        print("  |cffffa500/lco profile list/use/new/copy/delete|r - Manage profiles");
        print("  |cffffa500/lco minimap|r - Toggle the minimap icon on or off");
        print("  |cffffa500/lco options|r - Open the addon settings panel");
        print("  |cffffa500/lco reset|r - Wipe all settings to default");
        print("  |cffffa500Available Groups:|r " .. groups_id_list_string);
        print("  |cff00ff00QOL Shortcut:|r Hold |cffffa500Shift + Right-Click|r on an icon to permanently ignore and prevent it from ever showing.");
    end
end

SlashCmdList.LarlenCacheOpener = function(msg) slashHandler(msg) end;
SLASH_LarlenCacheOpener1 = "/LarlenCacheOpener";
SLASH_LarlenCacheOpener2 = "/lco";
SLASH_LarlenCacheOpener3 = "/LCO";

-- Addon Compartment Function (Modern WoW Minimap Dropdown)
function LarlenCacheOpener_OnCompartmentClick()
    Settings.OpenToCategory(LarlenCacheOpener.category.ID)
end

local function cout(msg, premsg)
    premsg = premsg or "[".."Larlen Cache Opener".."]"
    print("|cFFE8A317"..premsg.."|r "..msg);
end

local function coutBool(msg,bool)
    if bool then print(msg..": true"); else print(msg..": false"); end
end

--Main Frame
LarlenCacheOpener.frame = CreateFrame("Frame", "LarlenCacheOpener_Frame", UIParent);
LarlenCacheOpener.frame:Hide();
LarlenCacheOpener.frame:SetWidth(120);
LarlenCacheOpener.frame:SetHeight(38);
LarlenCacheOpener.frame:SetClampedToScreen(true);
LarlenCacheOpener.frame:SetFrameStrata("BACKGROUND");
LarlenCacheOpener.frame:SetMovable(true);
LarlenCacheOpener.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
LarlenCacheOpener.frame:RegisterEvent("PLAYER_REGEN_ENABLED");
LarlenCacheOpener.frame:RegisterEvent("PLAYER_LOGIN");
LarlenCacheOpener.frame:RegisterEvent("ADDON_LOADED")
LarlenCacheOpener.frame:RegisterEvent("BAG_UPDATE");

 for i = 1, maxButtons do
    LarlenCacheOpener.buttons[i] = CreateFrame("Button", "scocbutton" .. i, LarlenCacheOpener.frame, "SecureActionButtonTemplate");
    LarlenCacheOpener:createButton(LarlenCacheOpener.buttons[i], 86220);
end

LarlenCacheOpener.frame:SetScript("OnEvent", function(self,event,...) LarlenCacheOpener:OnEvent(event,...) end);
LarlenCacheOpener.frame:SetScript("OnShow", nil);

------------------------------------------------
-- Minimap Button (LibDBIcon-1.0)
------------------------------------------------

local _ldb_data = {
    type  = "launcher",
    label = "Larlen Cache Opener",
    icon  = 132596,  -- bag icon
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            if LarlenCacheOpener.category then
                Settings.OpenToCategory(LarlenCacheOpener.category.ID)
            end
        elseif btn == "RightButton" then
            LarlenCacheOpener:SetP("showMinimap", false)
            LarlenCacheOpener:UpdateMinimapVisibility()
            print("|cffffa500Larlen Cache Opener|r: Minimap icon hidden. Type |cff00ff00/lco minimap|r to show it again.")
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("Larlen Cache Opener", 1, 0.82, 0)
        tt:AddLine(" ")
        tt:AddLine("|cffffffffLeft-Click|r to open settings.", 1, 1, 1)
        tt:AddLine("|cffffffffRight-Click|r to hide minimap icon.", 1, 1, 1)
        tt:AddLine("|cffffffffDrag|r to move.", 1, 1, 1)
    end,
}
local ldb = LibStub("LibDataBroker-1.1"):GetDataObjectByName("LarlenCacheOpener")
        or LibStub("LibDataBroker-1.1"):NewDataObject("LarlenCacheOpener", _ldb_data)
if ldb then
    ldb.OnClick       = _ldb_data.OnClick
    ldb.OnTooltipShow = _ldb_data.OnTooltipShow
    ldb.icon          = _ldb_data.icon
end

LarlenCacheOpener.ldbi = LibStub("LibDBIcon-1.0")
LarlenCacheOpener.ldb = ldb  -- store reference so ADDON_LOADED can reach it
