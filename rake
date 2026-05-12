--[[
    Feather Hub – Rake Remastered
    Modern purple‑accented UI, no external library required.
    Inspired by the Feather Hub design system.
]]

-- ============================================================
-- THEME & COLOUR PALETTE (Purple accent)
-- ============================================================
local T = {
    bg          = Color3.fromRGB(8, 8, 14),
    card        = Color3.fromRGB(14, 14, 20),
    accent      = Color3.fromRGB(110, 95, 210),
    accentDim   = Color3.fromRGB(90, 78, 170),
    accentLt    = Color3.fromRGB(130, 115, 225),
    text        = Color3.fromRGB(210, 210, 220),
    muted       = Color3.fromRGB(140, 140, 155),
    dim         = Color3.fromRGB(30, 30, 40),
    border      = Color3.fromRGB(40, 40, 55),
    inputBg     = Color3.fromRGB(18, 18, 26),
    sep         = Color3.fromRGB(25, 25, 35),
    gold        = Color3.fromRGB(255, 200, 50),
    green       = Color3.fromRGB(80, 220, 100),
    red         = Color3.fromRGB(255, 80, 80),
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Helper function for quick tweens
local function tw(duration)
    return TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

-- ============================================================
-- UI BUILDING UTILITIES
-- ============================================================
local function makeCard(parent, order)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 0)
    c.AutomaticSize = Enum.AutomaticSize.Y
    c.BackgroundColor3 = T.card
    c.BorderSizePixel = 0
    c.LayoutOrder = order
    c.ZIndex = 3
    c.Parent = parent
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 11)
    local s = Instance.new("UIStroke")
    s.Color = T.border
    s.Thickness = 1
    s.Parent = c
    local ll = Instance.new("UIListLayout", c)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return c
end

local function makeRow(card, order, isLast, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height or 46)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 4
    row.Parent = card
    if not isLast then
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1, -28, 0, 1)
        sep.Position = UDim2.new(0, 14, 1, -1)
        sep.BackgroundColor3 = T.sep
        sep.BorderSizePixel = 0
        sep.ZIndex = 4
        sep.Parent = row
    end
    return row
end

local function makeSection(parent, labelText, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.ZIndex = 3
    f.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 8
    lbl.TextColor3 = T.accent
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.ZIndex = 3
    lbl.Parent = f
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 28, 0, 2)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = T.accent
    line.BorderSizePixel = 0
    line.ZIndex = 3
    line.Parent = f
    Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
    return f
end

local function makeToggleRow(card, order, labelText, initialState, isLast, onToggle)
    local row = makeRow(card, order, isLast, 44)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.65, 0, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.Text = labelText
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 10
    l.TextColor3 = T.text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.ZIndex = 5
    l.Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -52, 0.5, -10)
    track.BackgroundColor3 = initialState and T.accent or T.dim
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.Text = ""
    track.ZIndex = 5
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = initialState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = initialState
    track.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, tw(0.15), {BackgroundColor3 = state and T.accent or T.dim}):Play()
        TweenService:Create(knob, tw(0.15), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        onToggle(state)
    end)
    return row
end

local function makeButtonRow(card, order, labelText, buttonText, isLast, onClick)
    local row = makeRow(card, order, isLast, 46)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.Text = labelText
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 10
    l.TextColor3 = T.text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.ZIndex = 5
    l.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 28)
    btn.Position = UDim2.new(1, -114, 0.5, -14)
    btn.Text = buttonText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = T.accent
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function() TweenService:Create(btn, tw(), {BackgroundColor3 = T.accentLt}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, tw(), {BackgroundColor3 = T.accent}):Play() end)
    btn.MouseButton1Click:Connect(onClick)
    return row
end

local function makeSliderRow(card, order, labelText, min, max, initial, isLast, onChanged)
    local row = makeRow(card, order, isLast, 54)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 0, 20)
    l.Position = UDim2.new(0, 16, 0, 8)
    l.Text = labelText
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 10
    l.TextColor3 = T.text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.ZIndex = 5
    l.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 30, 0, 20)
    valueLabel.Position = UDim2.new(1, -42, 0, 8)
    valueLabel.Text = tostring(initial)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 9
    valueLabel.TextColor3 = T.accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.ZIndex = 5
    valueLabel.Parent = row

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -32, 0, 6)
    sliderTrack.Position = UDim2.new(0, 16, 0, 36)
    sliderTrack.BackgroundColor3 = T.dim
    sliderTrack.BorderSizePixel = 0
    sliderTrack.ZIndex = 5
    sliderTrack.Parent = row
    Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((initial - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = T.accent
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 6
    sliderFill.Parent = sliderTrack
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliderKnob = Instance.new("TextButton")
    sliderKnob.Size = UDim2.new(0, 14, 0, 14)
    sliderKnob.Position = UDim2.new((initial - min) / (max - min), -7, 0.5, -7)
    sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.AutoButtonColor = false
    sliderKnob.Text = ""
    sliderKnob.ZIndex = 7
    sliderKnob.Parent = sliderTrack
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos = sliderTrack.AbsolutePosition
            local absSize = sliderTrack.AbsoluteSize
            local ratio = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
            local value = math.floor(min + ratio * (max - min))
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            sliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
            onChanged(value)
        end
    end)

    return row
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FeatherHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() gui.Parent = CoreGui end) then
    gui.Parent = Player:WaitForChild("PlayerGui")
