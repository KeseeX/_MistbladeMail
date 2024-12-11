-----------------------------------------------SETTINGS--------------------------------------------

local _G = getfenv(0)

local FOLDER_NAME, private = ...
local panel = _G.CreateFrame("Frame", "_MistbladeMailSettingsPanel")

panel.name = "_MistbladeMailSettings"
panel:Hide()

local panel_title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
panel_title:SetPoint("TOPLEFT", 16, -16)
panel_title:SetText("MistbladeMail Settings")

_MistbladeMailSettings = _MistbladeMailSettings or {}

local function CreateNumberedTextbox(number, text, previousNumberLabel)
    local numberLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    if previousNumberLabel then
        numberLabel:SetPoint("TOPLEFT", previousNumberLabel, "BOTTOMLEFT", 0, -12)
    else
        numberLabel:SetPoint("TOPLEFT", panel_title, "BOTTOMLEFT", 0, -24)
    end
    numberLabel:SetText(number .. ".")
    numberLabel:SetTextColor(1, 1, 1)

    -- Create the textbox next to the label
    local textbox = _G.CreateFrame("EditBox", "Textbox" .. number, panel, "InputBoxTemplate")
    textbox:SetSize(100, 15)
    textbox:SetPoint("TOPLEFT", numberLabel, "TOPRIGHT", 5, 0)
    textbox:SetAutoFocus(false)
    textbox:SetText(_MistbladeMailSettings["Textbox" .. number] or "")
    textbox:SetScript("OnEditFocusLost", function(self)
        _MistbladeMailSettings["Textbox" .. number] = self:GetText()
    end)

    -- Create the description text next to the textbox
    local descriptionText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    descriptionText:SetPoint("TOPLEFT", textbox, "TOPRIGHT", 5, 0)
    descriptionText:SetText(text)
    descriptionText:SetTextColor(1, 1, 1)

    return numberLabel, textbox, descriptionText
end

local numberLabel1, textbox1, description1 = CreateNumberedTextbox(1, "Default recipient of Motes and Spirits of Harmony (Account Bound)", nil)
local numberLabel2, textbox2, description2 = CreateNumberedTextbox(2, "Default recipient of Cooking Materials", numberLabel1)
local numberLabel3, textbox3, description3 = CreateNumberedTextbox(3, "Default recipient of Cloths (Windwool and Embersilk)", numberLabel2)
local numberLabel4, textbox4, description4 = CreateNumberedTextbox(4, "Default recipient of Enchanting Materials", numberLabel3)
local numberLabel5, textbox5, description5 = CreateNumberedTextbox(5, "Default recipient of Raw Ores", numberLabel4)
local numberLabel6, textbox6, description6 = CreateNumberedTextbox(6, "Default recipient of Gems & Bars & Kyparite", numberLabel5)
local numberLabel7, textbox7, description7 = CreateNumberedTextbox(7, "Default recipient of Gathered Herbs", numberLabel6)
local numberLabel8, textbox8, description8 = CreateNumberedTextbox(8, "Default recipient of Lockboxes", numberLabel7)

local function SaveSettings()
    -- Save the values from textboxes into saved variables
    _MistbladeMailSettings["Textbox1Recipient"] = textbox1:GetText()
    _MistbladeMailSettings["Textbox2Recipient"] = textbox2:GetText()
    _MistbladeMailSettings["Textbox3Recipient"] = textbox3:GetText()
    _MistbladeMailSettings["Textbox4Recipient"] = textbox4:GetText()
    _MistbladeMailSettings["Textbox5Recipient"] = textbox5:GetText()
    _MistbladeMailSettings["Textbox6Recipient"] = textbox6:GetText()
    _MistbladeMailSettings["Textbox7Recipient"] = textbox7:GetText()
    _MistbladeMailSettings["Textbox8Recipient"] = textbox8:GetText()

    -- Print confirmation
    print("|cFFCD7F32MistbladeMail:|r Settings have been saved.")
end

-- Save button
local saveButton = _G.CreateFrame("Button", "SaveSettingsButton", panel, "UIPanelButtonTemplate")
saveButton:SetSize(120, 24)
saveButton:SetPoint("TOPLEFT", description8, "BOTTOMLEFT", 0, -16)
saveButton:SetText("Save Settings")
saveButton:SetScript("OnClick", SaveSettings)

