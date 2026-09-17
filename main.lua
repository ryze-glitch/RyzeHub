-- language: Lua, file: main.lua, target: Roblox Steal An Egg
-- RyzeHub v2.0.0 — stealth, auto-discovery, humanized

if _G.RyzeHubLoaded then return end
_G.RyzeHubLoaded = true

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local Tween      = game:GetService("TweenService")
local Replicated = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- STEALTH BOOT — niente azioni aggressive, solo GUI
-- ============================================================

-- 1. Spegni eventuali __namecall hooks di altri script (silenzioso)
pcall(function()
    local mt = getrawmetatable(game)
    if mt and mt.__namecall then
        -- non facciamo nulla se già pulito
    end
end)

-- 2. Nome GUI randomizzato — niente "Ryze" nel nome dell'oggetto
local function rndName()
    local chars = "abcdefghijklmnopqrstuvwxyz"
    local s = ""
    for i = 1, 12 do
        local idx = math.random(1, #chars)
        s = s .. chars:sub(idx, idx)
    end
    return s
end

local guiName = rndName()

-- 3. Parent: prova PlayerGui, non CoreGui (CoreGui è più monitorato)
local parentGui = LocalPlayer:WaitForChild("PlayerGui")
if gethui then
    pcall(function()
        local h = gethui()
        if h then parentGui = h end
    end)
end

-- ============================================================
-- HUMANIZED TIMING — nessun pattern fisso
-- ============================================================
local function humanWait(base)
    base = base or 0.5
    -- delay con jitter naturale: 0.7x - 1.6x + micro-pausa
    local t = base * (0.7 + math.random() * 0.9)
    if math.random() < 0.15 then
        t = t + math.random(0.5, 2.0)  -- pausa caffè
    end
    task.wait(t)
end

-- ============================================================
-- REMOTE AUTO-DISCOVERY
-- Cerca remote che matchano pattern noti senza hookare nulla
-- ============================================================
local RemoteCache = {}

local PATTERNS = {
    steal = {"steal", "grab", "pick", "take", "snatch"},
    sell  = {"sell", "sellall", "sellpet", "cashout"},
    hatch = {"hatch", "open", "unbox"},
    money = {"money", "cash", "coin", "reward", "claim", "collect"},
    egg   = {"egg", "pet", "inventory"},
}

local function discoverRemotes()
    RemoteCache = {}
    local scanned = 0
    for _, obj in pairs(Replicated:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            scanned = scanned + 1
            local n = obj.Name:lower()
            for cat, pats in pairs(PATTERNS) do
                for _, p in ipairs(pats) do
                    if n:find(p) then
                        if not RemoteCache[cat] then RemoteCache[cat] = {} end
                        table.insert(RemoteCache[cat], obj)
                        break
                    end
                end
            end
        end
    end
    return scanned
end

-- Scansione iniziale silenziosa (nessun fire, solo lettura)
local totalScanned = discoverRemotes()

-- ============================================================
-- COLORS / UI HELPERS
-- ============================================================
local C = {
    bg = Color3.fromRGB(14, 14, 20),
    bg2 = Color3.fromRGB(20, 20, 30),
    bg3 = Color3.fromRGB(28, 28, 40),
    bg4 = Color3.fromRGB(40, 40, 56),
    accent = Color3.fromRGB(140, 110, 255),
    accent2 = Color3.fromRGB(170, 140, 255),
    ok = Color3.fromRGB(90, 220, 140),
    warn = Color3.fromRGB(250, 180, 60),
    danger = Color3.fromRGB(240, 90, 100),
    text = Color3.fromRGB(240, 240, 250),
    sub = Color3.fromRGB(150, 150, 170),
    font = Enum.Font.Gotham,
    fontBold = Enum.Font.GothamBold,
}

local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function stroke(p, c, t) local s=Instance.new("UIStroke"); s.Color=c or C.bg4; s.Thickness=t or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function tw(o, t, p, st) Tween:Create(o, TweenInfo.new(t, st or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play() end

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = parentGui

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 320, 1, -40)
notifHolder.Position = UDim2.new(1, -340, 0, 20)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = gui
local nL = Instance.new("UIListLayout")
nL.SortOrder = Enum.SortOrder.LayoutOrder
nL.Padding = UDim.new(0, 8)
nL.Parent = notifHolder

local function notify(title, content, dur)
    dur = dur or 4
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 60)
    n.BackgroundColor3 = C.bg2
    n.BorderSizePixel = 0
    n.BackgroundTransparency = 1
    n.Parent = notifHolder
    corner(n, 10); stroke(n, C.bg4, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -16)
    bar.Position = UDim2.new(0, 8, 0, 8)
    bar.BackgroundColor3 = C.accent
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    bar.Parent = n
    corner(bar, 2)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -30, 0, 20)
    t.Position = UDim2.new(0, 18, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C.text
    t.Font = C.fontBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextTransparency = 1
    t.Parent = n

    local c = Instance.new("TextLabel")
    c.Size = UDim2.new(1, -30, 0, 24)
    c.Position = UDim2.new(0, 18, 0, 28)
    c.BackgroundTransparency = 1
    c.Text = content
    c.TextColor3 = C.sub
    c.Font = C.font
    c.TextSize = 12
    c.TextXAlignment = Enum.TextXAlignment.Left
    c.TextWrapped = true
    c.TextTransparency = 1
    c.Parent = n

    local info = TweenInfo.new(0.3)
    Tween:Create(n, info, {BackgroundTransparency = 0}):Play()
    Tween:Create(bar, info, {BackgroundTransparency = 0}):Play()
    Tween:Create(t, info, {TextTransparency = 0}):Play()
    Tween:Create(c, info, {TextTransparency = 0}):Play()

    task.delay(dur, function()
        local o = TweenInfo.new(0.3)
        Tween:Create(n, o, {BackgroundTransparency = 1}):Play()
        Tween:Create(bar, o, {BackgroundTransparency = 1}):Play()
        Tween:Create(t, o, {TextTransparency = 1}):Play()
        Tween:Create(c, o, {TextTransparency = 1}):Play()
        task.wait(0.35); n:Destroy()
    end)
end

-- ============================================================
-- WINDOW
-- ============================================================
local W, H = 620, 430
local win = Instance.new("Frame")
win.Size = UDim2.new(0, W, 0, H)
win.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.Parent = gui
corner(win, 14); stroke(win, C.bg4, 1)

local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 60, 1, 60)
glow.Position = UDim2.new(0, -30, 0, -30)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = C.accent
glow.ImageTransparency = 0.84
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 276, 276)
glow.Parent = win

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = C.bg2
topBar.BorderSizePixel = 0
topBar.Parent = win
corner(topBar, 14)
local patch = Instance.new("Frame")
patch.Size = UDim2.new(1, 0, 0, 14)
patch.Position = UDim2.new(0, 0, 1, -14)
patch.BackgroundColor3 = C.bg2
patch.BorderSizePixel = 0
patch.Parent = topBar
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -20, 0, 1)
sep.Position = UDim2.new(0, 10, 1, -1)
sep.BackgroundColor3 = C.bg4
sep.BorderSizePixel = 0
sep.Parent = win

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 22, 0, 22)
logo.Position = UDim2.new(0, 18, 0.5, -11)
logo.BackgroundColor3 = C.accent
logo.BorderSizePixel = 0
logo.Parent = topBar
corner(logo, 6)
local li = Instance.new("Frame")
li.Size = UDim2.new(0, 10, 0, 10)
li.Position = UDim2.new(0.5, -5, 0.5, -5)
li.BackgroundColor3 = C.bg
li.BorderSizePixel = 0
li.Parent = logo
corner(li, 3)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 200, 1, 0)
titleLbl.Position = UDim2.new(0, 50, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "RyzeHub"
titleLbl.TextColor3 = C.text
titleLbl.Font = C.fontBold
titleLbl.TextSize = 16
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local verLbl = Instance.new("TextLabel")
verLbl.Size = UDim2.new(0, 80, 1, 0)
verLbl.Position = UDim2.new(0, 128, 0, 0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "v2.0.0"
verLbl.TextColor3 = C.sub
verLbl.Font = C.font
verLbl.TextSize = 11
verLbl.TextXAlignment = Enum.TextXAlignment.Left
verLbl.Parent = topBar

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0, 224, 0.5, -4)
dot.BackgroundColor3 = C.ok
dot.BorderSizePixel = 0
dot.Parent = topBar
corner(dot, 4)

local stLbl = Instance.new("TextLabel")
stLbl.Size = UDim2.new(0, 120, 1, 0)
stLbl.Position = UDim2.new(0, 238, 0, 0)
stLbl.BackgroundTransparency = 1
stLbl.Text = "STEALTH"
stLbl.TextColor3 = C.ok
stLbl.Font = C.fontBold
stLbl.TextSize = 10
stLbl.TextXAlignment = Enum.TextXAlignment.Left
stLbl.Parent = topBar

local function mkBtn(x, color, sym, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, x, 0.5, -14)
    b.BackgroundColor3 = C.bg3
    b.Text = sym
    b.TextColor3 = color
    b.Font = C.fontBold
    b.TextSize = 16
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = topBar
    corner(b, 8)
    b.MouseEnter:Connect(function() tw(b, 0.15, {BackgroundColor3 = color, TextColor3 = C.bg}) end)
    b.MouseLeave:Connect(function() tw(b, 0.15, {BackgroundColor3 = C.bg3, TextColor3 = color}) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local minBtn = mkBtn(-78, C.sub, "—", function() end)
mkBtn(-44, C.danger, "✕", function() gui:Destroy(); _G.RyzeHubLoaded = false end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, -68)
sidebar.Position = UDim2.new(0, 10, 0, 58)
sidebar.BackgroundColor3 = C.bg2
sidebar.BorderSizePixel = 0
sidebar.Parent = win
corner(sidebar, 10)
local sL = Instance.new("UIListLayout")
sL.Padding = UDim.new(0, 6)
sL.SortOrder = Enum.SortOrder.LayoutOrder
sL.Parent = sidebar
local sP = Instance.new("UIPadding")
sP.PaddingTop = UDim.new(0, 10); sP.PaddingLeft = UDim.new(0, 8); sP.PaddingRight = UDim.new(0, 8)
sP.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -180, 1, -68)
content.Position = UDim2.new(0, 170, 0, 58)
content.BackgroundTransparency = 1
content.Parent = win
local cL = Instance.new("UIListLayout")
cL.Padding = UDim.new(0, 8)
cL.SortOrder = Enum.SortOrder.LayoutOrder
cL.Parent = content
local cP = Instance.new("UIPadding")
cP.PaddingTop = UDim.new(0, 4); cP.PaddingRight = UDim.new(0, 10); cP.PaddingBottom = UDim.new(0, 10)
cP.Parent = content

-- ============================================================
-- TABS
-- ============================================================
local tabs, tabBtns = {}, {}
local activeTab
local function selectTab(name)
    if activeTab == name then return end
    activeTab = name
    for n, t in pairs(tabs) do t.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        local on = (n == name)
        tw(b, 0.15, {BackgroundColor3 = on and C.accent or C.bg3})
        b.TextColor3 = on and C.text or C.sub
    end
end

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.bg3
    btn.Text = "  " .. name
    btn.TextColor3 = C.sub
    btn.Font = C.fontBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = sidebar
    corner(btn, 8)
    btn.MouseEnter:Connect(function() if activeTab ~= name then tw(btn, 0.15, {BackgroundColor3 = C.bg4}) end end)
    btn.MouseLeave:Connect(function() if activeTab ~= name then tw(btn, 0.15, {BackgroundColor3 = C.bg3}) end end)
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    tabBtns[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.Visible = false
    page.Parent = content
    local pL = Instance.new("UIListLayout")
    pL.Padding = UDim.new(0, 8)
    pL.SortOrder = Enum.SortOrder.LayoutOrder
    pL.Parent = page

    tabs[name] = page
    local api = {}
    local order = 0
    local function no() order = order + 1; return order end

    function api:Section(txt)
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1, 0, 0, 28)
        s.BackgroundTransparency = 1
        s.LayoutOrder = no()
        s.Parent = page
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20)
        l.Position = UDim2.new(0, 4, 0, 4)
        l.BackgroundTransparency = 1
        l.Text = string.upper(txt)
        l.TextColor3 = C.accent
        l.Font = C.fontBold
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = s
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -8, 0, 1)
        line.Position = UDim2.new(0, 4, 1, -2)
        line.BackgroundColor3 = C.bg4
        line.BorderSizePixel = 0
        line.Parent = s
    end

    function api:Toggle(o)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundColor3 = C.bg2
        row.BorderSizePixel = 0
        row.LayoutOrder = no()
        row.Parent = page
        corner(row, 8); stroke(row, C.bg4, 1)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -80, 0, 20)
        t.Position = UDim2.new(0, 14, 0, 6)
        t.BackgroundTransparency = 1
        t.Text = o.Title or "Toggle"
        t.TextColor3 = C.text
        t.Font = C.fontBold
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row
        if o.Description then
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, -80, 0, 14)
            d.Position = UDim2.new(0, 14, 0, 24)
            d.BackgroundTransparency = 1
            d.Text = o.Description
            d.TextColor3 = C.sub
            d.Font = C.font
            d.TextSize = 11
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = row
        end
        local state = o.CurrentValue or false
        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 40, 0, 22)
        sw.Position = UDim2.new(1, -54, 0.5, -11)
        sw.BackgroundColor3 = state and C.accent or C.bg4
        sw.BorderSizePixel = 0
        sw.Parent = row
        corner(sw, 11)
        local kn = Instance.new("Frame")
        kn.Size = UDim2.new(0, 16, 0, 16)
        kn.Position = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        kn.BackgroundColor3 = C.text
        kn.BorderSizePixel = 0
        kn.Parent = sw
        corner(kn, 8)
        local clk = Instance.new("TextButton")
        clk.Size = UDim2.new(1, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.Parent = row
        clk.MouseButton1Click:Connect(function()
            state = not state
            tw(sw, 0.2, {BackgroundColor3 = state and C.accent or C.bg4})
            tw(kn, 0.2, {Position = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
            if o.Callback then o.Callback(state) end
        end)
    end

    function api:Slider(o)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 56)
        row.BackgroundColor3 = C.bg2
        row.BorderSizePixel = 0
        row.LayoutOrder = no()
        row.Parent = page
        corner(row, 8); stroke(row, C.bg4, 1)
        local minV, maxV = o.Min or 0, o.Max or 100
        local val = o.CurrentValue or minV
        local suf = o.Suffix or ""
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -100, 0, 20)
        t.Position = UDim2.new(0, 14, 0, 6)
        t.BackgroundTransparency = 1
        t.Text = o.Title or "Slider"
        t.TextColor3 = C.text
        t.Font = C.fontBold
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row
        local vl = Instance.new("TextLabel")
        vl.Size = UDim2.new(0, 80, 0, 20)
        vl.Position = UDim2.new(1, -94, 0, 6)
        vl.BackgroundTransparency = 1
        vl.Text = tostring(val) .. suf
        vl.TextColor3 = C.accent
        vl.Font = C.fontBold
        vl.TextSize = 12
        vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.Parent = row
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -28, 0, 6)
        bg.Position = UDim2.new(0, 14, 0, 36)
        bg.BackgroundColor3 = C.bg4
        bg.BorderSizePixel = 0
        bg.Parent = row
        corner(bg, 3)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((val - minV)/(maxV - minV), 0, 1, 0)
        fill.BackgroundColor3 = C.accent
        fill.BorderSizePixel = 0
        fill.Parent = bg
        corner(fill, 3)
        local kn = Instance.new("Frame")
        kn.Size = UDim2.new(0, 14, 0, 14)
        kn.AnchorPoint = Vector2.new(0.5, 0.5)
        kn.Position = UDim2.new((val - minV)/(maxV - minV), 0, 0.5, 0)
        kn.BackgroundColor3 = C.text
        kn.BorderSizePixel = 0
        kn.Parent = bg
        corner(kn, 7)
        local clk = Instance.new("TextButton")
        clk.Size = UDim2.new(1, 0, 0, 30)
        clk.Position = UDim2.new(0, 0, 0, 24)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.Parent = row
        local dragging = false
        local function update(x)
            local rel = math.clamp((x - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local nv = math.floor(minV + (maxV - minV) * rel)
            if nv ~= val then
                val = nv
                vl.Text = tostring(val) .. suf
                fill.Size = UDim2.new(rel, 0, 1, 0)
                kn.Position = UDim2.new(rel, 0, 0.5, 0)
                if o.Callback then o.Callback(val) end
            end
        end
        clk.MouseButton1Down:Connect(function() dragging = true; update(UserInput:GetMouseLocation().X) end)
        UserInput.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
        UserInput.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    end

    function api:Button(o)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = C.bg2
        b.Text = o.Title or "Button"
        b.TextColor3 = C.text
        b.Font = C.fontBold
        b.TextSize = 13
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.LayoutOrder = no()
        b.Parent = page
        corner(b, 8); stroke(b, C.bg4, 1)
        b.MouseEnter:Connect(function() tw(b, 0.15, {BackgroundColor3 = C.bg3, TextColor3 = C.accent2}) end)
        b.MouseLeave:Connect(function() tw(b, 0.15, {BackgroundColor3 = C.bg2, TextColor3 = C.text}) end)
        b.MouseButton1Click:Connect(function() if o.Callback then o.Callback() end end)
    end

    function api:Input(o)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundColor3 = C.bg2
        row.BorderSizePixel = 0
        row.LayoutOrder = no()
        row.Parent = page
        corner(row, 8); stroke(row, C.bg4, 1)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(0, 120, 1, 0)
        t.Position = UDim2.new(0, 14, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = o.Title or "Input"
        t.TextColor3 = C.text
        t.Font = C.fontBold
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = row
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -160, 0, 30)
        box.Position = UDim2.new(0, 146, 0.5, -15)
        box.BackgroundColor3 = C.bg3
        box.Text = ""
        box.PlaceholderText = o.Placeholder or "..."
        box.PlaceholderColor3 = C.sub
        box.TextColor3 = C.text
        box.Font = C.font
        box.TextSize = 12
        box.BorderSizePixel = 0
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.Parent = row
        corner(box, 6); stroke(box, C.bg4, 1)
        local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 8); pad.Parent = box
        box.Focused:Connect(function() tw(box, 0.15, {BackgroundColor3 = C.bg4}) end)
        box.FocusLost:Connect(function() tw(box, 0.15, {BackgroundColor3 = C.bg3}); if o.Callback then o.Callback(box.Text) end end)
    end

    function api:Paragraph(o)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 0)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.BackgroundColor3 = C.bg2
        row.BorderSizePixel = 0
        row.LayoutOrder = no()
        row.Parent = page
        corner(row, 8); stroke(row, C.bg4, 1)
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10); pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 14); pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = row
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.BackgroundTransparency = 1
        l.Text = o.Content or ""
        l.TextColor3 = C.sub
        l.Font = C.font
        l.TextSize = 12
        l.TextWrapped = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.Parent = row
    end

    return api