end

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 480, 0, 360)
win.Position = UDim2.new(0, 100, 0, 100)
win.BackgroundColor3 = T.bg
win.BackgroundTransparency = 0.1
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.ZIndex = 2
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)

local winStroke = Instance.new("UIStroke")
winStroke.Color = T.accent
winStroke.Thickness = 1
winStroke.Parent = win

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = T.bg
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 4
titleBar.Parent = win

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 16, 0, 0)
titleText.Text = "Feather Hub"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextColor3 = T.accent
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 4)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = T.text
closeBtn.BackgroundColor3 = T.dim
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 5
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

-- Dragging logic
local dragToggle = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = win.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end)

-- Tab buttons (horizontal)
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -28, 0, 40)
tabBar.Position = UDim2.new(0, 14, 0, 48)
tabBar.BackgroundColor3 = T.card
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 3
tabBar.Parent = win
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 9)
local tabLL = Instance.new("UIListLayout", tabBar)
tabLL.FillDirection = Enum.FillDirection.Horizontal
tabLL.VerticalAlignment = Enum.VerticalAlignment.Center
tabLL.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLL.Padding = UDim.new(0, 8)

local pages = {}
local tabButtons = {}
local activeTabIndex = 1

local function switchTab(index)
    for i, page in ipairs(pages) do
        page.Visible = (i == index)
    end
    for i, btn in ipairs(tabButtons) do
        local on = (i == index)
        TweenService:Create(btn, tw(0.15), {
            BackgroundColor3 = on and T.accent or T.dim,
            TextColor3 = on and Color3.new(1, 1, 1) or T.text
        }):Play()
    end
    activeTabIndex = index
end

local tabNames = {"Main", "ESP", "Keybinds", "Locations"}
for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 0, 30)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = i == 1 and T.accent or T.dim
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = i == 1 and Color3.new(1, 1, 1) or T.text
    btn.ZIndex = 4
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 14)
    Instance.new("UIPadding", btn).PaddingRight = UDim.new(0, 14)

    local index = i
    btn.MouseButton1Click:Connect(function() switchTab(index) end)
    table.insert(tabButtons, btn)

    -- create page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -16, 1, -104)
    page.Position = UDim2.new(0, 8, 0, 96)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = T.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.Visible = (i == 1)
    page.ZIndex = 2
    page.Parent = win
    local list = Instance.new("UIListLayout", page)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Padding = UDim.new(0, 8)
    table.insert(pages, page)
end

-- ============================================================
-- UTILITY: NOTIFICATION
-- ============================================================
local function notify(title, msg, level)
    local color = level == "error" and T.red or level == "warning" and Color3.fromRGB(255, 180, 0) or T.accent
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 240, 0, 52)
    notif.Position = UDim2.new(1, -260, 0, 100)
    notif.BackgroundColor3 = T.card
    notif.BorderSizePixel = 0
    notif.ZIndex = 20
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 1.5
    s.Parent = notif
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -16, 0, 22)
    t.Position = UDim2.new(0, 8, 0, 6)
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 11
    t.TextColor3 = color
    t.BackgroundTransparency = 1
    t.Parent = notif
    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, -16, 0, 18)
    m.Position = UDim2.new(0, 8, 0, 28)
    m.Text = msg
    m.Font = Enum.Font.Gotham
    m.TextSize = 9
    m.TextColor3 = T.text
    m.BackgroundTransparency = 1
    m.Parent = notif
    task.spawn(function()
        for i = 1, 30 do
            if not notif.Parent then break end
            task.wait(0.1)
        end
        if notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.4), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.4)
            notif:Destroy()
        end
    end)
end

-- ============================================================
-- MAIN TAB FEATURES
-- ============================================================
local mainPage = pages[1]
makeSection(mainPage, "FEATURES", 1)
local featCard = makeCard(mainPage, 2)