local function RegisterPanel()
    InterfaceOptions_AddCategory(panel)
end

-- Slash command to open the settings panel
SLASH_MISTBLADEMAILSETTINGS1 = "/mbmail"
SlashCmdList["MISTBLADEMAILSETTINGS"] = function()
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel)  -- Second call
end

RegisterPanel()

panel:SetScript("OnShow", function()
    textbox1:SetText(_MistbladeMailSettings["Textbox1Recipient"] or "")
    textbox2:SetText(_MistbladeMailSettings["Textbox2Recipient"] or "")
    textbox3:SetText(_MistbladeMailSettings["Textbox3Recipient"] or "")
    textbox4:SetText(_MistbladeMailSettings["Textbox4Recipient"] or "")
    textbox5:SetText(_MistbladeMailSettings["Textbox5Recipient"] or "")
    textbox6:SetText(_MistbladeMailSettings["Textbox6Recipient"] or "")
    textbox7:SetText(_MistbladeMailSettings["Textbox7Recipient"] or "")
    textbox8:SetText(_MistbladeMailSettings["Textbox8Recipient"] or "")
end)

--------------------------------------------------------------------------------------------MISTBLADEMAIL_EVENTS-------------------------------------------------------------------------

local lockboxFrame = CreateFrame("Frame", "_MistbladeMailEvents")

lockboxFrame:RegisterEvent("MAIL_SHOW")
lockboxFrame:RegisterEvent("BAG_UPDATE")  -- Listen to bag updates

-- Function to check if items are in the player's bags
local function hasItemsInBags(itemList)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                for _, lockbox in ipairs(itemList) do
                    if itemName and itemName == lockbox then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Function to send items to a specific character based on item list
local function sendItemsToCharacter(characterName, itemList)
    local itemsToSend = {}

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                for _, lockbox in ipairs(itemList) do
                    if itemName and itemName == lockbox then
                        table.insert(itemsToSend, {bag, slot})
                    end
                end
            end
        end
    end

    -- If items to send are found, send them to the specified character
    if #itemsToSend > 0 then
        for _, item in ipairs(itemsToSend) do
            local bag, slot = item[1], item[2]
            PickupContainerItem(bag, slot)
            ClickSendMailItemButton()
        end
        SendMail(characterName, "Items", "")
        print("|cFFCD7F32MistbladeMail:|r Sending items to " .. characterName .. ".")
    else
        print("|cFFCD7F32MistbladeMail:|r No items found in bags.")
    end
end

-- Function to enable or disable a button based on specific items in bags
local function checkItemsInBags(button, itemList)
    if hasItemsInBags(itemList) then
        button:Enable()
        button:SetBackdropBorderColor(0, 1, 0)
    else
        button:Disable()
        button:SetBackdropBorderColor(0.5, 0.5, 0.5)
    end
end

local function createMailboxButton(buttonText, buttonPosition, recipientKey, itemList)
    local button = CreateFrame("Button", nil, MailFrame, "UIPanelButtonTemplate")
    button:SetSize(100, 45)
    button:SetPoint("RIGHT", MailFrame, "RIGHT", buttonPosition[1], buttonPosition[2])
    button:SetText(buttonText)

    local tabClicked = false

    -- OnClick script for the button to execute commands
    button:SetScript("OnClick", function()
        if not tabClicked then
            MailFrameTab2:Click()
            tabClicked = true
        end
    
        local recipientName = _MistbladeMailSettings[recipientKey]

        if recipientName and recipientName ~= "" then
            sendItemsToCharacter(recipientName, itemList)
        else
            print("|cFFCD7F32MistbladeMail:|r Recipient for " .. buttonText .. " is missing or empty in settings. Type /mbmail to open |cFFCD7F32MistbladeMail|r settings.")
        end

        checkItemsInBags(button, itemList)
    end)

    -- Update button state every second to reflect bag content changes
    C_Timer.NewTicker(1, function()
        checkItemsInBags(button, itemList)
    end)

    checkItemsInBags(button, itemList)

    return button
end

