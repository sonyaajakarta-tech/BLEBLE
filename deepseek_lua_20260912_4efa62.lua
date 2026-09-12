-- ================================================================
-- DARK HUB PREMIUM V3.0 — ARCANE UI EDITION
-- ================================================================

local Arcane = loadstring(game:HttpGet("https://raw.githubusercontent.com/Da7mu/Ui-Collection/refs/heads/main/Arcane%20Ui/Library.lua"))()

local TweenService = game:GetService("TweenService")
local CoreGui     = game:GetService("CoreGui")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Players     = game:GetService("Players")
local Http        = game:GetService("HttpService")
local RS          = game:GetService("ReplicatedStorage")
local plr         = Players.LocalPlayer

-- Auto Buy Settings (global)
_G.HNDRIXX_AUTOBUY = { Enabled = false, Amount = 10, Mode = "PACK" }

-- ================================================================
-- ANTI-AFK
-- ================================================================
do
    local VU = game:GetService("VirtualUser")
    plr.Idled:Connect(function()
        VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

-- ================================================================
-- THANK YOU POPUP
-- ================================================================
do
    local PopGui = Instance.new("ScreenGui")
    PopGui.Name = "DARKHUB_Popup"
    PopGui.ResetOnSpawn = false
    PopGui.Parent = CoreGui

    local Card = Instance.new("Frame", PopGui)
    Card.Size = UDim2.new(0, 320, 0, 64)
    Card.AnchorPoint = Vector2.new(0.5, 0)
    Card.Position = UDim2.new(0.5, 0, 0, -80)
    Card.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
    local cs = Instance.new("UIStroke", Card)
    cs.Color = Color3.fromRGB(45, 62, 110); cs.Thickness = 1

    local accent = Instance.new("Frame", Card)
    accent.Size = UDim2.new(0, 3, 0, 34)
    accent.Position = UDim2.new(0, 0, 0.5, -17)
    accent.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local badge = Instance.new("Frame", Card)
    badge.Size = UDim2.new(0, 50, 0, 18)
    badge.Position = UDim2.new(0, 14, 0, 11)
    badge.BackgroundColor3 = Color3.fromRGB(20, 28, 48)
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
    local bdgLbl = Instance.new("TextLabel", badge)
    bdgLbl.Size = UDim2.new(1,0,1,0); bdgLbl.BackgroundTransparency = 1
    bdgLbl.Text = "V3.0"; bdgLbl.TextColor3 = Color3.fromRGB(130, 175, 255)
    bdgLbl.Font = Enum.Font.GothamBlack; bdgLbl.TextSize = 11

    local Ttl = Instance.new("TextLabel", Card)
    Ttl.Size = UDim2.new(1,-76,0,20); Ttl.Position = UDim2.new(0,72,0,9)
    Ttl.BackgroundTransparency = 1; Ttl.Text = "DARK HUB"
    Ttl.TextColor3 = Color3.fromRGB(255,255,255)
    Ttl.Font = Enum.Font.GothamBlack; Ttl.TextSize = 13
    Ttl.TextXAlignment = Enum.TextXAlignment.Left

    local Msg = Instance.new("TextLabel", Card)
    Msg.Size = UDim2.new(1,-76,0,16); Msg.Position = UDim2.new(0,72,0,32)
    Msg.BackgroundTransparency = 1; Msg.Text = "TikTok · @darkhub"
    Msg.TextColor3 = Color3.fromRGB(130, 150, 190)
    Msg.Font = Enum.Font.Gotham; Msg.TextSize = 12
    Msg.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5,0,0,18)}):Play()
    task.delay(3.5, function()
        local out = TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5,0,0,-80)})
        out:Play(); out.Completed:Wait(); PopGui:Destroy()
    end)
end

-- ================================================================
-- STATE
-- ================================================================
local Flags = {
    BoxESP=false, Tracer=false,
    ESPName=true, ESPDist=true, ESPHPBar=true, ESPWeapon=true, ESPSkeleton=false, ESPMasak=true,
    TPNoClip=false, AimLock=false, WallCheck=false,
    InvScan=false, InstantInteract=false,
    InfStamina=false, HybridSpeed=false, AuraKill=false,
}
local AimFOV_Radius    = 120
local SilentFOV_Radius = 120
local AimMax_Dist      = 300
local TracerMaxDist    = 300
local ESPMaxDist       = 500
local AimSmooth        = 0.85
local AimTarget        = nil
local AimPart          = "Head"
local AimMode          = "PC"
local BoxESPMode       = "FULL"
local AimWhitelist     = {}
local BlinkMode        = "PC"
local SilentAim        = false
local SilentAimWallbang= false
local ShowAimFOV       = true
local ShowSilentFOV    = true
local SilentMode       = "PC"
local SilentPart       = "Head"
local Running          = true
local _overlayActive   = false

-- TP state
local tpBusy=false; local tpCancelled=false; local tpActive=false
local tpToPos
local _htpo={fn=function()end}
local function hideTPOverlay() _htpo.fn() end

-- ================================================================
-- OVERLAY GUI (HP panel, TP overlay, confirm modal, copy toast)
-- ================================================================
local OvGui = Instance.new("ScreenGui")
OvGui.Name = "DARKHUB_Overlays"
OvGui.ResetOnSpawn = false
OvGui.DisplayOrder = 25
OvGui.Parent = CoreGui

-- ================================================================
-- SAVE / LOAD SETTINGS
-- ================================================================
local SAVEFILE = "hndrixx_settings.json"
local function saveSettings()
    pcall(function()
        writefile(SAVEFILE, Http:JSONEncode({
            Flags = {
                BoxESP=Flags.BoxESP, Tracer=Flags.Tracer, TPNoClip=Flags.TPNoClip,
                AimLock=Flags.AimLock, WallCheck=Flags.WallCheck, InvScan=Flags.InvScan,
                InstantInteract=Flags.InstantInteract, InfStamina=Flags.InfStamina, AuraKill=Flags.AuraKill,
            },
            AimFOV_Radius = AimFOV_Radius,
            AimMax_Dist   = AimMax_Dist,
        }))
    end)
end
local function loadSettings()
    pcall(function()
        if isfile and isfile(SAVEFILE) then
            local d = Http:JSONDecode(readfile(SAVEFILE))
            if d.Flags then for k,v in pairs(d.Flags) do if Flags[k]~=nil then Flags[k]=v end end end
            if d.AimFOV_Radius then AimFOV_Radius=d.AimFOV_Radius end
            if d.AimMax_Dist then AimMax_Dist=d.AimMax_Dist end
        end
    end)
end

-- ================================================================
-- VEHICLE TP HELPER
-- ================================================================
local function doVehicleTP(targetCFrame)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat then return false end
    local vehicle = seat:FindFirstAncestorOfClass("Model")
    if not vehicle then return false end
    local vRoot = vehicle.PrimaryPart or seat
    vRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
    vRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
    vehicle:PivotTo(targetCFrame * CFrame.new(0,3,0))
    task.wait(0.1)
    vRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
    vRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
    return true
end

-- ================================================================
-- ESP DRAWINGS
-- ================================================================
local ESP = {}
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness=1.5; FovCircle.Color=Color3.fromRGB(90,160,255)
FovCircle.Filled=false; FovCircle.NumSides=64; FovCircle.Visible=false

local SilentFovCircle = Drawing.new("Circle")
SilentFovCircle.Thickness=1.5; SilentFovCircle.Color=Color3.fromRGB(90,160,255)
SilentFovCircle.Filled=false; SilentFovCircle.NumSides=64; SilentFovCircle.Visible=false

local SilentLine = Drawing.new("Line")
SilentLine.Thickness=1.5; SilentLine.Color=Color3.fromRGB(90,160,255)
SilentLine.Transparency=1; SilentLine.Visible=false

local function removeESP(p)
    if not ESP[p] then return end
    local _e=ESP[p]
    if _e.corners then for _,c in ipairs(_e.corners) do pcall(function() c:Remove() end) end end
    if _e.skeleton then for _,s in ipairs(_e.skeleton) do pcall(function() s:Remove() end) end end
    for k,d in pairs(_e) do if k~="corners" and k~="skeleton" then pcall(function() d:Remove() end) end end
    ESP[p]=nil
end
local function _mkLine(t,c) local d=Drawing.new("Line"); d.Thickness=t; d.Color=c; d.Visible=false; return d end
local function _mkText(s,c)
    local d=Drawing.new("Text"); d.Size=s; d.Color=c; d.Outline=true
    d.OutlineColor=Color3.fromRGB(0,0,0); d.Center=true; d.Font=Drawing.Fonts.Plex; d.Visible=false
    return d
end
local function _hideESP(e)
    e.box.Visible=false; e.hpbg.Visible=false; e.hpbar.Visible=false
    e.hpnum.Visible=false; e.dispname.Visible=false; e.username.Visible=false
    e.dist.Visible=false; e.weapon.Visible=false; e.masak.Visible=false; e.tracer.Visible=false
    for _,c in ipairs(e.corners) do c.Visible=false end
    for _,s in ipairs(e.skeleton) do s.Visible=false end
end
local function createESP(p)
    if ESP[p] or p == plr then return end
    local _c={} for i=1,8 do
        local cl=Drawing.new("Line"); cl.Thickness=2; cl.Color=Color3.fromRGB(90,160,255); cl.Visible=false; _c[i]=cl
    end
    local _sk={} for i=1,15 do
        local sl=Drawing.new("Line"); sl.Thickness=1.2; sl.Color=Color3.fromRGB(90,160,255); sl.Visible=false; _sk[i]=sl
    end
    local e = {
        box=Drawing.new("Square"), hpbg=Drawing.new("Square"), hpbar=Drawing.new("Square"),
        hpnum=_mkText(10,Color3.fromRGB(255,255,255)),
        dispname=_mkText(13,Color3.fromRGB(255,255,255)),
        username=_mkText(11,Color3.fromRGB(180,200,220)),
        dist=_mkText(11,Color3.fromRGB(160,180,210)),
        weapon=_mkText(11,Color3.fromRGB(90,160,255)),
        tracer=_mkLine(1.2, Color3.fromRGB(90,160,255)),
        masak=_mkText(13, Color3.fromRGB(0,255,120)),
        corners=_c, skeleton=_sk,
    }
    e.box.Thickness=1.5; e.box.Filled=false
    e.hpbg.Thickness=1; e.hpbg.Filled=true; e.hpbg.Color=Color3.fromRGB(0,0,0)
    e.hpbar.Thickness=1; e.hpbar.Filled=true
    ESP[p]=e
end

-- ================================================================
-- HP BLINK PANEL (custom overlay)
-- ================================================================
local HPPanel = Instance.new("Frame", OvGui)
HPPanel.Name = "HPBlinkPanel"
HPPanel.Size = UDim2.new(0,58,0,58)
HPPanel.Position = UDim2.new(0,16,0.5,-29)
HPPanel.BackgroundColor3 = Color3.fromRGB(14,18,30)
HPPanel.Active = true; HPPanel.Visible = false; HPPanel.ZIndex = 100
Instance.new("UICorner", HPPanel).CornerRadius = UDim.new(0,14)
local hpStr = Instance.new("UIStroke", HPPanel)
hpStr.Color = Color3.fromRGB(90,160,255); hpStr.Thickness = 1.5