makeButtonRow(featCard, 1, "3rd person & shift lock", "Enable", false, function()
    local LocalPlayer = Player
    local UIS = UserInputService
    local RS = RunService
    local iconId = "rbxassetid://6522857905"

    if _G.__RakeMouseConn then _G.__RakeMouseConn:Disconnect() end
    if _G.__RakeCameraConn then _G.__RakeCameraConn:Disconnect() end

    _G.__RakeMouseConn = RS.RenderStepped:Connect(function()
        UIS.MouseIconEnabled = true
        if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
            if UIS.MouseIcon ~= "" then UIS.MouseIcon = "" end
        elseif UIS.MouseIcon ~= iconId then
            UIS.MouseIcon = iconId
        end
    end)
    _G.__RakeCameraConn = RS.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if char then char = char:FindFirstChildOfClass("Humanoid") end
        if char then
            if char.Health >= 100 then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                LocalPlayer.CameraMinZoomDistance = 0.5
                LocalPlayer.CameraMaxZoomDistance = 15
            else
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                LocalPlayer.CameraMinZoomDistance = 8
                LocalPlayer.CameraMaxZoomDistance = 15
            end
        end
        pcall(function()
            LocalPlayer.DevEnableMouseLock = true
            LocalPlayer.DevComputerCameraMode = Enum.DevComputerCameraMovementMode.Classic
        end)
    end)
    notify("Camera", "3rd person & shift lock armed", "success")
end)

makeToggleRow(featCard, 2, "FullBright", false, false, function(on)
    if on then
        _G.LightingToggleEnabled = true
        local Lighting = game:GetService("Lighting")
        local function apply()
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 1
            Lighting.FogEnd = 10000000000
            for _, v in ipairs(Lighting:GetDescendants()) do
                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end
        end
        apply()
        Lighting.Changed:Connect(function()
            if _G.LightingToggleEnabled then apply() end
        end)
        spawn(function()
            while _G.LightingToggleEnabled do
                local char = Player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    if not hrp:FindFirstChildWhichIsA("PointLight") then
                        local pl = Instance.new("PointLight")
                        pl.Name = "HeadLight"
                        pl.Brightness = 1
                        pl.Range = 60
                        pl.Parent = hrp
                    end
                end
                task.wait(1)
            end
        end)
    else
        _G.LightingToggleEnabled = false
        local Lighting = game:GetService("Lighting")
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 2
        Lighting.FogEnd = 1000
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = true
            end
        end
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, v in ipairs(char.HumanoidRootPart:GetChildren()) do
                if v:IsA("PointLight") and v.Name == "HeadLight" then
                    v:Destroy()
                end
            end
        end
    end
end)

makeToggleRow(featCard, 3, "NoClip (glitchy)", false, false, function(on)
    local char = Player.Character
    while not char do task.wait(); char = Player.Character end
    local hum = char:WaitForChild("Humanoid")
    if on then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    else
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end)

local wsValue = 30
makeSliderRow(featCard, 4, "WalkSpeed", 30, 0, 30, false, function(v)
    wsValue = v
end)
RunService.RenderStepped:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if hum.WalkSpeed < wsValue then hum.WalkSpeed = wsValue end
    end
end)

makeToggleRow(featCard, 5, "Power Level GUI", false, false, function(on)
    if on then
        local sg = Instance.new("ScreenGui")
        sg.Name = "PowerGUI"
        sg.Parent = Player:WaitForChild("PlayerGui")
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 120, 0, 40)
        frame.Position = UDim2.new(0.5, -60, 0.12, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BackgroundTransparency = 0.15
        frame.Active = true
        frame.Draggable = true
        frame.Parent = sg
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Power: --%"
        lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 28
        lbl.Parent = frame

        local function findPowerLevel()
            local rs = game:GetService("ReplicatedStorage")
            for _, v in ipairs(rs:GetDescendants()) do
                if v.Name == "PowerLevel" and v.Value ~= nil then
                    return v
                end
            end
        end

        local powerRef = findPowerLevel()
        RunService.RenderStepped:Connect(function()
            if not powerRef then powerRef = findPowerLevel() end
            if powerRef and powerRef.Value ~= nil then
                local pct = math.floor(powerRef.Value / 1000 * 100 + 0.5)
                lbl.Text = "Power: " .. tostring(pct) .. "%"
            else
                lbl.Text = "Power: --%"
            end
        end)
        _G.PowerGUI = sg
    else
        local gui = Player.PlayerGui:FindFirstChild("PowerGUI")
        if gui then gui:Destroy() end
    end
end)

makeToggleRow(featCard, 6, "Night / Timer Display", false, false, function(on)
    if on then
        local sg = Instance.new("ScreenGui")
        sg.Name = "NightTimerGUI"
        sg.Parent = Player:WaitForChild("PlayerGui")
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 220, 0, 40)
        frame.Position = UDim2.new(0.5, -110, 0.18, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BackgroundTransparency = 0.15
        frame.Active = true
        frame.Draggable = true
        frame.Parent = sg
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Loading..."
        lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 22
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.Parent = frame

        local function findValue(name)
            local rs = game:GetService("ReplicatedStorage")
            for _, v in ipairs(rs:GetDescendants()) do
                if v.Name == name and v.Value ~= nil then return v end
            end
        end

        local nightVal = findValue("Night")
        local timerVal = findValue("Timer")
        local conn = RunService.RenderStepped:Connect(function()
            if not nightVal then nightVal = findValue("Night") end
            if not timerVal then timerVal = findValue("Timer") end
            local timerStr = (timerVal and timerVal.Value ~= nil) and tostring(timerVal.Value) or "--"
            if nightVal and nightVal.Value ~= nil then
                lbl.Text = nightVal.Value and ("Time until day: " .. timerStr) or ("Time until night: " .. timerStr)
            else
                lbl.Text = "Night/Timer not found"
            end
        end)
        sg.AncestryChanged:Connect(function(_, parent)
            if not parent then conn:Disconnect() end
        end)
    else
        local gui = Player.PlayerGui:FindFirstChild("NightTimerGUI")
        if gui then gui:Destroy() end
    end
end)

