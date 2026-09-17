-- language: Lua, file: main.lua, target: Roblox Steal An Egg
-- RyzeHub v3.1.0 — Full Integrated Farm Engine, TP Hatch, CFrame Speed & UI Fix

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

-- ============================================================
-- PARENT GUI SICURO
-- ============================================================
local parentGui
if gethui then
    pcall(function() parentGui = gethui() end)
end
if not parentGui then
    pcall(function() parentGui = CoreGui end)
end
if not parentGui then
    parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
end

local function rndName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local s = ""
    for _ = 1, 14 do
        local idx = math.random(1, #chars)
        s = s .. chars:sub(idx, idx)
    end
    return s
end

-- ============================================================
-- TEMA
-- ============================================================
local C = {
    bg        = Color3.fromRGB(14, 14, 20),
    bg2       = Color3.fromRGB(20, 20, 30),
    bg3       = Color3.fromRGB(28, 28, 40),
    bg4       = Color3.fromRGB(40, 40, 56),
    accent    = Color3.fromRGB(140, 110, 255),
    accent2   = Color3.fromRGB(170, 140, 255),
    ok        = Color3.fromRGB(90, 220, 140),
    warn      = Color3.fromRGB(250, 180, 60),
    danger    = Color3.fromRGB(240, 90, 100),
    text      = Color3.fromRGB(240, 240, 250),
    sub       = Color3.fromRGB(150, 150, 170),
    font      = Enum.Font.Gotham,
    fontBold  = Enum.Font.GothamBold,
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or C.bg4
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function tw(obj, dur, props, style)
    TweenService:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ============================================================
-- ROOT GUI & NOTIFICHE
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = rndName()
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = parentGui

local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 300, 1, -40)
notifHolder.Position = UDim2.new(1, -320, 0, 20)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = gui

local nL = Instance.new("UIListLayout")
nL.SortOrder = Enum.SortOrder.LayoutOrder
nL.Padding = UDim.new(0, 8)
nL.Parent = notifHolder

local function notify(title, content, dur)
    dur = dur or 3.5
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 56)
    n.BackgroundColor3 = C.bg2
    n.BorderSizePixel = 0
    n.BackgroundTransparency = 1
    n.Parent = notifHolder
    corner(n, 8)
    stroke(n, C.bg4, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -16)
    bar.Position = UDim2.new(0, 8, 0, 8)
    bar.BackgroundColor3 = C.accent
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    bar.Parent = n
    corner(bar, 2)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -26, 0, 18)
    t.Position = UDim2.new(0, 18, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C.text
    t.Font = C.fontBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextTransparency = 1
    t.Parent = n

    local c = Instance.new("TextLabel")
    c.Size = UDim2.new(1, -26, 0, 22)
    c.Position = UDim2.new(0, 18, 0, 26)
    c.BackgroundTransparency = 1
    c.Text = content
    c.TextColor3 = C.sub
    c.Font = C.font
    c.TextSize = 11
    c.TextXAlignment = Enum.TextXAlignment.Left
    c.TextWrapped = true
    c.TextTransparency = 1
    c.Parent = n

    tw(n, 0.2, {BackgroundTransparency = 0})
    tw(bar, 0.2, {BackgroundTransparency = 0})
    tw(t, 0.2, {TextTransparency = 0})
    tw(c, 0.2, {TextTransparency = 0})

    task.delay(dur, function()
        tw(n, 0.2, {BackgroundTransparency = 1})
        tw(bar, 0.2, {BackgroundTransparency = 1})
        tw(t, 0.2, {TextTransparency = 1})
        tw(c, 0.2, {TextTransparency = 1})
        task.wait(0.25)
        n:Destroy()
    end)
end

-- ============================================================
-- MAIN FRAME
-- ============================================================
local W, H = 600, 430
local win = Instance.new("Frame")
win.Size = UDim2.new(0, W, 0, H)
win.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = gui
corner(win, 10)
stroke(win, C.bg4, 1)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 44)
topBar.BackgroundColor3 = C.bg2
topBar.BorderSizePixel = 0
topBar.Parent = win
corner(topBar, 10)