local HPTBtn = Instance.new("TextButton", HPPanel)
HPTBtn.Size = UDim2.new(1,-10,1,-10); HPTBtn.Position = UDim2.new(0,5,0,5)
HPTBtn.BackgroundColor3 = Color3.fromRGB(19,24,40); HPTBtn.Text = "T"
HPTBtn.TextColor3 = Color3.fromRGB(255,255,255)
HPTBtn.Font = Enum.Font.GothamBlack; HPTBtn.TextSize = 22; HPTBtn.AutoButtonColor = false
Instance.new("UICorner", HPTBtn).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke", HPTBtn).Color = Color3.fromRGB(38,48,78)

local HPTLabel = Instance.new("TextLabel", HPPanel)
HPTLabel.Size = UDim2.new(1,0,0,12); HPTLabel.Position = UDim2.new(0,0,1,-13)
HPTLabel.BackgroundTransparency = 1; HPTLabel.Text = "BLINK"
HPTLabel.TextColor3 = Color3.fromRGB(90,160,255)
HPTLabel.Font = Enum.Font.GothamBlack; HPTLabel.TextSize = 9; HPTLabel.ZIndex = 102

do
    local dragging, dragStart, startPos = false, nil, nil
    HPPanel.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = inp.Position; startPos = HPPanel.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            HPPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                          startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

HPTBtn.MouseButton1Click:Connect(function()
    if not Flags.TPNoClip then return end
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        HPTBtn.BackgroundColor3 = Color3.fromRGB(0,80,140)
        TweenService:Create(HPTBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(19,24,40)}):Play()
        TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Linear),
            {CFrame = hrp.CFrame * CFrame.new(0,0,-6)}):Play()
    end
end)

local hpPanelLocked = false
local function updateHPPanel()
    HPPanel.Visible = (BlinkMode == "HP" and Flags.TPNoClip)
end

-- ================================================================
-- TP OVERLAY
-- ================================================================
local TPOverlay = Instance.new("ScreenGui")
TPOverlay.Name = "DARKHUB_TPOverlay"
TPOverlay.ResetOnSpawn = false
TPOverlay.DisplayOrder = 5
TPOverlay.IgnoreGuiInset = true
TPOverlay.Enabled = false
TPOverlay.Parent = CoreGui

local OvBG = Instance.new("Frame", TPOverlay)
OvBG.Size = UDim2.new(1,0,1,0)
OvBG.BackgroundColor3 = Color3.fromRGB(6,10,20)
OvBG.BackgroundTransparency = 1
OvBG.BorderSizePixel = 0; OvBG.ZIndex = 9999

local ovCenter = Instance.new("Frame", OvBG)
ovCenter.Size = UDim2.new(0,320,0,130)
ovCenter.AnchorPoint = Vector2.new(0.5,0.5); ovCenter.Position = UDim2.new(0.5,0,0.5,0)
ovCenter.BackgroundTransparency = 1; ovCenter.ZIndex = 10000

local logoFrame = Instance.new("Frame", ovCenter)
logoFrame.Size = UDim2.new(0,0,0,72); logoFrame.AutomaticSize = Enum.AutomaticSize.X
logoFrame.AnchorPoint = Vector2.new(0.5,0); logoFrame.Position = UDim2.new(0.5,0,0,0)
logoFrame.BackgroundTransparency = 1; logoFrame.ZIndex = 10001
local _lay = Instance.new("UIListLayout", logoFrame)
_lay.FillDirection = Enum.FillDirection.Horizontal
_lay.SortOrder = Enum.SortOrder.LayoutOrder
_lay.VerticalAlignment = Enum.VerticalAlignment.Center

local ovTG = Instance.new("TextLabel", logoFrame)
ovTG.Size = UDim2.new(0,0,1,0); ovTG.AutomaticSize = Enum.AutomaticSize.X
ovTG.BackgroundTransparency = 1; ovTG.Text = "DARK"
ovTG.TextColor3 = Color3.fromRGB(90,160,255)
ovTG.Font = Enum.Font.GothamBlack; ovTG.TextSize = 64; ovTG.ZIndex = 10001

local ovTW = Instance.new("TextLabel", logoFrame)
ovTW.Size = UDim2.new(0,0,1,0); ovTW.AutomaticSize = Enum.AutomaticSize.X
ovTW.BackgroundTransparency = 1; ovTW.Text = "HUB"
ovTW.TextColor3 = Color3.fromRGB(255,255,255)
ovTW.Font = Enum.Font.GothamBlack; ovTW.TextSize = 64; ovTW.ZIndex = 10002
local ovWS = Instance.new("UIStroke", ovTW)
ovWS.Color = Color3.fromRGB(90,160,255); ovWS.Thickness = 2.5

local ovLabel = Instance.new("TextLabel", ovCenter)
ovLabel.Size = UDim2.new(1,0,0,20); ovLabel.Position = UDim2.new(0,0,0,80)
ovLabel.BackgroundTransparency = 1; ovLabel.Text = "Teleporting, please wait"
ovLabel.TextColor3 = Color3.fromRGB(160,180,210)
ovLabel.Font = Enum.Font.Gotham; ovLabel.TextSize = 13
ovLabel.TextXAlignment = Enum.TextXAlignment.Center; ovLabel.ZIndex = 10001

local ovAnimConn = nil; local _panelWasVisible = false

local function showTPOverlay()
    _panelWasVisible = true
    _overlayActive = true
    FovCircle.Visible = false
    for _, e in pairs(ESP) do _hideESP(e) end
    OvBG.BackgroundTransparency = 0
    TPOverlay.Enabled = true
end
_htpo.fn = function()
    if ovAnimConn then ovAnimConn:Disconnect(); ovAnimConn = nil end
    TPOverlay.Enabled = false
    OvBG.BackgroundTransparency = 1
    _overlayActive = false
    _panelWasVisible = false
end

-- ================================================================
-- CONFIRM MODAL
-- ================================================================
local ConfirmModal = Instance.new("Frame", OvGui)
ConfirmModal.Size = UDim2.new(1,0,1,0)
ConfirmModal.BackgroundColor3 = Color3.fromRGB(0,0,0)
ConfirmModal.BackgroundTransparency = 0.5
ConfirmModal.ZIndex = 200; ConfirmModal.Visible = false

local ConfirmCard = Instance.new("Frame", ConfirmModal)
ConfirmCard.Size = UDim2.new(0,320,0,120)
ConfirmCard.AnchorPoint = Vector2.new(0.5,0.5); ConfirmCard.Position = UDim2.new(0.5,0,0.5,0)
ConfirmCard.BackgroundColor3 = Color3.fromRGB(14,18,32); ConfirmCard.ZIndex = 201
Instance.new("UICorner", ConfirmCard).CornerRadius = UDim.new(0,12)
local cms = Instance.new("UIStroke", ConfirmCard)
cms.Color = Color3.fromRGB(90,160,255); cms.Thickness = 1

local ConfirmTitle = Instance.new("TextLabel", ConfirmCard)
ConfirmTitle.Size = UDim2.new(1,-12,0,22); ConfirmTitle.Position = UDim2.new(0,6,0,8)
ConfirmTitle.BackgroundTransparency = 1; ConfirmTitle.Text = "Suicide TP"
ConfirmTitle.TextColor3 = Color3.fromRGB(238,244,255)
ConfirmTitle.Font = Enum.Font.GothamBlack; ConfirmTitle.TextSize = 16

local ConfirmMsg = Instance.new("TextLabel", ConfirmCard)
ConfirmMsg.Size = UDim2.new(1,-12,0,40); ConfirmMsg.Position = UDim2.new(0,6,0,34)
ConfirmMsg.BackgroundTransparency = 1; ConfirmMsg.Text = "TP ke lokasi ini?"
ConfirmMsg.TextColor3 = Color3.fromRGB(128,145,180)
ConfirmMsg.Font = Enum.Font.Gotham; ConfirmMsg.TextSize = 13
ConfirmMsg.TextWrapped = true

local ConfirmBtn = Instance.new("TextButton", ConfirmCard)
ConfirmBtn.Size = UDim2.new(0,140,0,30); ConfirmBtn.Position = UDim2.new(1,-150,1,-38)
ConfirmBtn.BackgroundColor3 = Color3.fromRGB(40,10,20)
ConfirmBtn.Text = "Confirm"; ConfirmBtn.TextColor3 = Color3.fromRGB(230,90,110)
ConfirmBtn.Font = Enum.Font.GothamBlack; ConfirmBtn.TextSize = 13; ConfirmBtn.AutoButtonColor = false
Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", ConfirmBtn).Color = Color3.fromRGB(100,30,50)

local CancelBtn2 = Instance.new("TextButton", ConfirmCard)
CancelBtn2.Size = UDim2.new(0,140,0,30); CancelBtn2.Position = UDim2.new(0,10,1,-38)
CancelBtn2.BackgroundColor3 = Color3.fromRGB(24,32,52)
CancelBtn2.Text = "Cancel"; CancelBtn2.TextColor3 = Color3.fromRGB(128,145,180)
CancelBtn2.Font = Enum.Font.GothamBlack; CancelBtn2.TextSize = 13; CancelBtn2.AutoButtonColor = false
Instance.new("UICorner", CancelBtn2).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", CancelBtn2).Color = Color3.fromRGB(38,48,78)

local confirmCallback = nil
local function showConfirm(locName, onConfirm)
    ConfirmMsg.Text = 'Teleport to: "'..locName..'"?'
    confirmCallback = onConfirm
    ConfirmModal.Visible = true
end
ConfirmBtn.MouseButton1Click:Connect(function()
    ConfirmModal.Visible = false
    if confirmCallback then confirmCallback(); confirmCallback = nil end
end)
CancelBtn2.MouseButton1Click:Connect(function()
    ConfirmModal.Visible = false; confirmCallback = nil; tpBusy = false
end)

-- ================================================================
-- ARC UI WINDOW
-- ================================================================
local Window = Arcane:Window({
    Name = "DARK HUB",
    User = plr.Name,
    Logo = "97741915311873"
})

Window:Watermark({ Title = "DARK HUB V3.0 · @darkhub" })

local function notify(name, desc, col)
    Arcane:Notification({
        Name = name, Description = desc, Duration = 3,
        Icon = "check", Color = col or Color3.fromRGB(90,160,255)
    })
end

-- ================================================================
-- PAGE: MAIN
-- ================================================================
local MainPage  = Window:Page({ Name = "Main",    Icon = "shield" })
local MainWar   = MainPage:Section({ Name = "War",      Side = 1 })
local MainBlink = MainPage:Section({ Name = "Blink",    Side = 2 })
local MainUtil  = MainPage:Section({ Name = "Utility",  Side = 2 })

