--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ENZO UI LIBRARY                           ║
    ║           Design G: Aurora Ethereal v2.3                     ║
    ║                  Author: ENZO-YT                             ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  v2.3 FIXES:                                                 ║
    ║  ✅ Search in Dropdown                                       ║
    ║  ✅ LayoutOrder for all elements                             ║
    ║  ✅ Opacity properly shows theme at 100%                     ║
    ║  ✅ Title size reduced                                       ║
    ║  ✅ TrayIcon removed                                         ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local EnzoLib = {}
EnzoLib.__index = EnzoLib

-- ============================================
-- ANTI-DETECTION: Random Naming
-- ============================================
local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local idx = math.random(1, #chars)
        result = result .. chars:sub(idx, idx)
    end
    return result
end

local UNIQUE_ID = RandomString(8)
local GUI_NAME = "G_" .. UNIQUE_ID
local BLUR_NAME = "B_" .. UNIQUE_ID

-- ============================================
-- SERVICES
-- ============================================
local Services = setmetatable({}, {
    __index = function(self, service)
        local s = game:GetService(service)
        rawset(self, service, s)
        return s
    end
})

local Players = Services.Players
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local CoreGui = Services.CoreGui
local Lighting = Services.Lighting
local RunService = Services.RunService
local HttpService = Services.HttpService
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- ERROR HANDLING
-- ============================================
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[ENZO UI] Error: " .. tostring(result))
    end
    return success, result
end

-- ============================================
-- SAFE CLEANUP
-- ============================================
SafeCall(function()
    if getgenv and getgenv().EnzoUILib then
        getgenv().EnzoUILib:Destroy()
    end
end)

SafeCall(function()
    for _, v in pairs(Lighting:GetChildren()) do
        if v.Name:find("B_") then v:Destroy() end
    end
end)

SafeCall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("G_") then v:Destroy() end
    end
end)

-- ============================================
-- THEMES
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
    Background = Color3.fromRGB(15, 15, 25),
    BackgroundDark = Color3.fromRGB(10, 10, 18),
    BackgroundLight = Color3.fromRGB(25, 25, 40),
    
    Card = Color3.fromRGB(22, 22, 35),
    CardHover = Color3.fromRGB(30, 30, 45),
    CardBorder = Color3.fromRGB(45, 45, 65),
    
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 150),
    TextDark = Color3.fromRGB(80, 80, 110),
    
    Success = Color3.fromRGB(80, 250, 150),
    Error = Color3.fromRGB(255, 80, 100),
    Warning = Color3.fromRGB(255, 200, 80),
    Info = Color3.fromRGB(80, 180, 255),
    
    Favorite = Color3.fromRGB(255, 215, 0),
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            SafeCall(function() inst[k] = v end)
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
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

-- ============================================
-- CONFIG SYSTEM
-- ============================================
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new(folderName)
    local self = setmetatable({}, ConfigSystem)
    self.FolderName = folderName or "EnzoUIConfigs"
    self.CurrentProfile = "Default"
    self.Elements = {}
    self.Favorites = {}
    self.Keybinds = {}
    
    SafeCall(function()
        if isfolder and not isfolder(self.FolderName) then
            makefolder(self.FolderName)
        end
    end)
    
    return self
end

function ConfigSystem:RegisterElement(id, element, default)
    self.Elements[id] = {
        Element = element,
        Default = default,
        Value = default
    }
end

function ConfigSystem:GetConfigPath(name)
    return self.FolderName .. "/" .. self.CurrentProfile .. "_" .. name .. ".json"
end

function ConfigSystem:Save(name)
    local data = {
        Settings = {},
        Favorites = self.Favorites,
        Keybinds = self.Keybinds
    }
    
    for id, info in pairs(self.Elements) do
        data.Settings[id] = info.Value
    end
    
    local success = SafeCall(function()
        if writefile then
            writefile(self:GetConfigPath(name), HttpService:JSONEncode(data))
        end
    end)
    
    return success
end

function ConfigSystem:Load(name)
    local success = SafeCall(function()
        if readfile and isfile and isfile(self:GetConfigPath(name)) then
            local data = HttpService:JSONDecode(readfile(self:GetConfigPath(name)))
            
            if data.Settings then
                for id, value in pairs(data.Settings) do
                    if self.Elements[id] then
                        self.Elements[id].Value = value
                        local element = self.Elements[id].Element
                        if element and element.SetValue then
                            element:SetValue(value)
                        end
                    end
                end
            end
            
            if data.Favorites then
                self.Favorites = data.Favorites
            end
            
            if data.Keybinds then
                self.Keybinds = data.Keybinds
            end
            
            return true
        end
        return false
    end)
    
    return success
end

function ConfigSystem:ToggleFavorite(id)
    self.Favorites[id] = not self.Favorites[id]
    return self.Favorites[id]
end

function ConfigSystem:IsFavorite(id)
    return self.Favorites[id] == true
end

function ConfigSystem:RegisterKeybind(id, key, callback)
    self.Keybinds[id] = {
        Key = key.Name,
        Callback = callback
    }
