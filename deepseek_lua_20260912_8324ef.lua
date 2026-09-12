local Arcane = loadstring(game:HttpGet("https://raw.githubusercontent.com/Da7mu/Ui-Collection/refs/heads/main/Arcane%20Ui/Library.lua"))()

local Window = Arcane:Window({
    Name = "DARK HUB",
    User = game.Players.LocalPlayer.Name,
    Logo = "97741915311873"
})

-- ... all the state and logic from before ...

-- Pages
local MainPage = Window:Page({ Name = "Main", Icon = "shield" })
local VisualPage = Window:Page({ Name = "Visual", Icon = "eye" })
local AimPage = Window:Page({ Name = "Aim", Icon = "crosshair" })
local FarmPage = Window:Page({ Name = "Farm", Icon = "shopping-bag" })
local TPPage = Window:Page({ Name = "TP", Icon = "map-pin" })
local VehiclePage = Window:Page({ Name = "Vehicle", Icon = "car" })
local InfoPage = Window:Page({ Name = "Info", Icon = "info" })
local ConfigPage = Window:Page({ Name = "Config", Icon = "save" })