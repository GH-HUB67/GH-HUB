--[[
    ╔══════════════════════════════════════════════════════════╗
    ║                  GH HUB  |  BLOX FRUITS                  ║
    ║                    Version: 1.01                         ║
    ║                  Made by GH-HUB67                        ║
    ║                                                          ║
    ║  Loader:                                                 ║
    ║  loadstring(game:HttpGet("https://raw.githubusercontent  ║
    ║  .com/GH-HUB67/GH-HUB/main/GH-HUB-v1.01.lua"))()         ║
    ╚══════════════════════════════════════════════════════════╝
]]

--============================================================
-- VERSION & UPDATE INFO
--============================================================
local GH_HUB = {
    Name    = "GH HUB",
    Version = "1.01",
    Author  = "GH-HUB67",
    RawURL  = "https://raw.githubusercontent.com/GH-HUB67/GH-HUB/main/GH-HUB-v1.01.lua"
}

--============================================================
-- SERVICES & PLAYER
--============================================================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser  = game:GetService("VirtualUser")
local UserInput    = game:GetService("UserInputService")
local HttpService  = game:GetService("HttpService")

local LP = Players.LocalPlayer

--============================================================
-- RAYFIELD UI
--============================================================
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not ok or not Rayfield then
    warn("[GH HUB] Không tải được Rayfield UI. Kiểm tra kết nối mạng.")
    return
end

local Window = Rayfield:CreateWindow({
    Name            = "GH HUB | Blox Fruits",
    LoadingTitle    = "GH HUB v" .. GH_HUB.Version .. " đang tải...",
    LoadingSubtitle = "by " .. GH_HUB.Author,
    Theme           = "Ocean",
    ConfigurationSaving = {
        Enabled     = true,
        FolderName  = "GHHub",
        FileName    = "GHHubConfig"
    },
    KeySystem = false
})

--============================================================
-- STATE
--============================================================
local State = {
    AutoFarmLevel  = false,
    AutoFarmBoss   = false,
    AutoFarmChest  = false,
    AutoHaki       = false,
    AutoSelectTool = true,
    AntiAFK        = true,
    BringMobs      = false,
    FarmDelay      = 0.15,
    AttackRange    = 200,
}

--============================================================
-- HELPERS
--============================================================
local function getChar() return LP.Character end
local function getHRP()
    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end
local function notify(title, content, dur)
    Rayfield:Notify({ Title = title or GH_HUB.Name, Content = content or "", Duration = dur or 3 })
end

local function teleport(pos)
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

local function tweenTo(pos, speed)
    local hrp = getHRP(); if not hrp then return end
    speed = speed or 200
    local dist = (hrp.Position - pos).Magnitude
    TweenService:Create(
        hrp,
        TweenInfo.new(dist / speed, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(pos) }
    ):Play()
end

local function equipBestTool()
    local char = getChar(); if not char then return end
    local backpack = LP:FindFirstChildOfClass("Backpack"); if not backpack then return end
    local keywords = { "sword", "blade", "melee", "fruit" }
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            for _, kw in ipairs(keywords) do
                if n:find(kw) then getHum():EquipTool(tool); return end
            end
        end
    end
    local first = backpack:FindFirstChildOfClass("Tool")
    if first then getHum():EquipTool(first) end
end

local function activateTool()
    local char = getChar(); if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
end

--============================================================
-- ANTI-AFK
--============================================================
LP.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

--============================================================
-- TAB 1: FARM
--============================================================
local FarmTab = Window:CreateTab("🌾 Farm", 4483362458)
local FarmSec = FarmTab:CreateSection("Tự động Farm")

FarmTab:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = false, Flag = "AutoFarmLevel",
    Callback = function(v)
        State.AutoFarmLevel = v
        notify(nil, v and "Đã BẬT Auto Farm Level" or "Đã TẮT Auto Farm Level")
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Farm Boss",
    CurrentValue = false, Flag = "AutoFarmBoss",
    Callback = function(v)
        State.AutoFarmBoss = v
        notify(nil, v and "Đã BẬT Auto Farm Boss" or "Đã TẮT Auto Farm Boss")
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Farm Chest",
    CurrentValue = false, Flag = "AutoFarmChest",
    Callback = function(v) State.AutoFarmChest = v end,
})