-- War toggles
MainWar:Toggle({
    Name = "Instant Interact", Default = false, Flag = "InstantInteract",
    Tooltip = "Interact dengan prompt langsung",
    Callback = function(s) Flags.InstantInteract = s; saveSettings() end
})
MainWar:Toggle({
    Name = "Inv Scan", Default = false, Flag = "InvScan",
    Tooltip = "Lihat inventory player lain",
    Callback = function(s) Flags.InvScan = s; saveSettings() end
})
MainWar:Toggle({
    Name = "Blink TP", Default = false, Flag = "TPNoClip",
    Tooltip = "Blink teleport (T / HP mode)",
    Callback = function(s) Flags.TPNoClip = s; updateHPPanel(); saveSettings() end
})
MainWar:Toggle({
    Name = "Inf Stamina", Default = false, Flag = "InfStamina",
    Callback = function(s) Flags.InfStamina = s; saveSettings() end
})
MainWar:Toggle({
    Name = "Speed Hack", Default = false, Flag = "HybridSpeed",
    Tooltip = "Hybrid speed walk",
    Callback = function(s) Flags.HybridSpeed = s; saveSettings() end
})
MainWar:Toggle({
    Name = "NoClip", Default = false, Flag = "AuraKill",
    Tooltip = "Tembus semua part",
    Callback = function(s) Flags.AuraKill = s; saveSettings() end
})

-- Blink mode selector
local BlinkSel = MainBlink:Selector({
    Name = "Blink Mode",
    Items = { "PC", "HP" },
    Default = "PC",
    Flag = "BlinkMode"
})
if BlinkSel and BlinkSel.Callback ~= nil then
    -- use flag-based updates via Arcane
end
-- Fallback: pakai dropdown untuk mode
MainBlink:Dropdown({
    Name = "Blink Mode",
    Items = { "PC", "HP" },
    Default = "PC",
    Flag = "BlinkModeDD",
    Callback = function(val)
        BlinkMode = val or "PC"
        updateHPPanel()
    end
})

MainBlink:Toggle({
    Name = "Lock HP Panel", Default = false, Flag = "HPLock",
    Callback = function(s)
        hpPanelLocked = s
        HPPanel.Active = not s
    end
})

-- Utility
MainUtil:Button({
    Name = "🔻 Reduce Grafik",
    Callback = function()
        notify("Reduce Grafik", "Menerapkan...", Color3.fromRGB(220,80,120))
        task.spawn(function()
            local Lighting = game:GetService("Lighting")
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then pcall(function() v:Destroy() end) end
            end
            pcall(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 2
            end)
            local localChar = plr.Character
            local function handleInstance(instance)
                if instance:IsA("BasePart") then
                    if localChar and instance:IsDescendantOf(localChar) then return end
                    pcall(function()
                        instance.Material = Enum.Material.SmoothPlastic
                        instance.Reflectance = 0
                    end)
                end
                if instance:IsA("Texture") or instance:IsA("Decal") then
                    if localChar and instance:IsDescendantOf(localChar) then return end
                    pcall(function() instance.Transparency = 1 end)
                end
            end
            local all = workspace:GetDescendants()
            for i = 1, #all, 100 do
                for j = i, math.min(i+99, #all) do
                    pcall(function() handleInstance(all[j]) end)
                end
                task.wait()
            end
            pcall(function()
                local t = workspace:FindFirstChild("Terrain")
                if t then t.WaterWaveSize=0; t.WaveSpeed=0; t.WaterReflectance=0; t.WaterTransparency=1 end
            end)
            pcall(function()
                settings().Physics.AllowSleep = true
                settings().Rendering.QualityLevel = 1
                settings().Rendering.TextureQuality = Enum.TextureQuality.Low
            end)
            notify("Reduce Grafik", "Applied (rejoin to restore)", Color3.fromRGB(60,215,130))
        end)
    end
})

-- Wall Selector (via toggle + hotkeys)
local wsSelectMode = false
local wsSelected   = {}
local wsDisabled   = {}
local wsHighlights = {}
local mouse2 = plr:GetMouse()
local cam2   = workspace.CurrentCamera

local wsHoverBox = Instance.new("SelectionBox", workspace)
wsHoverBox.Color3 = Color3.fromRGB(90,160,255); wsHoverBox.LineThickness = 0.05
wsHoverBox.SurfaceTransparency = 0.88; wsHoverBox.SurfaceColor3 = Color3.fromRGB(90,160,255)

local function wsGetTarget()
    local ray = cam2:ScreenPointToRay(mouse2.X, mouse2.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local chars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(chars, p.Character) end
    end
    params.FilterDescendantsInstances = chars
    local r = workspace:Raycast(ray.Origin, ray.Direction*1000, params)
    return r and r.Instance or nil
end

local function wsAddHL(part)
    if wsHighlights[part] then return end
    local b = Instance.new("SelectionBox", workspace)
    b.Adornee = part; b.Color3 = Color3.fromRGB(90,160,255)
    b.LineThickness = 0.07; b.SurfaceTransparency = 0.75
    b.SurfaceColor3 = Color3.fromRGB(90,160,255)
    wsHighlights[part] = b
end
local function wsRemoveHL(part)
    if wsHighlights[part] then wsHighlights[part]:Destroy(); wsHighlights[part] = nil end
end
local function wsDoSelect(part)
    if not part or not part:IsA("BasePart") then return end
    local anc = part.Parent
    while anc do
        if anc:IsA("Model") and anc:FindFirstChildOfClass("Humanoid") then return end
        anc = anc.Parent
    end
    if wsSelected[part] then
        wsSelected[part] = nil; wsRemoveHL(part)
    else
        wsSelected[part] = true; wsAddHL(part)
    end
end
local function wsDoDisable()
    for part in pairs(wsSelected) do
        if part and part.Parent then
            wsDisabled[part] = { trans=part.Transparency, collide=part.CanCollide, shadow=part.CastShadow }
            pcall(function()
                part.Transparency=0.9; part.CanCollide=false; part.CastShadow=false
            end)
            wsRemoveHL(part)
        end
    end
    wsSelected = {}
end
local function wsDoRestore()
    for part, p in pairs(wsDisabled) do
        if part and part.Parent then
            pcall(function()
                part.Transparency=p.trans; part.CanCollide=p.collide; part.CastShadow=p.shadow
            end)
        end
    end
    wsDisabled = {}
end
local function wsDoClr()
    for part in pairs(wsSelected) do wsRemoveHL(part) end
    wsSelected = {}; wsHoverBox.Adornee = nil
end

RunService.RenderStepped:Connect(function()
    if not wsSelectMode then wsHoverBox.Adornee = nil; return end
    local t = wsGetTarget()
    wsHoverBox.Adornee = (t and not wsSelected[t]) and t or nil
end)
mouse2.Button1Down:Connect(function()
    if not wsSelectMode then return end
    local t = wsGetTarget()
    if t then wsDoSelect(t) end
end)
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.P then
        wsSelectMode = not wsSelectMode
        if not wsSelectMode then wsHoverBox.Adornee = nil end
    elseif inp.KeyCode == Enum.KeyCode.M then wsDoDisable()
    elseif inp.KeyCode == Enum.KeyCode.L then wsDoRestore()
    elseif inp.KeyCode == Enum.KeyCode.K then wsDoClr()
    end
end)

MainUtil:Toggle({
    Name = "Wall Selector [P]", Default = false, Flag = "WallSel",
    Tooltip = "P=toggle • M=disable • L=restore • K=clear",
    Callback = function(s)
        wsSelectMode = s
        if not s then wsHoverBox.Adornee = nil end
    end
})
MainUtil:Button({
    Name = "[M] Disable Selected Parts",
    Callback = function() wsDoDisable(); notify("Wall Selector", "Parts disabled", Color3.fromRGB(220,60,80)) end
})
MainUtil:Button({
    Name = "[L] Restore All Parts",
    Callback = function() wsDoRestore(); notify("Wall Selector", "Parts restored", Color3.fromRGB(60,215,130)) end
})
MainUtil:Button({
    Name = "[K] Clear Selection",
    Callback = function() wsDoClr(); notify("Wall Selector", "Selection cleared", Color3.fromRGB(90,160,255)) end
})

-- Fake Name
local MainFake = MainPage:Section({ Name = "Fake Name", Side = 1 })
local fake1 = MainFake:Textbox({ Name = "In-Game Name", Placeholder = "name", Flag = "FakeName1" })
local fake2 = MainFake:Textbox({ Name = "Username",      Placeholder = "username", Flag = "FakeName2" })
MainFake:Button({
    Name = "Apply Fake Name",
    Callback = function()
        local ok = false
        pcall(function()
            local char = plr.Character
            local myChar = (workspace:FindFirstChild("Characters")
                and workspace.Characters:FindFirstChild(plr.Name)) or char
            if not myChar then return end
            local name1 = fake1 and fake1.Text or ""
            local name2 = fake2 and fake2.Text or ""
            if name1 ~= "" then
                local tag1 = myChar.Head:FindFirstChild("NameTag")
                if tag1 then
                    local lbl = tag1:FindFirstChild("MainFrame") and tag1.MainFrame:FindFirstChild("NameLabel")
                    if lbl then
                        lbl.Text = name1; lbl.TextColor3 = Color3.fromRGB(255,255,255)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0); lbl.TextStrokeTransparency = 0.5
                        ok = true
                    end
                end
            end
            if name2 ~= "" then
                local tag2 = myChar.Head:FindFirstChild("RankTag")
                if tag2 then
                    local lbl = tag2:FindFirstChild("MainFrame") and tag2.MainFrame:FindFirstChild("NameLabel")
                    if lbl then
                        lbl.Text = name2; lbl.TextColor3 = Color3.fromRGB(255,255,255)
                        lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0); lbl.TextStrokeTransparency = 0.5
                        ok = true
                    end
                end
            end
        end)
        if ok then notify("Fake Name", "Applied!", Color3.fromRGB(60,215,130))
        else notify("Fake Name", "Tag not found", Color3.fromRGB(220,80,100)) end
    end
})

-- ================================================================
-- PAGE: VISUAL
-- ================================================================
local VisualPage = Window:Page({ Name = "Visual", Icon = "eye" })
local VisESP     = VisualPage:Section({ Name = "ESP Features", Side = 1 })
local VisSet     = VisualPage:Section({ Name = "ESP Settings", Side = 2 })

local function addEspToggle(flag, label)
    VisESP:Toggle({
        Name = label, Default = Flags[flag], Flag = flag,
        Callback = function(s) Flags[flag] = s; saveSettings() end
    })
end
addEspToggle("BoxESP",   "Box ESP")
addEspToggle("Tracer",   "Tracer")
addEspToggle("ESPName",  "Name")
addEspToggle("ESPDist",  "Distance")
addEspToggle("ESPHPBar", "HP Bar")
addEspToggle("ESPWeapon","Weapon")
addEspToggle("ESPSkeleton","Skeleton")
addEspToggle("ESPMasak", "Masak Indicator")

VisSet:Slider({
    Name = "Tracer Distance", Min = 50, Max = 1000, Default = 300, Suffix = "studs",
    Callback = function(v) TracerMaxDist = v end
})
VisSet:Slider({
    Name = "ESP Distance", Min = 10, Max = 5000, Default = 500, Suffix = "studs",
    Callback = function(v) ESPMaxDist = v end
})
VisSet:Dropdown({
    Name = "Box ESP Mode", Items = { "FULL", "CORNER" }, Default = "FULL", Flag = "BoxESPmode",
    Callback = function(v) BoxESPMode = v or "FULL" end
})

