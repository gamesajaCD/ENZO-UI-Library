--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ENZO UI LIBRARY                           ║
    ║           Design G: Aurora Ethereal v2.4.2                   ║
    ║                  Author: ENZO-YT                             ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  v2.4.2 FIXES:                                               ║
    ║  ✅ Button Text Contrast (selalu readable)                   ║
    ║  ✅ Label/Section Size (lebih besar)                         ║
    ║  ✅ Opacity dengan Glow tetap                                ║
    ║  ✅ Blur parameter di CreateWindow                           ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  v2.4 FEATURES:                                              ║
    ║  ⭐ ColorPicker                                               ║
    ║  ⭐ Config Manager Tab                                        ║
    ║  ⭐ Enhanced Input (Validation)                               ║
    ║  ⭐ Tooltip System                                            ║
    ║  ⭐ Slider with Input                                         ║
    ║  ⭐ Image Element                                             ║
    ║  ⭐ Multi-Dropdown Enhanced (Select All/Clear All)            ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local EnzoLib = {}
EnzoLib.__index = EnzoLib

-- ============================================
-- ANTI-DETECTION
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
-- COLOR UTILITIES (For ColorPicker)
-- ============================================
local function RGBtoHSV(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    local d = max - min
    if max == 0 then s = 0 else s = d / max end
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function Color3ToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255))
end

local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber(hex:sub(1, 2), 16) or 0
        local g = tonumber(hex:sub(3, 4), 16) or 0
        local b = tonumber(hex:sub(5, 6), 16) or 0
        return Color3.fromRGB(r, g, b)
    end
    return Color3.fromRGB(255, 255, 255)
end

-- ============================================
-- CONFIG SYSTEM
-- ============================================
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new(folderName)
    local self = setmetatable({}, ConfigSystem)
    self.FolderName = folderName or "EnzoConfigs"
    self.CurrentProfile = "Default"
    self.Elements = {}
    self.Keybinds = {}
    self.Favorites = {}
    
    -- Create folder if possible
    SafeCall(function()
        if makefolder and not isfolder(self.FolderName) then
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
        Elements = {},
        Favorites = self.Favorites,
        Keybinds = {}
    }
    
    for id, info in pairs(self.Elements) do
        if info.Element and info.Element.Value ~= nil then
            local value = info.Element.Value
            if typeof(value) == "Color3" then
                data.Elements[id] = {Type = "Color3", Value = Color3ToHex(value)}
            elseif typeof(value) == "EnumItem" then
                data.Elements[id] = {Type = "Enum", Value = tostring(value)}
            else
                data.Elements[id] = {Type = "Raw", Value = value}
            end
        end
    end
    
    for id, info in pairs(self.Keybinds) do
        data.Keybinds[id] = info.Key and info.Key.Name or "Unknown"
    end
    
    local json = HttpService:JSONEncode(data)
    
    SafeCall(function()
        if writefile then
            writefile(self:GetConfigPath(name), json)
        end
    end)
    
    return true
end

function ConfigSystem:Load(name)
    local success, content = SafeCall(function()
        if readfile then
            return readfile(self:GetConfigPath(name))
        end
        return nil
    end)
    
    if not success or not content then return false end
    
    local data = HttpService:JSONDecode(content)
    if not data then return false end
    
    -- Load elements
    if data.Elements then
        for id, info in pairs(data.Elements) do
            if self.Elements[id] and self.Elements[id].Element then
                local element = self.Elements[id].Element
                local value = info.Value
                
                if info.Type == "Color3" then
                    value = HexToColor3(value)
                end
                
                if element.SetValue then
                    element:SetValue(value)
                elseif element.Value ~= nil then
                    element.Value = value
                end
            end
        end
    end
    
    -- Load favorites
    if data.Favorites then
        self.Favorites = data.Favorites
    end
    
    return true
end

function ConfigSystem:Delete(name)
    SafeCall(function()
        if delfile then
            delfile(self:GetConfigPath(name))
        end
    end)
end

