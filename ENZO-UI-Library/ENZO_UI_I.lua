--[[
    ╔══════════════════════════════════════════╗
    ║          NexusLib UI Library v1.0        ║
    ║       Modern Roblox UI Library           ║
    ╚══════════════════════════════════════════╝
    
    Contoh Penggunaan:
    
    local NexusLib = loadstring(game:HttpGet("URL_DISINI"))()
    
    local Window = NexusLib:CreateWindow({
        Title = "NexusLib",
        SubTitle = "v1.0.0",
        Size = UDim2.new(0, 580, 0, 400),
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift
    })
    
    local Tab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://7733960981" })
    
    Tab:AddButton({ Title = "Click Me", Description = "A button", Callback = function() print("Clicked!") end })
    Tab:AddToggle({ Title = "Toggle", Default = false, Callback = function(v) print(v) end })
    Tab:AddSlider({ Title = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(v) print(v) end })
    Tab:AddDropdown({ Title = "Select", Options = {"A","B","C"}, Default = "A", Callback = function(v) print(v) end })
    Tab:AddInput({ Title = "Name", Placeholder = "Enter name...", Callback = function(v) print(v) end })
    Tab:AddKeybind({ Title = "Keybind", Default = Enum.KeyCode.E, Callback = function() print("Pressed!") end })
    
    Window:AddNotification({ Title = "Welcome!", Content = "NexusLib loaded.", Duration = 5 })
]]

-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════════════
-- LIBRARY TABLE
-- ═══════════════════════════════════════════════
local NexusLib = {}
NexusLib.__index = NexusLib
NexusLib._version = "1.0.0"

-- ═══════════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════════
local Themes = {
    Dark = {
        Background        = Color3.fromRGB(22, 22, 30),
        SideBar           = Color3.fromRGB(18, 18, 26),
        TopBar            = Color3.fromRGB(28, 28, 38),
        TabActive         = Color3.fromRGB(50, 50, 75),
        TabInactive       = Color3.fromRGB(28, 28, 40),
        TabHover          = Color3.fromRGB(38, 38, 55),
        Element           = Color3.fromRGB(32, 32, 45),
        ElementHover      = Color3.fromRGB(40, 40, 55),
        ElementBorder     = Color3.fromRGB(55, 55, 75),
        Accent            = Color3.fromRGB(88, 101, 242),
        AccentDark        = Color3.fromRGB(68, 80, 200),
        TextPrimary       = Color3.fromRGB(235, 235, 245),
        TextSecondary     = Color3.fromRGB(155, 155, 175),
        TextDimmed        = Color3.fromRGB(95, 95, 115),
        ToggleOn          = Color3.fromRGB(88, 101, 242),
        ToggleOff         = Color3.fromRGB(55, 55, 75),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(88, 101, 242),
        SliderBack        = Color3.fromRGB(45, 45, 60),
        InputBackground   = Color3.fromRGB(25, 25, 36),
        DropdownOption     = Color3.fromRGB(28, 28, 40),
        DropdownOptionHover = Color3.fromRGB(42, 42, 58),
        NotifBackground   = Color3.fromRGB(28, 28, 40),
        NotifAccent       = Color3.fromRGB(88, 101, 242),
        Shadow            = Color3.fromRGB(8, 8, 12),
        Divider           = Color3.fromRGB(45, 45, 60),
        Close             = Color3.fromRGB(240, 70, 70),
        Minimize          = Color3.fromRGB(240, 190, 50),
    },
    Midnight = {
        Background        = Color3.fromRGB(15, 15, 25),
        SideBar           = Color3.fromRGB(12, 12, 20),
        TopBar            = Color3.fromRGB(20, 20, 32),
        TabActive         = Color3.fromRGB(40, 35, 70),
        TabInactive       = Color3.fromRGB(20, 18, 35),
        TabHover          = Color3.fromRGB(30, 28, 52),
        Element           = Color3.fromRGB(25, 22, 42),
        ElementHover      = Color3.fromRGB(35, 32, 55),
        ElementBorder     = Color3.fromRGB(50, 45, 75),
        Accent            = Color3.fromRGB(130, 80, 245),
        AccentDark        = Color3.fromRGB(105, 60, 210),
        TextPrimary       = Color3.fromRGB(230, 225, 245),
        TextSecondary     = Color3.fromRGB(150, 140, 175),
        TextDimmed        = Color3.fromRGB(90, 85, 115),
        ToggleOn          = Color3.fromRGB(130, 80, 245),
        ToggleOff         = Color3.fromRGB(50, 45, 70),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(130, 80, 245),
        SliderBack        = Color3.fromRGB(40, 35, 60),
        InputBackground   = Color3.fromRGB(18, 16, 30),
        DropdownOption     = Color3.fromRGB(22, 20, 38),
        DropdownOptionHover = Color3.fromRGB(38, 35, 58),
        NotifBackground   = Color3.fromRGB(22, 20, 38),
        NotifAccent       = Color3.fromRGB(130, 80, 245),
        Shadow            = Color3.fromRGB(5, 5, 10),
        Divider           = Color3.fromRGB(40, 36, 60),
        Close             = Color3.fromRGB(240, 70, 70),
        Minimize          = Color3.fromRGB(240, 190, 50),
    },
    Aqua = {
        Background        = Color3.fromRGB(18, 26, 32),
        SideBar           = Color3.fromRGB(14, 22, 28),
        TopBar            = Color3.fromRGB(22, 32, 40),
        TabActive         = Color3.fromRGB(30, 65, 75),
        TabInactive       = Color3.fromRGB(20, 30, 38),
        TabHover          = Color3.fromRGB(25, 48, 58),
        Element           = Color3.fromRGB(24, 36, 44),
        ElementHover      = Color3.fromRGB(30, 45, 55),
        ElementBorder     = Color3.fromRGB(40, 65, 78),
        Accent            = Color3.fromRGB(0, 180, 210),
        AccentDark        = Color3.fromRGB(0, 145, 175),
        TextPrimary       = Color3.fromRGB(225, 240, 245),
        TextSecondary     = Color3.fromRGB(140, 170, 180),
        TextDimmed        = Color3.fromRGB(85, 110, 120),
        ToggleOn          = Color3.fromRGB(0, 180, 210),
        ToggleOff         = Color3.fromRGB(40, 60, 70),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(0, 180, 210),
        SliderBack        = Color3.fromRGB(35, 50, 60),
        InputBackground   = Color3.fromRGB(16, 24, 30),
        DropdownOption     = Color3.fromRGB(20, 30, 38),
        DropdownOptionHover = Color3.fromRGB(30, 50, 60),
        NotifBackground   = Color3.fromRGB(20, 30, 38),
        NotifAccent       = Color3.fromRGB(0, 180, 210),
        Shadow            = Color3.fromRGB(6, 10, 14),
        Divider           = Color3.fromRGB(35, 55, 65),
        Close             = Color3.fromRGB(240, 70, 70),
        Minimize          = Color3.fromRGB(240, 190, 50),
    },
    Rose = {
        Background        = Color3.fromRGB(28, 20, 24),
        SideBar           = Color3.fromRGB(24, 16, 20),
        TopBar            = Color3.fromRGB(35, 25, 30),
        TabActive         = Color3.fromRGB(70, 40, 55),
        TabInactive       = Color3.fromRGB(32, 22, 28),
        TabHover          = Color3.fromRGB(50, 32, 42),
        Element           = Color3.fromRGB(38, 28, 33),
        ElementHover      = Color3.fromRGB(48, 35, 42),
        ElementBorder     = Color3.fromRGB(65, 45, 55),
        Accent            = Color3.fromRGB(230, 70, 120),
        AccentDark        = Color3.fromRGB(195, 55, 100),
        TextPrimary       = Color3.fromRGB(245, 230, 235),
        TextSecondary     = Color3.fromRGB(175, 145, 155),
        TextDimmed        = Color3.fromRGB(115, 90, 100),
        ToggleOn          = Color3.fromRGB(230, 70, 120),
        ToggleOff         = Color3.fromRGB(60, 42, 50),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(230, 70, 120),
        SliderBack        = Color3.fromRGB(50, 35, 42),
        InputBackground   = Color3.fromRGB(25, 18, 22),
        DropdownOption     = Color3.fromRGB(30, 22, 27),
        DropdownOptionHover = Color3.fromRGB(50, 35, 42),
        NotifBackground   = Color3.fromRGB(32, 24, 28),
        NotifAccent       = Color3.fromRGB(230, 70, 120),
        Shadow            = Color3.fromRGB(10, 6, 8),
        Divider           = Color3.fromRGB(55, 40, 48),
        Close             = Color3.fromRGB(240, 70, 70),
        Minimize          = Color3.fromRGB(240, 190, 50),
    },
}