-- Spectate
local SpectatePlayers = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= plr then table.insert(SpectatePlayers, p.Name) end
end
local spectateTarget = nil
local spectateConn = nil

local function stopSpectate()
    if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
    spectateTarget = nil
    local cam = workspace.CurrentCamera
    pcall(function()
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    end)
end

local SpectateSec = VisualPage:Section({ Name = "Spectate Player", Side = 2 })
local specDD
specDD = SpectateSec:Dropdown({
    Name = "Target", Items = (function()
        local t = {} for _,p in ipairs(Players:GetPlayers()) do
            if p~=plr then table.insert(t, p.Name) end end
        return #t>0 and t or {"(none)"}
    end)(),
    Default = (function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=plr then return p.Name end
        end
        return "(none)"
    end)(),
    Flag = "SpectateTarget"
})
SpectateSec:Button({
    Name = "▶ Start Spectate",
    Callback = function()
        stopSpectate()
        local name = specDD and specDD.Value or nil
        if not name then notify("Spectate", "Pilih target dulu", Color3.fromRGB(255,160,0)); return end
        local t = Players:FindFirstChild(name)
        if not t or not t.Character then notify("Spectate", "Player tidak ditemukan", Color3.fromRGB(220,80,100)); return end
        spectateTarget = t
        local cam = workspace.CurrentCamera
        pcall(function()
            local hum = t.Character:FindFirstChildOfClass("Humanoid")
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum
        end)
        spectateConn = RunService.RenderStepped:Connect(function()
            if not spectateTarget or not spectateTarget.Parent then stopSpectate(); return end
            local ch = spectateTarget.Character
            if not ch then return end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
            if hum and cam.CameraSubject ~= hum then cam.CameraSubject = hum end
        end)
        notify("Spectate", "Spectating: "..name, Color3.fromRGB(90,160,255))
    end
})
SpectateSec:Button({
    Name = "■ Stop Spectate",
    Callback = function() stopSpectate(); notify("Spectate", "Stopped", Color3.fromRGB(128,145,180)) end
})

-- ================================================================
-- PAGE: AIM
-- ================================================================
local AimPage  = Window:Page({ Name = "Aim", Icon = "crosshair" })
local AimSecA  = AimPage:Section({ Name = "Aimbot",      Side = 1 })
local AimSecS  = AimPage:Section({ Name = "Silent Aim",  Side = 1 })
local AimSecX  = AimPage:Section({ Name = "Settings",    Side = 2 })

local AimToggle = AimSecA:Toggle({
    Name = "Auto Aim", Default = false, Flag = "AimLock",
    Tooltip = "Hold RMB / HP mode",
    Callback = function(s)
        Flags.AimLock = s; AimTarget = nil
        saveSettings()
        notify("Auto Aim", s and "Enabled" or "Disabled", Color3.fromRGB(90,160,255))
    end
})
AimSecA:Toggle({
    Name = "Wall Check", Default = false, Flag = "WallCheck",
    Callback = function(s) Flags.WallCheck = s; saveSettings() end
})
AimSecA:Dropdown({
    Name = "Aim Part", Items = { "Head", "Body" }, Default = "Head", Flag = "AimPartDD",
    Callback = function(v) AimPart = (v=="Body" and "Body" or "Head"); AimTarget = nil end
})
AimSecA:Dropdown({
    Name = "Aim Mode", Items = { "PC", "HP" }, Default = "PC", Flag = "AimModeDD",
    Callback = function(v) AimMode = v or "PC"; AimTarget = nil end
})
AimSecA:Slider({
    Name = "FOV Radius", Min = 30, Max = 400, Default = 120, Suffix = "px",
    Callback = function(v) AimFOV_Radius = v; saveSettings() end
})
AimSecA:Slider({
    Name = "Max Jarak", Min = 50, Max = 1000, Default = 300, Suffix = "studs",
    Callback = function(v) AimMax_Dist = v; saveSettings() end
})
AimSecA:Slider({
    Name = "Smoothness", Min = 1, Max = 100, Default = 85, Suffix = "%",
    Callback = function(v) AimSmooth = math.clamp(v/100, 0.01, 0.99); saveSettings() end
})

-- Silent Aim
local SilentToggle = AimSecS:Toggle({
    Name = "Silent Aim", Default = false, Flag = "SilentAim",
    Callback = function(s) SilentAim = s end
})
AimSecS:Toggle({
    Name = "Silent Wallbang", Default = false, Flag = "SilentWB",
    Callback = function(s) SilentAimWallbang = s end
})
AimSecS:Dropdown({
    Name = "Silent Part", Items = { "Head", "Body" }, Default = "Head", Flag = "SilentPartDD",
    Callback = function(v) SilentPart = (v=="Body" and "Body" or "Head") end
})
AimSecS:Dropdown({
    Name = "Silent Mode", Items = { "PC", "HP" }, Default = "PC", Flag = "SilentModeDD",
    Callback = function(v) SilentMode = v or "PC" end
})
AimSecS:Slider({
    Name = "Silent FOV", Min = 30, Max = 400, Default = 120, Suffix = "px",
    Callback = function(v) SilentFOV_Radius = v end
})

-- Extras
AimSecX:Toggle({
    Name = "Show Aim FOV", Default = true, Flag = "ShowAimFOV",
    Callback = function(s) ShowAimFOV = s end
})
AimSecX:Toggle({
    Name = "Show Silent FOV", Default = true, Flag = "ShowSilentFOV",
    Callback = function(s) ShowSilentFOV = s end
})
AimSecX:Dropdown({
    Name = "Whitelist Aim (Multi)", Multi = true,
    Items = (function()
        local t = {} for _,p in ipairs(Players:GetPlayers()) do
            if p~=plr then table.insert(t, p.Name) end end
        return #t>0 and t or {"(none)"}
    end)(),
    Default = {},
    Flag = "AimWhitelistDD",
    Callback = function(sel)
        AimWhitelist = {}
        if type(sel) == "table" then
            for _, name in ipairs(sel) do AimWhitelist[name] = true end
        elseif type(sel) == "string" then
            AimWhitelist[sel] = true
        end
    end
})

-- ================================================================
-- PAGE: FARM
-- ================================================================
local FarmPage = Window:Page({ Name = "Farm", Icon = "shopping-bag" })
local FarmSec  = FarmPage:Section({ Name = "Auto Farm Marshmallow", Side = 1 })
local FarmInf  = FarmPage:Section({ Name = "Info", Side = 2 })

local FarmActive = false
local FarmBatchAmount = 1

local WS = workspace
local originalGravity = WS.Gravity
local modifiedParts = {}
local ghostConn = nil
local OwnedKitchenPos = nil
local OwnedDoorPos    = nil

local mBags = {
    "Marshmallow","Marshmellow","Large Marshmallow Bag","Large Marshmellow Bag",
    "Medium Marshmallow Bag","Medium Marshmellow Bag","Small Marshmallow Bag","Small Marshmellow Bag"
}
local shopPos = Vector3.new(510.50, 4.5, 598.28)
local sellPos = shopPos

local ApartmentData = {
    { ID=1, BuyPos=Vector3.new(1108.82,10.11,453.35), DoorPos=Vector3.new(1115.17,10.11,456.57), KitchenPos=Vector3.new(1142.81,4.11,449.94) },
    { ID=2, BuyPos=Vector3.new(1108.79,10.11,424.20), DoorPos=Vector3.new(1114.19,10.11,428.26), KitchenPos=Vector3.new(1142.80,4.14,423.56) },
    { ID=3, BuyPos=Vector3.new(1018.19,10.11,246.44), DoorPos=Vector3.new(1012.79,10.11,242.32), KitchenPos=Vector3.new(984.11,4.11,247.28) },
    { ID=4, BuyPos=Vector3.new(1018.12,10.11,218.03), DoorPos=Vector3.new(1012.66,10.08,213.73), KitchenPos=Vector3.new(984.15,4.11,218.77) },
    { ID=5, BuyPos=Vector3.new(927.72,10.11,72.27),  DoorPos=Vector3.new(931.79,10.11,67.12),  KitchenPos=Vector3.new(926.84,4.11,38.49) },
    { ID=6, BuyPos=Vector3.new(899.17,10.11,72.51),  DoorPos=Vector3.new(902.99,10.11,67.16),  KitchenPos=Vector3.new(898.65,4.11,38.53) },
    { ID=7, BuyPos=Vector3.new(1197.11,3.71,-237.50),DoorPos=Vector3.new(1199.14,3.71,-243.04),KitchenPos=Vector3.new(1202.15,-2.29,-220.04) },
    { ID=8, BuyPos=Vector3.new(1196.79,3.71,-201.87),DoorPos=Vector3.new(1199.00,3.71,-207.04),KitchenPos=Vector3.new(1202.14,-2.29,-180.56) },
    { ID=9, BuyPos=Vector3.new(1185.65,3.71,-207.83),DoorPos=Vector3.new(1183.52,3.71,-202.90),KitchenPos=Vector3.new(1180.38,-2.29,-188.99) },
    { ID=10,BuyPos=Vector3.new(1185.42,3.71,-243.37),DoorPos=Vector3.new(1183.58,3.71,-238.20),KitchenPos=Vector3.new(1180.41,-2.29,-227.24) },
}

local function checkDeathStatus()
    if not FarmActive then return true end
    local char = plr.Character; if not char then return true end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return true end
    return false
end

local function startGhostMode()
    if ghostConn then return end
    ghostConn = RunService.Heartbeat:Connect(function()
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Sit then return end
        local hrp = char.HumanoidRootPart
        local function processNoclipPart(part)
            if not part or not part:IsA("BasePart") or part:IsA("Terrain") then return end
            if part:IsDescendantOf(char) then return end
            if part:IsA("Seat") or part:IsA("VehicleSeat") or part.Name:lower():find("seat") then return end
            local model = part:FindFirstAncestorOfClass("Model")
            if model and (model:FindFirstChildOfClass("VehicleSeat",true) or model:FindFirstChildOfClass("Seat",true)) then return end
            if not modifiedParts[part] then
                modifiedParts[part] = { CanCollide=part.CanCollide, CanTouch=part.CanTouch }
            end
            part.CanCollide=false; part.CanTouch=false
        end
        for _, part in ipairs(hrp:GetTouchingParts()) do processNoclipPart(part) end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        for _, dir in ipairs({
            Vector3.new(0,-4,0),
            hrp.CFrame.LookVector*3.5, -hrp.CFrame.LookVector*3.5,
            hrp.CFrame.RightVector*3.5, -hrp.CFrame.RightVector*3.5
        }) do
            local res = workspace:Raycast(hrp.Position, dir, params)
            if res and res.Instance then processNoclipPart(res.Instance) end
        end
    end)
end
local function stopGhostMode()
    if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
    for part, state in pairs(modifiedParts) do
        if part and part.Parent then
            part.CanCollide = state.CanCollide; part.CanTouch = state.CanTouch
        end
    end
    modifiedParts = {}