makeButtonRow(featCard, 7, "Chat Logger", "Open", true, function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/v-oidd/chat-tracker/main/chat-tracker.lua"))()
    end)
    notify("Chat Logger", "Loaded", "success")
end)

-- ============================================================
-- ESP TAB
-- ============================================================
local espPage = pages[2]
makeSection(espPage, "ESP TOGGLES", 1)
local espCard = makeCard(espPage, 2)

-- Scrap ESP
makeToggleRow(espCard, 1, "Scrap ESP", false, false, function(on)
    if on then
        local maxDist = 800
        local labelSize = Vector2.new(60, 20)
        local minAlpha = 0.3
        local labels = {}
        local highlights = {}

        local function addESP(model)
            local part = nil
            for _, v in ipairs(model:GetChildren()) do
                if v:IsA("BasePart") then part = v; break end
            end
            if not part then return end
            if not part:FindFirstChild("ScrapLabel") then
                local bg = Instance.new("BillboardGui")
                bg.Name = "ScrapLabel"
                bg.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                bg.StudsOffset = Vector3.new(0, 3, 0)
                bg.Adornee = part
                bg.AlwaysOnTop = true
                bg.MaxDistance = maxDist
                bg.Parent = part
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = "Scrap"
                tl.TextColor3 = Color3.fromRGB(255, 255, 0)
                tl.TextStrokeColor3 = Color3.new(0, 0, 0)
                tl.TextStrokeTransparency = 0
                tl.TextScaled = true
                tl.Font = Enum.Font.SourceSansBold
                tl.Parent = bg
                table.insert(labels, { gui = bg, part = part })
            end
            if not model:FindFirstChild("ScrapHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "ScrapHighlight"
                hl.Adornee = model
                hl.FillColor = Color3.fromRGB(255, 255, 0)
                hl.OutlineColor = Color3.new(0, 0, 0)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = model
                table.insert(highlights, hl)
            end
        end

        for _, model in ipairs(game:GetDescendants()) do
            if model:IsA("Model") and model.Name:lower():find("scrap") then
                addESP(model)
            end
        end

        local descendantConn = game.DescendantAdded:Connect(function(inst)
            if inst:IsA("Model") and inst.Name:lower():find("scrap") then
                task.wait(0.1)
                addESP(inst)
            end
        end)

        local renderConn = RunService.RenderStepped:Connect(function()
            local char = Player.Character
            if char then char = char:FindFirstChild("HumanoidRootPart") end
            if char then
                for _, entry in ipairs(labels) do
                    if entry.part and entry.gui then
                        local dist = (char.Position - entry.part.Position).Magnitude
                        if dist > maxDist then
                            entry.gui.Size = UDim2.new(0, 0, 0, 0)
                        else
                            local scale = math.clamp(1 - dist / maxDist, minAlpha, 1)
                            entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                        end
                    end
                end
            end
        end)

        _G.ScrapESP = { conns = {descendantConn, renderConn}, list = labels, hls = highlights }
    else
        if _G.ScrapESP then
            for _, conn in ipairs(_G.ScrapESP.conns) do conn:Disconnect() end
            for _, entry in ipairs(_G.ScrapESP.list) do
                if entry.gui.Parent then entry.gui:Destroy() end
            end
            for _, hl in ipairs(_G.ScrapESP.hls) do
                if hl.Parent then hl:Destroy() end
            end
            _G.ScrapESP = nil
        end
        -- Also destroy any leftover
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Model") then
                local hl = v:FindFirstChild("ScrapHighlight")
                if hl then hl:Destroy() end
                for _, p in ipairs(v:GetChildren()) do
                    if p:IsA("BasePart") and p:FindFirstChild("ScrapLabel") then
                        p.ScrapLabel:Destroy()
                    end
                end
            end
        end
    end
end)

-- Flare Gun ESP
makeToggleRow(espCard, 2, "Flare Gun ESP", false, false, function(on)
    if on then
        local maxDist = 800
        local labelSize = Vector2.new(60, 20)
        local minAlpha = 0.3
        local labels = {}
        local highlights = {}

        local function isFlareGun(model)
            local name = model.Name:lower()
            return name:find("flaregun") and not name:find("clue")
        end

        local function addESP(model)
            local part = model:FindFirstChildWhichIsA("BasePart")
            if not part then return end
            if not part:FindFirstChild("ItemLabel") then
                local bg = Instance.new("BillboardGui")
                bg.Name = "ItemLabel"
                bg.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                bg.StudsOffset = Vector3.new(0, 3, 0)
                bg.Adornee = part
                bg.AlwaysOnTop = true
                bg.MaxDistance = maxDist
                bg.Parent = part
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = "FlareGun"
                tl.TextColor3 = Color3.fromRGB(255, 100, 100)
                tl.TextStrokeColor3 = Color3.new(0, 0, 0)
                tl.TextStrokeTransparency = 0
                tl.TextScaled = true
                tl.Font = Enum.Font.SourceSansBold
                tl.Parent = bg
                table.insert(labels, { gui = bg, part = part })
            end
            if not model:FindFirstChildOfClass("Highlight") then
                local hl = Instance.new("Highlight")
                hl.Adornee = model
                hl.FillColor = Color3.fromRGB(255, 100, 100)
                hl.OutlineColor = Color3.new(0, 0, 0)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = model
                table.insert(highlights, hl)
            end
        end

        for _, model in ipairs(game:GetDescendants()) do
            if model:IsA("Model") and isFlareGun(model) then
                addESP(model)
            end
        end

        local descConn = game.DescendantAdded:Connect(function(inst)
            if inst:IsA("Model") and isFlareGun(inst) then
                task.wait(0.1)
                addESP(inst)
            end
        end)

        local renderConn = RunService.RenderStepped:Connect(function()
            local char = Player.Character
            if char then char = char:FindFirstChild("HumanoidRootPart") end
            if char then
                for _, entry in ipairs(labels) do
                    if entry.part and entry.gui then
                        local dist = (char.Position - entry.part.Position).Magnitude
                        entry.gui.Enabled = true
                        if dist > maxDist then
                            entry.gui.Size = UDim2.new(0, 0, 0, 0)
                        else
                            local scale = math.clamp(1 - dist / maxDist, minAlpha, 1)
                            entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                        end
                    end
                end
                for _, hl in ipairs(highlights) do hl.Enabled = true end
            end
        end)

        _G.FlareGunESP = { conns = {descConn, renderConn}, list = labels, hls = highlights }
    else
        if _G.FlareGunESP then
            for _, conn in ipairs(_G.FlareGunESP.conns) do conn:Disconnect() end
            for _, entry in ipairs(_G.FlareGunESP.list) do
                if entry.gui.Parent then entry.gui:Destroy() end
            end
            for _, hl in ipairs(_G.FlareGunESP.hls) do
                if hl.Parent then hl:Destroy() end
            end
            _G.FlareGunESP = nil
        end
    end
end)

-- Supply Crate ESP
makeToggleRow(espCard, 3, "Supply Crate ESP", false, false, function(on)
    if on then
        local maxDist = 1000
        local labelSize = Vector2.new(120, 40)
        local minAlpha = 0.3
        local entries = {}

        local function addESP(model)
            local part = nil
            for _, v in ipairs(model:GetChildren()) do
                if v:IsA("BasePart") then part = v; break end
            end
            if not part then return end
            if not part:FindFirstChild("SupplyCrateLabel") then
                local bg = Instance.new("BillboardGui")
                bg.Name = "SupplyCrateLabel"
                bg.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                bg.StudsOffset = Vector3.new(0, 4, 0)
                bg.Adornee = part
                bg.AlwaysOnTop = true
                bg.Parent = part
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 0.3
                tl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                tl.Text = "Supply Crate"
                tl.TextColor3 = Color3.fromRGB(0, 255, 255)
                tl.TextStrokeColor3 = Color3.new(0, 0, 0)
                tl.TextStrokeTransparency = 0
                tl.TextScaled = true
                tl.Font = Enum.Font.SourceSansBold
                tl.Parent = bg
                table.insert(entries, { gui = bg, part = part })
            end
            if not model:FindFirstChildOfClass("Highlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "SupplyCrateHighlight"
                hl.Adornee = model
                hl.FillColor = Color3.fromRGB(0, 255, 255)
                hl.OutlineColor = Color3.new(0, 0, 0)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = model
            end
        end

        for _, model in ipairs(game:GetDescendants()) do
            if model:IsA("Model") and model.Name:lower():find("supplycrate") then
                addESP(model)
            end
        end

        local descConn = game.DescendantAdded:Connect(function(inst)
            if inst:IsA("Model") and inst.Name:lower():find("supplycrate") then
                task.wait(0.1)
                addESP(inst)
            end
        end)

        local renderConn = RunService.RenderStepped:Connect(function()
            local char = Player.Character
            if char then char = char:FindFirstChild("HumanoidRootPart") end
            if char then
                for i = #entries, 1, -1 do
                    local entry = entries[i]
                    if entry.part and entry.gui then
                        local dist = (char.Position - entry.part.Position).Magnitude
                        if dist > maxDist then
                            entry.gui.Size = UDim2.new(0, 0, 0, 0)
                        else
                            local scale = math.clamp(1 - dist / maxDist, minAlpha, 1)
                            entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                        end
                    else
                        table.remove(entries, i)
                    end
                end
            end
        end)

        _G.SupplyCrateESP = { conns = {descConn, renderConn}, list = entries }
    else
        if _G.SupplyCrateESP then
            for _, conn in ipairs(_G.SupplyCrateESP.conns) do conn:Disconnect() end
            for _, entry in ipairs(_G.SupplyCrateESP.list) do
                if entry.gui.Parent then entry.gui:Destroy() end
                if entry.part and entry.part.Parent then
                    local hl = entry.part.Parent:FindFirstChildOfClass("Highlight")
                    if hl and hl.Name == "SupplyCrateHighlight" then hl:Destroy() end
                end
            end
            _G.SupplyCrateESP = nil
        end
    end
end)

-- Rake ESP
makeToggleRow(espCard, 4, "Rake ESP", false, false, function(on)
    if on then
        local function addHighlight(rake)
            if rake and not rake:FindFirstChild("RakeESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "RakeESP"
                hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                hl.FillColor = Color3.fromRGB(255, 100, 100)
                hl.FillTransparency = 0.7
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = rake
                hl.Parent = rake
            end
        end

        local rake = workspace:FindFirstChild("Rake")
        if rake then addHighlight(rake) end
        local wsConn = workspace.ChildAdded:Connect(function(child)
            if child.Name == "Rake" then task.wait(0.2); addHighlight(child) end
        end)
        _G.RakeESPConn = wsConn
    else
        if _G.RakeESPConn then _G.RakeESPConn:Disconnect(); _G.RakeESPConn = nil end
        local rake = workspace:FindFirstChild("Rake")
        if rake then
            local hl = rake:FindFirstChild("RakeESP")
            if hl then hl:Destroy() end
        end
    end
end)

-- Player ESP
makeToggleRow(espCard, 5, "Player ESP", false, true, function(on)
    if on then
        local maxDist = 800
        local labelSize = Vector2.new(80, 20)
        local minAlpha = 0.375
        local labels = {}
        local highlights = {}
        local playerConns = {}

        local function addPlayer(player)
            if player == Player then return end
            local function onChar(char)
                local head = char:WaitForChild("Head", 3)
                if not head then return end
                if not head:FindFirstChild("PlayerESPLabel") then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "PlayerESPLabel"
                    bg.Size = UDim2.new(0, labelSize.X, 0, labelSize.Y)
                    bg.StudsOffset = Vector3.new(0, 3, 0)
                    bg.Adornee = head
                    bg.AlwaysOnTop = true
                    bg.MaxDistance = maxDist
                    bg.Parent = head
                    local tl = Instance.new("TextLabel")
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.Text = player.Name
                    tl.TextColor3 = Color3.new(1, 1, 1)
                    tl.TextStrokeColor3 = Color3.new(0, 0, 0)
                    tl.TextStrokeTransparency = 0
                    tl.TextScaled = true
                    tl.Font = Enum.Font.SourceSansBold
                    tl.Parent = bg
                    table.insert(labels, { gui = bg, part = head })
                end
                if not char:FindFirstChild("PlayerESPHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "PlayerESPHighlight"
                    hl.Adornee = char
                    hl.FillTransparency = 1
                    hl.OutlineTransparency = 0
                    hl.OutlineColor = T.accent
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                    table.insert(highlights, hl)
                end
            end
            if player.Character then onChar(player.Character) end
            table.insert(playerConns, player.CharacterAdded:Connect(onChar))
            table.insert(playerConns, player.CharacterRemoving:Connect(function(_)
                -- labels and highlights will be cleaned up later
            end))
        end

        for _, p in ipairs(Players:GetPlayers()) do addPlayer(p) end
        table.insert(playerConns, Players.PlayerAdded:Connect(addPlayer))
        local renderConn = RunService.RenderStepped:Connect(function()
            local char = Player.Character
            if char then char = char:FindFirstChild("HumanoidRootPart") end
            if char then
                for _, entry in ipairs(labels) do
                    if entry.part and entry.gui then
                        local dist = (char.Position - entry.part.Position).Magnitude
                        if dist > maxDist then
                            entry.gui.Size = UDim2.new(0, 0, 0, 0)
                        else
                            local scale = math.clamp(1 - dist / maxDist, minAlpha, 1)
                            entry.gui.Size = UDim2.new(0, labelSize.X * scale, 0, labelSize.Y * scale)
                        end
                    end
                end
            end
        end)

        _G.PlayerESP = { conns = {renderConn, unpack(playerConns)}, labels = labels, highlights = highlights }
    else
        if _G.PlayerESP then
            for _, conn in ipairs(_G.PlayerESP.conns) do conn:Disconnect() end
            for _, label in ipairs(_G.PlayerESP.labels) do
                if label.gui.Parent then label.gui:Destroy() end
            end
            for _, hl in ipairs(_G.PlayerESP.highlights) do
                if hl.Parent then hl:Destroy() end
            end
            _G.PlayerESP = nil
        end
    end
end)

-- ============================================================
-- KEYBINDS TAB
-- ============================================================
local kbPage = pages[3]
makeSection(kbPage, "GENERAL", 1)
local kbCard1 = makeCard(kbPage, 2)

-- Toggle UI keybind
local function createKeybindButton(card, order, label, defaultKey, callback)
    local row = makeRow(card, order, false, 44)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.Text = label
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 10
    l.TextColor3 = T.text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.ZIndex = 5
    l.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 28)
    btn.Position = UDim2.new(1, -104, 0.5, -14)
    btn.Text = defaultKey or "None"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = T.text
    btn.BackgroundColor3 = T.inputBg
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke")
    stroke.Color = T.border
    stroke.Thickness = 1
    stroke.Parent = btn

    local waiting = false
    btn.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        btn.Text = "..."
        TweenService:Create(stroke, tw(), {Color = T.accent, Thickness = 1.5}):Play()
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                conn:Disconnect()
                waiting = false
                btn.Text = input.KeyCode.Name
                TweenService:Create(stroke, tw(), {Color = T.border, Thickness = 1}):Play()
                callback(input.KeyCode)
            end
        end)
    end)
    return btn
end

createKeybindButton(kbCard1, 1, "Toggle UI", "Q", function(key)
    -- We use UserInputService to toggle gui.Enabled
    _G.ToggleUIKey = key
end)

-- Now the actual toggle logic
_G.ToggleUIKey = Enum.KeyCode.Q  -- default
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == _G.ToggleUIKey then
            gui.Enabled = not gui.Enabled
        end
    end
end)

