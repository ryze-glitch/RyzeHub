-- language: Lua, file: main.lua, target: Roblox Steal An Egg
-- RyzeHub v4.1.0 — Core Engine

if _G.RyzeHubLoaded then return end
_G.RyzeHubLoaded = true

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInput       = game:GetService("UserInputService")
local Replicated      = game:GetService("ReplicatedStorage")
local Workspace       = game:GetService("Workspace")
local LocalPlayer     = Players.LocalPlayer

-- Tabella di Stato Globale (Accessibile da loader.lua)
_G.RyzeState = {
    HomeCF = nil,
    TargetNestCF = nil,
    SellCF = nil,
    HatchStandPart = nil,
    AutoLoop = false,
    AutoHatch = false,
    HatchDelay = 1.5,
    MoveSpeed = 40,
    SpeedEnabled = false,
    Noclip = false,
}

local function getRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- Funzione Interazione Avanzata (Bypass Prompt/Click)
local function triggerInteraction(obj)
    if not obj then return end
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or (obj:IsA("ProximityPrompt") and obj)
    local click = obj:FindFirstChildWhichIsA("ClickDetector", true)

    if prompt then
        if fireproximityprompt then 
            fireproximityprompt(prompt) 
        else 
            prompt:InputHoldBegin() 
            task.wait(0.1) 
            prompt:InputHoldEnd() 
        end
    elseif click then
        if fireclickdetector then fireclickdetector(click) else click:Fire() end
    end
end

-- LOOP 1: Velocità e Fisica
RunService.Heartbeat:Connect(function()
    if _G.RyzeState.SpeedEnabled then
        local root = getRoot()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = hum.MoveDirection.Unit * _G.RyzeState.MoveSpeed + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- LOOP 2: Noclip (Collisioni)
RunService.Stepped:Connect(function()
    if _G.RyzeState.Noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- LOOP 3: Auto Farm (Teleport & Loot)
task.spawn(function()
    while task.wait(0.5) do
        local s = _G.RyzeState
        if s.AutoLoop and s.HomeCF and s.TargetNestCF then
            local root = getRoot()
            if root then
                -- Vai al nido nemico
                root.CFrame = s.TargetNestCF + Vector3.new(0, 3, 0)
                task.wait(0.4)
                
                -- Scan area per oggetti interagibili
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
                        local pos = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Position or nil
                        if pos and (root.Position - pos).Magnitude < 15 then
                            triggerInteraction(obj.Parent)
                        end
                    end
                end
                task.wait(0.3)

                -- Ritorno a casa o zona vendita
                local dest = s.SellCF or s.HomeCF
                root.CFrame = dest + Vector3.new(0, 3, 0)
                task.wait(0.5)
            end
        end
    end
end)

-- LOOP 4: Auto Hatch
task.spawn(function()
    while task.wait(0.5) do
        local s = _G.RyzeState
        if s.AutoHatch and s.HatchStandPart then
            local root = getRoot()
            if root then
                root.CFrame = s.HatchStandPart.CFrame + Vector3.new(0, 3, 0)
                triggerInteraction(s.HatchStandPart)
                task.wait(s.HatchDelay)
            end
        end
    end
end)

print("RyzeHub Core Loaded")