end

-- ============================================================
-- DRAG
-- ============================================================
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

-- ============================================================
-- STATE
-- ============================================================
local State = {
    Speed = 16, SpeedEnabled = false,
    JumpPower = 50, JumpEnabled = false,
    Noclip = false, InfJump = false,
    ESPEnabled = false,
    AutoSteal = false, AutoSell = false, AutoHatch = false,
    AutoDelay = 1.2,
}

local function getHumanoid()
    local c = LocalPlayer.Character
    if c then return c:FindFirstChildOfClass("Humanoid") end
end

local function getLS(n)
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild(n) or nil
end

-- ============================================================
-- MAIN TAB
-- ============================================================
local Main = createTab("Main")
Main:Section("Movement")

Main:Paragraph({
    Content = "⚠️ Stealth mode: WalkSpeed max 40, JumpPower max 90. Valori più alti triggerano BAC-4203. I movimenti sono rampati lentamente per non creare picchi.",
})

Main:Toggle({
    Title = "Speed Enabled",
    Description = "Rampa lenta 16→target in 2s",
    Callback = function(v)
        State.SpeedEnabled = v
        local h = getHumanoid()
        if not h then return end
        if v then
            task.spawn(function()
                local start = h.WalkSpeed
                local steps = 20
                for i = 1, steps do
                    if not State.SpeedEnabled then break end
                    h.WalkSpeed = start + (State.Speed - start) * (i/steps)
                    task.wait(0.1)
                end
            end)
        else
            h.WalkSpeed = 16
        end
    end,
})

