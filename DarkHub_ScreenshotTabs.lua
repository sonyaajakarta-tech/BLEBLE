local Zolar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Da7mu/Ui-Collection/refs/heads/main/Zolar%20Ui/Library.lua"))()

local Window = Zolar:Window({
    Name = "ZOLAR",
    Icon = "128056142918696",
    Accent = Color3.fromRGB(179, 165, 255)
})

local Main = Window:Tab({
    Name = "MAIN",
    Icon = "home"
})

local Visuals = Window:Tab({
    Name = "VISUAL",
    Icon = "eye"
})

local Aimbot = Window:Tab({
    Name = "AIM",
    Icon = "crosshair"
})

local Triggerbot = Aimbot

local Farm = Window:Tab({
    Name = "FARM",
    Icon = "sprout"
})

local TP = Window:Tab({
    Name = "TP",
    Icon = "map-pin"
})

local Info = Window:Tab({
    Name = "INFO",
    Icon = "info"
})

local Settings = Window:Tab({
    Name = "CFG",
    Icon = "settings"
})

local Veh = Window:Tab({
    Name = "VEH",
    Icon = "car"
})

local AimMain = Aimbot:Section({
    Name = "Main",
    Side = 1
})

local AimEnabled = AimMain:Toggle({
    Name = "Enabled",
    Default = true,
    Flag = "aim_enabled",
    Callback = function(Value)
        if Value then
            Zolar:Notification({
                Name = "Aimbot enabled",
                Description = "Targeting is now active.",
                Icon = "crosshair",
                Duration = 3
            })
        end
    end
})

AimEnabled:Keybind({
    Default = Enum.KeyCode.Q,
    Flag = "aim_enabled_key"
})

AimMain:Toggle({
    Name = "Team check",
    Default = true,
    Flag = "aim_team"
})

AimMain:Toggle({
    Name = "Visible check",
    Default = false,
    Flag = "aim_visible"
})

AimMain:Dropdown({
    Name = "Target part",
    Items = {
        "Head",
        "Torso",
        "Legs",
        "Random"
    },
    Default = "Head",
    Flag = "aim_part",
    Callback = function(Value) print("part:", Value) end
})

AimMain:Dropdown({
    Name = "Ignored teams",
    Items = {
        "Red",
        "Blue",
        "Green",
        "Yellow",
        "Neutral"
    },
    Multi = true,
    Default = {
        "Red"
    },
    Flag = "aim_ignore",
    Callback = function(Value) print("ignored:", table.concat(Value, ", ")) end
})

local AimTuning = Aimbot:Section({
    Name = "Tuning",
    Side = 2
})

AimTuning:Slider({
    Name = "FOV",
    Min = 0,
    Max = 360,
    Default = 120,
    Suffix = "°",
    Flag = "aim_fov"
})

AimTuning:Slider({
    Name = "Smoothing",
    Min = 0,
    Max = 100,
    Default = 45,
    Suffix = "%",
    Flag = "aim_smooth"
})

AimTuning:RangeSlider({
    Name = "Distance range",
    Min = 0,
    Max = 1000,
    Default = {
        50,
        600
    },
    Suffix = "m",
    Flag = "aim_range"
})

AimTuning:Keybind({
    Name = "Aim key",
    Default = Enum.KeyCode.E,
    Flag = "aim_key"
})

AimTuning:Colorpicker({
    Name = "FOV color",
    Default = Color3.fromRGB(179, 165, 255),
    Transparency = 0.2,
    Flag = "aim_fov_color"
})

AimTuning:Button({
    Name = "Reset tuning",
    Callback = function()
        Zolar:Notification({
            Name = "Tuning reset",
            Description = "All aim values returned to defaults.",
            Icon = "rotate-ccw",
            Duration = 3
        })
    end
})

local AimPrediction = Aimbot:Section({
    Name = "Prediction",
    Side = 1
})

AimPrediction:Toggle({
    Name = "Velocity prediction",
    Default = true,
    Flag = "aim_pred"
})

AimPrediction:Slider({
    Name = "Prediction factor",
    Min = 0,
    Max = 3,
    Default = 1.2,
    Decimals = 0.1,
    Flag = "aim_pred_factor"
})

AimPrediction:Toggle({
    Name = "Resolver",
    Default = false,
    Flag = "aim_resolver"
})

local AimExtras = Aimbot:Section({
    Name = "Aim visuals",
    Side = 2
})

local FovCircle = AimExtras:Toggle({
    Name = "FOV circle",
    Default = true,
    Flag = "aim_fov_show"
})

local FovOptions = FovCircle:Extra({ })

FovOptions:Slider({
    Name = "Thickness",
    Min = 1,
    Max = 6,
    Default = 2,
    Flag = "aim_fov_thick"
})

FovOptions:Toggle({
    Name = "Filled",
    Default = false,
    Flag = "aim_fov_filled"
})

FovOptions:Colorpicker({
    Name = "Circle color",
    Default = Color3.fromRGB(179, 165, 255),
    Flag = "aim_fov_circle_color"
})

AimExtras:Toggle({
    Name = "Show target",
    Default = false,
    Flag = "aim_show_target"
})

local TriggerMain = Triggerbot:Section({
    Name = "Trigger",
    Side = 1
})

TriggerMain:Toggle({
    Name = "Enabled",
    Default = false,
    Flag = "trig_enabled"
})

