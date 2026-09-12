local Zolar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Da7mu/Ui-Collection/refs/heads/main/Zolar%20Ui/Library.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Zolar:Window({
    Name = "ZOLAR",
    Icon = "128056142918696",
    Accent = Color3.fromRGB(179, 165, 255)
})

-- ================================================================
-- COMBAT
-- Lenger Store aimbot logic: target selection + FOV + smooth aim.
-- ================================================================

local Combat = Window:Tab({
    Name = "Combat",
    Icon = "swords"
})

local Aimbot = Combat:SubTab({
    Name = "Aimbot",
    Icon = "crosshair"
})

local Triggerbot = Combat:SubTab({
    Name = "Triggerbot",
    Icon = "zap"
})

local AimState = {
    Enabled = false,
    WallCheck = false,
    FOV = 120,
    MaxDistance = 300,
    Smoothness = 85,
    Part = "Head",
    Mode = "PC",
    ShowFOV = true,
    FOVThickness = 1.5,
    FOVFilled = false,
    FOVColor = Color3.fromRGB(179, 165, 255),
    Target = nil
}

local AimMain = Aimbot:Section({
    Name = "Main",
    Side = 1
})

local AimEnabled = AimMain:Toggle({
    Name = "Auto Aim",
    Default = false,
    Flag = "lenger_aim_enabled",
    Callback = function(v)
        AimState.Enabled = v
        if not v then AimState.Target = nil end
    end
})

AimMain:Toggle({
    Name = "Wall Check",
    Default = false,
    Flag = "lenger_aim_wallcheck",
    Callback = function(v)
        AimState.WallCheck = v
    end
})

AimMain:Dropdown({
    Name = "Target Part",
    Items = {"Head", "Body"},
    Default = "Head",
    Flag = "lenger_aim_part",
    Callback = function(v)
        AimState.Part = v
        AimState.Target = nil
    end
})

AimMain:Dropdown({
    Name = "Aim Mode",
    Items = {"PC", "HP"},
    Default = "PC",
    Flag = "lenger_aim_mode",
    Callback = function(v)
        AimState.Mode = v
        AimState.Target = nil
    end
})

local AimTuning = Aimbot:Section({
    Name = "Tuning",
    Side = 2
})

AimTuning:Slider({
    Name = "FOV Radius",
    Min = 30,
    Max = 400,
    Default = 120,
    Suffix = "px",
    Flag = "lenger_aim_fov",
    Callback = function(v)
        AimState.FOV = v
    end
})

AimTuning:Slider({
    Name = "Max Jarak",
    Min = 50,
    Max = 1000,
    Default = 300,
    Suffix = " studs",
    Flag = "lenger_aim_distance",
    Callback = function(v)
        AimState.MaxDistance = v
    end
})

AimTuning:Slider({
    Name = "Smoothness",
    Min = 1,
    Max = 100,
    Default = 85,
    Suffix = "%",
    Flag = "lenger_aim_smooth",
    Callback = function(v)
        AimState.Smoothness = v
    end
})

AimTuning:Keybind({
    Name = "Aim Key",
    Default = Enum.KeyCode.E,
    Flag = "lenger_aim_key"
})

local AimVisual = Aimbot:Section({
    Name = "FOV",
    Side = 1
})

AimVisual:Toggle({
    Name = "Show FOV",
    Default = true,
    Flag = "lenger_show_fov",
    Callback = function(v)
        AimState.ShowFOV = v
    end
})

AimVisual:Slider({
    Name = "FOV Thickness",
    Min = 1,
    Max = 6,
    Default = 2,
    Flag = "lenger_fov_thickness",
    Callback = function(v)
        AimState.FOVThickness = v
    end
})

AimVisual:Toggle({
    Name = "Filled",
    Default = false,
    Flag = "lenger_fov_filled",
    Callback = function(v)
        AimState.FOVFilled = v
    end
})

AimVisual:Colorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(179, 165, 255),
    Transparency = 0.2,
    Flag = "lenger_fov_color",
    Callback = function(v)
        AimState.FOVColor = v
    end
})