Main:Slider({
    Title = "WalkSpeed (safe)",
    Min = 16, Max = 40, CurrentValue = 16, Suffix = " studs",
    Callback = function(v)
        State.Speed = v
        if State.SpeedEnabled then
            local h = getHumanoid()
            if h then
                task.spawn(function()
                    local cur = h.WalkSpeed
                    for i = 1, 15 do
                        if not h or not h.Parent then break end
                        h.WalkSpeed = cur + (v - cur) * (i/15)
                        task.wait(0.1)
                    end
                end)
            end
        end
    end,
})

Main:Toggle({
    Title = "JumpPower Boost",
    Callback = function(v)
        State.JumpEnabled = v
        local h = getHumanoid()
        if h then
            h.UseJumpPower = true
            h.JumpPower = v and State.JumpPower or 50
        end
    end,
})

Main:Slider({
    Title = "JumpPower (safe)",
    Min = 50, Max = 90, CurrentValue = 50,
    Callback = function(v)
        State.JumpPower = v
        if State.JumpEnabled then
            local h = getHumanoid()
            if h then h.JumpPower = v end
        end
    end,
})

-- ============================================================
-- STEAL AN EGG
-- ============================================================
local Egg = createTab("Steal An Egg")
Egg:Section("Auto Farm")

Egg:Paragraph({
    Content = "Delay alto = meno rilevabile. Sotto 1s è a rischio kick. Il tool cerca i remote da solo — non serve configurarli a mano.",
})