end
-- ============================================
-- MAIN LIBRARY - CREATE WINDOW
-- ============================================
function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "Aurora Ethereal"
    local logoImage = config.Logo or nil
    local baseSize = config.Size or UDim2.new(0, 700, 0, 450)
    local expandedSize = UDim2.new(0, 900, 0, 550)
    local configFolder = config.ConfigFolder or "EnzoUI_" .. game.PlaceId
    local scriptVersion = config.Version or "1.0.0"
    local updateURL = config.UpdateURL or nil
    
    if config.Theme and Themes[config.Theme] then
        CurrentTheme = Themes[config.Theme]
    end
    
    local ConfigSys = ConfigSystem.new(configFolder)
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Minimized = false,
        Expanded = false,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
        Theme = CurrentTheme,
        ThemeObjects = {},
        Connections = {},
        Threads = {},
        ConfigSystem = ConfigSys,
        Scale = config.Scale or 1,
        StartTime = os.time(),
        SearchableElements = {},
        Version = scriptVersion,
        BaseSize = baseSize,
        ExpandedSize = expandedSize,
    }
    
    local currentScale = Window.Scale
    local currentOpacity = 1
    
    -- ============================================
    -- SCREENGUI
    -- ============================================
    local ScreenGui = Create("ScreenGui", {
        Name = GUI_NAME,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    SafeCall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    Window.ScreenGui = ScreenGui
    
    local ScaleContainer = Create("Frame", {
        Name = "ScaleContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = ScreenGui
    })
    
    local UIScale = Create("UIScale", {
        Scale = currentScale,
        Parent = ScaleContainer
    })
    
    local Blur = Create("BlurEffect", {
        Name = BLUR_NAME,
        Size = config.Blur ~= false and 12 or 0,
        Parent = Lighting
    })
    
    -- ============================================
    -- WATERMARK
    -- ============================================
    local Watermark = Create("Frame", {
        Name = "Watermark",
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 0, 0, 26),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = config.Watermark ~= false,
        ZIndex = 999,
        Parent = ScreenGui
    })
    AddCorner(Watermark, 6)
    AddStroke(Watermark, CurrentTheme.Primary, 1, 0.5)
    AddPadding(Watermark, 4, 4, 10, 10)
    
    local WatermarkText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = title .. " | FPS: -- | Ping: -- | 00:00:00",
        TextColor3 = Colors.Text,
        TextSize = 11,
        ZIndex = 1000,
        Parent = Watermark
    })
    
    MakeDraggable(Watermark, Watermark)
    
    table.insert(Window.Threads, task.spawn(function()
        while true do
            SafeCall(function()
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                local elapsed = os.time() - Window.StartTime
                local hours = math.floor(elapsed / 3600)
                local mins = math.floor((elapsed % 3600) / 60)
                local secs = elapsed % 60
                local timeStr = string.format("%02d:%02d:%02d", hours, mins, secs)
                WatermarkText.Text = string.format("%s | FPS: %d | Ping: %dms | ⏱️ %s", title, fps, ping, timeStr)
            end)
            task.wait(0.5)
        end
    end))
    
    -- ============================================
    -- MAIN FRAME (with proper initial transparency for theme visibility)
    -- ============================================
    local Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0.5, -baseSize.X.Offset/2, 0.5, -baseSize.Y.Offset/2),
        Size = baseSize,
        Parent = ScaleContainer
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
        Name = "BorderGradient",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = BorderFrame
    })
    AddCorner(BorderGradient, 18)
    local auroraGradient = AddGradient(BorderGradient, {CurrentTheme.Primary, CurrentTheme.Secondary, CurrentTheme.Tertiary, CurrentTheme.Primary}, 0)
    table.insert(Window.ThemeObjects, {Type = "AuroraGradient", Gradient = auroraGradient})
    
    table.insert(Window.Threads, task.spawn(function()
        local rotation = 0
        while true do
            rotation = (rotation + 1) % 360
            SafeCall(function()
                auroraGradient.Rotation = rotation
            end)
            task.wait(0.03)
        end
    end))
    
    local InnerMask = Create("Frame", {
        Name = "InnerMask",
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
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
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 10,
        Parent = Main
    })
    AddCorner(Header, 16)
    
    Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 9,
        Parent = Header
    })
    
    -- Logo Container
    local LogoContainer = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 12, 0.5, -18),
        Size = UDim2.new(0, 36, 0, 36),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(LogoContainer, 10)
    AddGradient(LogoContainer, {CurrentTheme.Primary, CurrentTheme.Secondary}, 135)
    AddGlow(LogoContainer, CurrentTheme.Primary, 10, 0.6)
    table.insert(Window.ThemeObjects, {Object = LogoContainer, Property = "BackgroundColor3", Key = "Primary"})
    
    if logoImage then
        Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.65, 0, 0.65, 0),
            Position = UDim2.new(0.175, 0, 0.175, 0),
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
            TextSize = 18,
            Parent = LogoContainer
        })
    end
    
    -- Title (SMALLER SIZE)
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 56, 0, 12),
        Size = UDim2.new(0, 160, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamBlack,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Header
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 56, 0, 30),
        Size = UDim2.new(0, 160, 0, 12),
        ZIndex = 11,
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Colors.TextMuted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- ============================================
    -- TAB CONTAINER
    -- ============================================
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 280, 0, 30),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(TabContainer, 15)
    
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
        Padding = UDim.new(0, 4),
        Parent = TabList
    })
    AddPadding(TabList, 3, 3, 5, 5)
    
    local TabIndicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 5, 0.5, -12),
        Size = UDim2.new(0, 50, 0, 24),
        ZIndex = 11,
        Parent = TabContainer
    })
    AddCorner(TabIndicator, 12)
    AddGradient(TabIndicator, {CurrentTheme.Primary, CurrentTheme.Secondary}, 90)
    AddGlow(TabIndicator, CurrentTheme.Primary, 6, 0.7)
    
    -- ============================================
    -- CONTROLS (Search + Buttons)
    -- ============================================
    local Controls = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -130, 0.5, -13),
        Size = UDim2.new(0, 120, 0, 26),
        ZIndex = 11,
        Parent = Header
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        Parent = Controls
    })
    
    -- Search Button
    local SearchBtn = Create("TextButton", {
        BackgroundColor3 = Colors.BackgroundLight,
        Size = UDim2.new(0, 24, 0, 24),
        ZIndex = 12,
        Font = Enum.Font.GothamBold,
        Text = "🔍",
        TextSize = 11,
        AutoButtonColor = false,
        LayoutOrder = 1,
        Parent = Controls
    })
    AddCorner(SearchBtn, 6)
    
    -- Search Popup
    local SearchPopup = Create("Frame", {
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(1, -250, 0, 65),
        Size = UDim2.new(0, 240, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
        Parent = Main
    })
    AddCorner(SearchPopup, 8)
    AddStroke(SearchPopup, CurrentTheme.Primary, 1, 0.5)
    AddShadow(SearchPopup, Color3.fromRGB(0, 0, 0), 10, 0.5)
    
    local SearchIcon = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 7),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = 101,
        Text = "🔍",
        TextSize = 12,
        Parent = SearchPopup
    })
    
    local SearchBox = Create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 5),
        Size = UDim2.new(1, -65, 0, 24),
        ZIndex = 101,
        Font = Enum.Font.GothamMedium,
        Text = "",
        PlaceholderText = "Search features...",
        PlaceholderColor3 = Colors.TextDark,
        TextColor3 = Colors.Text,
        TextSize = 11,
        ClearTextOnFocus = false,
        Parent = SearchPopup
    })
    
    local SearchCloseBtn = Create("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -28, 0, 7),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = 101,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Colors.TextMuted,
        TextSize = 16,
        Parent = SearchPopup
    })
    
    local SearchResults = Create("Frame", {
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        ClipsDescendants = true,
        ZIndex = 102,
        Parent = SearchPopup
    })
    
    local SearchResultsList = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 103,
        Parent = SearchResults
    })
    AddPadding(SearchResultsList, 4)
    Create("UIListLayout", {Padding = UDim.new(0, 3), Parent = SearchResultsList})
    
    local searchOpen = false
    
    local function OpenSearch()
        searchOpen = true
        SearchPopup.Visible = true
        Tween(SearchPopup, {Size = UDim2.new(0, 240, 0, 200)}, 0.25, Enum.EasingStyle.Back)
        task.delay(0.25, function()
            SearchBox:CaptureFocus()
        end)
    end
    
    local function CloseSearch()
        searchOpen = false
        SearchBox.Text = ""
        Tween(SearchPopup, {Size = UDim2.new(0, 240, 0, 0)}, 0.2)
        task.delay(0.2, function()
            SearchPopup.Visible = false
        end)
    end
    
    SearchBtn.MouseButton1Click:Connect(function()
        if searchOpen then CloseSearch() else OpenSearch() end
    end)
    
    SearchCloseBtn.MouseButton1Click:Connect(CloseSearch)
    
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        
        for _, child in pairs(SearchResultsList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        if query == "" then return end
        
        local results = {}
        for id, info in pairs(Window.SearchableElements) do
            local titleLower = (info.Title or ""):lower()
            if titleLower:find(query, 1, true) then
                table.insert(results, {Id = id, Info = info})
            end
        end
        
        if #results > 0 then
            for _, result in ipairs(results) do
                local info = result.Info
                local btn = Create("TextButton", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, -8, 0, 24),
                    ZIndex = 104,
                    Font = Enum.Font.GothamMedium,
                    Text = "  📌 " .. (info.Title or "Unknown"),
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = SearchResultsList
                })
                AddCorner(btn, 4)
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundColor3 = CurrentTheme.Primary, BackgroundTransparency = 0.7}, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundColor3 = Colors.BackgroundLight, BackgroundTransparency = 0.3}, 0.15)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    if info.Tab then Window:SelectTab(info.Tab) end
                    if info.Frame then
                        local originalColor = info.Frame.BackgroundColor3
                        for i = 1, 3 do
                            Tween(info.Frame, {BackgroundColor3 = CurrentTheme.Primary}, 0.15)
                            task.wait(0.15)
                            Tween(info.Frame, {BackgroundColor3 = originalColor}, 0.15)
                            task.wait(0.15)
                        end
                    end
                    CloseSearch()
                end)
            end
        else
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 24),
                ZIndex = 104,
                Font = Enum.Font.GothamMedium,
                Text = "  No results found",
                TextColor3 = Colors.TextMuted,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SearchResultsList
            })
        end
    end)
    
    -- Control Buttons
    local function CreateControlBtn(icon, color, callback, layoutOrder)
        local btn = Create("TextButton", {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.85,
            Size = UDim2.new(0, 24, 0, 24),
            ZIndex = 12,
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = color,
            TextSize = 11,
            AutoButtonColor = false,
            LayoutOrder = layoutOrder,
            Parent = Controls
        })
        AddCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.5}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.85}, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    CreateControlBtn("−", Colors.Warning, function() Window:Minimize() end, 2)
    local ExpandBtn = CreateControlBtn("□", Colors.Info, function() Window:ToggleExpand() end, 3)
    CreateControlBtn("×", Colors.Error, function() Window:Destroy() end, 4)
    
    MakeDraggable(Main, Header)
    
    -- ============================================
    -- CONTENT CONTAINER
    -- ============================================
    local ContentContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 68),
        Size = UDim2.new(1, -24, 1, -120),
        ZIndex = 3,
        Parent = Main
    })
    
    -- ============================================
    -- FOOTER
    -- ============================================
    local Footer = Create("Frame", {
        Name = "Footer",
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 12, 1, -48),
        Size = UDim2.new(1, -24, 0, 40),
        ZIndex = 10,
        Parent = Main
    })
    AddCorner(Footer, 10)
    
    -- Theme Selector
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -7),
        Size = UDim2.new(0, 40, 0, 14),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "Theme",
        TextColor3 = Colors.TextMuted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local ThemeContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0.5, -8),
        Size = UDim2.new(0, 110, 0, 16),
        ZIndex = 11,
        Parent = Footer
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = ThemeContainer
    })
    
    local themeButtons = {}
    for name, theme in pairs(Themes) do
        local themeBtn = Create("TextButton", {
            Name = name,
            BackgroundColor3 = theme.Primary,
            Size = UDim2.new(0, 14, 0, 14),
            ZIndex = 12,
            Text = "",
            AutoButtonColor = false,
            Parent = ThemeContainer
        })
        AddCorner(themeBtn, 7)
        AddGradient(themeBtn, {theme.Primary, theme.Secondary}, 135)
        
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
    
    -- ============================================
    -- OPACITY SLIDER (FIXED - Theme visible at 100%)
    -- ============================================
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 175, 0.5, -7),
        Size = UDim2.new(0, 45, 0, 14),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "Opacity",
        TextColor3 = Colors.TextMuted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local OpacityTrack = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 225, 0.5, -4),
        Size = UDim2.new(0, 60, 0, 8),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(OpacityTrack, 4)
    
    local OpacityFill = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12,
        Parent = OpacityTrack
    })
    AddCorner(OpacityFill, 4)
    AddGradient(OpacityFill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 0)
    
    local OpacityKnob = Create("Frame", {
        BackgroundColor3 = Colors.Text,
        Position = UDim2.new(1, -5, 0.5, -5),
        Size = UDim2.new(0, 10, 0, 10),
        ZIndex = 13,
        Parent = OpacityTrack
    })
    AddCorner(OpacityKnob, 5)
    
    local OpacityLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 290, 0.5, -7),
        Size = UDim2.new(0, 30, 0, 14),
        ZIndex = 11,
        Font = Enum.Font.GothamBold,
        Text = "100%",
        TextColor3 = CurrentTheme.Primary,
        TextSize = 9,
        Parent = Footer
    })
    
    -- FIXED Opacity Function
    local function UpdateOpacity(pos)
        currentOpacity = pos
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -5, 0.5, -5)
        OpacityLabel.Text = math.floor(pos * 100) .. "%"
        
        -- pos = 1 (100%): Theme visible, slight transparency
        -- pos = 0 (0%): Almost fully transparent
        
        -- Main & InnerMask: 100% = 0.05, 0% = 0.95
        local mainTrans = 0.05 + (1 - pos) * 0.9
        Main.BackgroundTransparency = mainTrans
        InnerMask.BackgroundTransparency = mainTrans
        
        -- Border: Always visible at 100%, fade at lower
        BorderGradient.BackgroundTransparency = (1 - pos) * 0.9
        
        -- Header & Footer
        local headerTrans = 0.2 + (1 - pos) * 0.75
        Header.BackgroundTransparency = headerTrans
        Footer.BackgroundTransparency = headerTrans
        
        -- Tab container
        TabContainer.BackgroundTransparency = 0.1 + (1 - pos) * 0.85
        
        -- Section cards
        for _, tab in pairs(Window.Tabs) do
            for _, section in pairs(tab.Sections or {}) do
                if section.Card then
                    section.Card.BackgroundTransparency = 0.05 + (1 - pos) * 0.9
                end
            end
        end
    end
    
    local opacityDragging = false
    
    OpacityTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = true
            local pos = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X, 0, 1)
            UpdateOpacity(pos)
        end
    end)
    
    OpacityKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = true
        end
    end)
    
    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X, 0, 1)
            UpdateOpacity(pos)
        end
    end))
    
    table.insert(Window.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = false
        end
    end))
    
    -- Toggle Key Badge
    local ToggleBadge = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(1, -85, 0.5, -11),
        Size = UDim2.new(0, 75, 0, 22),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(ToggleBadge, 6)
    
    local ToggleBadgeText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12,
        Font = Enum.Font.GothamBold,
        Text = "🎮 " .. Window.ToggleKey.Name,
        TextColor3 = CurrentTheme.Primary,
        TextSize = 9,
        Parent = ToggleBadge
    })
    
    -- ============================================
    -- UI SCALE CORNER
    -- ============================================
    local ScaleHandle = Create("TextButton", {
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(1, -22, 1, -22),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = 100,
        Text = "↘",
        TextColor3 = Colors.Text,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = Main
    })
    AddCorner(ScaleHandle, 6)
    AddGradient(ScaleHandle, {CurrentTheme.Primary, CurrentTheme.Secondary}, 135)
    
    local scaleDragging = false
    local scaleStartPos, scaleStartScale
    
    ScaleHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaleDragging = true
            scaleStartPos = input.Position
            scaleStartScale = currentScale
        end
    end)
    
    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if scaleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = (input.Position.X - scaleStartPos.X) + (input.Position.Y - scaleStartPos.Y)
            local newScale = math.clamp(scaleStartScale + delta * 0.002, 0.5, 1.5)
            currentScale = newScale
            UIScale.Scale = newScale
        end
    end))
    
    table.insert(Window.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaleDragging = false
        end
    end))
    
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
            local targetSize = self.Expanded and expandedSize or baseSize
            Main.Size = UDim2.new(0, targetSize.X.Offset, 0, 0)
            
            Tween(Main, {Size = targetSize}, 0.5, Enum.EasingStyle.Back)
            Tween(Blur, {Size = 12}, 0.3)
        else
            local currentSize = Main.Size
            Tween(Main, {Size = UDim2.new(0, currentSize.X.Offset, 0, 0)}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            
            task.delay(0.3, function()
                if not self.Visible then Main.Visible = false end
            end)
        end
    end
    
    function Window:ToggleExpand()
        self.Expanded = not self.Expanded
        local targetSize = self.Expanded and expandedSize or baseSize
        local newPos = UDim2.new(0.5, -targetSize.X.Offset/2, 0.5, -targetSize.Y.Offset/2)
        
        Tween(Main, {Size = targetSize, Position = newPos}, 0.4, Enum.EasingStyle.Back)
        ExpandBtn.Text = self.Expanded and "❐" or "□"
    end
    
    function Window:Minimize()
        self.Minimized = true
        self.Visible = false
        
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        Tween(Blur, {Size = 0}, 0.3)
        
        task.delay(0.3, function()
            Main.Visible = false
        end)
    end
    
    function Window:Restore()
        self.Minimized = false
        self.Visible = true
        
        Main.Visible = true
        local targetSize = self.Expanded and expandedSize or baseSize
        Main.Size = UDim2.new(0, targetSize.X.Offset, 0, 0)
        
        Tween(Main, {Size = targetSize}, 0.5, Enum.EasingStyle.Back)
        Tween(Blur, {Size = 12}, 0.3)
    end
    
    function Window:Destroy()
        for _, connection in pairs(self.Connections) do
            SafeCall(function() connection:Disconnect() end)
        end
        for _, thread in pairs(self.Threads) do
            SafeCall(function() task.cancel(thread) end)
        end
        
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.4)
        Tween(Blur, {Size = 0}, 0.3)
        Tween(Watermark, {BackgroundTransparency = 1}, 0.3)
        
        task.delay(0.4, function()
            SafeCall(function() ScreenGui:Destroy() end)
            SafeCall(function() Blur:Destroy() end)
        end)
        
        if getgenv then getgenv().EnzoUILib = nil end
    end
    
    function Window:SetTheme(themeName)
        if Themes[themeName] then
            CurrentTheme = Themes[themeName]
            Window.Theme = CurrentTheme
            
            for _, obj in pairs(Window.ThemeObjects) do
                SafeCall(function()
                    if obj.Type == "AuroraGradient" and obj.Gradient then
                        obj.Gradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, CurrentTheme.Primary),
                            ColorSequenceKeypoint.new(0.33, CurrentTheme.Secondary),
                            ColorSequenceKeypoint.new(0.66, CurrentTheme.Tertiary),
                            ColorSequenceKeypoint.new(1, CurrentTheme.Primary)
                        })
                    elseif obj.Object and obj.Property and obj.Key then
                        Tween(obj.Object, {[obj.Property] = CurrentTheme[obj.Key]}, 0.3)
                    end
                end)
            end
        end
    end
    
    function Window:SetToggleKey(key)
        Window.ToggleKey = key
        ToggleBadgeText.Text = "🎮 " .. key.Name
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Content.Visible = false
            Tween(Window.CurrentTab.TextLabel, {TextColor3 = Colors.TextMuted}, 0.2)
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        
        task.defer(function()
            local btnPos = tab.Button.AbsolutePosition
            local containerPos = TabContainer.AbsolutePosition
            local relativeX = btnPos.X - containerPos.X
            
            Tween(TabIndicator, {
                Position = UDim2.new(0, relativeX, 0.5, -12),
                Size = UDim2.new(0, tab.Button.AbsoluteSize.X, 0, 24)
            }, 0.3, Enum.EasingStyle.Back)
        end)
        
        Tween(tab.TextLabel, {TextColor3 = Colors.Text}, 0.2)
        
        if tab.Badge > 0 then tab:SetBadge(0) end
    end
    
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
                Position = UDim2.new(1, -320, 0, 50),
                Size = UDim2.new(0, 300, 0, 0),
                ZIndex = 1000,
                Parent = ScreenGui
            })
            Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = Container})
        end
        
        local Notif = Create("Frame", {
            BackgroundColor3 = Colors.Card,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 1001,
            Parent = Container
        })
        AddCorner(Notif, 10)
        AddStroke(Notif, data.col, 1.5, 0.3)
        
        Create("Frame", {
            BackgroundColor3 = data.col,
            Size = UDim2.new(0, 4, 1, 0),
            ZIndex = 1002,
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(0, 20, 0, 20),
            ZIndex = 1003,
            Text = data.icon,
            TextSize = 16,
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 8),
            Size = UDim2.new(1, -55, 0, 16),
            ZIndex = 1003,
            Font = Enum.Font.GothamBlack,
            Text = cfg.Title or "Notification",
            TextColor3 = Colors.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif
        })
        
        local ContentLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 26),
            Size = UDim2.new(1, -55, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 1003,
            Font = Enum.Font.Gotham,
            Text = cfg.Content or "",
            TextColor3 = Colors.TextSecondary,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notif
        })
        
        local Progress = Create("Frame", {
            BackgroundColor3 = data.col,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            ZIndex = 1003,
            Parent = Notif
        })
        AddCorner(Progress, 2)
        
        table.insert(Window.Threads, task.spawn(function()
            task.wait(0.05)
            local height = 48 + ContentLabel.TextBounds.Y
            Notif.Position = UDim2.new(1, 20, 0, 0)
            Notif.Size = UDim2.new(1, 0, 0, height)
            Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
            Tween(Progress, {Size = UDim2.new(0, 0, 0, 3)}, cfg.Duration or 4, Enum.EasingStyle.Linear)
            task.wait(cfg.Duration or 4)
            Tween(Notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.delay(0.3, function() SafeCall(function() Notif:Destroy() end) end)
        end))
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
            Sections = {},
            Badge = 0
        }
        
        local TabButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 24),
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
            Text = " " .. tabIcon .. " " .. tabName .. " ",
            TextColor3 = Colors.TextMuted,
            TextSize = 10,
            Parent = TabButton
        })
        
        local TabBadge = Create("Frame", {
            BackgroundColor3 = Colors.Error,
            Position = UDim2.new(1, -6, 0, 2),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 15,
            Visible = false,
            Parent = TabButton
        })
        AddCorner(TabBadge, 5)
        
        local TabContent = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Primary,
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
        Tab.TextLabel = TabText
        Tab.Content = TabContent
        
        function Tab:SetBadge(count)
            Tab.Badge = count
            if count > 0 then
                TabBadge.Visible = true
                Tween(TabBadge, {Size = UDim2.new(0, 10, 0, 10)}, 0.2, Enum.EasingStyle.Back)
            else
                Tween(TabBadge, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
                task.delay(0.2, function() TabBadge.Visible = false end)
            end
        end
        
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
            task.defer(function() Window:SelectTab(Tab) end)
        end
        
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
                Elements = {},
                ElementCount = 0
            }
            
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
                Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = column})
            end
            
            local SectionCard = Create("Frame", {
                Name = "SectionCard",
                BackgroundColor3 = Colors.Card,
                BackgroundTransparency = 0.05,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            AddCorner(SectionCard, 12)
            AddStroke(SectionCard, Colors.CardBorder, 1, 0.5)
            AddShadow(SectionCard, Color3.fromRGB(0, 0, 0), 12, 0.3)
            
            Section.Card = SectionCard
            
            local SectionHeader = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Parent = SectionCard
            })
            
            local IconBG = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                Position = UDim2.new(0, 10, 0.5, -12),
                Size = UDim2.new(0, 24, 0, 24),
                Parent = SectionHeader
            })
            AddCorner(IconBG, 6)
            AddGradient(IconBG, {CurrentTheme.Primary, CurrentTheme.Secondary}, 135)
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = Colors.Text,
                TextSize = 12,
                Parent = IconBG
            })
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 42, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.GothamBlack,
                Text = sectionName:upper(),
                TextColor3 = Colors.Text,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            local Divider = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                Position = UDim2.new(0, 10, 0, 38),
                Size = UDim2.new(1, -20, 0, 2),
                Parent = SectionCard
            })
            AddCorner(Divider, 1)
            AddGradient(Divider, {CurrentTheme.Primary, CurrentTheme.Secondary, Colors.Card}, 0)
            
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 44),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionCard
            })
            AddPadding(SectionContent, 4, 10, 10, 10)
            Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            Section.Content = SectionContent
            table.insert(Tab.Sections, Section)
            
            -- Helper for LayoutOrder
            local function GetNextOrder()
                Section.ElementCount = Section.ElementCount + 1
                return Section.ElementCount
            end
            
            -- ========== LABEL ==========
            function Section:AddLabel(text)
                local Label = {}
                local order = GetNextOrder()
                
                local LabelFrame = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                Label.Frame = LabelFrame
                function Label:SetText(t) LabelFrame.Text = t end
                
                table.insert(Section.Elements, Label)
                return Label
            end
            
            -- ========== TOGGLE ==========
            function Section:AddToggle(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Toggle"))
                local Toggle = {Value = cfg.Default or false, Id = id}
                local order = GetNextOrder()
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 44 or 34),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                Toggle.Frame = Frame
                
                local FavBtn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = ConfigSys:IsFavorite(id) and "⭐" or "☆",
                    TextColor3 = ConfigSys:IsFavorite(id) and Colors.Favorite or Colors.TextDark,
                    TextSize = 10,
                    Parent = Frame
                })
                
                FavBtn.MouseButton1Click:Connect(function()
                    local isFav = ConfigSys:ToggleFavorite(id)
                    FavBtn.Text = isFav and "⭐" or "☆"
                    FavBtn.TextColor3 = isFav and Colors.Favorite or Colors.TextDark
                end)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 26, 0, cfg.Description and 5 or 0),
                    Size = UDim2.new(1, -80, 0, cfg.Description and 14 or 34),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 26, 0, 20),
                        Size = UDim2.new(1, -80, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 8,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Switch = Create("Frame", {
                    BackgroundColor3 = Toggle.Value and CurrentTheme.Primary or Colors.BackgroundDark,
                    Position = UDim2.new(1, -48, 0.5, -9),
                    Size = UDim2.new(0, 38, 0, 18),
                    Parent = Frame
                })
                AddCorner(Switch, 9)
                
                local Knob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = Toggle.Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 2,
                    Parent = Switch
                })
                AddCorner(Knob, 7)
                
                local ClickArea = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Frame
                })
                
                ClickArea.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    
                    if Toggle.Value then
                        Tween(Switch, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                        Tween(Knob, {Position = UDim2.new(1, -16, 0.5, -7)}, 0.2, Enum.EasingStyle.Back)
                    else
                        Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.2)
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.2, Enum.EasingStyle.Back)
                    end
                    
                    if ConfigSys.Elements[id] then ConfigSys.Elements[id].Value = Toggle.Value end
                    if cfg.Callback then cfg.Callback(Toggle.Value) end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15) end)
                
                function Toggle:SetValue(v)
                    Toggle.Value = v
                    if v then
                        Tween(Switch, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                        Tween(Knob, {Position = UDim2.new(1, -16, 0.5, -7)}, 0.2)
                    else
                        Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.2)
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.2)
                    end
                    if cfg.Callback then cfg.Callback(v) end
                end
                
                ConfigSys:RegisterElement(id, Toggle, cfg.Default or false)
                Window.SearchableElements[id] = {Title = cfg.Title or "Toggle", Tab = Tab, Element = Toggle, Frame = Frame}
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- ========== SLIDER ==========
            function Section:AddSlider(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Slider"))
                local min, max = cfg.Min or 0, cfg.Max or 100
                local Slider = {Value = cfg.Default or min, Id = id}
                local order = GetNextOrder()
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 50 or 42),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                Slider.Frame = Frame
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 4),
                    Size = UDim2.new(1, -55, 0, 12),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -45, 0, 4),
                    Size = UDim2.new(0, 38, 0, 12),
                    Font = Enum.Font.GothamBlack,
                    Text = tostring(Slider.Value) .. (cfg.Suffix or ""),
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 16),
                        Size = UDim2.new(1, -20, 0, 10),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 8,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Track = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundDark,
                    Position = UDim2.new(0, 10, 1, -14),
                    Size = UDim2.new(1, -20, 0, 6),
                    Parent = Frame
                })
                AddCorner(Track, 3)
                
                local pct = (Slider.Value - min) / (max - min)
                
                local Fill = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    Size = UDim2.new(pct, 0, 1, 0),
                    Parent = Track
                })
                AddCorner(Fill, 3)
                AddGradient(Fill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 0)
                
                local SliderKnob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(pct, -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 2,
                    Parent = Track
                })
                AddCorner(SliderKnob, 6)
                AddStroke(SliderKnob, CurrentTheme.Primary, 2, 0)
                
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos + 0.5)
                    Slider.Value = val
                    local displayPos = (val - min) / (max - min)
                    Fill.Size = UDim2.new(displayPos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(displayPos, -6, 0.5, -6)
                    ValueLabel.Text = tostring(val) .. (cfg.Suffix or "")
                    
                    if ConfigSys.Elements[id] then ConfigSys.Elements[id].Value = val end
                    if cfg.Callback then cfg.Callback(val) end
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                    end
                end)
                
                table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end))
                
                table.insert(Window.Connections, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end))
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15) end)
                
                function Slider:SetValue(v)
                    Slider.Value = v
                    local pos = (v - min) / (max - min)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                    ValueLabel.Text = tostring(v) .. (cfg.Suffix or "")
                    if cfg.Callback then cfg.Callback(v) end
                end
                
                ConfigSys:RegisterElement(id, Slider, cfg.Default or min)
                Window.SearchableElements[id] = {Title = cfg.Title or "Slider", Tab = Tab, Element = Slider, Frame = Frame}
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ========== BUTTON ==========
            function Section:AddButton(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local styles = {
                    Primary = {CurrentTheme.Primary, CurrentTheme.Secondary},
                    Secondary = {Colors.BackgroundLight, Colors.CardHover},
                    Success = {Colors.Success, Color3.fromRGB(100, 255, 180)},
                    Danger = {Colors.Error, Color3.fromRGB(255, 120, 140)}
                }
                local style = styles[cfg.Style or "Primary"] or styles.Primary
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = style[1],
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.GothamBlack,
                    Text = cfg.Title or "Button",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    AutoButtonColor = false,
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Btn, 8)
                AddGradient(Btn, style, 90)
                
                Btn.MouseEnter:Connect(function() Tween(Btn, {Size = UDim2.new(1, 0, 0, 32)}, 0.15) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {Size = UDim2.new(1, 0, 0, 30)}, 0.15) end)
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, 0, 0, 28)}, 0.08)
                    task.delay(0.08, function() Tween(Btn, {Size = UDim2.new(1, 0, 0, 30)}, 0.08) end)
                    if cfg.Callback then cfg.Callback() end
                end)
                
                return {Button = Btn, Frame = Btn}
            end
            
            -- ========== TEXTBOX ==========
            function Section:AddTextBox(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "TextBox"))
                local TextBoxElement = {Value = cfg.Default or "", Id = id}
                local order = GetNextOrder()
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 50 or 34),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                TextBoxElement.Frame = Frame
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, cfg.Description and 4 or 0),
                    Size = UDim2.new(0.4, 0, 0, cfg.Description and 14 or 34),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "TextBox",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 18),
                        Size = UDim2.new(0.5, 0, 0, 12),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 8,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local InputBox = Create("TextBox", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0.5, 5, 0.5, -10),
                    Size = UDim2.new(0.5, -15, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "Enter value...",
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    ClearTextOnFocus = false,
                    Parent = Frame
                })
                AddCorner(InputBox, 5)
                AddStroke(InputBox, CurrentTheme.Primary, 1, 0.7)
                
                InputBox.FocusLost:Connect(function()
                    TextBoxElement.Value = InputBox.Text
                    if ConfigSys.Elements[id] then ConfigSys.Elements[id].Value = InputBox.Text end
                    if cfg.Callback then cfg.Callback(InputBox.Text) end
                end)
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15) end)
                
                function TextBoxElement:SetValue(v)
                    TextBoxElement.Value = v
                    InputBox.Text = v
                end
                
                ConfigSys:RegisterElement(id, TextBoxElement, cfg.Default or "")
                Window.SearchableElements[id] = {Title = cfg.Title or "TextBox", Tab = Tab, Element = TextBoxElement, Frame = Frame}
                
                table.insert(Section.Elements, TextBoxElement)
                return TextBoxElement
            end
            
            -- ========== KEYBIND ==========
            function Section:AddKeybind(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Keybind"))
                local Keybind = {Value = cfg.Default or Enum.KeyCode.E, Id = id}
                local listening = false
                local order = GetNextOrder()
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 34),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                Keybind.Frame = Frame
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -70, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Keybind",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local KeyBtn = Create("TextButton", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -58, 0.5, -10),
                    Size = UDim2.new(0, 50, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = Keybind.Value.Name,
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 9,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(KeyBtn, 5)
                AddStroke(KeyBtn, CurrentTheme.Primary, 1, 0.5)
                
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
                            
                            if cfg.IsToggleKey then
                                Window:SetToggleKey(input.KeyCode)
                            end
                            
                            ConfigSys:RegisterKeybind(id, input.KeyCode, cfg.OnPress)
                            if cfg.Callback then cfg.Callback(input.KeyCode) end
                        end
                    elseif not processed and input.KeyCode == Keybind.Value then
                        if cfg.OnPress then cfg.OnPress() end
                    end
                end))
                
                Frame.MouseEnter:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15) end)
                Frame.MouseLeave:Connect(function() Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15) end)
                
                function Keybind:SetValue(v)
                    if type(v) == "string" then v = Enum.KeyCode[v] or Enum.KeyCode.E end
                    Keybind.Value = v
                    KeyBtn.Text = v.Name
                end
                
                ConfigSys:RegisterElement(id, Keybind, cfg.Default and cfg.Default.Name or "E")
                Window.SearchableElements[id] = {Title = cfg.Title or "Keybind", Tab = Tab, Element = Keybind, Frame = Frame}
                
                table.insert(Section.Elements, Keybind)
                return Keybind
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
                AddPadding(Frame, 8)
                Create("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Frame})
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 12),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Title",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
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
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    LayoutOrder = 2,
                    Parent = Frame
                })
                
                table.insert(Section.Elements, {Frame = Frame})
                return {Frame = Frame}
            end
            
            -- ========== DROPDOWN (WITH SEARCH) ==========
            function Section:AddDropdown(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Dropdown"))
                local items = cfg.Items or {}
                local multi = cfg.Multi or false
                local Dropdown = {Value = multi and {} or cfg.Default, Open = false, Items = items, Id = id}
                local order = GetNextOrder()
                
                if multi and cfg.Default then
                    for _, v in pairs(cfg.Default) do Dropdown.Value[v] = true end
                end
                
                local baseH = 48
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, baseH),
                    ClipsDescendants = true,
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                Dropdown.Frame = Frame
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 4),
                    Size = UDim2.new(1, -20, 0, 12),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 8, 0, 20),
                    Size = UDim2.new(1, -16, 0, 22),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(DropBtn, 5)
                AddStroke(DropBtn, CurrentTheme.Primary, 1, 0.7)
                
                local BtnText = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -25, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = multi and "None" or (cfg.Default or "Select..."),
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropBtn
                })
                
                local Arrow = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -16, 0, 0),
                    Size = UDim2.new(0, 12, 1, 0),
                    Font = Enum.Font.GothamBlack,
                    Text = "▼",
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 8,
                    Parent = DropBtn
                })
                
                local Content = Create("Frame", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 8, 0, baseH + 2),
                    Size = UDim2.new(1, -16, 0, 0),
                    ClipsDescendants = true,
                    Parent = Frame
                })
                AddCorner(Content, 6)
                AddStroke(Content, CurrentTheme.Primary, 1, 0.7)
                
                -- Search box for dropdown
                local DropSearchBox = Create("TextBox", {
                    BackgroundColor3 = Colors.BackgroundDark,
                    Position = UDim2.new(0, 4, 0, 4),
                    Size = UDim2.new(1, -8, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = "",
                    PlaceholderText = "🔍 Search...",
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 9,
                    ClearTextOnFocus = false,
                    Visible = false,
                    ZIndex = 2,
                    Parent = Content
                })
                AddCorner(DropSearchBox, 4)
                
                local ItemsList = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 2,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Content
                })
                AddPadding(ItemsList, 3, 3, 4, 4)
                Create("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ItemsList})
                
                local itemBtns = {}
                local allItems = {}
                
                local function createItem(name, idx)
                    local isSel = multi and Dropdown.Value[name] or Dropdown.Value == name
                    
                    local ItemBtn = Create("TextButton", {
                        Name = name,
                        BackgroundColor3 = isSel and CurrentTheme.Primary or Colors.BackgroundLight,
                        BackgroundTransparency = isSel and 0.7 or 0.3,
                        Size = UDim2.new(1, -6, 0, 22),
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = idx,
                        Parent = ItemsList
                    })
                    AddCorner(ItemBtn, 4)
                    
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -14, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = name,
                        TextColor3 = isSel and Colors.Text or Colors.TextSecondary,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ItemBtn
                    })
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[name] = not Dropdown.Value[name]
                            local nowSel = Dropdown.Value[name]
                            
                            Tween(ItemBtn, {BackgroundColor3 = nowSel and CurrentTheme.Primary or Colors.BackgroundLight, BackgroundTransparency = nowSel and 0.7 or 0.3}, 0.15)
                            ItemBtn:FindFirstChild("Text").TextColor3 = nowSel and Colors.Text or Colors.TextSecondary
                            
                            local sel = {}
                            for k, v in pairs(Dropdown.Value) do if v then table.insert(sel, k) end end
                            BtnText.Text = #sel > 0 and table.concat(sel, ", ") or "None"
                            
                            if cfg.Callback then cfg.Callback(Dropdown.Value) end
                        else
                            Dropdown.Value = name
                            BtnText.Text = name
                            BtnText.TextColor3 = Colors.Text
                            
                            for n, btn in pairs(itemBtns) do
                                local isThis = n == name
                                Tween(btn, {BackgroundColor3 = isThis and CurrentTheme.Primary or Colors.BackgroundLight, BackgroundTransparency = isThis and 0.7 or 0.3}, 0.15)
                                btn:FindFirstChild("Text").TextColor3 = isThis and Colors.Text or Colors.TextSecondary
                            end
                            
                            if cfg.Callback then cfg.Callback(name) end
                            
                            Dropdown.Open = false
                            Tween(Arrow, {Rotation = 0}, 0.2)
                            Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                            Tween(Content, {Size = UDim2.new(1, -16, 0, 0)}, 0.25)
                            DropSearchBox.Visible = false
                            DropSearchBox.Text = ""
                        end
                        
                        if ConfigSys.Elements[id] then ConfigSys.Elements[id].Value = Dropdown.Value end
                    end)
                    
                    allItems[name] = ItemBtn
                    return ItemBtn
                end
                
                local function filterItems(query)
                    query = query:lower()
                    for name, btn in pairs(allItems) do
                        btn.Visible = query == "" or name:lower():find(query, 1, true) ~= nil
                    end
                end
                
                DropSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    filterItems(DropSearchBox.Text)
                end)
                
                for idx, item in ipairs(items) do
                    itemBtns[item] = createItem(item, idx)
                end
                
                DropBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        Tween(Arrow, {Rotation = 180}, 0.2)
                        local contentH = math.min(#items * 25 + 6, 150)
                        
                        if #items > 5 then
                            DropSearchBox.Visible = true
                            ItemsList.Position = UDim2.new(0, 0, 0, 28)
                            ItemsList.Size = UDim2.new(1, 0, 1, -28)
                            contentH = contentH + 28
                        else
                            DropSearchBox.Visible = false
                            ItemsList.Position = UDim2.new(0, 0, 0, 0)
                            ItemsList.Size = UDim2.new(1, 0, 1, 0)
                        end
                        
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH + 4 + contentH)}, 0.3, Enum.EasingStyle.Back)
                        Tween(Content, {Size = UDim2.new(1, -16, 0, contentH)}, 0.3, Enum.EasingStyle.Back)
                    else
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                        Tween(Content, {Size = UDim2.new(1, -16, 0, 0)}, 0.25)
                        DropSearchBox.Visible = false
                        DropSearchBox.Text = ""
                        filterItems("")
                    end
                end)
                
                function Dropdown:SetItems(newItems)
                    Dropdown.Items = newItems
                    items = newItems
                    for _, c in pairs(ItemsList:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    itemBtns = {}
                    allItems = {}
                    for idx, item in ipairs(newItems) do
                        itemBtns[item] = createItem(item, idx)
                    end
                end
                
                function Dropdown:SetValue(v)
                    Dropdown.Value = v
                    if multi then
                        local sel = {}
                        for k, val in pairs(v) do if val then table.insert(sel, k) end end
                        BtnText.Text = #sel > 0 and table.concat(sel, ", ") or "None"
                    else
                        BtnText.Text = v or "Select..."
                    end
                end
                
                ConfigSys:RegisterElement(id, Dropdown, multi and {} or cfg.Default)
                Window.SearchableElements[id] = {Title = cfg.Title or "Dropdown", Tab = Tab, Element = Dropdown, Frame = Frame}
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
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
EnzoLib.Version = "2.3.0"
EnzoLib.Author = "ENZO-YT"
EnzoLib.Design = "G - Aurora Ethereal v2.3"
EnzoLib.Themes = Themes
EnzoLib.Colors = Colors

return EnzoLib