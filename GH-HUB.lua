--[[
    GH HUB v1.0 - UI starter
    Dark/Purple theme | Touch + mouse draggable
    Tabs: Profile / Main / Settings

    This file contains the interface only. The Main tab controls are placeholders;
    they do not automate gameplay.
    Intended for a Roblox experience you own/control. For Roblox Studio, place this
    in a LocalScript (for example under StarterPlayerScripts).
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
    warn("GH HUB: LocalPlayer not available. Run this from a LocalScript.")
    return
end

local PURPLE = Color3.fromRGB(153, 86, 255)
local BG = Color3.fromRGB(18, 18, 27)
local PANEL = Color3.fromRGB(27, 27, 40)
local TEXT = Color3.fromRGB(242, 240, 255)
local MUTED = Color3.fromRGB(166, 163, 184)

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("GHHUB")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GHHUB"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(560, 360)
main.Position = UDim2.new(0.5, -280, 0.5, -180)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = PURPLE
mainStroke.Transparency = 0.25
mainStroke.Thickness = 1.5
mainStroke.Parent = main

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = PANEL
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerCover = Instance.new("Frame")
headerCover.Position = UDim2.new(0, 0, 1, -12)
headerCover.Size = UDim2.new(1, 0, 0, 12)
headerCover.BackgroundColor3 = PANEL
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 0)
title.Size = UDim2.new(1, -100, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "GH HUB  |  v1.0"
title.TextColor3 = TEXT
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -42, 0, 9)
close.BackgroundColor3 = Color3.fromRGB(70, 43, 83)
close.Text = "×"
close.TextColor3 = TEXT
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.Activated:Connect(function() gui:Destroy() end)

-- Dragging support for mouse and touch.
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.fromOffset(12, 60)
sidebar.Size = UDim2.new(0, 132, 1, -72)
sidebar.BackgroundColor3 = PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 8)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

local sidePadding = Instance.new("UIPadding")
sidePadding.PaddingTop = UDim.new(0, 12)
sidePadding.PaddingLeft = UDim.new(0, 8)
sidePadding.PaddingRight = UDim.new(0, 8)
sidePadding.Parent = sidebar

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(156, 60)
content.Size = UDim2.new(1, -168, 1, -72)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local tabButtons = {}
local activeTab = "Profile"

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = PURPLE
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page

    pages[name] = page
    return page
end

local function label(parent, text, size, color)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1
    item.Size = UDim2.new(1, 0, 0, size or 24)
    item.Font = Enum.Font.Gotham
    item.Text = text
    item.TextColor3 = color or TEXT
    item.TextSize = 14
    item.TextWrapped = true
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Parent = parent
    return item
end

local function card(parent, height)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, height or 70)
    frame.BackgroundColor3 = PANEL
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    return frame
end

local function addTab(name, order)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.LayoutOrder = order
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = name == activeTab and PURPLE or PANEL
    button.Text = name
    button.TextColor3 = TEXT
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.Parent = sidebar
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    tabButtons[name] = button

    button.Activated:Connect(function()
        activeTab = name
        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end
        for tabName, tab in pairs(tabButtons) do
            tab.BackgroundColor3 = tabName == name and PURPLE or PANEL
        end
    end)
end

local profilePage = createPage("Profile")
local mainPage = createPage("Main")
local settingsPage = createPage("Settings")

addTab("Profile", 1)
addTab("Main", 2)
addTab("Settings", 3)
profilePage.Visible = true

local profileCard = card(profilePage, 112)
local avatar = Instance.new("ImageLabel")
avatar.Position = UDim2.fromOffset(12, 12)
avatar.Size = UDim2.fromOffset(78, 78)
avatar.BackgroundColor3 = BG
avatar.BorderSizePixel = 0
avatar.Image = ""
avatar.Parent = profileCard
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if ok and avatar.Parent then avatar.Image = image end
end)

