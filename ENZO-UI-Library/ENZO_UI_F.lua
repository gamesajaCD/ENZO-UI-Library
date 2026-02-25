--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ENZO UI LIBRARY                           ║
    ║              Design F: Fusion Modern                         ║
    ║                   Version: 1.0.0                             ║
    ║                  Author: ENZO-YT                             ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  Style: Cyberpunk + Glassmorphism + Gradient                 ║
    ║  Inspired by: Fluent, Rayfield, Aurora                       ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║  - Multiple Color Themes (6 themes)                          ║
    ║  - Heavy Glass Effect with Blur                              ║
    ║  - Neon Glow Accents                                         ║
    ║  - Smooth Animations                                         ║
    ║  - Sidebar + Header Layout                                   ║
    ║  - Search in Dropdowns                                       ║
    ║  - Mobile Support                                            ║
    ║  - Notifications System                                      ║
    ║  - Safe Re-execution                                         ║
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
-- SAFE CLEANUP (Re-execution Support)
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
        if v.Name:find("Enzo") then 
            v:Destroy() 
        end
    end
end)

pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("EnzoUI") then 
            v:Destroy() 
        end
    end
end)

-- ============================================
-- THEMES - Multiple Color Options
-- ============================================
local Themes = {
    Neon = {
        Name = "Neon",
        Primary = Color3.fromRGB(255, 0, 128),
        Secondary = Color3.fromRGB(0, 255, 255),
        Accent = Color3.fromRGB(255, 0, 255),
        Glow = Color3.fromRGB(255, 100, 200),
    },
    Ocean = {
        Name = "Ocean",
        Primary = Color3.fromRGB(0, 150, 255),
        Secondary = Color3.fromRGB(0, 255, 200),
        Accent = Color3.fromRGB(100, 200, 255),
        Glow = Color3.fromRGB(50, 180, 255),
    },
    Sunset = {
        Name = "Sunset",
        Primary = Color3.fromRGB(255, 100, 50),
        Secondary = Color3.fromRGB(255, 50, 150),
        Accent = Color3.fromRGB(255, 150, 100),
        Glow = Color3.fromRGB(255, 120, 80),
    },
    Purple = {
        Name = "Purple",
        Primary = Color3.fromRGB(150, 50, 255),
        Secondary = Color3.fromRGB(255, 100, 255),
        Accent = Color3.fromRGB(180, 100, 255),
        Glow = Color3.fromRGB(160, 80, 255),
    },
    Mint = {
        Name = "Mint",
        Primary = Color3.fromRGB(0, 255, 150),
        Secondary = Color3.fromRGB(100, 255, 200),
        Accent = Color3.fromRGB(50, 255, 180),
        Glow = Color3.fromRGB(80, 255, 170),
    },
    Rose = {
        Name = "Rose",
        Primary = Color3.fromRGB(255, 80, 120),
        Secondary = Color3.fromRGB(255, 150, 180),
        Accent = Color3.fromRGB(255, 100, 150),
        Glow = Color3.fromRGB(255, 120, 160),
    },
}

local CurrentTheme = Themes.Neon

-- ============================================
-- BASE COLORS (Theme Independent)
-- ============================================
local Colors = {
    Background = Color3.fromRGB(8, 8, 12),
    BackgroundDark = Color3.fromRGB(5, 5, 8),
    BackgroundLight = Color3.fromRGB(15, 15, 22),
    
    Glass = Color3.fromRGB(20, 20, 30),
    GlassLight = Color3.fromRGB(30, 30, 45),
    GlassBorder = Color3.fromRGB(50, 50, 70),
    
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 145),
    TextDark = Color3.fromRGB(80, 80, 100),
    
    Success = Color3.fromRGB(50, 255, 130),
    Error = Color3.fromRGB(255, 70, 90),
    Warning = Color3.fromRGB(255, 200, 50),
    Info = Color3.fromRGB(70, 180, 255),
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then 
            inst[k] = v 
        end
    end
    if props and props.Parent then 
        inst.Parent = props.Parent 
    end
    return inst
end