function ConfigSystem:GetConfigs()
    local configs = {}
    SafeCall(function()
        if listfiles then
            local files = listfiles(self.FolderName)
            for _, file in ipairs(files) do
                local name = file:match("([^/\\]+)%.json$")
                if name then
                    table.insert(configs, name)
                end
            end
        end
    end)
    return configs
end

function ConfigSystem:Export(name)
    local success, content = SafeCall(function()
        if readfile then
            return readfile(self:GetConfigPath(name))
        end
        return nil
    end)
    return content or ""
end

function ConfigSystem:Import(jsonString)
    local success, data = SafeCall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    
    if success and data and data.Elements then
        for id, info in pairs(data.Elements) do
            if self.Elements[id] and self.Elements[id].Element then
                local element = self.Elements[id].Element
                local value = info.Value
                
                if info.Type == "Color3" then
                    value = HexToColor3(value)
                end
                
                if element.SetValue then
                    element:SetValue(value)
                end
            end
        end
        return true
    end
    return false
end

function ConfigSystem:ToggleFavorite(id)
    self.Favorites[id] = not self.Favorites[id]
    return self.Favorites[id]
end

function ConfigSystem:IsFavorite(id)
    return self.Favorites[id] == true
end

function ConfigSystem:RegisterKeybind(id, key, callback)
    self.Keybinds[id] = {Key = key, Callback = callback}
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if self.Keybinds[id] and input.KeyCode == self.Keybinds[id].Key then
            SafeCall(self.Keybinds[id].Callback)
        end
    end)
end

-- ============================================
-- TOOLTIP SYSTEM
-- ============================================
local TooltipFrame = nil
local TooltipText = nil
local TooltipVisible = false

local function CreateTooltip(screenGui)
    TooltipFrame = Create("Frame", {
        Name = "Tooltip",
        BackgroundColor3 = Colors.Card,
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 9999,
        Parent = screenGui
    })
    AddCorner(TooltipFrame, 6)
    AddStroke(TooltipFrame, CurrentTheme.Primary, 1, 0.5)
    AddShadow(TooltipFrame, Color3.new(0, 0, 0), 10, 0.5)
    
    TooltipText = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 10000,
        Parent = TooltipFrame
    })
end

local function ShowTooltip(text, x, y)
    if not TooltipFrame then return end
    
    TooltipText.Text = text
    
    -- Calculate size based on text
    local textSize = game:GetService("TextService"):GetTextSize(
        text, 11, Enum.Font.Gotham, Vector2.new(200, 100)
    )
    TooltipFrame.Size = UDim2.new(0, math.max(textSize.X + 20, 100), 0, textSize.Y + 12)
    
    -- Position tooltip
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local posX = math.min(x + 15, viewportSize.X - TooltipFrame.Size.X.Offset - 10)
    local posY = math.min(y + 15, viewportSize.Y - TooltipFrame.Size.Y.Offset - 10)
    
    TooltipFrame.Position = UDim2.new(0, posX, 0, posY)
    TooltipFrame.Visible = true
    TooltipVisible = true
end

local function HideTooltip()
    if TooltipFrame then
        TooltipFrame.Visible = false
        TooltipVisible = false
    end
end

local function AddTooltip(element, text)
    if not text or text == "" then return end
    
    element.MouseEnter:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        ShowTooltip(text, mouse.X, mouse.Y)
    end)
    
    element.MouseMoved:Connect(function()
        if TooltipVisible then
            local mouse = UserInputService:GetMouseLocation()
            ShowTooltip(text, mouse.X, mouse.Y)
        end
    end)
    
    element.MouseLeave:Connect(function()
        HideTooltip()
    end)
