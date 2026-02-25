--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    ENZO UI LIBRARY v2.4.2                      ║
    ║                   Design G - Aurora Ethereal                   ║
    ║                        by ENZO-YT                              ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  FIXES v2.4.2:                                                 ║
    ║  • Button Text Contrast (always readable)                     ║
    ║  • Label/Section Size (larger, more readable)                 ║
    ║  • Opacity with Glow (glow stays visible)                     ║
    ║  • Blur parameter in CreateWindow                             ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

local EnzoLib = {}

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- THEMES
-- ============================================
local Themes = {
    Aurora = {
        Primary = Color3.fromRGB(139, 92, 246),
        Secondary = Color3.fromRGB(236, 72, 153),
        Tertiary = Color3.fromRGB(59, 130, 246),
        Accent = Color3.fromRGB(16, 185, 129)
    },
    Sunset = {
        Primary = Color3.fromRGB(251, 146, 60),
        Secondary = Color3.fromRGB(251, 113, 133),
        Tertiary = Color3.fromRGB(252, 211, 77),
        Accent = Color3.fromRGB(245, 101, 101)
    },
    Ocean = {
        Primary = Color3.fromRGB(34, 211, 238),
        Secondary = Color3.fromRGB(56, 189, 248),
        Tertiary = Color3.fromRGB(99, 102, 241),
        Accent = Color3.fromRGB(20, 184, 166)
    },
    Forest = {
        Primary = Color3.fromRGB(34, 197, 94),
        Secondary = Color3.fromRGB(16, 185, 129),
        Tertiary = Color3.fromRGB(132, 204, 22),
        Accent = Color3.fromRGB(45, 212, 191)
    },
    Sakura = {
        Primary = Color3.fromRGB(244, 114, 182),
        Secondary = Color3.fromRGB(251, 113, 133),
        Tertiary = Color3.fromRGB(232, 121, 249),
        Accent = Color3.fromRGB(248, 113, 113)
    },
    Midnight = {
        Primary = Color3.fromRGB(99, 102, 241),
        Secondary = Color3.fromRGB(139, 92, 246),
        Tertiary = Color3.fromRGB(79, 70, 229),
        Accent = Color3.fromRGB(129, 140, 248)
    }
}

-- ============================================
-- COLORS
-- ============================================
local Colors = {
    Background = Color3.fromRGB(13, 13, 18),
    BackgroundDark = Color3.fromRGB(8, 8, 12),
    BackgroundLight = Color3.fromRGB(22, 22, 30),
    Border = Color3.fromRGB(45, 45, 55),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextDark = Color3.fromRGB(100, 100, 115),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    Info = Color3.fromRGB(59, 130, 246)
}

-- ============================================
-- UTILITIES
-- ============================================
local function SafeCall(func, ...)
    if func then
        local success, err = pcall(func, ...)
        if not success then
            warn("[EnzoLib] Error:", err)
        end
        return success, err
    end
end

local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function AddCorner(instance, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = instance
    })
end

local function AddStroke(instance, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Colors.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = instance
    })
end

local function AddPadding(instance, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = instance
    })
end

local function AddGradient(instance, colors, rotation)
    local keypoints = {}
    for i, color in ipairs(colors) do
        keypoints[i] = ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color)
    end
    return Create("UIGradient", {
        Color = ColorSequence.new(keypoints),
        Rotation = rotation or 45,
        Parent = instance
    })
end

local function AddShadow(parent, color, size, transparency)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, size or 20, 1, size or 20),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = color or Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
    return shadow
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
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(frame, TweenInfo.new(0.1), {Position = newPos}):Play()
        end
    end)
end

