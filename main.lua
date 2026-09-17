-- language: Lua, file: main.lua, target: Roblox Steal An Egg + universale
-- *RyzeHub Core — caricato dal loader, non incollare direttamente*

if _G.RyzeHubLoaded then
    warn("[RyzeHub] già caricato")
    return
end
_G.RyzeHubLoaded = true

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
    Name       = "RyzeHub",
    Version    = "1.0.0",
    Author     = "Lunar",
    Accent     = Color3.fromRGB(120, 90, 255),   -- viola elettrico
    Background = Color3.fromRGB(18, 18, 24),
    Text       = Color3.fromRGB(235, 235, 245),
    SubText    = Color3.fromRGB(140, 140, 160),
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local Replicated     = game:GetService("ReplicatedStorage")
local RunService     = game:GetService("RunService")
local UserInput      = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local CoreGui        = game:GetService("CoreGui")
local LocalPlayer    = Players.LocalPlayer

-- ============================================================
-- FLUENT UI (fallback a Rayfield se non disponibile)
-- ============================================================
local Fluent
local ok = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not ok or not Fluent then
    warn("[RyzeHub] Fluent UI non disponibile — uso fallback minimale")
    -- Fallback Rayfield
    Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Rayfield/main/Rayfield.lua"))()
end

-- ============================================================
-- STATE
-- ============================================================
local State = {
    Speed         = 16,
    SpeedEnabled  = false,
    JumpPower     = 50,
    JumpEnabled   = false,
    SpyEnabled    = false,
    SpyLog        = {},
    InfiniteJump  = false,
    Noclip        = false,
    LastHumanoid  = nil,
}

-- ============================================================
-- GUI — WINDOW
-- ============================================================
local Window
if Fluent.CreateWindow then
    -- Fluent API
    Window = Fluent:CreateWindow({
        Title = CONFIG.Name .. " — " .. CONFIG.Version,
        SubTitle = "by " .. CONFIG.Author,
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl,
    })
else
    -- Rayfield API
    Window = Fluent:CreateWindow({
        Name = CONFIG.Name .. " — " .. CONFIG.Version,
        LoadingTitle = "RyzeHub",
        LoadingSubtitle = "by " .. CONFIG.Author,
        ConfigurationSaving = { Enabled = false },
    })
end

-- ============================================================
-- TABS
-- ============================================================
local function mkTab(name, icon)
    if Window.CreateTab and Window.Tabs == nil then
        -- Fluent
        return Window:CreateTab(name, icon)
    else
        -- Rayfield
        return Window:CreateTab(name, icon)
    end
end

local Tabs = {
    Main     = Window:CreateTab("Main", 4483362458),
    Combat   = Window:CreateTab("Combat", 4483362458),
    Visuals  = Window:CreateTab("Visuals", 4483362458),
    Remote   = Window:CreateTab("Remote", 4483362458),
    Settings = Window:CreateTab("Settings", 4483362458),
}

-- ============================================================
-- HELPERS
-- ============================================================
local function notify(title, content, duration)
    duration = duration or 4
    if Fluent.Notify then
        Fluent:Notify({ Title = title, Content = content, Duration = duration })
    end
end

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getChar()
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function getLeaderstat(name)
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return nil end
    return ls:FindFirstChild(name)
end

-- ============================================================
-- TAB: MAIN — SPEED & MONEY
-- ============================================================
local MainSection = Tabs.Main:CreateSection("Movement")

Tabs.Main:CreateToggle({
    Title = "Speed Enabled",
    Description = "Applica WalkSpeed personalizzato",
    CurrentValue = false,
    Flag = "SpeedEnabled",
    Callback = function(v)
        State.SpeedEnabled = v
        local h = getHumanoid()
        if h then
            h.WalkSpeed = v and State.Speed or 16
        end
    end,
})

Tabs.Main:CreateSlider({
    Title = "WalkSpeed",
    Description = "Velocità di movimento",
    Range = {16, 300},
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(v)
        State.Speed = v
        if State.SpeedEnabled then
            local h = getHumanoid()
            if h then h.WalkSpeed = v end
        end
    end,
})

Tabs.Main:CreateInput({
    Title = "Velocità esatta",
    Description = "Imposta un valore preciso",
    Placeholder = "es. 75",
    RemoveTextAfterFocusLost = false,
    Flag = "SpeedInput",
    Callback = function(txt)
        local n = tonumber(txt)
        if n then
            State.Speed = n
            if State.SpeedEnabled then
                local h = getHumanoid()
                if h then h.WalkSpeed = n end
            end
        end
    end,
})

