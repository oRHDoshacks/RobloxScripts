local placeId = tostring(game.PlaceId)
print("PlaceId atual:", placeId)

if placeId == "140374914197602" then
     loadstring(game:HttpGet("https://raw.githubusercontent.com/oRHDoshacks/RobloxScripts/refs/heads/main/Scripts/frmn.lua",true))()
elseif placeId == "4972091010" then
     loadstring(game:HttpGet("https://raw.githubusercontent.com/oRHDoshacks/RobloxScripts/refs/heads/main/Scripts/Zombies.lua",true))()
elseif placeId == "292439477" then
     loadstring(game:HttpGet("https://raw.githubusercontent.com/oRHDoshacks/RobloxScripts/refs/heads/main/Scripts/Pforces.lua",true))()
else
    warn("Jogo sem script:", placeId)
end