local topPatch = Instance.new("Frame")
topPatch.Size = UDim2.new(1, 0, 0, 10)
topPatch.Position = UDim2.new(0, 0, 1, -10)
topPatch.BackgroundColor3 = C.bg2
topPatch.BorderSizePixel = 0
topPatch.Parent = topBar

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, 0, 0, 1)
sep.Position = UDim2.new(0, 0, 1, -1)
sep.BackgroundColor3 = C.bg4
sep.BorderSizePixel = 0
sep.Parent = topBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 140, 1, 0)
titleLbl.Position = UDim2.new(0, 16, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "RyzeHub Engine"
titleLbl.TextColor3 = C.text
titleLbl.Font = C.fontBold
titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local verLbl = Instance.new("TextLabel")
verLbl.Size = UDim2.new(0, 60, 1, 0)
verLbl.Position = UDim2.new(0, 135, 0, 0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "v3.1.0"
verLbl.TextColor3 = C.sub
verLbl.Font = C.font
verLbl.TextSize = 11
verLbl.TextXAlignment = Enum.TextXAlignment.Left
verLbl.Parent = topBar

local function createWinBtn(offsetX, color, txt, onClick)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 26, 0, 26)
    b.Position = UDim2.new(1, offsetX, 0.5, -13)
    b.BackgroundColor3 = C.bg3
    b.Text = txt
    b.TextColor3 = color
    b.Font = C.fontBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = topBar
    corner(b, 6)
    b.MouseEnter:Connect(function() tw(b, 0.15, {BackgroundColor3 = color, TextColor3 = C.bg}) end)
    b.MouseLeave:Connect(function() tw(b, 0.15, {BackgroundColor3 = C.bg3, TextColor3 = color}) end)
    b.MouseButton1Click:Connect(onClick)
    return b
end

local minimized = false
local function toggleMin()
    minimized = not minimized
    tw(win, 0.2, {Size = minimized and UDim2.new(0, W, 0, 44) or UDim2.new(0, W, 0, H)})
end

createWinBtn(-68, C.sub, "—", toggleMin)
createWinBtn(-36, C.danger, "✕", function()
    gui:Destroy()
    _G.RyzeHubLoaded = false
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -54)
sidebar.Position = UDim2.new(0, 8, 0, 48)
sidebar.BackgroundColor3 = C.bg2
sidebar.BorderSizePixel = 0
sidebar.Parent = win
corner(sidebar, 8)

local sL = Instance.new("UIListLayout")
sL.Padding = UDim.new(0, 4)
sL.SortOrder = Enum.SortOrder.LayoutOrder
sL.Parent = sidebar

local sP = Instance.new("UIPadding")
sP.PaddingTop = UDim.new(0, 6)
sP.PaddingLeft = UDim.new(0, 6)
sP.PaddingRight = UDim.new(0, 6)
sP.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -164, 1, -54)
content.Position = UDim2.new(0, 156, 0, 48)
content.BackgroundTransparency = 1
content.Parent = win

local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = win.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInput.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ============================================================
-- BUILDER
-- ============================================================
local tabs, tabBtns = {}, {}
local activeTab = nil

local function selectTab(name)
    if activeTab == name then return end
    activeTab = name
    for n, page in pairs(tabs) do page.Visible = (n == name) end
    for n, btn in pairs(tabBtns) do
        local isSel = (n == name)
        tw(btn, 0.15, {BackgroundColor3 = isSel and C.accent or C.bg3})
        btn.TextColor3 = isSel and C.text or C.sub
    end