FarmTab:CreateToggle({
    Name = "Auto Haki",
    CurrentValue = false, Flag = "AutoHaki",
    Callback = function(v) State.AutoHaki = v end,
})

FarmTab:CreateToggle({
    Name = "Auto Equip Tool",
    CurrentValue = true, Flag = "AutoSelectTool",
    Callback = function(v) State.AutoSelectTool = v end,
})

FarmTab:CreateSlider({
    Name = "Farm Delay (giây)",
    Range = { 0, 1 }, Increment = 0.05, Suffix = "s",
    CurrentValue = 0.15, Flag = "FarmDelay",
    Callback = function(v) State.FarmDelay = v end,
})

FarmTab:CreateSlider({
    Name = "Attack Range",
    Range = { 50, 500 }, Increment = 10, Suffix = " studs",
    CurrentValue = 200, Flag = "AttackRange",
    Callback = function(v) State.AttackRange = v end,
})

--============================================================
-- TAB 2: TELEPORT
--============================================================
local TpTab = Window:CreateTab("✈️ Teleport", 4483362458)
local IslandSec = TpTab:CreateSection("Đảo (Sea 1) — cập nhật tọa độ theo game")

local Islands = {
    ["Bandit Starter"] = Vector3.new(0, 50, 0),
    ["Jungle"]         = Vector3.new(-1000, 50, 1000),
    ["Pirate Village"] = Vector3.new(500, 50, -1500),
    ["Desert"]         = Vector3.new(1500, 50, 500),
    ["Frozen Village"] = Vector3.new(-2000, 50, -800),
    ["Marine Ford"]    = Vector3.new(3000, 50, 3000),
    ["Sky Islands"]    = Vector3.new(-4000, 300, 4000),
}

for name, pos in pairs(Islands) do
    IslandSec:CreateButton({
        Name = name,
        Callback = function()
            teleport(pos)
            notify("Teleport", "Đã đến " .. name)
        end,
    })
end

local BossSec = TpTab:CreateSection("Boss")
local Bosses = {
    ["Gorilla King"] = Vector3.new(-1200, 50, 1200),
    ["Yeti"]         = Vector3.new(-2000, 50, -900),
    ["Ice Admiral"]  = Vector3.new(-2100, 50, -1000),
    ["Diamond"]      = Vector3.new(1600, 50, 600),
    ["Cyborg"]       = Vector3.new(3100, 50, 3100),
}

for name, pos in pairs(Bosses) do
    BossSec:CreateButton({
        Name = name,
        Callback = function()
            teleport(pos)
            notify("Teleport", "Đã đến Boss: " .. name)
        end,
    })
end

--============================================================
-- TAB 3: PLAYER
--============================================================
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
PlayerTab:CreateSection("Chỉ số")

PlayerTab:CreateSlider({
    Name = "Walk Speed", Range = { 16, 350 }, Increment = 1,
    CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(v)
        local h = getHum(); if h then h.WalkSpeed = v end
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power", Range = { 50, 500 }, Increment = 10,
    CurrentValue = 50, Flag = "JumpPower",
    Callback = function(v)
        local h = getHum()
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end,
})

PlayerTab:CreateButton({
    Name = "Reset chỉ số",
    Callback = function()
        local h = getHum()
        if h then h.WalkSpeed = 16; h.JumpPower = 50 end
        notify("Player", "Đã reset chỉ số")
    end,
})

--============================================================
-- TAB 4: SETTINGS
--============================================================
local SetTab = Window:CreateTab("⚙️ Settings", 4483362458)
SetTab:CreateSection("Tiện ích")

SetTab:CreateToggle({
    Name = "Anti-AFK", CurrentValue = true, Flag = "AntiAFK",
    Callback = function(v) State.AntiAFK = v end,
})

