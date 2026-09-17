-- language: Lua, file: main.lua, target: Roblox Steal An Egg
-- RyzeHub v4.0.0 — Zero-Guesswork Engine: Point-to-Point TP Loop, Prompt Interceptor & Hatch Stand Lock

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

-- UI Container
local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:FindFirstChildOfClass("PlayerGui")

local function rndName()
    local s = ""
    for _ = 1, 12 do s = s .. string.char(math.random(97, 122)) end
    return s
end

local C = {
    bg      = Color3.fromRGB(16, 16, 22),
    bg2     = Color3.fromRGB(24, 24, 34),
    bg3     = Color3.fromRGB(32, 32, 46),
    bg4     = Color3.fromRGB(45, 45, 65),
    accent  = Color3.fromRGB(140, 110, 255),
    ok      = Color3.fromRGB(90, 220, 140),
    danger  = Color3.fromRGB(240, 90, 100),
    text    = Color3.fromRGB(240, 240, 250),
    sub     = Color3.fromRGB(150, 150, 170),
}

local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function stroke(p, col) local s = Instance.new("UIStroke"); s.Color = col or C.bg4; s.Parent = p; return s end
local function tw(obj, dur, props) TweenService:Create(obj, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

local gui = Instance.new("ScreenGui")
gui.Name = rndName()
gui.ResetOnSpawn = false
gui.Parent = parentGui

-- Finestra Principale
local W, H = 580, 420
local win = Instance.new("Frame")
win.Size = UDim2.new(0, W, 0, H)
win.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = gui
corner(win, 10); stroke(win, C.bg4)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = C.bg2
topBar.Parent = win
corner(topBar, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "RyzeHub Pro v4.0.0"
title.TextColor3 = C.text
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.bg3
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.danger
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.Parent = topBar
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    _G.RyzeHubLoaded = false
end)

-- Drag Finestra
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = win.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInput.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Layout Pagine
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -48)
sidebar.Position = UDim2.new(0, 8, 0, 44)
sidebar.BackgroundColor3 = C.bg2
sidebar.Parent = win
corner(sidebar, 8)
local sL = Instance.new("UIListLayout"); sL.Padding = UDim.new(0, 4); sL.Parent = sidebar
local sP = Instance.new("UIPadding"); sP.PaddingTop = UDim.new(0, 6); sP.PaddingLeft = UDim.new(0, 6); sP.PaddingRight = UDim.new(0, 6); sP.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -154, 1, -48)
content.Position = UDim2.new(0, 146, 0, 44)
content.BackgroundTransparency = 1
content.Parent = win

local tabs, tabBtns = {}, {}
local activeTab = nil

local function selectTab(name)
    if activeTab == name then return end
    activeTab = name
    for n, p in pairs(tabs) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        local on = (n == name)
        tw(b, 0.15, {BackgroundColor3 = on and C.accent or C.bg3})
        b.TextColor3 = on and C.text or C.sub
    end
end