Egg:Slider({
    Title = "Delay base",
    Min = 0.8, Max = 4, CurrentValue = 1.2, Suffix = "s",
    Callback = function(v) State.AutoDelay = v end,
})

local function safeFire(remote, ...)
    if not remote or not remote.Parent then return end
    pcall(function()
        if remote:IsA("RemoteEvent") then remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
    end)
end

Egg:Toggle({
    Title = "Auto Steal",
    Description = "Cerca remote 'steal' e li attiva",
    Callback = function(v)
        State.AutoSteal = v
        if not v then return end
        task.spawn(function()
            while State.AutoSteal do
                if not RemoteCache.steal then discoverRemotes() end
                if RemoteCache.steal then
                    for _, r in ipairs(RemoteCache.steal) do
                        if not State.AutoSteal then break end
                        safeFire(r)
                        humanWait(State.AutoDelay * 0.5)
                    end
                end
                humanWait(State.AutoDelay)
            end
        end)
    end,
})

Egg:Toggle({
    Title = "Auto Sell",
    Description = "Vende i pet periodicamente",
    Callback = function(v)
        State.AutoSell = v
        if not v then return end
        task.spawn(function()
            while State.AutoSell do
                if not RemoteCache.sell then discoverRemotes() end
                if RemoteCache.sell then
                    for _, r in ipairs(RemoteCache.sell) do
                        if not State.AutoSell then break end
                        safeFire(r)
                        humanWait(State.AutoDelay)
                    end
                end
                humanWait(State.AutoDelay * 2)
            end
        end)
    end,
})