end
local function discreteStepTP(startP, endP)
    local stepDistance = 0.8
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    while FarmActive do
        if checkDeathStatus() then return false end
        local dist = (endP - hrp.Position).Magnitude
        if dist <= stepDistance then
            hrp.CFrame = CFrame.new(endP)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            return true
        else
            hrp.CFrame = CFrame.new(hrp.Position + ((endP - hrp.Position).Unit * stepDistance))
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        task.wait(0.08)
    end
    return false
end
local function blinkTeleport(targetPos, isUnderground)
    local char = plr.Character
    if not char or not char:FindFirstChild('HumanoidRootPart') then return end
    startGhostMode()
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChild('Humanoid')
    if humanoid then humanoid.PlatformStand = true end
    Workspace.Gravity = 0
    if isUnderground then
        local underY = -4
        discreteStepTP(hrp.Position, Vector3.new(hrp.Position.X, underY, hrp.Position.Z))
        discreteStepTP(hrp.Position, Vector3.new(targetPos.X, underY, targetPos.Z))
        discreteStepTP(hrp.Position, targetPos)
    else
        discreteStepTP(hrp.Position, targetPos)
    end
    Workspace.Gravity = originalGravity
    if humanoid then humanoid.PlatformStand = false end
    stopGhostMode()
end
local function BypassTP(targetPos)
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 9e9, 0)
        bv.Parent = hrp
    end
    local newChar = plr.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
    if newHrp then task.wait(0.5); newHrp.CFrame = CFrame.new(targetPos) end
    task.wait(1.2)
end
local function lockPosition(targetPos)
    local char = plr.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    startGhostMode()
    Workspace.Gravity = 0; humanoid.PlatformStand = true
    local oldBv = hrp:FindFirstChild("FarmLock"); if oldBv then oldBv:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FarmLock"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0); bv.Parent = hrp
    hrp.CFrame = CFrame.new(targetPos)
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.Anchored = true
end
local function unlockPosition()
    Workspace.Gravity = originalGravity
    local char = plr.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if hrp then
        local bv = hrp:FindFirstChild("FarmLock"); if bv then bv:Destroy() end
        hrp.Anchored = false
    end
    if humanoid then humanoid.PlatformStand = false end
    stopGhostMode()
end
local function countTool(nameOrList)
    local count = 0
    local char = plr.Character
    local bp = plr:FindFirstChild("Backpack")
    local function check(c)
        if not c then return end
        for _, item in ipairs(c:GetChildren()) do
            if item:IsA("Tool") then
                if type(nameOrList) == "table" then
                    for _, n in ipairs(nameOrList) do
                        if item.Name == n then count = count + 1 end
                    end
                elseif item.Name == nameOrList then count = count + 1 end
            end
        end
    end
    check(char); check(bp); return count
end
local function hasTool(n) return countTool(n) > 0 end
local function equipTool(n)
    local char = plr.Character; if not char then return false end
    local hum = char:FindFirstChild("Humanoid"); if not hum then return false end
    if char:FindFirstChild(n) then return true end
    hum:UnequipTools(); task.wait(0.05)
    local bp = plr:FindFirstChild("Backpack")
    local t = bp and bp:FindFirstChild(n)
    if t then hum:EquipTool(t); task.wait(0.1); return true end
    return false
end
local function matchPromptText(text, kw)
    if not kw then return true end
    text = string.lower(text or ""); kw = string.lower(kw)
    if kw == "lock" and string.find(text, "unlock") then return false end
    return string.find(text, kw) ~= nil
end
local function firePromptAt(pos, maxDist, kw)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local pPos = obj.Parent and ((obj.Parent:IsA("BasePart") and obj.Parent.Position)
                or (obj.Parent:IsA("Attachment") and obj.Parent.WorldPosition))
            if pPos and (pos - pPos).Magnitude <= maxDist then
                if matchPromptText(obj.ActionText, kw) then
                    obj.RequiresLineOfSight = false; obj.HoldDuration = 0
                    if fireproximityprompt then fireproximityprompt(obj, 0)
                    else obj:InputHoldBegin(); task.wait(0.05); obj:InputHoldEnd() end
                    return true
                end
            end
        end
    end
    return false
end
local function checkPromptExistsAt(pos, maxDist, kw)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local pPos = obj.Parent and ((obj.Parent:IsA("BasePart") and obj.Parent.Position)
                or (obj.Parent:IsA("Attachment") and obj.Parent.WorldPosition))
            if pPos and (pos - pPos).Magnitude <= maxDist then
                if matchPromptText(obj.ActionText, kw) then return true end
            end
        end
    end
    return false
end
local function secureDoor(doorPos)
    for i=1,10 do
        if not FarmActive then return false end
        if checkPromptExistsAt(doorPos, 8, "unlock") then return true end
        if checkPromptExistsAt(doorPos, 8, "lock") then
            firePromptAt(doorPos, 8, "lock"); task.wait(0.5)
            if checkPromptExistsAt(doorPos, 8, "unlock") then return true
            else firePromptAt(doorPos, 8, "open"); task.wait(0.7) end
        else firePromptAt(doorPos, 8, "open"); task.wait(0.5) end
    end
    return false
end
local function SetupApartment()
    local targetData = nil
    for _, data in ipairs(ApartmentData) do
        if not FarmActive then return end
        local isVacant = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") and string.find(string.upper(obj.Text), "VACANT") then
                local gui = obj:FindFirstAncestorOfClass("SurfaceGui") or obj:FindFirstAncestorOfClass("BillboardGui")
                local uiPart = gui and (gui.Adornee or gui.Parent)
                if uiPart and uiPart:IsA("BasePart") and (uiPart.Position - data.BuyPos).Magnitude <= 5 then
                    isVacant = true; break
                end
            end
        end
        if isVacant then targetData = data; break end
    end
    if targetData then
        BypassTP(targetData.BuyPos)
        firePromptAt(targetData.BuyPos, 5, "purchase"); task.wait(1)
        OwnedKitchenPos = targetData.KitchenPos
        OwnedDoorPos = targetData.DoorPos
        blinkTeleport(targetData.DoorPos, false); task.wait(0.8)
        secureDoor(targetData.DoorPos)
        return true
    end
    return false
end
local function robustBuy()
    local target = FarmBatchAmount
    while FarmActive do
        if checkDeathStatus() then return end
        local w = countTool({"Water","Water23"})
        local s = countTool("Sugar Block Bag")
        local g = countTool("Gelatin")
        if w>=target and s>=target and g>=target then break end
        local rs = RS:FindFirstChild("RemoteEvents")
        if rs and rs:FindFirstChild("ReliableRemoteEvent") then
            local remote = rs.ReliableRemoteEvent
            if g<target then
                local b=buffer.create(3); buffer.writeu8(b,0,24); buffer.writeu8(b,1,19); buffer.writeu8(b,2,1)
                remote:FireServer(b); task.wait(0.35)
            end
            if s<target then
                local b=buffer.create(3); buffer.writeu8(b,0,24); buffer.writeu8(b,1,19); buffer.writeu8(b,2,2)
                remote:FireServer(b); task.wait(0.35)
            end
            if w<target then
                local b=buffer.create(3); buffer.writeu8(b,0,24); buffer.writeu8(b,1,19); buffer.writeu8(b,2,3)
                remote:FireServer(b); task.wait(0.35)
            end
        end
        task.wait(0.4)
    end
end
local function robustPutIngredient(names, waitAfter)
    if not FarmActive then return false end
    local init = countTool(names)
    if init == 0 then return false end
    local att = 0
    while FarmActive and countTool(names) >= init and att < 30 do
        if checkDeathStatus() then return false end
        if type(names)=="table" then
            for _, n in ipairs(names) do if countTool(n)>0 then equipTool(n); break end end
        else equipTool(names) end
        task.wait(0.2); firePromptAt(OwnedKitchenPos, 8); task.wait(1.2)
        att = att + 1
    end
    if countTool(names) < init then
        if waitAfter and waitAfter>0 then
            local start = os.clock()
            while FarmActive and (os.clock()-start) < waitAfter do
                if checkDeathStatus() then return false end
                task.wait(0.5)
            end
        end
        return true
    end
    return false
end
local function CookAndPackRobust(batchNum)
    if not FarmActive then return end
    robustPutIngredient({"Water","Water23"}, 23)
    robustPutIngredient("Sugar Block Bag", 0)
    robustPutIngredient("Gelatin", 47)
    if not FarmActive then return end
    local initM = countTool(mBags)
    local to = 0
    while FarmActive and countTool(mBags) <= initM and to < 100 do
        if checkDeathStatus() then return end
        equipTool("Empty Bag"); firePromptAt(OwnedKitchenPos, 10); task.wait(0.3); to = to + 1
    end
    if FarmActive and countTool({"Water","Water23"}) > 0 then equipTool("Water") end
end
local function sellAllBags()
    if not FarmActive then return end
    for _, name in ipairs(mBags) do
        while hasTool(name) and FarmActive do
            if checkDeathStatus() then FarmActive=false; break end
            equipTool(name); task.wait(0.25)
            local char = plr.Character
            if char and char:FindFirstChild(name) then
                firePromptAt(sellPos, 8); task.wait(0.4)
            else task.wait(0.2) end
        end
    end
    task.wait(0.4)
end
local function RunFarm()
    local firstRun = true
    while FarmActive and Running do
        if firstRun then BypassTP(shopPos); firstRun = false end
        robustBuy()
        if not FarmActive then break end
        blinkTeleport(OwnedKitchenPos, true)
        if not FarmActive then break end
        lockPosition(OwnedKitchenPos)
        local bc = 1
        while FarmActive and (countTool({"Water","Water23"}) > 0
            and countTool("Sugar Block Bag") > 0
            and countTool("Gelatin") > 0) do
            if checkDeathStatus() then FarmActive=false; break end
            CookAndPackRobust(bc); bc = bc + 1
        end
        unlockPosition()
        if not FarmActive then break end
        blinkTeleport(shopPos, true)
        lockPosition(shopPos)
        sellAllBags()
        unlockPosition()
    end
    unlockPosition()
end

FarmSec:Toggle({
    Name = "Start Auto Farm", Default = false, Flag = "FarmActive",
    Callback = function(state)
        if state then
            FarmActive = true
            notify("Farm", "Starting...", Color3.fromRGB(90,160,255))
            task.spawn(function()
                if not OwnedKitchenPos then
                    local ok = SetupApartment()
                    if not ok then
                        notify("Farm", "Tidak ada apartment kosong!", Color3.fromRGB(220,80,100))
                        FarmActive = false
                        return
                    end
                end
                RunFarm()
            end)
        else
            FarmActive = false
            unlockPosition()
            notify("Farm", "Stopped", Color3.fromRGB(128,145,180))
        end
    end
})
FarmSec:Slider({
    Name = "Batch Amount", Min = 1, Max = 50, Default = 1, Suffix = "x",
    Callback = function(v) FarmBatchAmount = v end
})

FarmInf:Button({ Name = "Reset Apartment", Callback = function()
    OwnedKitchenPos = nil; OwnedDoorPos = nil
    notify("Farm", "Apartment reset", Color3.fromRGB(90,160,255))
end })