-- ═══════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════
local function Tween(obj, props, duration, style, direction)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.25,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        props
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 70)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function AddPadding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

local function AddListLayout(parent, padding, dir, hAlign, vAlign, sortOrder)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 6)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center
    l.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
    l.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function MakeDraggable(topBar, mainFrame)
    local dragging, dragInput, dragStart, startPos

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(mainFrame, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.08, Enum.EasingStyle.Sine)
        end
    end)
end

local function CreateRipple(button, theme)
    button.ClipsDescendants = true
    button.MouseButton1Click:Connect(function()
        local mPos = UserInputService:GetMouseLocation()
        local aPos = button.AbsolutePosition
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.82
        ripple.BorderSizePixel = 0
        ripple.Position = UDim2.new(0, mPos.X - aPos.X, 0, mPos.Y - aPos.Y - 36)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.ZIndex = button.ZIndex + 5
        ripple.Parent = button
        AddCorner(ripple, 999)

        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
        Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.55)
        task.delay(0.55, function() ripple:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════
-- MAIN: CREATE WINDOW
-- ═══════════════════════════════════════════════
function NexusLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "NexusLib"
    local subTitle = config.SubTitle or "v1.0.0"
    local windowSize = config.Size or UDim2.new(0, 580, 0, 400)
    local themeName = config.Theme or "Dark"
    local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    local tabWidth = config.TabWidth or 155

    local Theme = Themes[themeName] or Themes.Dark

    -- Destroy existing
    local existing = (syn and syn.protect_gui) and game:GetService("CoreGui"):FindFirstChild("NexusLib") or game:GetService("CoreGui"):FindFirstChild("NexusLib")
    if existing then existing:Destroy() end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusLib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Try protect_gui (for some executors)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = game:GetService("CoreGui")
        elseif gethui then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = game:GetService("CoreGui")
        end
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end

    -- ════════════════════════
    -- MAIN FRAME (WINDOW)
    -- ════════════════════════
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.Size = windowSize
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, 10)
    AddStroke(MainFrame, Theme.ElementBorder, 1, 0.6)

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Theme.Shadow
    Shadow.ImageTransparency = 0.4
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame

    -- Open Animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.BackgroundTransparency = 1
    Tween(MainFrame, {Size = windowSize, BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ════════════════════════
    -- TOP BAR
    -- ════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = Theme.TopBar
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 5
    TopBar.Parent = MainFrame
    AddCorner(TopBar, 10)

    -- Bottom rectangle to cover bottom corners of topbar
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Name = "Fix"
    TopBarFix.BackgroundColor3 = Theme.TopBar
    TopBarFix.Size = UDim2.new(1, 0, 0, 14)
    TopBarFix.Position = UDim2.new(0, 0, 1, -14)
    TopBarFix.BorderSizePixel = 0
    TopBarFix.ZIndex = 5
    TopBarFix.Parent = TopBar

    -- Divider under TopBar
    local TopDivider = Instance.new("Frame")
    TopDivider.Name = "Divider"
    TopDivider.BackgroundColor3 = Theme.Divider
    TopDivider.Size = UDim2.new(1, 0, 0, 1)
    TopDivider.Position = UDim2.new(0, 0, 0, 42)
    TopDivider.BorderSizePixel = 0
    TopDivider.ZIndex = 6
    TopDivider.Parent = MainFrame

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 6
    TitleLabel.Parent = TopBar

    -- SubTitle
    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Name = "SubTitle"
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Position = UDim2.new(0, TitleLabel.Position.X.Offset + #title * 9 + 8, 0, 0)
    SubTitleLabel.Size = UDim2.new(0, 150, 1, 0)
    SubTitleLabel.Font = Enum.Font.Gotham
    SubTitleLabel.Text = subTitle
    SubTitleLabel.TextColor3 = Theme.TextDimmed
    SubTitleLabel.TextSize = 12
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.ZIndex = 6
    SubTitleLabel.Parent = TopBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.BackgroundColor3 = Theme.Close
    CloseBtn.Size = UDim2.new(0, 14, 0, 14)
    CloseBtn.Position = UDim2.new(1, -30, 0.5, 0)
    CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
    CloseBtn.Text = ""
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 7
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TopBar
    AddCorner(CloseBtn, 99)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {Size = UDim2.new(0, 16, 0, 16)}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {Size = UDim2.new(0, 14, 0, 14)}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.45, function() ScreenGui:Destroy() end)
    end)

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "Minimize"
    MinBtn.BackgroundColor3 = Theme.Minimize
    MinBtn.Size = UDim2.new(0, 14, 0, 14)
    MinBtn.Position = UDim2.new(1, -52, 0.5, 0)
    MinBtn.AnchorPoint = Vector2.new(0, 0.5)
    MinBtn.Text = ""
    MinBtn.BorderSizePixel = 0
    MinBtn.ZIndex = 7
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = TopBar
    AddCorner(MinBtn, 99)

    local minimized = false
    local originalSize = windowSize

    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {Size = UDim2.new(0, 16, 0, 16)}, 0.15)
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {Size = UDim2.new(0, 14, 0, 14)}, 0.15)
    end)
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, {Size = UDim2.new(0, originalSize.X.Offset, 0, 42)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        else
            Tween(MainFrame, {Size = originalSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    -- Keybind to toggle visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == minimizeKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    MakeDraggable(TopBar, MainFrame)

    -- ════════════════════════
    -- SIDEBAR (TAB LIST)
    -- ════════════════════════
    local SideBar = Instance.new("Frame")
    SideBar.Name = "SideBar"
    SideBar.BackgroundColor3 = Theme.SideBar
    SideBar.Size = UDim2.new(0, tabWidth, 1, -43)
    SideBar.Position = UDim2.new(0, 0, 0, 43)
    SideBar.BorderSizePixel = 0
    SideBar.ZIndex = 3
    SideBar.Parent = MainFrame

    -- Bottom-left corner fix
    local SBCornerFix = Instance.new("Frame")
    SBCornerFix.BackgroundColor3 = Theme.SideBar
    SBCornerFix.Size = UDim2.new(1, 0, 0, 10)
    SBCornerFix.Position = UDim2.new(0, 0, 0, 0)
    SBCornerFix.BorderSizePixel = 0
    SBCornerFix.ZIndex = 3
    SBCornerFix.Parent = SideBar

    -- Sidebar ScrollFrame
    local SideBarScroll = Instance.new("ScrollingFrame")
    SideBarScroll.Name = "TabScroll"
    SideBarScroll.BackgroundTransparency = 1
    SideBarScroll.Size = UDim2.new(1, 0, 1, -10)
    SideBarScroll.Position = UDim2.new(0, 0, 0, 10)
    SideBarScroll.BorderSizePixel = 0
    SideBarScroll.ScrollBarThickness = 0
    SideBarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SideBarScroll.ZIndex = 4
    SideBarScroll.Parent = SideBar
    AddPadding(SideBarScroll, 6, 6, 8, 8)
    local sideLayout = AddListLayout(SideBarScroll, 4, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)
    sideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SideBarScroll.CanvasSize = UDim2.new(0, 0, 0, sideLayout.AbsoluteContentSize.Y + 16)
    end)

    -- Sidebar divider
    local SideDivider = Instance.new("Frame")
    SideDivider.BackgroundColor3 = Theme.Divider
    SideDivider.Size = UDim2.new(0, 1, 1, -43)
    SideDivider.Position = UDim2.new(0, tabWidth, 0, 43)
    SideDivider.BorderSizePixel = 0
    SideDivider.ZIndex = 5
    SideDivider.Parent = MainFrame

    -- ════════════════════════
    -- CONTENT AREA
    -- ════════════════════════
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.BackgroundTransparency = 1
    ContentArea.Size = UDim2.new(1, -(tabWidth + 1), 1, -43)
    ContentArea.Position = UDim2.new(0, tabWidth + 1, 0, 43)
    ContentArea.BorderSizePixel = 0
    ContentArea.ZIndex = 3
    ContentArea.Parent = MainFrame

    -- ════════════════════════
    -- NOTIFICATION HOLDER
    -- ════════════════════════
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "Notifications"
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Size = UDim2.new(0, 300, 1, -20)
    NotifHolder.Position = UDim2.new(1, -310, 0, 10)
    NotifHolder.ZIndex = 100
    NotifHolder.Parent = ScreenGui
    local notifLayout = AddListLayout(NotifHolder, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Bottom)

    -- ════════════════════════
    -- WINDOW OBJECT
    -- ════════════════════════
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Theme = Theme
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame

    -- ════════════════════════════════════════════
    -- NOTIFICATIONS
    -- ════════════════════════════════════════════
    function Window:AddNotification(opts)
        opts = opts or {}
        local nTitle = opts.Title or "Notification"
        local nContent = opts.Content or ""
        local nDuration = opts.Duration or 5

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "Notification"
        NotifFrame.BackgroundColor3 = Theme.NotifBackground
        NotifFrame.Size = UDim2.new(1, 0, 0, 72)
        NotifFrame.BorderSizePixel = 0
        NotifFrame.ZIndex = 101
        NotifFrame.ClipsDescendants = true
        NotifFrame.Parent = NotifHolder
        AddCorner(NotifFrame, 8)
        AddStroke(NotifFrame, Theme.ElementBorder, 1, 0.6)

        -- Accent bar
        local AccBar = Instance.new("Frame")
        AccBar.BackgroundColor3 = Theme.NotifAccent
        AccBar.Size = UDim2.new(0, 4, 1, -10)
        AccBar.Position = UDim2.new(0, 6, 0, 5)
        AccBar.BorderSizePixel = 0
        AccBar.ZIndex = 102
        AccBar.Parent = NotifFrame
        AddCorner(AccBar, 3)

        local NTitle = Instance.new("TextLabel")
        NTitle.BackgroundTransparency = 1
        NTitle.Position = UDim2.new(0, 20, 0, 8)
        NTitle.Size = UDim2.new(1, -28, 0, 20)
        NTitle.Font = Enum.Font.GothamBold
        NTitle.Text = nTitle
        NTitle.TextColor3 = Theme.TextPrimary
        NTitle.TextSize = 14
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.ZIndex = 102
        NTitle.Parent = NotifFrame

        local NContent = Instance.new("TextLabel")
        NContent.BackgroundTransparency = 1
        NContent.Position = UDim2.new(0, 20, 0, 28)
        NContent.Size = UDim2.new(1, -28, 0, 30)
        NContent.Font = Enum.Font.Gotham
        NContent.Text = nContent
        NContent.TextColor3 = Theme.TextSecondary
        NContent.TextSize = 12
        NContent.TextXAlignment = Enum.TextXAlignment.Left
        NContent.TextYAlignment = Enum.TextYAlignment.Top
        NContent.TextWrapped = true
        NContent.ZIndex = 102
        NContent.Parent = NotifFrame

        -- Progress bar
        local ProgBack = Instance.new("Frame")
        ProgBack.BackgroundColor3 = Theme.SliderBack
        ProgBack.Size = UDim2.new(1, -24, 0, 3)
        ProgBack.Position = UDim2.new(0, 12, 1, -10)
        ProgBack.BorderSizePixel = 0
        ProgBack.ZIndex = 102
        ProgBack.Parent = NotifFrame
        AddCorner(ProgBack, 2)

        local ProgFill = Instance.new("Frame")
        ProgFill.BackgroundColor3 = Theme.NotifAccent
        ProgFill.Size = UDim2.new(1, 0, 1, 0)
        ProgFill.BorderSizePixel = 0
        ProgFill.ZIndex = 103
        ProgFill.Parent = ProgBack
        AddCorner(ProgFill, 2)

        -- Slide in animation
        NotifFrame.Position = UDim2.new(1, 20, 0, 0)
        Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        -- Progress animation
        Tween(ProgFill, {Size = UDim2.new(0, 0, 1, 0)}, nDuration, Enum.EasingStyle.Linear)

        -- Auto remove
        task.delay(nDuration, function()
            Tween(NotifFrame, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.35)
            task.delay(0.4, function() NotifFrame:Destroy() end)
        end)
    end

    -- ════════════════════════════════════════════
    -- ADD TAB
    -- ════════════════════════════════════════════
    function Window:AddTab(opts)
        opts = opts or {}
        local tabTitle = opts.Title or "Tab"
        local tabIcon = opts.Icon or nil

        local Tab = {}
        Tab.Elements = {}

        -- Tab Button in sidebar
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabTitle
        TabBtn.BackgroundColor3 = Theme.TabInactive
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.Text = ""
        TabBtn.BorderSizePixel = 0
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 5
        TabBtn.Parent = SideBarScroll
        AddCorner(TabBtn, 7)

        -- Accent indicator
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "Indicator"
        TabIndicator.BackgroundColor3 = Theme.Accent
        TabIndicator.Size = UDim2.new(0, 3, 0, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        TabIndicator.BorderSizePixel = 0
        TabIndicator.ZIndex = 6
        TabIndicator.Parent = TabBtn
        AddCorner(TabIndicator, 2)

        local textOffset = 12

        -- Icon (optional)
        if tabIcon then
            local IconLabel = Instance.new("ImageLabel")
            IconLabel.Name = "Icon"
            IconLabel.BackgroundTransparency = 1
            IconLabel.Position = UDim2.new(0, 12, 0.5, 0)
            IconLabel.AnchorPoint = Vector2.new(0, 0.5)
            IconLabel.Size = UDim2.new(0, 18, 0, 18)
            IconLabel.Image = tabIcon
            IconLabel.ImageColor3 = Theme.TextSecondary
            IconLabel.ZIndex = 6
            IconLabel.Parent = TabBtn
            textOffset = 38
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, textOffset, 0, 0)
        TabLabel.Size = UDim2.new(1, -textOffset - 8, 1, 0)
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.Text = tabTitle
        TabLabel.TextColor3 = Theme.TextSecondary
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.ZIndex = 6
        TabLabel.Parent = TabBtn

        -- Content page for this tab
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = "Page_" .. tabTitle
        TabPage.BackgroundTransparency = 1
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Theme.Accent
        TabPage.ScrollBarImageTransparency = 0.5
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Visible = false
        TabPage.ZIndex = 4
        TabPage.Parent = ContentArea
        AddPadding(TabPage, 10, 10, 12, 12)
        local pageLayout = AddListLayout(TabPage, 7, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 24)
        end)

        -- Tab selection logic
        local function SelectTab()
            -- Deselect all
            for _, t in pairs(Window.Tabs) do
                t.Button.BackgroundColor3 = Theme.TabInactive
                t.Label.TextColor3 = Theme.TextSecondary
                Tween(t.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                t.Page.Visible = false
                if t.IconLabel then
                    t.IconLabel.ImageColor3 = Theme.TextSecondary
                end
            end
            -- Select this
            TabBtn.BackgroundColor3 = Theme.TabActive
            TabLabel.TextColor3 = Theme.TextPrimary
            Tween(TabIndicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.25, Enum.EasingStyle.Back)
            TabPage.Visible = true
            if tabIcon then
                TabBtn:FindFirstChild("Icon").ImageColor3 = Theme.Accent
            end
            Window.ActiveTab = Tab
        end

        -- Hover effects
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Theme.TabHover}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Theme.TabInactive}, 0.15)
            end
        end)
        TabBtn.MouseButton1Click:Connect(SelectTab)

        -- Store references
        Tab.Button = TabBtn
        Tab.Label = TabLabel
        Tab.Indicator = TabIndicator
        Tab.Page = TabPage
        Tab.IconLabel = tabIcon and TabBtn:FindFirstChild("Icon") or nil
        Tab.Theme = Theme

        table.insert(Window.Tabs, Tab)

        -- Auto-select first tab
        if #Window.Tabs == 1 then
            SelectTab()
        end

        -- ════════════════════════════════════════
        -- SECTION
        -- ════════════════════════════════════════
        function Tab:AddSection(title)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section"
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Size = UDim2.new(1, 0, 0, 28)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.ZIndex = 5
            SectionFrame.Parent = TabPage

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Size = UDim2.new(1, 0, 0, 20)
            SectionLabel.Position = UDim2.new(0, 0, 0, 4)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = string.upper(title or "SECTION")
            SectionLabel.TextColor3 = Theme.TextDimmed
            SectionLabel.TextSize = 11
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.ZIndex = 5
            SectionLabel.Parent = SectionFrame

            local SectionLine = Instance.new("Frame")
            SectionLine.BackgroundColor3 = Theme.Divider
            SectionLine.Size = UDim2.new(1, 0, 0, 1)
            SectionLine.Position = UDim2.new(0, 0, 1, -2)
            SectionLine.BorderSizePixel = 0
            SectionLine.ZIndex = 5
            SectionLine.Parent = SectionFrame

            return SectionFrame
        end

        -- ════════════════════════════════════════
        -- LABEL
        -- ════════════════════════════════════════
        function Tab:AddLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Name = "Label"
            LabelFrame.BackgroundColor3 = Theme.Element
            LabelFrame.Size = UDim2.new(1, 0, 0, 36)
            LabelFrame.BorderSizePixel = 0
            LabelFrame.ZIndex = 5
            LabelFrame.Parent = TabPage
            AddCorner(LabelFrame, 7)
            AddStroke(LabelFrame, Theme.ElementBorder, 1, 0.7)

            local LabelText = Instance.new("TextLabel")
            LabelText.BackgroundTransparency = 1
            LabelText.Size = UDim2.new(1, -20, 1, 0)
            LabelText.Position = UDim2.new(0, 10, 0, 0)
            LabelText.Font = Enum.Font.Gotham
            LabelText.Text = text or "Label"
            LabelText.TextColor3 = Theme.TextSecondary
            LabelText.TextSize = 13
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.ZIndex = 6
            LabelText.Parent = LabelFrame

            local LabelObj = {}
            function LabelObj:Set(newText)
                LabelText.Text = newText
            end
            return LabelObj
        end

        -- ════════════════════════════════════════
        -- PARAGRAPH
        -- ════════════════════════════════════════
        function Tab:AddParagraph(opts)
            opts = opts or {}
            local pTitle = opts.Title or "Paragraph"
            local pContent = opts.Content or ""

            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Name = "Paragraph"
            ParagraphFrame.BackgroundColor3 = Theme.Element
            ParagraphFrame.Size = UDim2.new(1, 0, 0, 60)
            ParagraphFrame.BorderSizePixel = 0
            ParagraphFrame.ZIndex = 5
            ParagraphFrame.Parent = TabPage
            AddCorner(ParagraphFrame, 7)
            AddStroke(ParagraphFrame, Theme.ElementBorder, 1, 0.7)

            local PTitle = Instance.new("TextLabel")
            PTitle.BackgroundTransparency = 1
            PTitle.Position = UDim2.new(0, 12, 0, 8)
            PTitle.Size = UDim2.new(1, -24, 0, 18)
            PTitle.Font = Enum.Font.GothamBold
            PTitle.Text = pTitle
            PTitle.TextColor3 = Theme.TextPrimary
            PTitle.TextSize = 14
            PTitle.TextXAlignment = Enum.TextXAlignment.Left
            PTitle.ZIndex = 6
            PTitle.Parent = ParagraphFrame

            local PContent = Instance.new("TextLabel")
            PContent.BackgroundTransparency = 1
            PContent.Position = UDim2.new(0, 12, 0, 28)
            PContent.Size = UDim2.new(1, -24, 0, 26)
            PContent.Font = Enum.Font.Gotham
            PContent.Text = pContent
            PContent.TextColor3 = Theme.TextSecondary
            PContent.TextSize = 12
            PContent.TextXAlignment = Enum.TextXAlignment.Left
            PContent.TextWrapped = true
            PContent.ZIndex = 6
            PContent.Parent = ParagraphFrame

            -- Auto resize
            local textBounds = PContent.TextBounds
            task.defer(function()
                task.wait(0.05)
                local lines = math.ceil(PContent.TextBounds.Y / 14)
                local totalH = 36 + (lines * 16)
                ParagraphFrame.Size = UDim2.new(1, 0, 0, math.max(56, totalH))
                PContent.Size = UDim2.new(1, -24, 0, lines * 16)
            end)

            return ParagraphFrame
        end

        -- ════════════════════════════════════════
        -- BUTTON
        -- ════════════════════════════════════════
        function Tab:AddButton(opts)
            opts = opts or {}
            local bTitle = opts.Title or "Button"
            local bDesc = opts.Description or nil
            local bCallback = opts.Callback or function() end

            local hasDesc = bDesc ~= nil and bDesc ~= ""
            local btnHeight = hasDesc and 52 or 36

            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Name = "Button"
            ButtonFrame.BackgroundColor3 = Theme.Element
            ButtonFrame.Size = UDim2.new(1, 0, 0, btnHeight)
            ButtonFrame.Text = ""
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.ZIndex = 5
            ButtonFrame.Parent = TabPage
            AddCorner(ButtonFrame, 7)
            AddStroke(ButtonFrame, Theme.ElementBorder, 1, 0.7)

            local BTitle = Instance.new("TextLabel")
            BTitle.BackgroundTransparency = 1
            BTitle.Position = UDim2.new(0, 12, 0, hasDesc and 6 or 0)
            BTitle.Size = UDim2.new(1, -50, 0, hasDesc and 20 or btnHeight)
            BTitle.Font = Enum.Font.GothamMedium
            BTitle.Text = bTitle
            BTitle.TextColor3 = Theme.TextPrimary
            BTitle.TextSize = 13
            BTitle.TextXAlignment = Enum.TextXAlignment.Left
            BTitle.ZIndex = 6
            BTitle.Parent = ButtonFrame

            if hasDesc then
                local BDesc = Instance.new("TextLabel")
                BDesc.BackgroundTransparency = 1
                BDesc.Position = UDim2.new(0, 12, 0, 26)
                BDesc.Size = UDim2.new(1, -50, 0, 18)
                BDesc.Font = Enum.Font.Gotham
                BDesc.Text = bDesc
                BDesc.TextColor3 = Theme.TextDimmed
                BDesc.TextSize = 11
                BDesc.TextXAlignment = Enum.TextXAlignment.Left
                BDesc.ZIndex = 6
                BDesc.Parent = ButtonFrame
            end

            -- Arrow icon (text-based)
            local Arrow = Instance.new("TextLabel")
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "›"
            Arrow.TextColor3 = Theme.TextDimmed
            Arrow.TextSize = 20
            Arrow.ZIndex = 6
            Arrow.Parent = ButtonFrame

            -- Hover
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                Tween(Arrow, {TextColor3 = Theme.Accent}, 0.15)
            end)
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Element}, 0.15)
                Tween(Arrow, {TextColor3 = Theme.TextDimmed}, 0.15)
            end)

            CreateRipple(ButtonFrame, Theme)

            ButtonFrame.MouseButton1Click:Connect(function()
                -- Flash effect
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                task.delay(0.15, function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                end)
                pcall(bCallback)
            end)

            return ButtonFrame
        end

        -- ════════════════════════════════════════
        -- TOGGLE
        -- ════════════════════════════════════════
        function Tab:AddToggle(opts)
            opts = opts or {}
            local tTitle = opts.Title or "Toggle"
            local tDesc = opts.Description or nil
            local tDefault = opts.Default or false
            local tCallback = opts.Callback or function() end
            local tFlag = opts.Flag or nil

            local hasDesc = tDesc ~= nil and tDesc ~= ""
            local toggleHeight = hasDesc and 52 or 36
            local toggled = tDefault

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Name = "Toggle"
            ToggleFrame.BackgroundColor3 = Theme.Element
            ToggleFrame.Size = UDim2.new(1, 0, 0, toggleHeight)
            ToggleFrame.Text = ""
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.ZIndex = 5
            ToggleFrame.Parent = TabPage
            AddCorner(ToggleFrame, 7)
            AddStroke(ToggleFrame, Theme.ElementBorder, 1, 0.7)

            local TTitle = Instance.new("TextLabel")
            TTitle.BackgroundTransparency = 1
            TTitle.Position = UDim2.new(0, 12, 0, hasDesc and 6 or 0)
            TTitle.Size = UDim2.new(1, -70, 0, hasDesc and 20 or toggleHeight)
            TTitle.Font = Enum.Font.GothamMedium
            TTitle.Text = tTitle
            TTitle.TextColor3 = Theme.TextPrimary
            TTitle.TextSize = 13
            TTitle.TextXAlignment = Enum.TextXAlignment.Left
            TTitle.ZIndex = 6
            TTitle.Parent = ToggleFrame

            if hasDesc then
                local TDesc = Instance.new("TextLabel")
                TDesc.BackgroundTransparency = 1
                TDesc.Position = UDim2.new(0, 12, 0, 26)
                TDesc.Size = UDim2.new(1, -70, 0, 18)
                TDesc.Font = Enum.Font.Gotham
                TDesc.Text = tDesc
                TDesc.TextColor3 = Theme.TextDimmed
                TDesc.TextSize = 11
                TDesc.TextXAlignment = Enum.TextXAlignment.Left
                TDesc.ZIndex = 6
                TDesc.Parent = ToggleFrame
            end

            -- Toggle switch background
            local SwitchBack = Instance.new("Frame")
            SwitchBack.Name = "SwitchBack"
            SwitchBack.BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff
            SwitchBack.Size = UDim2.new(0, 40, 0, 22)
            SwitchBack.Position = UDim2.new(1, -52, 0.5, 0)
            SwitchBack.AnchorPoint = Vector2.new(0, 0.5)
            SwitchBack.BorderSizePixel = 0
            SwitchBack.ZIndex = 6
            SwitchBack.Parent = ToggleFrame
            AddCorner(SwitchBack, 11)

            -- Toggle circle
            local SwitchCircle = Instance.new("Frame")
            SwitchCircle.Name = "Circle"
            SwitchCircle.BackgroundColor3 = Theme.ToggleCircle
            SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
            SwitchCircle.Position = toggled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            SwitchCircle.AnchorPoint = Vector2.new(0, 0.5)
            SwitchCircle.BorderSizePixel = 0
            SwitchCircle.ZIndex = 7
            SwitchCircle.Parent = SwitchBack
            AddCorner(SwitchCircle, 99)

            local function UpdateToggle()
                if toggled then
                    Tween(SwitchBack, {BackgroundColor3 = Theme.ToggleOn}, 0.2)
                    Tween(SwitchCircle, {Position = UDim2.new(1, -19, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
                else
                    Tween(SwitchBack, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
                    Tween(SwitchCircle, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
                end
            end

            ToggleFrame.MouseEnter:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            ToggleFrame.MouseLeave:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.Element}, 0.15)
            end)

            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                UpdateToggle()
                pcall(tCallback, toggled)
            end)

            -- Fire default
            if tDefault then
                pcall(tCallback, tDefault)
            end

            local ToggleObj = {}
            function ToggleObj:Set(value)
                toggled = value
                UpdateToggle()
                pcall(tCallback, toggled)
            end
            function ToggleObj:Get()
                return toggled
            end
            return ToggleObj
        end

        -- ════════════════════════════════════════
        -- SLIDER
        -- ════════════════════════════════════════
        function Tab:AddSlider(opts)
            opts = opts or {}
            local sTitle = opts.Title or "Slider"
            local sMin = opts.Min or 0
            local sMax = opts.Max or 100
            local sDefault = opts.Default or sMin
            local sIncrement = opts.Increment or 1
            local sSuffix = opts.Suffix or ""
            local sCallback = opts.Callback or function() end

            local currentValue = sDefault

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "Slider"
            SliderFrame.BackgroundColor3 = Theme.Element
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.ZIndex = 5
            SliderFrame.Parent = TabPage
            AddCorner(SliderFrame, 7)
            AddStroke(SliderFrame, Theme.ElementBorder, 1, 0.7)

            local STitle = Instance.new("TextLabel")
            STitle.BackgroundTransparency = 1
            STitle.Position = UDim2.new(0, 12, 0, 6)
            STitle.Size = UDim2.new(0.5, -12, 0, 18)
            STitle.Font = Enum.Font.GothamMedium
            STitle.Text = sTitle
            STitle.TextColor3 = Theme.TextPrimary
            STitle.TextSize = 13
            STitle.TextXAlignment = Enum.TextXAlignment.Left
            STitle.ZIndex = 6
            STitle.Parent = SliderFrame

            local SValue = Instance.new("TextLabel")
            SValue.BackgroundTransparency = 1
            SValue.Position = UDim2.new(0.5, 0, 0, 6)
            SValue.Size = UDim2.new(0.5, -12, 0, 18)
            SValue.Font = Enum.Font.GothamMedium
            SValue.Text = tostring(currentValue) .. sSuffix
            SValue.TextColor3 = Theme.Accent
            SValue.TextSize = 13
            SValue.TextXAlignment = Enum.TextXAlignment.Right
            SValue.ZIndex = 6
            SValue.Parent = SliderFrame

            -- Slider bar
            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "Bar"
            SliderBar.BackgroundColor3 = Theme.SliderBack
            SliderBar.Size = UDim2.new(1, -24, 0, 6)
            SliderBar.Position = UDim2.new(0, 12, 0, 34)
            SliderBar.BorderSizePixel = 0
            SliderBar.ZIndex = 6
            SliderBar.Parent = SliderFrame
            AddCorner(SliderBar, 3)

            local fillPercent = (sDefault - sMin) / (sMax - sMin)

            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.BackgroundColor3 = Theme.SliderFill
            SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
            SliderFill.BorderSizePixel = 0
            SliderFill.ZIndex = 7
            SliderFill.Parent = SliderBar
            AddCorner(SliderFill, 3)

            -- Slider knob
            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.BackgroundColor3 = Theme.ToggleCircle
            SliderKnob.Size = UDim2.new(0, 14, 0, 14)
            SliderKnob.Position = UDim2.new(fillPercent, 0, 0.5, 0)
            SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderKnob.BorderSizePixel = 0
            SliderKnob.ZIndex = 8
            SliderKnob.Parent = SliderBar
            AddCorner(SliderKnob, 99)

            -- Shadow on knob
            local KnobStroke = AddStroke(SliderKnob, Theme.Accent, 2, 0.3)

            local sliding = false

            local function UpdateSlider(input)
                local barAbsPos = SliderBar.AbsolutePosition.X
                local barAbsSize = SliderBar.AbsoluteSize.X
                local mouseX = input.Position.X
                local percent = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)

                local rawValue = sMin + (sMax - sMin) * percent
                local steps = math.floor((rawValue - sMin) / sIncrement + 0.5)
                currentValue = math.clamp(sMin + steps * sIncrement, sMin, sMax)

                -- Round
                if sIncrement >= 1 then
                    currentValue = math.floor(currentValue)
                else
                    local decimals = #tostring(sIncrement):match("%.(%d+)") or 0
                    currentValue = tonumber(string.format("%." .. decimals .. "f", currentValue))
                end

                local newPercent = (currentValue - sMin) / (sMax - sMin)
                Tween(SliderFill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.08, Enum.EasingStyle.Sine)
                Tween(SliderKnob, {Position = UDim2.new(newPercent, 0, 0.5, 0)}, 0.08, Enum.EasingStyle.Sine)
                SValue.Text = tostring(currentValue) .. sSuffix
                pcall(sCallback, currentValue)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateSlider(input)
                end
            end)

            SliderKnob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            -- Fire default
            pcall(sCallback, sDefault)

            local SliderObj = {}
            function SliderObj:Set(value)
                currentValue = math.clamp(value, sMin, sMax)
                local newPercent = (currentValue - sMin) / (sMax - sMin)
                Tween(SliderFill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.15)
                Tween(SliderKnob, {Position = UDim2.new(newPercent, 0, 0.5, 0)}, 0.15)
                SValue.Text = tostring(currentValue) .. sSuffix
                pcall(sCallback, currentValue)
            end
            function SliderObj:Get()
                return currentValue
            end
            return SliderObj
        end

        -- ════════════════════════════════════════
        -- DROPDOWN
        -- ════════════════════════════════════════
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local dTitle = opts.Title or "Dropdown"
            local dOptions = opts.Options or {}
            local dDefault = opts.Default or nil
            local dMulti = opts.Multi or false
            local dCallback = opts.Callback or function() end

            local opened = false
            local selectedValue = dMulti and {} or dDefault
            local optionButtons = {}

            if dMulti and dDefault then
                if typeof(dDefault) == "table" then
                    selectedValue = dDefault
                else
                    selectedValue = {dDefault}
                end
            end

            local closedHeight = 40
            local optionHeight = 30
            local maxVisible = math.min(#dOptions, 6)

            local DropFrame = Instance.new("Frame")
            DropFrame.Name = "Dropdown"
            DropFrame.BackgroundColor3 = Theme.Element
            DropFrame.Size = UDim2.new(1, 0, 0, closedHeight)
            DropFrame.BorderSizePixel = 0
            DropFrame.ZIndex = 5
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage
            AddCorner(DropFrame, 7)
            AddStroke(DropFrame, Theme.ElementBorder, 1, 0.7)

            local DTitle = Instance.new("TextLabel")
            DTitle.BackgroundTransparency = 1
            DTitle.Position = UDim2.new(0, 12, 0, 0)
            DTitle.Size = UDim2.new(0.5, -12, 0, closedHeight)
            DTitle.Font = Enum.Font.GothamMedium
            DTitle.Text = dTitle
            DTitle.TextColor3 = Theme.TextPrimary
            DTitle.TextSize = 13
            DTitle.TextXAlignment = Enum.TextXAlignment.Left
            DTitle.ZIndex = 6
            DTitle.Parent = DropFrame

            -- Selected label
            local function GetDisplayText()
                if dMulti then
                    if #selectedValue == 0 then return "None" end
                    return table.concat(selectedValue, ", ")
                else
                    return selectedValue or "Select..."
                end
            end

            local DSelected = Instance.new("TextLabel")
            DSelected.BackgroundTransparency = 1
            DSelected.Position = UDim2.new(0.35, 0, 0, 0)
            DSelected.Size = UDim2.new(0.65, -40, 0, closedHeight)
            DSelected.Font = Enum.Font.Gotham
            DSelected.Text = GetDisplayText()
            DSelected.TextColor3 = Theme.TextSecondary
            DSelected.TextSize = 12
            DSelected.TextXAlignment = Enum.TextXAlignment.Right
            DSelected.TextTruncate = Enum.TextTruncate.AtEnd
            DSelected.ZIndex = 6
            DSelected.Parent = DropFrame

            -- Arrow
            local DArrow = Instance.new("TextLabel")
            DArrow.BackgroundTransparency = 1
            DArrow.Position = UDim2.new(1, -28, 0, 0)
            DArrow.Size = UDim2.new(0, 20, 0, closedHeight)
            DArrow.Font = Enum.Font.GothamBold
            DArrow.Text = "▾"
            DArrow.TextColor3 = Theme.TextDimmed
            DArrow.TextSize = 14
            DArrow.ZIndex = 6
            DArrow.Rotation = 0
            DArrow.Parent = DropFrame

            -- Option list container
            local OptionContainer = Instance.new("ScrollingFrame")
            OptionContainer.Name = "Options"
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.Position = UDim2.new(0, 8, 0, closedHeight + 2)
            OptionContainer.Size = UDim2.new(1, -16, 0, maxVisible * (optionHeight + 3))
            OptionContainer.BorderSizePixel = 0
            OptionContainer.ScrollBarThickness = 2
            OptionContainer.ScrollBarImageColor3 = Theme.Accent
            OptionContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
            OptionContainer.ZIndex = 7
            OptionContainer.Parent = DropFrame
            local optLayout = AddListLayout(OptionContainer, 3)
            optLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                OptionContainer.CanvasSize = UDim2.new(0, 0, 0, optLayout.AbsoluteContentSize.Y + 4)
            end)

            -- Toggle dropdown button
            local DropBtn = Instance.new("TextButton")
            DropBtn.BackgroundTransparency = 1
            DropBtn.Size = UDim2.new(1, 0, 0, closedHeight)
            DropBtn.Text = ""
            DropBtn.ZIndex = 8
            DropBtn.Parent = DropFrame

            local function UpdateOptions()
                for _, opt in pairs(optionButtons) do
                    local isSelected = false
                    if dMulti then
                        isSelected = table.find(selectedValue, opt.Value) ~= nil
                    else
                        isSelected = selectedValue == opt.Value
                    end
                    if isSelected then
                        Tween(opt.Button, {BackgroundColor3 = Theme.Accent}, 0.15)
                        opt.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        Tween(opt.Button, {BackgroundColor3 = Theme.DropdownOption}, 0.15)
                        opt.Label.TextColor3 = Theme.TextSecondary
                    end
                end
                DSelected.Text = GetDisplayText()
            end

            local function BuildOptions()
                for _, child in pairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                optionButtons = {}

                for i, optName in ipairs(dOptions) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Name = "Opt_" .. optName
                    OptBtn.BackgroundColor3 = Theme.DropdownOption
                    OptBtn.Size = UDim2.new(1, 0, 0, optionHeight)
                    OptBtn.Text = ""
                    OptBtn.BorderSizePixel = 0
                    OptBtn.AutoButtonColor = false
                    OptBtn.ZIndex = 8
                    OptBtn.LayoutOrder = i
                    OptBtn.Parent = OptionContainer
                    AddCorner(OptBtn, 5)

                    local OptLabel = Instance.new("TextLabel")
                    OptLabel.BackgroundTransparency = 1
                    OptLabel.Size = UDim2.new(1, -16, 1, 0)
                    OptLabel.Position = UDim2.new(0, 8, 0, 0)
                    OptLabel.Font = Enum.Font.Gotham
                    OptLabel.Text = optName
                    OptLabel.TextColor3 = Theme.TextSecondary
                    OptLabel.TextSize = 12
                    OptLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptLabel.ZIndex = 9
                    OptLabel.Parent = OptBtn

                    -- Hover
                    OptBtn.MouseEnter:Connect(function()
                        local isSelected = false
                        if dMulti then
                            isSelected = table.find(selectedValue, optName) ~= nil
                        else
                            isSelected = selectedValue == optName
                        end
                        if not isSelected then
                            Tween(OptBtn, {BackgroundColor3 = Theme.DropdownOptionHover}, 0.1)
                        end
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        local isSelected = false
                        if dMulti then
                            isSelected = table.find(selectedValue, optName) ~= nil
                        else
                            isSelected = selectedValue == optName
                        end
                        if not isSelected then
                            Tween(OptBtn, {BackgroundColor3 = Theme.DropdownOption}, 0.1)
                        end
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        if dMulti then
                            local idx = table.find(selectedValue, optName)
                            if idx then
                                table.remove(selectedValue, idx)
                            else
                                table.insert(selectedValue, optName)
                            end
                            UpdateOptions()
                            pcall(dCallback, selectedValue)
                        else
                            selectedValue = optName
                            UpdateOptions()
                            pcall(dCallback, selectedValue)
                            -- Auto close
                            opened = false
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                            Tween(DArrow, {Rotation = 0}, 0.25)
                        end
                    end)

                    table.insert(optionButtons, {Button = OptBtn, Label = OptLabel, Value = optName})
                end

                maxVisible = math.min(#dOptions, 6)
                OptionContainer.Size = UDim2.new(1, -16, 0, maxVisible * (optionHeight + 3))
                UpdateOptions()
            end

            BuildOptions()

            DropBtn.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    local openHeight = closedHeight + 6 + maxVisible * (optionHeight + 3)
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, openHeight)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    Tween(DArrow, {Rotation = 180}, 0.3)
                else
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    Tween(DArrow, {Rotation = 0}, 0.25)
                end
            end)

            -- Fire default
            if dDefault then
                pcall(dCallback, dMulti and selectedValue or dDefault)
            end

            local DropObj = {}
            function DropObj:Set(value)
                selectedValue = value
                UpdateOptions()
                pcall(dCallback, selectedValue)
            end
            function DropObj:SetOptions(newOptions)
                dOptions = newOptions
                BuildOptions()
            end
            function DropObj:Get()
                return selectedValue
            end
            return DropObj
        end

        -- ════════════════════════════════════════
        -- INPUT / TEXTBOX
        -- ════════════════════════════════════════
        function Tab:AddInput(opts)
            opts = opts or {}
            local iTitle = opts.Title or "Input"
            local iPlaceholder = opts.Placeholder or "Type here..."
            local iDefault = opts.Default or ""
            local iNumOnly = opts.NumbersOnly or false
            local iCallback = opts.Callback or function() end

            local InputFrame = Instance.new("Frame")
            InputFrame.Name = "Input"
            InputFrame.BackgroundColor3 = Theme.Element
            InputFrame.Size = UDim2.new(1, 0, 0, 40)
            InputFrame.BorderSizePixel = 0
            InputFrame.ZIndex = 5
            InputFrame.Parent = TabPage
            AddCorner(InputFrame, 7)
            AddStroke(InputFrame, Theme.ElementBorder, 1, 0.7)

            local ITitle = Instance.new("TextLabel")
            ITitle.BackgroundTransparency = 1
            ITitle.Position = UDim2.new(0, 12, 0, 0)
            ITitle.Size = UDim2.new(0.45, -12, 1, 0)
            ITitle.Font = Enum.Font.GothamMedium
            ITitle.Text = iTitle
            ITitle.TextColor3 = Theme.TextPrimary
            ITitle.TextSize = 13
            ITitle.TextXAlignment = Enum.TextXAlignment.Left
            ITitle.ZIndex = 6
            ITitle.Parent = InputFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Name = "Box"
            InputBox.BackgroundColor3 = Theme.InputBackground
            InputBox.Position = UDim2.new(0.45, 4, 0, 6)
            InputBox.Size = UDim2.new(0.55, -16, 1, -12)
            InputBox.Font = Enum.Font.Gotham
            InputBox.Text = iDefault
            InputBox.PlaceholderText = iPlaceholder
            InputBox.PlaceholderColor3 = Theme.TextDimmed
            InputBox.TextColor3 = Theme.TextPrimary
            InputBox.TextSize = 12
            InputBox.ClearTextOnFocus = false
            InputBox.BorderSizePixel = 0
            InputBox.ZIndex = 7
            InputBox.Parent = InputFrame
            AddCorner(InputBox, 5)
            local inputStroke = AddStroke(InputBox, Theme.ElementBorder, 1, 0.6)

            InputBox.Focused:Connect(function()
                Tween(inputStroke, {Color = Theme.Accent, Transparency = 0.2}, 0.2)
            end)

            InputBox.FocusLost:Connect(function(enterPressed)
                Tween(inputStroke, {Color = Theme.ElementBorder, Transparency = 0.6}, 0.2)
                if iNumOnly then
                    InputBox.Text = InputBox.Text:gsub("[^%d%.%-]", "")
                end
                pcall(iCallback, InputBox.Text)
            end)

            local InputObj = {}
            function InputObj:Set(value)
                InputBox.Text = tostring(value)
            end
            function InputObj:Get()
                return InputBox.Text
            end
            return InputObj
        end

        -- ════════════════════════════════════════
        -- KEYBIND
        -- ════════════════════════════════════════
        function Tab:AddKeybind(opts)
            opts = opts or {}
            local kTitle = opts.Title or "Keybind"
            local kDefault = opts.Default or Enum.KeyCode.Unknown
            local kCallback = opts.Callback or function() end
            local kChangedCallback = opts.ChangedCallback or function() end

            local currentKey = kDefault
            local listening = false

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = "Keybind"
            KeybindFrame.BackgroundColor3 = Theme.Element
            KeybindFrame.Size = UDim2.new(1, 0, 0, 40)
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.ZIndex = 5
            KeybindFrame.Parent = TabPage
            AddCorner(KeybindFrame, 7)
            AddStroke(KeybindFrame, Theme.ElementBorder, 1, 0.7)

            local KTitle = Instance.new("TextLabel")
            KTitle.BackgroundTransparency = 1
            KTitle.Position = UDim2.new(0, 12, 0, 0)
            KTitle.Size = UDim2.new(0.6, -12, 1, 0)
            KTitle.Font = Enum.Font.GothamMedium
            KTitle.Text = kTitle
            KTitle.TextColor3 = Theme.TextPrimary
            KTitle.TextSize = 13
            KTitle.TextXAlignment = Enum.TextXAlignment.Left
            KTitle.ZIndex = 6
            KTitle.Parent = KeybindFrame

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Name = "KeyButton"
            KeyBtn.BackgroundColor3 = Theme.InputBackground
            KeyBtn.Position = UDim2.new(1, -90, 0.5, 0)
            KeyBtn.AnchorPoint = Vector2.new(0, 0.5)
            KeyBtn.Size = UDim2.new(0, 78, 0, 26)
            KeyBtn.Font = Enum.Font.GothamMedium
            KeyBtn.Text = currentKey.Name or "None"
            KeyBtn.TextColor3 = Theme.TextSecondary
            KeyBtn.TextSize = 12
            KeyBtn.BorderSizePixel = 0
            KeyBtn.AutoButtonColor = false
            KeyBtn.ZIndex = 7
            KeyBtn.Parent = KeybindFrame
            AddCorner(KeyBtn, 5)
            local kStroke = AddStroke(KeyBtn, Theme.ElementBorder, 1, 0.5)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                Tween(kStroke, {Color = Theme.Accent, Transparency = 0.2}, 0.2)
                Tween(KeyBtn, {TextColor3 = Theme.Accent}, 0.2)
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        KeyBtn.Text = currentKey.Name
                        listening = false
                        Tween(kStroke, {Color = Theme.ElementBorder, Transparency = 0.5}, 0.2)
                        Tween(KeyBtn, {TextColor3 = Theme.TextSecondary}, 0.2)
                        pcall(kChangedCallback, currentKey)
                    end
                else
                    if input.KeyCode == currentKey then
                        pcall(kCallback)
                    end
                end
            end)

            local KeybindObj = {}
            function KeybindObj:Set(key)
                currentKey = key
                KeyBtn.Text = key.Name
                pcall(kChangedCallback, currentKey)
            end
            function KeybindObj:Get()
                return currentKey
            end
            return KeybindObj
        end

        -- ════════════════════════════════════════
        -- COLOR PICKER
        -- ════════════════════════════════════════
        function Tab:AddColorPicker(opts)
            opts = opts or {}
            local cpTitle = opts.Title or "Color Picker"
            local cpDefault = opts.Default or Color3.fromRGB(255, 255, 255)
            local cpCallback = opts.Callback or function() end

            local currentColor = cpDefault
            local pickerOpen = false
            local h, s, v = Color3.toHSV(cpDefault)

            local CPFrame = Instance.new("Frame")
            CPFrame.Name = "ColorPicker"
            CPFrame.BackgroundColor3 = Theme.Element
            CPFrame.Size = UDim2.new(1, 0, 0, 40)
            CPFrame.BorderSizePixel = 0
            CPFrame.ZIndex = 5
            CPFrame.ClipsDescendants = true
            CPFrame.Parent = TabPage
            AddCorner(CPFrame, 7)
            AddStroke(CPFrame, Theme.ElementBorder, 1, 0.7)

            local CPTitle = Instance.new("TextLabel")
            CPTitle.BackgroundTransparency = 1
            CPTitle.Position = UDim2.new(0, 12, 0, 0)
            CPTitle.Size = UDim2.new(0.6, -12, 0, 40)
            CPTitle.Font = Enum.Font.GothamMedium
            CPTitle.Text = cpTitle
            CPTitle.TextColor3 = Theme.TextPrimary
            CPTitle.TextSize = 13
            CPTitle.TextXAlignment = Enum.TextXAlignment.Left
            CPTitle.ZIndex = 6
            CPTitle.Parent = CPFrame

            -- Color preview
            local ColorPreview = Instance.new("TextButton")
            ColorPreview.BackgroundColor3 = cpDefault
            ColorPreview.Position = UDim2.new(1, -50, 0, 10)
            ColorPreview.Size = UDim2.new(0, 38, 0, 20)
            ColorPreview.Text = ""
            ColorPreview.BorderSizePixel = 0
            ColorPreview.AutoButtonColor = false
            ColorPreview.ZIndex = 7
            ColorPreview.Parent = CPFrame
            AddCorner(ColorPreview, 5)
            AddStroke(ColorPreview, Theme.ElementBorder, 1, 0.5)

            -- Color picker canvas
            local PickerCanvas = Instance.new("ImageLabel")
            PickerCanvas.Name = "Canvas"
            PickerCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            PickerCanvas.Position = UDim2.new(0, 12, 0, 48)
            PickerCanvas.Size = UDim2.new(1, -70, 0, 120)
            PickerCanvas.BorderSizePixel = 0
            PickerCanvas.ZIndex = 7
            PickerCanvas.Image = "rbxassetid://4155801252"
            PickerCanvas.Parent = CPFrame
            AddCorner(PickerCanvas, 5)

            -- Hue bar
            local HueBar = Instance.new("ImageLabel")
            HueBar.Name = "HueBar"
            HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueBar.Position = UDim2.new(1, -46, 0, 48)
            HueBar.Size = UDim2.new(0, 22, 0, 120)
            HueBar.BorderSizePixel = 0
            HueBar.ZIndex = 7
            HueBar.Image = "rbxassetid://3641079629"
            HueBar.Parent = CPFrame
            AddCorner(HueBar, 5)

            -- Selector circle on canvas
            local CanvasSelector = Instance.new("Frame")
            CanvasSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            CanvasSelector.Size = UDim2.new(0, 12, 0, 12)
            CanvasSelector.Position = UDim2.new(s, 0, 1 - v, 0)
            CanvasSelector.AnchorPoint = Vector2.new(0.5, 0.5)
            CanvasSelector.BorderSizePixel = 0
            CanvasSelector.ZIndex = 9
            CanvasSelector.Parent = PickerCanvas
            AddCorner(CanvasSelector, 99)
            AddStroke(CanvasSelector, Color3.fromRGB(40, 40, 40), 2, 0)

            -- Hue selector
            local HueSelector = Instance.new("Frame")
            HueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueSelector.Size = UDim2.new(1, 4, 0, 4)
            HueSelector.Position = UDim2.new(-0.1, 0, h, 0)
            HueSelector.AnchorPoint = Vector2.new(0, 0.5)
            HueSelector.BorderSizePixel = 0
            HueSelector.ZIndex = 9
            HueSelector.Parent = HueBar
            AddCorner(HueSelector, 2)

            local function UpdateColor()
                currentColor = Color3.fromHSV(h, s, v)
                ColorPreview.BackgroundColor3 = currentColor
                PickerCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                pcall(cpCallback, currentColor)
            end

            -- Canvas input
            local canvasDragging = false
            PickerCanvas.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    canvasDragging = true
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if canvasDragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
                    local relX = math.clamp((input.Position.X - PickerCanvas.AbsolutePosition.X) / PickerCanvas.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((input.Position.Y - PickerCanvas.AbsolutePosition.Y) / PickerCanvas.AbsoluteSize.Y, 0, 1)
                    s = relX
                    v = 1 - relY
                    CanvasSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                    UpdateColor()
                end
            end)

            -- Hue input
            local hueDragging = false
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDragging = true
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
                    local relY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                    h = relY
                    HueSelector.Position = UDim2.new(-0.1, 0, h, 0)
                    UpdateColor()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    canvasDragging = false
                    hueDragging = false
                end
            end)

            ColorPreview.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 180)}, 0.3, Enum.EasingStyle.Back)
                else
                    Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.25)
                end
            end)

            local CPObj = {}
            function CPObj:Set(color)
                currentColor = color
                h, s, v = Color3.toHSV(color)
                ColorPreview.BackgroundColor3 = color
                PickerCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                CanvasSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                HueSelector.Position = UDim2.new(-0.1, 0, h, 0)
                pcall(cpCallback, color)
            end
            function CPObj:Get()
                return currentColor
            end
            return CPObj
        end

        return Tab
    end

    -- Return Window object
    return Window
end

return NexusLib