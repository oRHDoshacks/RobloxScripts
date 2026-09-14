--Tycoon de Mineração Definitivo
local function LoadScript(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)

    if not success then
        warn("Falha ao carregar script:", result)
    end
end

if game.PlaceId == "140374914197602" then
    LoadScript("https://raw.githubusercontent.com/oRHDoshacks/RobloxScripts/refs/heads/main/Scripts/frmn.lua")
elseif game.PlaceId == "4972091010" then
    LoadScript("https://raw.githubusercontent.com/oRHDoshacks/RobloxScripts/refs/heads/main/Scripts/Zombies.lua")
end