-- ============================================
-- CREATE WINDOW
-- ============================================
function EnzoLib:CreateWindow(config)
    config = config or {}
    
    local windowTitle = config.Title or "Enzo UI"
    local windowSubTitle = config.SubTitle or "v2.4.2"
    local logoImage = config.Logo
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local themeName = config.Theme or "Aurora"
    local showWatermark = config.Watermark ~= false
    local scriptVersion = config.Version or "2.4.2"
    local updateURL = config.UpdateURL
    local blurEnabled = config.Blur ~= false -- DEFAULT TRUE, bisa di set false
    
    local CurrentTheme = Themes[themeName] or Themes.Aurora
    
    -- ============================================
    -- CLEANUP OLD UI
    -- ============================================
    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name:find("EnzoUI_") then
                gui:Destroy()
            end
        end
        for _, blur in ipairs(Lighting:GetChildren()) do
            if blur:IsA("BlurEffect") and blur.Name:find("EnzoBlur_") then
                blur:Destroy()
            end
        end
    end)
    
    -- ============================================
    -- SCREEN GUI
    -- ============================================
    local randomId = HttpService:GenerateGUID(false):sub(1, 8)
    local ScreenGui = Create("ScreenGui", {
        Name = "EnzoUI_" .. randomId,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = CoreGui
    })
    
    -- ============================================
    -- BLUR EFFECT (Controlled by config.Blur)
    -- ============================================
    local BlurEffect = Create("BlurEffect", {
        Name = "EnzoBlur_" .. randomId,
        Size = 0,
        Enabled = blurEnabled, -- Controlled by parameter
        Parent = Lighting
    })
    
    -- ============================================
    -- CONFIG SYSTEM
    -- ============================================
    local ConfigSys = {
        Elements = {},
        Keybinds = {}
    }
    
    function ConfigSys:RegisterElement(id, element, defaultValue)
        self.Elements[id] = {Element = element, Default = defaultValue}
    end
    
    function ConfigSys:RegisterKeybind(id, key, callback)
        self.Keybinds[id] = {Key = key, Callback = callback}
    end
    
    function ConfigSys:GetConfig()
        local cfg = {}
        for id, data in pairs(self.Elements) do
            if data.Element.GetValue then
                cfg[id] = data.Element:GetValue()
            elseif data.Element.Value ~= nil then
                cfg[id] = data.Element.Value
            end
        end
        return cfg
    end
    
    function ConfigSys:LoadConfig(cfg)
        for id, value in pairs(cfg) do
            if self.Elements[id] then
                local element = self.Elements[id].Element
                if element.SetValue then
                    element:SetValue(value)
                end
            end
        end
    end
    
    -- ============================================
    -- WINDOW OBJECT
    -- ============================================
    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        Minimized = false,
        ToggleKey = toggleKey,
        Config = ConfigSys,
        SearchableElements = {},
        Theme = CurrentTheme,
        BlurEnabled = blurEnabled -- Store blur state
    }
    
    -- ============================================
    -- BLUR CONTROL FUNCTION
    -- ============================================
    function Window:SetBlur(enabled)
        Window.BlurEnabled = enabled
        BlurEffect.Enabled = enabled
        if enabled and Window.Visible and not Window.Minimized then
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 15}):Play()
        else
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
        end
    end
    
    -- ============================================
    -- MAIN FRAME
    -- ============================================
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Colors.Background,
        Position = UDim2.new(0.5, -350, 0.5, -225),
        Size = UDim2.new(0, 700, 0, 450),
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, Colors.Border, 1)
    AddShadow(MainFrame, Color3.fromRGB(0, 0, 0), 30, 0.6)
    
    MakeDraggable(MainFrame)
    
    -- ============================================
    -- AURORA BORDER
    -- ============================================
    local AuroraBorder = Create("Frame", {
        Name = "AuroraBorder",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.new(0, -2, 0, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = 0,
        Parent = MainFrame
    })
    AddCorner(AuroraBorder, 14)
    local auroraGradient = AddGradient(AuroraBorder, {
        CurrentTheme.Primary,
        CurrentTheme.Secondary,
        CurrentTheme.Tertiary,
        CurrentTheme.Primary
    }, 0)
    
    -- Aurora Animation
    task.spawn(function()
        local rotation = 0
        while MainFrame and MainFrame.Parent do
            rotation = (rotation + 1) % 360
            auroraGradient.Rotation = rotation
            task.wait(0.03)
        end
    end)
    
    -- ============================================
    -- HEADER
    -- ============================================
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Colors.BackgroundDark,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = MainFrame
    })
    AddCorner(Header, 12)
    
    -- Fix corner overlap
    Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Logo
    if logoImage then
        Create("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0.5, -15),
            Size = UDim2.new(0, 30, 0, 30),
            Image = logoImage,
            Parent = Header
        })
    end
    
    -- Title
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, logoImage and 55 or 15, 0, 8),
        Size = UDim2.new(0, 200, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = windowTitle,
        TextColor3 = Colors.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Subtitle
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, logoImage and 55 or 15, 0, 26),
        Size = UDim2.new(0, 200, 0, 14),
        Font = Enum.Font.Gotham,
        Text = windowSubTitle,
        TextColor3 = Colors.TextSecondary,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    -- ============================================
    -- HEADER CONTROLS
    -- ============================================
    local ControlsFrame = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -120, 0.5, -12),
        Size = UDim2.new(0, 110, 0, 24),
        Parent = Header
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = ControlsFrame
    })
    
    local function CreateControlButton(icon, color, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = Colors.BackgroundLight,
            Size = UDim2.new(0, 24, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = color,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = ControlsFrame
        })
        AddCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.BackgroundLight}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = color}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Minimize Button
    CreateControlButton("—", Colors.Warning, function()
        Window:Minimize()
    end)
    
    -- Close Button
    CreateControlButton("×", Colors.Error, function()
        Window:Toggle()
    end)
    
    -- ============================================
    -- SEARCH BUTTON (Expandable)
    -- ============================================
    local SearchBtn = Create("TextButton", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(1, -180, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "🔍",
        TextColor3 = Colors.TextSecondary,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = Header
    })
    AddCorner(SearchBtn, 6)
    
    local SearchExpanded = false
    local SearchBox = Create("TextBox", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(1, -180, 0.5, -12),
        Size = UDim2.new(0, 0, 0, 24),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search...",
        Text = "",
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextDark,
        TextSize = 11,
        ClearTextOnFocus = false,
        Visible = false,
        ClipsDescendants = true,
        Parent = Header
    })
    AddCorner(SearchBox, 6)
    AddPadding(SearchBox, 6)
    
    SearchBtn.MouseButton1Click:Connect(function()
        SearchExpanded = not SearchExpanded
        if SearchExpanded then
            SearchBox.Visible = true
            TweenService:Create(SearchBox, TweenInfo.new(0.3), {Size = UDim2.new(0, 150, 0, 24)}):Play()
            TweenService:Create(SearchBtn, TweenInfo.new(0.3), {Position = UDim2.new(1, -340, 0.5, -12)}):Play()
            SearchBox:CaptureFocus()
        else
            TweenService:Create(SearchBox, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 24)}):Play()
            TweenService:Create(SearchBtn, TweenInfo.new(0.3), {Position = UDim2.new(1, -180, 0.5, -12)}):Play()
            task.delay(0.3, function() SearchBox.Visible = false end)
        end
    end)
    
    -- Search functionality
    SearchBox.Changed:Connect(function(prop)
        if prop == "Text" then
            local query = SearchBox.Text:lower()
            -- Implement search logic here
        end
    end)
    
    -- ============================================
    -- TABS FRAME
    -- ============================================
    local TabsFrame = Create("Frame", {
        Name = "TabsFrame",
        BackgroundColor3 = Colors.BackgroundDark,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 140, 1, -50),
        Parent = MainFrame
    })
    
    local TabsScroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Primary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabsFrame
    })
    AddPadding(TabsScroll, 8)
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsScroll
    })
    
    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 145, 0, 55),
        Size = UDim2.new(1, -150, 1, -60),
        ClipsDescendants = true,
        Parent = MainFrame
    })
    AddCorner(ContentArea, 8)
    
    -- ============================================
    -- NOTIFICATIONS
    -- ============================================
    local NotificationHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 10),
        Size = UDim2.new(0, 310, 1, -20),
        Parent = ScreenGui
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotificationHolder
    })
    
    function Window:Notify(cfg)
        cfg = cfg or {}
        local notifType = cfg.Type or "Info"
        local duration = cfg.Duration or 5
        
        local typeColors = {
            Info = Colors.Info,
            Success = Colors.Success,
            Warning = Colors.Warning,
            Error = Colors.Error
        }
        local typeIcons = {
            Info = "ℹ️",
            Success = "✅",
            Warning = "⚠️",
            Error = "❌"
        }
        
        local color = typeColors[notifType] or Colors.Info
        local icon = typeIcons[notifType] or "ℹ️"
        
        local Notif = Create("Frame", {
            BackgroundColor3 = Colors.Background,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Parent = NotificationHolder
        })
        AddCorner(Notif, 10)
        AddStroke(Notif, color, 1)
        AddShadow(Notif, color, 15, 0.7)
        
        local NotifContent = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Notif
        })
        AddPadding(NotifContent, 12)
        Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = NotifContent
        })
        
        -- Header
        local NotifHeader = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            LayoutOrder = 1,
            Parent = NotifContent
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = icon .. " " .. (cfg.Title or "Notification"),
            TextColor3 = color,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifHeader
        })
        
        -- Close button
        local CloseBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -16, 0, 0),
            Size = UDim2.new(0, 16, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Colors.TextSecondary,
            TextSize = 14,
            Parent = NotifHeader
        })
        CloseBtn.MouseButton1Click:Connect(function()
            TweenService:Create(Notif, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.delay(0.2, function() Notif:Destroy() end)
        end)
        
        -- Content
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = cfg.Content or "",
            TextColor3 = Colors.TextSecondary,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            Parent = NotifContent
        })
        
        -- Progress bar
        local ProgressBg = Create("Frame", {
            BackgroundColor3 = Colors.BackgroundLight,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            Parent = Notif
        })
        AddCorner(ProgressBg, 2)
        
        local ProgressFill = Create("Frame", {
            BackgroundColor3 = color,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = ProgressBg
        })
        AddCorner(ProgressFill, 2)
        
        -- Animate
        TweenService:Create(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        
        task.delay(duration, function()
            if Notif and Notif.Parent then
                TweenService:Create(Notif, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                task.delay(0.3, function() 
                    if Notif then Notif:Destroy() end 
                end)
            end
        end)
    end
    -- ============================================
    -- WINDOW FUNCTIONS
    -- ============================================
    function Window:Toggle()
        Window.Visible = not Window.Visible
        if Window.Visible then
            ScreenGui.Enabled = true
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 700, 0, 450),
                Position = UDim2.new(0.5, -350, 0.5, -225)
            }):Play()
            -- Only blur if BlurEnabled is true
            if Window.BlurEnabled then
                TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 15}):Play()
            end
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 700, 0, 0),
                Position = UDim2.new(0.5, -350, 0.5, 0)
            }):Play()
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
            task.delay(0.3, function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
        end
    end
    
    function Window:Minimize()
        Window.Minimized = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 200, 0, 50)
        }):Play()
        TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
    end
    
    function Window:Restore()
        Window.Minimized = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 700, 0, 450)
        }):Play()
        if Window.BlurEnabled then
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 15}):Play()
        end
    end
    
    function Window:Destroy()
        TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(0.3, function()
            ScreenGui:Destroy()
            BlurEffect:Destroy()
        end)
    end
    
    -- Toggle Key Handler
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Window.ToggleKey then
            if Window.Minimized then
                Window:Restore()
            else
                Window:Toggle()
            end
        end
    end)
    
    -- ============================================
    -- SCALE HANDLE
    -- ============================================
    local ScaleHandle = Create("TextButton", {
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 16, 0, 16),
        Text = "⤡",
        TextColor3 = Colors.Text,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        ZIndex = 100,
        Parent = MainFrame
    })
    AddCorner(ScaleHandle, 4)
    
    local scaling = false
    local baseSize = MainFrame.Size
    local baseScale = 1
    
    ScaleHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaling = true
            baseSize = MainFrame.Size
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaling = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if scaling and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = MainFrame.AbsolutePosition
            local newWidth = math.clamp(mousePos.X - framePos.X, 500, 900)
            local newHeight = math.clamp(mousePos.Y - framePos.Y, 350, 600)
            
            TweenService:Create(MainFrame, TweenInfo.new(0.1), {
                Size = UDim2.new(0, newWidth, 0, newHeight)
            }):Play()
        end
    end)
    
    -- ============================================
    -- SETTINGS PANEL (Theme, Opacity)
    -- ============================================
    local SettingsBtn = Create("TextButton", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 8, 1, -35),
        Size = UDim2.new(1, -16, 0, 28),
        Font = Enum.Font.Gotham,
        Text = "⚙️ Settings",
        TextColor3 = Colors.TextSecondary,
        TextSize = 11,
        AutoButtonColor = false,
        Parent = TabsFrame
    })
    AddCorner(SettingsBtn, 6)
    
    local SettingsPanel = Create("Frame", {
        BackgroundColor3 = Colors.Background,
        Position = UDim2.new(0, 145, 0, 55),
        Size = UDim2.new(1, -150, 1, -60),
        Visible = false,
        ZIndex = 50,
        Parent = MainFrame
    })
    AddCorner(SettingsPanel, 8)
    AddPadding(SettingsPanel, 15)
    
    local settingsOpen = false
    SettingsBtn.MouseButton1Click:Connect(function()
        settingsOpen = not settingsOpen
        SettingsPanel.Visible = settingsOpen
        ContentArea.Visible = not settingsOpen
    end)
    
    -- Settings Title
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "⚙️ UI Settings",
        TextColor3 = Colors.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SettingsPanel
    })
    
    -- ========== THEME SELECTOR ==========
    local ThemeLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "Theme",
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SettingsPanel
    })
    
    local ThemeGrid = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 105),
        Size = UDim2.new(1, 0, 0, 60),
        Parent = SettingsPanel
    })
    Create("UIGridLayout", {
        CellSize = UDim2.new(0, 70, 0, 25),
        CellPadding = UDim2.new(0, 8, 0, 8),
        Parent = ThemeGrid
    })
    
    for name, theme in pairs(Themes) do
        local themeBtn = Create("TextButton", {
            BackgroundColor3 = theme.Primary,
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Colors.Text,
            TextSize = 9,
            AutoButtonColor = false,
            Parent = ThemeGrid
        })
        AddCorner(themeBtn, 6)
        AddGradient(themeBtn, {theme.Primary, theme.Secondary}, 90)
        
        themeBtn.MouseButton1Click:Connect(function()
            CurrentTheme = theme
            Window.Theme = theme
            -- Update aurora gradient
            auroraGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.Primary),
                ColorSequenceKeypoint.new(0.33, theme.Secondary),
                ColorSequenceKeypoint.new(0.66, theme.Tertiary),
                ColorSequenceKeypoint.new(1, theme.Primary)
            })
            Window:Notify({Title = "Theme Changed", Content = "Applied: " .. name, Type = "Success", Duration = 2})
        end)
    end
    
    -- ========== OPACITY SLIDER (FIXED - Glow stays visible) ==========
    local OpacitySlider = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = SettingsPanel
    })
    AddCorner(OpacitySlider, 6)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Font = Enum.Font.Gotham,
        Text = "Opacity",
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = OpacitySlider
    })

    local OpacityTrack = Create("Frame", {
        BackgroundColor3 = Colors.Background,
        Size = UDim2.new(1, -110, 0, 6),
        Position = UDim2.new(0, 70, 0.5, -3),
        Parent = OpacitySlider
    })
    AddCorner(OpacityTrack, 3)

    local OpacityFill = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = OpacityTrack
    })
    AddCorner(OpacityFill, 3)
    AddGradient(OpacityFill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 90)

    local OpacityValue = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 35, 1, 0),
        Position = UDim2.new(1, -40, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "100%",
        TextColor3 = Colors.Text,
        TextSize = 10,
        Parent = OpacitySlider
    })

    -- FIX: Opacity hanya mempengaruhi background, BUKAN glow/aurora border
    local function UpdateOpacity(percent)
        percent = math.clamp(percent, 30, 100) -- Minimum 30%
        OpacityFill.Size = UDim2.new(percent / 100, 0, 1, 0)
        OpacityValue.Text = math.floor(percent) .. "%"
        
        -- Calculate transparency (inverted)
        local transparency = 1 - (percent / 100)
        
        -- Hanya background yang berubah, AURORA BORDER TETAP SOLID
        MainFrame.BackgroundTransparency = transparency * 0.6
        ContentArea.BackgroundTransparency = 0.3 + (transparency * 0.4)
        TabsFrame.BackgroundTransparency = transparency * 0.5
        Header.BackgroundTransparency = transparency * 0.4
        
        -- AuroraBorder TIDAK berubah - tetap solid untuk glow effect
        -- AuroraBorder.Transparency tetap 0
    end

    local opacityDragging = false

    OpacityTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = true
            local percent = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X * 100, 30, 100)
            UpdateOpacity(percent)
        end
    end)

    OpacityTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X * 100, 30, 100)
            UpdateOpacity(percent)
        end
    end)
    -- ============================================
    -- WATERMARK
    -- ============================================
    if showWatermark then
        local Watermark = Create("Frame", {
            BackgroundColor3 = Colors.Background,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, 200, 0, 32),
            Parent = ScreenGui
        })
        AddCorner(Watermark, 8)
        AddStroke(Watermark, CurrentTheme.Primary, 1, 0.5)
        AddShadow(Watermark, CurrentTheme.Primary, 10, 0.8)
        MakeDraggable(Watermark)
        
        local WatermarkText = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = Enum.Font.GothamBold,
            Text = "ENZO | FPS: -- | Ping: -- | 00:00:00",
            TextColor3 = Colors.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Watermark
        })
        
        local startTime = tick()
        task.spawn(function()
            while Watermark and Watermark.Parent do
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                local elapsed = tick() - startTime
                local hours = math.floor(elapsed / 3600)
                local mins = math.floor((elapsed % 3600) / 60)
                local secs = math.floor(elapsed % 60)
                local timeStr = string.format("%02d:%02d:%02d", hours, mins, secs)
                
                WatermarkText.Text = string.format("ENZO | FPS: %d | Ping: %dms | %s", fps, ping, timeStr)
            end
        end)
    end
    
    -- ============================================
    -- ADD CONFIG MANAGER TAB
    -- ============================================
    function Window:AddConfigManager()
        local ConfigTab = Window:AddTab({Title = "Configs", Icon = "💾"})
        local ConfigSection = ConfigTab:AddSection({Title = "Config Manager", Side = "Left", Icon = "📁"})
        
        ConfigSection:AddLabel("— Save & Load Configs —")
        
        local configNameInput = ""
        ConfigSection:AddInput({
            Title = "Config Name",
            Placeholder = "Enter config name...",
            Callback = function(text)
                configNameInput = text
            end
        })
        
        ConfigSection:AddButton({
            Title = "💾 Save Config",
            Style = "Success",
            Callback = function()
                if configNameInput ~= "" then
                    local cfg = ConfigSys:GetConfig()
                    local json = HttpService:JSONEncode(cfg)
                    if writefile then
                        writefile("EnzoConfigs/" .. configNameInput .. ".json", json)
                        Window:Notify({Title = "Config Saved", Content = "Saved: " .. configNameInput, Type = "Success", Duration = 3})
                    else
                        Window:Notify({Title = "Error", Content = "File system not available", Type = "Error", Duration = 3})
                    end
                end
            end
        })
        
        ConfigSection:AddButton({
            Title = "📂 Load Config",
            Style = "Primary",
            Callback = function()
                if configNameInput ~= "" and readfile then
                    local success, content = pcall(function()
                        return readfile("EnzoConfigs/" .. configNameInput .. ".json")
                    end)
                    if success then
                        local cfg = HttpService:JSONDecode(content)
                        ConfigSys:LoadConfig(cfg)
                        Window:Notify({Title = "Config Loaded", Content = "Loaded: " .. configNameInput, Type = "Success", Duration = 3})
                    else
                        Window:Notify({Title = "Error", Content = "Config not found", Type = "Error", Duration = 3})
                    end
                end
            end
        })
        
        return ConfigTab
    end
    
    -- ============================================
    -- ADD TAB
    -- ============================================
    function Window:AddTab(config)
        config = config or {}
        
        local Tab = {
            Name = config.Title or "Tab",
            Sections = {},
            Button = nil,
            Content = nil
        }
        
        -- Tab Button
        local TabBtn = Create("TextButton", {
            BackgroundColor3 = Colors.BackgroundLight,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Font = Enum.Font.GothamMedium,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #Window.Tabs + 1,
            Parent = TabsScroll
        })
        AddCorner(TabBtn, 8)
        
        -- Tab Icon & Text
        local TabContent = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = TabBtn
        })
        AddPadding(TabContent, 8)
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = config.Icon or "📁",
            TextColor3 = Colors.TextSecondary,
            TextSize = 14,
            Parent = TabContent
        })
        
        local TabLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 26, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = config.Title or "Tab",
            TextColor3 = Colors.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabContent
        })
        
        -- Tab Badge
        local TabBadge = Create("Frame", {
            BackgroundColor3 = Colors.Error,
            Position = UDim2.new(1, -20, 0.5, -8),
            Size = UDim2.new(0, 0, 0, 16),
            Visible = false,
            Parent = TabContent
        })
        AddCorner(TabBadge, 8)
        
        local BadgeText = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "0",
            TextColor3 = Colors.Text,
            TextSize = 10,
            Parent = TabBadge
        })
        
        function Tab:SetBadge(count)
            if count and count > 0 then
                TabBadge.Visible = true
                BadgeText.Text = tostring(count)
                TabBadge.Size = UDim2.new(0, math.max(16, #tostring(count) * 8 + 8), 0, 16)
            else
                TabBadge.Visible = false
            end
        end
        
        -- Tab Content Container
        local TabContainer = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Primary,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        AddPadding(TabContainer, 10)
        
        -- Two Column Layout
        local ColumnsFrame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = TabContainer
        })
        
        local LeftColumn = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = ColumnsFrame
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = LeftColumn
        })
        
        local RightColumn = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 5, 0, 0),
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = ColumnsFrame
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = RightColumn
        })
        
        Tab.Button = TabBtn
        Tab.Content = TabContainer
        Tab.LeftColumn = LeftColumn
        Tab.RightColumn = RightColumn
        
        -- Tab Selection
        local function SelectTab()
            -- Deselect all
            for _, t in ipairs(Window.Tabs) do
                t.Content.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                for _, label in ipairs(t.Button:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
                    end
                end
            end
            
            -- Select this tab
            Tab.Content.Visible = true
            Window.ActiveTab = Tab
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            for _, label in ipairs(TabBtn:GetDescendants()) do
                if label:IsA("TextLabel") then
                    TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
                end
            end
        end
        
        TabBtn.MouseButton1Click:Connect(SelectTab)
        
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end)
        
        -- Auto select first tab
        if #Window.Tabs == 0 then
            SelectTab()
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- ============================================
        -- ADD SECTION
        -- ============================================
        function Tab:AddSection(config)
            config = config or {}
            
            local Section = {
                Elements = {}
            }
            
            local parentColumn = config.Side == "Right" and RightColumn or LeftColumn
            
            local SectionFrame = Create("Frame", {
                BackgroundColor3 = Colors.Background,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #Tab.Sections + 1,
                Parent = parentColumn
            })
            AddCorner(SectionFrame, 10)
            AddStroke(SectionFrame, Colors.Border, 1)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                BackgroundColor3 = Colors.BackgroundDark,
                Size = UDim2.new(1, 0, 0, 32),
                Parent = SectionFrame
            })
            AddCorner(SectionHeader, 10)
            
            Create("Frame", {
                BackgroundColor3 = Colors.BackgroundDark,
                Position = UDim2.new(0, 0, 1, -10),
                Size = UDim2.new(1, 0, 0, 10),
                BorderSizePixel = 0,
                Parent = SectionHeader
            })
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = (config.Icon or "📁") .. "  " .. (config.Title or "Section"),
                TextColor3 = Colors.Text,
                TextSize = 12, -- FIXED: Larger size
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })
            AddPadding(SectionContent, 10)
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            table.insert(Tab.Sections, Section)
            
            local elementOrder = 0
            local function GetNextOrder()
                elementOrder = elementOrder + 1
                return elementOrder
            end
            
            -- Tooltip helper
            local function AddTooltip(element, text)
                if not text then return end
                
                local tooltip = Create("Frame", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 0, 0, -35),
                    Size = UDim2.new(0, 0, 0, 28),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Visible = false,
                    ZIndex = 1000,
                    Parent = element
                })
                AddCorner(tooltip, 6)
                AddStroke(tooltip, CurrentTheme.Primary, 1)
                AddPadding(tooltip, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    ZIndex = 1001,
                    Parent = tooltip
                })
                
                element.MouseEnter:Connect(function()
                    tooltip.Visible = true
                end)
                element.MouseLeave:Connect(function()
                    tooltip.Visible = false
                end)
            end
            
            -- ========== LABEL (FIXED SIZE) ==========
            function Section:AddLabel(text)
                local order = GetNextOrder()
                
                local Label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24), -- FIXED: Larger
                    LayoutOrder = order,
                    Font = Enum.Font.GothamMedium,
                    Text = text or "Label",
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 12, -- FIXED: Larger
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = SectionContent
                })
                
                local LabelObj = {
                    Label = Label,
                    SetText = function(self, newText)
                        Label.Text = newText
                    end
                }
                
                table.insert(Section.Elements, LabelObj)
                return LabelObj
            end
            
            -- ========== DIVIDER (FIXED SIZE) ==========
            function Section:AddDivider(text)
                local order = GetNextOrder()
                
                local DividerFrame = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 26), -- FIXED: Larger
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                
                if text and text ~= "" then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = "— " .. text .. " —",
                        TextColor3 = Colors.TextSecondary,
                        TextSize = 11, -- FIXED: Larger
                        Parent = DividerFrame
                    })
                else
                    local Line = Create("Frame", {
                        BackgroundColor3 = Colors.Border,
                        Size = UDim2.new(1, 0, 0, 2),
                        Position = UDim2.new(0, 0, 0.5, -1),
                        Parent = DividerFrame
                    })
                    AddCorner(Line, 1)
                end
                
                table.insert(Section.Elements, {Frame = DividerFrame})
                return {Frame = DividerFrame}
            end
            
            -- ========== TOGGLE ==========
            function Section:AddToggle(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local id = cfg.Title or ("Toggle_" .. order)
                
                local Toggle = {Value = cfg.Default or false}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 52 or 38), -- FIXED: Larger
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                local TitleLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 8 or 0),
                    Size = UDim2.new(1, -70, 0, cfg.Description and 18 or 38),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Colors.Text,
                    TextSize = 12, -- FIXED: Larger
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 26),
                        Size = UDim2.new(1, -70, 0, 18),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                -- Toggle Switch
                local SwitchBg = Create("Frame", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(1, -52, 0.5, -11),
                    Size = UDim2.new(0, 42, 0, 22),
                    Parent = Frame
                })
                AddCorner(SwitchBg, 11)
                
                local SwitchCircle = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(0, 3, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Parent = SwitchBg
                })
                AddCorner(SwitchCircle, 8)
                
                local function UpdateToggle()
                    if Toggle.Value then
                        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary}):Play()
                        TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
                    else
                        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Background}):Play()
                        TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
                    end
                end
                
                UpdateToggle()
                
                local ClickArea = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Frame
                })
                
                ClickArea.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                    SafeCall(cfg.Callback, Toggle.Value)
                end)
                
                function Toggle:SetValue(v)
                    Toggle.Value = v
                    UpdateToggle()
                end
                
                function Toggle:GetValue()
                    return Toggle.Value
                end
                
                if cfg.Tooltip then
                    AddTooltip(Frame, cfg.Tooltip)
                end
                
                ConfigSys:RegisterElement(id, Toggle, cfg.Default or false)
                Window.SearchableElements[id] = {Title = cfg.Title or "Toggle", Tab = Tab, Element = Toggle, Frame = Frame}
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- ========== SLIDER (dengan AllowInput) ==========
            function Section:AddSlider(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local id = cfg.Title or ("Slider_" .. order)
                
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local default = math.clamp(cfg.Default or min, min, max)
                local suffix = cfg.Suffix or ""
                local allowInput = cfg.AllowInput or false
                
                local Slider = {Value = default}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 62 or 48), -- FIXED: Larger
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(0.5, -12, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Colors.Text,
                    TextSize = 12, -- FIXED: Larger
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                -- Value display (can be input if AllowInput)
                local ValueDisplay
                if allowInput then
                    ValueDisplay = Create("TextBox", {
                        BackgroundColor3 = Colors.Background,
                        Position = UDim2.new(1, -70, 0, 6),
                        Size = UDim2.new(0, 58, 0, 22),
                        Font = Enum.Font.GothamBold,
                        Text = tostring(default) .. suffix,
                        TextColor3 = CurrentTheme.Primary,
                        TextSize = 11,
                        ClearTextOnFocus = false,
                        Parent = Frame
                    })
                    AddCorner(ValueDisplay, 6)
                else
                    ValueDisplay = Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -70, 0, 8),
                        Size = UDim2.new(0, 58, 0, 18),
                        Font = Enum.Font.GothamBold,
                        Text = tostring(default) .. suffix,
                        TextColor3 = CurrentTheme.Primary,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = Frame
                    })
                end
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 26),
                        Size = UDim2.new(1, -24, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local sliderY = cfg.Description and 44 or 32
                
                local Track = Create("Frame", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 12, 0, sliderY),
                    Size = UDim2.new(1, -24, 0, 8),
                    Parent = Frame
                })
                AddCorner(Track, 4)
                
                local Fill = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    Parent = Track
                })
                AddCorner(Fill, 4)
                AddGradient(Fill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 90)
                
                local Knob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 5,
                    Parent = Track
                })
                AddCorner(Knob, 8)
                AddStroke(Knob, CurrentTheme.Primary, 2)
                
                local function UpdateSlider(value)
                    value = math.clamp(math.floor(value), min, max)
                    Slider.Value = value
                    local percent = (value - min) / (max - min)
                    TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.new(percent, -8, 0.5, -8)}):Play()
                    ValueDisplay.Text = tostring(value) .. suffix
                end
                
                local dragging = false
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percent
                        UpdateSlider(value)
                        SafeCall(cfg.Callback, Slider.Value)
                    end
                end)
                
                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percent
                        UpdateSlider(value)
                        SafeCall(cfg.Callback, Slider.Value)
                    end
                end)
                
                -- Input handling for AllowInput
                if allowInput then
                    ValueDisplay.FocusLost:Connect(function(enterPressed)
                        local text = ValueDisplay.Text:gsub(suffix, "")
                        local num = tonumber(text)
                        if num then
                            UpdateSlider(num)
                            SafeCall(cfg.Callback, Slider.Value)
                        else
                            ValueDisplay.Text = tostring(Slider.Value) .. suffix
                        end
                    end)
                end
                
                function Slider:SetValue(v)
                    UpdateSlider(v)
                end
                
                function Slider:GetValue()
                    return Slider.Value
                end
                
                if cfg.Tooltip then
                    AddTooltip(Frame, cfg.Tooltip)
                end
                
                ConfigSys:RegisterElement(id, Slider, default)
                Window.SearchableElements[id] = {Title = cfg.Title or "Slider", Tab = Tab, Element = Slider, Frame = Frame}
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ========== BUTTON (FIXED TEXT CONTRAST) ==========
            function Section:AddButton(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local style = cfg.Style or "Primary"
                
                -- FIXED: Button styles dengan text yang SELALU PUTIH untuk kontras
                local ButtonStyles = {
                    Primary = {
                        Background = CurrentTheme.Primary,
                        Gradient = {CurrentTheme.Primary, CurrentTheme.Secondary},
                        Text = Color3.fromRGB(255, 255, 255), -- ALWAYS WHITE
                        Hover = CurrentTheme.Secondary
                    },
                    Secondary = {
                        Background = Colors.BackgroundLight,
                        Gradient = nil,
                        Text = Colors.Text,
                        Hover = Colors.Border
                    },
                    Success = {
                        Background = Color3.fromRGB(34, 197, 94),
                        Gradient = {Color3.fromRGB(34, 197, 94), Color3.fromRGB(22, 163, 74)},
                        Text = Color3.fromRGB(255, 255, 255), -- ALWAYS WHITE
                        Hover = Color3.fromRGB(22, 163, 74)
                    },
                    Danger = {
                        Background = Color3.fromRGB(239, 68, 68),
                        Gradient = {Color3.fromRGB(239, 68, 68), Color3.fromRGB(220, 38, 38)},
                        Text = Color3.fromRGB(255, 255, 255), -- ALWAYS WHITE
                        Hover = Color3.fromRGB(220, 38, 38)
                    }
                }
                
                local btnStyle = ButtonStyles[style] or ButtonStyles.Primary
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = btnStyle.Background,
                    Size = UDim2.new(1, 0, 0, 38), -- FIXED: Larger
                    LayoutOrder = order,
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Button",
                    TextColor3 = btnStyle.Text,
                    TextSize = 13, -- FIXED: Larger
                    AutoButtonColor = false,
                    Parent = SectionContent
                })
                AddCorner(Btn, 8)
                
                if btnStyle.Gradient then
                    AddGradient(Btn, btnStyle.Gradient, 90)
                end
                
                Btn.MouseEnter:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = btnStyle.Hover}):Play()
                end)
                
                Btn.MouseLeave:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = btnStyle.Background}):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    -- Press animation
                    TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 36)}):Play()
                    task.wait(0.1)
                    TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 38)}):Play()
                    
                    SafeCall(cfg.Callback)
                end)
                
                if cfg.Tooltip then
                    AddTooltip(Btn, cfg.Tooltip)
                end
                
                table.insert(Section.Elements, {Button = Btn})
                return {Button = Btn}
            end
            -- ========== INPUT (Enhanced) ==========
            function Section:AddInput(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local id = cfg.Title or ("Input_" .. order)
                
                local Input = {Value = cfg.Default or ""}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 70 or 56), -- FIXED: Larger
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(1, -24, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Input",
                    TextColor3 = Colors.Text,
                    TextSize = 12, -- FIXED: Larger
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 26),
                        Size = UDim2.new(1, -24, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextDark,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local inputY = cfg.Description and 42 or 28
                
                local TextBox = Create("TextBox", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 10, 0, inputY),
                    Size = UDim2.new(1, -20, 0, 28),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = cfg.Placeholder or "Enter text...",
                    Text = cfg.Default or "",
                    TextColor3 = Colors.Text,
                    PlaceholderColor3 = Colors.TextDark,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                    Parent = Frame
                })
                AddCorner(TextBox, 6)
                AddPadding(TextBox, 8)
                
                TextBox.FocusLost:Connect(function()
                    local value = TextBox.Text
                    
                    -- Type validation
                    if cfg.Type == "Number" or cfg.Type == "Integer" then
                        local num = tonumber(value)
                        if num then
                            if cfg.Min then num = math.max(num, cfg.Min) end
                            if cfg.Max then num = math.min(num, cfg.Max) end
                            if cfg.Type == "Integer" then num = math.floor(num) end
                            value = tostring(num)
                            TextBox.Text = value
                        else
                            TextBox.Text = Input.Value
                            return
                        end
                    end
                    
                    Input.Value = value
                    SafeCall(cfg.Callback, value)
                end)
                
                function Input:SetValue(v)
                    Input.Value = v
                    TextBox.Text = v
                end
                
                function Input:GetValue()
                    return Input.Value
                end
                
                if cfg.Tooltip then
                    AddTooltip(Frame, cfg.Tooltip)
                end
                
                ConfigSys:RegisterElement(id, Input, cfg.Default or "")
                
                table.insert(Section.Elements, Input)
                return Input
            end
            
            -- ========== COLOR PICKER ==========
            function Section:AddColorPicker(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local id = cfg.Title or ("ColorPicker_" .. order)
                
                local defaultColor = cfg.Default or Color3.fromRGB(255, 0, 0)
                local ColorPicker = {Value = defaultColor}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 38),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Color",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local ColorPreview = Create("TextButton", {
                    BackgroundColor3 = defaultColor,
                    Position = UDim2.new(1, -46, 0.5, -12),
                    Size = UDim2.new(0, 36, 0, 24),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(ColorPreview, 6)
                AddStroke(ColorPreview, Colors.Border, 1)
                
                -- Color Picker Panel
                local PickerPanel = Create("Frame", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(1, 0, 0, 120),
                    Visible = false,
                    ZIndex = 100,
                    Parent = Frame
                })
                AddCorner(PickerPanel, 8)
                AddStroke(PickerPanel, CurrentTheme.Primary, 1)
                AddPadding(PickerPanel, 10)
                
                -- Saturation/Value picker
                local SVPicker = Create("ImageButton", {
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -30, 0, 70),
                    Image = "rbxassetid://4155801252",
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                AddCorner(SVPicker, 6)
                
                local SVCursor = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 102,
                    Parent = SVPicker
                })
                AddCorner(SVCursor, 5)
                AddStroke(SVCursor, Colors.Background, 2)
                
                -- Hue slider
                local HueSlider = Create("ImageButton", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 15, 0, 70),
                    Image = "rbxassetid://3641079629",
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                AddCorner(HueSlider, 4)
                
                local HueCursor = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(0, -2, 0, 0),
                    Size = UDim2.new(1, 4, 0, 4),
                    ZIndex = 102,
                    Parent = HueSlider
                })
                AddCorner(HueCursor, 2)
                
                -- Hex input
                local HexInput = Create("TextBox", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Position = UDim2.new(0, 0, 1, -25),
                    Size = UDim2.new(1, 0, 0, 22),
                    Font = Enum.Font.GothamMedium,
                    Text = "#FF0000",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                AddCorner(HexInput, 4)
                
                local hue, sat, val = 0, 1, 1
                
                local function UpdateColor()
                    local color = Color3.fromHSV(hue, sat, val)
                    ColorPicker.Value = color
                    ColorPreview.BackgroundColor3 = color
                    SVPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    HexInput.Text = string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
                    SafeCall(cfg.Callback, color)
                end
                
                -- Initialize from default
                hue, sat, val = defaultColor:ToHSV()
                UpdateColor()
                
                -- SV Picker interaction
                local svDragging = false
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if svDragging then
                        local pos = SVPicker.AbsolutePosition
                        local size = SVPicker.AbsoluteSize
                        local x = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                        local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                        sat = x
                        val = 1 - y
                        SVCursor.Position = UDim2.new(x, -5, y, -5)
                        UpdateColor()
                    end
                end)
                
                -- Hue Slider interaction
                local hueDragging = false
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if hueDragging then
                        local pos = HueSlider.AbsolutePosition
                        local size = HueSlider.AbsoluteSize
                        local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                        hue = y
                        HueCursor.Position = UDim2.new(0, -2, y, -2)
                        UpdateColor()
                    end
                end)
                
                -- Hex input
                HexInput.FocusLost:Connect(function()
                    local hex = HexInput.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1, 2), 16)
                        local g = tonumber(hex:sub(3, 4), 16)
                        local b = tonumber(hex:sub(5, 6), 16)
                        if r and g and b then
                            local color = Color3.fromRGB(r, g, b)
                            hue, sat, val = color:ToHSV()
                            UpdateColor()
                        end
                    end
                end)
                
                -- Toggle picker
                ColorPreview.MouseButton1Click:Connect(function()
                    PickerPanel.Visible = not PickerPanel.Visible
                end)
                
                function ColorPicker:SetValue(color)
                    hue, sat, val = color:ToHSV()
                    UpdateColor()
                end
                
                function ColorPicker:GetValue()
                    return ColorPicker.Value
                end
                
                if cfg.Tooltip then
                    AddTooltip(Frame, cfg.Tooltip)
                end
                
                ConfigSys:RegisterElement(id, ColorPicker, defaultColor)
                
                table.insert(Section.Elements, ColorPicker)
                return ColorPicker
            end
            
            -- ========== KEYBIND ==========
            function Section:AddKeybind(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local id = cfg.Title or ("Keybind_" .. order)
                
                local Keybind = {Value = cfg.Default or Enum.KeyCode.Unknown}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 38),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Keybind",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local KeyBtn = Create("TextButton", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(1, -90, 0.5, -12),
                    Size = UDim2.new(0, 80, 0, 24),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Default and cfg.Default.Name or "None",
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(KeyBtn, 6)
                
                local listening = false
                
                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                    TweenService:Create(KeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary}):Play()
                    TweenService:Create(KeyBtn, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        Keybind.Value = input.KeyCode
                        KeyBtn.Text = input.KeyCode.Name
                        TweenService:Create(KeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Background}):Play()
                        TweenService:Create(KeyBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.Primary}):Play()
                        
                        if cfg.IsToggleKey then
                            Window.ToggleKey = input.KeyCode
                        end
                        
                        SafeCall(cfg.Callback, input.KeyCode)
                    end
                end)
                
                function Keybind:SetValue(key)
                    Keybind.Value = key
                    KeyBtn.Text = key.Name
                end
                
                function Keybind:GetValue()
                    return Keybind.Value
                end
                
                if cfg.Tooltip then
                    AddTooltip(Frame, cfg.Tooltip)
                end
                
                ConfigSys:RegisterElement(id, Keybind, cfg.Default)
                
                table.insert(Section.Elements, Keybind)
                return Keybind
            end
            
            -- ========== IMAGE ==========
            function Section:AddImage(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                
                local ImageFrame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, (cfg.Height or 100) + 10),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(ImageFrame, 8)
                
                local ImageLabel = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(1, -10, 1, -10),
                    Image = cfg.Image or "",
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = ImageFrame
                })
                
                if cfg.Rounded then
                    AddCorner(ImageLabel, 6)
                end
                
                table.insert(Section.Elements, {Frame = ImageFrame, Image = ImageLabel})
                return {Frame = ImageFrame, Image = ImageLabel}
            end
            
            -- ========== PARAGRAPH ==========
            function Section:AddParagraph(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                AddPadding(Frame, 10)
                Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Frame})
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Title",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 1,
                    Parent = Frame
                })
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham,
                    Text = cfg.Content or "Content",
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    LayoutOrder = 2,
                    Parent = Frame
                })
                
                table.insert(Section.Elements, {Frame = Frame})
                return {Frame = Frame}
            end
            
            -- ========== DROPDOWN ==========
            function Section:AddDropdown(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local id = cfg.Title or ("Dropdown_" .. order)
                local multi = cfg.Multi or false
                
                local Dropdown = {
                    Value = multi and {} or (cfg.Default or nil),
                    Items = cfg.Items or {}
                }
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 38),
                    LayoutOrder = order,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 10, 1, 5),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(DropBtn, 6)
                
                local BtnText = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = multi and "None" or (cfg.Default or "Select..."),
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropBtn
                })
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 15, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Colors.TextDark,
                    TextSize = 8,
                    Parent = DropBtn
                })
                
                Frame.Size = UDim2.new(1, 0, 0, 75)
                
                local DropList = Create("Frame", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 10, 0, 78),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50,
                    Parent = Frame
                })
                AddCorner(DropList, 6)
                AddStroke(DropList, Colors.Border, 1)
                
                -- Select All / Clear All for multi
                local ControlsFrame
                if multi then
                    ControlsFrame = Create("Frame", {
                        BackgroundColor3 = Colors.BackgroundDark,
                        Size = UDim2.new(1, 0, 0, 28),
                        ZIndex = 51,
                        Parent = DropList
                    })
                    
                    local SelectAllBtn = Create("TextButton", {
                        BackgroundColor3 = Colors.Success,
                        Position = UDim2.new(0, 5, 0, 4),
                        Size = UDim2.new(0.5, -8, 0, 20),
                        Font = Enum.Font.GothamBold,
                        Text = "Select All",
                        TextColor3 = Colors.Text,
                        TextSize = 9,
                        AutoButtonColor = false,
                        ZIndex = 52,
                        Parent = ControlsFrame
                    })
                    AddCorner(SelectAllBtn, 4)
                    
                    local ClearAllBtn = Create("TextButton", {
                        BackgroundColor3 = Colors.Error,
                        Position = UDim2.new(0.5, 3, 0, 4),
                        Size = UDim2.new(0.5, -8, 0, 20),
                        Font = Enum.Font.GothamBold,
                        Text = "Clear All",
                        TextColor3 = Colors.Text,
                        TextSize = 9,
                        AutoButtonColor = false,
                        ZIndex = 52,
                        Parent = ControlsFrame
                    })
                    AddCorner(ClearAllBtn, 4)
                    
                    SelectAllBtn.MouseButton1Click:Connect(function()
                        for item, _ in pairs(Dropdown.Value) do
                            Dropdown.Value[item] = true
                        end
                        for _, item in ipairs(Dropdown.Items) do
                            Dropdown.Value[item] = true
                        end
                        local count = 0
                        for _, v in pairs(Dropdown.Value) do if v then count = count + 1 end end
                        BtnText.Text = count .. " selected"
                        SafeCall(cfg.Callback, Dropdown.Value)
                    end)
                    
                    ClearAllBtn.MouseButton1Click:Connect(function()
                        for item, _ in pairs(Dropdown.Value) do
                            Dropdown.Value[item] = false
                        end
                        BtnText.Text = "None"
                        SafeCall(cfg.Callback, Dropdown.Value)
                    end)
                end
                
                local ListScroll = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, multi and 28 or 0),
                    Size = UDim2.new(1, 0, 1, multi and -28 or 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = CurrentTheme.Primary,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 51,
                    Parent = DropList
                })
                AddPadding(ListScroll, 5)
                Create("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ListScroll})
                
                local isOpen = false
                local itemBtns = {}
                
                local function createItem(itemText, idx)
                    local ItemBtn = Create("TextButton", {
                        BackgroundColor3 = Colors.BackgroundLight,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = idx,
                        ZIndex = 52,
                        Parent = ListScroll
                    })
                    AddCorner(ItemBtn, 4)
                    
                    if multi then
                        local check = Create("Frame", {
                            BackgroundColor3 = Colors.Background,
                            Position = UDim2.new(0, 5, 0.5, -8),
                            Size = UDim2.new(0, 16, 0, 16),
                            ZIndex = 53,
                            Parent = ItemBtn
                        })
                        AddCorner(check, 4)
                        
                        local checkMark = Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.GothamBold,
                            Text = "",
                            TextColor3 = Colors.Text,
                            TextSize = 12,
                            ZIndex = 54,
                            Parent = check
                        })
                        
                        Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 26, 0, 0),
                            Size = UDim2.new(1, -31, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = itemText,
                            TextColor3 = Colors.Text,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            ZIndex = 53,
                            Parent = ItemBtn
                        })
                        
                        ItemBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value[itemText] = not Dropdown.Value[itemText]
                            checkMark.Text = Dropdown.Value[itemText] and "✓" or ""
                            check.BackgroundColor3 = Dropdown.Value[itemText] and CurrentTheme.Primary or Colors.Background
                            
                            local count = 0
                            for _, v in pairs(Dropdown.Value) do if v then count = count + 1 end end
                            BtnText.Text = count > 0 and count .. " selected" or "None"
                            SafeCall(cfg.Callback, Dropdown.Value)
                        end)
                        
                        return {Btn = ItemBtn, Check = check, CheckMark = checkMark}
                    else
                        Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 10, 0, 0),
                            Size = UDim2.new(1, -20, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = itemText,
                            TextColor3 = Colors.Text,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 53,
                            Parent = ItemBtn
                        })
                        
                        ItemBtn.MouseEnter:Connect(function()
                            TweenService:Create(ItemBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                        end)
                        ItemBtn.MouseLeave:Connect(function()
                            TweenService:Create(ItemBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                        end)
                        
                        ItemBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value = itemText
                            BtnText.Text = itemText
                            isOpen = false
                            TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, 0)}):Play()
                            task.delay(0.2, function() DropList.Visible = false end)
                            SafeCall(cfg.Callback, itemText)
                        end)
                        
                        return {Btn = ItemBtn}
                    end
                end
                
                -- Create initial items
                for idx, item in ipairs(Dropdown.Items) do
                    itemBtns[item] = createItem(item, idx)
                    if multi then
                        Dropdown.Value[item] = false
                    end
                end
                
                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        DropList.Visible = true
                        local itemCount = #Dropdown.Items
                        local listHeight = math.min(itemCount * 29 + 10 + (multi and 28 or 0), 150)
                        TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, listHeight)}):Play()
                    else
                        TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, 0)}):Play()
                        task.delay(0.2, function() DropList.Visible = false end)
                    end
                end)
                
                function Dropdown:SetItems(newItems)
                    Dropdown.Items = newItems
                    for _, data in pairs(itemBtns) do
                        if data.Btn then data.Btn:Destroy() end
                    end
                    itemBtns = {}
                    for idx, item in ipairs(newItems) do
                        itemBtns[item] = createItem(item, idx)
                        if multi then
                            Dropdown.Value[item] = Dropdown.Value[item] or false
                        end
                    end
                end
                
                function Dropdown:SetValue(v)
                    Dropdown.Value = v
                    if multi then
                        local count = 0
                        for _, val in pairs(v) do if val then count = count + 1 end end
                        BtnText.Text = count > 0 and count .. " selected" or "None"
                    else
                        BtnText.Text = v or "Select..."
                    end
                end
                
                if cfg.Tooltip then
                    AddTooltip(Frame, cfg.Tooltip)
                end
                
                ConfigSys:RegisterElement(id, Dropdown, multi and {} or cfg.Default)
                Window.SearchableElements[id] = {Title = cfg.Title or "Dropdown", Tab = Tab, Element = Dropdown, Frame = Frame}
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- ========== TEXTBOX (Legacy) ==========
            function Section:AddTextBox(cfg)
                return Section:AddInput(cfg)
            end
            
            return Section
        end
        
        return Tab
    end
    -- ============================================
    -- MOBILE BUTTON
    -- ============================================
    local MobileBtn = Create("TextButton", {
        Name = "MobileToggle",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 15, 0.5, -25),
        Size = UDim2.new(0, 46, 0, 46),
        ZIndex = 999,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui
    })
    AddCorner(MobileBtn, 23)
    AddGradient(MobileBtn, {CurrentTheme.Primary, CurrentTheme.Secondary, CurrentTheme.Tertiary}, 135)
    AddShadow(MobileBtn, Color3.fromRGB(0, 0, 0), 8, 0.4)
    
    if logoImage then
        Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.55, 0, 0.55, 0),
            Position = UDim2.new(0.225, 0, 0.225, 0),
            ZIndex = 1000,
            Image = logoImage,
            ImageColor3 = Colors.Text,
            ScaleType = Enum.ScaleType.Fit,
            Parent = MobileBtn
        })
    else
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1000,
            Font = Enum.Font.GothamBlack,
            Text = "E",
            TextColor3 = Colors.Text,
            TextSize = 18,
            Parent = MobileBtn
        })
    end
    
    MakeDraggable(MobileBtn, MobileBtn)
    
    MobileBtn.MouseButton1Click:Connect(function()
        if Window.Minimized then
            Window:Restore()
        else
            Window:Toggle()
        end
    end)
    
    if updateURL then
        task.delay(2, function()
            SafeCall(function()
                local response = game:HttpGet(updateURL)
                local data = HttpService:JSONDecode(response)
                if data and data.version and data.version ~= scriptVersion then
                    Window:Notify({
                        Title = "🔄 Update Available!",
                        Content = "New version " .. data.version .. " is available!",
                        Type = "Info",
                        Duration = 8
                    })
                end
            end)
        end)
    end
    
    if getgenv then getgenv().EnzoUILib = Window end
    
    return Window
end

-- ============================================
-- LIBRARY INFO
-- ============================================
EnzoLib.Version = "2.4.2"
EnzoLib.Author = "ENZO-YT"
EnzoLib.Design = "G - Aurora Ethereal v2.4.2"
EnzoLib.Themes = Themes
EnzoLib.Colors = Colors

return EnzoLib