-- MAIL_SHOW and BAG_UPDATE handler
lockboxFrame:SetScript("OnEvent", function(self, event)
    if event == "MAIL_SHOW" then
        if not lockboxFrame.buttons then lockboxFrame.buttons = {} end
        for i = 1, #lockboxFrame.buttons do
            lockboxFrame.buttons[i]:Hide()
        end

        lockboxFrame.buttons = {}

        -- Create buttons individually
        local harmonyButton = createMailboxButton("Harmony", {95, 195}, "Textbox1Recipient", {"Mote of Harmony", "Spirit of Harmony"})
        table.insert(lockboxFrame.buttons, harmonyButton)

        local cookingButton = createMailboxButton("Cooking", {95, 150}, "Textbox2Recipient", {"100 Year Soy Sauce", "Black Pepper", "Rice Flour", "Barley", "Farm Chicken", "Ginseng", "Instant Noodles", "Needle Mushrooms", "Pandaren Peach", "Red Beans", "Rice", "Silkworm Pupa", "Yak Milk", "Mushan Ribs", "Raw Crab Meat", "Raw Crocolisk Belly", "Raw Tiger Steak", "Raw Turtle Meat", "Viseclaw Meat", "Wildfowl Breast", "Green Cabbage", "Jade Squash", "Juicycrunch Carrot", "Mogu Pumpkin", "Pink Turnip", "Red Blossom Leek", "Scallions", "Striped Melon", "White Turnip", "Witchberries", "Emperor Salmon", "Giant Mantis Shrimp", "Golden Carp", "Jade Lungfish", "Jewel Danio", "Krasarang Paddlefish", "Redbelly Mandarin", "Reef Octopus", "Tiger Gourami", "Chun Tian Spring Rolls", "Black Pepper Ribs and Shrimp", "Mogu Fish Stew", "Steamed Crab Surprise", "Sea Mist Rice Noodles", "Mad Brewer's Breakfast", "Aged Balsamic Vinegar", "Aged Mogu'shan Cheese", "Ancient Pandaren Spices"})
        table.insert(lockboxFrame.buttons, cookingButton)

        local clothButton = createMailboxButton("Cloths", {95, 105}, "Textbox3Recipient", {"Embersilk Cloth", "Bolt of Embersilk Cloth", "Windwool Cloth", "Bolt of Windwool Cloth"})
        table.insert(lockboxFrame.buttons, clothButton)

        local enchantButton = createMailboxButton("Enchants", {95, 60}, "Textbox4Recipient", {"Spirit Dust", "Ethereal Shard", "Mysterious Essence", "Sha Crystal"})
        table.insert(lockboxFrame.buttons, enchantButton)

        local oresButton = createMailboxButton("Raw Ores", {95, 15}, "Textbox5Recipient", {"Ghost Iron Ore", "Black Trillium Ore", "White Trillium Ore"})
        table.insert(lockboxFrame.buttons, oresButton)

        local gemsBarsButton = createMailboxButton("Gems&Bars", {95, -30}, "Textbox6Recipient", {"Pandarian Garnet", "Roguestone", "Sunstone", "Tiger Opal", "Alexandrite", "Lapis Lazuli", "River's Heart", "Imperial Amethyst", "Primordial Ruby", "Sun's Radiance", "Vermilion Onyx", "Wild Jade", "Primal Diamond", "Ghost Iron Bar", "Kyparite", "Trillium Bar"})
        table.insert(lockboxFrame.buttons, gemsBarsButton)

        local herbsButton = createMailboxButton("Herbs", {95, -75}, "Textbox7Recipient", {"Rain Poppy", "Snow Lily", "Green Tea Leaf", "Silkweed", "Fool's Cap", "Desecrated Herb", "Golden Lotus", "Starlight Ink", "Book of Glyph Mastery"})
        table.insert(lockboxFrame.buttons, herbsButton)

        local lockboxButton = createMailboxButton("Lockboxes", {95, -120}, "Textbox8Recipient", {"Titanium Lockbox", "Elementium Lockbox", "Ghost Iron Lockbox"})
        table.insert(lockboxFrame.buttons, lockboxButton)

    elseif event == "BAG_UPDATE" then
        -- Update button states
        for _, button in ipairs(lockboxFrame.buttons) do
            if button and button:IsShown() then
                local itemList = button.itemList
                checkItemsInBags(button, itemList)
            end
        end
    end
end)

---------------------------------------OPEN/DELETE-BUTTONS-------------------------------------------
local MailManager = CreateFrame("Frame", "MailManager")

