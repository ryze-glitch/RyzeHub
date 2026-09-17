-- language: Lua, file: main.lua, target: Roblox Steal An Egg
-- RyzeHub v1.1.0 — UI custom, anti-detection, SAFE MODE default

if _G.RyzeHubLoaded then return end
_G.RyzeHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Replicated = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- ANTI-DETECTION: disabilita anticheat locale del gioco
-- ============================================================
local function killLocalAntiCheat()
    local killed = 0
    local targets = {
        LocalPlayer:FindFirstChild("PlayerScripts"),
        LocalPlayer:FindFirstChild("PlayerGui"),
        Replicated,
        game:GetService("StarterPlayer"),
    }
    for _, root in pairs(targets) do
        if root then
            for _, d in pairs(root:GetDescendants()) do
                if d:IsA("LocalScript") or d:IsA("Script") then
                    local n = d.Name:lower()
                    if n:find("anticheat") or n:find("anti_cheat") or n:find("ac_")
                       or n:find("guard") or n:find("detect") or n:find("monitor")
                       or n:find("protection") or n:find("security") then
                        pcall(function() d.Disabled = true; killed = killed + 1 end)
                    end
                end
            end
        end
    end
    return killed
end

local killed = killLocalAntiCheat()

-- ============================================================
-- COLORS
-- ============================================================
local C = {
    bg    = Color3.fromRGB(15, 15, 22),
    bg2   = Color3.fromRGB(22, 22, 32),
    bg3   = Color3.fromRGB(30, 30, 42),
    bg4   = Color3.fromRGB(40, 40, 55),
    accent = Color3.fromRGB(130, 100, 255),
    accent2 = Color3.fromRGB(160, 130, 255),
    ok    = Color3.fromRGB(80, 220, 130),
    text  = Color3.fromRGB(240, 240, 250),
    subtext = Color3.fromRGB(150, 150, 170),
    danger = Color3.fromRGB(240, 80, 90),
    warn  = Color3.fromRGB(250, 180, 60),
    font  = Enum.Font.Gotham,
    fontBold = Enum.Font.GothamBold,
}

