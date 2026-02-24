--[[
    ENZO UI LIBRARY - Design D: Hybrid (B + C)
    Version: 1.0.0
    Author: ENZO-YT
    
    Kombinasi: Sidebar Modern (B) + Card Based (C)
]]

local EnzoLib = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Cleanup
if getgenv().EnzoUILib then
    pcall(function() getgenv().EnzoUILib:Destroy() end)
end
pcall(function()
    local oldBlur = Lighting:FindFirstChild("EnzoUIBlur")
    if oldBlur then oldBlur:Destroy() end
end)

-- Utilities
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function Tween(obj, props, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint), props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    local corner = Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
    return corner
end

local function AddPadding(parent, size)
    local padding = Create("UIPadding", {
        PaddingTop = UDim.new(0, size),
        PaddingBottom = UDim.new(0, size),
        PaddingLeft = UDim.new(0, size),
        PaddingRight = UDim.new(0, size),
        Parent = parent
    })
    return padding
end

local function AddStroke(parent, color, thickness)
    local stroke = Create("UIStroke", {
        Color = color or Color3.fromRGB(50, 50, 60),
        Thickness = thickness or 1,
        Transparency = 0.5,
        Parent = parent
    })
    return stroke
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Theme
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(18, 18, 24),
    Card = Color3.fromRGB(25, 25, 32),
    Element = Color3.fromRGB(32, 32, 42),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentLight = Color3.fromRGB(120, 130, 255),
    Green = Color3.fromRGB(87, 242, 135),
    Red = Color3.fromRGB(248, 81, 73),
    Orange = Color3.fromRGB(255, 159, 28),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 165),
    TextDark = Color3.fromRGB(100, 100, 115),
    Border = Color3.fromRGB(45, 45, 58),
}

