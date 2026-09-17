-- language: Lua, file: loader.lua, target: Roblox Steal An Egg
-- RyzeHub v4.5.0 — UI & Loader

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ATTESA CARICAMENTO CORE (Fondamentale!)
while not _G.RyzeState do task.wait() end
local State = _G.RyzeState

-- CONFIGURAZIONE COLORI
local C = {
    bg = Color3.fromRGB(15, 15, 20), bg2 = Color3.fromRGB(25, 25, 35),
    accent = Color3.fromRGB(140, 110, 255), ok = Color3.fromRGB(90, 220, 140),
    danger = Color3.fromRGB(240, 90, 100), text = Color3.fromRGB(255, 255, 255),
    sub = Color3.fromRGB(150, 150, 170),
}

-- FUNZIONI UTILI UI
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function stroke(p, col) local s = Instance.new("UIStroke"); s.Color = col or Color3.fromRGB(40, 40, 50); s.Parent = p; return s end

-- COSTUZIONE GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RyzeHub_UI"
ScreenGui.Parent = (gethui and gethui()) or CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = C.bg
MainFrame.Parent = ScreenGui
corner(MainFrame, 10); stroke(MainFrame, C.bg2)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = C.bg2
Title.Text = "RYZEHUB PRO LOADER"
Title.TextColor3 = C.text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame
corner(Title, 10)

-- AREA CONTENUTI (TABS)
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Content

-- API PER CREARE ELEMENTI
local function addToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = C.bg2
    btn.Text = "  " .. text .. ": OFF"
    btn.TextColor3 = C.sub
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Content
    corner(btn, 6)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = "  " .. text .. (enabled and ": ON" or ": OFF")
        btn.TextColor3 = enabled and C.ok or C.sub
        callback(enabled)
    end)
end

local function addButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = C.bg2
    btn.Text = text
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = Content
    corner(btn, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- AGGIUNTA FUNZIONI REALI AL MENU
addButton(Content, "📍 Save Home", function()
    local r = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if r then State.HomePos = r.CFrame end
end)

addButton(Content, "🎯 Save Target", function()
    local r = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if r then State.TargetPos = r.CFrame end
end)

addToggle(Content, "Auto Farm Loop", function(v) State.AutoFarm = v end)
addToggle(Content, "Speed Hack", function(v) State.SpeedEnabled = v end)
addToggle(Content, "Noclip", function(v) State.Noclip = v end)
addToggle(Content, "Auto Hatch", function(v) State.AutoHatch = v end)

-- CHIUDI
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = C.bg2
close.Text = "X"
close.TextColor3 = C.danger
close.Parent = MainFrame
corner(close, 5)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() _G.RyzeHubLoaded = false end)

print("[RyzeHub] UI Loaded Successfully")
