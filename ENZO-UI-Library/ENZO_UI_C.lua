--[[
    ENZO UI LIBRARY - Design C: Card Based
    Version: 1.0.0
    Author: ENZO-YT
    
    Style: iOS/Material Design inspired with card layouts
    Features (Basic untuk test design):
    - Window dengan Draggable
    - Card-based Tab Navigation
    - Toggle, Slider, Button, Dropdown with Search
    - Opacity Control
    - Blur Effect
    - Clean Destroy
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
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- [[ CLEANUP SYSTEM ]]
-- ============================================================
if getgenv().EnzoUILib then
    pcall(function()
        getgenv().EnzoUILib:Destroy()
    end)
end

-- Remove old blur
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
    local shadow = Create("ImageLabel", {
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
    return shadow
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
-- [[ THEME COLORS - Card Based (iOS/Material) ]]
-- ============================================================
local Theme = {
    -- Background
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundFloat = Color3.fromRGB(22, 22, 28),
    
    -- Cards
    Card = Color3.fromRGB(28, 28, 35),
    CardHover = Color3.fromRGB(35, 35, 42),
    CardBorder = Color3.fromRGB(45, 45, 55),
    
    -- Accent (iOS Blue)
    Accent = Color3.fromRGB(10, 132, 255),
    AccentLight = Color3.fromRGB(50, 160, 255),
    AccentDark = Color3.fromRGB(0, 100, 220),
    
    -- Secondary Accents
    Green = Color3.fromRGB(52, 199, 89),
    Red = Color3.fromRGB(255, 69, 58),
    Orange = Color3.fromRGB(255, 159, 10),
    Purple = Color3.fromRGB(175, 82, 222),
    Pink = Color3.fromRGB(255, 45, 85),
    Teal = Color3.fromRGB(90, 200, 250),
    
    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(170, 170, 180),
    TextTertiary = Color3.fromRGB(120, 120, 130),
    TextDisabled = Color3.fromRGB(80, 80, 90),
    
    -- Elements
    ElementBG = Color3.fromRGB(38, 38, 45),
    ElementBGHover = Color3.fromRGB(48, 48, 55),
    Divider = Color3.fromRGB(55, 55, 65),
    
    -- Glass effect
    Glass = Color3.fromRGB(255, 255, 255),
    GlassTransparency = 0.95,
}

-- ============================================================
-- [[ MAIN LIBRARY ]]
-- ============================================================

function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "v1.0.0"
    local size = config.Size or UDim2.new(0, 620, 0, 480)
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
        Name = "EnzoUI_C_" .. tostring(math.random(100000, 999999)),
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
        Size = blurEnabled and 8 or 0,
        Parent = Lighting
    })
    Window.BlurEffect = BlurEffect
    
    -- Main Container with Glass effect
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        ClipsDescendants = true
    })
    AddCorner(MainFrame, 16)
    AddShadow(MainFrame, 0.5)
    
    Window.MainFrame = MainFrame
    
    -- Glass overlay effect
    local GlassOverlay = Create("Frame", {
        Name = "GlassOverlay",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Glass,
        BackgroundTransparency = Theme.GlassTransparency,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0
    })
    AddCorner(GlassOverlay, 16)
    AddGradient(GlassOverlay, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 220), 180)
    
    -- ============================================================
    -- [[ HEADER ]]
    -- ============================================================
    
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = Theme.BackgroundFloat,
        BackgroundTransparency = opacity * 0.5,
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 10
    })
    AddCorner(Header, 16)
    
    -- Fix bottom corners
    local HeaderFix = Create("Frame", {
        Name = "Fix",
        Parent = Header,
        BackgroundColor3 = Theme.BackgroundFloat,
        BackgroundTransparency = opacity * 0.5,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 9
    })
    
    -- App Icon
    local AppIcon = Create("Frame", {
        Name = "AppIcon",
        Parent = Header,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 18, 0.5, -18),
        Size = UDim2.new(0, 36, 0, 36),
        ZIndex = 11
    })
    AddCorner(AppIcon, 10)
    AddGradient(AppIcon, Theme.AccentLight, Theme.AccentDark, 135)
    
    local AppIconText = Create("TextLabel", {
        Name = "Icon",
        Parent = AppIcon,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🎮",
        TextColor3 = Theme.TextPrimary,
        TextSize = 18,
        ZIndex = 12
    })
    
    -- Title Section
    local TitleSection = Create("Frame", {
        Name = "TitleSection",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 65, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        ZIndex = 11
    })
    
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = TitleSection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 14),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    
    local SubtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Parent = TitleSection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Theme.TextTertiary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    })
    
    -- Window Controls (iOS style)
    local Controls = Create("Frame", {
        Name = "Controls",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0.5, -10),
        Size = UDim2.new(0, 80, 0, 20),
        ZIndex = 11
    })
    
    local ControlsLayout = Create("UIListLayout", {
        Parent = Controls,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10)
    })
    
    local function CreateControlDot(name, color, callback)
        local dot = Create("TextButton", {
            Name = name,
            Parent = Controls,
            BackgroundColor3 = color,
            Size = UDim2.new(0, 14, 0, 14),
            Font = Enum.Font.GothamBold,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 12
        })
        AddCorner(dot, 7)
        
        local dotIcon = Create("TextLabel", {
            Name = "Icon",
            Parent = dot,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 8,
            TextTransparency = 1,
            ZIndex = 13
        })
        
        dot.MouseEnter:Connect(function()
            Tween(dot, {Size = UDim2.new(0, 16, 0, 16)}, 0.15)
            Tween(dotIcon, {TextTransparency = 0.3}, 0.15)
        end)
        dot.MouseLeave:Connect(function()
            Tween(dot, {Size = UDim2.new(0, 14, 0, 14)}, 0.15)
            Tween(dotIcon, {TextTransparency = 1}, 0.15)
        end)
        dot.MouseButton1Click:Connect(callback)
        
        return dot, dotIcon
    end
    
    local closeDot, closeIcon = CreateControlDot("Close", Theme.Red, function()
        Window:Destroy()
    end)
    closeIcon.Text = "✕"
    
    local minDot, minIcon = CreateControlDot("Minimize", Theme.Orange, function()
        Window:Toggle()
    end)
    minIcon.Text = "−"
    
    local maxDot, maxIcon = CreateControlDot("Maximize", Theme.Green, function()
        -- Future maximize
    end)
    maxIcon.Text = "+"
    
    MakeDraggable(MainFrame, Header)
    
    -- ============================================================
    -- [[ TAB BAR (Card Style) ]]
    -- ============================================================
    
    local TabBar = Create("Frame", {
        Name = "TabBar",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 65),
        Size = UDim2.new(1, -30, 0, 45),
        ZIndex = 5
    })
    
    local TabBarScroll = Create("ScrollingFrame", {
        Name = "Scroll",
        Parent = TabBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ZIndex = 6
    })
    
    local TabBarLayout = Create("UIListLayout", {
        Parent = TabBarScroll,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    AddPadding(TabBarScroll, 0, 0, 5, 5)
    
    -- ============================================================
    -- [[ CONTENT AREA ]]
    -- ============================================================
    
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 115),
        Size = UDim2.new(1, -30, 1, -170),
        ZIndex = 3
    })
    
    -- ============================================================
    -- [[ FOOTER ]]
    -- ============================================================
    
    local Footer = Create("Frame", {
        Name = "Footer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.BackgroundFloat,
        BackgroundTransparency = opacity * 0.5,
        Position = UDim2.new(0, 0, 1, -50),
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 10
    })
    AddCorner(Footer, 16)
    
    local FooterFix = Create("Frame", {
        Name = "Fix",
        Parent = Footer,
        BackgroundColor3 = Theme.BackgroundFloat,
        BackgroundTransparency = opacity * 0.5,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 9
    })
    
    -- Footer Content Container
    local FooterContent = Create("Frame", {
        Name = "Content",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        ZIndex = 11
    })
    
    -- Opacity Control
    local OpacitySection = Create("Frame", {
        Name = "OpacitySection",
        Parent = FooterContent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -12),
        Size = UDim2.new(0, 180, 0, 24),
        ZIndex = 12
    })
    
    local OpacityIcon = Create("TextLabel", {
        Name = "Icon",
        Parent = OpacitySection,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🔆",
        TextSize = 14,
        ZIndex = 13
    })
    
    local OpacitySliderContainer = Create("Frame", {
        Name = "SliderContainer",
        Parent = OpacitySection,
        BackgroundColor3 = Theme.ElementBG,
        Position = UDim2.new(0, 30, 0.5, -10),
        Size = UDim2.new(0, 110, 0, 20),
        ZIndex = 13
    })
    AddCorner(OpacitySliderContainer, 10)
    
    local OpacitySliderBG = Create("Frame", {
        Name = "SliderBG",
        Parent = OpacitySliderContainer,
        BackgroundColor3 = Theme.Divider,
        Position = UDim2.new(0, 8, 0.5, -3),
        Size = UDim2.new(1, -16, 0, 6),
        ZIndex = 14
    })
    AddCorner(OpacitySliderBG, 3)
    
    local OpacityFill = Create("Frame", {
        Name = "Fill",
        Parent = OpacitySliderBG,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1 - opacity, 0, 1, 0),
        ZIndex = 15
    })
    AddCorner(OpacityFill, 3)
    AddGradient(OpacityFill, Theme.AccentLight, Theme.Accent, 0)
    
    local OpacityKnob = Create("Frame", {
        Name = "Knob",
        Parent = OpacitySliderBG,
        BackgroundColor3 = Theme.TextPrimary,
        Position = UDim2.new(1 - opacity, -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        ZIndex = 16
    })
    AddCorner(OpacityKnob, 8)
    AddShadow(OpacityKnob, 0.7)
    
    local OpacityLabel = Create("TextLabel", {
        Name = "Label",
        Parent = OpacitySection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 145, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = math.floor((1 - opacity) * 100) .. "%",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        ZIndex = 13
    })
    
    -- Opacity Slider Logic
    local opacityDragging = false
    
    local function UpdateAllOpacity(newOpacity)
        Window.Opacity = newOpacity
        MainFrame.BackgroundTransparency = newOpacity
        Header.BackgroundTransparency = newOpacity * 0.5
        HeaderFix.BackgroundTransparency = newOpacity * 0.5
        Footer.BackgroundTransparency = newOpacity * 0.5
        FooterFix.BackgroundTransparency = newOpacity * 0.5
        GlassOverlay.BackgroundTransparency = Theme.GlassTransparency + (newOpacity * 0.03)
        
        -- Update blur based on opacity
        if Window.BlurEnabled then
            BlurEffect.Size = math.max(0, 8 - (newOpacity * 8))
        end
    end
    
    local function UpdateOpacitySlider(input)
        local pos = math.clamp((input.Position.X - OpacitySliderBG.AbsolutePosition.X) / OpacitySliderBG.AbsoluteSize.X, 0, 1)
        local newOpacity = 1 - pos
        
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -8, 0.5, -8)
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
    
    -- Toggle Key Display
    local ToggleKeySection = Create("Frame", {
        Name = "ToggleKeySection",
        Parent = FooterContent,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -120, 0.5, -12),
        Size = UDim2.new(0, 120, 0, 24),
        ZIndex = 12
    })
    
    local ToggleKeyBadge = Create("Frame", {
        Name = "Badge",
        Parent = ToggleKeySection,
        BackgroundColor3 = Theme.ElementBG,
        Position = UDim2.new(1, -100, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        ZIndex = 13
    })
    AddCorner(ToggleKeyBadge, 6)
    
    local ToggleKeyLabel = Create("TextLabel", {
        Name = "Label",
        Parent = ToggleKeyBadge,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = "🔑 " .. Window.ToggleKey.Name,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        ZIndex = 14
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
                Tween(BlurEffect, {Size = 8 - (self.Opacity * 8)}, 0.3)
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
        OpacityKnob.Position = UDim2.new(pos, -8, 0.5, -8)
        OpacityLabel.Text = math.floor(pos * 100) .. "%"
    end
    
    -- ============================================================
    -- [[ TAB SYSTEM ]]
    -- ============================================================
    
    function Window:AddTab(config)
        config = config or {}
        local tabName = config.Title or "Tab"
        local tabIcon = config.Icon or "📁"
        
        local Tab = {}
        Tab.Name = tabName
        Tab.Sections = {}
        
        -- Tab Button (Pill/Card Style)
        local TabButton = Create("TextButton", {
            Name = tabName,
            Parent = TabBarScroll,
            BackgroundColor3 = Theme.Card,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(0, 0, 0, 36),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamMedium,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 7
        })
        AddCorner(TabButton, 18)
        AddPadding(TabButton, 0, 0, 16, 16)
        
        local TabButtonLayout = Create("UIListLayout", {
            Parent = TabButton,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8)
        })
        
        local TabIconLabel = Create("TextLabel", {
            Name = "Icon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 18, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextSize = 14,
            LayoutOrder = 1,
            ZIndex = 8
        })
        
        local TabNameLabel = Create("TextLabel", {
            Name = "Name",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            LayoutOrder = 2,
            ZIndex = 8
        })
        
        -- Active indicator (glow effect)
        local TabGlow = Create("Frame", {
            Name = "Glow",
            Parent = TabButton,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6
        })
        AddCorner(TabGlow, 18)
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 0.5,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 4
        })
        
        local TabContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Glow = TabGlow
        Tab.NameLabel = TabNameLabel
        
        -- Tab Hover/Click Effects
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.1}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.3}, 0.15)
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
        -- [[ SECTION SYSTEM ]]
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
            
            -- Section Card
            local SectionCard = Create("Frame", {
                Name = sectionName,
                Parent = column,
                BackgroundColor3 = Theme.Card,
                BackgroundTransparency = 0.2,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddCorner(SectionCard, 12)
            AddStroke(SectionCard, Theme.CardBorder, 1, 0.7)
            AddShadow(SectionCard, 0.8)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                Name = "Header",
                Parent = SectionCard,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40)
            })
            
            local HeaderIcon = Create("Frame", {
                Name = "IconBG",
                Parent = SectionHeader,
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.85,
                Position = UDim2.new(0, 14, 0.5, -12),
                Size = UDim2.new(0, 24, 0, 24)
            })
            AddCorner(HeaderIcon, 6)
            
            local HeaderIconText = Create("TextLabel", {
                Name = "Icon",
                Parent = HeaderIcon,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = Theme.Accent,
                TextSize = 12
            })
            
            local HeaderTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 46, 0, 0),
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
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddPadding(SectionContent, 5, 14, 14, 14)
            
            Create("UIListLayout", {
                Parent = SectionContent,
                Padding = UDim.new(0, 10),
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
                    BackgroundColor3 = Theme.ElementBG,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, toggleDescription and 52 or 40)
                })
                AddCorner(ToggleFrame, 10)
                
                local ToggleTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, toggleDescription and 8 or 0),
                    Size = UDim2.new(1, -80, 0, toggleDescription and 18 or 40),
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
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -80, 0, 18),
                        Font = Enum.Font.Gotham,
                        Text = toggleDescription,
                        TextColor3 = Theme.TextTertiary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                -- iOS Style Switch
                local ToggleSwitch = Create("Frame", {
                    Name = "Switch",
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggleDefault and Theme.Green or Theme.ElementBG,
                    Position = UDim2.new(1, -60, 0.5, -14),
                    Size = UDim2.new(0, 50, 0, 28)
                })
                AddCorner(ToggleSwitch, 14)
                AddStroke(ToggleSwitch, toggleDefault and Theme.Green or Theme.Divider, 1, toggleDefault and 0.5 or 0)
                
                local ToggleKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = ToggleSwitch,
                    BackgroundColor3 = Theme.TextPrimary,
                    Position = toggleDefault and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
                    Size = UDim2.new(0, 24, 0, 24)
                })
                AddCorner(ToggleKnob, 12)
                AddShadow(ToggleKnob, 0.7)
                
                local function UpdateToggle()
                    Toggle.Value = not Toggle.Value
                    
                    local switchStroke = ToggleSwitch:FindFirstChildOfClass("UIStroke")
                    
                    if Toggle.Value then
                        Tween(ToggleSwitch, {BackgroundColor3 = Theme.Green}, 0.25)
                        Tween(ToggleKnob, {Position = UDim2.new(1, -26, 0.5, -12)}, 0.25, Enum.EasingStyle.Back)
                        if switchStroke then
                            Tween(switchStroke, {Color = Theme.Green, Transparency = 0.5}, 0.25)
                        end
                    else
                        Tween(ToggleSwitch, {BackgroundColor3 = Theme.ElementBG}, 0.25)
                        Tween(ToggleKnob, {Position = UDim2.new(0, 2, 0.5, -12)}, 0.25, Enum.EasingStyle.Back)
                        if switchStroke then
                            Tween(switchStroke, {Color = Theme.Divider, Transparency = 0}, 0.25)
                        end
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
                    Tween(ToggleFrame, {BackgroundTransparency = 0.3}, 0.15)
                end)
                ToggleFrame.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {BackgroundTransparency = 0.5}, 0.15)
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
            -- [[ ELEMENT: SLIDER (Material Style) ]]
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
                    BackgroundColor3 = Theme.ElementBG,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, sliderDescription and 65 or 55)
                })
                AddCorner(SliderFrame, 10)
                
                local SliderTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -80, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = sliderName,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Value Badge
                local SliderValueBadge = Create("Frame", {
                    Name = "ValueBadge",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.85,
                    Position = UDim2.new(1, -60, 0, 6),
                    Size = UDim2.new(0, 46, 0, 22)
                })
                AddCorner(SliderValueBadge, 6)
                
                local SliderValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Parent = SliderValueBadge,
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
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = sliderDescription,
                        TextColor3 = Theme.TextTertiary,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                -- Slider Track
                local SliderTrack = Create("Frame", {
                    Name = "Track",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Divider,
                    Position = UDim2.new(0, 14, 1, -22),
                    Size = UDim2.new(1, -28, 0, 6)
                })
                AddCorner(SliderTrack, 3)
                
                local defaultPercent = (sliderDefault - sliderMin) / (sliderMax - sliderMin)
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderTrack,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(defaultPercent, 0, 1, 0)
                })
                AddCorner(SliderFill, 3)
                AddGradient(SliderFill, Theme.AccentLight, Theme.Accent, 0)
                
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = SliderTrack,
                    BackgroundColor3 = Theme.TextPrimary,
                    Position = UDim2.new(defaultPercent, -10, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20),
                    ZIndex = 2
                })
                AddCorner(SliderKnob, 10)
                AddStroke(SliderKnob, Theme.Accent, 3, 0)
                AddShadow(SliderKnob, 0.6)
                
                local sliderDragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local value = math.floor(sliderMin + (sliderMax - sliderMin) * pos)
                    
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
                    SliderValueLabel.Text = tostring(value) .. sliderSuffix
                    
                    sliderCallback(value)
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = true
                        UpdateSlider(input)
                        
                        -- Expand knob
                        Tween(SliderKnob, {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(SliderKnob.Position.X.Scale, -12, 0.5, -12)}, 0.15)
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = false
                        
                        -- Shrink knob
                        local pos = SliderKnob.Position.X.Scale
                        Tween(SliderKnob, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(pos, -10, 0.5, -10)}, 0.15)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)
                
                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {BackgroundTransparency = 0.3}, 0.15)
                end)
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {BackgroundTransparency = 0.5}, 0.15)
                end)
                
                function Slider:SetValue(value)
                    local pos = (value - sliderMin) / (sliderMax - sliderMin)
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
                    SliderValueLabel.Text = tostring(value) .. sliderSuffix
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ============================================================
            -- [[ ELEMENT: BUTTON (Material Ripple Style) ]]
            -- ============================================================
            
            function Section:AddButton(config)
                config = config or {}
                local buttonName = config.Title or "Button"
                local buttonCallback = config.Callback or function() end
                local buttonDescription = config.Description or nil
                local buttonStyle = config.Style or "Primary" -- Primary, Secondary, Danger
                
                local Button = {}
                
                local buttonColors = {
                    Primary = {BG = Theme.Accent, Hover = Theme.AccentLight},
                    Secondary = {BG = Theme.ElementBG, Hover = Theme.ElementBGHover},
                    Danger = {BG = Theme.Red, Hover = Color3.fromRGB(255, 100, 90)}
                }
                
                local colors = buttonColors[buttonStyle] or buttonColors.Primary
                
                local ButtonFrame = Create("Frame", {
                    Name = buttonName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.ElementBG,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, buttonDescription and 75 or 50)
                })
                AddCorner(ButtonFrame, 10)
                
                if buttonDescription then
                    local ButtonTitle = Create("TextLabel", {
                        Name = "Title",
                        Parent = ButtonFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 10),
                        Size = UDim2.new(1, -28, 0, 18),
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
                        Position = UDim2.new(0, 14, 0, 28),
                        Size = UDim2.new(1, -28, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = buttonDescription,
                        TextColor3 = Theme.TextTertiary,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local ButtonMain = Create("TextButton", {
                    Name = "Button",
                    Parent = ButtonFrame,
                    BackgroundColor3 = colors.BG,
                    Position = buttonDescription and UDim2.new(0, 14, 1, -34) or UDim2.new(0, 14, 0.5, -16),
                    Size = UDim2.new(1, -28, 0, buttonDescription and 28 or 32),
                    Font = Enum.Font.GothamBold,
                    Text = buttonDescription and "▶  EXECUTE" or buttonName,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    AutoButtonColor = false,
                    ClipsDescendants = true
                })
                AddCorner(ButtonMain, 8)
                
                if buttonStyle == "Primary" then
                    AddGradient(ButtonMain, Theme.AccentLight, Theme.AccentDark, 135)
                end
                
                -- Ripple Effect
                local function CreateRipple(x, y)
                    local ripple = Create("Frame", {
                        Name = "Ripple",
                        Parent = ButtonMain,
                        BackgroundColor3 = Theme.TextPrimary,
                        BackgroundTransparency = 0.7,
                        Position = UDim2.new(0, x - ButtonMain.AbsolutePosition.X, 0, y - ButtonMain.AbsolutePosition.Y),
                        Size = UDim2.new(0, 0, 0, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5)
                    })
                    AddCorner(ripple, 1000)
                    
                    local maxSize = math.max(ButtonMain.AbsoluteSize.X, ButtonMain.AbsoluteSize.Y) * 2
                    
                    Tween(ripple, {
                        Size = UDim2.new(0, maxSize, 0, maxSize),
                        BackgroundTransparency = 1
                    }, 0.5).Completed:Connect(function()
                        ripple:Destroy()
                    end)
                end
                
                ButtonMain.MouseEnter:Connect(function()
                    Tween(ButtonMain, {BackgroundColor3 = colors.Hover}, 0.15)
                end)
                
                ButtonMain.MouseLeave:Connect(function()
                    Tween(ButtonMain, {BackgroundColor3 = colors.BG}, 0.15)
                end)
                
                ButtonMain.MouseButton1Click:Connect(function()
                    local mouse = UserInputService:GetMouseLocation()
                    CreateRipple(mouse.X, mouse.Y - 36) -- Adjust for topbar
                    
                    -- Scale animation
                    Tween(ButtonMain, {Size = UDim2.new(1, -32, 0, buttonDescription and 26 or 30)}, 0.1).Completed:Connect(function()
                        Tween(ButtonMain, {Size = UDim2.new(1, -28, 0, buttonDescription and 28 or 32)}, 0.1)
                    end)
                    
                    buttonCallback()
                end)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundTransparency = 0.3}, 0.15)
                end)
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundTransparency = 0.5}, 0.15)
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
                    BackgroundColor3 = Theme.ElementBG,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, baseHeight),
                    ClipsDescendants = true
                })
                AddCorner(DropdownFrame, 10)
                
                local DropdownTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -28, 0, 18),
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
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = dropdownDescription,
                        TextColor3 = Theme.TextTertiary,
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
                    Size = UDim2.new(1, -24, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })
                AddCorner(DropdownButton, 6)
                AddStroke(DropdownButton, Theme.CardBorder, 1, 0.5)
                
                local DropdownButtonText = Create("TextLabel", {
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
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextTertiary,
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
                AddStroke(DropdownContent, Theme.CardBorder, 1, 0.5)
                
                -- Search Container
                local SearchContainer = Create("Frame", {
                    Name = "SearchContainer",
                    Parent = DropdownContent,
                    BackgroundColor3 = Theme.ElementBG,
                    Position = UDim2.new(0, 8, 0, 8),
                    Size = UDim2.new(1, -16, 0, 30)
                })
                AddCorner(SearchContainer, 8)
                
                local SearchIcon = Create("TextLabel", {
                    Name = "Icon",
                    Parent = SearchContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "🔍",
                    TextColor3 = Theme.TextTertiary,
                    TextSize = 12
                })
                
                local SearchBox = Create("TextBox", {
                    Name = "SearchBox",
                    Parent = SearchContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 32, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "Search...",
                    PlaceholderColor3 = Theme.TextDisabled,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    ClearTextOnFocus = false
                })
                
                -- Items List
                local ItemsList = Create("ScrollingFrame", {
                    Name = "Items",
                    Parent = DropdownContent,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 45),
                    Size = UDim2.new(1, 0, 1, -45),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })
                AddPadding(ItemsList, 5, 8, 8, 8)
                
                Create("UIListLayout", {
                    Parent = ItemsList,
                    Padding = UDim.new(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local itemButtons = {}
                
                local function CreateItem(itemName)
                    local isSelected = dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName
                    
                    local ItemButton = Create("TextButton", {
                        Name = itemName,
                        Parent = ItemsList,
                        BackgroundColor3 = isSelected and Theme.Accent or Theme.ElementBG,
                        BackgroundTransparency = isSelected and 0.7 or 0.3,
                        Size = UDim2.new(1, -10, 0, 30),
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
                            Position = UDim2.new(0, 8, 0.5, -9),
                            Size = UDim2.new(0, 18, 0, 18)
                        })
                        AddCorner(Checkbox, 4)
                        AddStroke(Checkbox, isSelected and Theme.Green or Theme.Divider, 1, 0.5)
                        
                        local CheckIcon = Create("TextLabel", {
                            Name = "Icon",
                            Parent = Checkbox,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.GothamBold,
                            Text = isSelected and "✓" or "",
                            TextColor3 = Theme.TextPrimary,
                            TextSize = 12
                        })
                    end
                    
                    local ItemText = Create("TextLabel", {
                        Name = "Text",
                        Parent = ItemButton,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, dropdownMulti and 32 or 12, 0, 0),
                        Size = UDim2.new(1, dropdownMulti and -40 or -24, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = itemName,
                        TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    ItemButton.MouseEnter:Connect(function()
                        if not (dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName) then
                            Tween(ItemButton, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Accent}, 0.15)
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        local sel = dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName
                        Tween(ItemButton, {
                            BackgroundTransparency = sel and 0.7 or 0.3,
                            BackgroundColor3 = sel and Theme.Accent or Theme.ElementBG
                        }, 0.15)
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if dropdownMulti then
                            Dropdown.Value[itemName] = not Dropdown.Value[itemName]
                            local isNowSelected = Dropdown.Value[itemName]
                            
                            local checkbox = ItemButton:FindFirstChild("Checkbox")
                            if checkbox then
                                Tween(checkbox, {BackgroundColor3 = isNowSelected and Theme.Green or Theme.Card}, 0.15)
                                checkbox:FindFirstChild("Icon").Text = isNowSelected and "✓" or ""
                                local stroke = checkbox:FindFirstChildOfClass("UIStroke")
                                if stroke then
                                    Tween(stroke, {Color = isNowSelected and Theme.Green or Theme.Divider}, 0.15)
                                end
                            end
                            
                            Tween(ItemButton, {
                                BackgroundColor3 = isNowSelected and Theme.Accent or Theme.ElementBG,
                                BackgroundTransparency = isNowSelected and 0.7 or 0.3
                            }, 0.15)
                            ItemText.TextColor3 = isNowSelected and Theme.TextPrimary or Theme.TextSecondary
                            
                            local selected = {}
                            for k, v in pairs(Dropdown.Value) do
                                if v then table.insert(selected, k) end
                            end
                            DropdownButtonText.Text = #selected > 0 and table.concat(selected, ", ") or "Select items..."
                            DropdownButtonText.TextColor3 = #selected > 0 and Theme.TextPrimary or Theme.TextSecondary
                            
                            dropdownCallback(Dropdown.Value)
                        else
                            Dropdown.Value = itemName
                            DropdownButtonText.Text = itemName
                            DropdownButtonText.TextColor3 = Theme.TextPrimary
                            
                            for name, btn in pairs(itemButtons) do
                                local isThis = name == itemName
                                Tween(btn, {
                                    BackgroundColor3 = isThis and Theme.Accent or Theme.ElementBG,
                                    BackgroundTransparency = isThis and 0.7 or 0.3
                                }, 0.15)
                                btn:FindFirstChild("Text").TextColor3 = isThis and Theme.TextPrimary or Theme.TextSecondary
                            end
                            
                            dropdownCallback(itemName)
                            
                            -- Close
                            Dropdown.Open = false
                            Tween(DropdownArrow, {Rotation = 0}, 0.2)
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, baseHeight)}, 0.25)
                            Tween(DropdownContent, {Size = UDim2.new(1, -24, 0, 0)}, 0.25)
                        end
                    end)
                    
                    return ItemButton
                end
                
                -- Create items
                for _, item in pairs(dropdownItems) do
                    itemButtons[item] = CreateItem(item)
                end
                
                -- Search functionality
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local search = SearchBox.Text:lower()
                    for name, btn in pairs(itemButtons) do
                        local match = search == "" or name:lower():find(search, 1, true)
                        btn.Visible = match
                        
                        -- Highlight
                        local text = btn:FindFirstChild("Text")
                        if text and match and search ~= "" then
                            text.TextColor3 = Theme.Accent
                        elseif text then
                            local isSelected = dropdownMulti and Dropdown.Value[name] or Dropdown.Value == name
                            text.TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary
                        end
                    end
                end)
                
                -- Toggle dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        Tween(DropdownArrow, {Rotation = 180}, 0.2)
                        local itemCount = math.min(#dropdownItems, 5)
                        local contentHeight = 50 + (itemCount * 34) + 15
                        local totalHeight = baseHeight + 10 + contentHeight
                        
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3, Enum.EasingStyle.Back)
                        Tween(DropdownContent, {Size = UDim2.new(1, -24, 0, contentHeight)}, 0.3, Enum.EasingStyle.Back)
                    else
                        Tween(DropdownArrow, {Rotation = 0}, 0.2)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, baseHeight)}, 0.25)
                        Tween(DropdownContent, {Size = UDim2.new(1, -24, 0, 0)}, 0.25)
                    end
                end)
                
                DropdownFrame.MouseEnter:Connect(function()
                    Tween(DropdownFrame, {BackgroundTransparency = 0.3}, 0.15)
                end)
                DropdownFrame.MouseLeave:Connect(function()
                    Tween(DropdownFrame, {BackgroundTransparency = 0.5}, 0.15)
                end)
                
                function Dropdown:SetItems(items)
                    Dropdown.Items = items
                    for _, child in pairs(ItemsList:GetChildren()) do
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
                        -- Update UI...
                    else
                        Dropdown.Value = value
                        DropdownButtonText.Text = value
                        DropdownButtonText.TextColor3 = Theme.TextPrimary
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
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextTertiary,
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
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 0.3}, 0.2)
            Tween(Window.CurrentTab.Glow, {BackgroundTransparency = 1}, 0.2)
            Tween(Window.CurrentTab.NameLabel, {TextColor3 = Theme.TextSecondary}, 0.2)
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        
        Tween(tab.Button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent}, 0.2)
        Tween(tab.Glow, {BackgroundTransparency = 0.8}, 0.2)
        Tween(tab.NameLabel, {TextColor3 = Theme.TextPrimary}, 0.2)
    end
    
    -- ============================================================
    -- [[ NOTIFICATION SYSTEM (iOS Style) ]]
    -- ============================================================
    
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 20),
        Size = UDim2.new(0, 350, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0)
    })
    
    Create("UIListLayout", {
        Parent = NotificationContainer,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
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
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true
        })
        AddCorner(NotifCard, 14)
        AddShadow(NotifCard, 0.5)
        
        -- Glass effect
        local NotifGlass = Create("Frame", {
            Name = "Glass",
            Parent = NotifCard,
            BackgroundColor3 = Theme.Glass,
            BackgroundTransparency = 0.92,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 0
        })
        AddCorner(NotifGlass, 14)
        
        -- Accent bar
        local NotifAccent = Create("Frame", {
            Name = "Accent",
            Parent = NotifCard,
            BackgroundColor3 = data.Color,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 4, 1, 0)
        })
        
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
        
        -- Animate
        task.spawn(function()
            task.wait(0.05)
            local height = 55 + NotifContent.TextBounds.Y
            
            NotifCard.Position = UDim2.new(0, 0, 0, -height)
            Tween(NotifCard, {Size = UDim2.new(1, 0, 0, height), Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
            
            task.wait(duration)
            
            Tween(NotifCard, {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, -height)}, 0.3).Completed:Connect(function()
                NotifCard:Destroy()
            end)
        end)
    end
    
    getgenv().EnzoUILib = Window
    
    return Window
end

return EnzoLib