local profileText = Instance.new("Frame")
profileText.Position = UDim2.fromOffset(104, 13)
profileText.Size = UDim2.new(1, -116, 1, -20)
profileText.BackgroundTransparency = 1
profileText.Parent = profileCard
local profileLayout = Instance.new("UIListLayout")
profileLayout.Padding = UDim.new(0, 4)
profileLayout.Parent = profileText
label(profileText, player.DisplayName, 22, TEXT).Font = Enum.Font.GothamBold
label(profileText, "@" .. player.Name, 20, MUTED)
label(profileText, "User ID: " .. tostring(player.UserId), 20, MUTED)

label(profilePage, "PLAYER INFORMATION", 22, PURPLE).Font = Enum.Font.GothamBold
local levelText = label(profilePage, "Level: checking leaderstats…", 24, TEXT)
task.spawn(function()
    local stats = player:WaitForChild("leaderstats", 8)
    local levelValue = stats and (stats:FindFirstChild("Level") or stats:FindFirstChild("level"))
    if levelValue then
        levelText.Text = "Level: " .. tostring(levelValue.Value)
        levelValue:GetPropertyChangedSignal("Value"):Connect(function()
            levelText.Text = "Level: " .. tostring(levelValue.Value)
        end)
    else
        levelText.Text = "Level: unavailable in this experience"
    end
end)
label(profilePage, "GH HUB is a community UI starter.", 28, MUTED)

label(mainPage, "MAIN FEATURES", 24, PURPLE).Font = Enum.Font.GothamBold
label(mainPage, "Các nút bên dưới hiện là công tắc giao diện, chưa thực hiện hành động trong game.", 42, MUTED)

local function addToggle(parent, text)
    local row = card(parent, 48)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.fromOffset(12, 0)
    nameLabel.Size = UDim2.new(1, -90, 1, 0)
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.Text = text
    nameLabel.TextColor3 = TEXT
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = row

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(54, 28)
    toggle.Position = UDim2.new(1, -66, 0.5, -14)
    toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 80)
    toggle.Text = "OFF"
    toggle.TextColor3 = TEXT
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = row
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

    local enabled = false
    toggle.Activated:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ON" or "OFF"
        toggle.BackgroundColor3 = enabled and PURPLE or Color3.fromRGB(65, 65, 80)
    end)
end

addToggle(mainPage, "Auto Farm Level (UI only)")
addToggle(mainPage, "Auto Farm Boss (UI only)")
addToggle(mainPage, "Auto Quest (UI only)")
addToggle(mainPage, "Auto Equip Weapon (UI only)")
addToggle(mainPage, "Fast Attack (UI only)")

label(settingsPage, "SETTINGS", 24, PURPLE).Font = Enum.Font.GothamBold
label(settingsPage, "Menu size", 20, TEXT)

local function addSettingButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = PANEL
    button.Text = text
    button.TextColor3 = TEXT
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.Activated:Connect(callback)
    return button
end

local sizes = {
    Small = UDim2.fromOffset(460, 300),
    Normal = UDim2.fromOffset(560, 360),
    Large = UDim2.fromOffset(680, 430),
}
for _, sizeName in ipairs({"Small", "Normal", "Large"}) do
    addSettingButton(settingsPage, sizeName, function()
        local size = sizes[sizeName]
        main.Size = size
        main.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    end)
end

label(settingsPage, "Accent color", 20, TEXT)
local colors = {
    Purple = Color3.fromRGB(153, 86, 255),
    Blue = Color3.fromRGB(75, 135, 255),
    Red = Color3.fromRGB(245, 82, 105),
    Green = Color3.fromRGB(70, 200, 130),
    Pink = Color3.fromRGB(255, 90, 190),
}
for colorName, colorValue in pairs(colors) do
    addSettingButton(settingsPage, colorName, function()
        mainStroke.Color = colorValue
        mainStroke.Transparency = 0.25
        for tabName, tab in pairs(tabButtons) do
            tab.BackgroundColor3 = tabName == activeTab and colorValue or PANEL
        end
        for _, child in ipairs(settingsPage:GetChildren()) do
            if child:IsA("TextButton") and child.Text == colorName then
                child.BackgroundColor3 = colorValue
            end
        end
    end)
end

print("GH HUB v1.0 UI loaded.")
