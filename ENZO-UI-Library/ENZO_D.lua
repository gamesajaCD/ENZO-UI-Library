--[[
    ENZO UI LIBRARY - Design D: Hybrid (C + B)
    Version: 1.0.0
    Author: ENZO-YT
    t
    Style: Card Based + Sidebar Modern (iOS/Material + Discord)
    Kombinasi terbaik dari Design B & C
]]

local EnzoLib = {}
EnzoLib.__index = EnzoLib

-- ============================================================
-- [[ SERVICES ]]
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- [[ CLEANUP SYSTEM ]]
-- ============================================================
if getgenv().EnzoUILib then
    pcall(function()
        getgenv().EnzoUILib:Destroy()
    end)
end

pcall(function()
    local oldBlur = Lighting:FindFirstChild("EnzoUIBlur")
    if oldBlur then oldBlur:Destroy() end
end)

-- ============================================================
-- [[ UTILITY FUNCTIONS ]]
-- ============================================================
local function Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
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
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 12),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Color3.fromRGB(255, 255, 255),
        Thickness = thickness or 1,
        Transparency = transparency or 0.9,
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

local function AddShadow(parent, transparency)
    return Create("ImageLabel", {
        Name = "Shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = transparency or 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
end

local function AddGradient(parent, color1, color2, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        }),
        Rotation = rotation or 90,
        Parent = parent
    })
end

-- ============================================================
-- [[ THEME COLORS ]]
-- ============================================================
local Theme = {
    -- Main Background
    Background = Color3.fromRGB(12, 12, 16),
    BackgroundSecondary = Color3.fromRGB(18, 18, 24),
    
    -- Sidebar
    Sidebar = Color3.fromRGB(16, 16, 20),
    SidebarHover = Color3.fromRGB(28, 28, 35),
    
    -- Cards
    Card = Color3.fromRGB(24, 24, 32),
    CardHover = Color3.fromRGB(32, 32, 42),
    CardBorder = Color3.fromRGB(40, 40, 50),
    
    -- Elements
    Element = Color3.fromRGB(32, 32, 42),
    ElementHover = Color3.fromRGB(42, 42, 55),
    ElementBorder = Color3.fromRGB(50, 50, 62),
    
    -- Accent (Blue)
    Accent = Color3.fromRGB(88, 101, 242),
    AccentLight = Color3.fromRGB(118, 131, 255),
    AccentDark = Color3.fromRGB(68, 81, 200),
    
    -- Status Colors
    Green = Color3.fromRGB(87, 242, 135),
    Red = Color3.fromRGB(248, 81, 73),
    Orange = Color3.fromRGB(255, 159, 28),
    Yellow = Color3.fromRGB(250, 212, 42),
    Purple = Color3.fromRGB(190, 100, 255),
    Teal = Color3.fromRGB(69, 210, 220),
    Pink = Color3.fromRGB(255, 105, 180),
    
    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(185, 185, 195),
    TextMuted = Color3.fromRGB(130, 130, 145),
    TextDisabled = Color3.fromRGB(85, 85, 100),
    
    -- Misc
    Divider = Color3.fromRGB(45, 45, 58),
    Glass = Color3.fromRGB(255, 255, 255),
}

-- ============================================================
-- [[ MAIN LIBRARY ]]
-- ============================================================