SetTab:CreateToggle({
    Name = "Bring Mobs", CurrentValue = false, Flag = "BringMobs",
    Callback = function(v)
        State.BringMobs = v
        notify(nil, v and "Đã BẬT Bring Mobs" or "Đã TẮT Bring Mobs")
    end,
})

SetTab:CreateButton({
    Name = "Hop Server",
    Callback = function()
        local TS = game:GetService("TeleportService")
        local s = game:GetService("Players").LocalPlayer
        TS:Teleport(game.PlaceId, s)
    end,
})

SetTab:CreateButton({
    Name = "Check Update",
    Callback = function()
        local okFetch, body = pcall(function()
            return game:HttpGet(GH_HUB.RawURL .. "?t=" .. tick())
        end)
        if not okFetch or not body then
            notify("Update", "Không kiểm tra được. Kiểm tra mạng.")
            return
        end
        local ver = body:match("Version:%s*([%d%.]+)")
        if ver and ver ~= GH_HUB.Version then
            notify("Update", "Có bản mới v" .. ver .. "! Chạy lại loader để cập nhật.", 5)
        else
            notify("Update", "Bạn đang dùng bản mới nhất v" .. GH_HUB.Version)
        end
    end,
})

SetTab:CreateButton({
    Name = "Unload GH HUB",
    Callback = function() Rayfield:Destroy() end,
})

--============================================================
-- LOGIC: TÌM MOB
--============================================================
local function getNearestMob(range)
    local hrp = getHRP(); if not hrp then return nil end
    local nearest, dist = nil, range or State.AttackRange
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
            and obj:FindFirstChildOfClass("Humanoid")
            and obj:FindFirstChild("HumanoidRootPart")
            and obj ~= getChar()
        then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local d = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
                if d < dist then nearest, dist = obj, d end
            end
        end
    end
    return nearest
end

--============================================================
-- VÒNG LẶP FARM
--============================================================
task.spawn(function()
    while true do
        task.wait(State.FarmDelay)
        local hrp = getHRP()

        if State.AutoFarmLevel and hrp then
            local target = getNearestMob(State.AttackRange)
            if target and target:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                if State.AutoSelectTool then equipBestTool() end
                activateTool()
                task.wait(0.1)
                activateTool()
            end
        end

        if State.AutoFarmBoss and hrp then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model")
                    and obj:FindFirstChildOfClass("Humanoid")
                    and obj.Humanoid.Health > 0
                    and obj:FindFirstChild("HumanoidRootPart")
                    and string.find(string.lower(obj.Name), "boss")
                then
                    hrp.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                    if State.AutoSelectTool then equipBestTool() end
                    activateTool()
                    break
                end
            end
        end

        if State.AutoFarmChest and hrp then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model")
                    and (string.find(string.lower(obj.Name), "chest")
                    or string.find(string.lower(obj.Name), "treasure"))
                    and obj:FindFirstChild("HumanoidRootPart")
                then
                    if (hrp.Position - obj.HumanoidRootPart.Position).Magnitude < 400 then
                        teleport(obj.HumanoidRootPart.Position)
                        break
                    end
                end
            end
        end

        if State.AutoHaki then
            local char = getChar()
            local haki = char and char:FindFirstChild("Haki")
            if haki and haki:IsA("BoolValue") and not haki.Value then
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("Haki")
                end)
            end
        end

        if State.BringMobs and hrp then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model")
                    and obj:FindFirstChildOfClass("Humanoid")
                    and obj:FindFirstChild("HumanoidRootPart")
                    and obj ~= getChar()
                    and not Players:GetPlayerFromCharacter(obj)
                    and (hrp.Position - obj.HumanoidRootPart.Position).Magnitude < 500
                then
                    obj.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 5)
                end
            end
        end
    end
end)

--============================================================
-- KHỞI ĐỘNG
--============================================================
notify("GH HUB v" .. GH_HUB.Version, "Đã tải thành công! Chúc bạn chơi vui 🎉", 5)