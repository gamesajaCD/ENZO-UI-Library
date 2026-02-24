--[[
    ENZO UI LIBRARY - Design E: Ultra Modern
    Version: 1.0.0
    Author: ENZO-YT
    
    Style: Glassmorphism + Neon + Modern Dark
]]

local EnzoLib = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Cleanup
if getgenv().EnzoUILib then
    pcall(function() getgenv().EnzoUILib:Destroy() end)
end
pcall(function()
    local b = Lighting:FindFirstChild("EnzoBlur")
    if b then b:Destroy() end
end)

-- Utilities
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Tween(obj, props, dur, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function AddCorner(p, r)
    return Create("UICorner", {CornerRadius = UDim.new(0, r or 10), Parent = p})
end

local function AddPadding(p, t, b, l, r)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft = UDim.new(0, l or t or 0),
        PaddingRight = UDim.new(0, r or l or t or 0),
        Parent = p
    })
end

local function AddStroke(p, col, thick, trans)
    return Create("UIStroke", {
        Color = col or Color3.fromRGB(255, 255, 255),
        Thickness = thick or 1,
        Transparency = trans or 0.9,
        Parent = p
    })
end

local function AddGradient(p, c1, c2, rot)
    return Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2)
        }),
        Rotation = rot or 45,
        Parent = p
    })
end

local function MakeDraggable(frame, handle)
    local drag, start, startPos
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            start = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - start
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Theme - Ultra Modern Dark + Neon
local Theme = {
    -- Backgrounds
    BgPrimary = Color3.fromRGB(10, 10, 15),
    BgSecondary = Color3.fromRGB(15, 15, 22),
    BgTertiary = Color3.fromRGB(20, 20, 30),
    
    -- Glass
    Glass = Color3.fromRGB(30, 30, 45),
    GlassBorder = Color3.fromRGB(60, 60, 80),
    
    -- Accent (Neon Purple/Blue)
    Accent = Color3.fromRGB(130, 80, 255),
    AccentAlt = Color3.fromRGB(80, 200, 255),
    AccentGlow = Color3.fromRGB(150, 100, 255),
    
    -- Neon Colors
    Neon1 = Color3.fromRGB(255, 100, 200),
    Neon2 = Color3.fromRGB(100, 255, 200),
    Neon3 = Color3.fromRGB(255, 200, 100),
    
    -- Status
    Success = Color3.fromRGB(80, 250, 150),
    Error = Color3.fromRGB(255, 80, 100),
    Warning = Color3.fromRGB(255, 200, 80),
    Info = Color3.fromRGB(80, 180, 255),
    
    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 140),
    TextDark = Color3.fromRGB(80, 80, 100),
}