-- ================================================================
-- PAGE: TP
-- ================================================================
local TPPage = Window:Page({ Name = "TP", Icon = "map-pin" })
local TPSecOthers = TPPage:Section({ Name = "Others", Side = 1 })
local TPSecPlayer = TPPage:Section({ Name = "TP to Player", Side = 2 })

-- TP status text via button trick
local tpStatusLabel = TPSecOthers:Button({
    Name = "Status: Ready",
    Callback = function() end
})
local function setTPStatus(msg, col)
    if tpStatusLabel and tpStatusLabel.SetName then
        pcall(function() tpStatusLabel:SetName(msg) end)
    end
    notify("TP", msg, col or Color3.fromRGB(90,160,255))
end

local TP_OTHERS = {
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
    {name="Dealer", x=730.24, y=3.7, z=449.47},
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
    {name="The Deli 2", x=-662.23, y=3.98, z=159.33},
}

-- TP logic functions
local UNDERGROUND_Y = -4.00
local TP_SPEED = 16
local RESPAWN_WARP = Vector3.new(999999, 9999999, 999999)

local function resetHumanoid()
    local ch = plr.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then
        hum.Sit = false; task.wait(0.05)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        task.wait(0.1)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end
local function moveCharTo(targetPos)
    local ch = plr.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local offset = targetPos - hrp.Position
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p ~= hrp then
            pcall(function() p.CFrame = p.CFrame + offset end)
        end
    end
    hrp.CFrame = CFrame.new(targetPos) * (hrp.CFrame - hrp.CFrame.Position)
    hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
end
local function lerpChar(fromPos, toPos, speed)
    local dist = (toPos - fromPos).Magnitude
    if dist < 0.05 then return true end
    local travelT = dist / speed
    local elapsed = 0
    while elapsed < travelT and not tpCancelled do
        local hrp2 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return false end
        local t = math.clamp(elapsed / travelT, 0, 1)
        moveCharTo(fromPos:Lerp(toPos, t))
        local _, dt = RunService.Stepped:Wait()
        elapsed = elapsed + dt
    end
    if not tpCancelled then moveCharTo(toPos) end
    return not tpCancelled
end

tpToPos = function(cx, cy, cz, _, destName)
    if tpActive then return end
    tpActive = true; tpCancelled = false
    local ch = plr.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then tpActive = false; return end
    showTPOverlay()
    local underPos = Vector3.new(hrp.Position.X, UNDERGROUND_Y, hrp.Position.Z)
    local ok = lerpChar(hrp.Position, underPos, TP_SPEED)
    if ok and not tpCancelled then
        local hrp2 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp2 then ok = lerpChar(hrp2.Position, Vector3.new(cx, UNDERGROUND_Y, cz), TP_SPEED) end
    end
    if ok and not tpCancelled then
        local hrp3 = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp3 then lerpChar(hrp3.Position, Vector3.new(cx, cy + 3, cz), TP_SPEED) end
    end
    hideTPOverlay(); resetHumanoid(); tpActive = false
end

local function doSuicideTP(loc)
    tpBusy = true
    showTPOverlay()
    local ch = plr.Character
    local hrp0 = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp0 then tpBusy=false; hideTPOverlay(); return end
    hrp0.CFrame = CFrame.new(RESPAWN_WARP)
    local newChar = plr.CharacterAdded:Wait()
    local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
    local hum = newChar:WaitForChild("Humanoid", 10)
    if not hrp or not hum then tpBusy=false; hideTPOverlay(); return end
    local w = 0
    while hum.Health <= 0 and w < 5 do task.wait(0.1); w += 0.1 end
    task.wait(0.8)
    for _ = 1, 4 do hrp.CFrame = CFrame.new(loc.x, loc.y+3, loc.z); task.wait(0.15) end
    task.wait(0.1)
    hideTPOverlay(); notify("TP", "Arrived: "..loc.name, Color3.fromRGB(60,215,130))
    tpBusy = false
end

-- Populate TP buttons
for i, loc in ipairs(TP_OTHERS) do
    local L = loc
    TPSecOthers:Button({
        Name = L.name,
        Callback = function()
            if tpActive then notify("TP", "Sedang proses...", Color3.fromRGB(128,145,180)); return end
            task.spawn(function()
                tpToPos(L.x, L.y, L.z, nil, L.name)
                notify("TP", "Arrived: "..L.name, Color3.fromRGB(60,215,130))
            end)
        end
    })
end

-- Vehicle TP button in Others
TPSecOthers:Button({
    Name = "🚗 Vehicle TP (Bank)",
    Callback = function()
        local ok = doVehicleTP(CFrame.new(-48.64, 3.73, -320.46))
        notify("Vehicle TP", ok and "Bank" or "Tidak di kendaraan!",
            ok and Color3.fromRGB(90,160,255) or Color3.fromRGB(255,160,0))
    end
})

-- TP to Player
local playerListForTP = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= plr then table.insert(playerListForTP, p.Name) end
end
local tpPlayerDD
tpPlayerDD = TPSecPlayer:Dropdown({
    Name = "Target Player",
    Items = #playerListForTP > 0 and playerListForTP or {"(none)"},
    Default = playerListForTP[1] or "(none)",
    Flag = "TPPlayerTarget"
})
TPSecPlayer:Button({
    Name = "➤ TP to Player",
    Callback = function()
        local name = tpPlayerDD and tpPlayerDD.Value
        if not name then notify("TP", "Pilih player dulu", Color3.fromRGB(255,160,0)); return end
        local target = Players:FindFirstChild(name)
        local hrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("TP", "Player tidak ditemukan", Color3.fromRGB(220,80,100)); return end
        task.spawn(function()
            tpToPos(hrp.Position.X, hrp.Position.Y, hrp.Position.Z, nil, name)
            notify("TP", "Arrived: "..name, Color3.fromRGB(60,215,130))
        end)
    end
})
TPSecPlayer:Button({
    Name = "🚗 Vehicle TP to Player",
    Callback = function()
        local name = tpPlayerDD and tpPlayerDD.Value
        local target = name and Players:FindFirstChild(name)
        local hrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("TP", "Player tidak ditemukan", Color3.fromRGB(220,80,100)); return end
        local ok = doVehicleTP(CFrame.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z))
        notify("Vehicle TP", ok and name or "Tidak di kendaraan!",
            ok and Color3.fromRGB(90,160,255) or Color3.fromRGB(255,160,0))
    end
})
TPSecPlayer:Button({
    Name = "☠ Suicide TP to Player",
    Callback = function()
        local name = tpPlayerDD and tpPlayerDD.Value
        local target = name and Players:FindFirstChild(name)
        local hrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("TP", "Player tidak ditemukan", Color3.fromRGB(220,80,100)); return end
        showConfirm(name, function()
            task.spawn(function()
                doSuicideTP({name=name, x=hrp.Position.X, y=hrp.Position.Y, z=hrp.Position.Z})
            end)
        end)
    end
})

-- ================================================================
-- PAGE: VEHICLE
-- ================================================================
local VehPage = Window:Page({ Name = "Vehicle", Icon = "car" })
local VehSec  = VehPage:Section({ Name = "Vehicle Fly", Side = 1 })
local VehInf  = VehPage:Section({ Name = "Info", Side = 2 })

local vFlyActive = false
local vFlySpeed = 50
local vLockedCF = nil
local vFlyLoop = nil
local vCam = workspace.CurrentCamera

local function vStopFly()
    vLockedCF = nil
    if vFlyLoop then vFlyLoop:Disconnect(); vFlyLoop = nil end
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        vCam.CameraSubject = hum; vCam.CameraType = Enum.CameraType.Custom
    end
end
local function vStartFly()
    vStopFly()
    vFlyLoop = RunService.Heartbeat:Connect(function(dt)
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if seat then
            local vehicle = seat:FindFirstAncestorOfClass("Model")
            local vRoot = (vehicle and vehicle.PrimaryPart) or seat
            if not vLockedCF then vLockedCF = vRoot.CFrame end
            if vCam.CameraType ~= Enum.CameraType.Custom then vCam.CameraType = Enum.CameraType.Custom end
            if vCam.CameraSubject ~= hum then vCam.CameraSubject = hum end
            local dir = Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + vCam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - vCam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - vCam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + vCam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            vLockedCF = CFrame.new(vLockedCF.Position + dir * vFlySpeed * dt) * vLockedCF.Rotation
            vRoot.CFrame = vLockedCF
            vRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
            vRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
        else
            if vFlyActive then vFlyActive = false; vStopFly() end
        end
    end)
end

VehSec:Toggle({
    Name = "Vehicle Fly", Default = false, Flag = "VehicleFly",
    Tooltip = "W/A/S/D + E/Q",
    Callback = function(s)
        vFlyActive = s
        if s then vStartFly() else vStopFly() end
    end
})
VehSec:Slider({
    Name = "Fly Speed", Min = 10, Max = 500, Default = 50,
    Callback = function(v) vFlySpeed = v end
})

VehInf:Button({ Name = "ℹ Duduk dulu di kendaraan", Callback = function() end })
VehInf:Button({ Name = "ℹ W/A/S/D = gerak", Callback = function() end })
VehInf:Button({ Name = "ℹ E = naik / Q = turun", Callback = function() end })
VehInf:Button({ Name = "ℹ Auto OFF kalau keluar", Callback = function() end })

-- ================================================================
-- PAGE: INFO
-- ================================================================
local InfoPage = Window:Page({ Name = "Info", Icon = "info" })
local InfoSec  = InfoPage:Section({ Name = "Contact", Side = 1 })
local InfoWarn = InfoPage:Section({ Name = "Warning", Side = 2 })

InfoSec:Button({
    Name = "♪ TikTok @darkhub — Tap to Copy",
    Callback = function()
        pcall(function() setclipboard("@darkhub") end)
        notify("Copied", "@darkhub tersalin", Color3.fromRGB(60,215,130))
    end
})
InfoSec:Button({
    Name = "◈ Discord — Tap to Copy Link",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/pDEyArQ5B") end)
        notify("Copied", "Discord link tersalin", Color3.fromRGB(60,215,130))
    end
})

InfoWarn:Button({ Name = "⚠ USE AT YOUR OWN RISK", Callback = function() end })
InfoWarn:Button({ Name = "⚠ We are not responsible for bans", Callback = function() end })
InfoWarn:Button({ Name = "❌ DILARANG SHARING!", Callback = function() end })
InfoWarn:Button({ Name = "❌ DILARANG JUAL KEMBALI!", Callback = function() end })

-- ================================================================
-- PAGE: CONFIG
-- ================================================================
local ConfigPage = Window:Page({ Name = "Config", Icon = "save" })
local ConfigSub  = ConfigPage:SubPage({ Name = "Configs", Icon = "save" })
ConfigSub:Config()

-- ================================================================
-- ESP/AIM/NOCLIP LOGIC (START)
-- ================================================================
-- WALLCHECK ray params
local wpRayParams = RaycastParams.new()
wpRayParams.FilterType = Enum.RaycastFilterType.Blacklist

-- NOCLIP
local NC_CollideData = {}
local function NC_CacheCollide(char)
    NC_CollideData = {}
    for _, part in ipairs(char:GetChildren()) do
        pcall(function()
            if part:IsA("BasePart") and part.CanCollide ~= nil then
                NC_CollideData[part.Name] = part.CanCollide
            end
        end)
    end