MailManager:RegisterEvent("MAIL_SHOW")
MailManager:RegisterEvent("MAIL_INBOX_UPDATE")
MailManager:SetScript("OnEvent", function(self, event)
    if event == "MAIL_SHOW" or event == "MAIL_INBOX_UPDATE" then
        MailManager:ShowButtons()
        MailManager:UpdateButtonStates()
    end
end)

function MailManager:ShowButtons()
    -- Button "Open"
    if not self.takeItemsButton then
        self.takeItemsButton = CreateFrame("Button", nil, MailFrame, "UIPanelButtonTemplate")
        self.takeItemsButton:SetSize(50, 25)
        self.takeItemsButton:SetText("Open")
        self.takeItemsButton:SetPoint("RIGHT", MailFrame, "RIGHT", 45, -202)
        self.takeItemsButton:SetScript("OnClick", function() MailManager:TakeItemsFromMail() end)
    end

    -- Button "Delete"
    if not self.deleteEmptyButton then
        self.deleteEmptyButton = CreateFrame("Button", nil, MailFrame, "UIPanelButtonTemplate")
        self.deleteEmptyButton:SetSize(50, 25)
        self.deleteEmptyButton:SetText("Del")
        self.deleteEmptyButton:SetPoint("RIGHT", MailFrame, "RIGHT", 95, -202)
        self.deleteEmptyButton:SetScript("OnClick", function() MailManager:DeleteEmptyMails() end)
    end

    -- Button "Open All"
    if not self.openAllButton then
        self.openAllButton = CreateFrame("Button", nil, MailFrame, "UIPanelButtonTemplate")
        self.openAllButton:SetSize(100, 45)
        self.openAllButton:SetText("Open All")
        self.openAllButton:SetPoint("RIGHT", MailFrame, "RIGHT", 95, -165)
        self.openAllButton:SetScript("OnClick", function() MailManager:OpenAllMails() end)
    end

    -- Show the buttons
    self.takeItemsButton:Show()
    self.deleteEmptyButton:Show()
    self.openAllButton:Show()
end

function MailManager:UpdateButtonStates()
    local mailCount = GetInboxNumItems()
    local hasMail = mailCount > 0

    -- Enable or disable buttons based on mailbox state
    self.takeItemsButton:SetEnabled(hasMail)
    self.deleteEmptyButton:SetEnabled(hasMail)
    self.openAllButton:SetEnabled(hasMail)
end

-- Function to take items, excluding letters
function MailManager:TakeItemsFromMail()
    MiniMapMailFrame:Hide(4)
    for i = 1, GetInboxNumItems() do
        local _, _, _, _, _, _, _, hasItem = GetInboxHeaderInfo(i)
        if hasItem then
            AutoLootMailItem(i)
        end
    end
end

-- Function to delete empty mails (or mails with letter only)
function MailManager:DeleteEmptyMails()
    MiniMapMailFrame:Hide(4)
    for i = GetInboxNumItems(), 1, -1 do
        local _, _, _, _, money, CODAmount, _, hasItem = GetInboxHeaderInfo(i)
        if not hasItem and money == 0 and CODAmount == 0 then
            DeleteInboxItem(i)
        end
    end
end

-- Function to open all mails, excluding COD
function MailManager:OpenAllMails()
    print("|cFFCD7F32MistbladeMail:|r opening all available mails.")
    MiniMapMailFrame:Hide(4)
    local function ProcessMails()
        local mailCount = GetInboxNumItems()
        local hasMail = mailCount > 0
        local foundItems = false

        for mailIndex = mailCount, 1, -1 do
            local _, _, _, _, money, CODAmount, _, hasItem = GetInboxHeaderInfo(mailIndex)

            if CODAmount == 0 then -- Skip COD mails
                if money > 0 then
                    TakeInboxMoney(mailIndex)
                    foundItems = true
                end

                if hasItem then
                    for attachmentIndex = 1, ATTACHMENTS_MAX do
                        TakeInboxItem(mailIndex, attachmentIndex)
                    end
                    foundItems = true
                end

                if money == 0 and not hasItem then
                    DeleteInboxItem(mailIndex)
                end
            end
        end

        if foundItems then
            C_Timer.After(0.1, ProcessMails)
        end
    end

    ProcessMails()
end