local function Tween(obj, props, dur, style, dir)
    local tweenInfo = TweenInfo.new(
        dur or 0.3, 
        style or Enum.EasingStyle.Quint, 
        dir or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8), 
        Parent = parent
    })
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
        Color = color or Color3.fromRGB(255, 255, 255),
        Thickness = thickness or 1,
        Transparency = transparency or 0.8,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function AddGradient(parent, color1, color2, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        }),
        Rotation = rotation or 45,
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
        ImageTransparency = transparency or 0.8,
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
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================
-- MAIN LIBRARY - CREATE WINDOW
-- ============================================
function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "Fusion Modern"
    local size = config.Size or UDim2.new(0, 720, 0, 500)
    local sidebarWidth = 70
    
    -- Set initial theme
    if config.Theme and Themes[config.Theme] then
        CurrentTheme = Themes[config.Theme]
    end
    
    -- Window Object
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
        Name = "EnzoUI_F_" .. math.random(100000, 999999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    pcall(function() 
        ScreenGui.Parent = CoreGui 
    end)
    
    if not ScreenGui.Parent then 
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") 
    end
    
    Window.ScreenGui = ScreenGui
    
    -- ============================================
    -- BLUR EFFECT
    -- ============================================
    local Blur = Create("BlurEffect", {
        Name = "EnzoBlur",
        Size = config.Blur ~= false and 15 or 0,
        Parent = Lighting
    })
    
    -- ============================================
    -- MAIN FRAME
    -- ============================================
    local Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        Parent = ScreenGui
    })
    AddCorner(Main, 12)
    
    Window.Main = Main
    
    -- Main Border Glow
    local MainGlow = AddGlow(Main, CurrentTheme.Primary, 25, 0.85)
    table.insert(Window.ThemeObjects, {Object = MainGlow, Property = "ImageColor3", Key = "Primary"})
    
    -- Main Border Stroke
    local MainBorder = AddStroke(Main, CurrentTheme.Primary, 1.5, 0.7)
    table.insert(Window.ThemeObjects, {Object = MainBorder, Property = "Color", Key = "Primary"})
    
    -- Glass Overlay
    local GlassOverlay = Create("Frame", {
        Name = "Glass",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.97,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = Main
    })
    AddCorner(GlassOverlay, 12)
    AddGradient(GlassOverlay, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 220), 135)
    
    -- ============================================
    -- SIDEBAR
    -- ============================================
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        ZIndex = 5,
        Parent = Main
    })
    AddCorner(Sidebar, 12)
    
    -- Fix right corners of sidebar
    Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 12, 1, 0),
        ZIndex = 4,
        Parent = Sidebar
    })
    
    -- Sidebar gradient line
    local SidebarLine = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(1, -2, 0.1, 0),
        Size = UDim2.new(0, 2, 0.8, 0),
        ZIndex = 6,
        Parent = Sidebar
    })
    AddCorner(SidebarLine, 1)
    AddGradient(SidebarLine, CurrentTheme.Primary, CurrentTheme.Secondary, 90)
    table.insert(Window.ThemeObjects, {Object = SidebarLine, Property = "BackgroundColor3", Key = "Primary"})
    
    -- Logo Container
    local LogoContainer = Create("Frame", {
        BackgroundColor3 = Colors.Glass,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0.5, -25, 0, 15),
        Size = UDim2.new(0, 50, 0, 50),
        ZIndex = 7,
        Parent = Sidebar
    })
    AddCorner(LogoContainer, 14)
    local LogoStroke = AddStroke(LogoContainer, CurrentTheme.Primary, 2, 0.5)
    table.insert(Window.ThemeObjects, {Object = LogoStroke, Property = "Color", Key = "Primary"})
    
    local LogoGlow = AddGlow(LogoContainer, CurrentTheme.Primary, 15, 0.7)
    table.insert(Window.ThemeObjects, {Object = LogoGlow, Property = "ImageColor3", Key = "Primary"})
    
    local LogoGradient = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 8,
        Parent = LogoContainer
    })
    AddCorner(LogoGradient, 14)
    AddGradient(LogoGradient, CurrentTheme.Primary, CurrentTheme.Secondary, 135)
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 9,
        Font = Enum.Font.GothamBlack,
        Text = "E",
        TextColor3 = Colors.Text,
        TextSize = 26,
        Parent = LogoGradient
    })
    
    -- Sidebar Divider
    Create("Frame", {
        BackgroundColor3 = Colors.GlassBorder,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0.15, 0, 0, 75),
        Size = UDim2.new(0.7, 0, 0, 1),
        ZIndex = 7,
        Parent = Sidebar
    })
    
    -- Tab List
    local TabList = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 85),
        Size = UDim2.new(1, 0, 1, -140),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 7,
        Parent = Sidebar
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = TabList
    })
    AddPadding(TabList, 5)
    
    -- Bottom Divider
    Create("Frame", {
        BackgroundColor3 = Colors.GlassBorder,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0.15, 0, 1, -55),
        Size = UDim2.new(0.7, 0, 0, 1),
        ZIndex = 7,
        Parent = Sidebar
    })
    
    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local ContentArea = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, sidebarWidth, 0, 0),
        Size = UDim2.new(1, -sidebarWidth, 1, 0),
        ZIndex = 2,
        Parent = Main
    })
    
    -- ============================================
    -- HEADER
    -- ============================================
    local Header = Create("Frame", {
        BackgroundColor3 = Colors.Glass,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 10,
        Parent = ContentArea
    })
    AddCorner(Header, 12)
    
    -- Fix bottom corners
    Create("Frame", {
        BackgroundColor3 = Colors.Glass,
        BackgroundTransparency = 0.4,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, -12, 0, 12),
        ZIndex = 9,
        Parent = Header
    })
    
    -- Header gradient accent line
    local HeaderLine = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, -12, 0, 2),
        ZIndex = 11,
        Parent = Header
    })
    AddGradient(HeaderLine, CurrentTheme.Primary, CurrentTheme.Secondary, 0)
    table.insert(Window.ThemeObjects, {Object = HeaderLine, Property = "BackgroundColor3", Key = "Primary"})
    
    -- Tab Icon & Title Container
    local TitleContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        ZIndex = 11,
        Parent = Header
    })
    
    -- Tab Icon Background
    local TabIconBG = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0.85,
        Position = UDim2.new(0, 0, 0.5, -18),
        Size = UDim2.new(0, 36, 0, 36),
        ZIndex = 12,
        Parent = TitleContainer
    })
    AddCorner(TabIconBG, 10)
    table.insert(Window.ThemeObjects, {Object = TabIconBG, Property = "BackgroundColor3", Key = "Primary"})
    
    local TabIcon = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 13,
        Font = Enum.Font.GothamBold,
        Text = "🏠",
        TextColor3 = CurrentTheme.Primary,
        TextSize = 18,
        Parent = TabIconBG
    })
    table.insert(Window.ThemeObjects, {Object = TabIcon, Property = "TextColor3", Key = "Primary"})
    
    -- Title Labels
    local TabTitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 46, 0, 12),
        Size = UDim2.new(1, -50, 0, 20),
        ZIndex = 12,
        Font = Enum.Font.GothamBlack,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleContainer
    })
    
    local TabSubtitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 46, 0, 34),
        Size = UDim2.new(1, -50, 0, 14),
        ZIndex = 12,
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Colors.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleContainer
    })
    
    -- ============================================
    -- WINDOW CONTROLS
    -- ============================================
    local Controls = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(1, -140, 0.5, -16),
        Size = UDim2.new(0, 120, 0, 32),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(Controls, 8)
    
    local function CreateControl(icon, color, pos, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.9,
            Position = pos,
            Size = UDim2.new(0, 32, 0, 24),
            ZIndex = 12,
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = color,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = Controls
        })
        AddCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.5, TextSize = 16}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.9, TextSize = 14}, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    CreateControl("−", Colors.Warning, UDim2.new(0, 6, 0.5, -12), function() 
        Window:Toggle() 
    end)
    CreateControl("□", Colors.Info, UDim2.new(0, 44, 0.5, -12), function() 
        -- Maximize placeholder
    end)
    CreateControl("×", Colors.Error, UDim2.new(0, 82, 0.5, -12), function() 
        Window:Destroy() 
    end)
    
    -- Make window draggable by header
    MakeDraggable(Main, Header)
    
    -- ============================================
    -- CONTENT CONTAINER
    -- ============================================
    local ContentContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 68),
        Size = UDim2.new(1, -20, 1, -125),
        ZIndex = 3,
        Parent = ContentArea
    })
    
    -- ============================================
    -- FOOTER
    -- ============================================
    local Footer = Create("Frame", {
        BackgroundColor3 = Colors.Glass,
        BackgroundTransparency = 0.4,
        Position = UDim2.new(0, 10, 1, -52),
        Size = UDim2.new(1, -20, 0, 45),
        ZIndex = 10,
        Parent = ContentArea
    })
    AddCorner(Footer, 10)
    
    -- Footer gradient line
    local FooterLine = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(FooterLine, 1)
    AddGradient(FooterLine, CurrentTheme.Primary, CurrentTheme.Secondary, 0)
    table.insert(Window.ThemeObjects, {Object = FooterLine, Property = "BackgroundColor3", Key = "Primary"})
    
    -- Opacity Label
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -8),
        Size = UDim2.new(0, 55, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "Opacity",
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    -- Opacity Track
    local OpacityTrack = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        Position = UDim2.new(0, 75, 0.5, -5),
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
    AddGradient(OpacityFill, CurrentTheme.Primary, CurrentTheme.Secondary, 0)
    table.insert(Window.ThemeObjects, {Object = OpacityFill, Property = "BackgroundColor3", Key = "Primary"})
    
    local OpacityKnob = Create("Frame", {
        BackgroundColor3 = Colors.Text,
        Position = UDim2.new(1, -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        ZIndex = 13,
        Parent = OpacityTrack
    })
    AddCorner(OpacityKnob, 8)
    local OpacityKnobStroke = AddStroke(OpacityKnob, CurrentTheme.Primary, 2, 0)
    table.insert(Window.ThemeObjects, {Object = OpacityKnobStroke, Property = "Color", Key = "Primary"})
    
    local OpacityValue = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0.5, -8),
        Size = UDim2.new(0, 35, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamBold,
        Text = "100%",
        TextColor3 = CurrentTheme.Primary,
        TextSize = 11,
        Parent = Footer
    })
    table.insert(Window.ThemeObjects, {Object = OpacityValue, Property = "TextColor3", Key = "Primary"})
    
    -- Opacity Slider Logic
    local opacityDragging = false
    local currentOpacity = 1
    
    local function UpdateOpacity(input)
        local pos = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X, 0, 1)
        currentOpacity = pos
        
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -8, 0.5, -8)
        OpacityValue.Text = math.floor(pos * 100) .. "%"
        
        -- Apply transparency to main frame
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
    
    -- Theme Label
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 230, 0.5, -8),
        Size = UDim2.new(0, 45, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "Theme",
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    -- Theme Selector
    local ThemeSelector = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        Position = UDim2.new(0, 280, 0.5, -10),
        Size = UDim2.new(0, 130, 0, 20),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(ThemeSelector, 6)
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = ThemeSelector
    })
    
    local themeButtons = {}
    for name, theme in pairs(Themes) do
        local themeBtn = Create("TextButton", {
            Name = name,
            BackgroundColor3 = theme.Primary,
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 12,
            Text = "",
            AutoButtonColor = false,
            Parent = ThemeSelector
        })
        AddCorner(themeBtn, 8)
        
        if name == CurrentTheme.Name then
            AddStroke(themeBtn, Colors.Text, 2, 0)
        end
        
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
    
    -- Toggle Key Badge
    local ToggleBadge = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        Position = UDim2.new(1, -110, 0.5, -12),
        Size = UDim2.new(0, 95, 0, 24),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(ToggleBadge, 6)
    
    local ToggleBadgeText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12,
        Font = Enum.Font.GothamMedium,
        Text = "🔑 " .. Window.ToggleKey.Name,
        TextColor3 = Colors.TextMuted,
        TextSize = 10,
        Parent = ToggleBadge
    })
    
    -- Toggle Key Handler
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
            Tween(Blur, {Size = 15}, 0.3)
            Tween(MainGlow, {ImageTransparency = 0.85}, 0.3)
        else
            Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            Tween(MainGlow, {ImageTransparency = 1}, 0.3)
            
            task.delay(0.3, function()
                if not self.Visible then 
                    Main.Visible = false 
                end
            end)
        end
    end
    
    function Window:Destroy()
        -- Disconnect all connections
        for _, connection in pairs(self.Connections) do
            pcall(function() connection:Disconnect() end)
        end
        
        -- Cancel all threads
        for _, thread in pairs(self.Threads) do
            pcall(function() task.cancel(thread) end)
        end
        
        -- Animate and destroy
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
        Tween(Blur, {Size = 0}, 0.3)
        
        task.delay(0.4, function()
            pcall(function() ScreenGui:Destroy() end)
            pcall(function() Blur:Destroy() end)
        end)
        
        if getgenv then
            getgenv().EnzoUILib = nil
        end
    end
    
    function Window:SetTheme(themeName)
        if Themes[themeName] then
            CurrentTheme = Themes[themeName]
            Window.Theme = CurrentTheme
            
            -- Update all theme-dependent objects
            for _, obj in pairs(Window.ThemeObjects) do
                if obj.Object and obj.Property and obj.Key then
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
            Tween(Window.CurrentTab.IconLabel, {TextColor3 = Colors.TextMuted}, 0.2)
            
            if Window.CurrentTab.Indicator then
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
            end
            if Window.CurrentTab.Glow then
                Tween(Window.CurrentTab.Glow, {ImageTransparency = 1}, 0.2)
            end
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        TabIcon.Text = tab.Icon
        TabTitle.Text = tab.Name
        
        Tween(tab.Button, {BackgroundTransparency = 0.7}, 0.2)
        Tween(tab.IconLabel, {TextColor3 = CurrentTheme.Primary}, 0.2)
        
        if tab.Indicator then
            Tween(tab.Indicator, {Size = UDim2.new(0, 3, 0.6, 0)}, 0.2, Enum.EasingStyle.Back)
        end
        if tab.Glow then
            Tween(tab.Glow, {ImageTransparency = 0.7}, 0.2)
        end
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
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            BackgroundColor3 = CurrentTheme.Primary,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 50, 0, 50),
            ZIndex = 8,
            Text = "",
            AutoButtonColor = false,
            Parent = TabList
        })
        AddCorner(TabButton, 12)
        
        -- Tab Glow
        local TabGlow = AddGlow(TabButton, CurrentTheme.Primary, 10, 1)
        table.insert(Window.ThemeObjects, {Object = TabGlow, Property = "ImageColor3", Key = "Primary"})
        
        -- Tab Indicator (left line)
        local TabIndicator = Create("Frame", {
            BackgroundColor3 = CurrentTheme.Primary,
            Position = UDim2.new(0, -3, 0.2, 0),
            Size = UDim2.new(0, 3, 0, 0),
            ZIndex = 9,
            Parent = TabButton
        })
        AddCorner(TabIndicator, 2)
        AddGradient(TabIndicator, CurrentTheme.Primary, CurrentTheme.Secondary, 90)
        table.insert(Window.ThemeObjects, {Object = TabIndicator, Property = "BackgroundColor3", Key = "Primary"})
        
        -- Tab Icon
        local TabIconLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 9,
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextColor3 = Colors.TextMuted,
            TextSize = 22,
            Parent = TabButton
        })
        
        -- Tooltip
        local Tooltip = Create("Frame", {
            BackgroundColor3 = Colors.Glass,
            Position = UDim2.new(1, 15, 0.5, -14),
            Size = UDim2.new(0, 0, 0, 28),
            ZIndex = 100,
            ClipsDescendants = true,
            Visible = false,
            Parent = TabButton
        })
        AddCorner(Tooltip, 6)
        AddStroke(Tooltip, CurrentTheme.Primary, 1, 0.5)
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0, 80, 1, 0),
            ZIndex = 101,
            Font = Enum.Font.GothamBold,
            Text = tabName,
            TextColor3 = Colors.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Tooltip
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Primary,
            ScrollBarImageTransparency = 0.3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 4,
            Parent = ContentContainer
        })
        AddPadding(TabContent, 5)
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 12),
            Parent = TabContent
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.IconLabel = TabIconLabel
        Tab.Indicator = TabIndicator
        Tab.Glow = TabGlow
        Tab.Tooltip = Tooltip
        
        -- Hover Effects
        TabButton.MouseEnter:Connect(function()
            Tooltip.Visible = true
            Tween(Tooltip, {Size = UDim2.new(0, 100, 0, 28)}, 0.2, Enum.EasingStyle.Back)
            
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.8}, 0.15)
                Tween(TabIconLabel, {TextColor3 = Colors.TextSecondary}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            Tween(Tooltip, {Size = UDim2.new(0, 0, 0, 28)}, 0.15)
            task.delay(0.15, function() 
                Tooltip.Visible = false 
            end)
            
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
                Tween(TabIconLabel, {TextColor3 = Colors.TextMuted}, 0.15)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then 
            Window:SelectTab(Tab) 
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
                    Size = UDim2.new(0.485, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = sectionSide == "Left" and 1 or 2,
                    Parent = TabContent
                })
                Create("UIListLayout", {
                    Padding = UDim.new(0, 12), 
                    Parent = column
                })
            end
            
            -- Section Card
            local SectionCard = Create("Frame", {
                BackgroundColor3 = Colors.Glass,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            AddCorner(SectionCard, 12)
            AddStroke(SectionCard, Colors.GlassBorder, 1, 0.7)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 45),
                Parent = SectionCard
            })
            
            -- Icon Container
            local IconContainer = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                BackgroundTransparency = 0.85,
                Position = UDim2.new(0, 14, 0.5, -15),
                Size = UDim2.new(0, 30, 0, 30),
                Parent = SectionHeader
            })
            AddCorner(IconContainer, 8)
            table.insert(Window.ThemeObjects, {Object = IconContainer, Property = "BackgroundColor3", Key = "Primary"})
            
            local SectionIconLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = CurrentTheme.Primary,
                TextSize = 15,
                Parent = IconContainer
            })
            table.insert(Window.ThemeObjects, {Object = SectionIconLabel, Property = "TextColor3", Key = "Primary"})
            
            -- Section Title
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
            
            -- Divider with gradient
            local Divider = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                Position = UDim2.new(0, 14, 0, 45),
                Size = UDim2.new(1, -28, 0, 1),
                Parent = SectionCard
            })
            AddGradient(Divider, CurrentTheme.Primary, Color3.fromRGB(50, 50, 70), 0)
            table.insert(Window.ThemeObjects, {Object = Divider, Property = "BackgroundColor3", Key = "Primary"})
            
            -- Section Content
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 50),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionCard
            })
            AddPadding(SectionContent, 5, 14, 12, 12)
            Create("UIListLayout", {
                Padding = UDim.new(0, 8), 
                Parent = SectionContent
            })
            
            Section.Card = SectionCard
            Section.Content = SectionContent
            table.insert(Tab.Sections, Section)
            
            -- ============================================
            -- TOGGLE
            -- ============================================
            function Section:AddToggle(cfg)
                cfg = cfg or {}
                local Toggle = {Value = cfg.Default or false}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.GlassLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 55 or 44),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, cfg.Description and 10 or 0),
                    Size = UDim2.new(1, -80, 0, cfg.Description and 18 or 44),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 28),
                        Size = UDim2.new(1, -80, 0, 18),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                -- Switch
                local Switch = Create("Frame", {
                    BackgroundColor3 = Toggle.Value and Colors.Success or Colors.BackgroundDark,
                    Position = UDim2.new(1, -62, 0.5, -13),
                    Size = UDim2.new(0, 52, 0, 26),
                    Parent = Frame
                })
                AddCorner(Switch, 13)
                
                local SwitchGlow = AddGlow(Switch, Colors.Success, 8, Toggle.Value and 0.7 or 1)
                
                local Knob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = Toggle.Value and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
                    Size = UDim2.new(0, 22, 0, 22),
                    ZIndex = 2,
                    Parent = Switch
                })
                AddCorner(Knob, 11)
                
                local ClickArea = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Frame
                })
                
                ClickArea.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    
                    if Toggle.Value then
                        Tween(Switch, {BackgroundColor3 = Colors.Success}, 0.25)
                        Tween(Knob, {Position = UDim2.new(1, -24, 0.5, -11)}, 0.25, Enum.EasingStyle.Back)
                        Tween(SwitchGlow, {ImageTransparency = 0.7, ImageColor3 = Colors.Success}, 0.25)
                    else
                        Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.25)
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -11)}, 0.25, Enum.EasingStyle.Back)
                        Tween(SwitchGlow, {ImageTransparency = 1}, 0.25)
                    end
                    
                    if cfg.Callback then 
                        cfg.Callback(Toggle.Value) 
                    end
                end)
                
                Frame.MouseEnter:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) 
                end)
                Frame.MouseLeave:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.5}, 0.15) 
                end)
                
                function Toggle:SetValue(v)
                    if Toggle.Value ~= v then
                        Toggle.Value = v
                        if v then
                            Tween(Switch, {BackgroundColor3 = Colors.Success}, 0.2)
                            Tween(Knob, {Position = UDim2.new(1, -24, 0.5, -11)}, 0.2)
                            Tween(SwitchGlow, {ImageTransparency = 0.7, ImageColor3 = Colors.Success}, 0.2)
                        else
                            Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.2)
                            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -11)}, 0.2)
                            Tween(SwitchGlow, {ImageTransparency = 1}, 0.2)
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
                    BackgroundColor3 = Colors.GlassLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 65 or 55),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -75, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                -- Value Badge
                local ValueBadge = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -60, 0, 6),
                    Size = UDim2.new(0, 48, 0, 22),
                    Parent = Frame
                })
                AddCorner(ValueBadge, 6)
                table.insert(Window.ThemeObjects, {Object = ValueBadge, Property = "BackgroundColor3", Key = "Primary"})
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBlack,
                    Text = tostring(Slider.Value) .. (cfg.Suffix or ""),
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 11,
                    Parent = ValueBadge
                })
                table.insert(Window.ThemeObjects, {Object = ValueLabel, Property = "TextColor3", Key = "Primary"})
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                -- Track
                local Track = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundDark,
                    Position = UDim2.new(0, 14, 1, -20),
                    Size = UDim2.new(1, -28, 0, 10),
                    Parent = Frame
                })
                AddCorner(Track, 5)
                
                local pct = (Slider.Value - min) / (max - min)
                
                local Fill = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    Size = UDim2.new(pct, 0, 1, 0),
                    Parent = Track
                })
                AddCorner(Fill, 5)
                AddGradient(Fill, CurrentTheme.Primary, CurrentTheme.Secondary, 0)
                table.insert(Window.ThemeObjects, {Object = Fill, Property = "BackgroundColor3", Key = "Primary"})
                
                -- Fill Glow
                local FillGlow = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.6,
                    Position = UDim2.new(0, 0, 0, -3),
                    Size = UDim2.new(pct, 0, 1, 6),
                    ZIndex = -1,
                    Parent = Track
                })
                AddCorner(FillGlow, 8)
                table.insert(Window.ThemeObjects, {Object = FillGlow, Property = "BackgroundColor3", Key = "Primary"})
                
                local SliderKnob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(pct, -10, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20),
                    ZIndex = 2,
                    Parent = Track
                })
                AddCorner(SliderKnob, 10)
                local KnobStroke = AddStroke(SliderKnob, CurrentTheme.Primary, 2, 0)
                table.insert(Window.ThemeObjects, {Object = KnobStroke, Property = "Color", Key = "Primary"})
                
                local KnobGlow = AddGlow(SliderKnob, CurrentTheme.Primary, 8, 0.6)
                table.insert(Window.ThemeObjects, {Object = KnobGlow, Property = "ImageColor3", Key = "Primary"})
                
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    Slider.Value = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    FillGlow.Size = UDim2.new(pos, 0, 1, 6)
                    SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
                    ValueLabel.Text = tostring(val) .. (cfg.Suffix or "")
                    
                    if cfg.Callback then 
                        cfg.Callback(val) 
                    end
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
                    Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) 
                end)
                Frame.MouseLeave:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.5}, 0.15) 
                end)
                
                function Slider:SetValue(v)
                    local pos = (v - min) / (max - min)
                    Slider.Value = v
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    FillGlow.Size = UDim2.new(pos, 0, 1, 6)
                    SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
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
                    Primary = {c1 = CurrentTheme.Primary, c2 = CurrentTheme.Secondary},
                    Secondary = {c1 = Colors.GlassLight, c2 = Colors.Glass},
                    Success = {c1 = Colors.Success, c2 = Color3.fromRGB(100, 255, 180)},
                    Danger = {c1 = Colors.Error, c2 = Color3.fromRGB(255, 120, 140)}
                }
                local style = styles[cfg.Style or "Primary"] or styles.Primary
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.GlassLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 72 or 50),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 10),
                        Size = UDim2.new(1, -28, 0, 16),
                        Font = Enum.Font.GothamBold,
                        Text = cfg.Title or "Button",
                        TextColor3 = Colors.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                    
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = style.c1,
                    Position = cfg.Description and UDim2.new(0, 12, 1, -32) or UDim2.new(0, 12, 0.5, -15),
                    Size = UDim2.new(1, -24, 0, cfg.Description and 26 or 30),
                    Font = Enum.Font.GothamBlack,
                    Text = cfg.Description and "▶ EXECUTE" or (cfg.Title or "Button"),
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(Btn, 8)
                AddGradient(Btn, style.c1, style.c2, 90)
                
                local BtnGlow = AddGlow(Btn, style.c1, 10, 0.8)
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -22, 0, cfg.Description and 28 or 32)}, 0.15)
                    Tween(BtnGlow, {ImageTransparency = 0.6}, 0.15)
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -24, 0, cfg.Description and 26 or 30)}, 0.15)
                    Tween(BtnGlow, {ImageTransparency = 0.8}, 0.15)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -28, 0, cfg.Description and 24 or 28)}, 0.08)
                    task.delay(0.08, function()
                        Tween(Btn, {Size = UDim2.new(1, -24, 0, cfg.Description and 26 or 30)}, 0.08)
                    end)
                    
                    if cfg.Callback then 
                        cfg.Callback() 
                    end
                end)
                
                Frame.MouseEnter:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) 
                end)
                Frame.MouseLeave:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.5}, 0.15) 
                end)
                
                return {}
            end
            
            -- ============================================
            -- DROPDOWN (WITH SEARCH)
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
                    for _, v in pairs(cfg.Default) do 
                        Dropdown.Value[v] = true 
                    end
                end
                
                local baseH = cfg.Description and 75 or 60
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.GlassLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, baseH),
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -28, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Colors.Glass,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 44 or 32),
                    Size = UDim2.new(1, -24, 0, 26),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(DropBtn, 6)
                AddStroke(DropBtn, CurrentTheme.Primary, 1, 0.7)
                
                local BtnText = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = multi and "Select..." or (cfg.Default or "Select..."),
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropBtn
                })
                
                local Arrow = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBlack,
                    Text = "▼",
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 10,
                    Parent = DropBtn
                })
                table.insert(Window.ThemeObjects, {Object = Arrow, Property = "TextColor3", Key = "Primary"})
                
                -- Dropdown Content
                local Content = Create("Frame", {
                    BackgroundColor3 = Colors.Glass,
                    Position = UDim2.new(0, 12, 0, baseH + 4),
                    Size = UDim2.new(1, -24, 0, 0),
                    ClipsDescendants = true,
                    Parent = Frame
                })
                AddCorner(Content, 8)
                AddStroke(Content, CurrentTheme.Primary, 1, 0.7)
                
                -- Search Box
                local SearchBox = Create("TextBox", {
                    BackgroundColor3 = Colors.BackgroundDark,
                    Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.new(1, -12, 0, 28),
                    Font = Enum.Font.GothamMedium,
                    Text = "",
                    PlaceholderText = "🔍 Search...",
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    Parent = Content
                })
                AddCorner(SearchBox, 6)
                AddPadding(SearchBox, 0, 0, 10, 10)
                
                -- Items List
                local ItemsList = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 40),
                    Size = UDim2.new(1, 0, 1, -40),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = CurrentTheme.Primary,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Content
                })
                AddPadding(ItemsList, 4, 6, 6, 6)
                Create("UIListLayout", {
                    Padding = UDim.new(0, 4), 
                    Parent = ItemsList
                })
                
                local itemBtns = {}
                
                local function createItem(name)
                    local isSel = multi and Dropdown.Value[name] or Dropdown.Value == name
                    
                    local ItemBtn = Create("TextButton", {
                        Name = name,
                        BackgroundColor3 = isSel and CurrentTheme.Primary or Colors.GlassLight,
                        BackgroundTransparency = isSel and 0.6 or 0.3,
                        Size = UDim2.new(1, -8, 0, 30),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = ItemsList
                    })
                    AddCorner(ItemBtn, 6)
                    
                    if multi then
                        local cb = Create("Frame", {
                            BackgroundColor3 = isSel and Colors.Success or Colors.BackgroundDark,
                            Position = UDim2.new(0, 8, 0.5, -9),
                            Size = UDim2.new(0, 18, 0, 18),
                            Parent = ItemBtn
                        })
                        AddCorner(cb, 5)
                        
                        Create("TextLabel", {
                            Name = "Check",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.GothamBlack,
                            Text = isSel and "✓" or "",
                            TextColor3 = Colors.Text,
                            TextSize = 12,
                            Parent = cb
                        })
                    end
                    
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, multi and 32 or 12, 0, 0),
                        Size = UDim2.new(1, multi and -40 or -20, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = name,
                        TextColor3 = isSel and Colors.Text or Colors.TextSecondary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ItemBtn
                    })
                    
                    ItemBtn.MouseEnter:Connect(function()
                        if not (multi and Dropdown.Value[name] or Dropdown.Value == name) then
                            Tween(ItemBtn, {BackgroundTransparency = 0.4, BackgroundColor3 = CurrentTheme.Primary}, 0.1)
                        end
                    end)
                    
                    ItemBtn.MouseLeave:Connect(function()
                        local sel = multi and Dropdown.Value[name] or Dropdown.Value == name
                        Tween(ItemBtn, {
                            BackgroundTransparency = sel and 0.6 or 0.3, 
                            BackgroundColor3 = sel and CurrentTheme.Primary or Colors.GlassLight
                        }, 0.1)
                    end)
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[name] = not Dropdown.Value[name]
                            local nowSel = Dropdown.Value[name]
                            
                            local cb = ItemBtn:FindFirstChild("Frame")
                            if cb then
                                Tween(cb, {BackgroundColor3 = nowSel and Colors.Success or Colors.BackgroundDark}, 0.15)
                                local check = cb:FindFirstChild("Check")
                                if check then check.Text = nowSel and "✓" or "" end
                            end
                            
                            Tween(ItemBtn, {
                                BackgroundColor3 = nowSel and CurrentTheme.Primary or Colors.GlassLight, 
                                BackgroundTransparency = nowSel and 0.6 or 0.3
                            }, 0.15)
                            
                            local textLabel = ItemBtn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = nowSel and Colors.Text or Colors.TextSecondary
                            end
                            
                            local sel = {}
                            for k, v in pairs(Dropdown.Value) do 
                                if v then 
                                    table.insert(sel, k) 
                                end 
                            end
                            BtnText.Text = #sel > 0 and table.concat(sel, ", ") or "Select..."
                            BtnText.TextColor3 = #sel > 0 and Colors.Text or Colors.TextSecondary
                            
                            if cfg.Callback then 
                                cfg.Callback(Dropdown.Value) 
                            end
                        else
                            Dropdown.Value = name
                            BtnText.Text = name
                            BtnText.TextColor3 = Colors.Text
                            
                            for n, btn in pairs(itemBtns) do
                                local isThis = n == name
                                Tween(btn, {
                                    BackgroundColor3 = isThis and CurrentTheme.Primary or Colors.GlassLight, 
                                    BackgroundTransparency = isThis and 0.6 or 0.3
                                }, 0.15)
                                
                                local textLabel = btn:FindFirstChild("Text")
                                if textLabel then
                                    textLabel.TextColor3 = isThis and Colors.Text or Colors.TextSecondary
                                end
                            end
                            
                            if cfg.Callback then 
                                cfg.Callback(name) 
                            end
                            
                            -- Close dropdown
                            Dropdown.Open = false
                            Tween(Arrow, {Rotation = 0}, 0.2)
                            Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                            Tween(Content, {Size = UDim2.new(1, -24, 0, 0)}, 0.25)
                        end
                    end)
                    
                    return ItemBtn
                end
                
                for _, item in pairs(items) do
                    itemBtns[item] = createItem(item)
                end
                
                -- Search functionality
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local s = SearchBox.Text:lower()
                    for name, btn in pairs(itemBtns) do
                        btn.Visible = s == "" or name:lower():find(s, 1, true) ~= nil
                    end
                end)
                
                -- Toggle dropdown
                DropBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        Tween(Arrow, {Rotation = 180}, 0.2)
                        local cnt = math.min(#items, 5)
                        local contentH = 46 + (cnt * 34) + 10
                        local totalH = baseH + 8 + contentH
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, totalH)}, 0.3, Enum.EasingStyle.Back)
                        Tween(Content, {Size = UDim2.new(1, -24, 0, contentH)}, 0.3, Enum.EasingStyle.Back)
                    else
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                        Tween(Content, {Size = UDim2.new(1, -24, 0, 0)}, 0.25)
                    end
                end)
                
                Frame.MouseEnter:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) 
                end)
                Frame.MouseLeave:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.5}, 0.15) 
                end)
                
                function Dropdown:SetItems(newItems)
                    Dropdown.Items = newItems
                    for _, c in pairs(ItemsList:GetChildren()) do
                        if c:IsA("TextButton") then 
                            c:Destroy() 
                        end
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
                                cb.BackgroundColor3 = sel and Colors.Success or Colors.BackgroundDark
                                local check = cb:FindFirstChild("Check")
                                if check then check.Text = sel and "✓" or "" end
                            end
                            btn.BackgroundColor3 = sel and CurrentTheme.Primary or Colors.GlassLight
                            btn.BackgroundTransparency = sel and 0.6 or 0.3
                            local textLabel = btn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = sel and Colors.Text or Colors.TextSecondary
                            end
                        end
                        local selected = {}
                        for k, val in pairs(v) do 
                            if val then 
                                table.insert(selected, k) 
                            end 
                        end
                        BtnText.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                    else
                        Dropdown.Value = v
                        BtnText.Text = v
                        BtnText.TextColor3 = Colors.Text
                        for name, btn in pairs(itemBtns) do
                            local isThis = name == v
                            btn.BackgroundColor3 = isThis and CurrentTheme.Primary or Colors.GlassLight
                            btn.BackgroundTransparency = isThis and 0.6 or 0.3
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
                    BackgroundColor3 = Colors.GlassLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 75 or 60),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -28, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Input",
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local InputBox = Create("TextBox", {
                    BackgroundColor3 = Colors.Glass,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 44 or 32),
                    Size = UDim2.new(1, -24, 0, 26),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "Enter text...",
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                    Parent = Frame
                })
                AddCorner(InputBox, 6)
                AddStroke(InputBox, CurrentTheme.Primary, 1, 0.7)
                AddPadding(InputBox, 0, 0, 10, 10)
                
                InputBox.Focused:Connect(function()
                    local stroke = InputBox:FindFirstChildOfClass("UIStroke")
                    if stroke then 
                        Tween(stroke, {Transparency = 0.3}, 0.2) 
                    end
                end)
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    local stroke = InputBox:FindFirstChildOfClass("UIStroke")
                    if stroke then 
                        Tween(stroke, {Transparency = 0.7}, 0.2) 
                    end
                    Textbox.Value = InputBox.Text
                    
                    if cfg.Callback then 
                        cfg.Callback(InputBox.Text, enterPressed) 
                    end
                end)
                
                Frame.MouseEnter:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) 
                end)
                Frame.MouseLeave:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.5}, 0.15) 
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
                    BackgroundColor3 = Colors.GlassLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 55 or 44),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, cfg.Description and 10 or 0),
                    Size = UDim2.new(1, -100, 0, cfg.Description and 18 or 44),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Keybind",
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 28),
                        Size = UDim2.new(1, -100, 0, 18),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local KeyBtn = Create("TextButton", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -85, 0.5, -14),
                    Size = UDim2.new(0, 75, 0, 28),
                    Font = Enum.Font.GothamBold,
                    Text = Keybind.Value.Name,
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 11,
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
                            
                            if cfg.Callback then 
                                cfg.Callback(input.KeyCode) 
                            end
                        end
                    elseif not processed and input.KeyCode == Keybind.Value then
                        if cfg.OnPress then 
                            cfg.OnPress() 
                        end
                    end
                end))
                
                Frame.MouseEnter:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) 
                end)
                Frame.MouseLeave:Connect(function() 
                    Tween(Frame, {BackgroundTransparency = 0.5}, 0.15) 
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
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 11,
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
                    BackgroundColor3 = Colors.GlassLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                AddPadding(Frame, 12)
                
                Create("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    Parent = Frame
                })
                
                local TitleLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Title",
                    TextColor3 = Colors.Text,
                    TextSize = 13,
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
                    TextSize = 11,
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
                Position = UDim2.new(1, -350, 0, 20),
                Size = UDim2.new(0, 330, 0, 0),
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
            BackgroundColor3 = Colors.Glass,
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 1001,
            Parent = Container
        })
        AddCorner(Notif, 12)
        AddStroke(Notif, data.col, 1.5, 0.4)
        
        local NotifGlow = AddGlow(Notif, data.col, 15, 0.75)
        
        -- Accent Line
        local AccentLine = Create("Frame", {
            BackgroundColor3 = data.col,
            Size = UDim2.new(0, 4, 1, 0),
            ZIndex = 1002,
            Parent = Notif
        })
        AddCorner(AccentLine, 2)
        
        -- Gradient overlay
        local GradientBG = Create("Frame", {
            BackgroundColor3 = data.col,
            BackgroundTransparency = 0.9,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1001,
            Parent = Notif
        })
        AddCorner(GradientBG, 12)
        AddGradient(GradientBG, data.col, Colors.Glass, 0)
        
        -- Icon
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 14),
            Size = UDim2.new(0, 26, 0, 26),
            ZIndex = 1003,
            Font = Enum.Font.GothamBlack,
            Text = data.icon,
            TextSize = 20,
            Parent = Notif
        })
        
        -- Title
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 52, 0, 12),
            Size = UDim2.new(1, -70, 0, 20),
            ZIndex = 1003,
            Font = Enum.Font.GothamBlack,
            Text = cfg.Title or "Notification",
            TextColor3 = Colors.Text,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif
        })
        
        -- Content
        local ContentLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 52, 0, 34),
            Size = UDim2.new(1, -70, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 1003,
            Font = Enum.Font.Gotham,
            Text = cfg.Content or "",
            TextColor3 = Colors.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notif
        })
        
        -- Progress Bar
        local ProgressBG = Create("Frame", {
            BackgroundColor3 = Colors.BackgroundDark,
            Position = UDim2.new(0, 0, 1, -4),
            Size = UDim2.new(1, 0, 0, 4),
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
        
        -- Close Button
        local CloseBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -32, 0, 10),
            Size = UDim2.new(0, 22, 0, 22),
            ZIndex = 1004,
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Colors.TextMuted,
            TextSize = 18,
            Parent = Notif
        })
        
        local notifClosed = false
        
        local function closeNotif()
            if notifClosed then return end
            notifClosed = true
            Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(NotifGlow, {ImageTransparency = 1}, 0.3)
            task.delay(0.3, function() 
                pcall(function() Notif:Destroy() end) 
            end)
        end
        
        CloseBtn.MouseButton1Click:Connect(closeNotif)
        CloseBtn.MouseEnter:Connect(function()
            Tween(CloseBtn, {TextColor3 = Colors.Text}, 0.1)
        end)
        CloseBtn.MouseLeave:Connect(function()
            Tween(CloseBtn, {TextColor3 = Colors.TextMuted}, 0.1)
        end)
        
        -- Animate notification
        table.insert(Window.Threads, task.spawn(function()
            task.wait(0.05)
            local height = 60 + ContentLabel.TextBounds.Y
            
            Notif.Position = UDim2.new(1, 30, 0, 0)
            Notif.Size = UDim2.new(1, 0, 0, height)
            
            Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
            Tween(NotifGlow, {ImageTransparency = 0.75}, 0.3)
            
            Tween(Progress, {Size = UDim2.new(0, 0, 1, 0)}, cfg.Duration or 5, Enum.EasingStyle.Linear)
            
            task.wait(cfg.Duration or 5)
            closeNotif()
        end))
    end
    
    -- ============================================
    -- MOBILE TOGGLE BUTTON
    -- ============================================
    local MobileBtn = Create("TextButton", {
        Name = "MobileToggle",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 15, 0.5, -25),
        Size = UDim2.new(0, 50, 0, 50),
        ZIndex = 999,
        Font = Enum.Font.GothamBlack,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui
    })
    AddCorner(MobileBtn, 25)
    AddGradient(MobileBtn, CurrentTheme.Primary, CurrentTheme.Secondary, 135)
    
    local MobileGlow = AddGlow(MobileBtn, CurrentTheme.Primary, 12, 0.7)
    table.insert(Window.ThemeObjects, {Object = MobileGlow, Property = "ImageColor3", Key = "Primary"})
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1000,
        Font = Enum.Font.GothamBlack,
        Text = "E",
        TextColor3 = Colors.Text,
        TextSize = 24,
        Parent = MobileBtn
    })
    
    -- Mobile draggable
    local mobileDrag, mobileStart, mobileStartPos
    MobileBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mobileDrag = true
            mobileStart = input.Position
            mobileStartPos = MobileBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mobileDrag = false
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
        Tween(MobileGlow, {ImageTransparency = 0.5}, 0.15)
    end)
    MobileBtn.MouseLeave:Connect(function()
        Tween(MobileBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.15)
        Tween(MobileGlow, {ImageTransparency = 0.7}, 0.15)
    end)
    
    -- Update mobile button on toggle
    local origToggle = Window.Toggle
    Window.Toggle = function(self)
        self.Visible = not self.Visible
        
        if self.Visible then
            Main.Visible = true
            Main.Size = UDim2.new(0, size.X.Offset, 0, 0)
            Main.BackgroundTransparency = 1
            
            Tween(Main, {Size = size, BackgroundTransparency = 1 - (currentOpacity * 0.95)}, 0.5, Enum.EasingStyle.Back)
            Tween(Blur, {Size = 15}, 0.3)
            Tween(MainGlow, {ImageTransparency = 0.85}, 0.3)
            Tween(MobileBtn, {Position = UDim2.new(0, -60, 0.5, -25)}, 0.3)
        else
            Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            Tween(MainGlow, {ImageTransparency = 1}, 0.3)
            Tween(MobileBtn, {Position = UDim2.new(0, 15, 0.5, -25)}, 0.3)
            
            task.delay(0.3, function()
                if not self.Visible then 
                    Main.Visible = false 
                end
            end)
        end
    end
    
    -- Store in global
    if getgenv then
        getgenv().EnzoUILib = Window
    end
    
    return Window
end

-- ============================================
-- RETURN LIBRARY (WAJIB ADA!)
-- ============================================
return EnzoLib