end
if plr.Character then pcall(function() NC_CacheCollide(plr.Character) end) end
plr.CharacterAdded:Connect(NC_CacheCollide)

local _ncMetaInstalled = false
local function NC_InstallMeta()
    if _ncMetaInstalled then return end
    _ncMetaInstalled = true
    pcall(function()
        local oldMeta = getrawmetatable(game)
        local oldIndex = oldMeta.__index
        local oldNamecall = oldMeta.__namecall
        setreadonly(oldMeta, false)
        oldMeta.__index = function(self, index)
            if index == "CanCollide" then
                if typeof(self)=="Instance" and self.Name and NC_CollideData[self.Name] then
                    return NC_CollideData[self.Name]
                end
            end
            return oldIndex(self, index)
        end
        oldMeta.__namecall = function(self, ...) return oldNamecall(self, ...) end
        setreadonly(oldMeta, true)
    end)
end

local noclipActive = false
local function enableAura()
    if noclipActive then return end
    NC_InstallMeta()
    noclipActive = true
    RunService:BindToRenderStep("NoClip", 400, function()
        if not Flags.AuraKill then return end
        local char = plr.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function() part.CanCollide = false end)
            end
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then pcall(function() root.CanCollide = false end) end
    end)
end
local function disableAura()
    if not noclipActive then return end
    noclipActive = false
    RunService:UnbindFromRenderStep("NoClip")
    local char = plr.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name and NC_CollideData[part.Name] ~= nil then
                pcall(function() part.CanCollide = NC_CollideData[part.Name] end)
            elseif part:IsA("BasePart") and part.Name == "HumanoidRootPart" then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
end
plr.CharacterAdded:Connect(function(char)
    if noclipActive then disableAura() end
    task.wait(0.5); NC_CacheCollide(char)
end)

-- Stamina
RunService:BindToRenderStep("InfStamina", 0, function()
    if not Flags.InfStamina then return end
    pcall(function()
        local MovCtrl = require(plr.PlayerScripts["Client.Initializer"].Modules.MovementController)
        MovCtrl.Stamina = 100
    end)
end)

-- Speed hack
local HS_ANIM_SPEED = 22
local HS_FINAL_SPEED = 25
local HS_PUSH = HS_FINAL_SPEED - HS_ANIM_SPEED

-- Blink keybind (T for PC mode)
UIS.InputBegan:Connect(function(input, processed)
    if not Running then return end
    if Flags.TPNoClip and BlinkMode == "PC" and input.KeyCode == Enum.KeyCode.T then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Linear),
                {CFrame = hrp.CFrame * CFrame.new(0,0,-6)}):Play()
        end
    end
end)

-- Instant Interact
do
    local pps = game:GetService("ProximityPromptService")
    pps.PromptShown:Connect(function(prompt)
        if not Running then return end
        if Flags.InstantInteract then
            pcall(function() if prompt.HoldDuration > 0 then prompt.HoldDuration = 0.05 end end)
        end
    end)
end

-- Inventory scan billboards
local Inv_Tags = {}
local function createInvTag(p)
    if Inv_Tags[p] or p == plr then return end
    local it = Instance.new("BillboardGui")
    it.Size = UDim2.new(0,250,0,150)
    it.StudsOffset = Vector3.new(0,4,0)
    it.AlwaysOnTop = true; it.Enabled = false; it.Parent = OvGui
    local lbl = Instance.new("TextLabel", it)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 14; lbl.TextStrokeTransparency = 0.5; lbl.TextYAlignment = Enum.TextYAlignment.Top
    Inv_Tags[p] = it
    p.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        local h = char:FindFirstChild("Head")
        if h and Inv_Tags[p] then Inv_Tags[p].Adornee = h end
    end)
    local ch = p.Character
    if ch then
        local h = ch:FindFirstChild("Head")
        if h then it.Adornee = h end
    end
end
local function removeInvTag(p)
    if Inv_Tags[p] then Inv_Tags[p]:Destroy(); Inv_Tags[p] = nil end
end
for _, p in pairs(Players:GetPlayers()) do createInvTag(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1); createInvTag(p) end)
Players.PlayerRemoving:Connect(removeInvTag)

task.spawn(function()
    while Running do
        task.wait(2)
        for _, p in pairs(Players:GetPlayers()) do
            if p == plr then continue end
            local it = Inv_Tags[p]; if not it then continue end
            if _overlayActive then it.Enabled = false; continue end
            local ch = p.Character
            local head = ch and ch:FindFirstChild("Head")
            if Flags.InvScan and head then
                if it.Adornee ~= head then it.Adornee = head end
                it.Enabled = true
                pcall(function()
                    local held = "None"
                    local inv = {}
                    for _, v in pairs(ch:GetChildren()) do if v:IsA("Tool") then held = v.Name end end
                    for _, v in pairs(p.Backpack:GetChildren()) do table.insert(inv, "• "..v.Name) end
                    local lbl = it:FindFirstChildOfClass("TextLabel")
                    if lbl then lbl.Text = "[HELD]: "..held.."\n\n[INV]:\n"..table.concat(inv, "\n") end
                end)
            else it.Enabled = false end
        end
    end
end)

-- ESP player connectors
local espCache = {}; local espConns = {}
local ESP_MASAK_KW = {"water","sugar","gelatin","marshmallow"}
local function isKW(name)
    local n = name:lower()
    for _, kw in ipairs(ESP_MASAK_KW) do if n:find(kw) then return true end end
    return false
end
local function rebuildCache(p)
    if not p or not p.Parent then return end
    local hb, wn = false, nil
    pcall(function()
        local bp = p.Backpack
        if bp then
            for _, v in ipairs(bp:GetChildren()) do
                if v:IsA("Tool") and isKW(v.Name) then hb = true end
            end
        end
        local ch = p.Character
        if ch then
            for _, v in ipairs(ch:GetChildren()) do
                if v:IsA("Tool") then
                    if isKW(v.Name) then hb = true else wn = v.Name end
                end
            end
        end
    end)
    espCache[p] = {hasBahan=hb, wName=wn}
end
local function connectESPPlayer(p)
    if p == plr or espConns[p] then return end
    local conns = {}; espConns[p] = conns
    rebuildCache(p)
    local bp = p.Backpack
    if bp then
        table.insert(conns, bp.ChildAdded:Connect(function() rebuildCache(p) end))
        table.insert(conns, bp.ChildRemoved:Connect(function() rebuildCache(p) end))
    end
    local function watchChar(ch)
        if not ch then return end
        table.insert(conns, ch.ChildAdded:Connect(function(v)
            if v:IsA("Tool") then rebuildCache(p) end end))
        table.insert(conns, ch.ChildRemoved:Connect(function(v)
            if v:IsA("Tool") then rebuildCache(p) end end))
        rebuildCache(p)
    end
    if p.Character then watchChar(p.Character) end
    table.insert(conns, p.CharacterAdded:Connect(function(ch) task.wait(0.1); watchChar(ch) end))
end
local function disconnectESPPlayer(p)
    local conns = espConns[p]
    if conns then for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end; espConns[p] = nil end
    espCache[p] = nil
end
for _, p in ipairs(Players:GetPlayers()) do
    createESP(p); connectESPPlayer(p)
end
Players.PlayerAdded:Connect(function(p) createESP(p); connectESPPlayer(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p); disconnectESPPlayer(p) end)

-- Silent Aim hook (searchGc)
task.spawn(function()
    local function searchGc(fname)
        local ok, gc = pcall(getgc)
        if not ok then return nil end
        for _, v in pairs(gc) do
            if type(v) == "function" then
                local ok2, info = pcall(debug.getinfo, v)
                if ok2 and info and info.name == fname then return v end
            end
        end
    end
    local tries = 0
    local OldCast, CastWL
    while tries < 30 do
        task.wait(1); tries = tries + 1
        local cb = searchGc("CastBlacklist")
        local cw = searchGc("CastWhitelist")
        if cb and cw then
            OldCast = hookfunction(cb, function(...)
                if not SilentAim then return OldCast(...) end
                local cam = workspace.CurrentCamera
                local vp = cam.ViewportSize
                local center = SilentMode == "HP" and Vector2.new(vp.X/2, vp.Y/2) or UIS:GetMouseLocation()
                local Target, LowestDist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    local ch = p.Character
                    if p == plr or not ch then continue end
                    local hp2 = ch:FindFirstChild(SilentPart == "Head" and "Head" or "HumanoidRootPart")
                    local hrp = ch:FindFirstChild("HumanoidRootPart")
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    if not hp2 or not hrp or not hum or hum.Health <= 0 then continue end
                    local sp, on = cam:WorldToViewportPoint(hrp.Position)
                    if not on then continue end
                    local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                    if d < SilentFOV_Radius and d < LowestDist then Target = p; LowestDist = d end
                end
                if Target then
                    local args = {...}
                    local hp2 = Target.Character and Target.Character:FindFirstChild(SilentPart=="Head" and "Head" or "HumanoidRootPart")
                    if hp2 then
                        args[2] = hp2.Position - args[1]
                        if SilentAimWallbang then args[3] = {Target.Character}; return cw(table.unpack(args)) end
                    end
                    return OldCast(table.unpack(args))
                end
                return OldCast(...)
            end)
            break
        end
    end
end)

-- ================================================================
-- MAIN RENDER LOOP
-- ================================================================
local RMB = false
UIS.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then RMB = true end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then
        RMB = false; AimTarget = nil
    end
end)

local SKEL_BONES = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"RightUpperLeg","LeftUpperLeg"},
}