local function createTab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = C.bg3
    b.Text = name
    b.TextColor3 = C.sub
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = sidebar
    corner(b, 6)
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    tabBtns[name] = b

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 2
    page.Visible = false
    page.Parent = content

    local pL = Instance.new("UIListLayout"); pL.Padding = UDim.new(0, 6); pL.Parent = page
    local pP = Instance.new("UIPadding"); pP.PaddingTop = UDim.new(0, 4); pP.PaddingBottom = UDim.new(0, 6); pP.PaddingRight = UDim.new(0, 6); pP.Parent = page

    tabs[name] = page
    local api = {}

    function api:Button(txt, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = C.bg2
        btn.Text = txt
        btn.TextColor3 = C.text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = page
        corner(btn, 6); stroke(btn, C.bg4)
        btn.MouseButton1Click:Connect(cb)
        return btn
    end

    function api:Toggle(txt, cb)
        local state = false
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = C.bg2
        btn.Text = "  " .. txt .. ": OFF"
        btn.TextColor3 = C.sub
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page
        corner(btn, 6); stroke(btn, C.bg4)

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = "  " .. txt .. (state and ": ON" or ": OFF")
            btn.TextColor3 = state and C.ok or C.sub
            tw(btn, 0.15, {BackgroundColor3 = state and C.bg3 or C.bg2})
            cb(state)
        end)
    end

    function api:Slider(txt, minV, maxV, defV, cb)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = C.bg2
        row.Parent = page
        corner(row, 6); stroke(row, C.bg4)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 0, 18)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = txt .. ": " .. defV
        label.TextColor3 = C.text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -20, 0, 4)
        bar.Position = UDim2.new(0, 10, 0, 28)
        bar.BackgroundColor3 = C.bg4
        bar.Parent = row
        corner(bar, 2)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defV - minV)/(maxV - minV), 0, 1, 0)
        fill.BackgroundColor3 = C.accent
        fill.Parent = bar
        corner(fill, 2)

        local clk = Instance.new("TextButton")
        clk.Size = UDim2.new(1, 0, 0, 20)
        clk.Position = UDim2.new(0, 0, 0, 20)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.Parent = row

        local isSliding = false
        local function upd(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(minV + (maxV - minV) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = txt .. ": " .. v
            cb(v)
        end

        clk.MouseButton1Down:Connect(function() isSliding = true; upd(UserInput:GetMouseLocation().X) end)
        UserInput.InputChanged:Connect(function(i) if isSliding and i.UserInputType == Enum.UserInputType.MouseMovement then upd(UserInput:GetMouseLocation().X) end end)
        UserInput.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end end)
    end

    return api
end

-- ============================================================
-- CORE LOGIC (ZERO-GUESSWORK)
-- ============================================================
local State = {
    HomeCF = nil,
    TargetNestCF = nil,
    SellCF = nil,
    HatchStandPart = nil,
    HatchStandPrompt = nil,
    AutoLoop = false,
    AutoHatch = false,
    HatchDelay = 1.0,
    MoveSpeed = 40,
    SpeedEnabled = false,
    Noclip = false,
}

local function getRoot()
    local c = LocalPlayer.Character
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end

local function triggerAnyPrompt(obj)
    if not obj then return end
    local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if p then
        p.RequiresLineOfSight = false
        p.MaxActivationDistance = 999
        if fireproximityprompt then
            fireproximityprompt(p)
        else
            p:InputHoldBegin()
            task.wait(p.HoldDuration)
            p:InputHoldEnd()
        end
    end
end

-- 1. VELOCITÀ FISICA ASSEGNAZIONE LINEARE
RunService.Heartbeat:Connect(function()
    if not State.SpeedEnabled then return end
    local root = getRoot()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.MoveDirection.Magnitude > 0 then
        root.AssemblyLinearVelocity = hum.MoveDirection.Unit * State.MoveSpeed + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    end
end)

-- 2. NOCLIP
RunService.Stepped:Connect(function()
    if not State.Noclip then return end
    local c = LocalPlayer.Character
    if c then
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- 3. LOOP RAPIDO FURTO & DEPOSITO (TARGET-BASED)
task.spawn(function()
    while true do
        if State.AutoLoop and State.HomeCF and State.TargetNestCF then
            local root = getRoot()
            if root then
                -- Vai al nido nemico
                root.CFrame = State.TargetNestCF + Vector3.new(0, 1.5, 0)
                task.wait(0.15)

                -- Interagisci con tutti i prompt nell'area
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent:IsA("BasePart") then
                        if (root.Position - prompt.Parent.Position).Magnitude <= 20 then
                            triggerAnyPrompt(prompt.Parent)
                        end
                    end
                end
                task.wait(0.3)

                -- Vai a depositare al nido personale
                root.CFrame = State.HomeCF + Vector3.new(0, 1.5, 0)
                task.wait(0.4)

                -- Se è impostata la zona vendita, fa un passaggio di sell
                if State.SellCF then
                    root.CFrame = State.SellCF + Vector3.new(0, 1.5, 0)
                    task.wait(0.3)
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 4. HATCH MOTORIZZATO SU ISTANZA BLOCCATA
task.spawn(function()
    while true do
        if State.AutoHatch and State.HatchStandPart then
            local root = getRoot()
            if root then
                local oldPos = root.CFrame
                root.CFrame = State.HatchStandPart.CFrame + Vector3.new(0, 2, 2)
                task.wait(0.1)

                -- Trigger fisico prompt
                if State.HatchStandPrompt then
                    triggerAnyPrompt(State.HatchStandPrompt.Parent)
                end

                -- Trigger ClickDetector
                local cd = State.HatchStandPart:FindFirstChildWhichIsA("ClickDetector", true)
                if cd and fireclickdetector then
                    fireclickdetector(cd)
                end

                -- Fire di qualsiasi RemoteEvent associato a Egg/Hatch
                for _, r in ipairs(Replicated:GetDescendants()) do
                    if r:IsA("RemoteEvent") then
                        local n = r.Name:lower()
                        if n:find("egg") or n:find("hatch") or n:find("buy") then
                            pcall(function() r:FireServer(1) end)
                            pcall(function() r:FireServer(State.HatchStandPart.Name) end)
                        end
                    end
                end

                task.wait(0.1)
                root.CFrame = oldPos
            end
            task.wait(State.HatchDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- ============================================================
-- PAGINE & BOTTONI
-- ============================================================
local FarmTab = createTab("Farm Loop")

FarmTab:Button("📍 1. Salva Mio Nido (Home)", function()
    local r = getRoot()
    if r then State.HomeCF = r.CFrame end
end)

FarmTab:Button("🎯 2. Salva Nido Nemico (Target)", function()
    local r = getRoot()
    if r then State.TargetNestCF = r.CFrame end
end)

FarmTab:Button("💰 3. Salva Pedana Sell (Opzionale)", function()
    local r = getRoot()
    if r then State.SellCF = r.CFrame end
end)

FarmTab:Toggle("Avvia Loop Furto Automatico", function(v)
    State.AutoLoop = v
end)

local HatchTab = createTab("Hatch")

HatchTab:Button("🎯 Blocca Uovo Qui (Stand Lock)", function()
    local root = getRoot()
    if root then
        -- Trova il modello o la parte più vicina davanti al player
        local nearest, dist = nil, 25
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and obj.Parent and obj.Parent:IsA("BasePart") then
                local d = (root.Position - obj.Parent.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = obj.Parent
                    State.HatchStandPrompt = obj
                end
            end
        end
        if nearest then
            State.HatchStandPart = nearest
        else
            -- Se non ci sono prompt, blocca la parte fisica più vicina
            for _, p in ipairs(Workspace:GetDescendants()) do
                if p:IsA("BasePart") and not p:IsDescendantOf(LocalPlayer.Character) then
                    local d = (root.Position - p.Position).Magnitude
                    if d < 12 and d < dist then
                        dist = d
                        State.HatchStandPart = p
                    end
                end
            end
        end
    end
end)

HatchTab:Toggle("Auto Hatch Uovo Bloccato", function(v)
    State.AutoHatch = v
end)

HatchTab:Slider("Velocità Schiusa", 1, 4, 1, function(v)
    State.HatchDelay = v
end)

local MoveTab = createTab("Movement")

MoveTab:Toggle("Velocità Anticheat Safe", function(v)
    State.SpeedEnabled = v
end)

MoveTab:Slider("Velocità", 20, 100, 40, function(v)
    State.MoveSpeed = v
end)

MoveTab:Toggle("Noclip", function(v)
    State.Noclip = v
end)

selectTab("Farm Loop")