-- Keep the original Triggerbot page available.
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

-- ================================================================
-- VISUALS
-- Based on the Lenger Store ESP render system.
-- ================================================================

local Visuals = Window:Tab({
    Name = "Visuals",
    Icon = "eye"
})

local Esp = Visuals:SubTab({
    Name = "ESP",
    Icon = "scan-eye"
})

local World = Visuals:SubTab({
    Name = "World",
    Icon = "globe"
})

local ESPState = {
    Box = false,
    Name = true,
    Distance = true,
    HPBar = true,
    Weapon = true,
    Skeleton = false,
    Masak = true,
    Tracer = false,
    BoxMode = "FULL",
    MaxDistance = 500,
    Chams = false,
    Glow = false
}

local EspMain = Esp:Section({
    Name = "Players",
    Side = 1
})

EspMain:Toggle({
    Name = "Boxes",
    Default = false,
    Flag = "lenger_esp_box",
    Callback = function(v) ESPState.Box = v end
})

EspMain:Toggle({
    Name = "Names",
    Default = true,
    Flag = "lenger_esp_name",
    Callback = function(v) ESPState.Name = v end
})

EspMain:Toggle({
    Name = "Distance",
    Default = true,
    Flag = "lenger_esp_distance",
    Callback = function(v) ESPState.Distance = v end
})

EspMain:Toggle({
    Name = "HP Bar",
    Default = true,
    Flag = "lenger_esp_hp",
    Callback = function(v) ESPState.HPBar = v end
})

EspMain:Toggle({
    Name = "GUN",
    Default = true,
    Flag = "lenger_esp_weapon",
    Callback = function(v) ESPState.Weapon = v end
})

EspMain:Toggle({
    Name = "Skeleton",
    Default = false,
    Flag = "lenger_esp_skeleton",
    Callback = function(v) ESPState.Skeleton = v end
})

EspMain:Toggle({
    Name = "Masak",
    Default = true,
    Flag = "lenger_esp_masak",
    Callback = function(v) ESPState.Masak = v end
})

EspMain:Toggle({
    Name = "Tracers",
    Default = false,
    Flag = "lenger_esp_tracer",
    Callback = function(v) ESPState.Tracer = v end
})

local EspExtra = Esp:Section({
    Name = "Extras",
    Side = 2
})

EspExtra:Dropdown({
    Name = "Box Style",
    Items = {"FULL", "CORNER"},
    Default = "FULL",
    Flag = "lenger_esp_style",
    Callback = function(v) ESPState.BoxMode = v end
})

EspExtra:Slider({
    Name = "Render Distance",
    Min = 50,
    Max = 5000,
    Default = 500,
    Suffix = " studs",
    Flag = "lenger_esp_maxdist",
    Callback = function(v) ESPState.MaxDistance = v end
})

local EspHighlight = Esp:Section({
    Name = "Highlights",
    Side = 2
})

EspHighlight:Toggle({
    Name = "Chams",
    Default = false,
    Flag = "lenger_chams",
    Callback = function(v) ESPState.Chams = v end
})

EspHighlight:Toggle({
    Name = "Glow",
    Default = false,
    Flag = "lenger_glow",
    Callback = function(v) ESPState.Glow = v end
})

local WorldMain = World:Section({
    Name = "Environment",
    Side = 1
})

WorldMain:Toggle({
    Name = "Fullbright",
    Default = false,
    Flag = "world_fullbright",
    Callback = function(v)
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end
    end
})

WorldMain:Slider({
    Name = "Time of day",
    Min = 0,
    Max = 24,
    Default = 14,
    Suffix = "h",
    Flag = "world_time",
    Callback = function(v)
        Lighting.ClockTime = v
    end
})

WorldMain:Toggle({
    Name = "No fog",
    Default = false,
    Flag = "world_nofog",
    Callback = function(v)
        if v then
            Lighting.FogEnd = 100000
        end
    end
})