-- Main Library Function
function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "v1.0.0"
    local size = config.Size or UDim2.new(0, 650, 0, 430)
    local sidebarWidth = 60
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    }
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "EnzoUI_" .. math.random(100000, 999999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    -- Blur
    local Blur = Create("BlurEffect", {
        Name = "EnzoUIBlur",
        Size = config.Blur ~= false and 8 or 0,
        Parent = Lighting
    })
    
    -- Main Frame
    local Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        Parent = ScreenGui
    })
    AddCorner(Main, 12)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        Parent = Main
    })
    AddCorner(Sidebar, 12)
    
    -- Fix sidebar right corners
    Create("Frame", {
        BackgroundColor3 = Theme.Sidebar,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        BorderSizePixel = 0,
        Parent = Sidebar
    })
    
    -- Logo
    local LogoFrame = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0.5, -20, 0, 15),
        Size = UDim2.new(0, 40, 0, 40),
        Parent = Sidebar
    })
    AddCorner(LogoFrame, 10)
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "E",
        TextColor3 = Theme.Text,
        TextSize = 22,
        Parent = LogoFrame
    })
    
    -- Tab List
    local TabList = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -120),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = TabList
    })
    AddPadding(TabList, 5)
    
    -- Content Area
    local ContentArea = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, sidebarWidth, 0, 0),
        Size = UDim2.new(1, -sidebarWidth, 1, 0),
        Parent = Main
    })
    
    -- Header
    local Header = Create("Frame", {
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = ContentArea
    })
    AddCorner(Header, 12)
    
    Create("Frame", {
        BackgroundColor3 = Theme.Card,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, -10, 0, 12),
        BorderSizePixel = 0,
        Parent = Header
    })
    
    local TabIcon = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "🏠",
        TextSize = 18,
        Parent = Header
    })
    
    local TabTitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 10),
        Size = UDim2.new(0.5, 0, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    local TabSubtitle = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 26),
        Size = UDim2.new(0.5, 0, 0, 12),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Control Dots
    local function CreateDot(color, pos, callback)
        local dot = Create("TextButton", {
            BackgroundColor3 = color,
            Position = pos,
            Size = UDim2.new(0, 14, 0, 14),
            Text = "",
            Parent = Header
        })
        AddCorner(dot, 7)
        dot.MouseButton1Click:Connect(callback)
        return dot
    end
    
    CreateDot(Theme.Red, UDim2.new(1, -35, 0.5, -7), function() Window:Destroy() end)
    CreateDot(Theme.Orange, UDim2.new(1, -55, 0.5, -7), function() Window:Toggle() end)
    CreateDot(Theme.Green, UDim2.new(1, -75, 0.5, -7), function() end)
    
    MakeDraggable(Main, Header)
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -100),
        Parent = ContentArea
    })
    
    -- Footer
    local Footer = Create("Frame", {
        BackgroundColor3 = Theme.Card,
        Position = UDim2.new(0, 0, 1, -45),
        Size = UDim2.new(1, 0, 0, 45),
        Parent = ContentArea
    })
    AddCorner(Footer, 12)
    
    Create("Frame", {
        BackgroundColor3 = Theme.Card,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -10, 0, 12),
        BorderSizePixel = 0,
        Parent = Footer
    })
    
    -- Opacity Slider in Footer
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -8),
        Size = UDim2.new(0, 20, 0, 16),
        Text = "☀",
        TextColor3 = Theme.TextMuted,
        TextSize = 14,
        Parent = Footer
    })
    
    local OpacityTrack = Create("Frame", {
        BackgroundColor3 = Theme.Element,
        Position = UDim2.new(0, 40, 0.5, -3),
        Size = UDim2.new(0, 80, 0, 6),
        Parent = Footer
    })
    AddCorner(OpacityTrack, 3)
    
    local OpacityFill = Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = OpacityTrack
    })
    AddCorner(OpacityFill, 3)
    
    local OpacityLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 125, 0.5, -8),
        Size = UDim2.new(0, 35, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = "100%",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Parent = Footer
    })
    
    -- Toggle Key Display
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0.5, -8),
        Size = UDim2.new(0, 85, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = "🔑 " .. Window.ToggleKey.Name,
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Footer
    })
    
    -- Toggle Key Handler
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Window.ToggleKey then
            Window:Toggle()
        end
    end)
    
    -- Window Methods
    function Window:Toggle()
        self.Visible = not self.Visible
        if self.Visible then
            Main.Visible = true
            Tween(Main, {Size = size}, 0.3)
            Tween(Blur, {Size = 8}, 0.3)
        else
            Tween(Main, {Size = UDim2.new(0, size.X.Offset, 0, 0)}, 0.25)
            Tween(Blur, {Size = 0}, 0.25)
            task.delay(0.25, function()
                if not self.Visible then Main.Visible = false end
            end)
        end
    end
    
    function Window:Destroy()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        Tween(Blur, {Size = 0}, 0.3)
        task.delay(0.3, function()
            ScreenGui:Destroy()
            Blur:Destroy()
        end)
        getgenv().EnzoUILib = nil
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Content.Visible = false
            Window.CurrentTab.Indicator.Visible = false
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1})
            Window.CurrentTab.IconLabel.TextColor3 = Theme.TextMuted
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        tab.Indicator.Visible = true
        TabIcon.Text = tab.Icon
        TabTitle.Text = tab.Name
        
        Tween(tab.Button, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Accent})
        tab.IconLabel.TextColor3 = Theme.Text
    end
    
    -- AddTab Function
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
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 44, 0, 44),
            Text = "",
            Parent = TabList
        })
        AddCorner(TabButton, 10)
        
        local TabIconLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextColor3 = Theme.TextMuted,
            TextSize = 18,
            Parent = TabButton
        })
        
        local TabIndicator = Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            Position = UDim2.new(0, -5, 0.25, 0),
            Size = UDim2.new(0, 3, 0.5, 0),
            Visible = false,
            Parent = TabButton
        })
        AddCorner(TabIndicator, 2)
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentContainer
        })
        AddPadding(TabContent, 10)
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10),
            Parent = TabContent
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Indicator = TabIndicator
        Tab.IconLabel = TabIconLabel
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.7})
                TabIconLabel.TextColor3 = Theme.Text
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1})
                TabIconLabel.TextColor3 = Theme.TextMuted
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Window:SelectTab(Tab) end
        
        -- AddSection Function
        function Tab:AddSection(config)
            config = config or {}
            local sectionName = config.Title or "Section"
            local sectionSide = config.Side or "Left"
            local sectionIcon = config.Icon or "⚡"
            
            local Section = {
                Name = sectionName,
                Elements = {}
            }
            
            -- Get or create column
            local columnName = sectionSide .. "Column"
            local column = TabContent:FindFirstChild(columnName)
            
            if not column then
                column = Create("Frame", {
                    Name = columnName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.48, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = sectionSide == "Left" and 1 or 2,
                    Parent = TabContent
                })
                Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = column})
            end
            
            -- Section Card
            local SectionCard = Create("Frame", {
                BackgroundColor3 = Theme.Card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            AddCorner(SectionCard, 10)
            AddStroke(SectionCard, Theme.Border)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Parent = SectionCard
            })
            
            local IconBG = Create("Frame", {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.85,
                Position = UDim2.new(0, 12, 0.5, -11),
                Size = UDim2.new(0, 22, 0, 22),
                Parent = SectionHeader
            })
            AddCorner(IconBG, 6)
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = Theme.Accent,
                TextSize = 11,
                Parent = IconBG
            })
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 40, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionCard
            })
            AddPadding(SectionContent, 8)
            Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = SectionContent})
            
            Section.Card = SectionCard
            Section.Content = SectionContent
            table.insert(Tab.Sections, Section)
            
            -- AddToggle
            function Section:AddToggle(cfg)
                cfg = cfg or {}
                local Toggle = {Value = cfg.Default or false}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 50 or 38),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 8 or 0),
                    Size = UDim2.new(1, -70, 0, cfg.Description and 16 or 38),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 24),
                        Size = UDim2.new(1, -70, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Switch = Create("Frame", {
                    BackgroundColor3 = Toggle.Value and Theme.Green or Theme.Element,
                    Position = UDim2.new(1, -55, 0.5, -11),
                    Size = UDim2.new(0, 44, 0, 22),
                    Parent = Frame
                })
                AddCorner(Switch, 11)
                
                local Knob = Create("Frame", {
                    BackgroundColor3 = Theme.Text,
                    Position = Toggle.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    Size = UDim2.new(0, 18, 0, 18),
                    Parent = Switch
                })
                AddCorner(Knob, 9)
                
                local ClickArea = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Frame
                })
                
                ClickArea.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    if Toggle.Value then
                        Tween(Switch, {BackgroundColor3 = Theme.Green})
                        Tween(Knob, {Position = UDim2.new(1, -20, 0.5, -9)})
                    else
                        Tween(Switch, {BackgroundColor3 = Theme.Element})
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -9)})
                    end
                    if cfg.Callback then cfg.Callback(Toggle.Value) end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.2}) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.4}) end)
                
                function Toggle:SetValue(v)
                    if Toggle.Value ~= v then
                        Toggle.Value = v
                        if v then
                            Tween(Switch, {BackgroundColor3 = Theme.Green})
                            Tween(Knob, {Position = UDim2.new(1, -20, 0.5, -9)})
                        else
                            Tween(Switch, {BackgroundColor3 = Theme.Element})
                            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -9)})
                        end
                    end
                end
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- AddSlider
            function Section:AddSlider(cfg)
                cfg = cfg or {}
                local min, max = cfg.Min or 0, cfg.Max or 100
                local Slider = {Value = cfg.Default or min}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 58 or 48),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -60, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local ValueBadge = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.85,
                    Position = UDim2.new(1, -50, 0, 5),
                    Size = UDim2.new(0, 40, 0, 18),
                    Parent = Frame
                })
                AddCorner(ValueBadge, 4)
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(Slider.Value) .. (cfg.Suffix or ""),
                    TextColor3 = Theme.Accent,
                    TextSize = 10,
                    Parent = ValueBadge
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 22),
                        Size = UDim2.new(1, -24, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Track = Create("Frame", {
                    BackgroundColor3 = Theme.Border,
                    Position = UDim2.new(0, 12, 1, -16),
                    Size = UDim2.new(1, -24, 0, 6),
                    Parent = Frame
                })
                AddCorner(Track, 3)
                
                local pct = (Slider.Value - min) / (max - min)
                
                local Fill = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(pct, 0, 1, 0),
                    Parent = Track
                })
                AddCorner(Fill, 3)
                
                local SliderKnob = Create("Frame", {
                    BackgroundColor3 = Theme.Text,
                    Position = UDim2.new(pct, -7, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 2,
                    Parent = Track
                })
                AddCorner(SliderKnob, 7)
                AddStroke(SliderKnob, Theme.Accent, 2)
                
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    Slider.Value = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
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
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.2}) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.4}) end)
                
                function Slider:SetValue(v)
                    local pos = (v - min) / (max - min)
                    Slider.Value = v
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(v) .. (cfg.Suffix or "")
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- AddButton
            function Section:AddButton(cfg)
                cfg = cfg or {}
                local colors = {
                    Primary = Theme.Accent,
                    Secondary = Theme.Element,
                    Danger = Theme.Red
                }
                local color = colors[cfg.Style or "Primary"] or Theme.Accent
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 65 or 42),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 8),
                        Size = UDim2.new(1, -24, 0, 14),
                        Font = Enum.Font.GothamMedium,
                        Text = cfg.Title or "Button",
                        TextColor3 = Theme.Text,
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
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = color,
                    Position = cfg.Description and UDim2.new(0, 10, 1, -28) or UDim2.new(0, 10, 0.5, -12),
                    Size = UDim2.new(1, -20, 0, cfg.Description and 22 or 24),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Description and "▶ EXECUTE" or (cfg.Title or "Button"),
                    TextColor3 = Theme.Text,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(Btn, 6)
                
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency = 0.2}) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency = 0}) end)
                Btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then cfg.Callback() end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.2}) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.4}) end)
                
                return {}
            end
            
            -- AddDropdown
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
                
                local baseH = cfg.Description and 68 or 55
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, baseH),
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -24, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Theme.Text,
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
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Theme.Card,
                    Position = UDim2.new(0, 10, 0, cfg.Description and 38 or 26),
                    Size = UDim2.new(1, -20, 0, 22),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(DropBtn, 5)
                AddStroke(DropBtn, Theme.Border)
                
                local BtnText = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -28, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = multi and "Select..." or (cfg.Default or "Select..."),
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropBtn
                })
                
                local Arrow = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 16, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextMuted,
                    TextSize = 10,
                    Parent = DropBtn
                })
                
                -- Dropdown Content
                local Content = Create("Frame", {
                    BackgroundColor3 = Theme.Card,
                    Position = UDim2.new(0, 10, 0, baseH + 3),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true,
                    Parent = Frame
                })
                AddCorner(Content, 6)
                AddStroke(Content, Theme.Border)
                
                -- Search
                local SearchBox = Create("TextBox", {
                    BackgroundColor3 = Theme.Element,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "🔍 Search...",
                    PlaceholderColor3 = Theme.TextDark,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    Parent = Content
                })
                AddCorner(SearchBox, 5)
                AddPadding(SearchBox, 5)
                
                -- Items List
                local ItemsList = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 34),
                    Size = UDim2.new(1, 0, 1, -34),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Content
                })
                AddPadding(ItemsList, 4)
                Create("UIListLayout", {Padding = UDim.new(0, 3), Parent = ItemsList})
                
                local itemBtns = {}
                
                local function createItem(name)
                    local isSel = multi and Dropdown.Value[name] or Dropdown.Value == name
                    
                    local ItemBtn = Create("TextButton", {
                        Name = name,
                        BackgroundColor3 = isSel and Theme.Accent or Theme.Element,
                        BackgroundTransparency = isSel and 0.7 or 0.3,
                        Size = UDim2.new(1, -8, 0, 26),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = ItemsList
                    })
                    AddCorner(ItemBtn, 5)
                    
                    if multi then
                        local cb = Create("Frame", {
                            BackgroundColor3 = isSel and Theme.Green or Theme.Card,
                            Position = UDim2.new(0, 6, 0.5, -7),
                            Size = UDim2.new(0, 14, 0, 14),
                            Parent = ItemBtn
                        })
                        AddCorner(cb, 3)
                        Create("TextLabel", {
                            Name = "Check",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.GothamBold,
                            Text = isSel and "✓" or "",
                            TextColor3 = Theme.Text,
                            TextSize = 10,
                            Parent = cb
                        })
                    end
                    
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, multi and 26 or 8, 0, 0),
                        Size = UDim2.new(1, multi and -32 or -14, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = name,
                        TextColor3 = isSel and Theme.Text or Theme.TextMuted,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ItemBtn
                    })
                    
                    ItemBtn.MouseEnter:Connect(function()
                        if not (multi and Dropdown.Value[name] or Dropdown.Value == name) then
                            Tween(ItemBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Accent})
                        end
                    end)
                    
                    ItemBtn.MouseLeave:Connect(function()
                        local sel = multi and Dropdown.Value[name] or Dropdown.Value == name
                        Tween(ItemBtn, {BackgroundTransparency = sel and 0.7 or 0.3, BackgroundColor3 = sel and Theme.Accent or Theme.Element})
                    end)
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[name] = not Dropdown.Value[name]
                            local nowSel = Dropdown.Value[name]
                            
                            local cb = ItemBtn:FindFirstChild("Frame")
                            if cb then
                                Tween(cb, {BackgroundColor3 = nowSel and Theme.Green or Theme.Card})
                                cb:FindFirstChild("Check").Text = nowSel and "✓" or ""
                            end
                            Tween(ItemBtn, {BackgroundColor3 = nowSel and Theme.Accent or Theme.Element, BackgroundTransparency = nowSel and 0.7 or 0.3})
                            ItemBtn:FindFirstChild("Text").TextColor3 = nowSel and Theme.Text or Theme.TextMuted
                            
                            local sel = {}
                            for k, v in pairs(Dropdown.Value) do if v then table.insert(sel, k) end end
                            BtnText.Text = #sel > 0 and table.concat(sel, ", ") or "Select..."
                            BtnText.TextColor3 = #sel > 0 and Theme.Text or Theme.TextMuted
                            
                            if cfg.Callback then cfg.Callback(Dropdown.Value) end
                        else
                            Dropdown.Value = name
                            BtnText.Text = name
                            BtnText.TextColor3 = Theme.Text
                            
                            for n, btn in pairs(itemBtns) do
                                local isThis = n == name
                                Tween(btn, {BackgroundColor3 = isThis and Theme.Accent or Theme.Element, BackgroundTransparency = isThis and 0.7 or 0.3})
                                btn:FindFirstChild("Text").TextColor3 = isThis and Theme.Text or Theme.TextMuted
                            end
                            
                            if cfg.Callback then cfg.Callback(name) end
                            
                            -- Close
                            Dropdown.Open = false
                            Tween(Arrow, {Rotation = 0})
                            Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)})
                            Tween(Content, {Size = UDim2.new(1, -20, 0, 0)})
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
                        Tween(Arrow, {Rotation = 180})
                        local cnt = math.min(#items, 5)
                        local contentH = 40 + (cnt * 29) + 10
                        local totalH = baseH + 8 + contentH
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, totalH)})
                        Tween(Content, {Size = UDim2.new(1, -20, 0, contentH)})
                    else
                        Tween(Arrow, {Rotation = 0})
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)})
                        Tween(Content, {Size = UDim2.new(1, -20, 0, 0)})
                    end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundTransparency = 0.2}) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundTransparency = 0.4}) end)
                
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
                        BtnText.TextColor3 = Theme.Text
                    end
                end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- AddLabel
            function Section:AddLabel(text)
                local Label = {}
                local LabelFrame = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Gotham,
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
    
    -- Notify Function
    function Window:Notify(cfg)
        cfg = cfg or {}
        local typeData = {
            Info = {Color = Theme.Accent, Icon = "ℹ️"},
            Success = {Color = Theme.Green, Icon = "✅"},
            Warning = {Color = Theme.Orange, Icon = "⚠️"},
            Error = {Color = Theme.Red, Icon = "❌"}
        }
        local data = typeData[cfg.Type or "Info"] or typeData.Info
        
        local NotifContainer = ScreenGui:FindFirstChild("Notifications")
        if not NotifContainer then
            NotifContainer = Create("Frame", {
                Name = "Notifications",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -330, 0, 15),
                Size = UDim2.new(0, 310, 0, 0),
                Parent = ScreenGui
            })
            Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = NotifContainer})
        end
        
        local Notif = Create("Frame", {
            BackgroundColor3 = Theme.Card,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Parent = NotifContainer
        })
        AddCorner(Notif, 10)
        AddStroke(Notif, data.Color)
        
        Create("Frame", {
            BackgroundColor3 = data.Color,
            Size = UDim2.new(0, 4, 1, 0),
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(0, 20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = data.Icon,
            TextSize = 16,
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 10),
            Size = UDim2.new(1, -55, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = cfg.Title or "Notification",
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif
        })
        
        local ContentLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 28),
            Size = UDim2.new(1, -55, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = cfg.Content or "",
            TextColor3 = Theme.TextMuted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notif
        })
        
        local Progress = Create("Frame", {
            BackgroundColor3 = data.Color,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            Parent = Notif
        })
        
        task.spawn(function()
            task.wait(0.05)
            local h = 50 + ContentLabel.TextBounds.Y
            Tween(Notif, {Size = UDim2.new(1, 0, 0, h)}, 0.3)
            Tween(Progress, {Size = UDim2.new(0, 0, 0, 3)}, cfg.Duration or 5)
            task.wait(cfg.Duration or 5)
            Tween(Notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
            task.wait(0.25)
            Notif:Destroy()
        end)
    end
    
    getgenv().EnzoUILib = Window
    return Window
end

return EnzoLib