Tabs.Main:CreateToggle({
    Title = "JumpPower boost",
    Description = "Salto potenziato",
    CurrentValue = false,
    Flag = "JumpEnabled",
    Callback = function(v)
        State.JumpEnabled = v
        local h = getHumanoid()
        if h then
            h.UseJumpPower = true
            h.JumpPower = v and State.JumpPower or 50
        end
    end,
})

Tabs.Main:CreateSlider({
    Title = "JumpPower",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(v)
        State.JumpPower = v
        if State.JumpEnabled then
            local h = getHumanoid()
            if h then h.JumpPower = v end
        end
    end,
})

-- MONEY
local MoneySection = Tabs.Main:CreateSection("Money — leaderstats")

local function listLeaderstats()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return {} end
    local names = {}
    for _, v in pairs(ls:GetChildren()) do
        if v:IsA("ValueBase") then
            table.insert(names, v.Name)
        end
    end
    return names
end

local moneyTarget = "Money"
local moneyNames = listLeaderstats()

Tabs.Main:CreateDropdown({
    Title = "Stat da modificare",
    Options = #moneyNames > 0 and moneyNames or {"Money", "Cash", "Coins"},
    CurrentOption = {"Money"},
    Flag = "MoneyStat",
    Callback = function(opt)
        moneyTarget = opt
    end,
})

local MoneyInputValue = "1000"

Tabs.Main:CreateInput({
    Title = "Importo",
    Placeholder = "es. 10000",
    RemoveTextAfterFocusLost = false,
    Flag = "MoneyAmount",
    Callback = function(txt)
        MoneyInputValue = txt
    end,
})

Tabs.Main:CreateButton({
    Title = "Aggiungi soldi",
    Description = "Somma l'importo allo stat",
    Callback = function()
        local n = tonumber(MoneyInputValue)
        local stat = getLeaderstat(moneyTarget)
        if stat and n then
            stat.Value = stat.Value + n
            notify("Money", "+" .. n .. " " .. moneyTarget)
        else
            notify("Money", "stat non trovato: " .. moneyTarget)
        end
    end,
})

Tabs.Main:CreateButton({
    Title = "Imposta soldi",
    Description = "Sostituisci il valore",
    Callback = function()
        local n = tonumber(MoneyInputValue)
        local stat = getLeaderstat(moneyTarget)
        if stat and n then
            stat.Value = n
            notify("Money", moneyTarget .. " = " .. n)
        else
            notify("Money", "stat non trovato: " .. moneyTarget)
        end
    end,
})

-- ============================================================
-- TAB: COMBAT
-- ============================================================
Tabs.Combat:CreateSection("Character")

Tabs.Combat:CreateToggle({
    Title = "Noclip",
    Description = "Attraversa i muri",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        State.Noclip = v
        if v then
            task.spawn(function()
                while State.Noclip do
                    local char = LocalPlayer.Character
                    if char then
                        for _, p in pairs(char:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then
                                p.CanCollide = false
                            end
                        end
                    end
                    RunService.Stepped:Wait()
                end
            end)
        end
    end,
})

Tabs.Combat:CreateToggle({
    Title = "Infinite Jump",
    Description = "Salto infinito in aria",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(v)
        State.InfiniteJump = v
    end,
})

UserInput.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Tabs.Combat:CreateButton({
    Title = "Reset character",
    Callback = function()
        local h = getHumanoid()
        if h then h.Health = 0 end
    end,
})

-- ============================================================
-- TAB: VISUALS
-- ============================================================
Tabs.Visuals:CreateSection("ESP")

local espEnabled = false
local espObjects = {}

local function createESP(part, color)
    if not part or not part:IsA("BasePart") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "RyzeESP"
    hl.FillColor = color
    hl.FillTransparency = 0.7
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.Adornee = part
    hl.Parent = part
    table.insert(espObjects, hl)
end

local function clearESP()
    for _, v in pairs(espObjects) do
        if v then v:Destroy() end
    end
    espObjects = {}
end

Tabs.Visuals:CreateToggle({
    Title = "Player ESP",
    Description = "Evidenzia i giocatori",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(v)
        espEnabled = v
        if v then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    createESP(plr.Character:FindFirstChild("HumanoidRootPart"), plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 60, 60))
                end
            end
        else
            clearESP()
        end
    end,
})

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if espEnabled and plr ~= LocalPlayer then
            task.wait(0.5)
            createESP(char:FindFirstChild("HumanoidRootPart"), Color3.fromRGB(255, 60, 60))
        end
    end)
end)

-- ============================================================
-- TAB: REMOTE SPY
-- ============================================================
Tabs.Remote:CreateSection("Spy")

local remoteEventConn
local hookInstalled = false