end

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C.bg3
    btn.Text = " " .. name
    btn.TextColor3 = C.sub
    btn.Font = C.fontBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = sidebar
    corner(btn, 6)

    btn.MouseEnter:Connect(function() if activeTab ~= name then tw(btn, 0.15, {BackgroundColor3 = C.bg4}) end end)
    btn.MouseLeave:Connect(function() if activeTab ~= name then tw(btn, 0.15, {BackgroundColor3 = C.bg3}) end end)
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    tabBtns[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.Visible = false
    page.Parent = content

    local pL = Instance.new("UIListLayout")
    pL.Padding = UDim.new(0, 6)
    pL.SortOrder = Enum.SortOrder.LayoutOrder
    pL.Parent = page

    local pP = Instance.new("UIPadding")
    pP.PaddingTop = UDim.new(0, 2)
    pP.PaddingRight = UDim.new(0, 6)
    pP.PaddingBottom = UDim.new(0, 6)
    pP.Parent = page

    tabs[name] = page
    local api = {}
    local order = 0
    local function nextOrder() order = order + 1; return order end

    function api:Section(txt)
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1, 0, 0, 22)
        s.BackgroundTransparency = 1
        s.LayoutOrder = nextOrder()
        s.Parent = page

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Text = string.upper(txt)
        l.TextColor3 = C.accent
        l.Font = C.fontBold
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = s
    end

    function api:Toggle(o)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = C.bg2
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder()
        row.Parent = page
        corner(row, 6)
        stroke(row, C.bg4, 1)

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -60, 1, 0)
        t.Position = UDim2.new(0, 10, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = o.Title or "Toggle"
        t.TextColor3 = C.text
        t.Font = C.fontBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row

        local state = o.CurrentValue or false
        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 36, 0, 18)
        sw.Position = UDim2.new(1, -46, 0.5, -9)
        sw.BackgroundColor3 = state and C.accent or C.bg4
        sw.BorderSizePixel = 0
        sw.Parent = row
        corner(sw, 9)

        local kn = Instance.new("Frame")
        kn.Size = UDim2.new(0, 14, 0, 14)
        kn.Position = state and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        kn.BackgroundColor3 = C.text
        kn.BorderSizePixel = 0
        kn.Parent = sw
        corner(kn, 7)

        local clk = Instance.new("TextButton")
        clk.Size = UDim2.new(1, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.Parent = row

        clk.MouseButton1Click:Connect(function()
            state = not state
            tw(sw, 0.15, {BackgroundColor3 = state and C.accent or C.bg4})
            tw(kn, 0.15, {Position = state and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
            if o.Callback then o.Callback(state) end
        end)
    end

    function api:Button(o)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundColor3 = C.bg2
        b.Text = o.Title or "Button"
        b.TextColor3 = C.text
        b.Font = C.fontBold
        b.TextSize = 12
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.LayoutOrder = nextOrder()
        b.Parent = page
        corner(b, 6)
        stroke(b, C.bg4, 1)

        b.MouseEnter:Connect(function() tw(b, 0.15, {BackgroundColor3 = C.bg3, TextColor3 = C.accent2}) end)
        b.MouseLeave:Connect(function() tw(b, 0.15, {BackgroundColor3 = C.bg2, TextColor3 = C.text}) end)
        b.MouseButton1Click:Connect(function() if o.Callback then o.Callback() end end)
    end

    function api:Slider(o)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 48)
        row.BackgroundColor3 = C.bg2
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder()
        row.Parent = page
        corner(row, 6)
        stroke(row, C.bg4, 1)

        local minV, maxV = o.Min or 0, o.Max or 100
        local val = math.clamp(o.CurrentValue or minV, minV, maxV)
        local suf = o.Suffix or ""

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -70, 0, 20)
        t.Position = UDim2.new(0, 10, 0, 4)
        t.BackgroundTransparency = 1
        t.Text = o.Title or "Slider"
        t.TextColor3 = C.text
        t.Font = C.fontBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row

        local vl = Instance.new("TextLabel")
        vl.Size = UDim2.new(0, 60, 0, 20)
        vl.Position = UDim2.new(1, -66, 0, 4)
        vl.BackgroundTransparency = 1
        vl.Text = tostring(val) .. suf
        vl.TextColor3 = C.accent
        vl.Font = C.fontBold
        vl.TextSize = 11
        vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.Parent = row

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -20, 0, 4)
        bg.Position = UDim2.new(0, 10, 0, 32)
        bg.BackgroundColor3 = C.bg4
        bg.BorderSizePixel = 0
        bg.Parent = row
        corner(bg, 2)

        local fill = Instance.new("Frame")
        local startRel = math.clamp((val - minV)/(maxV - minV), 0, 1)
        fill.Size = UDim2.new(startRel, 0, 1, 0)
        fill.BackgroundColor3 = C.accent
        fill.BorderSizePixel = 0
        fill.Parent = bg
        corner(fill, 2)

        local clk = Instance.new("TextButton")
        clk.Size = UDim2.new(1, 0, 0, 24)
        clk.Position = UDim2.new(0, 0, 0, 22)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.Parent = row

        local isSliding = false
        local function update(inputX)
            local barPos = bg.AbsolutePosition.X
            local barSize = bg.AbsoluteSize.X
            if barSize <= 0 then return end
            local rel = math.clamp((inputX - barPos) / barSize, 0, 1)
            local nv = math.floor(minV + (maxV - minV) * rel)
            val = nv
            vl.Text = tostring(val) .. suf
            fill.Size = UDim2.new(rel, 0, 1, 0)
            if o.Callback then o.Callback(val) end
        end

        clk.MouseButton1Down:Connect(function()
            isSliding = true
            update(UserInput:GetMouseLocation().X)
        end)

        UserInput.InputChanged:Connect(function(i)
            if isSliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                update(UserInput:GetMouseLocation().X)
            end
        end)

        UserInput.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = false
            end
        end)
    end

    function api:Dropdown(o)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = C.bg2
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder()
        row.Parent = page
        corner(row, 6)
        stroke(row, C.bg4, 1)

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(0, 120, 1, 0)
        t.Position = UDim2.new(0, 10, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = o.Title or "Select"
        t.TextColor3 = C.text
        t.Font = C.fontBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row

        local curIndex = 1
        local list = o.Items or {"Default"}
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 130, 0, 26)
        b.Position = UDim2.new(1, -140, 0.5, -13)
        b.BackgroundColor3 = C.bg3
        b.Text = list[curIndex]
        b.TextColor3 = C.accent2
        b.Font = C.font
        b.TextSize = 11
        b.BorderSizePixel = 0
        b.Parent = row
        corner(b, 4)

        b.MouseButton1Click:Connect(function()
            curIndex = curIndex + 1
            if curIndex > #list then curIndex = 1 end
            b.Text = list[curIndex]
            if o.Callback then o.Callback(list[curIndex]) end
        end)
    end

    return api
