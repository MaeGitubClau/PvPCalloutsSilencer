local ADDON_NAME = ...

local defaults = {
    enabled = true,
    suppressAllTaint = true,
    suppressJoinMessages = true,
    announceLoad = true,
}

local optionsPanel
local controls = {}

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffPvPCalloutsSilencer:|r " .. message)
end

local function EnsureDB()
    if type(PvPCalloutsSilencerDB) ~= "table" then
        PvPCalloutsSilencerDB = {}
    end

    for key, value in pairs(defaults) do
        if PvPCalloutsSilencerDB[key] == nil then
            PvPCalloutsSilencerDB[key] = value
        end
    end
end

local function IsTaintError(message)
    if type(message) ~= "string" then
        return false
    end

    local ok, isTaint = pcall(function()
        return message:find("tainted", 1, true)
            or message:find("execution tainted by", 1, true)
            or message:find("cannot be accessed while tainted", 1, true)
            or message:find("has been blocked from an action only available to the Blizzard UI", 1, true)
            or message:find("Interface action failed because of an AddOn", 1, true)
    end)

    return ok and isTaint
end

local function InstallErrorFilter()
    if type(seterrorhandler) ~= "function" or type(geterrorhandler) ~= "function" then
        return
    end

    local previousHandler = geterrorhandler()

    seterrorhandler(function(message)
        EnsureDB()

        if PvPCalloutsSilencerDB.enabled
            and PvPCalloutsSilencerDB.suppressAllTaint
            and IsTaintError(message) then
            return
        end

        if type(previousHandler) == "function" then
            return previousHandler(message)
        end
    end)
end

local joinPatterns = {
    "has joined the instance group",
    "has joined the battle",
    "has joined the arena",
    "has joined the battleground",
    "has entered the arena",
    "has entered the battleground",
    "has left the arena",
    "has left the battleground",
}

local function NormalizeMessage(message)
    if type(message) ~= "string" then
        return nil
    end

    local ok, normalized = pcall(function()
        return message
            :gsub("|c%x%x%x%x%x%x%x%x", "")
            :gsub("|r", "")
            :gsub("|H.-|h(.-)|h", "%1")
            :lower()
    end)

    if not ok then
        return nil
    end

    return normalized
end

local function IsJoinSpam(message)
    local normalized = NormalizeMessage(message)

    if not normalized then
        return false
    end

    for _, text in ipairs(joinPatterns) do
        local ok, found = pcall(function()
            return normalized:find(text, 1, true)
        end)

        if ok and found then
            return true
        end
    end

    return false
end

local function ChatFilter(_, _, message)
    EnsureDB()

    if not PvPCalloutsSilencerDB.enabled or not PvPCalloutsSilencerDB.suppressJoinMessages then
        return false
    end

    return IsJoinSpam(message)
end

local function RefreshOptionsPanel()
    if not optionsPanel then
        return
    end

    EnsureDB()

    for key, checkbox in pairs(controls) do
        checkbox:SetChecked(PvPCalloutsSilencerDB[key])
    end
end

local function SetOption(option, value, quiet)
    EnsureDB()
    PvPCalloutsSilencerDB[option] = value
    RefreshOptionsPanel()

    if not quiet then
        Print(option .. " " .. (value and "enabled" or "disabled") .. ".")
    end
end

local function PrintStatus()
    EnsureDB()
    Print("enabled=" .. tostring(PvPCalloutsSilencerDB.enabled)
        .. ", allTaint=" .. tostring(PvPCalloutsSilencerDB.suppressAllTaint)
        .. ", joins=" .. tostring(PvPCalloutsSilencerDB.suppressJoinMessages))
end

SLASH_PVPCALLOUTSSILENCER1 = "/pcsilence"
SLASH_PVPCALLOUTSSILENCER2 = "/pvpcsilence"
SlashCmdList.PVPCALLOUTSSILENCER = function(input)
    EnsureDB()
    input = (input or ""):lower():match("^%s*(.-)%s*$")

    if input == "on" then
        SetOption("enabled", true)
    elseif input == "off" then
        SetOption("enabled", false)
    elseif input == "taint on" then
        SetOption("suppressAllTaint", true)
    elseif input == "taint off" then
        SetOption("suppressAllTaint", false)
    elseif input == "joins on" then
        SetOption("suppressJoinMessages", true)
    elseif input == "joins off" then
        SetOption("suppressJoinMessages", false)
    elseif input == "quiet" then
        SetOption("announceLoad", false)
    elseif input == "status" or input == "" then
        PrintStatus()
    else
        Print("commands: /pcsilence on, off, status, taint on/off, joins on/off, quiet")
    end
end

local function CreateCheckbox(parent, key, label, description, yOffset)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 24, yOffset)
    checkbox:SetSize(26, 26)

    checkbox.label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkbox.label:SetPoint("LEFT", checkbox, "RIGHT", 8, 0)
    checkbox.label:SetText(label)

    checkbox.description = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    checkbox.description:SetPoint("TOPLEFT", checkbox.label, "BOTTOMLEFT", 0, -3)
    checkbox.description:SetWidth(520)
    checkbox.description:SetJustifyH("LEFT")
    checkbox.description:SetText(description)

    checkbox:SetScript("OnClick", function(self)
        SetOption(key, self:GetChecked(), true)
    end)

    controls[key] = checkbox
end

local function RegisterOptionsPanel()
    optionsPanel = CreateFrame("Frame", "PvPCalloutsSilencerOptionsPanel")
    optionsPanel.name = "PvPCallouts Silencer"

    local title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("PvPCallouts Silencer")

    local subtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    subtitle:SetWidth(560)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetText("Suppress addon taint error spam and arena/battleground join spam.")

    CreateCheckbox(
        optionsPanel,
        "enabled",
        "Enable silencer",
        "Master switch for every filter in this addon.",
        -72
    )

    CreateCheckbox(
        optionsPanel,
        "suppressAllTaint",
        "Suppress addon taint errors",
        "Hides common taint error popups such as execution tainted by, blocked Blizzard UI actions, and inaccessible tainted tables.",
        -132
    )

    CreateCheckbox(
        optionsPanel,
        "suppressJoinMessages",
        "Suppress arena/BG join notices",
        "Filters repeated arena and battleground joined, entered, left, battle, and instance group system messages.",
        -206
    )

    CreateCheckbox(
        optionsPanel,
        "announceLoad",
        "Show load message",
        "Prints one small chat line when the addon loads.",
        -280
    )

    optionsPanel:SetScript("OnShow", RefreshOptionsPanel)

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
        Settings.RegisterAddOnCategory(category)
        optionsPanel.category = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(optionsPanel)
    end

    RefreshOptionsPanel()
end

local chatEvents = {
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_BG_SYSTEM_ALLIANCE",
    "CHAT_MSG_BG_SYSTEM_HORDE",
    "CHAT_MSG_BG_SYSTEM_NEUTRAL",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
}

local function RegisterChatFilters()
    if type(ChatFrame_AddMessageEventFilter) ~= "function" then
        return
    end

    for _, eventName in ipairs(chatEvents) do
        ChatFrame_AddMessageEventFilter(eventName, ChatFilter)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, addonName)
    if event ~= "ADDON_LOADED" or addonName ~= ADDON_NAME then
        return
    end

    EnsureDB()
    InstallErrorFilter()
    RegisterOptionsPanel()
    RegisterChatFilters()

    if PvPCalloutsSilencerDB.announceLoad then
        Print("loaded. Open Options > AddOns > PvPCallouts Silencer.")
    end
end)
