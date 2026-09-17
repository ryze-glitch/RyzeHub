-- language: Lua, file: loader.lua, target: Roblox
-- RyzeHub Loader v3.0.0 — Cache-busting, fetch sicuro e anti-doppio avvio

local CONFIG = {
    Version = "3.0.0",
    CoreURL = "https://raw.githubusercontent.com/ryze-glitch/RyzeHub/main/main.lua",
}

-- Controllo esecuzione precedente
if _G.RyzeHubLoaded then
    warn("[RyzeHub] Script già caricato in memoria.")
    return
end

-- Verifica disponibilità delle funzioni dell'esecutore
if not game.HttpGet or not loadstring then
    warn("[RyzeHub] Esecutore non supportato: HttpGet o loadstring mancanti.")
    return
end

-- Download con parametro anti-cache per evitare versioni vecchie salvate da GitHub CDN
local fetchURL = CONFIG.CoreURL .. "?nocache=" .. tostring(os.time())
local fetchOk, core = pcall(function()
    return game:HttpGet(fetchURL, true)
end)

if not fetchOk or not core or core == "" then
    warn("[RyzeHub] Download fallito: " .. tostring(core))
    return
end

-- Compilazione del codice
local chunk, compileErr = loadstring(core, "RyzeHubCore@" .. CONFIG.Version)
if not chunk then
    warn("[RyzeHub] Errore di compilazione: " .. tostring(compileErr))
    return
end

-- Esecuzione protetta del chunk principale
local runOk, runErr = pcall(chunk)
if not runOk then
    _G.RyzeHubLoaded = false
    warn("[RyzeHub] Errore runtime durante l'avvio: " .. tostring(runErr))
end
