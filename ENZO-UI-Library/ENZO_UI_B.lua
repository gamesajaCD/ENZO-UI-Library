--[[
    ENZO UI LIBRARY - Design B: Sidebar Modern
    Version: 1.0.0
    Author: ENZO-YT
    
    Style: Discord/Spotify inspired with left sidebar
    Features (Basic untuk test design):
    - Window dengan Draggable
    - Sidebar Tab Navigation
    - Toggle, Slider, Button, Dropdown with Search
    - Opacity Control
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
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
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
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Color3.fromRGB(60, 60, 60),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
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
-- [[ THEME COLORS - Sidebar Modern ]]
-- ============================================================
local Theme = {
    -- Sidebar
    SidebarBG = Color3.fromRGB(18, 18, 22),
    SidebarAccent = Color3.fromRGB(25, 25, 30),
    
    -- Main
    Background = Color3.fromRGB(24, 24, 28),
    Secondary = Color3.fromRGB(32, 32, 38),
    Tertiary = Color3.fromRGB(42, 42, 50),
    
    -- Accent
    Accent = Color3.fromRGB(114, 137, 218),      -- Discord blurple
    AccentHover = Color3.fromRGB(134, 157, 238),
    AccentDark = Color3.fromRGB(94, 117, 198),
    
    -- Text
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 160),
    TextDark = Color3.fromRGB(100, 100, 110),
    
    -- Status
    Online = Color3.fromRGB(67, 181, 129),
    Idle = Color3.fromRGB(250, 166, 26),
    Dnd = Color3.fromRGB(240, 71, 71),
    Offline = Color3.fromRGB(116, 127, 141),
    
    -- Misc
    Divider = Color3.fromRGB(50, 50, 55),
    Hover = Color3.fromRGB(55, 55, 65),
}

-- ============================================================
-- [[ MAIN LIBRARY ]]
-- ============================================================

function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "v1.0.0"
    local size = config.Size or UDim2.new(0, 650, 0, 450)
    local sidebarWidth = config.SidebarWidth or 60
    local opacity = config.Opacity or 0
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Opacity = opacity
    Window.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    Window.Visible = true
    Window.SidebarExpanded = false
    
    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "EnzoUI_B_" .. tostring(math.random(100000, 999999)),
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
    
    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        ClipsDescendants = true
    })
    AddCorner(MainFrame, 10)
    
    Window.MainFrame = MainFrame
    
    -- Shadow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    
    -- ============================================================
    -- [[ SIDEBAR ]]
    -- ============================================================
    
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.SidebarBG,
        BackgroundTransparency = opacity,
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        ZIndex = 5
    })
    
    -- Round only left corners
    local SidebarCorner = Create("Frame", {
        Name = "CornerMask",
        Parent = Sidebar,
        BackgroundColor3 = Theme.SidebarBG,
        BackgroundTransparency = opacity,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        ZIndex = 4
    })
    AddCorner(Sidebar, 10)
    
    -- Logo/Brand Area
    local LogoArea = Create("Frame", {
        Name = "LogoArea",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 6
    })
    
    local LogoIcon = Create("TextLabel", {
        Name = "Logo",
        Parent = LogoArea,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0.5, -20, 0.5, -20),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "E",
        TextColor3 = Theme.Text,
        TextSize = 22,
        ZIndex = 7
    })
    AddCorner(LogoIcon, 10)
    
    -- Divider after logo
    local LogoDivider = Create("Frame", {
        Name = "Divider",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Divider,
        Position = UDim2.new(0.15, 0, 0, 65),
        Size = UDim2.new(0.7, 0, 0, 2),
        ZIndex = 6
    })
    AddCorner(LogoDivider, 1)
    
    -- Tab List Container
    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 75),
        Size = UDim2.new(1, 0, 1, -135),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 6
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabList,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    AddPadding(TabList, 5)
    
    -- Bottom Section (Settings icon)
    local BottomSection = Create("Frame", {
        Name = "BottomSection",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -60),
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 6
    })
    
    -- Divider before bottom
    local BottomDivider = Create("Frame", {
        Name = "Divider",
        Parent = BottomSection,
        BackgroundColor3 = Theme.Divider,
        Position = UDim2.new(0.15, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 0, 2),
        ZIndex = 6
    })
    AddCorner(BottomDivider, 1)
    
    MakeDraggable(MainFrame, LogoArea)
    
    -- ============================================================
    -- [[ CONTENT AREA ]]
    -- ============================================================
    
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, sidebarWidth, 0, 0),
        Size = UDim2.new(1, -sidebarWidth, 1, 0)
    })
    
    -- Top Bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = ContentArea,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = opacity,
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 3
    })
    
    -- Round only top-right corner
    AddCorner(TopBar, 10)
    local TopBarFix1 = Create("Frame", {
        Name = "Fix1",
        Parent = TopBar,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        ZIndex = 2
    })
    local TopBarFix2 = Create("Frame", {
        Name = "Fix2",
        Parent = TopBar,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        ZIndex = 2
    })
    
    -- Tab Title in TopBar
    local TabTitle = Create("TextLabel", {
        Name = "TabTitle",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "# " .. title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    })
    
    -- Window Controls
    local Controls = Create("Frame", {
        Name = "Controls",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0.5, -12),
        Size = UDim2.new(0, 85, 0, 24),
        ZIndex = 4
    })
    
    local ControlsLayout = Create("UIListLayout", {
        Parent = Controls,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8)
    })
    
    local function CreateControl(name, icon, color, callback)
        local btn = Create("TextButton", {
            Name = name,
            Parent = Controls,
            BackgroundColor3 = color,
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0, 24, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = Theme.Text,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 5
        })
        AddCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.3}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.7}, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    CreateControl("Minimize", "─", Theme.Idle, function()
        Window:Toggle()
    end)
    CreateControl("Maximize", "□", Theme.Accent, function() end)
    CreateControl("Close", "✕", Theme.Dnd, function()
        Window:Destroy()
    end)
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -90)
    })
    
    -- Bottom Bar
    local BottomBar = Create("Frame", {
        Name = "BottomBar",
        Parent = ContentArea,
        BackgroundColor3 = Theme.SidebarBG,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0, 0, 1, -40),
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 3
    })
    AddCorner(BottomBar, 10)
    
    local BottomBarFix = Create("Frame", {
        Name = "Fix",
        Parent = BottomBar,
        BackgroundColor3 = Theme.SidebarBG,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -10, 0, 15),
        ZIndex = 2
    })
    
    -- Opacity Control in Bottom Bar
    local OpacityContainer = Create("Frame", {
        Name = "OpacityContainer",
        Parent = BottomBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -10),
        Size = UDim2.new(0, 150, 0, 20),
        ZIndex = 4
    })
    
    local OpacityIcon = Create("TextLabel", {
        Name = "Icon",
        Parent = OpacityContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🔆",
        TextSize = 14,
        ZIndex = 5
    })
    
    local OpacitySliderBG = Create("Frame", {
        Name = "SliderBG",
        Parent = OpacityContainer,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0, 25, 0.5, -3),
        Size = UDim2.new(0, 80, 0, 6),
        ZIndex = 5
    })
    AddCorner(OpacitySliderBG, 3)
    
    local OpacityFill = Create("Frame", {
        Name = "Fill",
        Parent = OpacitySliderBG,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1 - opacity, 0, 1, 0),
        ZIndex = 6
    })
    AddCorner(OpacityFill, 3)
    
    local OpacityKnob = Create("Frame", {
        Name = "Knob",
        Parent = OpacitySliderBG,
        BackgroundColor3 = Theme.Text,
        Position = UDim2.new(1 - opacity, -5, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        ZIndex = 7
    })
    AddCorner(OpacityKnob, 5)
    
    local OpacityValue = Create("TextLabel", {
        Name = "Value",
        Parent = OpacityContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 110, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.Gotham,
        Text = math.floor((1 - opacity) * 100) .. "%",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        ZIndex = 5
    })
    
    -- Opacity Slider Logic
    local opacityDragging = false
    
    local function UpdateAllOpacity(newOpacity)
        Window.Opacity = newOpacity
        MainFrame.BackgroundTransparency = newOpacity
        Sidebar.BackgroundTransparency = newOpacity
        SidebarCorner.BackgroundTransparency = newOpacity
        TopBar.BackgroundTransparency = newOpacity
        TopBarFix1.BackgroundTransparency = newOpacity
        TopBarFix2.BackgroundTransparency = newOpacity
        BottomBar.BackgroundTransparency = newOpacity
        BottomBarFix.BackgroundTransparency = newOpacity
    end
    
    local function UpdateOpacitySlider(input)
        local pos = math.clamp((input.Position.X - OpacitySliderBG.AbsolutePosition.X) / OpacitySliderBG.AbsoluteSize.X, 0, 1)
        local newOpacity = 1 - pos
        
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -5, 0.5, -5)
        OpacityValue.Text = math.floor(pos * 100) .. "%"
        
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
    local ToggleKeyDisplay = Create("TextLabel", {
        Name = "ToggleKey",
        Parent = BottomBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -130, 0.5, -10),
        Size = UDim2.new(0, 115, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "🔑 " .. Window.ToggleKey.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 4
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
            Tween(MainFrame, {Size = size}, 0.3, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 0)}, 0.25).Completed:Connect(function()
                if not self.Visible then
                    MainFrame.Visible = false
                end
            end)
        end
    end
    
    function Window:Destroy()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3).Completed:Connect(function()
            ScreenGui:Destroy()
        end)
        getgenv().EnzoUILib = nil
    end
    
    function Window:SetOpacity(value)
        UpdateAllOpacity(value)
        local pos = 1 - value
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -5, 0.5, -5)
        OpacityValue.Text = math.floor(pos * 100) .. "%"
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
        
        -- Tab Button in Sidebar
        local TabButton = Create("TextButton", {
            Name = tabName,
            Parent = TabList,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 44, 0, 44),
            Font = Enum.Font.GothamBold,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 7
        })
        AddCorner(TabButton, 12)
        
        local TabIcon = Create("TextLabel", {
            Name = "Icon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextColor3 = Theme.TextMuted,
            TextSize = 20,
            ZIndex = 8
        })
        
        -- Indicator line (left side)
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            Parent = TabButton,
            BackgroundColor3 = Theme.Accent,
            Position = UDim2.new(0, -8, 0.2, 0),
            Size = UDim2.new(0, 4, 0.6, 0),
            Visible = false,
            ZIndex = 8
        })
        AddCorner(TabIndicator, 2)
        
        -- Tooltip
        local TabTooltip = Create("TextLabel", {
            Name = "Tooltip",
            Parent = TabButton,
            BackgroundColor3 = Theme.Tertiary,
            Position = UDim2.new(1, 10, 0.5, -12),
            Size = UDim2.new(0, 0, 0, 24),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamMedium,
            Text = "  " .. tabName .. "  ",
            TextColor3 = Theme.Text,
            TextSize = 12,
            Visible = false,
            ZIndex = 100
        })
        AddCorner(TabTooltip, 6)
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        AddPadding(TabContent, 15)
        
        local TabContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 15),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Indicator = TabIndicator
        Tab.Icon = TabIcon
        
        -- Tab Hover Effects
        TabButton.MouseEnter:Connect(function()
            TabTooltip.Visible = true
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.8}, 0.15)
                Tween(TabIcon, {TextColor3 = Theme.Text}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            TabTooltip.Visible = false
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
                Tween(TabIcon, {TextColor3 = Theme.TextMuted}, 0.15)
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
                    Size = UDim2.new(0.48, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = sectionSide == "Left" and 1 or 2
                })
                
                Create("UIListLayout", {
                    Parent = column,
                    Padding = UDim.new(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
            
            -- Section Frame
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Parent = column,
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = Window.Opacity * 0.5,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddCorner(SectionFrame, 8)
            AddStroke(SectionFrame, Theme.Divider, 1, 0.5)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                Name = "Header",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35)
            })
            
            local SectionIcon = Create("TextLabel", {
                Name = "Icon",
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Font = Enum.Font.GothamBold,
                Text = "⚡",
                TextSize = 14
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 32, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName:upper(),
                TextColor3 = Theme.TextMuted,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Divider line
            local SectionDivider = Create("Frame", {
                Name = "Divider",
                Parent = SectionFrame,
                BackgroundColor3 = Theme.Divider,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 1)
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                Name = "Content",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddPadding(SectionContent, 8, 12, 10, 10)
            
            Create("UIListLayout", {
                Parent = SectionContent,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            Section.Frame = SectionFrame
            Section.Content = SectionContent
            
            table.insert(Tab.Sections, Section)
            
            -- ============================================================
            -- [[ ELEMENT: TOGGLE ]]
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
                    BackgroundColor3 = Theme.Tertiary,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, toggleDescription and 48 or 36)
                })
                AddCorner(ToggleFrame, 6)
                
                local ToggleTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, toggleDescription and 6 or 0),
                    Size = UDim2.new(1, -70, 0, toggleDescription and 18 or 36),
                    Font = Enum.Font.GothamMedium,
                    Text = toggleName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if toggleDescription then
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = ToggleFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 24),
                        Size = UDim2.new(1, -70, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = toggleDescription,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local ToggleSwitch = Create("Frame", {
                    Name = "Switch",
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggleDefault and Theme.Online or Theme.Tertiary,
                    Position = UDim2.new(1, -52, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                AddCorner(ToggleSwitch, 10)
                AddStroke(ToggleSwitch, Theme.Divider, 1, 0.5)
                
                local ToggleKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = ToggleSwitch,
                    BackgroundColor3 = Theme.Text,
                    Position = toggleDefault and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                AddCorner(ToggleKnob, 8)
                
                local function UpdateToggle()
                    Toggle.Value = not Toggle.Value
                    
                    if Toggle.Value then
                        Tween(ToggleSwitch, {BackgroundColor3 = Theme.Online}, 0.2)
                        Tween(ToggleKnob, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2, Enum.EasingStyle.Back)
                    else
                        Tween(ToggleSwitch, {BackgroundColor3 = Theme.Tertiary}, 0.2)
                        Tween(ToggleKnob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back)
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
                
                local Slider = {}
                Slider.Value = sliderDefault
                
                local SliderFrame = Create("Frame", {
                    Name = sliderName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Tertiary,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, sliderDescription and 58 or 48)
                })
                AddCorner(SliderFrame, 6)
                
                local SliderTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -60, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = sliderName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -50, 0, 6),
                    Size = UDim2.new(0, 38, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(sliderDefault),
                    TextColor3 = Theme.Accent,
                    TextSize = 11
                })
                AddCorner(SliderValueLabel, 4)
                
                if sliderDescription then
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = SliderFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -24, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = sliderDescription,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local SliderBG = Create("Frame", {
                    Name = "SliderBG",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 12, 1, -18),
                    Size = UDim2.new(1, -24, 0, 8)
                })
                AddCorner(SliderBG, 4)
                
                local defaultPercent = (sliderDefault - sliderMin) / (sliderMax - sliderMin)
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBG,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(defaultPercent, 0, 1, 0)
                })
                AddCorner(SliderFill, 4)
                AddGradient(SliderFill, Theme.AccentHover, Theme.AccentDark, 0)
                
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = SliderBG,
                    BackgroundColor3 = Theme.Text,
                    Position = UDim2.new(defaultPercent, -7, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 2
                })
                AddCorner(SliderKnob, 7)
                AddStroke(SliderKnob, Theme.Accent, 2)
                
                local sliderDragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                    local value = math.floor(sliderMin + (sliderMax - sliderMin) * pos)
                    
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                    SliderValueLabel.Text = tostring(value)
                    
                    sliderCallback(value)
                end
                
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderBG.InputEnded:Connect(function(input)
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
                    Tween(SliderFrame, {BackgroundTransparency = 0.3}, 0.15)
                end)
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {BackgroundTransparency = 0.5}, 0.15)
                end)
                
                function Slider:SetValue(value)
                    local pos = (value - sliderMin) / (sliderMax - sliderMin)
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                    SliderValueLabel.Text = tostring(value)
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
                
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = buttonName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(1, 0, 0, buttonDescription and 50 or 36),
                    Font = Enum.Font.GothamBold,
                    Text = "",
                    AutoButtonColor = false
                })
                AddCorner(ButtonFrame, 6)
                AddGradient(ButtonFrame, Theme.Accent, Theme.AccentDark, 90)
                
                local ButtonIcon = Create("TextLabel", {
                    Name = "Icon",
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, buttonDescription and 8 or 0),
                    Size = UDim2.new(0, 20, 0, buttonDescription and 18 or 36),
                    Font = Enum.Font.GothamBold,
                    Text = "▶",
                    TextColor3 = Theme.Text,
                    TextSize = 12
                })
                
                local ButtonTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 35, 0, buttonDescription and 8 or 0),
                    Size = UDim2.new(1, -45, 0, buttonDescription and 18 or 36),
                    Font = Enum.Font.GothamBold,
                    Text = buttonName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if buttonDescription then
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = ButtonFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 35, 0, 26),
                        Size = UDim2.new(1, -45, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = buttonDescription,
                        TextColor3 = Color3.fromRGB(200, 200, 220),
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentHover}, 0.15)
                end)
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.15)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    -- Ripple effect simulation
                    local originalSize = ButtonFrame.Size
                    Tween(ButtonFrame, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, originalSize.Y.Scale, originalSize.Y.Offset - 2)}, 0.1).Completed:Connect(function()
                        Tween(ButtonFrame, {Size = originalSize}, 0.1)
                    end)
                    buttonCallback()
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
                
                local baseHeight = dropdownDescription and 65 or 52
                
                local DropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Tertiary,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, baseHeight),
                    ClipsDescendants = true
                })
                AddCorner(DropdownFrame, 6)
                
                local DropdownTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -24, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = dropdownName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if dropdownDescription then
                    Create("TextLabel", {
                        Name = "Description",
                        Parent = DropdownFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -24, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = dropdownDescription,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 10, 0, dropdownDescription and 38 or 26),
                    Size = UDim2.new(1, -20, 0, 22),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false
                })
                AddCorner(DropdownButton, 4)
                AddStroke(DropdownButton, Theme.Divider, 1)
                
                local DropdownButtonText = Create("TextLabel", {
                    Name = "Text",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = dropdownMulti and "Select items..." or (dropdownDefault or "Select..."),
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -22, 0, 0),
                    Size = UDim2.new(0, 18, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextMuted,
                    TextSize = 10
                })
                
                -- Dropdown Content Container
                local DropdownContent = Create("Frame", {
                    Name = "Content",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 10, 0, baseHeight + 5),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true
                })
                AddCorner(DropdownContent, 4)
                AddStroke(DropdownContent, Theme.Divider, 1)
                
                -- Search Box
                local SearchContainer = Create("Frame", {
                    Name = "SearchContainer",
                    Parent = DropdownContent,
                    BackgroundColor3 = Theme.Tertiary,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 0, 26)
                })
                AddCorner(SearchContainer, 4)
                
                local SearchIcon = Create("TextLabel", {
                    Name = "Icon",
                    Parent = SearchContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "🔍",
                    TextSize = 12
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
                    PlaceholderColor3 = Theme.TextDark,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false
                })
                
                -- Items Scroll
                local ItemsScroll = Create("ScrollingFrame", {
                    Name = "Items",
                    Parent = DropdownContent,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 1, -36),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })
                AddPadding(ItemsScroll, 5)
                
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
                        BackgroundColor3 = isSelected and Theme.Accent or Theme.Tertiary,
                        BackgroundTransparency = isSelected and 0.3 or 0.7,
                        Size = UDim2.new(1, -10, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false
                    })
                    AddCorner(ItemButton, 4)
                    
                    if dropdownMulti then
                        local Checkbox = Create("TextLabel", {
                            Name = "Checkbox",
                            Parent = ItemButton,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(0, 18, 1, 0),
                            Font = Enum.Font.GothamBold,
                            Text = isSelected and "☑" or "☐",
                            TextColor3 = isSelected and Theme.Online or Theme.TextMuted,
                            TextSize = 14
                        })
                    end
                    
                    local ItemText = Create("TextLabel", {
                        Name = "Text",
                        Parent = ItemButton,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, dropdownMulti and 28 or 10, 0, 0),
                        Size = UDim2.new(1, dropdownMulti and -35 or -20, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = itemName,
                        TextColor3 = isSelected and Theme.Text or Theme.TextMuted,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    ItemButton.MouseEnter:Connect(function()
                        if not (dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName) then
                            Tween(ItemButton, {BackgroundTransparency = 0.5}, 0.1)
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        local sel = dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName
                        Tween(ItemButton, {BackgroundTransparency = sel and 0.3 or 0.7}, 0.1)
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if dropdownMulti then
                            Dropdown.Value[itemName] = not Dropdown.Value[itemName]
                            local isNowSelected = Dropdown.Value[itemName]
                            
                            ItemButton:FindFirstChild("Checkbox").Text = isNowSelected and "☑" or "☐"
                            ItemButton:FindFirstChild("Checkbox").TextColor3 = isNowSelected and Theme.Online or Theme.TextMuted
                            Tween(ItemButton, {
                                BackgroundColor3 = isNowSelected and Theme.Accent or Theme.Tertiary,
                                BackgroundTransparency = isNowSelected and 0.3 or 0.7
                            }, 0.15)
                            ItemText.TextColor3 = isNowSelected and Theme.Text or Theme.TextMuted
                            
                            -- Update display text
                            local selected = {}
                            for k, v in pairs(Dropdown.Value) do
                                if v then table.insert(selected, k) end
                            end
                            DropdownButtonText.Text = #selected > 0 and table.concat(selected, ", ") or "Select items..."
                            
                            dropdownCallback(Dropdown.Value)
                        else
                            Dropdown.Value = itemName
                            DropdownButtonText.Text = itemName
                            DropdownButtonText.TextColor3 = Theme.Text
                            
                            for name, btn in pairs(itemButtons) do
                                local isThis = name == itemName
                                Tween(btn, {
                                    BackgroundColor3 = isThis and Theme.Accent or Theme.Tertiary,
                                    BackgroundTransparency = isThis and 0.3 or 0.7
                                }, 0.15)
                                btn:FindFirstChild("Text").TextColor3 = isThis and Theme.Text or Theme.TextMuted
                            end
                            
                            dropdownCallback(itemName)
                            
                            -- Close dropdown
                            Dropdown.Open = false
                            DropdownArrow.Text = "▼"
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, baseHeight)}, 0.2)
                            Tween(DropdownContent, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
                        end
                    end)
                    
                    return ItemButton
                end
                
                -- Create all items
                for _, item in pairs(dropdownItems) do
                    itemButtons[item] = CreateItem(item)
                end
                
                -- Search filter
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local search = SearchBox.Text:lower()
                    for name, btn in pairs(itemButtons) do
                        local match = search == "" or name:lower():find(search, 1, true)
                        btn.Visible = match
                        
                        -- Highlight matching text
                        if match and search ~= "" then
                            local text = btn:FindFirstChild("Text")
                            if text then
                                -- Simple highlight by making matched items more visible
                                text.TextColor3 = Theme.Accent
                            end
                        else
                            local text = btn:FindFirstChild("Text")
                            if text then
                                local isSelected = dropdownMulti and Dropdown.Value[name] or Dropdown.Value == name
                                text.TextColor3 = isSelected and Theme.Text or Theme.TextMuted
                            end
                        end
                    end
                end)
                
                -- Toggle dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownArrow.Text = "▲"
                        local itemCount = math.min(#dropdownItems, 5)
                        local contentHeight = 36 + (itemCount * 29) + 15
                        local totalHeight = baseHeight + 5 + contentHeight
                        
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.25, Enum.EasingStyle.Back)
                        Tween(DropdownContent, {Size = UDim2.new(1, -20, 0, contentHeight)}, 0.25, Enum.EasingStyle.Back)
                    else
                        DropdownArrow.Text = "▼"
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, baseHeight)}, 0.2)
                        Tween(DropdownContent, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
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
                        for name, btn in pairs(itemButtons) do
                            local isSelected = value[name]
                            btn:FindFirstChild("Checkbox").Text = isSelected and "☑" or "☐"
                            btn:FindFirstChild("Checkbox").TextColor3 = isSelected and Theme.Online or Theme.TextMuted
                            btn.BackgroundColor3 = isSelected and Theme.Accent or Theme.Tertiary
                            btn.BackgroundTransparency = isSelected and 0.3 or 0.7
                            btn:FindFirstChild("Text").TextColor3 = isSelected and Theme.Text or Theme.TextMuted
                        end
                        local selected = {}
                        for k, v in pairs(value) do
                            if v then table.insert(selected, k) end
                        end
                        DropdownButtonText.Text = #selected > 0 and table.concat(selected, ", ") or "Select items..."
                    else
                        Dropdown.Value = value
                        DropdownButtonText.Text = value
                        for name, btn in pairs(itemButtons) do
                            local isThis = name == value
                            btn.BackgroundColor3 = isThis and Theme.Accent or Theme.Tertiary
                            btn.BackgroundTransparency = isThis and 0.3 or 0.7
                            btn:FindFirstChild("Text").TextColor3 = isThis and Theme.Text or Theme.TextMuted
                        end
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
            Tween(Window.CurrentTab.Icon, {TextColor3 = Theme.TextMuted}, 0.15)
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        tab.Indicator.Visible = true
        TabTitle.Text = "# " .. tab.Name
        
        Tween(tab.Button, {BackgroundTransparency = 0.7}, 0.15)
        Tween(tab.Icon, {TextColor3 = Theme.Text}, 0.15)
    end
    
    -- ============================================================
    -- [[ NOTIFICATION SYSTEM ]]
    -- ============================================================
    
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -330, 1, -20),
        Size = UDim2.new(0, 310, 0, 0),
        AnchorPoint = Vector2.new(0, 1)
    })
    
    Create("UIListLayout", {
        Parent = NotificationContainer,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
    
    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local content = config.Content or ""
        local duration = config.Duration or 5
        local notifType = config.Type or "Info"
        
        local typeData = {
            Info = {Color = Theme.Accent, Icon = "ℹ️"},
            Success = {Color = Theme.Online, Icon = "✅"},
            Warning = {Color = Theme.Idle, Icon = "⚠️"},
            Error = {Color = Theme.Dnd, Icon = "❌"}
        }
        
        local data = typeData[notifType] or typeData.Info
        
        local NotifFrame = Create("Frame", {
            Name = "Notification",
            Parent = NotificationContainer,
            BackgroundColor3 = Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true
        })
        AddCorner(NotifFrame, 8)
        AddStroke(NotifFrame, data.Color, 1, 0.5)
        
        local NotifAccent = Create("Frame", {
            Name = "Accent",
            Parent = NotifFrame,
            BackgroundColor3 = data.Color,
            Size = UDim2.new(0, 4, 1, 0)
        })
        
        local NotifIcon = Create("TextLabel", {
            Name = "Icon",
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 12),
            Size = UDim2.new(0, 20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = data.Icon,
            TextSize = 16
        })
        
        local NotifTitle = Create("TextLabel", {
            Name = "Title",
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 10),
            Size = UDim2.new(1, -50, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local NotifContent = Create("TextLabel", {
            Name = "Content",
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 30),
            Size = UDim2.new(1, -50, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = content,
            TextColor3 = Theme.TextMuted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        
        -- Progress bar
        local NotifProgress = Create("Frame", {
            Name = "Progress",
            Parent = NotifFrame,
            BackgroundColor3 = data.Color,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3)
        })
        
        task.spawn(function()
            task.wait(0.05)
            local height = 50 + NotifContent.TextBounds.Y
            Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.3, Enum.EasingStyle.Back)
            
            -- Animate progress bar
            Tween(NotifProgress, {Size = UDim2.new(0, 0, 0, 3)}, duration)
            
            task.wait(duration)
            
            Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25).Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end)
    end
    
    getgenv().EnzoUILib = Window
    
    return Window
end

return EnzoLib