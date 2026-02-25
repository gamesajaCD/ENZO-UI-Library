--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ENZO UI LIBRARY                           ║
    ║              Design G: Aurora Ethereal                       ║
    ║                   Version: 1.0.0                             ║
    ║                  Author: ENZO-YT                             ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  Style: Floating Cards + Aurora Gradients + Neumorphism      ║
    ║  Layout: Horizontal Tabs + Dual Column Content               ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║  - Aurora animated gradients                                 ║
    ║  - Floating card sections                                    ║
    ║  - Pill-style horizontal tabs                                ║
    ║  - Neumorphism toggle & buttons                              ║
    ║  - Particle background effect                                ║
    ║  - Custom logo support                                       ║
    ║  - Fixed mobile button position                              ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local EnzoLib = {}

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- SAFE CLEANUP
-- ============================================
if getgenv then
    if getgenv().EnzoUILib then
        pcall(function() 
            getgenv().EnzoUILib:Destroy() 
        end)
    end
end

pcall(function()
    for _, v in pairs(Lighting:GetChildren()) do
        if v.Name:find("Enzo") then v:Destroy() end
    end
end)

pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("EnzoUI") then v:Destroy() end
    end
end)

-- ============================================
-- THEMES - Aurora Color Palettes
-- ============================================
local Themes = {
    Aurora = {
        Name = "Aurora",
        Primary = Color3.fromRGB(120, 80, 255),
        Secondary = Color3.fromRGB(80, 200, 255),
        Tertiary = Color3.fromRGB(255, 100, 200),
        Accent = Color3.fromRGB(100, 255, 180),
    },
    Sunset = {
        Name = "Sunset",
        Primary = Color3.fromRGB(255, 100, 80),
        Secondary = Color3.fromRGB(255, 180, 50),
        Tertiary = Color3.fromRGB(255, 50, 100),
        Accent = Color3.fromRGB(255, 220, 100),
    },
    Ocean = {
        Name = "Ocean",
        Primary = Color3.fromRGB(30, 144, 255),
        Secondary = Color3.fromRGB(0, 255, 200),
        Tertiary = Color3.fromRGB(100, 149, 237),
        Accent = Color3.fromRGB(64, 224, 208),
    },
    Forest = {
        Name = "Forest",
        Primary = Color3.fromRGB(50, 205, 50),
        Secondary = Color3.fromRGB(144, 238, 144),
        Tertiary = Color3.fromRGB(34, 139, 34),
        Accent = Color3.fromRGB(124, 252, 0),
    },
    Sakura = {
        Name = "Sakura",
        Primary = Color3.fromRGB(255, 182, 193),
        Secondary = Color3.fromRGB(255, 105, 180),
        Tertiary = Color3.fromRGB(255, 192, 203),
        Accent = Color3.fromRGB(255, 20, 147),
    },
    Midnight = {
        Name = "Midnight",
        Primary = Color3.fromRGB(75, 0, 130),
        Secondary = Color3.fromRGB(138, 43, 226),
        Tertiary = Color3.fromRGB(72, 61, 139),
        Accent = Color3.fromRGB(147, 112, 219),
    },
}

local CurrentTheme = Themes.Aurora

