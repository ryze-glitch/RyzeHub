-- language: Lua, file: loader.lua, target: Roblox
-- *RyzeHub Loader — viene scaricato dalla one-liner in Solara*

local CONFIG = {
    Version = "1.0.0",
    CoreURL = "https://raw.githubusercontent.com/ryze-glitch/RyzeHub/main/main.lua",
}

-- Anti-doppio caricamento
if _G.RyzeHubLoaded then
    warn("[RyzeHub] già caricato")
    return
end

local ok, core = pcall(function()
    return game:HttpGet(CONFIG.CoreURL, true)
end)

if not ok or not core or core == "" then
    warn("[RyzeHub] fetch fallito: " .. tostring(core))
    return
end

local chunk, err = loadstring(core, "RyzeHub@" .. CONFIG.Version)
if not chunk then
    warn("[RyzeHub] loadstring: " .. tostring(err))
    return
end

local ok2, runErr = pcall(chunk)
if not ok2 then
    warn("[RyzeHub] runtime: " .. tostring(runErr))
end
