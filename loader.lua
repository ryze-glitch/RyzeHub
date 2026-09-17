-- language: Lua, file: loader.lua, target: Roblox
-- RyzeHub Loader — fetch sicuro e anti-doppio caricamento

local CONFIG = {
    Version = "2.1.0",
    CoreURL = "https://raw.githubusercontent.com/ryze-glitch/RyzeHub/main/main.lua",
}

if _G.RyzeHubLoaded then
    warn("[RyzeHub] Script già in esecuzione.")
    return
end

local ok, core = pcall(function()
    return game:HttpGet(CONFIG.CoreURL, true)
end)

if not ok or not core or core == "" then
    warn("[RyzeHub] Errore durante il download del core: " .. tostring(core))
    return
end

local chunk, compileErr = loadstring(core, "RyzeHub@" .. CONFIG.Version)
if not chunk then
    warn("[RyzeHub] Errore di compilazione: " .. tostring(compileErr))
    return
end

local execOk, runtimeErr = pcall(chunk)
if not execOk then
    warn("[RyzeHub] Errore di esecuzione runtime: " .. tostring(runtimeErr))
end