local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function stroke(p, c, t) local s=Instance.new("UIStroke"); s.Color=c or C.bg4; s.Thickness=t or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function tw(o,t,p,st) TweenService:Create(o,TweenInfo.new(t,st or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end

-- ============================================================
-- ROOT
-- ============================================================
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui")
gui.Name = "RyzeHub_" .. tostring(math.random(1000, 9999))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
pcall(function() gui.Parent = parentGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 320, 1, -40)
notifHolder.Position = UDim2.new(1, -340, 0, 20)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = gui
local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Padding = UDim.new(0, 8)
notifLayout.Parent = notifHolder

local function notify(title, content, duration)
    duration = duration or 4
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

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -30, 0, 20)
    tLbl.Position = UDim2.new(0, 18, 0, 8)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = C.text
    tLbl.Font = C.fontBold
    tLbl.TextSize = 14
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.TextTransparency = 1
    tLbl.Parent = n

    local cLbl = Instance.new("TextLabel")
    cLbl.Size = UDim2.new(1, -30, 0, 24)
    cLbl.Position = UDim2.new(0, 18, 0, 28)
    cLbl.BackgroundTransparency = 1
    cLbl.Text = content
    cLbl.TextColor3 = C.subtext
    cLbl.Font = C.font
    cLbl.TextSize = 12
    cLbl.TextXAlignment = Enum.TextXAlignment.Left
    cLbl.TextWrapped = true
    cLbl.TextTransparency = 1
    cLbl.Parent = n

    local info = TweenInfo.new(0.3)
    TweenService:Create(n, info, {BackgroundTransparency = 0}):Play()
    TweenService:Create(bar, info, {BackgroundTransparency = 0}):Play()
    TweenService:Create(tLbl, info, {TextTransparency = 0}):Play()
    TweenService:Create(cLbl, info, {TextTransparency = 0}):Play()

    task.delay(duration, function()
        local o = TweenInfo.new(0.3)
        TweenService:Create(n, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(bar, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(tLbl, o, {TextTransparency = 1}):Play()
        TweenService:Create(cLbl, o, {TextTransparency = 1}):Play()
        task.wait(0.35); n:Destroy()
    end)
end

-- ============================================================
-- WINDOW
-- ============================================================
local W, H = 620, 420
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
glow.ImageTransparency = 0.82
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
local logoInner = Instance.new("Frame")
logoInner.Size = UDim2.new(0, 10, 0, 10)
logoInner.Position = UDim2.new(0.5, -5, 0.5, -5)
logoInner.BackgroundColor3 = C.bg
logoInner.BorderSizePixel = 0
logoInner.Parent = logo
corner(logoInner, 3)

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
verLbl.Text = "v1.1.0"
verLbl.TextColor3 = C.subtext
verLbl.Font = C.font
verLbl.TextSize = 11
verLbl.TextXAlignment = Enum.TextXAlignment.Left
verLbl.Parent = topBar

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(0, 220, 0.5, -4)
statusDot.BackgroundColor3 = C.ok
statusDot.BorderSizePixel = 0
statusDot.Parent = topBar
corner(statusDot, 4)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0, 100, 1, 0)
statusLbl.Position = UDim2.new(0, 234, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "SAFE MODE"
statusLbl.TextColor3 = C.ok
statusLbl.Font = C.fontBold
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = topBar

local function makeBtn(xPos, color, symbol, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, xPos, 0.5, -14)
    b.BackgroundColor3 = C.bg3
    b.Text = symbol
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

local minBtn = makeBtn(-78, C.subtext, "—", function() end)
local closeBtn = makeBtn(-44, C.danger, "✕", function()
    gui:Destroy(); _G.RyzeHubLoaded = false
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, -68)
sidebar.Position = UDim2.new(0, 10, 0, 58)
sidebar.BackgroundColor3 = C.bg2
sidebar.BorderSizePixel = 0
sidebar.Parent = win
corner(sidebar, 10)
local sLayout = Instance.new("UIListLayout")
sLayout.Padding = UDim.new(0, 6)
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.Parent = sidebar
local sPad = Instance.new("UIPadding")
sPad.PaddingTop = UDim.new(0, 10)
sPad.PaddingLeft = UDim.new(0, 8)
sPad.PaddingRight = UDim.new(0, 8)
sPad.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -180, 1, -68)
content.Position = UDim2.new(0, 170, 0, 58)
content.BackgroundTransparency = 1
content.Parent = win
local cLayout = Instance.new("UIListLayout")
cLayout.Padding = UDim.new(0, 8)
cLayout.SortOrder = Enum.SortOrder.LayoutOrder
cLayout.Parent = content
local cPad = Instance.new("UIPadding")
cPad.PaddingTop = UDim.new(0, 4)
cPad.PaddingRight = UDim.new(0, 10)
cPad.PaddingBottom = UDim.new(0, 10)
cPad.Parent = content

-- ============================================================
-- TABS
-- ============================================================
local tabs, tabBtns = {}, {}
local activeTab = nil

local function selectTab(name)
    if activeTab == name then return end
    activeTab = name
    for n, t in pairs(tabs) do t.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        local on = (n == name)
        tw(b, 0.15, {BackgroundColor3 = on and C.accent or C.bg3})
        b.TextColor3 = on and C.text or C.subtext
    end
end

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.bg3
    btn.Text = "  " .. name
    btn.TextColor3 = C.subtext
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
    local pLayout = Instance.new("UIListLayout")
    pLayout.Padding = UDim.new(0, 8)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Parent = page

    tabs[name] = page
    local api = {}
    local order = 0
    local function no() order = order + 1; return order end

    function api:Section(text)
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1, 0, 0, 28)
        s.BackgroundTransparency = 1
        s.LayoutOrder = no()
        s.Parent = page
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20)
        l.Position = UDim2.new(0, 4, 0, 4)
        l.BackgroundTransparency = 1
        l.Text = string.upper(text)
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
            d.TextColor3 = C.subtext
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
        box.PlaceholderColor3 = C.subtext
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
        l.TextColor3 = C.subtext
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
    SpyEnabled = false, SpyLog = {},
    InfiniteJump = false, Noclip = false,
    ESPEnabled = false,
    AutoSteal = false, AutoSell = false, AutoHatch = false,
    AutoDelay = 0.5,
}

local function getHumanoid()
    local c = LocalPlayer.Character
    if c then return c:FindFirstChildOfClass("Humanoid") end
end

local function getLS(name)
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return nil end
    return ls:FindFirstChild(name)
end