end
-- ============================================
-- MAIN LIBRARY - CREATE WINDOW
-- ============================================
function EnzoLib:CreateWindow(config)
    config = config or {}
    
    local windowTitle = config.Title or "Enzo UI"
    local windowSubTitle = config.SubTitle or "v2.4.2"
    local windowSize = config.Size or UDim2.new(0, 700, 0, 450)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local logoImage = config.Logo
    local themeName = config.Theme or "Aurora"
    local showWatermark = config.Watermark ~= false
    local scriptVersion = config.Version or "2.4.2"
    local updateURL = config.UpdateURL
    local blurEnabled = config.Blur ~= false -- NEW: Blur parameter (default true)
    
    CurrentTheme = Themes[themeName] or Themes.Aurora
    
    -- Config System
    local Config = ConfigSystem.new(config.ConfigFolder or "EnzoConfigs")
    
    -- ============================================
    -- SCREEN GUI
    -- ============================================
    local ScreenGui = Create("ScreenGui", {
        Name = GUI_NAME,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = CoreGui
    })
    
    -- Create Tooltip
    CreateTooltip(ScreenGui)
    
    -- ============================================
    -- BLUR EFFECT (Controlled by config.Blur)
    -- ============================================
    local BlurEffect = Create("BlurEffect", {
        Name = BLUR_NAME,
        Size = 0,
        Enabled = blurEnabled,
        Parent = Lighting
    })
    
    -- ============================================
    -- MAIN CONTAINER
    -- ============================================
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Colors.Background,
        Position = UDim2.new(0.5, -350, 0.5, -225),
        Size = windowSize,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, Colors.CardBorder, 1, 0)
    AddShadow(MainFrame, Color3.new(0, 0, 0), 25, 0.5)
    
    -- ============================================
    -- AURORA BORDER (Glow Effect - TIDAK dipengaruhi opacity)
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
    local AuroraGradient = AddGradient(AuroraBorder, {
        CurrentTheme.Primary,
        CurrentTheme.Secondary,
        CurrentTheme.Tertiary,
        CurrentTheme.Primary
    }, 0)
    AddGlow(AuroraBorder, CurrentTheme.Primary, 15, 0.6)
    
    -- Aurora animation
    task.spawn(function()
        local rotation = 0
        while AuroraBorder and AuroraBorder.Parent do
            rotation = (rotation + 1) % 360
            AuroraGradient.Rotation = rotation
            task.wait(0.03)
        end
    end)
    
    MakeDraggable(MainFrame)
    
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
    
    -- Header bottom fix
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
        Position = UDim2.new(1, -100, 0.5, -12),
        Size = UDim2.new(0, 90, 0, 24),
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
            TextSize = 14,
            AutoButtonColor = false,
            Parent = ControlsFrame
        })
        AddCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = color}, 0.2)
            Tween(btn, {TextColor3 = Colors.Text}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.BackgroundLight}, 0.2)
            Tween(btn, {TextColor3 = color}, 0.2)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
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
        Config = Config,
        SearchableElements = {},
        BlurEnabled = blurEnabled
    }
    
    -- ============================================
    -- BLUR CONTROL FUNCTION
    -- ============================================
    function Window:SetBlur(enabled)
        Window.BlurEnabled = enabled
        BlurEffect.Enabled = enabled
        if enabled and Window.Visible and not Window.Minimized then
            Tween(BlurEffect, {Size = 15}, 0.3)
        else
            Tween(BlurEffect, {Size = 0}, 0.3)
        end
    end
    
    -- ============================================
    -- WINDOW FUNCTIONS
    -- ============================================
    function Window:Toggle()
        Window.Visible = not Window.Visible
        if Window.Visible then
            ScreenGui.Enabled = true
            MainFrame.Visible = true
            Tween(MainFrame, {
                Size = windowSize,
                Position = UDim2.new(0.5, -350, 0.5, -225)
            }, 0.3)
            if Window.BlurEnabled then
                Tween(BlurEffect, {Size = 15}, 0.3)
            end
        else
            Tween(MainFrame, {
                Size = UDim2.new(0, windowSize.X.Offset, 0, 0),
                Position = UDim2.new(0.5, -350, 0.5, 0)
            }, 0.3)
            Tween(BlurEffect, {Size = 0}, 0.3)
            task.delay(0.3, function()
                if not Window.Visible then
                    MainFrame.Visible = false
                end
            end)
        end
    end
    
    function Window:Minimize()
        Window.Minimized = true
        Tween(MainFrame, {Size = UDim2.new(0, 200, 0, 50)}, 0.3)
        Tween(BlurEffect, {Size = 0}, 0.3)
    end
    
    function Window:Restore()
        Window.Minimized = false
        Tween(MainFrame, {Size = windowSize}, 0.3)
        if Window.BlurEnabled then
            Tween(BlurEffect, {Size = 15}, 0.3)
        end
    end
    
    function Window:Destroy()
        Tween(BlurEffect, {Size = 0}, 0.3)
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.delay(0.3, function()
            ScreenGui:Destroy()
            BlurEffect:Destroy()
        end)
    end
    
    -- Minimize Button
    CreateControlButton("—", Colors.Warning, function()
        if Window.Minimized then
            Window:Restore()
        else
            Window:Minimize()
        end
    end)
    
    -- Close Button
    CreateControlButton("×", Colors.Error, function()
        Window:Toggle()
    end)
    
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
        Size = UDim2.new(1, 0, 1, -50),
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
    
    -- ========== OPACITY SLIDER (FIXED - Glow tetap terlihat) ==========
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

    -- FIXED: Opacity hanya mempengaruhi background, BUKAN glow/aurora border
    local function UpdateOpacity(percent)
        percent = math.clamp(percent, 30, 100)
        OpacityFill.Size = UDim2.new(percent / 100, 0, 1, 0)
        OpacityValue.Text = math.floor(percent) .. "%"
        
        local transparency = 1 - (percent / 100)
        
        -- Hanya background yang berubah, AURORA BORDER TETAP SOLID
        MainFrame.BackgroundTransparency = transparency * 0.6
        ContentArea.BackgroundTransparency = 0.3 + (transparency * 0.4)
        TabsFrame.BackgroundTransparency = transparency * 0.5
        Header.BackgroundTransparency = transparency * 0.4
        -- AuroraBorder TIDAK berubah - tetap solid untuk glow effect
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
    
    -- ========== THEME SELECTOR ==========
    Create("TextLabel", {
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
            AuroraGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.Primary),
                ColorSequenceKeypoint.new(0.33, theme.Secondary),
                ColorSequenceKeypoint.new(0.66, theme.Tertiary),
                ColorSequenceKeypoint.new(1, theme.Primary)
            })
            Window:Notify({Title = "Theme Changed", Content = "Applied: " .. name, Type = "Success", Duration = 2})
        end)
    end
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
            BackgroundColor3 = Colors.Card,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Parent = NotificationHolder
        })
        AddCorner(Notif, 10)
        AddStroke(Notif, color, 1)
        AddShadow(Notif, color, 10, 0.7)
        
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
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = icon .. " " .. (cfg.Title or "Notification"),
            TextColor3 = color,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            Parent = NotifContent
        })
        
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
        
        Tween(ProgressFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
        
        task.delay(duration, function()
            if Notif and Notif.Parent then
                Tween(Notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
                task.delay(0.3, function() 
                    if Notif then Notif:Destroy() end 
                end)
            end
        end)
    end
    
    -- ============================================
    -- WATERMARK
    -- ============================================
    if showWatermark then
        local Watermark = Create("Frame", {
            BackgroundColor3 = Colors.Card,
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
            Text = "ENZO | FPS: -- | Ping: --",
            TextColor3 = Colors.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Watermark
        })
        
        local startTime = tick()
        task.spawn(function()
            while Watermark and Watermark.Parent do
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
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
                    Config:Save(configNameInput)
                    Window:Notify({Title = "Config Saved", Content = "Saved: " .. configNameInput, Type = "Success", Duration = 3})
                end
            end
        })
        
        ConfigSection:AddButton({
            Title = "📂 Load Config",
            Style = "Primary",
            Callback = function()
                if configNameInput ~= "" then
                    if Config:Load(configNameInput) then
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
            Sections = {}
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
        
        -- Tab Content Frame
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
        
        Create("TextLabel", {
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
        
        -- Tab Container (ScrollingFrame)
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
            for _, t in ipairs(Window.Tabs) do
                t.Content.Visible = false
                Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
                for _, label in ipairs(t.Button:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        Tween(label, {TextColor3 = Colors.TextSecondary}, 0.2)
                    end
                end
            end
            
            Tab.Content.Visible = true
            Window.ActiveTab = Tab
            Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
            for _, label in ipairs(TabBtn:GetDescendants()) do
                if label:IsA("TextLabel") then
                    Tween(label, {TextColor3 = Colors.Text}, 0.2)
                end
            end
        end
        
        TabBtn.MouseButton1Click:Connect(SelectTab)
        
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.5}, 0.2)
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
            end
        end)
        
        if #Window.Tabs == 0 then
            SelectTab()
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- ============================================
        -- ADD SECTION
        -- ============================================
        function Tab:AddSection(config)
            config = config or {}
            
            local Section = {Elements = {}}
            
            local parentColumn = config.Side == "Right" and RightColumn or LeftColumn
            
            local SectionFrame = Create("Frame", {
                BackgroundColor3 = Colors.Card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #Tab.Sections + 1,
                Parent = parentColumn
            })
            AddCorner(SectionFrame, 10)
            AddStroke(SectionFrame, Colors.CardBorder, 1)
            
            -- Section Header (FIXED SIZE)
            local SectionHeader = Create("Frame", {
                BackgroundColor3 = Colors.BackgroundDark,
                Size = UDim2.new(1, 0, 0, 34), -- FIXED: Sedikit lebih tinggi
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
            
            -- FIXED: Section header text size lebih besar
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = (config.Icon or "📁") .. "  " .. (config.Title or "Section"),
                TextColor3 = Colors.Text,
                TextSize = 12, -- FIXED: Dari 11 ke 12
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            -- Section Content
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 34),
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
            
            -- ========== LABEL (FIXED SIZE) ==========
            function Section:AddLabel(text)
                local order = GetNextOrder()
                
                local Label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22), -- FIXED: Lebih tinggi
                    LayoutOrder = order,
                    Font = Enum.Font.GothamMedium,
                    Text = text or "Label",
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 12, -- FIXED: Dari 10 ke 12
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
                    Size = UDim2.new(1, 0, 0, 24), -- FIXED: Lebih tinggi
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
                        TextSize = 11, -- FIXED: Dari 9 ke 11
                        Parent = DividerFrame
                    })
                else
                    local Line = Create("Frame", {
                        BackgroundColor3 = Colors.CardBorder,
                        Size = UDim2.new(1, 0, 0, 2), -- FIXED: Lebih tebal
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
                    Size = UDim2.new(1, 0, 0, cfg.Description and 52 or 38),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                -- FIXED: Title size
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, cfg.Description and 8 or 0),
                    Size = UDim2.new(1, -70, 0, cfg.Description and 18 or 38),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Colors.Text,
                    TextSize = 12, -- FIXED: Dari 11 ke 12
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
                        Tween(SwitchBg, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                        Tween(SwitchCircle, {Position = UDim2.new(1, -19, 0.5, -8)}, 0.2)
                    else
                        Tween(SwitchBg, {BackgroundColor3 = Colors.Background}, 0.2)
                        Tween(SwitchCircle, {Position = UDim2.new(0, 3, 0.5, -8)}, 0.2)
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
                
                Config:RegisterElement(id, Toggle, cfg.Default or false)
                Window.SearchableElements[id] = {Title = cfg.Title or "Toggle", Tab = Tab, Element = Toggle, Frame = Frame}
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- ========== SLIDER ==========
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
                    Size = UDim2.new(1, 0, 0, cfg.Description and 62 or 48),
                    LayoutOrder = order,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                -- FIXED: Title size
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(0.5, -12, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Colors.Text,
                    TextSize = 12, -- FIXED: Dari 11 ke 12
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                -- Value display
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
                    Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    Tween(Knob, {Position = UDim2.new(percent, -8, 0.5, -8)}, 0.1)
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
                
                if allowInput then
                    ValueDisplay.FocusLost:Connect(function()
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
                
                Config:RegisterElement(id, Slider, default)
                Window.SearchableElements[id] = {Title = cfg.Title or "Slider", Tab = Tab, Element = Slider, Frame = Frame}
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ========== BUTTON (FIXED TEXT CONTRAST) ==========
            function Section:AddButton(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local style = cfg.Style or "Primary"
                
                -- FIXED: Button styles dengan text yang SELALU KONTRAS
                local ButtonStyles = {
                    Primary = {
                        Background = CurrentTheme.Primary,
                        Gradient = {CurrentTheme.Primary, CurrentTheme.Secondary},
                        Text = Color3.fromRGB(255, 255, 255), -- SELALU PUTIH
                        Hover = CurrentTheme.Secondary
                    },
                    Secondary = {
                        Background = Colors.BackgroundLight,
                        Gradient = nil,
                        Text = Colors.Text,
                        Hover = Colors.CardHover
                    },
                    Success = {
                        Background = Colors.Success,
                        Gradient = {Colors.Success, Color3.fromRGB(50, 200, 120)},
                        Text = Color3.fromRGB(255, 255, 255), -- SELALU PUTIH
                        Hover = Color3.fromRGB(50, 200, 120)
                    },
                    Danger = {
                        Background = Colors.Error,
                        Gradient = {Colors.Error, Color3.fromRGB(200, 50, 70)},
                        Text = Color3.fromRGB(255, 255, 255), -- SELALU PUTIH
                        Hover = Color3.fromRGB(200, 50, 70)
                    }
                }
                
                local btnStyle = ButtonStyles[style] or ButtonStyles.Primary
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = btnStyle.Background,
                    Size = UDim2.new(1, 0, 0, 36), -- FIXED: Sedikit lebih besar
                    LayoutOrder = order,
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Button",
                    TextColor3 = btnStyle.Text, -- FIXED: Warna text yang kontras
                    TextSize = 12, -- FIXED: Sedikit lebih besar
                    AutoButtonColor = false,
                    Parent = SectionContent
                })
                AddCorner(Btn, 8)
                
                if btnStyle.Gradient then
                    AddGradient(Btn, btnStyle.Gradient, 90)
                end
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = btnStyle.Hover}, 0.2)
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = btnStyle.Background}, 0.2)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    -- Press animation
                    Tween(Btn, {Size = UDim2.new(1, -4, 0, 34)}, 0.1)
                    task.wait(0.1)
                    Tween(Btn, {Size = UDim2.new(1, 0, 0, 36)}, 0.1)
                    
                    SafeCall(cfg.Callback)
                end)
                
                if cfg.Tooltip then
                    AddTooltip(Btn, cfg.Tooltip)
                end
                
                table.insert(Section.Elements, {Button = Btn})
                return {Button = Btn}
            end
            
            -- ========== INPUT ==========
            function Section:AddInput(cfg)
                cfg = cfg or {}
                local order = GetNextOrder()
                local id = cfg.Title or ("Input_" .. order)
                
                local Input = {Value = cfg.Default or ""}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 70 or 56),
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
                    TextSize = 12,
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
                AddPadding(TextBox, 0, 0, 8, 8)
                
                TextBox.FocusLost:Connect(function()
                    local value = TextBox.Text
                    
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
                
                Config:RegisterElement(id, Input, cfg.Default or "")
                
                table.insert(Section.Elements, Input)
                return Input
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
                    Size = UDim2.new(1, 0, 0, 75),
                    LayoutOrder = order,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(1, -24, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 10, 0, 32),
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
                
                local DropList = Create("Frame", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 10, 0, 67),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50,
                    Parent = Frame
                })
                AddCorner(DropList, 6)
                AddStroke(DropList, Colors.CardBorder, 1)
                
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
                        ZIndex = 52,
                        Parent = ControlsFrame
                    })
                    AddCorner(ClearAllBtn, 4)
                    
                    SelectAllBtn.MouseButton1Click:Connect(function()
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
                            Tween(ItemBtn, {BackgroundTransparency = 0}, 0.2)
                        end)
                        ItemBtn.MouseLeave:Connect(function()
                            Tween(ItemBtn, {BackgroundTransparency = 1}, 0.2)
                        end)
                        
                        ItemBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value = itemText
                            BtnText.Text = itemText
                            isOpen = false
                            Tween(DropList, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
                            task.delay(0.2, function() DropList.Visible = false end)
                            SafeCall(cfg.Callback, itemText)
                        end)
                        
                        return {Btn = ItemBtn}
                    end
                end
                
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
                        Tween(DropList, {Size = UDim2.new(1, -20, 0, listHeight)}, 0.2)
                    else
                        Tween(DropList, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
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
                
                Config:RegisterElement(id, Dropdown, multi and {} or cfg.Default)
                Window.SearchableElements[id] = {Title = cfg.Title or "Dropdown", Tab = Tab, Element = Dropdown, Frame = Frame}
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
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
                    Tween(KeyBtn, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                    Tween(KeyBtn, {TextColor3 = Colors.Text}, 0.2)
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        Keybind.Value = input.KeyCode
                        KeyBtn.Text = input.KeyCode.Name
                        Tween(KeyBtn, {BackgroundColor3 = Colors.Background}, 0.2)
                        Tween(KeyBtn, {TextColor3 = CurrentTheme.Primary}, 0.2)
                        
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
                
                Config:RegisterElement(id, Keybind, cfg.Default)
                
                table.insert(Section.Elements, Keybind)
                return Keybind
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
                AddStroke(ColorPreview, Colors.CardBorder, 1)
                
                local PickerPanel = Create("Frame", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(1, 0, 0, 120),
                    Visible = false,
                    ZIndex = 100,
                    Parent = Frame
                })
                AddCorner(PickerPanel, 8)
                AddStroke(PickerPanel, CurrentTheme.Primary, 1)
                AddPadding(PickerPanel, 10)
                
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
                
                local HexInput = Create("TextBox", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Position = UDim2.new(0, 0, 1, -25),
                    Size = UDim2.new(1, 0, 0, 22),
                    Font = Enum.Font.GothamMedium,
                    Text = Color3ToHex(defaultColor),
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    ZIndex = 101,
                    Parent = PickerPanel
                })
                AddCorner(HexInput, 4)
                
                local hue, sat, val = RGBtoHSV(defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255)
                
                local function UpdateColor()
                    local r, g, b = HSVtoRGB(hue, sat, val)
                    local color = Color3.fromRGB(r, g, b)
                    ColorPicker.Value = color
                    ColorPreview.BackgroundColor3 = color
                    SVPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    HexInput.Text = Color3ToHex(color)
                    SafeCall(cfg.Callback, color)
                end
                
                local svDragging = false
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = true
                    end
                end)
                
                local hueDragging = false
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                        hueDragging = false
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
                    if hueDragging then
                        local pos = HueSlider.AbsolutePosition
                        local size = HueSlider.AbsoluteSize
                        local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                        hue = y
                        HueCursor.Position = UDim2.new(0, -2, y, -2)
                        UpdateColor()
                    end
                end)
                
                HexInput.FocusLost:Connect(function()
                    local color = HexToColor3(HexInput.Text)
                    hue, sat, val = RGBtoHSV(color.R * 255, color.G * 255, color.B * 255)
                    UpdateColor()
                end)
                
                ColorPreview.MouseButton1Click:Connect(function()
                    PickerPanel.Visible = not PickerPanel.Visible
                end)
                
                function ColorPicker:SetValue(color)
                    hue, sat, val = RGBtoHSV(color.R * 255, color.G * 255, color.B * 255)
                    UpdateColor()
                end
                
                function ColorPicker:GetValue()
                    return ColorPicker.Value
                end
                
                if cfg.Tooltip then
                    AddTooltip(Frame, cfg.Tooltip)
                end
                
                Config:RegisterElement(id, ColorPicker, defaultColor)
                
                table.insert(Section.Elements, ColorPicker)
                return ColorPicker
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
    AddShadow(MobileBtn, Color3.new(0, 0, 0), 8, 0.4)
    
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
    
    -- Store in global
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