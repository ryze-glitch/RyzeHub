-- language: Lua, file: loader.lua, target: Roblox Steal An Egg
-- RyzeHub v4.1.0 — UI & Loader

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Attesa caricamento Core
while not _G.RyzeState do task.wait() end
local State = _G.RyzeState

-- Colori e Configurazione
local C = {
    bg = Color3.fromRGB(16, 16, 22), bg2 = Color3.fromRGB(24, 24, 34),
    bg3 = Color3.fromRGB(32, 32, 46), bg4 = Color3.fromRGB(45, 45, 65),
    accent = Color3.fromRGB(140, 110, 255), ok = Color3.fromRGB(90, 220, 140),
    danger = Color3.fromRGB(240, 90, 100), text = Color3.fromRGB(240, 240, 250),
    sub = Color3.fromRGB(150, 150, 170),
}

-- Helper UI
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function stroke(p, col) local s = Instance.new("UIStroke"); s.Color = col or C.bg4; s.Parent = p; return s end
local function tw(obj, dur, props) TweenService:Create(obj, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

local function getRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- Costruzione GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RyzeHub_Loader"
gui.Parent = (gethui and gethui()) or CoreGui

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 450, 0, 300)
win.Position = UDim2.new(0.5, -225, 0.5, -150)
win.BackgroundColor3 = C.bg
win.Parent = gui
corner(win, 10); stroke(win, C.bg4)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = C.bg2
topBar.Parent = win
corner(topBar, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "RyzeHub Pro Loader"
title.TextColor3 = C.text
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Sidebar & Tabs
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -45)
sidebar.Position = UDim2.new(0, 10, 0, 40)
sidebar.BackgroundColor3 = C.bg2
sidebar.Parent = win
corner(sidebar, 8)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -130, 1, -50)
content.Position = UDim2.new(0, 125, 0, 40)
content.BackgroundTransparency = 1
content.Parent = win

local tabs = {}
local activeTab = nil

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = C.bg3
    btn.Text = name
    btn.TextColor3 = C.sub
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = sidebar
    corner(btn, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.Parent = content
    
    local pL = Instance.new("UIListLayout"); pL.Padding = UDim.new(0, 6); pL.Parent = page
    
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(tabs) do p.Visible = (n == name) end
        for n, b in pairs(tabs) do
            local isTab = (n == name)
            tw(btn, 0.2, {BackgroundColor3 = isTab and C.accent or C.bg3})
        end
    end)
    
    tabs[name] = page
    return page
end

-- API per Bottoni/Toggle
local function addToggle(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = C.bg2
    btn.Text = "  " .. text .. ": OFF"
    btn.TextColor3 = C.sub
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = page
    corner(btn, 6)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = "  " .. text .. (enabled and ": ON" or ": OFF")
        btn.TextColor3 = enabled and C.ok or C.sub
        callback(enabled)
    end)
end

local function addButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = C.bg2
    btn.Text = text
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = page
    corner(btn, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- Costruzione Menu
local FarmTab = createTab("Farm")
local MoveTab = createTab("Move")
local HatchTab = createTab("Hatch")

-- Farm
addButton(FarmTab, "📍 Save Home", function()
    local r = getRoot()
    if r then State.HomeCF = r.CFrame end
end)

addButton(FarmTab, "🎯 Save Target", function()
    local r = getRoot()
    if r then State.TargetNestCF = r.CFrame end
end)

addToggle(FarmTab, "Auto Farm Loop", function(v) State.AutoLoop = v end)

-- Movement
addToggle(MoveTab, "Speed Hack", function(v) State.SpeedEnabled = v end)
addToggle(MoveTab, "Noclip", function(v) State.Noclip = v end)

-- Hatch
addToggle(HatchTab, "Auto Hatch", function(v) State.AutoHatch = v end)

-- Close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = C.bg3
close.Text = "X"
close.TextColor3 = C.danger
close.Parent = topBar
corner(close, 5)
close.MouseButton1Click:Connect(function() gui:Destroy() _G.RyzeHubLoaded = false end)

print("RyzeHub Loader Ready")