-- ============================================
-- BASE COLORS
-- ============================================
local Colors = {
    -- Backgrounds
    Background = Color3.fromRGB(15, 15, 25),
    BackgroundDark = Color3.fromRGB(10, 10, 18),
    BackgroundLight = Color3.fromRGB(25, 25, 40),
    
    -- Cards
    Card = Color3.fromRGB(22, 22, 35),
    CardHover = Color3.fromRGB(30, 30, 45),
    CardBorder = Color3.fromRGB(45, 45, 65),
    
    -- Text
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 150),
    TextDark = Color3.fromRGB(80, 80, 110),
    
    -- Status
    Success = Color3.fromRGB(80, 250, 150),
    Error = Color3.fromRGB(255, 80, 100),
    Warning = Color3.fromRGB(255, 200, 80),
    Info = Color3.fromRGB(80, 180, 255),
    
    -- Neumorphism
    NeuLight = Color3.fromRGB(35, 35, 55),
    NeuDark = Color3.fromRGB(8, 8, 15),
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Tween(obj, props, dur, style, dir)
    local tweenInfo = TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function AddPadding(parent, top, bottom, left, right)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or top or 0),
        PaddingRight = UDim.new(0, right or left or top or 0),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Colors.CardBorder,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function AddGradient(parent, colors, rotation)
    local colorSeq = {}
    for i, col in ipairs(colors) do
        table.insert(colorSeq, ColorSequenceKeypoint.new((i-1)/(#colors-1), col))
    end
    return Create("UIGradient", {
        Color = ColorSequence.new(colorSeq),
        Rotation = rotation or 45,
        Parent = parent
    })
end

local function AddShadow(parent, color, size, transparency)
    return Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -size, 0, -size),
        Size = UDim2.new(1, size * 2, 1, size * 2),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = color or Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
end

local function AddGlow(parent, color, size, transparency)
    return Create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -size, 0, -size),
        Size = UDim2.new(1, size * 2, 1, size * 2),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = color,
        ImageTransparency = transparency or 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ============================================
-- MAIN LIBRARY - CREATE WINDOW
-- ============================================
function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "Aurora Ethereal"
    local logoImage = config.Logo or nil -- Custom logo image ID
    local size = config.Size or UDim2.new(0, 750, 0, 480)
    
    if config.Theme and Themes[config.Theme] then
        CurrentTheme = Themes[config.Theme]
    end
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
        Theme = CurrentTheme,
        ThemeObjects = {},
        Connections = {},
        Threads = {}
    }
    
    -- ============================================
    -- SCREENGUI
    -- ============================================
    local ScreenGui = Create("ScreenGui", {
        Name = "EnzoUI_G_" .. math.random(100000, 999999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    Window.ScreenGui = ScreenGui
    
    -- Blur Effect
    local Blur = Create("BlurEffect", {
        Name = "EnzoBlur_G",
        Size = config.Blur ~= false and 12 or 0,
        Parent = Lighting
    })
    
    -- ============================================
    -- MAIN FRAME
    -- ============================================
    local Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Colors.Background,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        Parent = ScreenGui
    })
    AddCorner(Main, 16)
    AddShadow(Main, Color3.fromRGB(0, 0, 0), 30, 0.4)
    
    Window.Main = Main
    
    -- Aurora Gradient Border
    local BorderFrame = Create("Frame", {
        Name = "Border",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0, -2, 0, -2),
        ZIndex = 0,
        Parent = Main
    })
    AddCorner(BorderFrame, 18)
    
    local BorderGradient = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = BorderFrame
    })
    AddCorner(BorderGradient, 18)
    local auroraGradient = AddGradient(BorderGradient, {CurrentTheme.Primary, CurrentTheme.Secondary, CurrentTheme.Tertiary, CurrentTheme.Primary}, 0)
    table.insert(Window.ThemeObjects, {Type = "AuroraGradient", Gradient = auroraGradient})
    
    -- Animate aurora gradient
    table.insert(Window.Threads, task.spawn(function()
        local rotation = 0
        while true do
            rotation = (rotation + 1) % 360
            pcall(function()
                auroraGradient.Rotation = rotation
            end)
            task.wait(0.03)
        end
    end))
    
    -- Inner mask
    local InnerMask = Create("Frame", {
        BackgroundColor3 = Colors.Background,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        ZIndex = 1,
        Parent = BorderFrame
    })
    AddCorner(InnerMask, 16)
    
    -- ============================================
    -- HEADER
    -- ============================================
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 70),
        ZIndex = 10,
        Parent = Main
    })
    AddCorner(Header, 16)
    
    -- Fix bottom corners
    Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 9,
        Parent = Header
    })
    
    -- Logo Container
    local LogoContainer = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 15, 0.5, -22),
        Size = UDim2.new(0, 44, 0, 44),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(LogoContainer, 12)
    AddGradient(LogoContainer, {CurrentTheme.Primary, CurrentTheme.Secondary}, 135)
    AddGlow(LogoContainer, CurrentTheme.Primary, 12, 0.6)
    table.insert(Window.ThemeObjects, {Object = LogoContainer, Property = "BackgroundColor3", Key = "Primary"})
    
    -- Logo (Image or Text)
    if logoImage then
        Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.7, 0, 0.7, 0),
            Position = UDim2.new(0.15, 0, 0.15, 0),
            ZIndex = 12,
            Image = logoImage,
            ImageColor3 = Colors.Text,
            ScaleType = Enum.ScaleType.Fit,
            Parent = LogoContainer
        })
    else
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 12,
            Font = Enum.Font.GothamBlack,
            Text = "E",
            TextColor3 = Colors.Text,
            TextSize = 22,
            Parent = LogoContainer
        })
    end
    
    -- Title
    local TitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 12),
        Size = UDim2.new(0, 200, 0, 24),
        ZIndex = 11,
        Font = Enum.Font.GothamBlack,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    local SubtitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 38),
        Size = UDim2.new(0, 200, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Colors.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Tab Container (Horizontal Pills)
    local TabContainer = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 280, 0.5, -17),
        Size = UDim2.new(0, 320, 0, 34),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(TabContainer, 17)
    
    local TabList = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12,
        Parent = TabContainer
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TabList
    })
    AddPadding(TabList, 4, 4, 6, 6)
    
    -- Tab Indicator (sliding pill)
    local TabIndicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 6, 0.5, -13),
        Size = UDim2.new(0, 70, 0, 26),
        ZIndex = 11,
        Parent = TabContainer
    })
    AddCorner(TabIndicator, 13)
    AddGradient(TabIndicator, {CurrentTheme.Primary, CurrentTheme.Secondary}, 90)
    AddGlow(TabIndicator, CurrentTheme.Primary, 8, 0.7)
    table.insert(Window.ThemeObjects, {Object = TabIndicator, Property = "BackgroundColor3", Key = "Primary"})
    
    -- Window Controls
    local Controls = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0.5, -15),
        Size = UDim2.new(0, 85, 0, 30),
        ZIndex = 11,
        Parent = Header
    })
    
    local function CreateControlBtn(icon, color, layoutOrder, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.85,
            Size = UDim2.new(0, 26, 0, 26),
            LayoutOrder = layoutOrder,
            ZIndex = 12,
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = color,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = Controls
        })
        AddCorner(btn, 8)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.5, Size = UDim2.new(0, 28, 0, 28)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.85, Size = UDim2.new(0, 26, 0, 26)}, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = Controls
    })
    
    CreateControlBtn("−", Colors.Warning, 1, function() Window:Toggle() end)
    CreateControlBtn("□", Colors.Info, 2, function() end)
    CreateControlBtn("×", Colors.Error, 3, function() Window:Destroy() end)
    
    MakeDraggable(Main, Header)
    
    -- ============================================
    -- CONTENT CONTAINER
    -- ============================================
    local ContentContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 80),
        Size = UDim2.new(1, -30, 1, -140),
        ZIndex = 3,
        Parent = Main
    })
    
    -- ============================================
    -- FOOTER
    -- ============================================
    local Footer = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 15, 1, -52),
        Size = UDim2.new(1, -30, 0, 42),
        ZIndex = 10,
        Parent = Main
    })
    AddCorner(Footer, 12)
    
    -- Theme Selector
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -8),
        Size = UDim2.new(0, 50, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "Theme",
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local ThemeContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0.5, -10),
        Size = UDim2.new(0, 130, 0, 20),
        ZIndex = 11,
        Parent = Footer
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = ThemeContainer
    })
    
    local themeButtons = {}
    for name, theme in pairs(Themes) do
        local themeBtn = Create("TextButton", {
            Name = name,
            BackgroundColor3 = theme.Primary,
            Size = UDim2.new(0, 18, 0, 18),
            ZIndex = 12,
            Text = "",
            AutoButtonColor = false,
            Parent = ThemeContainer
        })
        AddCorner(themeBtn, 9)
        AddGradient(themeBtn, {theme.Primary, theme.Secondary}, 135)
        
        if name == CurrentTheme.Name then
            AddStroke(themeBtn, Colors.Text, 2, 0)
        end
        
        themeBtn.MouseEnter:Connect(function()
            Tween(themeBtn, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
        end)
        themeBtn.MouseLeave:Connect(function()
            Tween(themeBtn, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
        end)
        
        themeBtn.MouseButton1Click:Connect(function()
            Window:SetTheme(name)
            for _, btn in pairs(themeButtons) do
                local stroke = btn:FindFirstChildOfClass("UIStroke")
                if stroke then stroke:Destroy() end
            end
            AddStroke(themeBtn, Colors.Text, 2, 0)
        end)
        
        table.insert(themeButtons, themeBtn)
    end
    
    -- Opacity Slider
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 220, 0.5, -8),
        Size = UDim2.new(0, 55, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "Opacity",
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local OpacityTrack = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 280, 0.5, -5),
        Size = UDim2.new(0, 100, 0, 10),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(OpacityTrack, 5)
    
    local OpacityFill = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12,
        Parent = OpacityTrack
    })
    AddCorner(OpacityFill, 5)
    AddGradient(OpacityFill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 0)
    table.insert(Window.ThemeObjects, {Object = OpacityFill, Property = "BackgroundColor3", Key = "Primary"})
    
    local OpacityKnob = Create("Frame", {
        BackgroundColor3 = Colors.Text,
        Position = UDim2.new(1, -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        ZIndex = 13,
        Parent = OpacityTrack
    })
    AddCorner(OpacityKnob, 8)
    AddShadow(OpacityKnob, Color3.fromRGB(0,0,0), 4, 0.5)
    
    local OpacityLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 385, 0.5, -8),
        Size = UDim2.new(0, 35, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamBold,
        Text = "100%",
        TextColor3 = CurrentTheme.Primary,
        TextSize = 11,
        Parent = Footer
    })
    table.insert(Window.ThemeObjects, {Object = OpacityLabel, Property = "TextColor3", Key = "Primary"})
    
    -- Opacity Logic
    local opacityDragging = false
    local currentOpacity = 1
    
    local function UpdateOpacity(input)
        local pos = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X, 0, 1)
        currentOpacity = pos
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -8, 0.5, -8)
        OpacityLabel.Text = math.floor(pos * 100) .. "%"
        Main.BackgroundTransparency = 1 - (pos * 0.95)
    end
    
    OpacityTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = true
            UpdateOpacity(input)
        end
    end)
    
    OpacityTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = false
        end
    end)
    
    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateOpacity(input)
        end
    end))
    
    -- Toggle Key Badge
    local ToggleBadge = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(1, -110, 0.5, -13),
        Size = UDim2.new(0, 95, 0, 26),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(ToggleBadge, 8)
    
    local ToggleBadgeText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12,
        Font = Enum.Font.GothamBold,
        Text = "🎮 " .. Window.ToggleKey.Name,
        TextColor3 = CurrentTheme.Primary,
        TextSize = 10,
        Parent = ToggleBadge
    })
    table.insert(Window.ThemeObjects, {Object = ToggleBadgeText, Property = "TextColor3", Key = "Primary"})
    
    -- Toggle Key Input Handler
    table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Window.ToggleKey then
            Window:Toggle()
        end
    end))
    
    -- ============================================
    -- WINDOW METHODS
    -- ============================================
    function Window:Toggle()
        self.Visible = not self.Visible
        
        if self.Visible then
            Main.Visible = true
            Main.Size = UDim2.new(0, size.X.Offset, 0, 0)
            Main.BackgroundTransparency = 1
            
            Tween(Main, {Size = size, BackgroundTransparency = 1 - (currentOpacity * 0.95)}, 0.5, Enum.EasingStyle.Back)
            Tween(Blur, {Size = 12}, 0.3)
        else
            Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            
            task.delay(0.3, function()
                if not self.Visible then Main.Visible = false end
            end)
        end
    end
    
    function Window:Destroy()
        for _, connection in pairs(self.Connections) do
            pcall(function() connection:Disconnect() end)
        end
        for _, thread in pairs(self.Threads) do
            pcall(function() task.cancel(thread) end)
        end
        
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
        Tween(Blur, {Size = 0}, 0.3)
        
        task.delay(0.4, function()
            pcall(function() ScreenGui:Destroy() end)
            pcall(function() Blur:Destroy() end)
        end)
        
        if getgenv then getgenv().EnzoUILib = nil end
    end
    
    function Window:SetTheme(themeName)
        if Themes[themeName] then
            CurrentTheme = Themes[themeName]
            Window.Theme = CurrentTheme
            
            for _, obj in pairs(Window.ThemeObjects) do
                if obj.Type == "AuroraGradient" and obj.Gradient then
                    pcall(function()
                        obj.Gradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, CurrentTheme.Primary),
                            ColorSequenceKeypoint.new(0.33, CurrentTheme.Secondary),
                            ColorSequenceKeypoint.new(0.66, CurrentTheme.Tertiary),
                            ColorSequenceKeypoint.new(1, CurrentTheme.Primary)
                        })
                    end)
                elseif obj.Object and obj.Property and obj.Key then
                    pcall(function()
                        Tween(obj.Object, {[obj.Property] = CurrentTheme[obj.Key]}, 0.3)
                    end)
                end
            end
        end
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Content.Visible = false
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
            Tween(Window.CurrentTab.TextLabel, {TextColor3 = Colors.TextMuted}, 0.2)
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        
        -- Animate indicator
        local btnPos = tab.Button.AbsolutePosition
        local containerPos = TabContainer.AbsolutePosition
        local relativeX = btnPos.X - containerPos.X
        
        Tween(TabIndicator, {
            Position = UDim2.new(0, relativeX, 0.5, -13),
            Size = UDim2.new(0, tab.Button.AbsoluteSize.X, 0, 26)
        }, 0.3, Enum.EasingStyle.Back)
        
        Tween(tab.Button, {BackgroundTransparency = 1}, 0.2)
        Tween(tab.TextLabel, {TextColor3 = Colors.Text}, 0.2)
        
        TitleLabel.Text = tab.Name
    end
    
    -- ============================================
    -- ADD TAB METHOD
    -- ============================================
    function Window:AddTab(config)
        config = config or {}
        local tabName = config.Title or "Tab"
        local tabIcon = config.Icon or "📁"
        
        local Tab = {
            Name = tabName,
            Icon = tabIcon,
            Sections = {}
        }
        
        -- Tab Button (Pill)
        local TabButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 26),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 13,
            Text = "",
            AutoButtonColor = false,
            Parent = TabList
        })
        
        local TabText = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 14,
            Font = Enum.Font.GothamBold,
            Text = "  " .. tabIcon .. " " .. tabName .. "  ",
            TextColor3 = Colors.TextMuted,
            TextSize = 11,
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Primary,
            ScrollBarImageTransparency = 0.5,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 4,
            Parent = ContentContainer
        })
        AddPadding(TabContent, 5)
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 15),
            Parent = TabContent
        })
        
        Tab.Button = TabButton
        Tab.TextLabel = TabText
        Tab.Content = TabContent
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabText, {TextColor3 = Colors.TextSecondary}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabText, {TextColor3 = Colors.TextMuted}, 0.15)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            task.defer(function()
                Window:SelectTab(Tab)
            end)
        end
        
        -- ============================================
        -- ADD SECTION METHOD
        -- ============================================
        function Tab:AddSection(config)
            config = config or {}
            local sectionName = config.Title or "Section"
            local sectionSide = config.Side or "Left"
            local sectionIcon = config.Icon or "⚡"
            
            local Section = {
                Name = sectionName,
                Elements = {}
            }
            
            -- Get or Create Column
            local colName = sectionSide .. "Column"
            local column = TabContent:FindFirstChild(colName)
            
            if not column then
                column = Create("Frame", {
                    Name = colName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.48, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = sectionSide == "Left" and 1 or 2,
                    Parent = TabContent
                })
                Create("UIListLayout", {Padding = UDim.new(0, 12), Parent = column})
            end
            
            -- Section Card (Floating Style)
            local SectionCard = Create("Frame", {
                BackgroundColor3 = Colors.Card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            AddCorner(SectionCard, 14)
            AddStroke(SectionCard, Colors.CardBorder, 1, 0.5)
            AddShadow(SectionCard, Color3.fromRGB(0,0,0), 15, 0.3)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 45),
                Parent = SectionCard
            })
            
            -- Icon with gradient background
            local IconBG = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                Position = UDim2.new(0, 14, 0.5, -15),
                Size = UDim2.new(0, 30, 0, 30),
                Parent = SectionHeader
            })
            AddCorner(IconBG, 10)
            AddGradient(IconBG, {CurrentTheme.Primary, CurrentTheme.Secondary}, 135)
            table.insert(Window.ThemeObjects, {Object = IconBG, Property = "BackgroundColor3", Key = "Primary"})
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Parent = IconBG
            })
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 52, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamBlack,
                Text = sectionName:upper(),
                TextColor3 = Colors.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Gradient divider
            local Divider = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                Position = UDim2.new(0, 14, 0, 45),
                Size = UDim2.new(1, -28, 0, 2),
                Parent = SectionCard
            })
            AddCorner(Divider, 1)
            AddGradient(Divider, {CurrentTheme.Primary, CurrentTheme.Secondary, Colors.Card}, 0)
            table.insert(Window.ThemeObjects, {Object = Divider, Property = "BackgroundColor3", Key = "Primary"})
            
            -- Content
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 52),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionCard
            })
            AddPadding(SectionContent, 5, 14, 14, 14)
            Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = SectionContent})
            
            Section.Card = SectionCard
            Section.Content = SectionContent
            table.insert(Tab.Sections, Section)
            
            -- ============================================
            -- TOGGLE (Neumorphism Style)
            -- ============================================
            function Section:AddToggle(cfg)
                cfg = cfg or {}
                local Toggle = {Value = cfg.Default or false}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 52 or 42),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 8 or 0),
                    Size = UDim2.new(1, -75, 0, cfg.Description and 18 or 42),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 26),
                        Size = UDim2.new(1, -75, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                -- Neumorphism Switch
                local Switch = Create("Frame", {
                    BackgroundColor3 = Toggle.Value and CurrentTheme.Primary or Colors.BackgroundDark,
                    Position = UDim2.new(1, -58, 0.5, -12),
                    Size = UDim2.new(0, 48, 0, 24),
                    Parent = Frame
                })
                AddCorner(Switch, 12)
                
                if Toggle.Value then
                    AddGlow(Switch, CurrentTheme.Primary, 6, 0.6)
                end
                
                local Knob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = Toggle.Value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20),
                    ZIndex = 2,
                    Parent = Switch
                })
                AddCorner(Knob, 10)
                AddShadow(Knob, Color3.fromRGB(0,0,0), 4, 0.3)
                
                local ClickArea = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Frame
                })
                
                ClickArea.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    
                    -- Remove old glow
                    local oldGlow = Switch:FindFirstChild("Glow")
                    if oldGlow then oldGlow:Destroy() end
                    
                    if Toggle.Value then
                        Tween(Switch, {BackgroundColor3 = CurrentTheme.Primary}, 0.25)
                        Tween(Knob, {Position = UDim2.new(1, -22, 0.5, -10)}, 0.25, Enum.EasingStyle.Back)
                        AddGlow(Switch, CurrentTheme.Primary, 6, 0.6)
                    else
                        Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.25)
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.25, Enum.EasingStyle.Back)
                    end
                    
                    if cfg.Callback then cfg.Callback(Toggle.Value) end
                end)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Toggle:SetValue(v)
                    if Toggle.Value ~= v then
                        Toggle.Value = v
                        local oldGlow = Switch:FindFirstChild("Glow")
                        if oldGlow then oldGlow:Destroy() end
                        
                        if v then
                            Tween(Switch, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                            Tween(Knob, {Position = UDim2.new(1, -22, 0.5, -10)}, 0.2)
                            AddGlow(Switch, CurrentTheme.Primary, 6, 0.6)
                        else
                            Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.2)
                            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.2)
                        end
                    end
                end
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- ============================================
            -- SLIDER
            -- ============================================
            function Section:AddSlider(cfg)
                cfg = cfg or {}
                local min, max = cfg.Min or 0, cfg.Max or 100
                local Slider = {Value = cfg.Default or min}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 60 or 50),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -70, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                -- Value Badge
                local ValueBadge = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -55, 0, 5),
                    Size = UDim2.new(0, 45, 0, 20),
                    Parent = Frame
                })
                AddCorner(ValueBadge, 6)
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBlack,
                    Text = tostring(Slider.Value) .. (cfg.Suffix or ""),
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 10,
                    Parent = ValueBadge
                })
                table.insert(Window.ThemeObjects, {Object = ValueLabel, Property = "TextColor3", Key = "Primary"})
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -24, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                -- Track
                local Track = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundDark,
                    Position = UDim2.new(0, 12, 1, -18),
                    Size = UDim2.new(1, -24, 0, 8),
                    Parent = Frame
                })
                AddCorner(Track, 4)
                
                local pct = (Slider.Value - min) / (max - min)
                
                local Fill = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    Size = UDim2.new(pct, 0, 1, 0),
                    Parent = Track
                })
                AddCorner(Fill, 4)
                AddGradient(Fill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 0)
                table.insert(Window.ThemeObjects, {Object = Fill, Property = "BackgroundColor3", Key = "Primary"})
                
                local SliderKnob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(pct, -9, 0.5, -9),
                    Size = UDim2.new(0, 18, 0, 18),
                    ZIndex = 2,
                    Parent = Track
                })
                AddCorner(SliderKnob, 9)
                AddShadow(SliderKnob, Color3.fromRGB(0,0,0), 4, 0.3)
                AddStroke(SliderKnob, CurrentTheme.Primary, 2, 0)
                
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    Slider.Value = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -9, 0.5, -9)
                    ValueLabel.Text = tostring(val) .. (cfg.Suffix or "")
                    if cfg.Callback then cfg.Callback(val) end
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                    end
                end)
                
                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end))
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Slider:SetValue(v)
                    local pos = (v - min) / (max - min)
                    Slider.Value = v
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -9, 0.5, -9)
                    ValueLabel.Text = tostring(v) .. (cfg.Suffix or "")
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ============================================
            -- BUTTON
            -- ============================================
            function Section:AddButton(cfg)
                cfg = cfg or {}
                local styles = {
                    Primary = {CurrentTheme.Primary, CurrentTheme.Secondary},
                    Secondary = {Colors.BackgroundLight, Colors.CardHover},
                    Success = {Colors.Success, Color3.fromRGB(100, 255, 180)},
                    Danger = {Colors.Error, Color3.fromRGB(255, 120, 140)}
                }
                local style = styles[cfg.Style or "Primary"] or styles.Primary
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 65 or 45),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 8),
                        Size = UDim2.new(1, -24, 0, 14),
                        Font = Enum.Font.GothamBold,
                        Text = cfg.Title or "Button",
                        TextColor3 = Colors.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                    
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -24, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = style[1],
                    Position = cfg.Description and UDim2.new(0, 10, 1, -28) or UDim2.new(0, 10, 0.5, -14),
                    Size = UDim2.new(1, -20, 0, cfg.Description and 24 or 28),
                    Font = Enum.Font.GothamBlack,
                    Text = cfg.Description and "▶ EXECUTE" or (cfg.Title or "Button"),
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(Btn, 8)
                AddGradient(Btn, style, 90)
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -18, 0, cfg.Description and 26 or 30)}, 0.15)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -20, 0, cfg.Description and 24 or 28)}, 0.15)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -24, 0, cfg.Description and 22 or 26)}, 0.08)
                    task.delay(0.08, function()
                        Tween(Btn, {Size = UDim2.new(1, -20, 0, cfg.Description and 24 or 28)}, 0.08)
                    end)
                    if cfg.Callback then cfg.Callback() end
                end)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                return {}
            end
            
            -- ============================================
            -- DROPDOWN (With Search)
            -- ============================================
            function Section:AddDropdown(cfg)
                cfg = cfg or {}
                local items = cfg.Items or {}
                local multi = cfg.Multi or false
                local Dropdown = {
                    Value = multi and {} or cfg.Default,
                    Open = false,
                    Items = items
                }
                
                if multi and cfg.Default then
                    for _, v in pairs(cfg.Default) do Dropdown.Value[v] = true end
                end
                
                local baseH = cfg.Description and 70 or 55
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, baseH),
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -24, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -24, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 10, 0, cfg.Description and 38 or 28),
                    Size = UDim2.new(1, -20, 0, 24),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(DropBtn, 6)
                AddStroke(DropBtn, CurrentTheme.Primary, 1, 0.7)
                
                local BtnText = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -35, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = multi and "Select..." or (cfg.Default or "Select..."),
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropBtn
                })
                
                local Arrow = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -22, 0, 0),
                    Size = UDim2.new(0, 18, 1, 0),
                    Font = Enum.Font.GothamBlack,
                    Text = "▼",
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 9,
                    Parent = DropBtn
                })
                table.insert(Window.ThemeObjects, {Object = Arrow, Property = "TextColor3", Key = "Primary"})
                
                -- Content
                local Content = Create("Frame", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 10, 0, baseH + 4),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true,
                    Parent = Frame
                })
                AddCorner(Content, 8)
                AddStroke(Content, CurrentTheme.Primary, 1, 0.7)
                
                -- Search Box
                local SearchBox = Create("TextBox", {
                    BackgroundColor3 = Colors.BackgroundDark,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 0, 24),
                    Font = Enum.Font.GothamMedium,
                    Text = "",
                    PlaceholderText = "🔍 Search...",
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    ClearTextOnFocus = false,
                    Parent = Content
                })
                AddCorner(SearchBox, 6)
                AddPadding(SearchBox, 0, 0, 8, 8)
                
                -- Items List
                local ItemsList = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 34),
                    Size = UDim2.new(1, 0, 1, -34),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = CurrentTheme.Primary,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Content
                })
                AddPadding(ItemsList, 4, 6, 5, 5)
                Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = ItemsList})
                
                local itemBtns = {}
                
                local function createItem(name)
                    local isSel = multi and Dropdown.Value[name] or Dropdown.Value == name
                    
                    local ItemBtn = Create("TextButton", {
                        Name = name,
                        BackgroundColor3 = isSel and CurrentTheme.Primary or Colors.BackgroundLight,
                        BackgroundTransparency = isSel and 0.7 or 0.3,
                        Size = UDim2.new(1, -6, 0, 26),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = ItemsList
                    })
                    AddCorner(ItemBtn, 6)
                    
                    if multi then
                        local cb = Create("Frame", {
                            BackgroundColor3 = isSel and CurrentTheme.Accent or Colors.BackgroundDark,
                            Position = UDim2.new(0, 6, 0.5, -8),
                            Size = UDim2.new(0, 16, 0, 16),
                            Parent = ItemBtn
                        })
                        AddCorner(cb, 4)
                        
                        Create("TextLabel", {
                            Name = "Check",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.GothamBlack,
                            Text = isSel and "✓" or "",
                            TextColor3 = Colors.Text,
                            TextSize = 10,
                            Parent = cb
                        })
                    end
                    
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, multi and 28 or 10, 0, 0),
                        Size = UDim2.new(1, multi and -35 or -18, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = name,
                        TextColor3 = isSel and Colors.Text or Colors.TextSecondary,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ItemBtn
                    })
                    
                    ItemBtn.MouseEnter:Connect(function()
                        if not (multi and Dropdown.Value[name] or Dropdown.Value == name) then
                            Tween(ItemBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = CurrentTheme.Primary}, 0.1)
                        end
                    end)
                    
                    ItemBtn.MouseLeave:Connect(function()
                        local sel = multi and Dropdown.Value[name] or Dropdown.Value == name
                        Tween(ItemBtn, {
                            BackgroundTransparency = sel and 0.7 or 0.3,
                            BackgroundColor3 = sel and CurrentTheme.Primary or Colors.BackgroundLight
                        }, 0.1)
                    end)
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[name] = not Dropdown.Value[name]
                            local nowSel = Dropdown.Value[name]
                            
                            local cb = ItemBtn:FindFirstChild("Frame")
                            if cb then
                                Tween(cb, {BackgroundColor3 = nowSel and CurrentTheme.Accent or Colors.BackgroundDark}, 0.15)
                                local check = cb:FindFirstChild("Check")
                                if check then check.Text = nowSel and "✓" or "" end
                            end
                            
                            Tween(ItemBtn, {
                                BackgroundColor3 = nowSel and CurrentTheme.Primary or Colors.BackgroundLight,
                                BackgroundTransparency = nowSel and 0.7 or 0.3
                            }, 0.15)
                            
                            local textLabel = ItemBtn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = nowSel and Colors.Text or Colors.TextSecondary
                            end
                            
                            local sel = {}
                            for k, v in pairs(Dropdown.Value) do
                                if v then table.insert(sel, k) end
                            end
                            BtnText.Text = #sel > 0 and table.concat(sel, ", ") or "Select..."
                            BtnText.TextColor3 = #sel > 0 and Colors.Text or Colors.TextSecondary
                            
                            if cfg.Callback then cfg.Callback(Dropdown.Value) end
                        else
                            Dropdown.Value = name
                            BtnText.Text = name
                            BtnText.TextColor3 = Colors.Text
                            
                            for n, btn in pairs(itemBtns) do
                                local isThis = n == name
                                Tween(btn, {
                                    BackgroundColor3 = isThis and CurrentTheme.Primary or Colors.BackgroundLight,
                                    BackgroundTransparency = isThis and 0.7 or 0.3
                                }, 0.15)
                                local textLabel = btn:FindFirstChild("Text")
                                if textLabel then
                                    textLabel.TextColor3 = isThis and Colors.Text or Colors.TextSecondary
                                end
                            end
                            
                            if cfg.Callback then cfg.Callback(name) end
                            
                            Dropdown.Open = false
                            Tween(Arrow, {Rotation = 0}, 0.2)
                            Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                            Tween(Content, {Size = UDim2.new(1, -20, 0, 0)}, 0.25)
                        end
                    end)
                    
                    return ItemBtn
                end
                
                for _, item in pairs(items) do
                    itemBtns[item] = createItem(item)
                end
                
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local s = SearchBox.Text:lower()
                    for name, btn in pairs(itemBtns) do
                        btn.Visible = s == "" or name:lower():find(s, 1, true) ~= nil
                    end
                end)
                
                DropBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        Tween(Arrow, {Rotation = 180}, 0.2)
                        local cnt = math.min(#items, 5)
                        local contentH = 40 + (cnt * 30) + 10
                        local totalH = baseH + 8 + contentH
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, totalH)}, 0.3, Enum.EasingStyle.Back)
                        Tween(Content, {Size = UDim2.new(1, -20, 0, contentH)}, 0.3, Enum.EasingStyle.Back)
                    else
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                        Tween(Content, {Size = UDim2.new(1, -20, 0, 0)}, 0.25)
                    end
                end)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Dropdown:SetItems(newItems)
                    Dropdown.Items = newItems
                    for _, c in pairs(ItemsList:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    itemBtns = {}
                    for _, item in pairs(newItems) do
                        itemBtns[item] = createItem(item)
                    end
                end
                
                function Dropdown:SetValue(v)
                    if multi then
                        Dropdown.Value = v
                        for name, btn in pairs(itemBtns) do
                            local sel = v[name]
                            local cb = btn:FindFirstChild("Frame")
                            if cb then
                                cb.BackgroundColor3 = sel and CurrentTheme.Accent or Colors.BackgroundDark
                                local check = cb:FindFirstChild("Check")
                                if check then check.Text = sel and "✓" or "" end
                            end
                            btn.BackgroundColor3 = sel and CurrentTheme.Primary or Colors.BackgroundLight
                            btn.BackgroundTransparency = sel and 0.7 or 0.3
                            local textLabel = btn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = sel and Colors.Text or Colors.TextSecondary
                            end
                        end
                        local selected = {}
                        for k, val in pairs(v) do
                            if val then table.insert(selected, k) end
                        end
                        BtnText.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                    else
                        Dropdown.Value = v
                        BtnText.Text = v
                        BtnText.TextColor3 = Colors.Text
                        for name, btn in pairs(itemBtns) do
                            local isThis = name == v
                            btn.BackgroundColor3 = isThis and CurrentTheme.Primary or Colors.BackgroundLight
                            btn.BackgroundTransparency = isThis and 0.7 or 0.3
                            local textLabel = btn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = isThis and Colors.Text or Colors.TextSecondary
                            end
                        end
                    end
                end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- ============================================
            -- TEXTBOX
            -- ============================================
            function Section:AddTextbox(cfg)
                cfg = cfg or {}
                local Textbox = {Value = cfg.Default or ""}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 65 or 50),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -24, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Input",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -24, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local InputBox = Create("TextBox", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 10, 0, cfg.Description and 38 or 28),
                    Size = UDim2.new(1, -20, 0, 22),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "Enter text...",
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    Parent = Frame
                })
                AddCorner(InputBox, 6)
                AddStroke(InputBox, CurrentTheme.Primary, 1, 0.7)
                AddPadding(InputBox, 0, 0, 8, 8)
                
                InputBox.Focused:Connect(function()
                    local stroke = InputBox:FindFirstChildOfClass("UIStroke")
                    if stroke then Tween(stroke, {Transparency = 0.3}, 0.2) end
                end)
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    local stroke = InputBox:FindFirstChildOfClass("UIStroke")
                    if stroke then Tween(stroke, {Transparency = 0.7}, 0.2) end
                    Textbox.Value = InputBox.Text
                    if cfg.Callback then cfg.Callback(InputBox.Text, enterPressed) end
                end)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Textbox:SetValue(v)
                    Textbox.Value = v
                    InputBox.Text = v
                end
                
                table.insert(Section.Elements, Textbox)
                return Textbox
            end
            
            -- ============================================
            -- KEYBIND
            -- ============================================
            function Section:AddKeybind(cfg)
                cfg = cfg or {}
                local Keybind = {Value = cfg.Default or Enum.KeyCode.E}
                local listening = false
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 50 or 40),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 6 or 0),
                    Size = UDim2.new(1, -90, 0, cfg.Description and 16 or 40),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Keybind",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -90, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local KeyBtn = Create("TextButton", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -75, 0.5, -12),
                    Size = UDim2.new(0, 65, 0, 24),
                    Font = Enum.Font.GothamBold,
                    Text = Keybind.Value.Name,
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(KeyBtn, 6)
                AddStroke(KeyBtn, CurrentTheme.Primary, 1, 0.5)
                
                table.insert(Window.ThemeObjects, {Object = KeyBtn, Property = "BackgroundColor3", Key = "Primary"})
                table.insert(Window.ThemeObjects, {Object = KeyBtn, Property = "TextColor3", Key = "Primary"})
                
                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                    Tween(KeyBtn, {BackgroundTransparency = 0.5}, 0.2)
                end)
                
                table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            Keybind.Value = input.KeyCode
                            KeyBtn.Text = input.KeyCode.Name
                            Tween(KeyBtn, {BackgroundTransparency = 0.8}, 0.2)
                            
                            -- Update Window toggle key if this is the toggle key keybind
                            if cfg.Callback then cfg.Callback(input.KeyCode) end
                        end
                    elseif not processed and input.KeyCode == Keybind.Value then
                        if cfg.OnPress then cfg.OnPress() end
                    end
                end))
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Keybind:SetValue(key)
                    Keybind.Value = key
                    KeyBtn.Text = key.Name
                end
                
                table.insert(Section.Elements, Keybind)
                return Keybind
            end
            
            -- ============================================
            -- LABEL
            -- ============================================
            function Section:AddLabel(text)
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionContent
                })
                
                function Label:SetText(t)
                    LabelFrame.Text = t
                end
                
                table.insert(Section.Elements, Label)
                return Label
            end
            
            -- ============================================
            -- PARAGRAPH
            -- ============================================
            function Section:AddParagraph(cfg)
                cfg = cfg or {}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                AddPadding(Frame, 10)
                
                Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = Frame})
                
                local TitleLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Title",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local ContentLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham,
                    Text = cfg.Content or "Content",
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = Frame
                })
                
                local Paragraph = {}
                
                function Paragraph:SetTitle(t)
                    TitleLabel.Text = t
                end
                
                function Paragraph:SetContent(c)
                    ContentLabel.Text = c
                end
                
                return Paragraph
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- ============================================
    -- NOTIFICATION SYSTEM
    -- ============================================
    function Window:Notify(cfg)
        cfg = cfg or {}
        local types = {
            Info = {col = Colors.Info, icon = "ℹ️"},
            Success = {col = Colors.Success, icon = "✅"},
            Warning = {col = Colors.Warning, icon = "⚠️"},
            Error = {col = Colors.Error, icon = "❌"}
        }
        local data = types[cfg.Type or "Info"] or types.Info
        
        local Container = ScreenGui:FindFirstChild("Notifications")
        if not Container then
            Container = Create("Frame", {
                Name = "Notifications",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -340, 0, 20),
                Size = UDim2.new(0, 320, 0, 0),
                ZIndex = 1000,
                Parent = ScreenGui
            })
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Parent = Container
            })
        end
        
        local Notif = Create("Frame", {
            BackgroundColor3 = Colors.Card,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 1001,
            Parent = Container
        })
        AddCorner(Notif, 12)
        AddStroke(Notif, data.col, 1.5, 0.3)
        AddShadow(Notif, data.col, 12, 0.5)
        
        -- Left accent
        local Accent = Create("Frame", {
            BackgroundColor3 = data.col,
            Size = UDim2.new(0, 4, 1, 0),
            ZIndex = 1002,
            Parent = Notif
        })
        AddCorner(Accent, 2)
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 12),
            Size = UDim2.new(0, 24, 0, 24),
            ZIndex = 1003,
            Font = Enum.Font.GothamBlack,
            Text = data.icon,
            TextSize = 18,
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 48, 0, 10),
            Size = UDim2.new(1, -65, 0, 18),
            ZIndex = 1003,
            Font = Enum.Font.GothamBlack,
            Text = cfg.Title or "Notification",
            TextColor3 = Colors.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif
        })
        
        local ContentLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 48, 0, 30),
            Size = UDim2.new(1, -65, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 1003,
            Font = Enum.Font.Gotham,
            Text = cfg.Content or "",
            TextColor3 = Colors.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notif
        })
        
        -- Progress Bar
        local ProgressBG = Create("Frame", {
            BackgroundColor3 = Colors.BackgroundDark,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            ZIndex = 1002,
            Parent = Notif
        })
        
        local Progress = Create("Frame", {
            BackgroundColor3 = data.col,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1003,
            Parent = ProgressBG
        })
        AddCorner(Progress, 2)
        
        local CloseBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -28, 0, 8),
            Size = UDim2.new(0, 20, 0, 20),
            ZIndex = 1004,
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Colors.TextMuted,
            TextSize = 16,
            Parent = Notif
        })
        
        local notifClosed = false
        
        local function closeNotif()
            if notifClosed then return end
            notifClosed = true
            Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.delay(0.3, function() pcall(function() Notif:Destroy() end) end)
        end
        
        CloseBtn.MouseButton1Click:Connect(closeNotif)
        CloseBtn.MouseEnter:Connect(function()
            Tween(CloseBtn, {TextColor3 = Colors.Text}, 0.1)
        end)
        CloseBtn.MouseLeave:Connect(function()
            Tween(CloseBtn, {TextColor3 = Colors.TextMuted}, 0.1)
        end)
        
        table.insert(Window.Threads, task.spawn(function()
            task.wait(0.05)
            local height = 55 + ContentLabel.TextBounds.Y
            
            Notif.Position = UDim2.new(1, 30, 0, 0)
            Notif.Size = UDim2.new(1, 0, 0, height)
            
            Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
            Tween(Progress, {Size = UDim2.new(0, 0, 1, 0)}, cfg.Duration or 5, Enum.EasingStyle.Linear)
            
            task.wait(cfg.Duration or 5)
            closeNotif()
        end))
    end
    
    -- ============================================
    -- MOBILE TOGGLE BUTTON (FIXED POSITION)
    -- ============================================
    local lastMobilePosition = UDim2.new(0, 15, 0.5, -25)
    local mobileHidden = false
    
    local MobileBtn = Create("TextButton", {
        Name = "MobileToggle",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = lastMobilePosition,
        Size = UDim2.new(0, 50, 0, 50),
        ZIndex = 999,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui
    })
    AddCorner(MobileBtn, 25)
    AddGradient(MobileBtn, {CurrentTheme.Primary, CurrentTheme.Secondary, CurrentTheme.Tertiary}, 135)
    AddShadow(MobileBtn, Color3.fromRGB(0,0,0), 10, 0.4)
    
    local MobileGlow = AddGlow(MobileBtn, CurrentTheme.Primary, 12, 0.6)
    table.insert(Window.ThemeObjects, {Object = MobileGlow, Property = "ImageColor3", Key = "Primary"})
    
    -- Mobile Logo
    local MobileLogo
    if logoImage then
        MobileLogo = Create("ImageLabel", {
            Name = "Logo",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 0.6, 0),
            Position = UDim2.new(0.2, 0, 0.2, 0),
            ZIndex = 1000,
            Image = logoImage,
            ImageColor3 = Colors.Text,
            ScaleType = Enum.ScaleType.Fit,
            Parent = MobileBtn
        })
    else
        MobileLogo = Create("TextLabel", {
            Name = "Logo",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1000,
            Font = Enum.Font.GothamBlack,
            Text = "E",
            TextColor3 = Colors.Text,
            TextSize = 22,
            Parent = MobileBtn
        })
    end
    
    -- Mobile draggable (FIXED - Saves position)
    local mobileDrag = false
    local mobileStart, mobileStartPos
    
    MobileBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mobileDrag = true
            mobileStart = input.Position
            mobileStartPos = MobileBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mobileDrag = false
                    lastMobilePosition = MobileBtn.Position -- SAVE POSITION
                end
            end)
        end
    end)
    
    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if mobileDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mobileStart
            MobileBtn.Position = UDim2.new(
                mobileStartPos.X.Scale,
                mobileStartPos.X.Offset + delta.X,
                mobileStartPos.Y.Scale,
                mobileStartPos.Y.Offset + delta.Y
            )
        end
    end))
    
    MobileBtn.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)
    
    MobileBtn.MouseEnter:Connect(function()
        Tween(MobileBtn, {Size = UDim2.new(0, 55, 0, 55)}, 0.15)
        Tween(MobileGlow, {ImageTransparency = 0.4}, 0.15)
    end)
    MobileBtn.MouseLeave:Connect(function()
        Tween(MobileBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.15)
        Tween(MobileGlow, {ImageTransparency = 0.6}, 0.15)
    end)
    
    -- Override Toggle to handle mobile button visibility (NOT position)
    local origToggle = Window.Toggle
    Window.Toggle = function(self)
        self.Visible = not self.Visible
        
        if self.Visible then
            Main.Visible = true
            Main.Size = UDim2.new(0, size.X.Offset, 0, 0)
            Main.BackgroundTransparency = 1
            
            Tween(Main, {Size = size, BackgroundTransparency = 1 - (currentOpacity * 0.95)}, 0.5, Enum.EasingStyle.Back)
            Tween(Blur, {Size = 12}, 0.3)
            
            -- Fade out mobile button (keep position)
            Tween(MobileBtn, {BackgroundTransparency = 1}, 0.3)
            if MobileLogo:IsA("TextLabel") then
                Tween(MobileLogo, {TextTransparency = 1}, 0.3)
            else
                Tween(MobileLogo, {ImageTransparency = 1}, 0.3)
            end
            Tween(MobileGlow, {ImageTransparency = 1}, 0.3)
            mobileHidden = true
        else
            Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            
            -- Fade in mobile button (at saved position)
            Tween(MobileBtn, {BackgroundTransparency = 0}, 0.3)
            if MobileLogo:IsA("TextLabel") then
                Tween(MobileLogo, {TextTransparency = 0}, 0.3)
            else
                Tween(MobileLogo, {ImageTransparency = 0}, 0.3)
            end
            Tween(MobileGlow, {ImageTransparency = 0.6}, 0.3)
            mobileHidden = false
            
            task.delay(0.3, function()
                if not self.Visible then Main.Visible = false end
            end)
        end
    end
    
    if getgenv then
        getgenv().EnzoUILib = Window
    end
    
    return Window
end

-- ============================================
-- RETURN LIBRARY
-- ============================================
return EnzoLib