function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "v1.0.0"
    local size = config.Size or UDim2.new(0, 680, 0, 460)
    local sidebarWidth = 65
    local opacity = config.Opacity or 0
    local blurEnabled = config.Blur ~= false
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Opacity = opacity
    Window.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    Window.Visible = true
    Window.BlurEnabled = blurEnabled
    
    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "EnzoUI_D_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    Window.ScreenGui = ScreenGui
    
    -- Blur Effect
    local BlurEffect = Create("BlurEffect", {
        Name = "EnzoUIBlur",
        Size = blurEnabled and 10 or 0,
        Parent = Lighting
    })
    Window.BlurEffect = BlurEffect
    
    -- ============================================================
    -- [[ MAIN FRAME ]]
    -- ============================================================
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        ClipsDescendants = true
    })
    AddCorner(MainFrame, 14)
    AddShadow(MainFrame, 0.4)
    
    Window.MainFrame = MainFrame
    
    -- Glass Overlay
    local GlassOverlay = Create("Frame", {
        Name = "GlassOverlay",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Glass,
        BackgroundTransparency = 0.97,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0
    })
    AddCorner(GlassOverlay, 14)
    
    -- ============================================================
    -- [[ SIDEBAR (dari Design B) ]]
    -- ============================================================
    
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = opacity * 0.3,
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        ZIndex = 10
    })
    AddCorner(Sidebar, 14)
    
    -- Fix right side of sidebar corner
    local SidebarFix = Create("Frame", {
        Name = "Fix",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = opacity * 0.3,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        ZIndex = 9
    })
    
    -- Logo Area
    local LogoArea = Create("Frame", {
        Name = "LogoArea",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 65),
        ZIndex = 11
    })
    
    -- Logo Icon (Card Style dari C)
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        Parent = LogoArea,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0.5, -22, 0.5, -22),
        Size = UDim2.new(0, 44, 0, 44),
        ZIndex = 12
    })
    AddCorner(LogoContainer, 12)
    AddGradient(LogoContainer, Theme.AccentLight, Theme.AccentDark, 135)
    AddShadow(LogoContainer, 0.6)
    
    local LogoText = Create("TextLabel", {
        Name = "Logo",
        Parent = LogoContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "E",
        TextColor3 = Theme.TextPrimary,
        TextSize = 24,
        ZIndex = 13
    })
    
    -- Divider
    local LogoDivider = Create("Frame", {
        Name = "Divider",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Divider,
        Position = UDim2.new(0.15, 0, 0, 70),
        Size = UDim2.new(0.7, 0, 0, 1),
        ZIndex = 11
    })
    
    -- Tab List
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -130),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 11
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabList,
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    AddPadding(TabList, 5)
    
    -- Bottom Divider
    local BottomDivider = Create("Frame", {
        Name = "BottomDivider",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Divider,
        Position = UDim2.new(0.15, 0, 1, -50),
        Size = UDim2.new(0.7, 0, 0, 1),
        ZIndex = 11
    })
    
    MakeDraggable(MainFrame, LogoArea)
    
    -- ============================================================
    -- [[ CONTENT AREA ]]
    -- ============================================================
    
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, sidebarWidth, 0, 0),
        Size = UDim2.new(1, -sidebarWidth, 1, 0),
        ZIndex = 2
    })
    
    -- Header (Card Style dari C)
    local Header = Create("Frame", {
        Name = "Header",
        Parent = ContentArea,
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = opacity * 0.5,
        Size = UDim2.new(1, 0, 0, 55),
        ZIndex = 8
    })
    AddCorner(Header, 14)
    
    local HeaderFix = Create("Frame", {
        Name = "Fix",
        Parent = Header,
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = opacity * 0.5,
        Position = UDim2.new(0, 0, 1, -14),
        Size = UDim2.new(1, -14, 0, 14),
        ZIndex = 7
    })
    
    -- Tab Title
    local TabTitleContainer = Create("Frame", {
        Name = "TitleContainer",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        ZIndex = 9
    })
    
    local TabIcon = Create("TextLabel", {
        Name = "Icon",
        Parent = TabTitleContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "🏠",
        TextSize = 18,
        ZIndex = 10
    })
    
    local TabTitle = Create("TextLabel", {
        Name = "Title",
        Parent = TabTitleContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 10),
        Size = UDim2.new(1, -40, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })
    
    local TabSubtitle = Create("TextLabel", {
        Name = "Subtitle",
        Parent = TabTitleContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 28),
        Size = UDim2.new(1, -40, 0, 14),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })
    
    -- Window Controls (macOS style dari C)
    local Controls = Create("Frame", {
        Name = "Controls",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -90, 0.5, -8),
        Size = UDim2.new(0, 70, 0, 16),
        ZIndex = 9
    })
    
    local ControlsLayout = Create("UIListLayout", {
        Parent = Controls,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8)
    })
    
    local function CreateControlDot(name, color, hoverColor, callback)
        local dot = Create("TextButton", {
            Name = name,
            Parent = Controls,
            BackgroundColor3 = color,
            Size = UDim2.new(0, 14, 0, 14),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 10
        })
        AddCorner(dot, 7)
        
        local icon = Create("TextLabel", {
            Name = "Icon",
            Parent = dot,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 9,
            TextTransparency = 1,
            ZIndex = 11
        })
        
        dot.MouseEnter:Connect(function()
            Tween(dot, {BackgroundColor3 = hoverColor, Size = UDim2.new(0, 16, 0, 16)}, 0.15)
            Tween(icon, {TextTransparency = 0.2}, 0.15)
        end)
        
        dot.MouseLeave:Connect(function()
            Tween(dot, {BackgroundColor3 = color, Size = UDim2.new(0, 14, 0, 14)}, 0.15)
            Tween(icon, {TextTransparency = 1}, 0.15)
        end)
        
        dot.MouseButton1Click:Connect(callback)
        
        return dot, icon
    end
    
    local closeDot, closeIcon = CreateControlDot("Close", Theme.Red, Color3.fromRGB(255, 110, 100), function()
        Window:Destroy()
    end)
    closeIcon.Text = "✕"
    
    local minDot, minIcon = CreateControlDot("Minimize", Theme.Orange, Color3.fromRGB(255, 185, 50), function()
        Window:Toggle()
    end)
    minIcon.Text = "−"
    
    local maxDot, maxIcon = CreateControlDot("Maximize", Theme.Green, Color3.fromRGB(110, 255, 150), function()
        -- Future
    end)
    maxIcon.Text = "+"
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -105),
        ZIndex = 3
    })
    
    -- ============================================================
    -- [[ FOOTER ]]
    -- ============================================================
    
    local Footer = Create("Frame", {
        Name = "Footer",
        Parent = ContentArea,
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = opacity * 0.5,
        Position = UDim2.new(0, 0, 1, -50),
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 8
    })
    AddCorner(Footer, 14)
    
    local FooterFix = Create("Frame", {
        Name = "Fix",
        Parent = Footer,
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = opacity * 0.5,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -14, 0, 14),
        ZIndex = 7
    })
    
    -- Opacity Section
    local OpacitySection = Create("Frame", {
        Name = "OpacitySection",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -12),
        Size = UDim2.new(0, 170, 0, 24),
        ZIndex = 9
    })
    
    local OpacityIcon = Create("TextLabel", {
        Name = "Icon",
        Parent = OpacitySection,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "☀",
        TextColor3 = Theme.TextMuted,
        TextSize = 14,
        ZIndex = 10
    })
    
    local OpacitySliderBG = Create("Frame", {
        Name = "SliderBG",
        Parent = OpacitySection,
        BackgroundColor3 = Theme.Element,
        Position = UDim2.new(0, 25, 0.5, -8),
        Size = UDim2.new(0, 100, 0, 16),
        ZIndex = 10
    })
    AddCorner(OpacitySliderBG, 8)
    
    local OpacityTrack = Create("Frame", {
        Name = "Track",
        Parent = OpacitySliderBG,
        BackgroundColor3 = Theme.Divider,
        Position = UDim2.new(0, 6, 0.5, -2),
        Size = UDim2.new(1, -12, 0, 4),
        ZIndex = 11
    })
    AddCorner(OpacityTrack, 2)
    
    local OpacityFill = Create("Frame", {
        Name = "Fill",
        Parent = OpacityTrack,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1 - opacity, 0, 1, 0),
        ZIndex = 12
    })
    AddCorner(OpacityFill, 2)
    
    local OpacityKnob = Create("Frame", {
        Name = "Knob",
        Parent = OpacityTrack,
        BackgroundColor3 = Theme.TextPrimary,
        Position = UDim2.new(1 - opacity, -7, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        ZIndex = 13
    })
    AddCorner(OpacityKnob, 7)
    AddStroke(OpacityKnob, Theme.Accent, 2, 0)
    
    local OpacityLabel = Create("TextLabel", {
        Name = "Label",
        Parent = OpacitySection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 130, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = math.floor((1 - opacity) * 100) .. "%",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        ZIndex = 10
    })
    
    -- Opacity Logic
    local opacityDragging = false
    
    local function UpdateAllOpacity(newOpacity)
        Window.Opacity = newOpacity
        MainFrame.BackgroundTransparency = newOpacity
        Sidebar.BackgroundTransparency = newOpacity * 0.3
        SidebarFix.BackgroundTransparency = newOpacity * 0.3
        Header.BackgroundTransparency = newOpacity * 0.5
        HeaderFix.BackgroundTransparency = newOpacity * 0.5
        Footer.BackgroundTransparency = newOpacity * 0.5
        FooterFix.BackgroundTransparency = newOpacity * 0.5
        GlassOverlay.BackgroundTransparency = 0.97 + (newOpacity * 0.02)
        
        if Window.BlurEnabled then
            BlurEffect.Size = math.max(0, 10 - (newOpacity * 10))
        end
    end
    
    local function UpdateOpacitySlider(input)
        local pos = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X, 0, 1)
        local newOpacity = 1 - pos
        
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -7, 0.5, -7)
        OpacityLabel.Text = math.floor(pos * 100) .. "%"
        
        UpdateAllOpacity(newOpacity)
    end
    
    OpacitySliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = true
            UpdateOpacitySlider(input)
        end
    end)
    
    OpacitySliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateOpacitySlider(input)
        end
    end)
    
    -- Toggle Key Badge
    local ToggleKeyBadge = Create("Frame", {
        Name = "ToggleKeyBadge",
        Parent = Footer,
        BackgroundColor3 = Theme.Element,
        Position = UDim2.new(1, -115, 0.5, -12),
        Size = UDim2.new(0, 100, 0, 24),
        ZIndex = 9
    })
    AddCorner(ToggleKeyBadge, 6)
    
    local ToggleKeyLabel = Create("TextLabel", {
        Name = "Label",
        Parent = ToggleKeyBadge,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = "🔑 " .. Window.ToggleKey.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        ZIndex = 10
    })
    
    -- Toggle Key Handler
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            Window:Toggle()
        end
    end)
    
    -- ============================================================
    -- [[ WINDOW METHODS ]]
    -- ============================================================
    
    function Window:Toggle()
        self.Visible = not self.Visible
        
        if self.Visible then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, size.X.Offset, 0, 0)
            MainFrame.BackgroundTransparency = 1
            
            Tween(MainFrame, {Size = size, BackgroundTransparency = self.Opacity}, 0.4, Enum.EasingStyle.Back)
            
            if self.BlurEnabled then
                Tween(BlurEffect, {Size = 10 - (self.Opacity * 10)}, 0.3)
            end
        else
            Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3).Completed:Connect(function()
                if not self.Visible then
                    MainFrame.Visible = false
                end
            end)
            
            if self.BlurEnabled then
                Tween(BlurEffect, {Size = 0}, 0.3)
            end
        end
    end
    
    function Window:Destroy()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3).Completed:Connect(function()
            ScreenGui:Destroy()
            BlurEffect:Destroy()
        end)
        getgenv().EnzoUILib = nil
    end
    
    function Window:SetOpacity(value)
        UpdateAllOpacity(value)
        local pos = 1 - value
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -7, 0.5, -7)
        OpacityLabel.Text = math.floor(pos * 100) .. "%"
    end
    
    -- ============================================================
    -- [[ TAB SYSTEM (Sidebar dari B, Visual dari C) ]]
    -- ============================================================
    
    function Window:AddTab(config)
        config = config or {}
        local tabName = config.Title or "Tab"
        local tabIcon = config.Icon or "📁"
        
        local Tab = {}
        Tab.Name = tabName
        Tab.Icon = tabIcon
        Tab.Sections = {}
        
        -- Tab Button (Fixed size, tidak melebar)
        local TabButton = Create("TextButton", {
            Name = tabName,
            Parent = TabList,
            BackgroundColor3 = Theme.SidebarHover,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 48, 0, 48),
            Font = Enum.Font.GothamBold,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 12
        })
        AddCorner(TabButton, 12)
        
        -- Icon
        local TabIconLabel = Create("TextLabel", {
            Name = "Icon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextColor3 = Theme.TextMuted,
            TextSize = 20,
            ZIndex = 13
        })
        
        -- Active Indicator (left bar)
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            Parent = TabButton,
            BackgroundColor3 = Theme.Accent,
            Position = UDim2.new(0, -6, 0.25, 0),
            Size = UDim2.new(0, 4, 0.5, 0),
            Visible = false,
            ZIndex = 13
        })
        AddCorner(TabIndicator, 2)
        
        -- Tooltip
        local TabTooltip = Create("Frame", {
            Name = "Tooltip",
            Parent = TabButton,
            BackgroundColor3 = Theme.Card,
            Position = UDim2.new(1, 12, 0.5, -14),
            Size = UDim2.new(0, 0, 0, 28),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 100
        })
        AddCorner(TabTooltip, 6)
        AddShadow(TabTooltip, 0.7)
        
        local TooltipText = Create("TextLabel", {
            Name = "Text",
            Parent = TabTooltip,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0, 100, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = Theme.TextPrimary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 0.3,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 4
        })
        AddPadding(TabContent, 12)
        
        local TabContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Indicator = TabIndicator
        Tab.IconLabel = TabIconLabel
        Tab.Tooltip = TabTooltip
        
        -- Hover Effects
        TabButton.MouseEnter:Connect(function()
            TabTooltip.Visible = true
            Tween(TabTooltip, {Size = UDim2.new(0, 100, 0, 28)}, 0.2, Enum.EasingStyle.Back)
            
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.15)
                Tween(TabIconLabel, {TextColor3 = Theme.TextSecondary}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            Tween(TabTooltip, {Size = UDim2.new(0, 0, 0, 28)}, 0.15).Completed:Connect(function()
                TabTooltip.Visible = false
            end)
            
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
                Tween(TabIconLabel, {TextColor3 = Theme.TextMuted}, 0.15)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        -- ============================================================
        -- [[ SECTION SYSTEM (Card Style dari C) ]]
        -- ============================================================
        
        function Tab:AddSection(config)
            config = config or {}
            local sectionName = config.Title or "Section"
            local sectionSide = config.Side or "Left"
            local sectionIcon = config.Icon or "⚡"
            
            local Section = {}
            Section.Name = sectionName
            Section.Elements = {}
            
            -- Find or create column
            local columnName = sectionSide .. "Column"
            local column = TabContent:FindFirstChild(columnName)
            
            if not column then
                column = Create("Frame", {
                    Name = columnName,
                    Parent = TabContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.485, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = sectionSide == "Left" and 1 or 2
                })
                
                Create("UIListLayout", {
                    Parent = column,
                    Padding = UDim.new(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
            
            -- Section Card (Beautiful Card dari C)
            local SectionCard = Create("Frame", {
                Name = sectionName,
                Parent = column,
                BackgroundColor3 = Theme.Card,
                BackgroundTransparency = 0.15,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddCorner(SectionCard, 12)
            AddStroke(SectionCard, Theme.CardBorder, 1, 0.6)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                Name = "Header",
                Parent = SectionCard,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42)
            })
            
            -- Icon Badge
            local IconBadge = Create("Frame", {
                Name = "IconBadge",
                Parent = SectionHeader,
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.85,
                Position = UDim2.new(0, 14, 0.5, -13),
                Size = UDim2.new(0, 26, 0, 26)
            })
            AddCorner(IconBadge, 7)
            
            local IconText = Create("TextLabel", {
                Name = "Icon",
                Parent = IconBadge,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = Theme.Accent,
                TextSize = 13
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 48, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                Name = "Content",
                Parent = SectionCard,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 42),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddPadding(SectionContent, 0, 14, 12, 12)
            
            Create("UIListLayout", {
                Parent = SectionContent,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            Section.Card = SectionCard
            Section.Content = SectionContent
            
            table.insert(Tab.Sections, Section)
            
            -- ============================================================
            -- [[ ELEMENT: TOGGLE (iOS Style) ]]
            -- ============================================================
            
            function Section:AddToggle(config)
                config = config or {}
                local toggleName = config.Title or "Toggle"
                local toggleDefault = config.Default or false
                local toggleCallback = config.Callback or function() end
                local toggleDescription = config.Description or nil
                
                local Toggle = {}
                Toggle.Value = toggleDefault
                
                local ToggleFrame = Create("Frame", {
                    Name = toggleName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, toggleDescription and 54 or 42)
                })
                AddCorner(ToggleFrame, 10)
                
                local ToggleTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, toggleDescription and 10 or 0),
                    Size = UDim2.new(1, -80, 0, toggleDescription and 18 or 42),
                    Font = Enum.Font.GothamMedium,
                    Text = toggleName,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if toggleDescription then
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = ToggleFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 28),
                        Size = UDim2.new(1, -80, 0, 18),
                        Font = Enum.Font.Gotham,
                        Text = toggleDescription,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                -- iOS Switch
                local Switch = Create("Frame", {
                    Name = "Switch",
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggleDefault and Theme.Green or Theme.Element,
                    Position = UDim2.new(1, -60, 0.5, -13),
                    Size = UDim2.new(0, 48, 0, 26)
                })
                AddCorner(Switch, 13)
                
                local Knob = Create("Frame", {
                    Name = "Knob",
                    Parent = Switch,
                    BackgroundColor3 = Theme.TextPrimary,
                    Position = toggleDefault and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
                    Size = UDim2.new(0, 22, 0, 22)
                })
                AddCorner(Knob, 11)
                
                local function UpdateToggle()
                    Toggle.Value = not Toggle.Value
                    
                    if Toggle.Value then
                        Tween(Switch, {BackgroundColor3 = Theme.Green}, 0.2)
                        Tween(Knob, {Position = UDim2.new(1, -24, 0.5, -11)}, 0.2, Enum.EasingStyle.Back)
                    else
                        Tween(Switch, {BackgroundColor3 = Theme.Element}, 0.2)
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -11)}, 0.2, Enum.EasingStyle.Back)
                    end
                    
                    toggleCallback(Toggle.Value)
                end
                
                local ClickArea = Create("TextButton", {
                    Name = "ClickArea",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                ClickArea.MouseButton1Click:Connect(UpdateToggle)
                
                ToggleFrame.MouseEnter:Connect(function()
                    Tween(ToggleFrame, {BackgroundTransparency = 0.2}, 0.15)
                end)
                ToggleFrame.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {BackgroundTransparency = 0.4}, 0.15)
                end)
                
                function Toggle:SetValue(value)
                    if Toggle.Value ~= value then
                        UpdateToggle()
                    end
                end
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- ============================================================
            -- [[ ELEMENT: SLIDER ]]
            -- ============================================================
            
            function Section:AddSlider(config)
                config = config or {}
                local sliderName = config.Title or "Slider"
                local sliderMin = config.Min or 0
                local sliderMax = config.Max or 100
                local sliderDefault = config.Default or sliderMin
                local sliderCallback = config.Callback or function() end
                local sliderDescription = config.Description or nil
                local sliderSuffix = config.Suffix or ""
                
                local Slider = {}
                Slider.Value = sliderDefault
                
                local SliderFrame = Create("Frame", {
                    Name = sliderName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, sliderDescription and 62 or 52)
                })
                AddCorner(SliderFrame, 10)
                
                local SliderTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -70, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = sliderName,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Value Badge
                local ValueBadge = Create("Frame", {
                    Name = "ValueBadge",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.85,
                    Position = UDim2.new(1, -55, 0, 6),
                    Size = UDim2.new(0, 42, 0, 20)
                })
                AddCorner(ValueBadge, 5)
                
                local ValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Parent = ValueBadge,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(sliderDefault) .. sliderSuffix,
                    TextColor3 = Theme.Accent,
                    TextSize = 11
                })
                
                if sliderDescription then
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = SliderFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 24),
                        Size = UDim2.new(1, -28, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = sliderDescription,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                -- Slider Track
                local Track = Create("Frame", {
                    Name = "Track",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Divider,
                    Position = UDim2.new(0, 14, 1, -18),
                    Size = UDim2.new(1, -28, 0, 6)
                })
                AddCorner(Track, 3)
                
                local defaultPercent = (sliderDefault - sliderMin) / (sliderMax - sliderMin)
                
                local Fill = Create("Frame", {
                    Name = "Fill",
                    Parent = Track,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(defaultPercent, 0, 1, 0)
                })
                AddCorner(Fill, 3)
                AddGradient(Fill, Theme.AccentLight, Theme.Accent, 0)
                
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = Track,
                    BackgroundColor3 = Theme.TextPrimary,
                    Position = UDim2.new(defaultPercent, -8, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 2
                })
                AddCorner(SliderKnob, 8)
                AddStroke(SliderKnob, Theme.Accent, 2, 0)
                
                local sliderDragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local value = math.floor(sliderMin + (sliderMax - sliderMin) * pos)
                    
                    Slider.Value = value
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
                    ValueLabel.Text = tostring(value) .. sliderSuffix
                    
                    sliderCallback(value)
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = true
                        UpdateSlider(input)
                    end
                end)
                
                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)
                
                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {BackgroundTransparency = 0.2}, 0.15)
                end)
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {BackgroundTransparency = 0.4}, 0.15)
                end)
                
                function Slider:SetValue(value)
                    local pos = (value - sliderMin) / (sliderMax - sliderMin)
                    Slider.Value = value
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
                    ValueLabel.Text = tostring(value) .. sliderSuffix
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ============================================================
            -- [[ ELEMENT: BUTTON ]]
            -- ============================================================
            
            function Section:AddButton(config)
                config = config or {}
                local buttonName = config.Title or "Button"
                local buttonCallback = config.Callback or function() end
                local buttonDescription = config.Description or nil
                local buttonStyle = config.Style or "Primary"
                
                local Button = {}
                
                local colors = {
                    Primary = {BG = Theme.Accent, Hover = Theme.AccentLight},
                    Secondary = {BG = Theme.Element, Hover = Theme.ElementHover},
                    Danger = {BG = Theme.Red, Hover = Color3.fromRGB(255, 100, 90)}
                }
                local color = colors[buttonStyle] or colors.Primary
                
                local ButtonFrame = Create("Frame", {
                    Name = buttonName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, buttonDescription and 70 or 48)
                })
                AddCorner(ButtonFrame, 10)
                
                if buttonDescription then
                    Create("TextLabel", {
                        Name = "Title",
                        Parent = ButtonFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 10),
                        Size = UDim2.new(1, -28, 0, 16),
                        Font = Enum.Font.GothamMedium,
                        Text = buttonName,
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = ButtonFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = buttonDescription,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local ButtonMain = Create("TextButton", {
                    Name = "Button",
                    Parent = ButtonFrame,
                    BackgroundColor3 = color.BG,
                    Position = buttonDescription and UDim2.new(0, 12, 1, -32) or UDim2.new(0, 12, 0.5, -14),
                    Size = UDim2.new(1, -24, 0, buttonDescription and 26 or 28),
                    Font = Enum.Font.GothamBold,
                    Text = buttonDescription and "▶  EXECUTE" or buttonName,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    AutoButtonColor = false,
                    ClipsDescendants = true
                })
                AddCorner(ButtonMain, 7)
                
                if buttonStyle == "Primary" then
                    AddGradient(ButtonMain, Theme.AccentLight, Theme.AccentDark, 135)
                end
                
                ButtonMain.MouseEnter:Connect(function()
                    Tween(ButtonMain, {BackgroundColor3 = color.Hover}, 0.15)
                end)
                ButtonMain.MouseLeave:Connect(function()
                    Tween(ButtonMain, {BackgroundColor3 = color.BG}, 0.15)
                end)
                
                ButtonMain.MouseButton1Click:Connect(function()
                    local origSize = ButtonMain.Size
                    Tween(ButtonMain, {Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 4, origSize.Y.Scale, origSize.Y.Offset - 2)}, 0.08).Completed:Connect(function()
                        Tween(ButtonMain, {Size = origSize}, 0.08)
                    end)
                    buttonCallback()
                end)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundTransparency = 0.2}, 0.15)
                end)
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundTransparency = 0.4}, 0.15)
                end)
                
                table.insert(Section.Elements, Button)
                return Button
            end
            
            -- ============================================================
            -- [[ ELEMENT: DROPDOWN WITH SEARCH ]]
            -- ============================================================
            
            function Section:AddDropdown(config)
                config = config or {}
                local dropdownName = config.Title or "Dropdown"
                local dropdownItems = config.Items or {}
                local dropdownDefault = config.Default or nil
                local dropdownCallback = config.Callback or function() end
                local dropdownDescription = config.Description or nil
                local dropdownMulti = config.Multi or false
                
                local Dropdown = {}
                Dropdown.Value = dropdownMulti and {} or dropdownDefault
                Dropdown.Open = false
                Dropdown.Items = dropdownItems
                
                if dropdownMulti and dropdownDefault then
                    for _, item in pairs(dropdownDefault) do
                        Dropdown.Value[item] = true
                    end
                end
                
                local baseHeight = dropdownDescription and 72 or 58
                
                local DropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, baseHeight),
                    ClipsDescendants = true
                })
                AddCorner(DropdownFrame, 10)
                
                local DropdownTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -28, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = dropdownName,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if dropdownDescription then
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = DropdownFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 24),
                        Size = UDim2.new(1, -28, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = dropdownDescription,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                -- Dropdown Button
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Card,
                    Position = UDim2.new(0, 12, 0, dropdownDescription and 42 or 30),
                    Size = UDim2.new(1, -24, 0, 22),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })
                AddCorner(DropdownButton, 6)
                AddStroke(DropdownButton, Theme.CardBorder, 1, 0.6)
                
                local ButtonText = Create("TextLabel", {
                    Name = "Text",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -35, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = dropdownMulti and "Select items..." or (dropdownDefault or "Select..."),
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })
                
                local Arrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0, 0),
                    Size = UDim2.new(0, 18, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextMuted,
                    TextSize = 10
                })
                
                -- Dropdown Content
                local DropdownContent = Create("Frame", {
                    Name = "Content",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Card,
                    Position = UDim2.new(0, 12, 0, baseHeight + 5),
                    Size = UDim2.new(1, -24, 0, 0),
                    ClipsDescendants = true
                })
                AddCorner(DropdownContent, 8)
                AddStroke(DropdownContent, Theme.CardBorder, 1, 0.6)
                
                -- Search
                local SearchContainer = Create("Frame", {
                    Name = "SearchContainer",
                    Parent = DropdownContent,
                    BackgroundColor3 = Theme.Element,
                    Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.new(1, -12, 0, 28)
                })
                AddCorner(SearchContainer, 6)
                
                local SearchIcon = Create("TextLabel", {
                    Name = "Icon",
                    Parent = SearchContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0, 18, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "🔍",
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11
                })
                
                local SearchBox = Create("TextBox", {
                    Name = "SearchBox",
                    Parent = SearchContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 28, 0, 0),
                    Size = UDim2.new(1, -35, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "Search...",
                    PlaceholderColor3 = Theme.TextDisabled,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    ClearTextOnFocus = false
                })
                
                -- Items Scroll
                local ItemsScroll = Create("ScrollingFrame", {
                    Name = "Items",
                    Parent = DropdownContent,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 40),
                    Size = UDim2.new(1, 0, 1, -40),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })
                AddPadding(ItemsScroll, 4, 6, 6, 6)
                
                Create("UIListLayout", {
                    Parent = ItemsScroll,
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local itemButtons = {}
                
                local function CreateItem(itemName)
                    local isSelected = dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName
                    
                    local ItemButton = Create("TextButton", {
                        Name = itemName,
                        Parent = ItemsScroll,
                        BackgroundColor3 = isSelected and Theme.Accent or Theme.Element,
                        BackgroundTransparency = isSelected and 0.7 or 0.3,
                        Size = UDim2.new(1, -8, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false
                    })
                    AddCorner(ItemButton, 6)
                    
                    if dropdownMulti then
                        local Checkbox = Create("Frame", {
                            Name = "Checkbox",
                            Parent = ItemButton,
                            BackgroundColor3 = isSelected and Theme.Green or Theme.Card,
                            Position = UDim2.new(0, 8, 0.5, -8),
                            Size = UDim2.new(0, 16, 0, 16)
                        })
                        AddCorner(Checkbox, 4)
                        
                        Create("TextLabel", {
                            Name = "Icon",
                            Parent = Checkbox,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.GothamBold,
                            Text = isSelected and "✓" or "",
                            TextColor3 = Theme.TextPrimary,
                            TextSize = 11
                        })
                    end
                    
                    local ItemText = Create("TextLabel", {
                        Name = "Text",
                        Parent = ItemButton,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, dropdownMulti and 30 or 10, 0, 0),
                        Size = UDim2.new(1, dropdownMulti and -38 or -18, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = itemName,
                        TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    ItemButton.MouseEnter:Connect(function()
                        if not (dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName) then
                            Tween(ItemButton, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Accent}, 0.12)
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        local sel = dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName
                        Tween(ItemButton, {
                            BackgroundTransparency = sel and 0.7 or 0.3,
                            BackgroundColor3 = sel and Theme.Accent or Theme.Element
                        }, 0.12)
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if dropdownMulti then
                            Dropdown.Value[itemName] = not Dropdown.Value[itemName]
                            local isNowSelected = Dropdown.Value[itemName]
                            
                            local checkbox = ItemButton:FindFirstChild("Checkbox")
                            if checkbox then
                                Tween(checkbox, {BackgroundColor3 = isNowSelected and Theme.Green or Theme.Card}, 0.12)
                                checkbox:FindFirstChild("Icon").Text = isNowSelected and "✓" or ""
                            end
                            
                            Tween(ItemButton, {
                                BackgroundColor3 = isNowSelected and Theme.Accent or Theme.Element,
                                BackgroundTransparency = isNowSelected and 0.7 or 0.3
                            }, 0.12)
                            ItemText.TextColor3 = isNowSelected and Theme.TextPrimary or Theme.TextSecondary
                            
                            local selected = {}
                            for k, v in pairs(Dropdown.Value) do
                                if v then table.insert(selected, k) end
                            end
                            ButtonText.Text = #selected > 0 and table.concat(selected, ", ") or "Select items..."
                            ButtonText.TextColor3 = #selected > 0 and Theme.TextPrimary or Theme.TextSecondary
                            
                            dropdownCallback(Dropdown.Value)
                        else
                            Dropdown.Value = itemName
                            ButtonText.Text = itemName
                            ButtonText.TextColor3 = Theme.TextPrimary
                            
                            for name, btn in pairs(itemButtons) do
                                local isThis = name == itemName
                                Tween(btn, {
                                    BackgroundColor3 = isThis and Theme.Accent or Theme.Element,
                                    BackgroundTransparency = isThis and 0.7 or 0.3
                                }, 0.12)
                                btn:FindFirstChild("Text").TextColor3 = isThis and Theme.TextPrimary or Theme.TextSecondary
                            end
                            
                            dropdownCallback(itemName)
                            
                            -- Close
                            Dropdown.Open = false
                            Tween(Arrow, {Rotation = 0}, 0.2)
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, baseHeight)}, 0.25)
                            Tween(DropdownContent, {Size = UDim2.new(1, -24, 0, 0)}, 0.25)
                        end
                    end)
                    
                    return ItemButton
                end
                
                for _, item in pairs(dropdownItems) do
                    itemButtons[item] = CreateItem(item)
                end
                
                -- Search
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local search = SearchBox.Text:lower()
                    for name, btn in pairs(itemButtons) do
                        btn.Visible = search == "" or name:lower():find(search, 1, true)
                    end
                end)
                
                -- Toggle
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        Tween(Arrow, {Rotation = 180}, 0.2)
                        local itemCount = math.min(#dropdownItems, 5)
                        local contentHeight = 45 + (itemCount * 31) + 12
                        local totalHeight = baseHeight + 10 + contentHeight
                        
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3, Enum.EasingStyle.Back)
                        Tween(DropdownContent, {Size = UDim2.new(1, -24, 0, contentHeight)}, 0.3, Enum.EasingStyle.Back)
                    else
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, baseHeight)}, 0.25)
                        Tween(DropdownContent, {Size = UDim2.new(1, -24, 0, 0)}, 0.25)
                    end
                end)
                
                DropdownFrame.MouseEnter:Connect(function()
                    Tween(DropdownFrame, {BackgroundTransparency = 0.2}, 0.15)
                end)
                DropdownFrame.MouseLeave:Connect(function()
                    Tween(DropdownFrame, {BackgroundTransparency = 0.4}, 0.15)
                end)
                
                function Dropdown:SetItems(items)
                    Dropdown.Items = items
                    for _, child in pairs(ItemsScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    itemButtons = {}
                    for _, item in pairs(items) do
                        itemButtons[item] = CreateItem(item)
                    end
                end
                
                function Dropdown:SetValue(value)
                    if dropdownMulti then
                        Dropdown.Value = value
                    else
                        Dropdown.Value = value
                        ButtonText.Text = value
                        ButtonText.TextColor3 = Theme.TextPrimary
                    end
                end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- ============================================================
            -- [[ ELEMENT: LABEL ]]
            -- ============================================================
            
            function Section:AddLabel(text)
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    Name = "Label",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                function Label:SetText(newText)
                    LabelFrame.Text = newText
                end
                
                table.insert(Section.Elements, Label)
                return Label
            end
            
            return Section
        end
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Content.Visible = false
            Window.CurrentTab.Indicator.Visible = false
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.15)
            Tween(Window.CurrentTab.IconLabel, {TextColor3 = Theme.TextMuted}, 0.15)
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        tab.    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Content.Visible = false
            Window.CurrentTab.Indicator.Visible = false
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.15)
            Tween(Window.CurrentTab.IconLabel, {TextColor3 = Theme.TextMuted}, 0.15)
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        tab.Indicator.Visible = true
        
        -- Update header
        TabIcon.Text = tab.Icon
        TabTitle.Text = tab.Name
        
        Tween(tab.Button, {BackgroundTransparency = 0.6, BackgroundColor3 = Theme.Accent}, 0.2)
        Tween(tab.IconLabel, {TextColor3 = Theme.TextPrimary}, 0.2)
        Tween(tab.Indicator, {BackgroundTransparency = 0}, 0.2)
    end
    
    -- ============================================================
    -- [[ NOTIFICATION SYSTEM ]]
    -- ============================================================
    
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -340, 0, 20),
        Size = UDim2.new(0, 320, 0, 0),
        AnchorPoint = Vector2.new(0, 0)
    })
    
    Create("UIListLayout", {
        Parent = NotificationContainer,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local content = config.Content or ""
        local duration = config.Duration or 5
        local notifType = config.Type or "Info"
        
        local typeData = {
            Info = {Color = Theme.Accent, Icon = "ℹ️"},
            Success = {Color = Theme.Green, Icon = "✅"},
            Warning = {Color = Theme.Orange, Icon = "⚠️"},
            Error = {Color = Theme.Red, Icon = "❌"}
        }
        
        local data = typeData[notifType] or typeData.Info
        
        local NotifCard = Create("Frame", {
            Name = "Notification",
            Parent = NotificationContainer,
            BackgroundColor3 = Theme.Card,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true
        })
        AddCorner(NotifCard, 12)
        AddStroke(NotifCard, data.Color, 1, 0.5)
        AddShadow(NotifCard, 0.5)
        
        -- Accent Line
        local AccentLine = Create("Frame", {
            Name = "Accent",
            Parent = NotifCard,
            BackgroundColor3 = data.Color,
            Size = UDim2.new(0, 4, 1, 0)
        })
        AddCorner(AccentLine, 2)
        
        -- Icon
        local NotifIcon = Create("TextLabel", {
            Name = "Icon",
            Parent = NotifCard,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 14),
            Size = UDim2.new(0, 24, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = data.Icon,
            TextSize = 18,
            ZIndex = 2
        })
        
        -- Title
        local NotifTitle = Create("TextLabel", {
            Name = "Title",
            Parent = NotifCard,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 48, 0, 12),
            Size = UDim2.new(1, -60, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        -- Content
        local NotifContent = Create("TextLabel", {
            Name = "Content",
            Parent = NotifCard,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 48, 0, 32),
            Size = UDim2.new(1, -60, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = content,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 2
        })
        
        -- Progress Bar
        local ProgressBar = Create("Frame", {
            Name = "Progress",
            Parent = NotifCard,
            BackgroundColor3 = data.Color,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            ZIndex = 3
        })
        
        -- Close Button
        local CloseBtn = Create("TextButton", {
            Name = "Close",
            Parent = NotifCard,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -30, 0, 10),
            Size = UDim2.new(0, 20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = "✕",
            TextColor3 = Theme.TextMuted,
            TextSize = 12,
            ZIndex = 3
        })
        
        local notifClosed = false
        
        local function CloseNotification()
            if notifClosed then return end
            notifClosed = true
            
            Tween(NotifCard, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            }, 0.3).Completed:Connect(function()
                NotifCard:Destroy()
            end)
        end
        
        CloseBtn.MouseButton1Click:Connect(CloseNotification)
        
        CloseBtn.MouseEnter:Connect(function()
            Tween(CloseBtn, {TextColor3 = Theme.TextPrimary}, 0.1)
        end)
        CloseBtn.MouseLeave:Connect(function()
            Tween(CloseBtn, {TextColor3 = Theme.TextMuted}, 0.1)
        end)
        
        -- Animate
        task.spawn(function()
            task.wait(0.05)
            local height = 55 + NotifContent.TextBounds.Y
            
            -- Slide in
            NotifCard.Position = UDim2.new(1, 50, 0, 0)
            NotifCard.Size = UDim2.new(1, 0, 0, height)
            
            Tween(NotifCard, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
            
            -- Progress bar animation
            Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)
            
            task.wait(duration)
            
            CloseNotification()
        end)
    end
    
    -- ============================================================
    -- [[ MOBILE TOGGLE BUTTON ]]
    -- ============================================================
    
    local MobileToggle = Create("TextButton", {
        Name = "MobileToggle",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 15, 0.5, -25),
        Size = UDim2.new(0, 50, 0, 50),
        Font = Enum.Font.GothamBold,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 100
    })
    AddCorner(MobileToggle, 25)
    AddShadow(MobileToggle, 0.5)
    AddGradient(MobileToggle, Theme.AccentLight, Theme.AccentDark, 135)
    
    local MobileIcon = Create("TextLabel", {
        Name = "Icon",
        Parent = MobileToggle,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🎮",
        TextColor3 = Theme.TextPrimary,
        TextSize = 22,
        ZIndex = 101
    })
    
    -- Make mobile button draggable
    local mobileDragging = false
    local mobileDragStart, mobileStartPos
    
    MobileToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = true
            mobileDragStart = input.Position
            mobileStartPos = MobileToggle.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mobileDragging = false
                end
            end)
        end
    end)
    
    MobileToggle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if mobileDragging then
                local delta = input.Position - mobileDragStart
                MobileToggle.Position = UDim2.new(
                    mobileStartPos.X.Scale, 
                    mobileStartPos.X.Offset + delta.X, 
                    mobileStartPos.Y.Scale, 
                    mobileStartPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    MobileToggle.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)
    
    MobileToggle.MouseEnter:Connect(function()
        Tween(MobileToggle, {Size = UDim2.new(0, 55, 0, 55)}, 0.15)
    end)
    MobileToggle.MouseLeave:Connect(function()
        Tween(MobileToggle, {Size = UDim2.new(0, 50, 0, 50)}, 0.15)
    end)
    
    -- Hide mobile toggle when UI visible, show when hidden
    Window.MobileToggle = MobileToggle
    
    local originalToggle = Window.Toggle
    function Window:Toggle()
        self.Visible = not self.Visible
        
        if self.Visible then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, size.X.Offset, 0, 0)
            MainFrame.BackgroundTransparency = 1
            
            Tween(MainFrame, {Size = size, BackgroundTransparency = self.Opacity}, 0.4, Enum.EasingStyle.Back)
            Tween(MobileToggle, {Position = UDim2.new(0, -60, 0.5, -25)}, 0.3) -- Hide mobile button
            
            if self.BlurEnabled then
                Tween(BlurEffect, {Size = 10 - (self.Opacity * 10)}, 0.3)
            end
        else
            Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3).Completed:Connect(function()
                if not self.Visible then
                    MainFrame.Visible = false
                end
            end)
            Tween(MobileToggle, {Position = UDim2.new(0, 15, 0.5, -25)}, 0.3) -- Show mobile button
            
            if self.BlurEnabled then
                Tween(BlurEffect, {Size = 0}, 0.3)
            end
        end
    end
    
    -- Store reference
    getgenv().EnzoUILib = Window
    
    return Window
end

return EnzoLib