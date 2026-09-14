--Tycoon de Mineração Definitivo
local function LoadScript(url)
    local httpSuccess, source = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not httpSuccess then
        warn("Falha no HttpGet:", source)
        return
    end

    local compileSuccess, scriptFunction = pcall(loadstring, source)
    if not compileSuccess or type(scriptFunction) ~= "function" then
        warn("Falha no loadstring:", scriptFunction)
        return
    end

    local runSuccess, runError = pcall(scriptFunction)
    if not runSuccess then
        warn("Falha ao executar script:", runError)
    end
end

local placeId = tostring(game.PlaceId)
print("PlaceId atual:", placeId)

if placeId == "140374914197602" then
    LoadScript("https://raw.githubusercontent.com/oRHDoshacks/RobloxScripts/refs/heads/main/Scripts/frmn.lua")
elseif placeId == "4972091010" then
    LoadScript("https://raw.githubusercontent.com/oRHDoshacks/RobloxScripts/refs/heads/main/Scripts/Zombies.lua")
else
    warn("PlaceId sem script:", placeId)
end