RunService.RenderStepped:Connect(function()
    if not Running then
        FovCircle:Remove(); SilentFovCircle:Remove(); SilentLine:Remove()
        return
    end

    -- Speed hack
    if Flags.HybridSpeed then
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            if hum.WalkSpeed ~= HS_ANIM_SPEED then hum.WalkSpeed = HS_ANIM_SPEED end
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + hum.MoveDirection * HS_PUSH * (1/60)
            end
        end
    end

    -- Aura toggle handling
    if Flags.AuraKill and not noclipActive then enableAura()
    elseif not Flags.AuraKill and noclipActive then disableAura() end

    -- HP panel visibility
    HPPanel.Visible = (BlinkMode == "HP" and Flags.TPNoClip and not _overlayActive)

    if _overlayActive then
        FovCircle.Visible = false; SilentFovCircle.Visible = false; SilentLine.Visible = false
        for _, e in pairs(ESP) do _hideESP(e) end
        return
    end

    local cam = workspace.CurrentCamera
    local vp  = cam.ViewportSize
    local mousePos = UIS:GetMouseLocation()
    local localChar = plr.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

    local fovCenter = (AimMode == "HP") and Vector2.new(vp.X/2, vp.Y/2) or mousePos
    FovCircle.Radius = AimFOV_Radius
    FovCircle.Visible = Flags.AimLock and ShowAimFOV

    -- Silent aim visualization
    if SilentAim then
        local saOrigin = SilentMode == "HP" and Vector2.new(vp.X/2, vp.Y/2) or mousePos
        local bestWorldD = math.huge
        local bestScreenPos = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p == plr then continue end
            local ch = p.Character; if not ch then continue end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local part = ch:FindFirstChild(AimPart == "Head" and "Head" or "HumanoidRootPart")
            if not part or not hum or hum.Health <= 0 then continue end
            local sp, on = cam:WorldToViewportPoint(part.Position)
            if not on or sp.Z <= 0 then continue end
            local screenPos = Vector2.new(sp.X, sp.Y)
            if (saOrigin - screenPos).Magnitude > SilentFOV_Radius then continue end
            local wd = localRoot and (part.Position - localRoot.Position).Magnitude or math.huge
            if wd < bestWorldD then bestWorldD = wd; bestScreenPos = screenPos end
        end
        if bestScreenPos then
            SilentFovCircle.Position = SilentMode == "HP" and bestScreenPos or saOrigin
            SilentFovCircle.Radius = SilentFOV_Radius
            SilentFovCircle.Visible = ShowSilentFOV
            SilentLine.From = saOrigin; SilentLine.To = bestScreenPos; SilentLine.Visible = ShowSilentFOV
        else
            SilentFovCircle.Position = saOrigin
            SilentFovCircle.Radius = SilentFOV_Radius
            SilentFovCircle.Visible = ShowSilentFOV
            SilentLine.Visible = false
        end
    else
        SilentFovCircle.Visible = false; SilentLine.Visible = false
    end

    -- Aimbot
    if AimTarget then
        local tHum = AimTarget.Parent and AimTarget.Parent:FindFirstChildOfClass("Humanoid")
        if not tHum or tHum.Health <= 0 then AimTarget = nil end
    end
    if AimTarget and AimMode == "PC" then
        local sp, on = cam:WorldToScreenPoint(AimTarget.Position)
        if not on then AimTarget = nil
        else
            local d = math.sqrt((sp.X - fovCenter.X)^2 + (sp.Y - fovCenter.Y)^2)
            if d > AimFOV_Radius then AimTarget = nil end
        end
    end

    local shouldAim = Flags.AimLock and localRoot and (AimMode == "HP" or RMB)
    if shouldAim then
        if AimMode == "HP" or not AimTarget then
            local bestDist, bestPart = math.huge, nil
            for _, p in pairs(Players:GetPlayers()) do
                if p == plr or AimWhitelist[p.Name] then continue end
                local ch = p.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local tp2 = ch and ch:FindFirstChild(AimPart == "Head" and "Head" or "HumanoidRootPart")
                if not tp2 or not hum or hum.Health <= 0 then continue end
                if (tp2.Position - localRoot.Position).Magnitude > AimMax_Dist then continue end
                local sp, on = cam:WorldToScreenPoint(tp2.Position)
                if not on then continue end
                if Flags.WallCheck then
                    local camPos = cam.CFrame.Position
                    local dir = tp2.Position - camPos
                    wpRayParams.FilterDescendantsInstances = {cam, plr.Character}
                    local hit = workspace:Raycast(camPos, dir.Unit * dir.Magnitude, wpRayParams)
                    if hit and not hit.Instance:IsDescendantOf(ch) then continue end
                end
                local d = math.sqrt((sp.X-fovCenter.X)^2 + (sp.Y-fovCenter.Y)^2)
                if d <= AimFOV_Radius and d < bestDist then bestDist = d; bestPart = tp2 end
            end
            AimTarget = bestPart
        end
        if AimTarget then
            local targetCF = CFrame.lookAt(cam.CFrame.Position, AimTarget.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCF, AimSmooth)
            FovCircle.Color = Color3.fromRGB(255,80,80)
        else
            FovCircle.Color = Color3.fromRGB(90,160,255)
        end
    else
        if AimMode == "PC" and not RMB then AimTarget = nil end
        FovCircle.Color = Color3.fromRGB(90,160,255)
    end

    if AimMode == "HP" and AimTarget then
        local sp2, vis2 = cam:WorldToViewportPoint(AimTarget.Position)
        if vis2 and sp2.Z > 0 then FovCircle.Position = Vector2.new(sp2.X, sp2.Y)
        else FovCircle.Position = fovCenter end
    else
        FovCircle.Position = fovCenter
    end

    -- ESP render
    local anyESP = Flags.BoxESP or Flags.Tracer or Flags.ESPName or Flags.ESPDist
        or Flags.ESPHPBar or Flags.ESPWeapon or Flags.ESPSkeleton or Flags.ESPMasak
    for p, e in pairs(ESP) do
        local ch = p.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if not anyESP or not ch or not hum or not root then _hideESP(e); continue end

        local pos3, on = cam:WorldToViewportPoint(root.Position)
        if not on or pos3.Z <= 0 then _hideESP(e); continue end
        local isDead = hum.Health <= 0
        if localRoot and (root.Position - localRoot.Position).Magnitude > ESPMaxDist then _hideESP(e); continue end

        if Flags.ESPSkeleton then
            local W2 = isDead and Color3.fromRGB(255,80,100) or Color3.fromRGB(90,160,255)
            for si, bone in ipairs(SKEL_BONES) do
                local p1 = ch:FindFirstChild(bone[1])
                local p2 = ch:FindFirstChild(bone[2])
                local sk = e.skeleton[si]
                if p1 and p2 then
                    local s1, v1 = cam:WorldToViewportPoint(p1.Position)
                    local s2, v2 = cam:WorldToViewportPoint(p2.Position)
                    if v1 and v2 and s1.Z>0 and s2.Z>0 then
                        sk.From = Vector2.new(s1.X, s1.Y); sk.To = Vector2.new(s2.X, s2.Y)
                        sk.Color = W2; sk.Visible = true
                    else sk.Visible = false end
                else sk.Visible = false end
            end
        else
            for _, s in ipairs(e.skeleton) do s.Visible = false end
        end

        local topPos = cam:WorldToViewportPoint(root.Position + Vector3.new(0,3.2,0))
        local botPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0,3.5,0))
        local sY = math.abs(botPos.Y - topPos.Y)
        local sX = sY * 0.6
        local bx = pos3.X - sX/2
        local by = math.min(topPos.Y, botPos.Y)
        local cache = espCache[p] or {hasBahan=false, wName=nil}
        local W = isDead and Color3.fromRGB(255,80,100) or Color3.fromRGB(90,160,255)

        if Flags.BoxESP then
            e.box.Color = W; e.box.Size = Vector2.new(sX, sY); e.box.Position = Vector2.new(bx, by)
            e.box.Visible = (BoxESPMode == "FULL")
            local showC = (BoxESPMode == "CORNER")
            local cL = math.min(sX, sY) * 0.25
            local cx = e.corners
            cx[1].From = Vector2.new(bx, by);         cx[1].To = Vector2.new(bx+cL, by)
            cx[2].From = Vector2.new(bx, by);         cx[2].To = Vector2.new(bx, by+cL)
            cx[3].From = Vector2.new(bx+sX, by);      cx[3].To = Vector2.new(bx+sX-cL, by)
            cx[4].From = Vector2.new(bx+sX, by);      cx[4].To = Vector2.new(bx+sX, by+cL)
            cx[5].From = Vector2.new(bx, by+sY);      cx[5].To = Vector2.new(bx+cL, by+sY)
            cx[6].From = Vector2.new(bx, by+sY);      cx[6].To = Vector2.new(bx, by+sY-cL)
            cx[7].From = Vector2.new(bx+sX, by+sY);   cx[7].To = Vector2.new(bx+sX-cL, by+sY)
            cx[8].From = Vector2.new(bx+sX, by+sY);   cx[8].To = Vector2.new(bx+sX, by+sY-cL)
            for ci = 1,8 do cx[ci].Color = W; cx[ci].Visible = showC end
        else
            e.box.Visible = false
            for ci = 1,8 do e.corners[ci].Visible = false end
        end

        local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local barH = math.max(1, sY * hp)
        local barX = bx - 7
        local hpCol = hp > 0.5 and Color3.fromRGB(0,220,0) or hp > 0.2 and Color3.fromRGB(255,165,0) or Color3.fromRGB(255,0,0)
        if Flags.ESPHPBar then
            e.hpbg.Size = Vector2.new(4, sY); e.hpbg.Position = Vector2.new(barX, by)
            e.hpbg.Color = Color3.fromRGB(0,0,0); e.hpbg.Filled = false
            e.hpbg.Thickness = 1; e.hpbg.Visible = true
            e.hpbar.Color = hpCol; e.hpbar.Size = Vector2.new(4, barH)
            e.hpbar.Position = Vector2.new(barX, by + (sY - barH))
            e.hpbar.Filled = true; e.hpbar.Visible = true
            e.hpnum.Text = math.floor(hum.Health).."HP"; e.hpnum.Size = 11
            e.hpnum.Position = Vector2.new(barX+2, by-1); e.hpnum.Center = false
            e.hpnum.Color = hpCol; e.hpnum.Visible = true
        else
            e.hpbg.Visible = false; e.hpbar.Visible = false; e.hpnum.Visible = false
        end

        local distNow = localRoot and (root.Position - localRoot.Position).Magnitude or 100
        local tSize = math.clamp(math.floor(14 - distNow/40), 8, 14)
        if Flags.ESPName then
            e.dispname.Text = (p.DisplayName or p.Name).."(@"..p.Name..")"
            e.dispname.Size = tSize; e.dispname.Color = W
            e.dispname.Position = Vector2.new(pos3.X, by-14); e.dispname.Visible = true
            e.username.Visible = false
        else
            e.dispname.Visible = false; e.username.Visible = false
        end

        local dist = localRoot and math.floor((root.Position - localRoot.Position).Magnitude) or 0
        local nY = by + sY + 3
        if Flags.ESPDist then
            e.dist.Text = dist.."m"; e.dist.Size = tSize; e.dist.Color = W
            e.dist.Position = Vector2.new(pos3.X, nY); e.dist.Visible = true; nY = nY + 13
        else e.dist.Visible = false end

        if Flags.ESPWeapon and cache.wName then
            e.weapon.Text = cache.wName; e.weapon.Color = Color3.fromRGB(90,160,255)
            e.weapon.Position = Vector2.new(pos3.X, nY); e.weapon.Visible = true
        else e.weapon.Visible = false end

        if Flags.ESPMasak and cache.hasBahan then
            e.masak.Text = "MASAK"; e.masak.Position = Vector2.new(bx+sX+4, by+sY/2-6)
            e.masak.Center = false; e.masak.Visible = true
        else e.masak.Visible = false end

        local tDist = localRoot and (root.Position - localRoot.Position).Magnitude or 999
        if Flags.Tracer and tDist < TracerMaxDist then
            local vp2 = cam.ViewportSize
            e.tracer.From = Vector2.new(vp2.X/2, vp2.Y); e.tracer.To = Vector2.new(pos3.X, by+sY)
            e.tracer.Color = W; e.tracer.Visible = true
        else e.tracer.Visible = false end
    end
end)

-- ================================================================
-- LOADED NOTIFICATION
-- ================================================================
task.delay(0.5, function()
    notify("DARK HUB", "Loaded — Right Ctrl to toggle.", Color3.fromRGB(60,215,130))
end)

loadSettings()