end

-- ============================================================
-- RUNTIME STATE & CORE ENGINE
-- ============================================================
local State = {
    -- Movement
    CFrameSpeed = false,
    CFrameMultiplier = 3,
    Noclip = false,
    InfJump = false,
    -- Farm & Deliver
    AutoStealTP = false,
    AutoDeposit = false,
    AutoSellZone = false,
    HomeCFrame = nil,
    SellZoneCFrame = nil,
    InteractRadius = 80,
    -- Hatch
    AutoHatch = false,
    EggTarget = "Common",
    HatchDelay = 1.5,
    -- Money
    AutoRewards = false,
}

local function getChar()
    return LocalPlayer.Character
end

local function getRoot()
    local c = getChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- 1. CFRAME SPEED LOOP
RunService.Heartbeat:Connect(function(dt)
    if not State.CFrameSpeed then return end
    local hum = getHumanoid()
    local root = getRoot()
    if hum and root and hum.MoveDirection.Magnitude > 0 then
        local moveVec = hum.MoveDirection.Unit * (State.CFrameMultiplier * 16 * dt)
        root.CFrame = root.CFrame + Vector3.new(moveVec.X, 0, moveVec.Z)
    end
end)

-- 2. NOCLIP CONTINUO
RunService.Stepped:Connect(function()
    if not State.Noclip then return end
    local c = getChar()
    if c then
        for _, p in pairs(c:GetChildren()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- 3. INFINITE JUMP VIA VELOCITY
UserInput.JumpRequest:Connect(function()
    if State.InfJump then
        local root = getRoot()
        if root then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 50, root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- 4. INVENTORY TOOL / EGG CHECK
local function isHoldingEgg()
    local c = getChar()
    if c then
        for _, item in pairs(c:GetChildren()) do
            if item:IsA("Tool") or item.Name:lower():find("egg") then return true end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in pairs(bp:GetChildren()) do
            if item.Name:lower():find("egg") then return true end
        end
    end
    return false
end

-- 5. RICERCA UOVA FISICHE (RADIAL SEARCH)
local function getNearbyEggs()
    local found = {}
    local myRoot = getRoot()
    if not myRoot then return found end
    local myPos = myRoot.Position

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("drop") or n:find("item") or n:find("spawn") or n:find("nest") or n:find("base") then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Name:lower():find("egg") or (part.Parent and part.Parent.Name:lower():find("egg"))) then
                        if (part.Position - myPos).Magnitude <= State.InteractRadius then
                            local isSelfNest = false
                            if State.HomeCFrame and (part.Position - State.HomeCFrame.Position).Magnitude < 18 then
                                isSelfNest = true
                            end
                            if not isSelfNest then table.insert(found, part) end
                        end
                    end
                end
            end
        end
    end
    return found
end

-- 6. DISCOVERY & HATCH STAND FINDER
local function findHatchRemote()
    for _, r in ipairs(Replicated:GetDescendants()) do
        if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
            local n = r.Name:lower()
            if n:find("hatch") or n:find("buyegg") or n:find("openegg") then
                return r
            end
        end
    end
    return nil
end

local function getEggStand(eggName)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(eggName:lower()) then
            local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if p then return p, obj end
        end
    end
    return nil
end

-- ============================================================
-- TAB 1: STEAL ENGINE
-- ============================================================
local StealTab = createTab("Steal Engine")
StealTab:Section("Punti Chiave")

StealTab:Button({
    Title = "📍 Salva Base Personale (Home)",
    Callback = function()
        local r = getRoot()
        if r then
            State.HomeCFrame = r.CFrame
            notify("Base", "Nido personale salvato!", 3)
        end
    end
})

StealTab:Button({
    Title = "💰 Salva Zona Vendita (Sell Area)",
    Callback = function()
        local r = getRoot()
        if r then
            State.SellZoneCFrame = r.CFrame
            notify("Sell Area", "Zona vendita salvata!", 3)
        end
    end
})

StealTab:Section("Raccolta & Consegna")

StealTab:Toggle({
    Title = "Auto Steal (Micro-TP Collect)",
    Callback = function(v)
        State.AutoStealTP = v
        if not v then return end
        task.spawn(function()
            while State.AutoStealTP do
                local root = getRoot()
                if root and not isHoldingEgg() then
                    local eggs = getNearbyEggs()
                    for _, eggPart in ipairs(eggs) do
                        if not State.AutoStealTP or isHoldingEgg() then break end
                        if eggPart and eggPart.Parent then
                            local origin = root.CFrame
                            root.CFrame = eggPart.CFrame + Vector3.new(0, 1.5, 0)
                            task.wait(0.12)
                            local p = eggPart:FindFirstChildOfClass("ProximityPrompt") or (eggPart.Parent and eggPart.Parent:FindFirstChildOfClass("ProximityPrompt"))
                            if p and fireproximityprompt then
                                fireproximityprompt(p)
                            end
                            task.wait(0.08)
                            if not isHoldingEgg() and root then
                                root.CFrame = origin
                            end
                            task.wait(0.15)
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end
})

StealTab:Toggle({
    Title = "Instant Base Deposit",
    Callback = function(v)
        State.AutoDeposit = v
        if not v then return end
        task.spawn(function()
            while State.AutoDeposit do
                if State.HomeCFrame and isHoldingEgg() then
                    local root = getRoot()
                    if root then
                        local origin = root.CFrame
                        root.CFrame = State.HomeCFrame
                        task.wait(0.35)
                        if root and not isHoldingEgg() then
                            root.CFrame = origin
                        end
                    end
                end
                task.wait(0.4)
            end
        end)
    end
})

StealTab:Slider({
    Title = "Raggio Cerca Uova",
    Min = 20, Max = 300, CurrentValue = 80, Suffix = " studs",
    Callback = function(v) State.InteractRadius = v end
})

-- ============================================================
-- TAB 2: MONEY & SELL
-- ============================================================
local MoneyTab = createTab("Money")
MoneyTab:Section("Vendita Rapida")

MoneyTab:Toggle({
    Title = "Auto Sell (TP su Zona Vendita)",
    Callback = function(v)
        State.AutoSellZone = v
        if not v then return end
        task.spawn(function()
            while State.AutoSellZone do
                if State.SellZoneCFrame and isHoldingEgg() then
                    local root = getRoot()
                    if root then
                        local origin = root.CFrame
                        root.CFrame = State.SellZoneCFrame
                        task.wait(0.35)
                        if root and not isHoldingEgg() then
                            root.CFrame = origin
                        end
                    end
                end
                task.wait(0.8)
            end
        end)
    end
})

MoneyTab:Toggle({
    Title = "Auto Claim Rewards",
    Callback = function(v)
        State.AutoRewards = v
        if not v then return end
        task.spawn(function()
            local kw = {"reward", "claim", "daily", "collect", "gift", "income", "money"}
            while State.AutoRewards do
                for _, obj in ipairs(Replicated:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local n = obj.Name:lower()
                        for _, w in ipairs(kw) do
                            if n:find(w) then
                                pcall(function() obj:FireServer() end)
                                pcall(function() obj:FireServer(1) end)
                                break
                            end
                        end
                    end
                end
                task.wait(3.5)
            end
        end)
    end
})

-- ============================================================
-- TAB 3: HATCH
-- ============================================================
local HatchTab = createTab("Hatch")
HatchTab:Section("Schiusa Uova")

HatchTab:Dropdown({
    Title = "Uovo Target",
    Items = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    Callback = function(val) State.EggTarget = val end
})

HatchTab:Toggle({
    Title = "Auto Hatch (Presenza Fisica + Remote)",
    Callback = function(v)
        State.AutoHatch = v
        if not v then return end
        task.spawn(function()
            while State.AutoHatch do
                local root = getRoot()
                local remote = findHatchRemote()
                local eggPart, eggModel = getEggStand(State.EggTarget)

                local oldPos
                if eggPart and root then
                    if (root.Position - eggPart.Position).Magnitude > 12 then
                        oldPos = root.CFrame
                        root.CFrame = eggPart.CFrame + Vector3.new(0, 3, 2)
                        task.wait(0.15)
                    end
                end

                if remote then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(State.EggTarget)
                            remote:FireServer(State.EggTarget, 1)
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(State.EggTarget, 1)
                        end
                    end)
                end

                if eggModel then
                    local p = eggModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p and fireproximityprompt then
                        fireproximityprompt(p)
                    end
                end

                if oldPos and root then
                    task.wait(0.1)
                    root.CFrame = oldPos
                end

                task.wait(State.HatchDelay)
            end
        end)
    end
})

HatchTab:Slider({
    Title = "Hatch Delay",
    Min = 1, Max = 4, CurrentValue = 2, Suffix = "s",
    Callback = function(v) State.HatchDelay = v end
})

-- ============================================================
-- TAB 4: MOVEMENT
-- ============================================================
local MoveTab = createTab("Movement")
MoveTab:Section("Velocità CFrame (Bypass AC)")

MoveTab:Toggle({
    Title = "CFrame Speed",
    Callback = function(v) State.CFrameSpeed = v end
})

MoveTab:Slider({
    Title = "CFrame Multiplier",
    Min = 1, Max = 8, CurrentValue = 3, Suffix = "x",
    Callback = function(v) State.CFrameMultiplier = v end
})

MoveTab:Section("Fisica Personaggio")

MoveTab:Toggle({
    Title = "Noclip (Muri Trasparenti)",
    Callback = function(v) State.Noclip = v end
})

MoveTab:Toggle({
    Title = "Infinite Jump",
    Callback = function(v) State.InfJump = v end
})

-- ============================================================
-- TAB 5: VISUALS
-- ============================================================
local VisTab = createTab("Visuals")
VisTab:Section("ESP Uova")

local highlights = {}
local function cleanESP()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights = {}
end

VisTab:Toggle({
    Title = "Highlight Uova Vicine",
    Callback = function(v)
        if v then
            task.spawn(function()
                while v do
                    local eggs = getNearbyEggs()
                    for _, egg in ipairs(eggs) do
                        if not egg:FindFirstChild("RyzeHL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "RyzeHL"
                            hl.FillColor = Color3.fromRGB(255, 200, 50)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.Adornee = egg
                            hl.Parent = egg
                            table.insert(highlights, hl)
                        end
                    end
                    task.wait(2.5)
                end
            end)
        else
            cleanESP()
        end
    end
})

-- ============================================================
-- TAB 6: SETTINGS
-- ============================================================
local SetTab = createTab("Settings")
SetTab:Section("Controllo")

SetTab:Button({
    Title = "Scarica Script (Unload)",
    Callback = function()
        cleanESP()
        gui:Destroy()
        _G.RyzeHubLoaded = false
    end
})

UserInput.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then toggleMin() end
end)

selectTab("Steal Engine")
notify("RyzeHub Pro", "v3.1.0 attivo. Salva i punti di base per iniziare.", 5)