WorldMain:Toggle({
    Name = "No shadows",
    Default = true,
    Flag = "world_noshadows",
    Callback = function(v)
        Lighting.GlobalShadows = not v
    end
})

-- ================================================================
-- TP
-- Only the "Others" locations from the Lenger Store file.
-- ================================================================

local TP = Window:Tab({
    Name = "TP",
    Icon = "map-pin"
})

local OthersTP = TP:SubTab({
    Name = "OthersTP",
    Icon = "navigation"
})

local Others = {
    {name="Bag Store", x=992.77, y=3.78, z=422.53},
    {name="Bank", x=-48.64, y=3.73, z=-320.46},
    {name="Binary Store", x=-281.06, y=3.74, z=251.23},
    {name="Boutique Store", x=992.60, y=3.78, z=453.07},
    {name="Box Job", x=-578.48, y=3.53, z=-74.82},
    {name="Buy Marshmellow", x=510.38, y=3.59, z=603.50},
    {name="Cap Store", x=-270.15, y=3.88, z=-331.36},
    {name="Casino", x=1152.53, y=20.32, z=-26.31},
    {name="Chips Cook", x=-487.11, y=3.86, z=-454.16},
    {name="Chips Store", x=-773.72, y=3.66, z=-187.54},
    {name="Chips Tukar", x=-34.91, y=4.56, z=-24.15},
    {name="Clothes Store 1", x=-202.62, y=3.48, z=-58.82},
    {name="Clothes Store 2", x=-747.62, y=3.76, z=571.96},
    {name="Dealer", x=730.24, y=3.70, z=449.47},
    {name="Deli Grocery", x=-364.30, y=3.61, z=-325.87},
    {name="Fake Card", x=216.28, y=3.73, z=-331.79},
    {name="Food Corp", x=365.69, y=3.48, z=-349.23},
    {name="Glasses Store", x=-697.77, y=4.21, z=-336.85},
    {name="Gun Sell", x=75.09, y=3.76, z=26.53},
    {name="Gun Store 1", x=215.77, y=3.73, z=-179.89},
    {name="Gun Store 2", x=-468.37, y=3.86, z=349.56},
    {name="Gun Tier", x=1114.80, y=3.78, z=167.36},
    {name="Haircut", x=52.73, y=3.73, z=-71.39},
    {name="Jewerely Store", x=-75.48, y=4.29, z=-176.28},
    {name="Shoes Store", x=524.48, y=3.75, z=-196.93},
    {name="Store 1", x=904.05, y=3.53, z=-87.44},
    {name="Store 2", x=530.13, y=3.46, z=430.07},
    {name="Tattoo Shop", x=951.72, y=3.83, z=-72.93},
    {name="The Deli 2", x=-662.23, y=3.98, z=159.33}
}

OthersTP:Paragraph({
    Title = "OthersTP",
    Content = "Teleport destinations from the Lenger Store Others category."
})

local TPNames = {}
for _, loc in ipairs(Others) do
    table.insert(TPNames, loc.name)
end

OthersTP:Dropdown({
    Name = "Location",
    Items = TPNames,
    Default = TPNames[1],
    Flag = "others_tp_location",
    Callback = function(v)
        for _, loc in ipairs(Others) do
            if loc.name == v then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(loc.x, loc.y + 3, loc.z)
                end
                break
            end
        end
    end
})

OthersTP:Button({
    Name = "Teleport",
    Callback = function()
        local selected = TPNames[1]
        -- Read the selected flag when available; the dropdown callback also teleports.
        local ok, flags = pcall(function()
            return Zolar.Flags
        end)
        if ok and flags and flags.others_tp_location then
            selected = flags.others_tp_location
        end

        for _, loc in ipairs(Others) do
            if loc.name == selected then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(loc.x, loc.y + 3, loc.z)
                    Zolar:Notification({
                        Name = "Teleport",
                        Description = "Arrived: " .. loc.name,
                        Icon = "map-pin",
                        Duration = 2
                    })
                end
                break
            end
        end
    end
})

