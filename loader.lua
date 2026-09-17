-- language: Lua, file: loader.lua, target: Roblox
-- RyzeHub Loader v3.1.0 — Cache-Buster, Error Guard & Safe Load

local CONFIG = {
    Version = "3.1.0",
    CoreURL = "https://raw.githubusercontent.com/ryze-glitch/RyzeHub/main/main.lua",
}

if _G.RyzeHubLoaded then
    warn("[RyzeHub] Script già attivo in memoria.")
    return
end

if not game.HttpGet or not loadstring then
    warn("[RyzeHub] Funzioni HttpGet o loadstring non presenti nell'esecutore.")
    return
end

-- Bypass cache GitHub per caricare istantaneamente le modifiche puslate
local noCacheURL = CONFIG.CoreURL .. "?t=" .. tostring(os.time())
local okFetch, core = pcall(function()
    return game:HttpGet(noCacheURL, true)
end)

if not okFetch or not core or core == "" then
    warn("[RyzeHub] Download fallito: " .. tostring(core))
    return
end

local chunk, compileErr = loadstring(core, "RyzeHubCore@" .. CONFIG.Version)
if not chunk then
    warn("[RyzeHub] Errore di sintassi nel Core: " .. tostring(compileErr))
    return
end

local okRun, runErr = pcall(chunk)
if not okRun then
    _G.RyzeHubLoaded = false
    warn("[RyzeHub] Crash all'avvio: " .. tostring(runErr))
end