TriggerMain:Slider({
    Name = "Delay",
    Min = 0,
    Max = 500,
    Default = 80,
    Suffix = "ms",
    Flag = "trig_delay"
})

TriggerMain:Textbox({
    Name = "Whitelist name",
    Placeholder = "username",
    Finished = true,
    Flag = "trig_whitelist"
})

local TriggerFilters = Triggerbot:Section({
    Name = "Filters",
    Side = 2
})

local WallCheck = TriggerFilters:Toggle({
    Name = "Wall check",
    Default = true,
    Flag = "trig_walls"
})

WallCheck:Keybind({
    Default = Enum.KeyCode.T,
    Flag = "trig_walls_key"
})

TriggerFilters:Dropdown({
    Name = "Ignored classes",
    Items = {
        "Scout",
        "Sniper",
        "Medic",
        "Heavy",
        "Spy"
    },
    Multi = true,
    Flag = "trig_ignore"
})

local TriggerInfo = Triggerbot:Section({
    Name = "Notes",
    Side = 2
})

TriggerInfo:Paragraph({
    Title = "How it works",
    Content = "Triggerbot fires when your crosshair rests on a valid target for longer than the delay."
})

local Esp = Visuals
local World = Visuals

local EspMain = Esp:Section({
    Name = "Players",
    Side = 1
})

EspMain:Toggle({
    Name = "Boxes",
    Default = true,
    Flag = "esp_boxes"
})

EspMain:Toggle({
    Name = "Names",
    Default = true,
    Flag = "esp_names"
})

EspMain:Toggle({
    Name = "Tracers",
    Default = false,
    Flag = "esp_tracers"
})

EspMain:Colorpicker({
    Name = "Box color",
    Default = Color3.fromRGB(255, 110, 120),
    Flag = "esp_box_color"
})

EspMain:Slider({
    Name = "Text size",
    Min = 8,
    Max = 24,
    Default = 14,
    Flag = "esp_text_size"
})

EspMain:Keybind({
    Name = "Toggle ESP",
    Default = Enum.KeyCode.X,
    Flag = "esp_toggle_key"
})

local EspExtra = Esp:Section({
    Name = "Extras",
    Side = 2
})

EspExtra:Dropdown({
    Name = "Box style",
    Items = {
        "Corner",
        "Full",
        "3D"
    },
    Default = "Corner",
    Flag = "esp_style"
})

EspExtra:Slider({
    Name = "Render distance",
    Min = 100,
    Max = 5000,
    Default = 1500,
    Suffix = "m",
    Flag = "esp_distance"
})

EspExtra:Label({
    Name = "Showing 0 players"
})

local EspHighlight = Esp:Section({
    Name = "Highlights",
    Side = 2
})

local Chams = EspHighlight:Toggle({
    Name = "Chams",
    Default = false,
    Flag = "esp_chams"
})

Chams:Colorpicker({
    Name = "Chams color",
    Default = Color3.fromRGB(179, 165, 255),
    Transparency = 0.35,
    Flag = "esp_chams_color"
})

Chams:Keybind({
    Default = Enum.KeyCode.C,
    Flag = "esp_chams_key"
})

local Glow = EspHighlight:Toggle({
    Name = "Glow",
    Default = false,
    Flag = "esp_glow"
})

Glow:Colorpicker({
    Name = "Glow color",
    Default = Color3.fromRGB(96, 170, 255),
    Flag = "esp_glow_color"
})

local WorldMain = World:Section({
    Name = "Environment",
    Side = 1
})

WorldMain:Toggle({
    Name = "Fullbright",
    Default = false,
    Flag = "world_fullbright"
})

WorldMain:Slider({
    Name = "Time of day",
    Min = 0,
    Max = 24,
    Default = 14,
    Suffix = "h",
    Flag = "world_time"
})

WorldMain:Colorpicker({
    Name = "Ambient",
    Default = Color3.fromRGB(120, 130, 160),
    Flag = "world_ambient"
})

WorldMain:Dropdown({
    Name = "Sky preset",
    Items = {
        "Default",
        "Clear",
        "Storm",
        "Night"
    },
    Default = "Default",
    Flag = "world_sky"
})

WorldMain:Textbox({
    Name = "Skybox id",
    Placeholder = "rbxassetid://",
    Finished = true,
    Flag = "world_skybox"
})

local WorldEffects = World:Section({
    Name = "Effects",
    Side = 2
})

WorldEffects:Toggle({
    Name = "No fog",
    Default = false,
    Flag = "world_nofog"
})

WorldEffects:Toggle({
    Name = "No shadows",
    Default = true,
    Flag = "world_noshadows"
})

WorldEffects:Slider({
    Name = "Field of view",
    Min = 70,
    Max = 120,
    Default = 90,
    Suffix = "°",
    Flag = "world_fov"
})

WorldEffects:Button({
    Name = "Reset lighting",
    Callback = function()
        Zolar:Notification({
            Name = "Lighting reset",
            Description = "All environment values were restored.",
            Icon = "rotate-ccw",
            Duration = 3
        })
    end
})

local Config = Settings

Config:ThemeConfig({ })

Window:Watermark({
    Name = "ZOLAR"
})

Zolar:Notification({
    Name = "ZOLAR loaded",
    Description = "Press G to toggle the menu.",
    Icon = "check",
    Duration = 6
})