-- ============================================================
-- SAFE REMOTE FINDER — cerca remote per pattern
-- ============================================================
local function findRemote(patterns)
    for _, obj in pairs(Replicated:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            for _, p in ipairs(patterns) do
                if n:find(p) then return obj end
            end
        end
    end
    return nil
end

-- ============================================================
-- MAIN TAB
-- ============================================================
local Main = createTab("Main")
Main:Section("Movement (SAFE — cap 100)")

Main:Toggle({
    Title = "Speed Enabled",
    Description = "WalkSpeed personalizzato (max 100 per non triggerare AC)",
    Callback = function(v)
        State.SpeedEnabled = v
        local h = getHumanoid()
        if h then h.WalkSpeed = v and State.Speed or 16 end
    end,
})

Main:Slider({
    Title = "WalkSpeed",
    Min = 16, Max = 100, CurrentValue = 16, Suffix = " studs",
    Callback = function(v)
        State.Speed = v
        if State.SpeedEnabled then local h = getHumanoid(); if h then h.WalkSpeed = v end end
    end,
})

Main:Toggle({
    Title = "JumpPower Boost",
    Callback = function(v)
        State.JumpEnabled = v
        local h = getHumanoid()
        if h then h.UseJumpPower = true; h.JumpPower = v and State.JumpPower or 50 end
    end,
})

Main:Slider({
    Title = "JumpPower",
    Min = 50, Max = 150, CurrentValue = 50,
    Callback = function(v)
        State.JumpPower = v
        if State.JumpEnabled then local h = getHumanoid(); if h then h.JumpPower = v end end
    end,
})

-- ============================================================
-- STEAL AN EGG TAB
-- ============================================================
local Egg = createTab("Steal An Egg")
Egg:Section("Auto Farm")

Egg:Slider({
    Title = "Delay tra azioni",
    Min = 0.1, Max = 3, CurrentValue = 0.5, Suffix = "s",
    Callback = function(v) State.AutoDelay = v end,
})

Egg:Toggle({
    Title = "Auto Steal",
    Description = "Ruba uova automaticamente",
    Callback = function(v)
        State.AutoSteal = v
        if v then
            task.spawn(function()
                while State.AutoSteal do
                    local remote = findRemote({"steal", "grab", "pickup", "take"})
                    if remote then
                        pcall(function() remote:FireServer() end)
                    end
                    task.wait(State.AutoDelay + math.random() * 0.3)
                end
            end)
        end
    end,
})

Egg:Toggle({
    Title = "Auto Sell",
    Description = "Vende i pet automaticamente",
    Callback = function(v)
        State.AutoSell = v
        if v then
            task.spawn(function()
                while State.AutoSell do
                    local remote = findRemote({"sell", "sellall", "sellpet"})
                    if remote then
                        pcall(function()
                            if remote:IsA("RemoteFunction") then remote:InvokeServer()
                            else remote:FireServer() end
                        end)
                    end
                    task.wait(State.AutoDelay * 2 + math.random())
                end
            end)
        end
    end,
})

Egg:Toggle({
    Title = "Auto Hatch",
    Description = "Schiusa uova automaticamente",
    Callback = function(v)
        State.AutoHatch = v
        if v then
            task.spawn(function()
                while State.AutoHatch do
                    local remote = findRemote({"hatch", "open", "egg"})
                    if remote then
                        pcall(function()
                            if remote:IsA("RemoteFunction") then remote:InvokeServer("Basic")
                            else remote:FireServer("Basic") end
                        end)
                    end
                    task.wait(State.AutoDelay + math.random())
                end
            end)
        end
    end,
})

Egg:Button({
    Title = "🔍  Scansiona remote del gioco",
    Callback = function()
        local found = {}
        for _, obj in pairs(Replicated:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(found, obj:GetFullName())
            end
        end
        State.SpyLog = found
        notify("Scan", #found .. " remote trovati. Apri la tab Remote → Stampa log")
    end,
})

Egg:Section("Manipolazione diretta")

local moneyStat = "Money"
local moneyAmt = "1000"

Egg:Input({
    Title = "Stat soldi",
    Placeholder = "Money",
    Callback = function(t) if t ~= "" then moneyStat = t end end,
})

Egg:Input({
    Title = "Importo",
    Placeholder = "1000",
    Callback = function(t) moneyAmt = t end,
})

Egg:Button({
    Title = "➕  Aggiungi soldi (leaderstats)",
    Callback = function()
        local n = tonumber(moneyAmt)
        local s = getLS(moneyStat)
        if s and n then
            s.Value = s.Value + n
            notify("Money", "+" .. n)
        else
            notify("Money", "stat non trovato — usa Remote Spy per trovare il remote")
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
    Callback = function(v) State.InfiniteJump = v end,
})

UserInput.JumpRequest:Connect(function()
    if State.InfiniteJump then
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

local function applyESP(plr, color)
    if not plr.Character then return end
    local hl = Instance.new("Highlight")
    hl.Name = "RyzeESP"
    hl.FillColor = color
    hl.FillTransparency = 0.65
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.Adornee = plr.Character
    hl.Parent = plr.Character
    table.insert(espObjs, hl)
end

Visuals:Toggle({
    Title = "Player ESP",
    Callback = function(v)
        State.ESPEnabled = v
        if v then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then applyESP(plr, Color3.fromRGB(255, 60, 60)) end
            end
        else
            clearESP()
        end
    end,
})

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if State.ESPEnabled and plr ~= LocalPlayer then
            task.wait(0.3)
            applyESP(plr, Color3.fromRGB(255, 60, 60))
        end
    end)
end)

-- ============================================================
-- REMOTE
-- ============================================================
local Remote = createTab("Remote")
Remote:Section("Spy (⚠️ può triggerare AC — usare per pochi secondi)")

local hooked = false
local function installHooks()
    if hooked then return end
    hooked = true
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if State.SpyEnabled and (m == "FireServer" or m == "InvokeServer") then
            local parts = {}
            for _, v in ipairs({...}) do table.insert(parts, tostring(v)) end
            local entry = m .. " " .. self:GetFullName() .. "(" .. table.concat(parts, ", ") .. ")"
            table.insert(State.SpyLog, entry)
            if #State.SpyLog > 300 then table.remove(State.SpyLog, 1) end
            notify("Remote", entry, 4)
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

Remote:Toggle({
    Title = "Remote Spy",
    Description = "Logga le chiamate remote",
    Callback = function(v)
        State.SpyEnabled = v
        if v then installHooks() end
    end,
})

Remote:Button({
    Title = "📜  Stampa log in console",
    Callback = function()
        for _, l in ipairs(State.SpyLog) do print("[RyzeSpy] " .. l) end
        notify("Remote", #State.SpyLog .. " righe in console")
    end,
})

Remote:Button({
    Title = "🗑  Pulisci log",
    Callback = function() State.SpyLog = {}; notify("Remote", "pulito") end,
})

Remote:Section("Fire Manuale")
local remotePath, remoteArgs = "", ""
Remote:Input({Title="Percorso", Placeholder="ReplicatedStorage.X", Callback=function(t) remotePath=t end})
Remote:Input({Title="Args (csv)", Placeholder="1000, true", Callback=function(t) remoteArgs=t end})

local function parseArgs(s)
    local o = {}
    if not s or s == "" then return o end
    for a in s:gmatch("[^,]+") do
        local t = a:match("^%s*(.-)%s*$")
        local n = tonumber(t)
        if n then table.insert(o, n)
        elseif t == "true" then table.insert(o, true)
        elseif t == "false" then table.insert(o, false)
        else table.insert(o, t) end
    end
    return o
end

Remote:Button({
    Title = "🚀  Fire Remote",
    Callback = function()
        if remotePath == "" then notify("Errore", "percorso vuoto"); return end
        local obj = game
        for part in remotePath:gmatch("[^%.]+") do
            obj = obj:FindFirstChild(part)
            if not obj then notify("Errore", "non trovato: " .. part); return end
        end
        local a = parseArgs(remoteArgs)
        if obj:IsA("RemoteEvent") then obj:FireServer(table.unpack(a)); notify("Fire", "OK")
        elseif obj:IsA("RemoteFunction") then notify("Invoke", "→ " .. tostring(obj:InvokeServer(table.unpack(a))))
        else notify("Errore", "non è un remote") end
    end,
})

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = createTab("Settings")
Settings:Section("Info")

Settings:Paragraph({
    Content = "RyzeHub v1.1.0\nAnti-detection attivo\n\n• SAFE MODE: speed max 100, jump max 150\n• Remote Spy hooka __namecall — usa solo per pochi secondi\n• Auto-farm usa delay random per evitare pattern detection\n\nRightControl = minimize",
})

Settings:Button({
    Title = "🧹  Ri-disabilita anticheat locale",
    Callback = function()
        local n = killLocalAntiCheat()
        notify("AC", n .. " script disabilitati")
    end,
})

Settings:Button({
    Title = "♻  Reset stato",
    Callback = function()
        State.Speed = 16; State.SpeedEnabled = false
        State.JumpPower = 50; State.JumpEnabled = false
        State.Noclip = false; State.InfiniteJump = false
        State.SpyEnabled = false; State.SpyLog = {}
        State.ESPEnabled = false; State.AutoSteal = false
        State.AutoSell = false; State.AutoHatch = false
        clearESP()
        local h = getHumanoid()
        if h then h.WalkSpeed = 16; h.JumpPower = 50 end
        notify("Reset", "ok")
    end,
})

Settings:Button({
    Title = "🗑  Unload RyzeHub",
    Callback = function()
        gui:Destroy(); _G.RyzeHubLoaded = false
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
        if State.SpeedEnabled then h.WalkSpeed = State.Speed end
        if State.JumpEnabled then h.UseJumpPower = true; h.JumpPower = State.JumpPower end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
selectTab("Main")
notify("RyzeHub", killed .. " anticheat locali disabilitati. v1.1.0 caricato.", 6)
