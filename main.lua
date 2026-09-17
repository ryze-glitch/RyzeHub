-- language: Lua, file: main.lua, target: Roblox Steal An Egg
-- RyzeHub v4.1.0 (Optimized Edition)

if _G.RyzeHubLoaded then return end
_G.RyzeHubLoaded = true

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInput       = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Replicated      = game:GetService("ReplicatedStorage")
local Workspace       = game:GetService("Workspace")
local CoreGui         = game:GetService("CoreGui")
local LocalPlayer     = Players.LocalPlayer

-- UI Setup & Colors
local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:FindFirstChildOfClass("PlayerGui")
local C = {
    bg = Color3.fromRGB(16, 16, 22), bg2 = Color3.fromRGB(24, 24, 34),
    bg3 = Color3.fromRGB(32, 32, 46), bg4 = Color3.fromRGB(45, 45, 65),
    accent = Color3.fromRGB(140, 110, 255), ok = Color3.fromRGB(90, 220, 140),
    danger = Color3.fromRGB(240, 90, 100), text = Color3.fromRGB(240, 240, 250),
    sub = Color3.fromRGB(150, 150, 170),
}

-- State Management
local State = {
    HomeCF = nil, TargetNestCF = nil, SellCF = nil,
    HatchStandPart = nil, HatchStandPrompt = nil,
    AutoLoop = false, AutoHatch = false, HatchDelay = 1.5,
    MoveSpeed = 40, SpeedEnabled = false, Noclip = false
}

-- Helper Functions
local function getRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function triggerInteraction(obj)
    if not obj then return end
    -- Prova a trovare ProximityPrompt o ClickDetector
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or (obj:IsA("ProximityPrompt") and obj)
    local click = obj:FindFirstChildWhichIsA("ClickDetector", true)

    if prompt then
        if fireproximityprompt then fireproximityprompt(prompt) else prompt:InputHoldBegin() task.wait(0.1) prompt:InputHoldEnd() end
    elseif click then
        if fireclickdetector then fireclickdetector(click) else click:Fire() end
    end
end

-- CORE LOOPS
-- 1. Movement & Speed
RunService.Heartbeat:Connect(function()
    if State.SpeedEnabled then
        local root = getRoot()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = hum.MoveDirection.Unit * State.MoveSpeed + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- 2. Noclip
RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- 3. Farm Loop (TP & Interaction)
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoLoop and State.HomeCF and State.TargetNestCF then
            local root = getRoot()
            if root then
                -- Teleport to Enemy Nest
                root.CFrame = State.TargetNestCF + Vector3.new(0, 3, 0)
                task.wait(0.4)
                
                -- Interaction Area Scan
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
                        local pos = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Position or nil
                        if pos and (root.Position - pos).Magnitude < 15 then
                            triggerInteraction(obj.Parent)
                        end
                    end
                end
                task.wait(0.3)

                -- Teleport to Home/Sell
                if State.SellCF then
                    root.CFrame = State.SellCF + Vector3.new(0, 3, 0)
                else
                    root.CFrame = State.HomeCF + Vector3.new(0, 3, 0)
                end
                task.wait(0.5)
            end
        end
    end
end)

-- 4. Auto Hatch Loop
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoHatch and State.HatchStandPart then
            local root = getRoot()
            if root then
                root.CFrame = State.HatchStandPart.CFrame + Vector3.new(0, 3, 0)
                triggerInteraction(State.HatchStandPart)
                task.wait(State.HatchDelay)
            end
        end
    end
end)

-- Export State for UI
_G.RyzeState = State