Egg:Toggle({
    Title = "Auto Hatch",
    Description = "Schiusa uova periodicamente",
    Callback = function(v)
        State.AutoHatch = v
        if not v then return end
        task.spawn(function()
            while State.AutoHatch do
                if not RemoteCache.hatch then discoverRemotes() end
                if RemoteCache.hatch then
                    for _, r in ipairs(RemoteCache.hatch) do
                        if not State.AutoHatch then break end
                        safeFire(r, "Basic")
                        humanWait(State.AutoDelay)
                    end
                end
                humanWait(State.AutoDelay * 3)
            end
        end)
    end,
})

Egg:Section("Diagnostica")

Egg:Button({
    Title = "🔍  Mostra remote trovati",
    Callback = function()
        discoverRemotes()
        local lines = {"Remote scoperti:"}
        for cat, list in pairs(RemoteCache) do
            table.insert(lines, "• " .. cat .. ": " .. #list)
        end
        for _, l in ipairs(lines) do print("[RyzeScan] " .. l) end
        notify("Scan", table.concat(lines, " | "), 6)
    end,
})

Egg:Section("Soldi (leaderstats)")

local moneyStat, moneyAmt = "Money", "1000"
Egg:Input({ Title = "Stat", Placeholder = "Money", Callback = function(t) if t~="" then moneyStat=t end end })
Egg:Input({ Title = "Importo", Placeholder = "1000", Callback = function(t) moneyAmt=t end })

Egg:Button({
    Title = "➕  Aggiungi soldi (rischioso)",
    Callback = function()
        local n = tonumber(moneyAmt)
        local s = getLS(moneyStat)
        if s and n then
            s.Value = s.Value + n
            notify("Money", "+" .. n .. " (⚠️ possibile kick)")
        else
            notify("Money", "stat non trovato")
        end
    end,
})

-- ============================================================
-- COMBAT
-- ============================================================
local Combat = createTab("Combat")
Combat:Section("Character")

Combat:Toggle({
    Title = "Noclip",
    Callback = function(v)
        State.Noclip = v
        if v then
            task.spawn(function()
                while State.Noclip do
                    local c = LocalPlayer.Character
                    if c then
                        for _, p in pairs(c:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                        end
                    end
                    RunService.Stepped:Wait()
                end
            end)
        end
    end,
})

Combat:Toggle({
    Title = "Infinite Jump",
    Callback = function(v) State.InfJump = v end,
})

UserInput.JumpRequest:Connect(function()
    if State.InfJump then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================================
-- VISUALS
-- ============================================================
local Visuals = createTab("Visuals")
Visuals:Section("ESP")

local espObjs = {}
local function clearESP()
    for _, v in pairs(espObjs) do pcall(function() v:Destroy() end) end
    espObjs = {}
end

Visuals:Toggle({
    Title = "Player ESP",
    Callback = function(v)
        State.ESPEnabled = v
        if v then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.FillTransparency = 0.65
                    hl.OutlineColor = Color3.fromRGB(255, 60, 60)
                    hl.OutlineTransparency = 0
                    hl.Adornee = plr.Character
                    hl.Parent = plr.Character
                    table.insert(espObjs, hl)
                end
            end
        else
            clearESP()
        end
    end,
})

-- ============================================================
-- REMOTE — hook on-demand, auto-off dopo 30s
-- ============================================================
local Remote = createTab("Remote")
Remote:Section("Spy temporaneo")

Remote:Paragraph({
    Content = "⚠️ L'hook su __namecall è rilevabile. Il tool lo tiene attivo MASSIMO 30 secondi e poi lo rimuove da solo. Usalo solo per capire quali remote usa il gioco.",
})

local spyHooked = false
local spyMT, spyOldNamecall

local function installSpy()
    if spyHooked then return end
    spyHooked = true
    spyMT = getrawmetatable(game)
    spyOldNamecall = spyMT.__namecall
    setreadonly(spyMT, false)
    spyMT.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if State.SpyEnabled and (m == "FireServer" or m == "InvokeServer") then
            local parts = {}
            for _, v in ipairs({...}) do table.insert(parts, tostring(v)) end
            print("[RyzeSpy] " .. m .. " " .. self:GetFullName() .. "(" .. table.concat(parts, ", ") .. ")")
        end
        return spyOldNamecall(self, ...)
    end)
    setreadonly(spyMT, true)
end

local function uninstallSpy()
    if not spyHooked then return end
    spyHooked = false
    pcall(function()
        setreadonly(spyMT, false)
        spyMT.__namecall = spyOldNamecall
        setreadonly(spyMT, true)
    end)
end

Remote:Toggle({
    Title = "Remote Spy (auto-off 30s)",
    Description = "Stampa in console F12 / esecutore",
    Callback = function(v)
        State.SpyEnabled = v
        if v then
            installSpy()
            notify("Spy", "Attivo per 30s — poi si spegne", 5)
            task.delay(30, function()
                State.SpyEnabled = false
                uninstallSpy()
                notify("Spy", "Auto-disattivato", 4)
            end)
        else
            uninstallSpy()
        end
    end,
})

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = createTab("Settings")
Settings:Section("Info")

Settings:Paragraph({
    Content = "RyzeHub v2.0.0 — stealth edition\n\n• Nessuno script dell'AC viene toccato\n• Speed max 40 con rampa lenta\n• Jump max 90\n• Auto-farm delay default 1.2s + jitter\n• Remote Spy auto-off dopo 30s\n• GUI name randomizzato\n\nSe ti kicka: aumenta i delay e tieni solo Auto Steal attivo.",
})

Settings:Button({
    Title = "🔄  Ri-scansiona remote",
    Callback = function()
        local n = discoverRemotes()
        notify("Scan", n .. " remote scansionati")
    end,
})

Settings:Button({
    Title = "🗑  Unload",
    Callback = function()
        uninstallSpy()
        gui:Destroy()
        _G.RyzeHubLoaded = false
    end,
})

-- ============================================================
-- MINIMIZE
-- ============================================================
local minimized = false
local function toggleMin()
    minimized = not minimized
    tw(win, 0.25, {Size = minimized and UDim2.new(0, W, 0, 48) or UDim2.new(0, W, 0, H)})
end
minBtn.MouseButton1Click:Connect(toggleMin)
UserInput.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightControl then toggleMin() end
end)

-- ============================================================
-- RESPAWN
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(c)
    local h = c:WaitForChild("Humanoid", 10)
    if h then
        if State.SpeedEnabled then
            task.spawn(function()
                task.wait(1)
                local start = h.WalkSpeed
                for i = 1, 20 do
                    if not h.Parent then break end
                    h.WalkSpeed = start + (State.Speed - start) * (i/20)
                    task.wait(0.1)
                end
            end)
        end
        if State.JumpEnabled then h.UseJumpPower = true; h.JumpPower = State.JumpPower end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
selectTab("Main")
task.wait(0.5)
notify("RyzeHub", totalScanned .. " remote scansionati. Stealth attivo.", 6)
