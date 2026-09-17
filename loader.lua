-- language: Lua, file: loader.lua, target: Roblox
-- *RyzeHub Loader v3.2.0 — cache-busting dinamico, safe fetch e reset stato*

local CONFIG = {
    Version = "3.2.0",
    CoreURL = "https://raw.githubusercontent.com/ryze-glitch/RyzeHub/main/main.lua",
}

-- Reset della sessione precedente per consentire il re-load pulito
if _G.RyzeHubLoaded then
    warn("[RyzeHub] Sessione precedente rilevata. Reset in corso...")
    _G.RyzeHubLoaded = nil
end

-- Verifica disponibilità delle funzioni primitive dell'esecutore
if not game.HttpGet or not loadstring then
    warn("[RyzeHub] Esecutore non compatibile: HttpGet o loadstring assenti.")
    return
end

-- Cache-busting aggressivo tramite tick() per aggirare la CDN di raw.githubusercontent.com
local freshURL = CONFIG.CoreURL .. "?nocache=" .. tostring(tick()) .. "_" .. tostring(math.random(10000, 99999))

local okFetch, core = pcall(function()
    return game:HttpGet(freshURL, true)
end)

if not okFetch or not core or core == "" then
    warn("[RyzeHub] Errore nel recupero del file remoto: " .. tostring(core))
    return
end

-- Compilazione isolata del chunk
local chunk, compileErr = loadstring(core, "RyzeHubCore@" .. CONFIG.Version)
if not chunk then
    warn("[RyzeHub] Errore di compilazione: " .. tostring(compileErr))
    return
end

-- Esecuzione protetta con traceback
local okRun, runErr = pcall(chunk)
if not okRun then
    _G.RyzeHubLoaded = nil
    warn("[RyzeHub] Errore di esecuzione: " .. tostring(runErr))
else
    print("[RyzeHub] Core v" .. CONFIG.Version .. " caricato con successo.")
end
