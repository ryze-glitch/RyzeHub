-- language: Lua, file: main.lua, target: Roblox Steal An Egg
-- RyzeHub v4.5.0 — Core Engine (Logic Only)

if _G.RyzeHubLoaded then return end
_G.RyzeHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- TABELLA DI STATO (Questa viene letta dal Loader)
_G.RyzeState = {
    AutoFarm = false,
    AutoHatch = false,
    Noclip = false,
    Speed = 40,
    SpeedEnabled = false,
    AutoCollect = true,
    TargetPos = nil,
    HomePos = nil,
}

local function getRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function triggerInteraction(obj)
    if not obj then return end
    local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or (obj:IsA("ProximityPrompt") and obj)
    if p then
        p.RequiresLineOfSight = false
        if fireproximityprompt then fireproximityprompt(p) else p:InputHoldBegin() task.wait(0.1) p:InputHoldEnd() end
    end
end

-- LOOP 1: Velocità
RunService.Heartbeat:Connect(function()
    local s = _G.RyzeState
    if s.SpeedEnabled then
        local root = getRoot()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = hum.MoveDirection.Unit * s.Speed + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- LOOP 2: Noclip
RunService.Stepped:Connect(function()
    if _G.RyzeState.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- LOOP 3: Auto Farm (Teleport & Loot)
task.spawn(function()
    while task.wait(0.5) do
        local s = _G.RyzeState
        if s.AutoFarm and s.TargetPos then
            local root = getRoot()
            if root then
                root.CFrame = s.TargetPos + Vector3.new(0, 4, 0)
                task.wait(0.4)
                if s.AutoCollect then
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
                            local p = v.Parent
                            if p and p:IsA("BasePart") and (root.Position - p.Position).Magnitude < 15 then
                                triggerInteraction(p)
                            end
                        end
                    end
                end
                task.wait(0.3)
            end
        end
    end
end)

print("[RyzeHub] Engine Loaded")