-- Main Function
function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "Ultra Modern"
    local size = config.Size or UDim2.new(0, 700, 0, 480)
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    }
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "EnzoUI_E_" .. math.random(100000, 999999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    -- Blur
    local Blur = Create("BlurEffect", {
        Name = "EnzoBlur",
        Size = config.Blur ~= false and 12 or 0,
        Parent = Lighting
    })
    
    -- Main Container
    local Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Theme.BgPrimary,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        Parent = ScreenGui
    })
    AddCorner(Main, 16)
    
    -- Outer Glow Effect
    local Glow = Create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -30, 0, -30),
        Size = UDim2.new(1, 60, 1, 60),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = Main
    })
    
    -- Glass Overlay
    local GlassOverlay = Create("Frame", {
        Name = "Glass",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.97,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = Main
    })
    AddCorner(GlassOverlay, 16)
    AddGradient(GlassOverlay, Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 200), 135)
    
    -- Border Glow
    local BorderGlow = AddStroke(Main, Theme.Accent, 1.5, 0.5)
    
    -- ============================================
    -- HEADER
    -- ============================================
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.BgSecondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = Main
    })
    AddCorner(Header, 16)
    
    -- Fix bottom corners
    Create("Frame", {
        BackgroundColor3 = Theme.BgSecondary,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = Header
    })
    
    -- Logo Container with Glow
    local LogoContainer = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 18, 0.5, -20),
        Size = UDim2.new(0, 40, 0, 40),
        Parent = Header
    })
    AddCorner(LogoContainer, 12)
    AddGradient(LogoContainer, Theme.Accent, Theme.AccentAlt, 135)
    
    -- Logo Glow
    Create("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -25, 0.5, -25),
        Size = UDim2.new(0, 50, 0, 50),
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = LogoContainer
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = "E",
        TextColor3 = Theme.TextPrimary,
        TextSize = 22,
        Parent = LogoContainer
    })
    
    -- Title
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 12),
        Size = UDim2.new(0.5, 0, 0, 20),
        Font = Enum.Font.GothamBlack,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 34),
        Size = UDim2.new(0.5, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Theme.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Window Controls (Modern Pills)
    local Controls = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -130, 0.5, -14),
        Size = UDim2.new(0, 110, 0, 28),
        Parent = Header
    })
    
    local ControlsBG = Create("Frame", {
        BackgroundColor3 = Theme.BgTertiary,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = Controls
    })
    AddCorner(ControlsBG, 14)
    
    local function CreateControl(icon, color, pos, callback)
        local btn = Create("TextButton", {
            BackgroundTransparency = 1,
            Position = pos,
            Size = UDim2.new(0, 28, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = color,
            TextSize = 14,
            Parent = Controls
        })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {TextSize = 16}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {TextSize = 14}, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    CreateControl("−", Theme.Warning, UDim2.new(0, 8, 0, 0), function() Window:Toggle() end)
    CreateControl("□", Theme.Info, UDim2.new(0, 40, 0, 0), function() end)
    CreateControl("×", Theme.Error, UDim2.new(0, 74, 0, 0), function() Window:Destroy() end)
    
    MakeDraggable(Main, Header)
    
    -- ============================================
    -- TAB BAR (Floating Pills)
    -- ============================================
    local TabBar = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 68),
        Size = UDim2.new(1, -36, 0, 42),
        Parent = Main
    })
    
    local TabBarBG = Create("Frame", {
        BackgroundColor3 = Theme.BgSecondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TabBar
    })
    AddCorner(TabBarBG, 12)
    AddStroke(TabBarBG, Theme.GlassBorder, 1, 0.8)
    
    local TabContainer = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = TabBar
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TabContainer
    })
    
    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local ContentArea = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 118),
        Size = UDim2.new(1, -36, 1, -175),
        Parent = Main
    })
    
    -- ============================================
    -- FOOTER
    -- ============================================
    local Footer = Create("Frame", {
        BackgroundColor3 = Theme.BgSecondary,
        BackgroundTransparency = 0.4,
        Position = UDim2.new(0, 18, 1, -50),
        Size = UDim2.new(1, -36, 0, 42),
        Parent = Main
    })
    AddCorner(Footer, 12)
    AddStroke(Footer, Theme.GlassBorder, 1, 0.8)
    
    -- Opacity Control
    local OpacityLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -8),
        Size = UDim2.new(0, 50, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = "Opacity",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local OpacityTrack = Create("Frame", {
        BackgroundColor3 = Theme.BgTertiary,
        Position = UDim2.new(0, 70, 0.5, -4),
        Size = UDim2.new(0, 100, 0, 8),
        Parent = Footer
    })
    AddCorner(OpacityTrack, 4)
    
    local OpacityFill = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = OpacityTrack
    })
    AddCorner(OpacityFill, 4)
    AddGradient(OpacityFill, Theme.Accent, Theme.AccentAlt, 0)
    
    local OpacityKnob = Create("Frame", {
        BackgroundColor3 = Theme.TextPrimary,
        Position = UDim2.new(1, -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        ZIndex = 2,
        Parent = OpacityTrack
    })
    AddCorner(OpacityKnob, 6)
    
    local OpacityValue = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 175, 0.5, -8),
        Size = UDim2.new(0, 35, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "100%",
        TextColor3 = Theme.Accent,
        TextSize = 11,
        Parent = Footer
    })
    
    -- Toggle Key Badge
    local ToggleBadge = Create("Frame", {
        BackgroundColor3 = Theme.BgTertiary,
        Position = UDim2.new(1, -110, 0.5, -12),
        Size = UDim2.new(0, 95, 0, 24),
        Parent = Footer
    })
    AddCorner(ToggleBadge, 6)
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = "🔑 " .. Window.ToggleKey.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Parent = ToggleBadge
    })
    
    -- Toggle Handler
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Window.ToggleKey then
            Window:Toggle()
        end
    end)
    
    -- ============================================
    -- WINDOW METHODS
    -- ============================================
    function Window:Toggle()
        self.Visible = not self.Visible
        if self.Visible then
            Main.Visible = true
            Main.Size = UDim2.new(0, size.X.Offset, 0, 0)
            Tween(Main, {Size = size}, 0.4, Enum.EasingStyle.Back)
            Tween(Blur, {Size = 12}, 0.3)
            Tween(Glow, {ImageTransparency = 0.85}, 0.3)
        else
            Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0)}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            Tween(Glow, {ImageTransparency = 1}, 0.3)
            task.delay(0.3, function()
                if not self.Visible then Main.Visible = false end
            end)
        end
    end
    
    function Window:Destroy()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.35)
        Tween(Blur, {Size = 0}, 0.3)
        task.delay(0.35, function()
            ScreenGui:Destroy()
            Blur:Destroy()
        end)
        getgenv().EnzoUILib = nil
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Content.Visible = false
            Tween(Window.CurrentTab.Button, {BackgroundColor3 = Theme.BgTertiary, BackgroundTransparency = 0.5}, 0.2)
            Tween(Window.CurrentTab.Glow, {ImageTransparency = 1}, 0.2)
            Window.CurrentTab.NameLabel.TextColor3 = Theme.TextMuted
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        Tween(tab.Button, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.2}, 0.2)
        Tween(tab.Glow, {ImageTransparency = 0.7}, 0.2)
        tab.NameLabel.TextColor3 = Theme.TextPrimary
    end
    
    -- ============================================
    -- ADD TAB
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
        
        -- Tab Button (Pill Style)
        local TabButton = Create("TextButton", {
            BackgroundColor3 = Theme.BgTertiary,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(0, 0, 0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            AutoButtonColor = false,
            Parent = TabContainer
        })
        AddCorner(TabButton, 8)
        AddPadding(TabButton, 0, 0, 14, 14)
        
        -- Tab Glow
        local TabGlow = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -8, 0, -8),
            Size = UDim2.new(1, 16, 1, 16),
            Image = "rbxassetid://6015897843",
            ImageColor3 = Theme.Accent,
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            ZIndex = -1,
            Parent = TabButton
        })
        
        local TabLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = TabButton
        })
        
        local TabIconLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextSize = 14,
            LayoutOrder = 1,
            Parent = TabButton
        })
        
        local TabNameLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = tabName,
            TextColor3 = Theme.TextMuted,
            TextSize = 12,
            LayoutOrder = 2,
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 0.3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        AddPadding(TabContent, 8)
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 12),
            Parent = TabContent
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Glow = TabGlow
        Tab.NameLabel = TabNameLabel
        
        -- Hover Effects
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.3}, 0.15)
                Tween(TabNameLabel, {TextColor3 = Theme.TextSecondary}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.15)
                Tween(TabNameLabel, {TextColor3 = Theme.TextMuted}, 0.15)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Window:SelectTab(Tab) end
        
        -- ============================================
        -- ADD SECTION
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
            
            -- Column
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
                Create("UIListLayout", {Padding = UDim.new(0, 12), Parent = column})
            end
            
            -- Section Card (Glass Style)
            local SectionCard = Create("Frame", {
                BackgroundColor3 = Theme.Glass,
                BackgroundTransparency = 0.6,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            AddCorner(SectionCard, 14)
            AddStroke(SectionCard, Theme.GlassBorder, 1, 0.7)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 44),
                Parent = SectionCard
            })
            
            -- Icon with Glow
            local IconContainer = Create("Frame", {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.8,
                Position = UDim2.new(0, 14, 0.5, -14),
                Size = UDim2.new(0, 28, 0, 28),
                Parent = SectionHeader
            })
            AddCorner(IconContainer, 8)
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = Theme.Accent,
                TextSize = 14,
                Parent = IconContainer
            })
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 50, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamBlack,
                Text = sectionName:upper(),
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Divider
            local Divider = Create("Frame", {
                BackgroundColor3 = Theme.GlassBorder,
                BackgroundTransparency = 0.5,
                Position = UDim2.new(0, 14, 0, 44),
                Size = UDim2.new(1, -28, 0, 1),
                Parent = SectionCard
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 50),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionCard
            })
            AddPadding(SectionContent, 6, 14, 12, 12)
            Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = SectionContent})
            
            Section.Card = SectionCard
            Section.Content = SectionContent
            table.insert(Tab.Sections, Section)
            
            -- ============================================
            -- TOGGLE (Neon Switch)
            -- ============================================
            function Section:AddToggle(cfg)
                cfg = cfg or {}
                local Toggle = {Value = cfg.Default or false}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.BgTertiary,
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 54 or 42),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, cfg.Description and 10 or 0),
                    Size = UDim2.new(1, -75, 0, cfg.Description and 18 or 42),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 28),
                        Size = UDim2.new(1, -75, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                -- Neon Switch
                local Switch = Create("Frame", {
                    BackgroundColor3 = Toggle.Value and Theme.Success or Theme.BgPrimary,
                    Position = UDim2.new(1, -58, 0.5, -12),
                    Size = UDim2.new(0, 48, 0, 24),
                    Parent = Frame
                })
                AddCorner(Switch, 12)
                AddStroke(Switch, Toggle.Value and Theme.Success or Theme.GlassBorder, 1.5, Toggle.Value and 0.3 or 0.7)
                
                -- Switch Glow
                local SwitchGlow = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -6, 0, -6),
                    Size = UDim2.new(1, 12, 1, 12),
                    Image = "rbxassetid://6015897843",
                    ImageColor3 = Theme.Success,
                    ImageTransparency = Toggle.Value and 0.7 or 1,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(49, 49, 450, 450),
                    ZIndex = -1,
                    Parent = Switch
                })
                
                local Knob = Create("Frame", {
                    BackgroundColor3 = Theme.TextPrimary,
                    Position = Toggle.Value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20),
                    Parent = Switch
                })
                AddCorner(Knob, 10)
                
                local ClickArea = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Frame
                })
                
                ClickArea.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    local stroke = Switch:FindFirstChildOfClass("UIStroke")
                    
                    if Toggle.Value then
                        Tween(Switch, {BackgroundColor3 = Theme.Success}, 0.25)
                        Tween(Knob, {Position = UDim2.new(1, -22, 0.5, -10)}, 0.25, Enum.EasingStyle.Back)
                        Tween(SwitchGlow, {ImageTransparency = 0.7}, 0.25)
                        if stroke then Tween(stroke, {Color = Theme.Success, Transparency = 0.3}, 0.25) end
                    else
                        Tween(Switch, {BackgroundColor3 = Theme.BgPrimary}, 0.25)
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.25, Enum.EasingStyle.Back)
                        Tween(SwitchGlow, {ImageTransparency = 1}, 0.25)
                        if stroke then Tween(stroke, {Color = Theme.GlassBorder, Transparency = 0.7}, 0.25) end
                    end
                    
                    if cfg.Callback then cfg.Callback(Toggle.Value) end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.1}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) end)
                
                function Toggle:SetValue(v)
                    if Toggle.Value ~= v then
                        Toggle.Value = v
                        local stroke = Switch:FindFirstChildOfClass("UIStroke")
                        if v then
                            Tween(Switch, {BackgroundColor3 = Theme.Success})
                            Tween(Knob, {Position = UDim2.new(1, -22, 0.5, -10)})
                            Tween(SwitchGlow, {ImageTransparency = 0.7})
                            if stroke then Tween(stroke, {Color = Theme.Success, Transparency = 0.3}) end
                        else
                            Tween(Switch, {BackgroundColor3 = Theme.BgPrimary})
                            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -10)})
                            Tween(SwitchGlow, {ImageTransparency = 1})
                            if stroke then Tween(stroke, {Color = Theme.GlassBorder, Transparency = 0.7}) end
                        end
                    end
                end
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- ============================================
            -- SLIDER (Gradient Neon)
            -- ============================================
            function Section:AddSlider(cfg)
                cfg = cfg or {}
                local min, max = cfg.Min or 0, cfg.Max or 100
                local Slider = {Value = cfg.Default or min}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.BgTertiary,
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 62 or 52),
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -70, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                -- Value Badge
                local ValueBadge = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.7,
                    Position = UDim2.new(1, -55, 0, 6),
                    Size = UDim2.new(0, 42, 0, 20),
                    Parent = Frame
                })
                AddCorner(ValueBadge, 6)
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBlack,
                    Text = tostring(Slider.Value) .. (cfg.Suffix or ""),
                    TextColor3 = Theme.Accent,
                    TextSize = 11,
                    Parent = ValueBadge
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 24),
                        Size = UDim2.new(1, -28, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                -- Track
                local Track = Create("Frame", {
                    BackgroundColor3 = Theme.BgPrimary,
                    Position = UDim2.new(0, 14, 1, -18),
                    Size = UDim2.new(1, -28, 0, 8),
                    Parent = Frame
                })
                AddCorner(Track, 4)
                
                local pct = (Slider.Value - min) / (max - min)
                
                local Fill = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(pct, 0, 1, 0),
                    Parent = Track
                })
                AddCorner(Fill, 4)
                AddGradient(Fill, Theme.Accent, Theme.AccentAlt, 0)
                
                -- Fill Glow
                local FillGlow = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.7,
                    Position = UDim2.new(0, 0, 0, -2),
                    Size = UDim2.new(pct, 0, 1, 4),
                    ZIndex = -1,
                    Parent = Track
                })
                AddCorner(FillGlow, 6)
                
                local SliderKnob = Create("Frame", {
                    BackgroundColor3 = Theme.TextPrimary,
                    Position = UDim2.new(pct, -8, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 2,
                    Parent = Track
                })
                AddCorner(SliderKnob, 8)
                AddStroke(SliderKnob, Theme.Accent, 2, 0)
                
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    Slider.Value = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    FillGlow.Size = UDim2.new(pos, 0, 1, 4)
                    SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
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
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.1}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) end)
                
                function Slider:SetValue(v)
                    local pos = (v - min) / (max - min)
                    Slider.Value = v
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    FillGlow.Size = UDim2.new(pos, 0, 1, 4)
                    SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
                    ValueLabel.Text = tostring(v) .. (cfg.Suffix or "")
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ============================================
            -- BUTTON (Neon Glow)
            -- ============================================
            function Section:AddButton(cfg)
                cfg = cfg or {}
                local colors = {
                    Primary = {bg = Theme.Accent, glow = Theme.AccentGlow},
                    Secondary = {bg = Theme.BgTertiary, glow = Theme.GlassBorder},
                    Success = {bg = Theme.Success, glow = Theme.Success},
                    Danger = {bg = Theme.Error, glow = Theme.Error}
                }
                local color = colors[cfg.Style or "Primary"] or colors.Primary
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.BgTertiary,
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 70 or 48),
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
                        TextColor3 = Theme.TextPrimary,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                    
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 26),
                        Size = UDim2.new(1, -28, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = color.bg,
                    Position = cfg.Description and UDim2.new(0, 12, 1, -30) or UDim2.new(0, 12, 0.5, -14),
                    Size = UDim2.new(1, -24, 0, cfg.Description and 24 or 28),
                    Font = Enum.Font.GothamBlack,
                    Text = cfg.Description and "▶ EXECUTE" or (cfg.Title or "Button"),
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(Btn, 8)
                
                if cfg.Style == "Primary" or cfg.Style == nil then
                    AddGradient(Btn, Theme.Accent, Theme.AccentAlt, 90)
                end
                
                -- Button Glow
                local BtnGlow = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -6, 0, -6),
                    Size = UDim2.new(1, 12, 1, 12),
                    Image = "rbxassetid://6015897843",
                    ImageColor3 = color.glow,
                    ImageTransparency = 0.85,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(49, 49, 450, 450),
                    ZIndex = -1,
                    Parent = Btn
                })
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -22, 0, cfg.Description and 26 or 30)}, 0.15)
                    Tween(BtnGlow, {ImageTransparency = 0.7}, 0.15)
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -24, 0, cfg.Description and 24 or 28)}, 0.15)
                    Tween(BtnGlow, {ImageTransparency = 0.85}, 0.15)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    -- Click Effect
                    Tween(Btn, {Size = UDim2.new(1, -28, 0, cfg.Description and 22 or 26)}, 0.08)
                    task.delay(0.08, function()
                        Tween(Btn, {Size = UDim2.new(1, -24, 0, cfg.Description and 24 or 28)}, 0.08)
                    end)
                    if cfg.Callback then cfg.Callback() end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.1}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) end)
                
                return {}
            end
            
            -- ============================================
            -- DROPDOWN (Glass + Neon)
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
                
                local baseH = cfg.Description and 72 or 58
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.BgTertiary,
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, 0, 0, baseH),
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                AddCorner(Frame, 10)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -28, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0, 24),
                        Size = UDim2.new(1, -28, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Theme.Glass,
                    BackgroundTransparency = 0.5,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 42 or 30),
                    Size = UDim2.new(1, -24, 0, 24),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(DropBtn, 6)
                AddStroke(DropBtn, Theme.GlassBorder, 1, 0.6)
                
                local BtnText = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -35, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = multi and "Select..." or (cfg.Default or "Select..."),
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 11,
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
                    TextColor3 = Theme.Accent,
                    TextSize = 10,
                    Parent = DropBtn
                })
                
                -- Dropdown Content
                local Content = Create("Frame", {
                    BackgroundColor3 = Theme.Glass,
                    BackgroundTransparency = 0.4,
                    Position = UDim2.new(0, 12, 0, baseH + 4),
                    Size = UDim2.new(1, -24, 0, 0),
                    ClipsDescendants = true,
                    Parent = Frame
                })
                AddCorner(Content, 8)
                AddStroke(Content, Theme.GlassBorder, 1, 0.6)
                
                -- Search
                local SearchBox = Create("TextBox", {
                    BackgroundColor3 = Theme.BgPrimary,
                    Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.new(1, -12, 0, 26),
                    Font = Enum.Font.GothamMedium,
                    Text = "",
                    PlaceholderText = "🔍 Search...",
                    PlaceholderColor3 = Theme.TextDark,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    Parent = Content
                })
                AddCorner(SearchBox, 6)
                AddPadding(SearchBox, 0, 0, 8, 8)
                
                -- Items
                local ItemsList = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 38),
                    Size = UDim2.new(1, 0, 1, -38),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Content
                })
                AddPadding(ItemsList, 4, 6, 6, 6)
                Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = ItemsList})
                
                local itemBtns = {}
                
                local function createItem(name)
                    local isSel = multi and Dropdown.Value[name] or Dropdown.Value == name
                    
                    local ItemBtn = Create("TextButton", {
                        Name = name,
                        BackgroundColor3 = isSel and Theme.Accent or Theme.BgTertiary,
                        BackgroundTransparency = isSel and 0.6 or 0.3,
                        Size = UDim2.new(1, -8, 0, 28),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = ItemsList
                    })
                    AddCorner(ItemBtn, 6)
                    
                    if multi then
                        local cb = Create("Frame", {
                            BackgroundColor3 = isSel and Theme.Success or Theme.BgPrimary,
                            Position = UDim2.new(0, 8, 0.5, -8),
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
                            TextColor3 = Theme.TextPrimary,
                            TextSize = 11,
                            Parent = cb
                        })
                    end
                    
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, multi and 30 or 10, 0, 0),
                        Size = UDim2.new(1, multi and -38 or -18, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = name,
                        TextColor3 = isSel and Theme.TextPrimary or Theme.TextSecondary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ItemBtn
                    })
                    
                    ItemBtn.MouseEnter:Connect(function()
                        if not (multi and Dropdown.Value[name] or Dropdown.Value == name) then
                            Tween(ItemBtn, {BackgroundTransparency = 0.4, BackgroundColor3 = Theme.Accent}, 0.1)
                        end
                    end)
                    
                    ItemBtn.MouseLeave:Connect(function()
                        local sel = multi and Dropdown.Value[name] or Dropdown.Value == name
                        Tween(ItemBtn, {BackgroundTransparency = sel and 0.6 or 0.3, BackgroundColor3 = sel and Theme.Accent or Theme.BgTertiary}, 0.1)
                    end)
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[name] = not Dropdown.Value[name]
                            local nowSel = Dropdown.Value[name]
                            
                            local cb = ItemBtn:FindFirstChild("Frame")
                            if cb then
                                Tween(cb, {BackgroundColor3 = nowSel and Theme.Success or Theme.BgPrimary}, 0.15)
                                cb:FindFirstChild("Check").Text = nowSel and "✓" or ""
                            end
                            Tween(ItemBtn, {BackgroundColor3 = nowSel and Theme.Accent or Theme.BgTertiary, BackgroundTransparency = nowSel and 0.6 or 0.3}, 0.15)
                            ItemBtn:FindFirstChild("Text").TextColor3 = nowSel and Theme.TextPrimary or Theme.TextSecondary
                            
                            local sel = {}
                            for k, v in pairs(Dropdown.Value) do if v then table.insert(sel, k) end end
                            BtnText.Text = #sel > 0 and table.concat(sel, ", ") or "Select..."
                            BtnText.TextColor3 = #sel > 0 and Theme.TextPrimary or Theme.TextSecondary
                            
                            if cfg.Callback then cfg.Callback(Dropdown.Value) end
                        else
                            Dropdown.Value = name
                            BtnText.Text = name
                            BtnText.TextColor3 = Theme.TextPrimary
                            
                            for n, btn in pairs(itemBtns) do
                                local isThis = n == name
                                Tween(btn, {BackgroundColor3 = isThis and Theme.Accent or Theme.BgTertiary, BackgroundTransparency = isThis and 0.6 or 0.3}, 0.15)
                                btn:FindFirstChild("Text").TextColor3 = isThis and Theme.TextPrimary or Theme.TextSecondary
                            end
                            
                            if cfg.Callback then cfg.Callback(name) end
                            
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
                
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local s = SearchBox.Text:lower()
                    for name, btn in pairs(itemBtns) do
                        btn.Visible = s == "" or name:lower():find(s, 1, true)
                    end
                end)
                
                DropBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    if Dropdown.Open then
                        Tween(Arrow, {Rotation = 180}, 0.2)
                        local cnt = math.min(#items, 5)
                        local contentH = 44 + (cnt * 32) + 8
                        local totalH = baseH + 8 + contentH
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, totalH)}, 0.3, Enum.EasingStyle.Back)
                        Tween(Content, {Size = UDim2.new(1, -24, 0, contentH)}, 0.3, Enum.EasingStyle.Back)
                    else
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                        Tween(Content, {Size = UDim2.new(1, -24, 0, 0)}, 0.25)
                    end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.1}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.3}, 0.15) end)
                
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
                    else
                        Dropdown.Value = v
                        BtnText.Text = v
                        BtnText.TextColor3 = Theme.TextPrimary
                    end
                end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
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
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionContent
                })
                function Label:SetText(t) LabelFrame.Text = t end
                table.insert(Section.Elements, Label)
                return Label
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- ============================================
    -- NOTIFICATION (Neon Style)
    -- ============================================
    function Window:Notify(cfg)
        cfg = cfg or {}
        local types = {
            Info = {col = Theme.Info, icon = "ℹ️"},
            Success = {col = Theme.Success, icon = "✅"},
            Warning = {col = Theme.Warning, icon = "⚠️"},
            Error = {col = Theme.Error, icon = "❌"}
        }
        local data = types[cfg.Type or "Info"] or types.Info
        
        local Container = ScreenGui:FindFirstChild("Notifications")
        if not Container then
            Container = Create("Frame", {
                Name = "Notifications",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -340, 0, 20),
                Size = UDim2.new(0, 320, 0, 0),
                Parent = ScreenGui
            })
            Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = Container})
        end
        
        local Notif = Create("Frame", {
            BackgroundColor3 = Theme.Glass,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Parent = Container
        })
        AddCorner(Notif, 12)
        AddStroke(Notif, data.col, 1.5, 0.4)
        
        -- Glow
        Create("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -10, 0, -10),
            Size = UDim2.new(1, 20, 1, 20),
            Image = "rbxassetid://6015897843",
            ImageColor3 = data.col,
            ImageTransparency = 0.8,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            ZIndex = -1,
            Parent = Notif
        })
        
        -- Accent Line
        Create("Frame", {
            BackgroundColor3 = data.col,
            Size = UDim2.new(0, 4, 1, 0),
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 12),
            Size = UDim2.new(0, 22, 0, 22),
            Font = Enum.Font.GothamBlack,
            Text = data.icon,
            TextSize = 18,
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 46, 0, 12),
            Size = UDim2.new(1, -60, 0, 18),
            Font = Enum.Font.GothamBlack,
            Text = cfg.Title or "Notification",
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif
        })
        
        local ContentLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 46, 0, 32),
            Size = UDim2.new(1, -60, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = cfg.Content or "",
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notif
        })
        
        -- Progress
        local Progress = Create("Frame", {
            BackgroundColor3 = data.col,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            Parent = Notif
        })
        AddCorner(Progress, 2)
        
        task.spawn(function()
            task.wait(0.05)
            local h = 55 + ContentLabel.TextBounds.Y
            Tween(Notif, {Size = UDim2.new(1, 0, 0, h)}, 0.35, Enum.EasingStyle.Back)
            Tween(Progress, {Size = UDim2.new(0, 0, 0, 3)}, cfg.Duration or 5, Enum.EasingStyle.Linear)
            task.wait(cfg.Duration or 5)
            Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.wait(0.3)
            Notif:Destroy()
        end)
    end
    
    getgenv().EnzoUILib = Window
    return Window
end

return EnzoLib