makeSection(kbPage, "RISKY REMOTES", 3)
local riskCard = makeCard(kbPage, 4)

local function remoteAction(cooldownVarName, teleportCF, remotePath, arg)
    if _G[cooldownVarName] then return end
    _G[cooldownVarName] = true
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        _G[cooldownVarName] = false
        return
    end
    local root = char.HumanoidRootPart
    local oldCF = root.CFrame
    root.CFrame = teleportCF
    task.wait(0.25)
    pcall(function()
        local args = remotePath:split(".")
        local obj = workspace
        for i = 1, #args - 1 do obj = obj[args[i]] end
        obj[args[#args]]:FireServer(arg)
    end)
    task.wait(0.15)
    root.CFrame = oldCF
    task.wait(2.5)
    _G[cooldownVarName] = false
end

makeButtonRow(riskCard, 1, "SafeHouse Door (anywhere)", "F", false, function()
    remoteAction("SafeDoorCooldown", CFrame.new(-365.13, 15.72, 65.05), "Map.SafeHouse.Door.RemoteEvent", "Door")
end)
makeButtonRow(riskCard, 2, "SafeHouse Light (anywhere)", "G", false, function()
    remoteAction("SafeLightCooldown", CFrame.new(-371.1, 15.68, 57.85), "Map.SafeHouse.Door.RemoteEvent", "Light")
end)
makeButtonRow(riskCard, 3, "Tower Light (anywhere)", "L", true, function()
    remoteAction("TowerLightCooldown", CFrame.new(42.63, 57.82, -50.22), "Map.ObservationTower.Lights.RemoteEvent", "Light")
end)

makeSection(kbPage, "SAFE REMOTES", 5)
local safeCard = makeCard(kbPage, 6)

makeButtonRow(safeCard, 1, "SafeHouse Door (close)", "X", false, function()
    workspace.Map.SafeHouse.Door.RemoteEvent:FireServer("Door")
end)
makeButtonRow(safeCard, 2, "SafeHouse Light (close)", "C", false, function()
    workspace.Map.SafeHouse.Door.RemoteEvent:FireServer("Light")
end)
makeButtonRow(safeCard, 3, "Tower Light (close)", "V", true, function()
    workspace.Map.ObservationTower.Lights.RemoteEvent:FireServer("Light")
end)

-- ============================================================
-- SHOW LOCATIONS TAB
-- ============================================================
local locPage = pages[4]
makeSection(locPage, "LOCATION MARKERS", 1)
local locCard = makeCard(locPage, 2)

local function locationToggle(label, locationName, offset, partPath)
    makeToggleRow(locCard, 0, label, false, false, function(on)
        local mapPart = workspace:FindFirstChild(partPath)
        if not mapPart then
            notify("Location", label .. " not found", "warning")
            return
        end
        local basePart = mapPart:FindFirstChildWhichIsA("BasePart") or mapPart:FindFirstChild("Main") or mapPart:FindFirstChildOfClass("Part")
        if not basePart then
            notify("Location", "No suitable part", "warning")
            return
        end
        local markerName = locationName .. "Marker"
        if on then
            if not basePart:FindFirstChild(markerName) then
                local bg = Instance.new("BillboardGui")
                bg.Name = markerName
                bg.Size = UDim2.new(0, 120, 0, 40)
                bg.StudsOffset = Vector3.new(0, (offset or 30), 0)
                bg.Adornee = basePart
                bg.AlwaysOnTop = true
                bg.Parent = basePart
                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 0.3
                tl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                tl.Text = locationName
                tl.TextColor3 = T.accent
                tl.TextStrokeColor3 = Color3.new(0, 0, 0)
                tl.TextStrokeTransparency = 0
                tl.TextScaled = true
                tl.Font = Enum.Font.SourceSansBold
                tl.Parent = bg
                Instance.new("UICorner", tl).CornerRadius = UDim.new(0, 12)
            end
        else
            local existing = basePart:FindFirstChild(markerName)
            if existing then existing:Destroy() end
        end
    end)
end

locationToggle("SafeHouse", "SafeHouse", 30, "Map.SafeHouse")
locationToggle("Observation Tower", "Tower", 50, "Map.ObservationTower")
locationToggle("Shop (Shack)", "Shop", 20, "Map.Shack")
locationToggle("BaseCamp", "BaseCamp", 30, "Map.BaseCamp")

-- Power Station (using a custom anchored part because location may not exist)
makeToggleRow(locCard, 5, "Power Station", false, false, function(on)
    local pos = Vector3.new(-281.82, 20, -211.18)
    local markerPartName = "PowerLocationMarker"
    if on then
        local markerPart = workspace:FindFirstChild(markerPartName)
        if not markerPart then
            markerPart = Instance.new("Part")
            markerPart.Name = markerPartName
            markerPart.Anchored = true
            markerPart.CanCollide = false
            markerPart.Size = Vector3.new(2, 2, 2)
            markerPart.Position = pos
            markerPart.Transparency = 1
            markerPart.Parent = workspace
            local bg = Instance.new("BillboardGui")
            bg.Name = "PowerBillboard"
            bg.Size = UDim2.new(0, 120, 0, 40)
            bg.StudsOffset = Vector3.new(0, 30, 0)
            bg.Adornee = markerPart
            bg.AlwaysOnTop = true
            bg.Parent = markerPart
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 0.3
            tl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            tl.Text = "Power"
            tl.TextColor3 = T.accent
            tl.TextStrokeColor3 = Color3.new(0, 0, 0)
            tl.TextStrokeTransparency = 0
            tl.TextScaled = true
            tl.Font = Enum.Font.SourceSansBold
            tl.Parent = bg
            Instance.new("UICorner", tl).CornerRadius = UDim.new(0, 12)
        end
    else
        local markerPart = workspace:FindFirstChild(markerPartName)
        if markerPart then markerPart:Destroy() end
    end
end)

-- Cave (similar)
makeToggleRow(locCard, 6, "Cave", false, true, function(on)
    local pos = Vector3.new(-149.67, 26.13, 36.42)
    local markerPartName = "CaveLocationMarker"
    if on then
        local markerPart = workspace:FindFirstChild(markerPartName)
        if not markerPart then
            markerPart = Instance.new("Part")
            markerPart.Name = markerPartName
            markerPart.Anchored = true
            markerPart.CanCollide = false
            markerPart.Size = Vector3.new(2, 2, 2)
            markerPart.Position = pos
            markerPart.Transparency = 1
            markerPart.Parent = workspace
            local bg = Instance.new("BillboardGui")
            bg.Name = "CaveBillboard"
            bg.Size = UDim2.new(0, 120, 0, 40)
            bg.StudsOffset = Vector3.new(0, 30, 0)
            bg.Adornee = markerPart
            bg.AlwaysOnTop = true
            bg.Parent = markerPart
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 0.3
            tl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            tl.Text = "Cave"
            tl.TextColor3 = T.accent
            tl.TextStrokeColor3 = Color3.new(0, 0, 0)
            tl.TextStrokeTransparency = 0
            tl.TextScaled = true
            tl.Font = Enum.Font.SourceSansBold
            tl.Parent = bg
            Instance.new("UICorner", tl).CornerRadius = UDim.new(0, 12)
        end
    else
        local markerPart = workspace:FindFirstChild(markerPartName)
        if markerPart then markerPart:Destroy() end
    end
end)

-- ============================================================
-- STARTUP
-- ============================================================
switchTab(1)
notify("Feather Hub", "Rake Remastered loaded. Press Q to toggle UI.", "success")

-- Allow re‑execution on teleport
if syn and syn.queue_on_teleport then
    syn.queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/YourRepo/.../featherhub.lua'))()")
elseif queue_on_teleport then
    queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/YourRepo/.../featherhub.lua'))()")
end