-- ================================================================
-- SETTINGS
-- ================================================================

local Settings = Window:Tab({
    Name = "Settings",
    Icon = "settings"
})

local Config = Settings:SubTab({
    Name = "Config",
    Icon = "save"
})

Config:ThemeConfig({})

Window:Watermark({
    Name = "ZOLAR"
})

-- ================================================================
-- RUNTIME: AIMBOT + FOV + ESP
-- ================================================================

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Visible = false
FovCircle.Color = AimState.FOVColor

local ESP = {}

local SKEL_BONES = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},
    {"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},
    {"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},
    {"RightLowerLeg","RightFoot"},
    {"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},
    {"RightUpperLeg","LeftUpperLeg"}
}

local function newLine(thickness)
    local d = Drawing.new("Line")
    d.Thickness = thickness
    d.Visible = false
    return d
end

local function newText(size)
    local d = Drawing.new("Text")
    d.Size = size
    d.Outline = true
    d.OutlineColor = Color3.fromRGB(0, 0, 0)
    d.Center = true
    d.Visible = false
    return d
end

local function createESP(player)
    if player == LocalPlayer or ESP[player] then return end

    local corners = {}
    for i = 1, 8 do
        corners[i] = newLine(2)
    end

    local skeleton = {}
    for i = 1, #SKEL_BONES do
        skeleton[i] = newLine(1.2)
    end

    ESP[player] = {
        box = Drawing.new("Square"),
        hpbg = Drawing.new("Square"),
        hpbar = Drawing.new("Square"),
        hpnum = newText(11),
        name = newText(13),
        dist = newText(11),
        weapon = newText(11),
        tracer = newLine(1.2),
        masak = newText(13),
        corners = corners,
        skeleton = skeleton
    }

    ESP[player].box.Thickness = 1.5
    ESP[player].box.Filled = false
    ESP[player].hpbg.Filled = false
    ESP[player].hpbar.Filled = true
end

local function hideESP(e)
    e.box.Visible = false
    e.hpbg.Visible = false
    e.hpbar.Visible = false
    e.hpnum.Visible = false
    e.name.Visible = false
    e.dist.Visible = false
    e.weapon.Visible = false
    e.tracer.Visible = false
    e.masak.Visible = false

    for _, x in ipairs(e.corners) do
        x.Visible = false
    end
    for _, x in ipairs(e.skeleton) do
        x.Visible = false
    end
end

local function removeESP(player)
    local e = ESP[player]
    if not e then return end

    for _, x in pairs(e) do
        if type(x) == "table" then
            for _, d in ipairs(x) do
                pcall(function() d:Remove() end)
            end
        else
            pcall(function() x:Remove() end)
        end
    end

    ESP[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

local function getTargetPart(character)
    if AimState.Part == "Body" then
        return character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    end
    return character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

local function isVisibleTarget(character, targetPart)
    if not AimState.WallCheck then
        return true
    end

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

    local hit = workspace:Raycast(origin, direction, params)
    return not hit or hit.Instance:IsDescendantOf(character)
end

local function findAimTarget(fovCenter)
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    local bestScreenDist = math.huge
    local bestPart = nil

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local character = p.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPart = getTargetPart(character)

            if humanoid and humanoid.Health > 0 and targetPart then
                local worldDistance = (targetPart.Position - localRoot.Position).Magnitude

                if worldDistance <= AimState.MaxDistance and isVisibleTarget(character, targetPart) then
                    local screen, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                    if onScreen and screen.Z > 0 then
                        local screenDistance = (Vector2.new(screen.X, screen.Y) - fovCenter).Magnitude

                        if screenDistance <= AimState.FOV and screenDistance < bestScreenDist then
                            bestScreenDist = screenDistance
                            bestPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return bestPart
end

local RMB = false
local AimKeyDown = false

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RMB = true
    elseif input.KeyCode == Enum.KeyCode.E then
        AimKeyDown = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RMB = false
    elseif input.KeyCode == Enum.KeyCode.E then
        AimKeyDown = false
    end
end)

local function updateESP(player, e)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or not root then
        hideESP(e)
        return
    end

    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if localRoot and (root.Position - localRoot.Position).Magnitude > ESPState.MaxDistance then
        hideESP(e)
        return
    end

    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen or rootPos.Z <= 0 then
        hideESP(e)
        return
    end

    local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
    local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
    local height = math.abs(bottom.Y - top.Y)
    local width = height * 0.6
    local bx = rootPos.X - width / 2
    local by = math.min(top.Y, bottom.Y)

    local dead = humanoid.Health <= 0
    local white = dead and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(255, 255, 255)

    if ESPState.Box then
        if ESPState.BoxMode == "FULL" then
            e.box.Color = white
            e.box.Size = Vector2.new(width, height)
            e.box.Position = Vector2.new(bx, by)
            e.box.Visible = true
            for _, c in ipairs(e.corners) do c.Visible = false end
        else
            e.box.Visible = false
            local len = math.min(width, height) * 0.25
            local c = e.corners

            c[1].From = Vector2.new(bx, by)
            c[1].To = Vector2.new(bx + len, by)
            c[2].From = Vector2.new(bx, by)
            c[2].To = Vector2.new(bx, by + len)
            c[3].From = Vector2.new(bx + width, by)
            c[3].To = Vector2.new(bx + width - len, by)
            c[4].From = Vector2.new(bx + width, by)
            c[4].To = Vector2.new(bx + width, by + len)
            c[5].From = Vector2.new(bx, by + height)
            c[5].To = Vector2.new(bx + len, by + height)
            c[6].From = Vector2.new(bx, by + height)
            c[6].To = Vector2.new(bx, by + height - len)
            c[7].From = Vector2.new(bx + width, by + height)
            c[7].To = Vector2.new(bx + width - len, by + height)
            c[8].From = Vector2.new(bx + width, by + height)
            c[8].To = Vector2.new(bx + width, by + height - len)

            for _, line in ipairs(c) do
                line.Color = white
                line.Visible = true
            end
        end
    else
        e.box.Visible = false
        for _, c in ipairs(e.corners) do c.Visible = false end
    end

    local hp = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
    if ESPState.HPBar then
        local barX = bx - 7
        e.hpbg.Size = Vector2.new(4, height)
        e.hpbg.Position = Vector2.new(barX, by)
        e.hpbg.Color = Color3.fromRGB(0, 0, 0)
        e.hpbg.Visible = true

        e.hpbar.Size = Vector2.new(4, math.max(1, height * hp))
        e.hpbar.Position = Vector2.new(barX, by + height - math.max(1, height * hp))
        e.hpbar.Color = hp > 0.5 and Color3.fromRGB(0, 220, 0)
            or hp > 0.2 and Color3.fromRGB(255, 165, 0)
            or Color3.fromRGB(255, 0, 0)
        e.hpbar.Visible = true

        e.hpnum.Text = math.floor(humanoid.Health) .. "HP"
        e.hpnum.Position = Vector2.new(barX + 2, by - 1)
        e.hpnum.Center = false
        e.hpnum.Color = e.hpbar.Color
        e.hpnum.Visible = true
    else
        e.hpbg.Visible = false
        e.hpbar.Visible = false
        e.hpnum.Visible = false
    end

    local distance = localRoot and math.floor((root.Position - localRoot.Position).Magnitude) or 0
    local textSize = math.clamp(math.floor(14 - distance / 40), 8, 14)

    if ESPState.Name then
        e.name.Text = (player.DisplayName or player.Name) .. "(@" .. player.Name .. ")"
        e.name.Size = textSize
        e.name.Color = white
        e.name.Position = Vector2.new(rootPos.X, by - 14)
        e.name.Visible = true
    else
        e.name.Visible = false
    end

    local nextY = by + height + 3

    if ESPState.Distance then
        e.dist.Text = distance .. "m"
        e.dist.Size = textSize
        e.dist.Color = white
        e.dist.Position = Vector2.new(rootPos.X, nextY)
        e.dist.Visible = true
        nextY = nextY + 13
    else
        e.dist.Visible = false
    end

    if ESPState.Weapon then
        local toolName
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then
                toolName = item.Name
                break
            end
        end

        if toolName then
            e.weapon.Text = toolName
            e.weapon.Size = textSize
            e.weapon.Color = Color3.fromRGB(255, 220, 80)
            e.weapon.Position = Vector2.new(rootPos.X, nextY)
            e.weapon.Visible = true
        else
            e.weapon.Visible = false
        end
    else
        e.weapon.Visible = false
    end

    if ESPState.Masak then
        -- Lenger's MASAK label is driven by its cooking/material cache.
        -- This standalone merge does not have that game's private cache,
        -- so the label stays hidden rather than guessing.
        e.masak.Visible = false
    else
        e.masak.Visible = false
    end

    if ESPState.Tracer then
        local vp = Camera.ViewportSize
        e.tracer.From = Vector2.new(vp.X / 2, vp.Y)
        e.tracer.To = Vector2.new(rootPos.X, by + height)
        e.tracer.Color = white
        e.tracer.Visible = true
    else
        e.tracer.Visible = false
    end

    if ESPState.Skeleton then
        for i, bone in ipairs(SKEL_BONES) do
            local a = character:FindFirstChild(bone[1])
            local b = character:FindFirstChild(bone[2])
            local line = e.skeleton[i]

            if a and b then
                local p1, v1 = Camera:WorldToViewportPoint(a.Position)
                local p2, v2 = Camera:WorldToViewportPoint(b.Position)

                if v1 and v2 and p1.Z > 0 and p2.Z > 0 then
                    line.From = Vector2.new(p1.X, p1.Y)
                    line.To = Vector2.new(p2.X, p2.Y)
                    line.Color = white
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    else
        for _, line in ipairs(e.skeleton) do
            line.Visible = false
        end
    end
end

local Running = true

local RenderConnection = RunService.RenderStepped:Connect(function()
    if not Running then return end

    Camera = workspace.CurrentCamera or Camera
    local viewport = Camera.ViewportSize
    local mousePos = UIS:GetMouseLocation()

    local fovCenter
    if AimState.Mode == "HP" then
        fovCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
    else
        fovCenter = mousePos
    end

    FovCircle.Position = fovCenter
    FovCircle.Radius = AimState.FOV
    FovCircle.Thickness = AimState.FOVThickness
    FovCircle.Filled = AimState.FOVFilled
    FovCircle.Color = AimState.FOVColor
    FovCircle.Visible = AimState.Enabled and AimState.ShowFOV

    local shouldAim = AimState.Enabled and (AimState.Mode == "HP" or RMB or AimKeyDown)

    if shouldAim then
        if not AimState.Target or not AimState.Target.Parent then
            AimState.Target = findAimTarget(fovCenter)
        end

        local target = AimState.Target

        if target then
            local screen, onScreen = Camera:WorldToViewportPoint(target.Position)
            if not onScreen or screen.Z <= 0 then
                AimState.Target = nil
            else
                local screenDistance =
                    (Vector2.new(screen.X, screen.Y) - fovCenter).Magnitude

                if screenDistance > AimState.FOV then
                    AimState.Target = nil
                else
                    local smooth = math.clamp(AimState.Smoothness / 100, 0.01, 0.99)
                    local targetCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
                end
            end
        end
    elseif AimState.Mode == "PC" then
        AimState.Target = nil
    end

    for player, e in pairs(ESP) do
        updateESP(player, e)
    end
end)

-- Cleanup if the window is closed through the library.
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G and not UIS:GetFocusedTextBox() then
        -- Zolar handles the actual menu toggle; this is intentionally empty.
    end
end)

Zolar:Notification({
    Name = "ZOLAR + LENGER",
    Description = "Aimbot, FOV, Visual ESP and OthersTP loaded.",
    Icon = "check",
    Duration = 5
})