local function installHooks()
    if hookInstalled then return end
    hookInstalled = true

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if State.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            local parts = {}
            for _, v in ipairs(args) do
                table.insert(parts, tostring(v))
            end
            local entry = method .. " " .. self:GetFullName() .. "(" .. table.concat(parts, ", ") .. ")"
            table.insert(State.SpyLog, entry)
            if #State.SpyLog > 100 then table.remove(State.SpyLog, 1) end
            notify("Remote", entry, 4)
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

Tabs.Remote:CreateToggle({
    Title = "Remote Spy",
    Description = "Logga FireServer / InvokeServer",
    CurrentValue = false,
    Flag = "Spy",
    Callback = function(v)
        State.SpyEnabled = v
        if v then installHooks() end
    end,
})

Tabs.Remote:CreateButton({
    Title = "Stampa log in console",
    Callback = function()
        for _, line in ipairs(State.SpyLog) do
            print("[RyzeSpy] " .. line)
        end
        notify("Remote", #State.SpyLog .. " righe stampate in console")
    end,
})

Tabs.Remote:CreateButton({
    Title = "Pulisci log",
    Callback = function()
        State.SpyLog = {}
        notify("Remote", "Log pulito")
    end,
})

-- FIRE MANUALE
Tabs.Remote:CreateSection("Fire manuale")

local remotePath = ""
local remoteArgs = ""

Tabs.Remote:CreateInput({
    Title = "Percorso remote",
    Placeholder = "ReplicatedStorage.Remotes.AddMoney",
    RemoveTextAfterFocusLost = false,
    Flag = "RemotePath",
    Callback = function(txt) remotePath = txt end,
})

Tabs.Remote:CreateInput({
    Title = "Argomenti (csv)",
    Placeholder = "1000, true, hello",
    RemoveTextAfterFocusLost = false,
    Flag = "RemoteArgs",
    Callback = function(txt) remoteArgs = txt end,
})

local function parseArgs(str)
    local out = {}
    if not str or str == "" then return out end
    for arg in str:gmatch("[^,]+") do
        local trimmed = arg:match("^%s*(.-)%s*$")
        local n = tonumber(trimmed)
        if n then table.insert(out, n)
        elseif trimmed == "true" then table.insert(out, true)
        elseif trimmed == "false" then table.insert(out, false)
        elseif trimmed == "nil" then table.insert(out, nil)
        else table.insert(out, trimmed) end
    end
    return out
end

Tabs.Remote:CreateButton({
    Title = "Fire Remote",
    Callback = function()
        if remotePath == "" then
            notify("Errore", "Percorso vuoto"); return
        end
        local obj = game
        for part in remotePath:gmatch("[^%.]+") do
            obj = obj:FindFirstChild(part)
            if not obj then
                notify("Errore", "non trovato: " .. part); return
            end
        end
        local args = parseArgs(remoteArgs)
        if obj:IsA("RemoteEvent") then
            obj:FireServer(table.unpack(args))
            notify("Fire", "OK " .. remotePath)
        elseif obj:IsA("RemoteFunction") then
            local r = obj:InvokeServer(table.unpack(args))
            notify("Invoke", remotePath .. " -> " .. tostring(r))
        else
            notify("Errore", "non è un remote")
        end
    end,
})

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
Tabs.Settings:CreateSection("RyzeHub")

Tabs.Settings:CreateParagraph({
    Title = "Informazioni",
    Content = CONFIG.Name .. " v" .. CONFIG.Version .. "\nby " .. CONFIG.Author .. "\n\nTasto minimize: RightControl",
})

Tabs.Settings:CreateButton({
    Title = "Reset stato interno",
    Callback = function()
        State.Speed = 16
        State.SpeedEnabled = false
        State.JumpPower = 50
        State.JumpEnabled = false
        State.Noclip = false
        State.InfiniteJump = false
        State.SpyEnabled = false
        State.SpyLog = {}
        local h = getHumanoid()
        if h then
            h.WalkSpeed = 16
            h.JumpPower = 50
        end
        notify("Reset", "stato ripristinato")
    end,
})

Tabs.Settings:CreateButton({
    Title = "Unload RyzeHub",
    Callback = function()
        _G.RyzeHubLoaded = false
        if Fluent.Destroy then Fluent:Destroy()
        elseif Window.Destroy then Window:Destroy() end
        clearESP()
    end,
})

-- ============================================================
-- BOOT NOTIFY
-- ============================================================
notify("RyzeHub", "v" .. CONFIG.Version .. " caricato. RightControl per minimizzare.", 6)

-- ============================================================
-- CHARACTER RESPAWN — riapplica speed
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    local h = char:WaitForChild("Humanoid", 10)
    if h and State.SpeedEnabled then
        h.WalkSpeed = State.Speed
    end
    if h and State.JumpEnabled then
        h.UseJumpPower = true
        h.JumpPower = State.JumpPower
    end
end)
