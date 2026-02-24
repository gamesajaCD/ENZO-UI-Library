--[[
    ENZO UI LIBRARY - Design A: Minimal Floating
    Version: 1.0.0
    Author: ENZO-YT
    
    Features (Basic untuk test design):
    - Window dengan Draggable
    - Tab Navigation
    - Toggle, Slider, Button, Dropdown
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

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Color3.fromRGB(60, 60, 60),
        Thickness = thickness or 1,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

-- ============================================================
-- [[ THEME COLORS ]]
-- ============================================================
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Tertiary = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentDark = Color3.fromRGB(68, 81, 222),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(87, 242, 135),
    Error = Color3.fromRGB(242, 87, 87),
    Warning = Color3.fromRGB(242, 201, 76),
}

-- ============================================================
-- [[ MAIN LIBRARY ]]
-- ============================================================

function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "v1.0.0"
    local size = config.Size or UDim2.new(0, 550, 0, 400)
    local opacity = config.Opacity or 0
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Opacity = opacity
    Window.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    Window.Visible = true
    
    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "EnzoUI_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    Window.ScreenGui = ScreenGui
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        ClipsDescendants = true
    })
    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, Color3.fromRGB(50, 50, 55), 1)
    
    Window.MainFrame = MainFrame
    
    -- Shadow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = opacity,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0
    })
    AddCorner(TitleBar, 12)
    
    -- Fix bottom corners of title bar
    local TitleBarFix = Create("Frame", {
        Name = "Fix",
        Parent = TitleBar,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        BorderSizePixel = 0
    })
    
    -- Title Icon
    local TitleIcon = Create("TextLabel", {
        Name = "Icon",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "🎮",
        TextSize = 18
    })
    
    -- Title Text
    local TitleText = Create("TextLabel", {
        Name = "Title",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 42, 0, 8),
        Size = UDim2.new(0, 200, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Subtitle Text
    local SubtitleText = Create("TextLabel", {
        Name = "Subtitle",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 42, 0, 24),
        Size = UDim2.new(0, 200, 0, 14),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Theme.TextDark,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Window Controls
    local ControlsFrame = Create("Frame", {
        Name = "Controls",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -90, 0.5, -10),
        Size = UDim2.new(0, 75, 0, 20)
    })
    
    local function CreateControlButton(name, icon, position, color, callback)
        local btn = Create("TextButton", {
            Name = name,
            Parent = ControlsFrame,
            BackgroundColor3 = color,
            BackgroundTransparency = 0.8,
            Position = position,
            Size = UDim2.new(0, 20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = Theme.Text,
            TextSize = 12,
            AutoButtonColor = false
        })
        AddCorner(btn, 4)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.5}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.8}, 0.2)
        end)
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    -- Minimize Button
    CreateControlButton("Minimize", "─", UDim2.new(0, 0, 0, 0), Theme.Warning, function()
        Window:Toggle()
    end)
    
    -- Maximize Button (placeholder)
    CreateControlButton("Maximize", "□", UDim2.new(0, 27, 0, 0), Theme.Accent, function()
        -- Future: maximize functionality
    end)
    
    -- Close Button
    CreateControlButton("Close", "✕", UDim2.new(0, 54, 0, 0), Theme.Error, function()
        Window:Destroy()
    end)
    
    MakeDraggable(MainFrame, TitleBar)
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(1, -20, 0, 35)
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Tab Indicator Line
    local TabIndicator = Create("Frame", {
        Name = "Indicator",
        Parent = TabContainer,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(0, 50, 0, 2)
    })
    AddCorner(TabIndicator, 1)
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 90),
        Size = UDim2.new(1, -20, 1, -130)
    })
    
    -- Bottom Bar (Opacity, Theme, etc)
    local BottomBar = Create("Frame", {
        Name = "BottomBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0, 0, 1, -35),
        Size = UDim2.new(1, 0, 0, 35),
        BorderSizePixel = 0
    })
    AddCorner(BottomBar, 12)
    
    local BottomBarFix = Create("Frame", {
        Name = "Fix",
        Parent = BottomBar,
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = opacity,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 12),
        BorderSizePixel = 0
    })
    
    -- Opacity Label
    local OpacityLabel = Create("TextLabel", {
        Name = "OpacityLabel",
        Parent = BottomBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -8),
        Size = UDim2.new(0, 20, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "🔆",
        TextSize = 14
    })
    
    -- Opacity Slider
    local OpacitySliderBG = Create("Frame", {
        Name = "OpacitySliderBG",
        Parent = BottomBar,
        BackgroundColor3 = Theme.Tertiary,
        Position = UDim2.new(0, 40, 0.5, -4),
        Size = UDim2.new(0, 100, 0, 8)
    })
    AddCorner(OpacitySliderBG, 4)
    
    local OpacitySliderFill = Create("Frame", {
        Name = "Fill",
        Parent = OpacitySliderBG,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1 - opacity, 0, 1, 0)
    })
    AddCorner(OpacitySliderFill, 4)
    
    local OpacitySliderKnob = Create("Frame", {
        Name = "Knob",
        Parent = OpacitySliderBG,
        BackgroundColor3 = Theme.Text,
        Position = UDim2.new(1 - opacity, -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12)
    })
    AddCorner(OpacitySliderKnob, 6)
    
    local OpacityValue = Create("TextLabel", {
        Name = "Value",
        Parent = BottomBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 145, 0.5, -8),
        Size = UDim2.new(0, 35, 0, 16),
        Font = Enum.Font.Gotham,
        Text = tostring(math.floor((1 - opacity) * 100)) .. "%",
        TextColor3 = Theme.TextDark,
        TextSize = 11
    })
    
    -- Opacity Slider Logic
    local opacityDragging = false
    
    local function UpdateOpacity(input)
        local pos = math.clamp((input.Position.X - OpacitySliderBG.AbsolutePosition.X) / OpacitySliderBG.AbsoluteSize.X, 0, 1)
        local newOpacity = 1 - pos
        Window.Opacity = newOpacity
        
        OpacitySliderFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacitySliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
        OpacityValue.Text = tostring(math.floor(pos * 100)) .. "%"
        
        -- Update all frames
        MainFrame.BackgroundTransparency = newOpacity
        TitleBar.BackgroundTransparency = newOpacity
        TitleBarFix.BackgroundTransparency = newOpacity
        BottomBar.BackgroundTransparency = newOpacity
        BottomBarFix.BackgroundTransparency = newOpacity
    end
    
    OpacitySliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = true
            UpdateOpacity(input)
        end
    end)
    
    OpacitySliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateOpacity(input)
        end
    end)
    
    -- Toggle Key Display
    local ToggleKeyLabel = Create("TextLabel", {
        Name = "ToggleKey",
        Parent = BottomBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -120, 0.5, -8),
        Size = UDim2.new(0, 105, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "🔑 " .. tostring(Window.ToggleKey.Name),
        TextColor3 = Theme.TextDark,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Toggle Visibility
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
            Tween(MainFrame, {Size = size}, 0.3, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 0)}, 0.3, Enum.EasingStyle.Back).Completed:Connect(function()
                if not self.Visible then
                    MainFrame.Visible = false
                end
            end)
        end
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
        getgenv().EnzoUILib = nil
    end
    
    function Window:SetOpacity(value)
        self.Opacity = value
        MainFrame.BackgroundTransparency = value
        TitleBar.BackgroundTransparency = value
        TitleBarFix.BackgroundTransparency = value
        BottomBar.BackgroundTransparency = value
        BottomBarFix.BackgroundTransparency = value
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
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.Gotham,
            Text = "",
            AutoButtonColor = false
        })
        AddCorner(TabButton, 6)
        AddPadding(TabButton, 10)
        
        local TabButtonLayout = Create("UIListLayout", {
            Parent = TabButton,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6)
        })
        
        local TabIconLabel = Create("TextLabel", {
            Name = "Icon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Font = Enum.Font.Gotham,
            Text = tabIcon,
            TextSize = 14,
            LayoutOrder = 1
        })
        
        local TabNameLabel = Create("TextLabel", {
            Name = "Name",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            LayoutOrder = 2
        })
        
        -- Tab Content Frame
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
        
        local TabContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        -- Tab Selection Logic
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.8}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.2)
            end
        end)
        
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab by default
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
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
            
            -- Section Frame
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Parent = column,
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = Window.Opacity,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddCorner(SectionFrame, 8)
            AddStroke(SectionFrame, Color3.fromRGB(50, 50, 55), 1)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                Name = "Header",
                Parent = SectionFrame,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new(1, 0, 0, 30)
            })
            AddCorner(SectionHeader, 8)
            
            local SectionHeaderFix = Create("Frame", {
                Name = "Fix",
                Parent = SectionHeader,
                BackgroundColor3 = Theme.Accent,
                Position = UDim2.new(0, 0, 1, -8),
                Size = UDim2.new(1, 0, 0, 8),
                BorderSizePixel = 0
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                Name = "Content",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddPadding(SectionContent, 8)
            
            Create("UIListLayout", {
                Parent = SectionContent,
                Padding = UDim.new(0, 6),
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
                    Size = UDim2.new(1, 0, 0, toggleDescription and 50 or 35)
                })
                AddCorner(ToggleFrame, 6)
                
                local ToggleTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, toggleDescription and 8 or 0),
                    Size = UDim2.new(1, -60, 0, toggleDescription and 18 or 35),
                    Font = Enum.Font.GothamMedium,
                    Text = toggleName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if toggleDescription then
                    local ToggleDesc = Create("TextLabel", {
                        Name = "Description",
                        Parent = ToggleFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 26),
                        Size = UDim2.new(1, -60, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = toggleDescription,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local ToggleButton = Create("Frame", {
                    Name = "Button",
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggleDefault and Theme.Accent or Theme.Background,
                    Position = UDim2.new(1, -50, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                AddCorner(ToggleButton, 10)
                
                local ToggleKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = ToggleButton,
                    BackgroundColor3 = Theme.Text,
                    Position = toggleDefault and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                AddCorner(ToggleKnob, 8)
                
                local function UpdateToggle()
                    Toggle.Value = not Toggle.Value
                    
                    if Toggle.Value then
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Accent}, 0.2)
                        Tween(ToggleKnob, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                    else
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Background}, 0.2)
                        Tween(ToggleKnob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                    end
                    
                    toggleCallback(Toggle.Value)
                end
                
                local ToggleClickArea = Create("TextButton", {
                    Name = "ClickArea",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                ToggleClickArea.MouseButton1Click:Connect(UpdateToggle)
                
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
                    Size = UDim2.new(1, 0, 0, sliderDescription and 60 or 50)
                })
                AddCorner(SliderFrame, 6)
                
                local SliderTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
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
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 8),
                    Size = UDim2.new(0, 40, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(sliderDefault),
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                if sliderDescription then
                    local SliderDesc = Create("TextLabel", {
                        Name = "Description",
                        Parent = SliderFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 24),
                        Size = UDim2.new(1, -20, 0, 14),
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
                    Position = UDim2.new(0, 10, 1, -18),
                    Size = UDim2.new(1, -20, 0, 8)
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
                
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = SliderBG,
                    BackgroundColor3 = Theme.Text,
                    Position = UDim2.new(defaultPercent, -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                AddCorner(SliderKnob, 6)
                
                local sliderDragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                    local value = math.floor(sliderMin + (sliderMax - sliderMin) * pos)
                    
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
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
                
                function Slider:SetValue(value)
                    local pos = (value - sliderMin) / (sliderMax - sliderMin)
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
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
                
                local ButtonFrame = Create("Frame", {
                    Name = buttonName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Tertiary,
                    Size = UDim2.new(1, 0, 0, buttonDescription and 55 or 40)
                })
                AddCorner(ButtonFrame, 6)
                
                if buttonDescription then
                    local ButtonTitle = Create("TextLabel", {
                        Name = "Title",
                        Parent = ButtonFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 6),
                        Size = UDim2.new(1, -20, 0, 16),
                        Font = Enum.Font.GothamMedium,
                        Text = buttonName,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    local ButtonDesc = Create("TextLabel", {
                        Name = "Description",
                        Parent = ButtonFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 22),
                        Size = UDim2.new(1, -20, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = buttonDescription,
                        TextColor3 = Theme.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local ButtonMain = Create("TextButton", {
                    Name = "Button",
                    Parent = ButtonFrame,
                    BackgroundColor3 = Theme.Accent,
                    Position = buttonDescription and UDim2.new(0, 10, 1, -28) or UDim2.new(0, 10, 0.5, -12),
                    Size = buttonDescription and UDim2.new(1, -20, 0, 22) or UDim2.new(1, -20, 0, 24),
                    Font = Enum.Font.GothamBold,
                    Text = buttonDescription and "▶ EXECUTE" or buttonName,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    AutoButtonColor = false
                })
                AddCorner(ButtonMain, 4)
                
                ButtonMain.MouseEnter:Connect(function()
                    Tween(ButtonMain, {BackgroundColor3 = Theme.AccentDark}, 0.2)
                end)
                
                ButtonMain.MouseLeave:Connect(function()
                    Tween(ButtonMain, {BackgroundColor3 = Theme.Accent}, 0.2)
                end)
                
                ButtonMain.MouseButton1Click:Connect(function()
                    -- Click animation
                    Tween(ButtonMain, {Size = buttonDescription and UDim2.new(1, -24, 0, 20) or UDim2.new(1, -24, 0, 22)}, 0.1).Completed:Connect(function()
                        Tween(ButtonMain, {Size = buttonDescription and UDim2.new(1, -20, 0, 22) or UDim2.new(1, -20, 0, 24)}, 0.1)
                    end)
                    buttonCallback()
                end)
                
                table.insert(Section.Elements, Button)
                return Button
            end
            
            -- ============================================================
            -- [[ ELEMENT: DROPDOWN ]]
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
                
                local DropdownFrame = Create("Frame", {
                    Name = dropdownName,
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.Tertiary,
                    Size = UDim2.new(1, 0, 0, dropdownDescription and 70 or 55),
                    ClipsDescendants = true
                })
                AddCorner(DropdownFrame, 6)
                
                local DropdownTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
                    Size = UDim2.new(1, -20, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = dropdownName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                if dropdownDescription then
                    local DropdownDesc = Create("TextLabel", {
                        Name = "Description",
                        Parent = DropdownFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 24),
                        Size = UDim2.new(1, -20, 0, 12),
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
                    Position = UDim2.new(0, 10, 0, dropdownDescription and 40 or 28),
                    Size = UDim2.new(1, -20, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = dropdownMulti and "Select..." or (dropdownDefault or "Select..."),
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                AddCorner(DropdownButton, 4)
                AddPadding(DropdownButton, 8)
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10
                })
                
                local DropdownContent = Create("Frame", {
                    Name = "Content",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Background,
                    Position = UDim2.new(0, 10, 0, dropdownDescription and 70 or 58),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true
                })
                AddCorner(DropdownContent, 4)
                
                -- Search Box
                local SearchBox = Create("TextBox", {
                    Name = "Search",
                    Parent = DropdownContent,
                    BackgroundColor3 = Theme.Tertiary,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "🔍 Search...",
                    PlaceholderColor3 = Theme.TextDark,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false
                })
                AddCorner(SearchBox, 4)
                AddPadding(SearchBox, 6)
                
                local DropdownScroll = Create("ScrollingFrame", {
                    Name = "Scroll",
                    Parent = DropdownContent,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 35),
                    Size = UDim2.new(1, 0, 1, -35),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })
                
                Create("UIListLayout", {
                    Parent = DropdownScroll,
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                AddPadding(DropdownScroll, 5)
                
                local function CreateDropdownItem(itemName)
                    local isSelected = dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName
                    
                    local ItemButton = Create("TextButton", {
                        Name = itemName,
                        Parent = DropdownScroll,
                        BackgroundColor3 = isSelected and Theme.Accent or Theme.Tertiary,
                        Size = UDim2.new(1, -10, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = (dropdownMulti and (isSelected and "☑ " or "☐ ") or "") .. itemName,
                        TextColor3 = Theme.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false
                    })
                    AddCorner(ItemButton, 4)
                    AddPadding(ItemButton, 8)
                    
                    ItemButton.MouseEnter:Connect(function()
                        if not (dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName) then
                            Tween(ItemButton, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        local isSelected = dropdownMulti and Dropdown.Value[itemName] or Dropdown.Value == itemName
                        Tween(ItemButton, {BackgroundColor3 = isSelected and Theme.Accent or Theme.Tertiary}, 0.1)
                    end)
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        if dropdownMulti then
                            Dropdown.Value[itemName] = not Dropdown.Value[itemName]
                            local isSelected = Dropdown.Value[itemName]
                            ItemButton.Text = (isSelected and "☑ " or "☐ ") .. itemName
                            Tween(ItemButton, {BackgroundColor3 = isSelected and Theme.Accent or Theme.Tertiary}, 0.1)
                            
                            -- Update button text
                            local selected = {}
                            for k, v in pairs(Dropdown.Value) do
                                if v then table.insert(selected, k) end
                            end
                            DropdownButton.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                            
                            dropdownCallback(Dropdown.Value)
                        else
                            Dropdown.Value = itemName
                            DropdownButton.Text = itemName
                            
                            -- Update all items
                            for _, item in pairs(DropdownScroll:GetChildren()) do
                                if item:IsA("TextButton") then
                                    local isThis = item.Name == itemName
                                    Tween(item, {BackgroundColor3 = isThis and Theme.Accent or Theme.Tertiary}, 0.1)
                                end
                            end
                            
                            dropdownCallback(itemName)
                            
                            -- Close dropdown
                            Dropdown.Open = false
                            DropdownArrow.Text = "▼"
                            local closedHeight = dropdownDescription and 70 or 55
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.2)
                            Tween(DropdownContent, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
                        end
                    end)
                    
                    return ItemButton
                end
                
                -- Create items
                local itemButtons = {}
                for _, item in pairs(dropdownItems) do
                    itemButtons[item] = CreateDropdownItem(item)
                end
                
                -- Search functionality
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local searchText = SearchBox.Text:lower()
                    for itemName, button in pairs(itemButtons) do
                        button.Visible = searchText == "" or itemName:lower():find(searchText, 1, true)
                    end
                end)
                
                -- Toggle dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownArrow.Text = "▲"
                        local itemCount = math.min(#dropdownItems, 5)
                        local contentHeight = 35 + (itemCount * 27) + 10
                        local frameHeight = (dropdownDescription and 70 or 55) + contentHeight + 5
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, frameHeight)}, 0.2)
                        Tween(DropdownContent, {Size = UDim2.new(1, -20, 0, contentHeight)}, 0.2)
                    else
                        DropdownArrow.Text = "▼"
                        local closedHeight = dropdownDescription and 70 or 55
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, closedHeight)}, 0.2)
                        Tween(DropdownContent, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
                    end
                end)
                
                function Dropdown:SetItems(items)
                    Dropdown.Items = items
                    for _, child in pairs(DropdownScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    itemButtons = {}
                    for _, item in pairs(items) do
                        itemButtons[item] = CreateDropdownItem(item)
                    end
                end
                
                function Dropdown:SetValue(value)
                    if dropdownMulti then
                        Dropdown.Value = value
                        for itemName, button in pairs(itemButtons) do
                            local isSelected = value[itemName]
                            button.Text = (isSelected and "☑ " or "☐ ") .. itemName
                            button.BackgroundColor3 = isSelected and Theme.Accent or Theme.Tertiary
                        end
                        local selected = {}
                        for k, v in pairs(value) do
                            if v then table.insert(selected, k) end
                        end
                        DropdownButton.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                    else
                        Dropdown.Value = value
                        DropdownButton.Text = value
                        for itemName, button in pairs(itemButtons) do
                            button.BackgroundColor3 = itemName == value and Theme.Accent or Theme.Tertiary
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
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
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
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
            Window.CurrentTab.Button:FindFirstChild("Name").TextColor3 = Theme.TextDark
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        Tween(tab.Button, {BackgroundTransparency = 0.8}, 0.2)
        tab.Button:FindFirstChild("Name").TextColor3 = Theme.Text
        
        -- Move indicator
        task.spawn(function()
            task.wait(0.05)
            Tween(TabIndicator, {
                Position = UDim2.new(0, tab.Button.AbsolutePosition.X - TabContainer.AbsolutePosition.X, 1, -2),
                Size = UDim2.new(0, tab.Button.AbsoluteSize.X, 0, 2)
            }, 0.2)
        end)
    end
    
    -- ============================================================
    -- [[ NOTIFICATION SYSTEM ]]
    -- ============================================================
    
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 0, 0),
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
        
        local typeColors = {
            Info = Theme.Accent,
            Success = Theme.Success,
            Warning = Theme.Warning,
            Error = Theme.Error
        }
        
        local NotifFrame = Create("Frame", {
            Name = "Notification",
            Parent = NotificationContainer,
            BackgroundColor3 = Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true
        })
        AddCorner(NotifFrame, 8)
        AddStroke(NotifFrame, typeColors[notifType], 1)
        
        local NotifAccent = Create("Frame", {
            Name = "Accent",
            Parent = NotifFrame,
            BackgroundColor3 = typeColors[notifType],
            Size = UDim2.new(0, 4, 1, 0)
        })
        
        local NotifTitle = Create("TextLabel", {
            Name = "Title",
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -25, 0, 18),
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
            Position = UDim2.new(0, 15, 0, 30),
            Size = UDim2.new(1, -25, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = content,
            TextColor3 = Theme.TextDark,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        
        -- Animate in
        task.spawn(function()
            task.wait(0.05)
            local height = 45 + NotifContent.TextBounds.Y
            Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, height)}, 0.3, Enum.EasingStyle.Back)
            
            task.wait(duration)
            
            -- Animate out
            Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3).Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end)
    end
    
    -- Store reference
    getgenv().EnzoUILib = Window
    
    return Window
end

return EnzoLib