--[[
    ███████╗███╗   ██╗███████╗ ██████╗     ██╗   ██╗██╗
    ██╔════╝████╗  ██║╚══███╔╝██╔═══██╗    ██║   ██║██║
    █████╗  ██╔██╗ ██║  ███╔╝ ██║   ██║    ██║   ██║██║
    ██╔══╝  ██║╚██╗██║ ███╔╝  ██║   ██║    ██║   ██║██║
    ███████╗██║ ╚████║███████╗╚██████╔╝    ╚██████╔╝██║
    ╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝      ╚═════╝ ╚═╝
    
    ENZO UI - Cyberpunk Terminal Edition
    Version: 1.0.0
    Author: ENZO
    
    Premium UI Library for Roblox
    Compatible with all executors (PC & Mobile)
]]

-- ═══════════════════════════════════════════════════════════════════
-- PART 1: CORE & UTILITIES
-- ═══════════════════════════════════════════════════════════════════

local EnzoUI = {}
EnzoUI.__index = EnzoUI
EnzoUI.Version = "1.0.0"
EnzoUI.Windows = {}
EnzoUI.ToggleKey = Enum.KeyCode.RightShift

-- ═══════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════════
-- EXECUTOR COMPATIBILITY
-- ═══════════════════════════════════════════════════════════════════

local function GetExecutorName()
    if identifyexecutor then
        return identifyexecutor()
    elseif getexecutorname then
        return getexecutorname()
    end
    return "Unknown"
end

local function SafeProtect(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif protect_gui then
        protect_gui(gui)
    elseif gethui then
        gui.Parent = gethui()
        return
    end
    
    pcall(function()
        gui.Parent = CoreGui
    end)
    
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function WriteFile(path, content)
    if writefile then
        writefile(path, content)
        return true
    end
    return false
end

local function ReadFile(path)
    if readfile and isfile and isfile(path) then
        return readfile(path)
    end
    return nil
end

local function MakeFolder(path)
    if makefolder and not isfolder(path) then
        makefolder(path)
        return true
    end
    return false
end

local function IsFolder(path)
    if isfolder then
        return isfolder(path)
    end
    return false
end

local function ListFiles(path)
    if listfiles then
        return listfiles(path)
    end
    return {}
end

local function DeleteFile(path)
    if delfile and isfile and isfile(path) then
        delfile(path)
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════
-- DEVICE DETECTION
-- ═══════════════════════════════════════════════════════════════════

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IsConsole = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════════════════════════════

local Themes = {
    Aurora = {
        Name = "Aurora",
        Primary = Color3.fromRGB(139, 92, 246),
        Secondary = Color3.fromRGB(59, 130, 246),
        Accent = Color3.fromRGB(167, 139, 250),
        Background = Color3.fromRGB(13, 13, 23),
        BackgroundSecondary = Color3.fromRGB(22, 22, 35),
        BackgroundTertiary = Color3.fromRGB(30, 30, 45),
        Border = Color3.fromRGB(50, 50, 70),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        TextMuted = Color3.fromRGB(120, 120, 150),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(139, 92, 246),
        GlowTransparency = 0.7
    },
    Sunset = {
        Name = "Sunset",
        Primary = Color3.fromRGB(255, 107, 53),
        Secondary = Color3.fromRGB(247, 147, 30),
        Accent = Color3.fromRGB(255, 140, 90),
        Background = Color3.fromRGB(20, 15, 12),
        BackgroundSecondary = Color3.fromRGB(30, 22, 18),
        BackgroundTertiary = Color3.fromRGB(40, 30, 25),
        Border = Color3.fromRGB(70, 50, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 180, 170),
        TextMuted = Color3.fromRGB(150, 120, 100),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(255, 107, 53),
        GlowTransparency = 0.7
    },
    Ocean = {
        Name = "Ocean",
        Primary = Color3.fromRGB(6, 182, 212),
        Secondary = Color3.fromRGB(59, 130, 246),
        Accent = Color3.fromRGB(34, 211, 238),
        Background = Color3.fromRGB(10, 22, 40),
        BackgroundSecondary = Color3.fromRGB(15, 30, 55),
        BackgroundTertiary = Color3.fromRGB(20, 40, 70),
        Border = Color3.fromRGB(40, 70, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 200, 220),
        TextMuted = Color3.fromRGB(100, 140, 170),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(6, 182, 212),
        GlowTransparency = 0.7
    },
    Forest = {
        Name = "Forest",
        Primary = Color3.fromRGB(34, 197, 94),
        Secondary = Color3.fromRGB(22, 163, 74),
        Accent = Color3.fromRGB(74, 222, 128),
        Background = Color3.fromRGB(12, 20, 15),
        BackgroundSecondary = Color3.fromRGB(18, 30, 22),
        BackgroundTertiary = Color3.fromRGB(25, 40, 30),
        Border = Color3.fromRGB(45, 70, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 210, 190),
        TextMuted = Color3.fromRGB(120, 160, 130),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(34, 197, 94),
        GlowTransparency = 0.7
    },
    Sakura = {
        Name = "Sakura",
        Primary = Color3.fromRGB(236, 72, 153),
        Secondary = Color3.fromRGB(219, 39, 119),
        Accent = Color3.fromRGB(244, 114, 182),
        Background = Color3.fromRGB(20, 12, 18),
        BackgroundSecondary = Color3.fromRGB(30, 18, 26),
        BackgroundTertiary = Color3.fromRGB(40, 25, 35),
        Border = Color3.fromRGB(70, 45, 60),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(220, 180, 200),
        TextMuted = Color3.fromRGB(170, 120, 150),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(236, 72, 153),
        GlowTransparency = 0.7
    },
    Midnight = {
        Name = "Midnight",
        Primary = Color3.fromRGB(99, 102, 241),
        Secondary = Color3.fromRGB(79, 70, 229),
        Accent = Color3.fromRGB(129, 140, 248),
        Background = Color3.fromRGB(8, 8, 16),
        BackgroundSecondary = Color3.fromRGB(15, 15, 28),
        BackgroundTertiary = Color3.fromRGB(22, 22, 40),
        Border = Color3.fromRGB(45, 45, 70),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 210),
        TextMuted = Color3.fromRGB(110, 110, 150),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(239, 68, 68),
        Info = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(99, 102, 241),
        GlowTransparency = 0.7
    }
}

-- ═══════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

local Utility = {}

function Utility.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[ENZO UI] Error: " .. tostring(result))
    end
    return success, result
end

function Utility.Tween(object, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, easingStyle, easingDirection),
        properties
    )
    tween:Play()
    return tween
end

function Utility.CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility.Ripple(button, x, y)
    local ripple = Utility.Create("Frame", {
        Name = "Ripple",
        Parent = button,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 1
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Utility.Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Utility.GetTextSize(text, fontSize, font, bounds)
    bounds = bounds or Vector2.new(math.huge, math.huge)
    local textSize = TextService:GetTextSize(text, fontSize, font, bounds)
    return textSize
end

function Utility.Truncate(str, maxLength)
    if #str > maxLength then
        return string.sub(str, 1, maxLength - 3) .. "..."
    end
    return str
end

function Utility.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Utility.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utility.LerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

function Utility.HSVToRGB(h, s, v)
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
    
    return Color3.new(r, g, b)
end

function Utility.RGBToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    
    v = max
    
    local d = max - min
    if max == 0 then
        s = 0
    else
        s = d / max
    end
    
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

function Utility.HexToRGB(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 255,
        tonumber(hex:sub(3, 4), 16) or 255,
        tonumber(hex:sub(5, 6), 16) or 255
    )
end

function Utility.RGBToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utility.RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local idx = math.random(1, #chars)
        result = result .. chars:sub(idx, idx)
    end
    return result
end

function Utility.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- ═══════════════════════════════════════════════════════════════════
-- DRAGGING UTILITY
-- ═══════════════════════════════════════════════════════════════════

function Utility.MakeDraggable(frame, dragObject)
    dragObject = dragObject or frame
    
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        Utility.Tween(frame, {
            Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        }, 0.1)
    end
    
    dragObject.InputBegan:Connect(function(input)
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
    
    dragObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- ASCII ART GENERATOR
-- ═══════════════════════════════════════════════════════════════════

local AsciiArt = {}

AsciiArt.Logo = [[
███████╗███╗   ██╗███████╗ ██████╗     ██╗   ██╗██╗
██╔════╝████╗  ██║╚══███╔╝██╔═══██╗    ██║   ██║██║
█████╗  ██╔██╗ ██║  ███╔╝ ██║   ██║    ██║   ██║██║
██╔══╝  ██║╚██╗██║ ███╔╝  ██║   ██║    ██║   ██║██║
███████╗██║ ╚████║███████╗╚██████╔╝    ╚██████╔╝██║
╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝      ╚═════╝ ╚═╝]]

AsciiArt.SmallLogo = [[
╔═══╗
║ E ║  ENZO UI
╚═══╝]]

-- ═══════════════════════════════════════════════════════════════════
-- END PART 1
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- PART 2: WINDOW SYSTEM
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- CREATE SCREENGUI
-- ═══════════════════════════════════════════════════════════════════

local function CreateScreenGui()
    local screenGui = Utility.Create("ScreenGui", {
        Name = "EnzoUI_" .. Utility.RandomString(8),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    SafeProtect(screenGui)
    return screenGui
end

-- ═══════════════════════════════════════════════════════════════════
-- BLUR EFFECT
-- ═══════════════════════════════════════════════════════════════════

local BlurEffect = nil

local function SetBlur(enabled, size)
    size = size or 10
    
    if enabled then
        if not BlurEffect then
            BlurEffect = Instance.new("BlurEffect")
            BlurEffect.Name = "EnzoUI_Blur"
            BlurEffect.Size = 0
            BlurEffect.Parent = game:GetService("Lighting")
        end
        Utility.Tween(BlurEffect, {Size = size}, 0.3)
    else
        if BlurEffect then
            Utility.Tween(BlurEffect, {Size = 0}, 0.3)
            task.delay(0.3, function()
                if BlurEffect then
                    BlurEffect:Destroy()
                    BlurEffect = nil
                end
            end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════

local NotificationHolder = nil
local Notifications = {}

local function CreateNotificationHolder(screenGui)
    if NotificationHolder then return NotificationHolder end
    
    NotificationHolder = Utility.Create("Frame", {
        Name = "NotificationHolder",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 320, 1, -40),
        AnchorPoint = Vector2.new(1, 1)
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right
        })
    })
    
    return NotificationHolder
end

local function Notify(options, theme)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local notifType = options.Type or "Info"
    local duration = options.Duration or 5
    
    theme = theme or Themes.Aurora
    
    local typeColors = {
        Info = theme.Info,
        Success = theme.Success,
        Warning = theme.Warning,
        Error = theme.Error
    }
    
    local typeIcons = {
        Info = "ℹ️",
        Success = "✅",
        Warning = "⚠️",
        Error = "❌"
    }
    
    local color = typeColors[notifType] or theme.Info
    local icon = typeIcons[notifType] or "ℹ️"
    
    local notification = Utility.Create("Frame", {
        Name = "Notification",
        Parent = NotificationHolder,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        LayoutOrder = -tick()
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utility.Create("UIStroke", {
            Color = color,
            Thickness = 1,
            Transparency = 0.5
        }),
        
        -- Glow Effect
        Utility.Create("ImageLabel", {
            Name = "Glow",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 40, 1, 40),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = "rbxassetid://5028857084",
            ImageColor3 = color,
            ImageTransparency = 0.85,
            ZIndex = 0
        }),
        
        -- Side Accent
        Utility.Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0)
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)})
        }),
        
        -- Content Container
        Utility.Create("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -14, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        }, {
            Utility.Create("UIPadding", {
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8)
            }),
            Utility.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            }),
            
            -- Header
            Utility.Create("Frame", {
                Name = "Header",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                LayoutOrder = 1
            }, {
                Utility.Create("TextLabel", {
                    Name = "Icon",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = icon,
                    TextColor3 = color,
                    TextSize = 14
                }),
                Utility.Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 24, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "[" .. string.upper(notifType) .. "] " .. title,
                    TextColor3 = theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                }),
                Utility.Create("TextButton", {
                    Name = "Close",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "×",
                    TextColor3 = theme.TextMuted,
                    TextSize = 18
                })
            }),
            
            -- Message
            Utility.Create("TextLabel", {
                Name = "Message",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = Enum.Font.Gotham,
                Text = content,
                TextColor3 = theme.TextSecondary,
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 2
            }),
            
            -- Progress Bar
            Utility.Create("Frame", {
                Name = "ProgressContainer",
                BackgroundColor3 = theme.BackgroundTertiary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 3),
                LayoutOrder = 3
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Utility.Create("Frame", {
                    Name = "Progress",
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                })
            })
        })
    })
    
    -- Close button functionality
    local closeBtn = notification.Content.Header.Close
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, {TextColor3 = theme.Error}, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, {TextColor3 = theme.TextMuted}, 0.1)
    end)
    
    local function CloseNotification()
        Utility.Tween(notification, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(CloseNotification)
    
    -- Progress bar animation
    local progressBar = notification.Content.ProgressContainer.Progress
    Utility.Tween(progressBar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    
    -- Auto close
    task.delay(duration, function()
        if notification.Parent then
            CloseNotification()
        end
    end)
    
    return notification
end

-- ═══════════════════════════════════════════════════════════════════
-- TOOLTIP SYSTEM
-- ═══════════════════════════════════════════════════════════════════

local TooltipFrame = nil

local function CreateTooltip(screenGui, theme)
    if TooltipFrame then return TooltipFrame end
    
    TooltipFrame = Utility.Create("Frame", {
        Name = "Tooltip",
        Parent = screenGui,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 200, 0, 30),
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false,
        ZIndex = 999
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utility.Create("UIStroke", {
            Color = theme.Border,
            Thickness = 1
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        }),
        Utility.Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = theme.Text,
            TextSize = 12,
            TextWrapped = true,
            ZIndex = 999
        })
    })
    
    return TooltipFrame
end

local function ShowTooltip(text, x, y)
    if not TooltipFrame then return end
    
    TooltipFrame.Text.Text = text
    TooltipFrame.Position = UDim2.new(0, x + 15, 0, y + 15)
    TooltipFrame.Visible = true
end

local function HideTooltip()
    if not TooltipFrame then return end
    TooltipFrame.Visible = false
end

-- ═══════════════════════════════════════════════════════════════════
-- WATERMARK SYSTEM
-- ═══════════════════════════════════════════════════════════════════

local WatermarkFrame = nil
local WatermarkConnection = nil

local function CreateWatermark(screenGui, theme, options)
    options = options or {}
    
    if WatermarkFrame then
        WatermarkFrame:Destroy()
    end
    
    if WatermarkConnection then
        WatermarkConnection:Disconnect()
    end
    
    local startTime = tick()
    
    WatermarkFrame = Utility.Create("Frame", {
        Name = "Watermark",
        Parent = screenGui,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 280, 0, 35),
        AnchorPoint = Vector2.new(1, 0)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utility.Create("UIStroke", {
            Color = theme.Primary,
            Thickness = 1,
            Transparency = 0.5
        }),
        Utility.Create("ImageLabel", {
            Name = "Glow",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 30, 1, 30),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = "rbxassetid://5028857084",
            ImageColor3 = theme.GlowColor,
            ImageTransparency = theme.GlowTransparency,
            ZIndex = 0
        }),
        Utility.Create("TextLabel", {
            Name = "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.Code,
            Text = "💫 FPS: 60 | 📡 Ping: 0ms | ⏱️ 00:00:00",
            TextColor3 = theme.Text,
            TextSize = 12
        })
    })
    
    Utility.MakeDraggable(WatermarkFrame)
    
    -- Update watermark
    WatermarkConnection = RunService.Heartbeat:Connect(function()
        if not WatermarkFrame or not WatermarkFrame.Parent then
            if WatermarkConnection then
                WatermarkConnection:Disconnect()
            end
            return
        end
        
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        local elapsed = tick() - startTime
        local timeStr = Utility.FormatTime(elapsed)
        
        WatermarkFrame.Content.Text = string.format("💫 FPS: %d | 📡 Ping: %dms | ⏱️ %s", fps, ping, timeStr)
    end)
    
    return WatermarkFrame
end

-- ═══════════════════════════════════════════════════════════════════
-- MOBILE TOGGLE BUTTON
-- ═══════════════════════════════════════════════════════════════════

local function CreateMobileButton(screenGui, theme, onClick)
    local mobileButton = Utility.Create("Frame", {
        Name = "MobileToggle",
        Parent = screenGui,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.new(0, 50, 0, 50),
        AnchorPoint = Vector2.new(0, 0.5),
        Visible = IsMobile
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utility.Create("ImageLabel", {
            Name = "Glow",
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 20, 1, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = "rbxassetid://5028857084",
            ImageColor3 = theme.GlowColor,
            ImageTransparency = 0.6,
            ZIndex = 0
        }),
        Utility.Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "E",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 24
        })
    })
    
    Utility.MakeDraggable(mobileButton)
    
    local button = Utility.Create("TextButton", {
        Name = "Button",
        Parent = mobileButton,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    button.MouseButton1Click:Connect(function()
        if onClick then onClick() end
    end)
    
    return mobileButton
end

-- ═══════════════════════════════════════════════════════════════════
-- MAIN WINDOW CREATION
-- ═══════════════════════════════════════════════════════════════════

function EnzoUI:CreateWindow(options)
    options = options or {}
    
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Visible = true
    Window.Minimized = false
    Window.Elements = {}
    Window.SearchableElements = {}
    Window.ConfigElements = {}
    Window.Favorites = {}
    
    -- Options
    local title = options.Title or "ENZO UI"
    local subTitle = options.SubTitle or "Cyberpunk Terminal"
    local size = options.Size or UDim2.new(0, 700, 0, 500)
    local themeName = options.Theme or "Aurora"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local showWatermark = options.Watermark ~= false
    local version = options.Version or EnzoUI.Version
    local blurEnabled = options.Blur ~= false
    local configFolder = options.ConfigFolder or "EnzoUI"
    
    local theme = Themes[themeName] or Themes.Aurora
    Window.Theme = theme
    Window.ConfigFolder = configFolder
    
    -- Create folder for configs
    MakeFolder(configFolder)
    
    -- Create ScreenGui
    local screenGui = CreateScreenGui()
    Window.ScreenGui = screenGui
    
    -- Create notification holder
    CreateNotificationHolder(screenGui)
    
    -- Create tooltip
    CreateTooltip(screenGui, theme)
    
    -- ═══════════════════════════════════════════════════════════════
    -- MAIN WINDOW FRAME
    -- ═══════════════════════════════════════════════════════════════
    
    local mainFrame = Utility.Create("Frame", {
        Name = "MainWindow",
        Parent = screenGui,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    Window.MainFrame = mainFrame
    
    -- ═══════════════════════════════════════════════════════════════
    -- AURORA BORDER (Animated Gradient Border)
    -- ═══════════════════════════════════════════════════════════════
    
    local borderFrame = Utility.Create("Frame", {
        Name = "AuroraBorder",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -2, 0, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = 0
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Utility.Create("UIStroke", {
            Color = theme.Primary,
            Thickness = 2,
            Transparency = 0.3
        })
    })
    
    -- Border animation
    local borderStroke = borderFrame.UIStroke
    local hue = 0
    
    task.spawn(function()
        while mainFrame.Parent do
            hue = (hue + 0.005) % 1
            local color = Utility.LerpColor(theme.Primary, theme.Secondary, math.sin(hue * math.pi * 2) * 0.5 + 0.5)
            borderStroke.Color = color
            task.wait(0.03)
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- GLOW EFFECT
    -- ═══════════════════════════════════════════════════════════════
    
    local glow = Utility.Create("ImageLabel", {
        Name = "Glow",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 60, 1, 60),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5028857084",
        ImageColor3 = theme.GlowColor,
        ImageTransparency = theme.GlowTransparency,
        ZIndex = 0
    })
    
    Window.GlowEffect = glow
    
    -- ═══════════════════════════════════════════════════════════════
    -- HEADER SECTION
    -- ═══════════════════════════════════════════════════════════════
    
    local header = Utility.Create("Frame", {
        Name = "Header",
        Parent = mainFrame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 80)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    -- Fix bottom corners
    local headerFix = Utility.Create("Frame", {
        Name = "HeaderFix",
        Parent = header,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10)
    })
    
    -- ASCII Logo
    local logoText = Utility.Create("TextLabel", {
        Name = "Logo",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 5),
        Size = UDim2.new(0, 400, 0, 50),
        Font = Enum.Font.Code,
        Text = "[ ENZO UI ]  //  CYBER TERMINAL  //  ROOT@ENZO:~#",
        TextColor3 = theme.Primary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(0.7, -15, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = ">_ " .. title,
        TextColor3 = theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- SubTitle
    local subTitleLabel = Utility.Create("TextLabel", {
        Name = "SubTitle",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 58),
        Size = UDim2.new(0.7, -15, 0, 16),
        Font = Enum.Font.Code,
        Text = "// " .. subTitle .. " v" .. version,
        TextColor3 = theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Window Controls
    local controls = Utility.Create("Frame", {
        Name = "Controls",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 10),
        Size = UDim2.new(0, 90, 0, 25)
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8)
        })
    })
    
    -- Settings Button
    local settingsBtn = Utility.Create("TextButton", {
        Name = "Settings",
        Parent = controls,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "⚙",
        TextColor3 = theme.TextSecondary,
        TextSize = 14,
        LayoutOrder = 1
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Minimize Button
    local minimizeBtn = Utility.Create("TextButton", {
        Name = "Minimize",
        Parent = controls,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "─",
        TextColor3 = theme.TextSecondary,
        TextSize = 14,
        LayoutOrder = 2
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Close Button
    local closeBtn = Utility.Create("TextButton", {
        Name = "Close",
        Parent = controls,
        BackgroundColor3 = theme.Error,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        LayoutOrder = 3
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Make header draggable
    Utility.MakeDraggable(mainFrame, header)
    
    -- ═══════════════════════════════════════════════════════════════
    -- TAB NAVIGATION
    -- ═══════════════════════════════════════════════════════════════
    
    local tabContainer = Utility.Create("Frame", {
        Name = "TabContainer",
        Parent = mainFrame,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 0, 45)
    })
    
    local tabScroll = Utility.Create("ScrollingFrame", {
        Name = "TabScroll",
        Parent = tabContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 5),
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        })
    })
    
    -- ═══════════════════════════════════════════════════════════════
    -- CONTENT AREA
    -- ═══════════════════════════════════════════════════════════════
    
    local contentArea = Utility.Create("Frame", {
        Name = "ContentArea",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 125),
        Size = UDim2.new(1, 0, 1, -125)
    })
    
    Window.ContentArea = contentArea
    
    -- ═══════════════════════════════════════════════════════════════
    -- WINDOW CONTROLS FUNCTIONALITY
    -- ═══════════════════════════════════════════════════════════════
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}, 0.1)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, {BackgroundColor3 = theme.Error}, 0.1)
    end)
    
    -- Minimize button
    minimizeBtn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
    
    minimizeBtn.MouseEnter:Connect(function()
        Utility.Tween(minimizeBtn, {BackgroundColor3 = theme.Primary}, 0.1)
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        Utility.Tween(minimizeBtn, {BackgroundColor3 = theme.BackgroundTertiary}, 0.1)
    end)
    
    -- Settings button (will open settings panel)
    settingsBtn.MouseEnter:Connect(function()
        Utility.Tween(settingsBtn, {BackgroundColor3 = theme.Primary}, 0.1)
    end)
    
    settingsBtn.MouseLeave:Connect(function()
        Utility.Tween(settingsBtn, {BackgroundColor3 = theme.BackgroundTertiary}, 0.1)
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- CREATE WATERMARK
    -- ═══════════════════════════════════════════════════════════════
    
    if showWatermark then
        Window.Watermark = CreateWatermark(screenGui, theme)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- CREATE MOBILE BUTTON
    -- ═══════════════════════════════════════════════════════════════
    
    if IsMobile then
        Window.MobileButton = CreateMobileButton(screenGui, theme, function()
            Window:Toggle()
        end)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- SET BLUR
    -- ═══════════════════════════════════════════════════════════════
    
    if blurEnabled then
        SetBlur(true)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- KEYBIND TOGGLE
    -- ═══════════════════════════════════════════════════════════════
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == toggleKey then
            Window:Toggle()
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- WINDOW METHODS
    -- ═══════════════════════════════════════════════════════════════
    
    function Window:Toggle()
        self.Visible = not self.Visible
        
        if self.Visible then
            mainFrame.Visible = true
            Utility.Tween(mainFrame, {
                Size = size,
                BackgroundTransparency = 0
            }, 0.3)
            if blurEnabled then SetBlur(true) end
        else
            Utility.Tween(mainFrame, {
                Size = UDim2.new(0, size.X.Offset, 0, 0),
                BackgroundTransparency = 1
            }, 0.3)
            task.delay(0.3, function()
                mainFrame.Visible = false
            end)
            if blurEnabled then SetBlur(false) end
        end
    end
    
    function Window:Minimize()
        self.Minimized = not self.Minimized
        
        if self.Minimized then
            Utility.Tween(mainFrame, {
                Size = UDim2.new(0, size.X.Offset, 0, 80)
            }, 0.3)
            contentArea.Visible = false
            tabContainer.Visible = false
            minimizeBtn.Text = "+"
        else
            Utility.Tween(mainFrame, {
                Size = size
            }, 0.3)
            task.delay(0.15, function()
                contentArea.Visible = true
                tabContainer.Visible = true
            end)
            minimizeBtn.Text = "─"
        end
    end
    
    function Window:Restore()
        if self.Minimized then
            self:Minimize()
        end
        if not self.Visible then
            self:Toggle()
        end
    end
    
    function Window:Destroy()
        SetBlur(false)
        
        Utility.Tween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        
        if WatermarkConnection then
            WatermarkConnection:Disconnect()
        end
        
        task.delay(0.3, function()
            screenGui:Destroy()
        end)
    end
    
    function Window:SetBlur(enabled)
        SetBlur(enabled)
    end
    
    function Window:Notify(options)
        return Notify(options, self.Theme)
    end
    
    function Window:SetTheme(newThemeName)
        local newTheme = Themes[newThemeName]
        if not newTheme then return end
        
        self.Theme = newTheme
        theme = newTheme
        
        -- Update colors (simplified - full implementation would update all elements)
        Utility.Tween(mainFrame, {BackgroundColor3 = newTheme.Background}, 0.3)
        Utility.Tween(header, {BackgroundColor3 = newTheme.BackgroundSecondary}, 0.3)
        Utility.Tween(glow, {ImageColor3 = newTheme.GlowColor}, 0.3)
        borderStroke.Color = newTheme.Primary
        titleLabel.TextColor3 = newTheme.Text
        logoText.TextColor3 = newTheme.Primary
    end
    
    function Window:SetOpacity(opacity)
        local transparency = 1 - opacity
        mainFrame.BackgroundTransparency = transparency * 0.5
        header.BackgroundTransparency = transparency * 0.3
        
        -- Keep glow visible
        glow.ImageTransparency = math.max(0.5, theme.GlowTransparency - (opacity * 0.2))
    end
    
    -- Store window reference
    table.insert(EnzoUI.Windows, Window)
    
    return Window
end

-- ═══════════════════════════════════════════════════════════════════
-- END PART 2
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- PART 3: TAB & SECTION SYSTEM
-- ═══════════════════════════════════════════════════════════════════

-- Add to Window methods (continued from Part 2)

function EnzoUI:CreateWindow(options)
    -- ... (previous code from Part 2)
    
    -- ═══════════════════════════════════════════════════════════════
    -- ADD TAB METHOD
    -- ═══════════════════════════════════════════════════════════════
    
    function Window:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        
        local Tab = {}
        Tab.Sections = {}
        Tab.Name = tabOptions.Title or "Tab"
        Tab.Icon = tabOptions.Icon or "📁"
        Tab.Badge = 0
        
        local theme = self.Theme
        local isFirst = #self.Tabs == 0
        
        -- ═══════════════════════════════════════════════════════════
        -- TAB BUTTON
        -- ═══════════════════════════════════════════════════════════
        
        local tabButton = Utility.Create("TextButton", {
            Name = Tab.Name,
            Parent = tabScroll,
            BackgroundColor3 = isFirst and theme.Primary or theme.BackgroundTertiary,
            BackgroundTransparency = isFirst and 0 or 0.5,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = theme.Text,
            TextSize = 12
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Utility.Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12)
            }),
            Utility.Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6)
            }),
            
            -- Icon
            Utility.Create("TextLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Font = Enum.Font.GothamBold,
                Text = Tab.Icon,
                TextColor3 = theme.Text,
                TextSize = 12,
                LayoutOrder = 1
            }),
            
            -- Title
            Utility.Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 16),
                AutomaticSize = Enum.AutomaticSize.X,
                Font = Enum.Font.GothamBold,
                Text = Tab.Name,
                TextColor3 = theme.Text,
                TextSize = 11,
                LayoutOrder = 2
            }),
            
            -- Badge
            Utility.Create("Frame", {
                Name = "Badge",
                BackgroundColor3 = theme.Error,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 16, 0, 16),
                Visible = false,
                LayoutOrder = 3
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Utility.Create("TextLabel", {
                    Name = "Count",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "0",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10
                })
            })
        })
        
        Tab.Button = tabButton
        
        -- Active indicator
        local activeIndicator = Utility.Create("Frame", {
            Name = "ActiveIndicator",
            Parent = tabButton,
            BackgroundColor3 = theme.Primary,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 1, -3),
            Size = UDim2.new(isFirst and 0.8 or 0, 0, 0, 2),
            AnchorPoint = Vector2.new(0.5, 0)
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        
        -- ═══════════════════════════════════════════════════════════
        -- TAB CONTENT
        -- ═══════════════════════════════════════════════════════════
        
        local tabContent = Utility.Create("ScrollingFrame", {
            Name = Tab.Name .. "Content",
            Parent = contentArea,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 1, -20),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Primary,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = isFirst
        }, {
            Utility.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
        })
        
        Tab.Content = tabContent
        
        -- Two Column Container
        local columnContainer = Utility.Create("Frame", {
            Name = "ColumnContainer",
            Parent = tabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        }, {
            Utility.Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 10)
            })
        })
        
        -- Left Column
        local leftColumn = Utility.Create("Frame", {
            Name = "LeftColumn",
            Parent = columnContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1
        }, {
            Utility.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
        })
        
        -- Right Column
        local rightColumn = Utility.Create("Frame", {
            Name = "RightColumn",
            Parent = columnContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2
        }, {
            Utility.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
        })
        
        Tab.LeftColumn = leftColumn
        Tab.RightColumn = rightColumn
        
        -- ═══════════════════════════════════════════════════════════
        -- TAB BUTTON FUNCTIONALITY
        -- ═══════════════════════════════════════════════════════════
        
        local function SelectTab()
            -- Deselect all tabs
            for _, tab in ipairs(self.Tabs) do
                Utility.Tween(tab.Button, {
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BackgroundTransparency = 0.5
                }, 0.2)
                Utility.Tween(tab.Button.ActiveIndicator, {
                    Size = UDim2.new(0, 0, 0, 2)
                }, 0.2)
                tab.Content.Visible = false
            end
            
            -- Select this tab
            Utility.Tween(tabButton, {
                BackgroundColor3 = theme.Primary,
                BackgroundTransparency = 0
            }, 0.2)
            Utility.Tween(activeIndicator, {
                Size = UDim2.new(0.8, 0, 0, 2)
            }, 0.2)
            tabContent.Visible = true
            
            self.ActiveTab = Tab
        end
        
        tabButton.MouseButton1Click:Connect(SelectTab)
        
        tabButton.MouseEnter:Connect(function()
            if self.ActiveTab ~= Tab then
                Utility.Tween(tabButton, {BackgroundTransparency = 0.3}, 0.1)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if self.ActiveTab ~= Tab then
                Utility.Tween(tabButton, {BackgroundTransparency = 0.5}, 0.1)
            end
        end)
        
        -- ═══════════════════════════════════════════════════════════
        -- TAB METHODS
        -- ═══════════════════════════════════════════════════════════
        
        function Tab:SetBadge(count)
            self.Badge = count
            local badge = tabButton.Badge
            
            if count > 0 then
                badge.Visible = true
                badge.Count.Text = count > 99 and "99+" or tostring(count)
            else
                badge.Visible = false
            end
        end
        
        function Tab:AddSection(sectionOptions)
            sectionOptions = sectionOptions or {}
            
            local Section = {}
            Section.Elements = {}
            Section.Name = sectionOptions.Title or "Section"
            Section.Icon = sectionOptions.Icon or "📌"
            
            local side = sectionOptions.Side or "Left"
            local parent = side == "Right" and rightColumn or leftColumn
            
            -- ═══════════════════════════════════════════════════════
            -- SECTION FRAME
            -- ═══════════════════════════════════════════════════════
            
            local sectionFrame = Utility.Create("Frame", {
                Name = Section.Name,
                Parent = parent,
                BackgroundColor3 = theme.BackgroundSecondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #Tab.Sections
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Utility.Create("UIStroke", {
                    Color = theme.Border,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            
            Section.Frame = sectionFrame
            
            -- Section Header
            local sectionHeader = Utility.Create("Frame", {
                Name = "Header",
                Parent = sectionFrame,
                BackgroundColor3 = theme.BackgroundTertiary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 35)
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                
                -- Fix bottom corners
                Utility.Create("Frame", {
                    Name = "Fix",
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -8),
                    Size = UDim2.new(1, 0, 0, 8)
                }),
                
                Utility.Create("TextLabel", {
                    Name = "Icon",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font = Enum.Font.GothamBold,
                    Text = Section.Icon,
                    TextColor3 = theme.Primary,
                    TextSize = 14
                }),
                
                Utility.Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 35, 0.5, 0),
                    Size = UDim2.new(1, -45, 0, 20),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font = Enum.Font.GothamBold,
                    Text = ">_ " .. string.upper(Section.Name),
                    TextColor3 = theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
            
            -- Section Content
            local sectionContent = Utility.Create("Frame", {
                Name = "Content",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            }, {
                Utility.Create("UIPadding", {
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                }),
                Utility.Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                })
            })
            
            Section.Content = sectionContent
            
            -- Store section reference
            table.insert(Tab.Sections, Section)
            
            -- ═══════════════════════════════════════════════════════
            -- SECTION: ADD LABEL
            -- ═══════════════════════════════════════════════════════
            
            function Section:AddLabel(labelOptions)
                labelOptions = labelOptions or {}
                
                local Label = {}
                Label.Type = "Label"
                Label.Text = labelOptions.Text or "Label"
                
                local labelFrame = Utility.Create("Frame", {
                    Name = "Label",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    LayoutOrder = #Section.Elements
                })
                
                local labelText = Utility.Create("TextLabel", {
                    Name = "Text",
                    Parent = labelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Code,
                    Text = ">> " .. Label.Text,
                    TextColor3 = theme.TextSecondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                Label.Frame = labelFrame
                Label.TextLabel = labelText
                
                function Label:SetText(newText)
                    Label.Text = newText
                    labelText.Text = ">> " .. newText
                end
                
                table.insert(Section.Elements, Label)
                Window.Elements[#Window.Elements + 1] = Label
                
                return Label
            end
            
            -- ═══════════════════════════════════════════════════════
            -- SECTION: ADD DIVIDER
            -- ═══════════════════════════════════════════════════════
            
            function Section:AddDivider(dividerOptions)
                dividerOptions = dividerOptions or {}
                
                local Divider = {}
                Divider.Type = "Divider"
                Divider.Text = dividerOptions.Text
                
                local dividerFrame = Utility.Create("Frame", {
                    Name = "Divider",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, dividerOptions.Text and 25 or 15),
                    LayoutOrder = #Section.Elements
                })
                
                if dividerOptions.Text then
                    -- Divider with text
                    Utility.Create("Frame", {
                        Name = "LeftLine",
                        Parent = dividerFrame,
                        BackgroundColor3 = theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(0.3, -5, 0, 1),
                        AnchorPoint = Vector2.new(0, 0.5)
                    })
                    
                    Utility.Create("TextLabel", {
                        Name = "Text",
                        Parent = dividerFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0.4, 0, 1, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Font = Enum.Font.Code,
                        Text = "══ " .. dividerOptions.Text .. " ══",
                        TextColor3 = theme.TextMuted,
                        TextSize = 11
                    })
                    
                    Utility.Create("Frame", {
                        Name = "RightLine",
                        Parent = dividerFrame,
                        BackgroundColor3 = theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0.3, -5, 0, 1),
                        AnchorPoint = Vector2.new(1, 0.5)
                    })
                else
                    -- Simple line divider
                    Utility.Create("Frame", {
                        Name = "Line",
                        Parent = dividerFrame,
                        BackgroundColor3 = theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 0, 1),
                        AnchorPoint = Vector2.new(0.5, 0.5)
                    })
                end
                
                Divider.Frame = dividerFrame
                table.insert(Section.Elements, Divider)
                
                return Divider
            end
            
            return Section
        end
        
        -- Select first tab
        if isFirst then
            self.ActiveTab = Tab
        end
        
        table.insert(self.Tabs, Tab)
        
        return Tab
    end
    
    return Window
end

-- ═══════════════════════════════════════════════════════════════════
-- END PART 3
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- PART 4: ELEMENTS (Toggle, Slider, Button)
-- ═══════════════════════════════════════════════════════════════════

-- Add these methods to Section (continued from Part 3)

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD TOGGLE
-- ═══════════════════════════════════════════════════════════════════

function Section:AddToggle(toggleOptions)
    toggleOptions = toggleOptions or {}
    
    local Toggle = {}
    Toggle.Type = "Toggle"
    Toggle.Name = toggleOptions.Title or "Toggle"
    Toggle.Value = toggleOptions.Default or false
    Toggle.Callback = toggleOptions.Callback or function() end
    Toggle.Flag = toggleOptions.Flag
    
    local theme = Window.Theme
    
    local toggleFrame = Utility.Create("Frame", {
        Name = "Toggle_" .. Toggle.Name,
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, toggleOptions.Description and 50 or 35),
        LayoutOrder = #Section.Elements
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Parent = toggleFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, toggleOptions.Description and 8 or 0),
        Size = UDim2.new(1, -70, 0, toggleOptions.Description and 18 or 35),
        Font = Enum.Font.GothamBold,
        Text = ">> " .. Toggle.Name,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Description
    if toggleOptions.Description then
        Utility.Create("TextLabel", {
            Name = "Description",
            Parent = toggleFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 26),
            Size = UDim2.new(1, -70, 0, 16),
            Font = Enum.Font.Gotham,
            Text = toggleOptions.Description,
            TextColor3 = theme.TextMuted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })
    end
    
    -- Toggle Switch Container
    local switchContainer = Utility.Create("Frame", {
        Name = "Switch",
        Parent = toggleFrame,
        BackgroundColor3 = Toggle.Value and theme.Primary or theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -55, 0.5, 0),
        Size = UDim2.new(0, 45, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Toggle Knob
    local knob = Utility.Create("Frame", {
        Name = "Knob",
        Parent = switchContainer,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = Toggle.Value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Status Text
    local statusText = Utility.Create("TextLabel", {
        Name = "Status",
        Parent = switchContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -22, 1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Font = Enum.Font.Code,
        Text = Toggle.Value and "ON" or "OFF",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 8,
        Visible = false
    })
    
    Toggle.Frame = toggleFrame
    
    -- Toggle Function
    local function SetValue(value, skipCallback)
        Toggle.Value = value
        
        Utility.Tween(switchContainer, {
            BackgroundColor3 = value and theme.Primary or theme.Border
        }, 0.2)
        
        Utility.Tween(knob, {
            Position = value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.2)
        
        statusText.Text = value and "ON" or "OFF"
        
        if not skipCallback then
            Toggle.Callback(value)
        end
        
        -- Update config
        if Toggle.Flag then
            Window.ConfigElements[Toggle.Flag] = value
        end
    end
    
    -- Click Handler
    local clickButton = Utility.Create("TextButton", {
        Name = "ClickArea",
        Parent = toggleFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    clickButton.MouseButton1Click:Connect(function()
        SetValue(not Toggle.Value)
    end)
    
    -- Hover Effects
    clickButton.MouseEnter:Connect(function()
        Utility.Tween(toggleFrame, {BackgroundColor3 = theme.BackgroundSecondary}, 0.1)
    end)
    
    clickButton.MouseLeave:Connect(function()
        Utility.Tween(toggleFrame, {BackgroundColor3 = theme.BackgroundTertiary}, 0.1)
    end)
    
    -- Tooltip
    if toggleOptions.Tooltip then
        clickButton.MouseEnter:Connect(function()
            ShowTooltip(toggleOptions.Tooltip, Mouse.X, Mouse.Y)
        end)
        clickButton.MouseLeave:Connect(function()
            HideTooltip()
        end)
    end
    
    -- Methods
    function Toggle:SetValue(value)
        SetValue(value, true)
    end
    
    function Toggle:GetValue()
        return Toggle.Value
    end
    
    -- Initialize
    if Toggle.Value then
        Toggle.Callback(true)
    end
    
    if Toggle.Flag then
        Window.ConfigElements[Toggle.Flag] = Toggle.Value
    end
    
    table.insert(Section.Elements, Toggle)
    Window.Elements[#Window.Elements + 1] = Toggle
    Window.SearchableElements[Toggle.Name] = Toggle
    
    return Toggle
end

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD SLIDER
-- ═══════════════════════════════════════════════════════════════════

function Section:AddSlider(sliderOptions)
    sliderOptions = sliderOptions or {}
    
    local Slider = {}
    Slider.Type = "Slider"
    Slider.Name = sliderOptions.Title or "Slider"
    Slider.Min = sliderOptions.Min or 0
    Slider.Max = sliderOptions.Max or 100
    Slider.Value = sliderOptions.Default or Slider.Min
    Slider.Increment = sliderOptions.Increment or 1
    Slider.Suffix = sliderOptions.Suffix or ""
    Slider.Callback = sliderOptions.Callback or function() end
    Slider.Flag = sliderOptions.Flag
    
    local theme = Window.Theme
    
    local sliderFrame = Utility.Create("Frame", {
        Name = "Slider_" .. Slider.Name,
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, sliderOptions.Description and 60 or 50),
        LayoutOrder = #Section.Elements
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(0.6, -10, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = ">> " .. Slider.Name,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Value Display
    local valueLabel = Utility.Create("TextLabel", {
        Name = "Value",
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0, 8),
        Size = UDim2.new(0.4, 0, 0, 16),
        AnchorPoint = Vector2.new(1, 0),
        Font = Enum.Font.Code,
        Text = tostring(Slider.Value) .. Slider.Suffix,
        TextColor3 = theme.Primary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Description
    if sliderOptions.Description then
        Utility.Create("TextLabel", {
            Name = "Description",
            Parent = sliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 24),
            Size = UDim2.new(1, -20, 0, 14),
            Font = Enum.Font.Gotham,
            Text = sliderOptions.Description,
            TextColor3 = theme.TextMuted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })
    end
    
    -- Slider Track
    local trackY = sliderOptions.Description and 42 or 32
    local sliderTrack = Utility.Create("Frame", {
        Name = "Track",
        Parent = sliderFrame,
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, trackY),
        Size = UDim2.new(1, -20, 0, 6)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    -- Slider Fill
    local initialPercent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
    local sliderFill = Utility.Create("Frame", {
        Name = "Fill",
        Parent = sliderTrack,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(initialPercent, 0, 1, 0)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utility.Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, theme.Secondary),
                ColorSequenceKeypoint.new(1, theme.Primary)
            })
        })
    })
    
    -- Slider Knob
    local sliderKnob = Utility.Create("Frame", {
        Name = "Knob",
        Parent = sliderTrack,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(initialPercent, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 2
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utility.Create("UIStroke", {
            Color = theme.Primary,
            Thickness = 2
        })
    })
    
    Slider.Frame = sliderFrame
    
    -- Slider Logic
    local dragging = false
    
    local function SetValue(value, skipCallback)
        value = math.clamp(value, Slider.Min, Slider.Max)
        
        -- Round to increment
        value = math.floor(value / Slider.Increment + 0.5) * Slider.Increment
        value = math.clamp(value, Slider.Min, Slider.Max)
        
        -- Round to avoid floating point issues
        if Slider.Increment >= 1 then
            value = math.floor(value)
        else
            value = tonumber(string.format("%.2f", value))
        end
        
        Slider.Value = value
        
        local percent = (value - Slider.Min) / (Slider.Max - Slider.Min)
        
        Utility.Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        Utility.Tween(sliderKnob, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.1)
        
        valueLabel.Text = tostring(value) .. Slider.Suffix
        
        if not skipCallback then
            Slider.Callback(value)
        end
        
        if Slider.Flag then
            Window.ConfigElements[Slider.Flag] = value
        end
    end
    
    local function UpdateSlider(input)
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackSize = sliderTrack.AbsoluteSize.X
        
        local percent = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
        local value = Slider.Min + (Slider.Max - Slider.Min) * percent
        
        SetValue(value)
    end
    
    -- Input Handling
    local inputButton = Utility.Create("TextButton", {
        Name = "InputArea",
        Parent = sliderTrack,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 10),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = ""
    })
    
    inputButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    
    inputButton.MouseButton1Click:Connect(function()
        local input = {Position = Vector3.new(Mouse.X, Mouse.Y, 0)}
        UpdateSlider(input)
    end)
    
    -- Hover Effects
    sliderFrame.MouseEnter:Connect(function()
        Utility.Tween(sliderFrame, {BackgroundColor3 = theme.BackgroundSecondary}, 0.1)
    end)
    
    sliderFrame.MouseLeave:Connect(function()
        Utility.Tween(sliderFrame, {BackgroundColor3 = theme.BackgroundTertiary}, 0.1)
    end)
    
    -- Tooltip
    if sliderOptions.Tooltip then
        sliderFrame.MouseEnter:Connect(function()
            ShowTooltip(sliderOptions.Tooltip, Mouse.X, Mouse.Y)
        end)
        sliderFrame.MouseLeave:Connect(function()
            HideTooltip()
        end)
    end
    
    -- Methods
    function Slider:SetValue(value)
        SetValue(value, true)
    end
    
    function Slider:GetValue()
        return Slider.Value
    end
    
    -- Initialize
    if Slider.Flag then
        Window.ConfigElements[Slider.Flag] = Slider.Value
    end
    
    table.insert(Section.Elements, Slider)
    Window.Elements[#Window.Elements + 1] = Slider
    Window.SearchableElements[Slider.Name] = Slider
    
    return Slider
end

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD BUTTON
-- ═══════════════════════════════════════════════════════════════════

function Section:AddButton(buttonOptions)
    buttonOptions = buttonOptions or {}
    
    local Button = {}
    Button.Type = "Button"
    Button.Name = buttonOptions.Title or "Button"
    Button.Style = buttonOptions.Style or "Primary"
    Button.Callback = buttonOptions.Callback or function() end
    
    local theme = Window.Theme
    
    local styleColors = {
        Primary = theme.Primary,
        Secondary = theme.BackgroundTertiary,
        Success = theme.Success,
        Danger = theme.Error
    }
    
    local buttonColor = styleColors[Button.Style] or theme.Primary
    
    local buttonFrame = Utility.Create("Frame", {
        Name = "Button_" .. Button.Name,
        Parent = sectionContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35),
        LayoutOrder = #Section.Elements
    })
    
    local button = Utility.Create("TextButton", {
        Name = "Button",
        Parent = buttonFrame,
        BackgroundColor3 = buttonColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utility.Create("UIStroke", {
            Color = buttonColor,
            Thickness = 1,
            Transparency = 0.5
        }),
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8)
        }),
        Utility.Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = "⚡",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            LayoutOrder = 1
        }),
        Utility.Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = Button.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            LayoutOrder = 2
        })
    })
    
    Button.Frame = buttonFrame
    Button.Button = button
    
    -- Click Handler
    button.MouseButton1Click:Connect(function()
        -- Ripple effect
        Utility.Ripple(button, Mouse.X, Mouse.Y)
        
        -- Click animation
        Utility.Tween(button, {Size = UDim2.new(0.98, 0, 0.9, 0)}, 0.1)
        task.wait(0.1)
        Utility.Tween(button, {Size = UDim2.new(1, 0, 1, 0)}, 0.1)
        
        Button.Callback()
    end)
    
    -- Hover Effects
    local originalColor = buttonColor
    
    button.MouseEnter:Connect(function()
        Utility.Tween(button, {
            BackgroundColor3 = Color3.new(
                math.min(originalColor.R + 0.1, 1),
                math.min(originalColor.G + 0.1, 1),
                math.min(originalColor.B + 0.1, 1)
            )
        }, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = originalColor}, 0.1)
    end)
    
    -- Tooltip
    if buttonOptions.Tooltip then
        button.MouseEnter:Connect(function()
            ShowTooltip(buttonOptions.Tooltip, Mouse.X, Mouse.Y)
        end)
        button.MouseLeave:Connect(function()
            HideTooltip()
        end)
    end
    
    table.insert(Section.Elements, Button)
    Window.Elements[#Window.Elements + 1] = Button
    
    return Button
end

-- ═══════════════════════════════════════════════════════════════════
-- END PART 4
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- PART 5: ELEMENTS (Input, Dropdown, Keybind)
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD INPUT (TextBox)
-- ═══════════════════════════════════════════════════════════════════

function Section:AddInput(inputOptions)
    inputOptions = inputOptions or {}
    
    local Input = {}
    Input.Type = "Input"
    Input.Name = inputOptions.Title or "Input"
    Input.Value = inputOptions.Default or ""
    Input.Placeholder = inputOptions.Placeholder or "Enter text..."
    Input.InputType = inputOptions.Type or "String" -- String, Number, Integer
    Input.Min = inputOptions.Min
    Input.Max = inputOptions.Max
    Input.Callback = inputOptions.Callback or function() end
    Input.Flag = inputOptions.Flag
    
    local theme = Window.Theme
    
    local inputFrame = Utility.Create("Frame", {
        Name = "Input_" .. Input.Name,
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, inputOptions.Description and 70 or 55),
        LayoutOrder = #Section.Elements
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Title
    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = inputFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = ">> " .. Input.Name,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Description
    if inputOptions.Description then
        Utility.Create("TextLabel", {
            Name = "Description",
            Parent = inputFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 24),
            Size = UDim2.new(1, -20, 0, 14),
            Font = Enum.Font.Gotham,
            Text = inputOptions.Description,
            TextColor3 = theme.TextMuted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    
    -- TextBox Container
    local boxY = inputOptions.Description and 42 or 28
    local textBoxContainer = Utility.Create("Frame", {
        Name = "TextBoxContainer",
        Parent = inputFrame,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, boxY),
        Size = UDim2.new(1, -20, 0, 22)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIStroke", {
            Color = theme.Border,
            Thickness = 1
        })
    })
    
    -- TextBox
    local textBox = Utility.Create("TextBox", {
        Name = "TextBox",
        Parent = textBoxContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Enum.Font.Code,
        Text = Input.Value,
        PlaceholderText = Input.Placeholder,
        PlaceholderColor3 = theme.TextMuted,
        TextColor3 = theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })
    
    Input.Frame = inputFrame
    Input.TextBox = textBox
    
    -- Focus Effects
    textBox.Focused:Connect(function()
        Utility.Tween(textBoxContainer.UIStroke, {Color = theme.Primary}, 0.2)
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        Utility.Tween(textBoxContainer.UIStroke, {Color = theme.Border}, 0.2)
        
        local value = textBox.Text
        
        -- Validate based on type
        if Input.InputType == "Number" then
            value = tonumber(value) or Input.Value
            if Input.Min then value = math.max(value, Input.Min) end
            if Input.Max then value = math.min(value, Input.Max) end
            textBox.Text = tostring(value)
        elseif Input.InputType == "Integer" then
            value = math.floor(tonumber(value) or Input.Value)
            if Input.Min then value = math.max(value, Input.Min) end
            if Input.Max then value = math.min(value, Input.Max) end
            textBox.Text = tostring(value)
        end
        
        Input.Value = value
        Input.Callback(value)
        
        if Input.Flag then
            Window.ConfigElements[Input.Flag] = value
        end
    end)
    
    -- Hover Effects
    inputFrame.MouseEnter:Connect(function()
        Utility.Tween(inputFrame, {BackgroundColor3 = theme.BackgroundSecondary}, 0.1)
    end)
    
    inputFrame.MouseLeave:Connect(function()
        Utility.Tween(inputFrame, {BackgroundColor3 = theme.BackgroundTertiary}, 0.1)
    end)
    
    -- Methods
    function Input:SetValue(value)
        Input.Value = value
        textBox.Text = tostring(value)
    end
    
    function Input:GetValue()
        return Input.Value
    end
    
    if Input.Flag then
        Window.ConfigElements[Input.Flag] = Input.Value
    end
    
    table.insert(Section.Elements, Input)
    Window.Elements[#Window.Elements + 1] = Input
    Window.SearchableElements[Input.Name] = Input
    
    return Input
end

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD DROPDOWN
-- ═══════════════════════════════════════════════════════════════════

function Section:AddDropdown(dropdownOptions)
    dropdownOptions = dropdownOptions or {}
    
    local Dropdown = {}
    Dropdown.Type = "Dropdown"
    Dropdown.Name = dropdownOptions.Title or "Dropdown"
    Dropdown.Items = dropdownOptions.Items or {}
    Dropdown.Value = dropdownOptions.Default
    Dropdown.Multi = dropdownOptions.Multi or false
    Dropdown.Callback = dropdownOptions.Callback or function() end
    Dropdown.Flag = dropdownOptions.Flag
    Dropdown.Open = false
    
    if Dropdown.Multi then
        Dropdown.Value = dropdownOptions.Default or {}
    else
        Dropdown.Value = dropdownOptions.Default or (Dropdown.Items[1] or "")
    end
    
    local theme = Window.Theme
    
    local dropdownFrame = Utility.Create("Frame", {
        Name = "Dropdown_" .. Dropdown.Name,
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 55),
        ClipsDescendants = false,
        LayoutOrder = #Section.Elements,
        ZIndex = 10
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Title
    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = dropdownFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = ">> " .. Dropdown.Name,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })
    
    -- Dropdown Button
    local dropdownButton = Utility.Create("TextButton", {
        Name = "DropdownButton",
        Parent = dropdownFrame,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 28),
        Size = UDim2.new(1, -20, 0, 22),
        Font = Enum.Font.Code,
        Text = "",
        TextColor3 = theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 10
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIStroke", {
            Color = theme.Border,
            Thickness = 1
        })
    })
    
    -- Selected Text
    local function GetDisplayText()
        if Dropdown.Multi then
            if #Dropdown.Value == 0 then
                return "Select..."
            elseif #Dropdown.Value == #Dropdown.Items then
                return "All Selected"
            else
                return table.concat(Dropdown.Value, ", ")
            end
        else
            return Dropdown.Value or "Select..."
        end
    end
    
    local selectedText = Utility.Create("TextLabel", {
        Name = "SelectedText",
        Parent = dropdownButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.Code,
        Text = GetDisplayText(),
        TextColor3 = theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 10
    })
    
    -- Arrow
    local arrow = Utility.Create("TextLabel", {
        Name = "Arrow",
        Parent = dropdownButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0, 0.5),
        Font = Enum.Font.GothamBold,
        Text = "▼",
        TextColor3 = theme.TextMuted,
        TextSize = 10,
        ZIndex = 10
    })
    
    -- Options Container
    local optionsContainer = Utility.Create("Frame", {
        Name = "OptionsContainer",
        Parent = dropdownFrame,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 52),
        Size = UDim2.new(1, -20, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIStroke", {
            Color = theme.Primary,
            Thickness = 1
        }),
        Utility.Create("ScrollingFrame", {
            Name = "Scroll",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Primary,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 100
        }, {
            Utility.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            }),
            Utility.Create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4)
            })
        })
    })
    
    local optionsScroll = optionsContainer.Scroll
    
    Dropdown.Frame = dropdownFrame
    Dropdown.OptionsContainer = optionsContainer
    
    -- Create option items
    local function CreateOptions()
        for _, child in ipairs(optionsScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Multi-select controls
        if Dropdown.Multi then
            -- Select All
            local selectAllBtn = Utility.Create("TextButton", {
                Name = "SelectAll",
                Parent = optionsScroll,
                BackgroundColor3 = theme.Success,
                BackgroundTransparency = 0.8,
                BorderSizePixel = 0,
                Size = UDim2.new(0.48, 0, 0, 22),
                Font = Enum.Font.GothamBold,
                Text = "Select All",
                TextColor3 = theme.Success,
                TextSize = 10,
                LayoutOrder = -2,
                ZIndex = 100
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
            })
            
            selectAllBtn.MouseButton1Click:Connect(function()
                Dropdown.Value = Utility.DeepCopy(Dropdown.Items)
                selectedText.Text = GetDisplayText()
                CreateOptions()
                Dropdown.Callback(Dropdown.Value)
            end)
            
            -- Clear All
            local clearAllBtn = Utility.Create("TextButton", {
                Name = "ClearAll",
                Parent = optionsScroll,
                BackgroundColor3 = theme.Error,
                BackgroundTransparency = 0.8,
                BorderSizePixel = 0,
                Size = UDim2.new(0.48, 0, 0, 22),
                Font = Enum.Font.GothamBold,
                Text = "Clear All",
                TextColor3 = theme.Error,
                TextSize = 10,
                LayoutOrder = -1,
                ZIndex = 100
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
            })
            
            clearAllBtn.MouseButton1Click:Connect(function()
                Dropdown.Value = {}
                selectedText.Text = GetDisplayText()
                CreateOptions()
                Dropdown.Callback(Dropdown.Value)
            end)
        end
        
        -- Options
        for i, item in ipairs(Dropdown.Items) do
            local isSelected = false
            if Dropdown.Multi then
                isSelected = table.find(Dropdown.Value, item) ~= nil
            else
                isSelected = Dropdown.Value == item
            end
            
            local optionBtn = Utility.Create("TextButton", {
                Name = item,
                Parent = optionsScroll,
                BackgroundColor3 = isSelected and theme.Primary or theme.BackgroundTertiary,
                BackgroundTransparency = isSelected and 0.3 or 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                Font = Enum.Font.Code,
                Text = (isSelected and "✓ " or "  ") .. item,
                TextColor3 = isSelected and theme.Primary or theme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
                ZIndex = 100
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Utility.Create("UIPadding", {PaddingLeft = UDim.new(0, 8)})
            })
            
            optionBtn.MouseButton1Click:Connect(function()
                if Dropdown.Multi then
                    local idx = table.find(Dropdown.Value, item)
                    if idx then
                        table.remove(Dropdown.Value, idx)
                    else
                        table.insert(Dropdown.Value, item)
                    end
                    selectedText.Text = GetDisplayText()
                    CreateOptions()
                    Dropdown.Callback(Dropdown.Value)
                else
                    Dropdown.Value = item
                    selectedText.Text = item
                    Dropdown:Close()
                    Dropdown.Callback(Dropdown.Value)
                end
                
                if Dropdown.Flag then
                    Window.ConfigElements[Dropdown.Flag] = Dropdown.Value
                end
            end)
            
            optionBtn.MouseEnter:Connect(function()
                if not isSelected then
                    Utility.Tween(optionBtn, {BackgroundTransparency = 0.3}, 0.1)
                end
            end)
            
            optionBtn.MouseLeave:Connect(function()
                if not isSelected then
                    Utility.Tween(optionBtn, {BackgroundTransparency = 0.5}, 0.1)
                end
            end)
        end
    end
    
    CreateOptions()
    
    -- Toggle dropdown
    local function ToggleDropdown()
        Dropdown.Open = not Dropdown.Open
        
        if Dropdown.Open then
            optionsContainer.Visible = true
            local itemCount = #Dropdown.Items + (Dropdown.Multi and 2 or 0)
            local height = math.min(itemCount * 28 + 8, 150)
            
            Utility.Tween(optionsContainer, {
                Size = UDim2.new(1, -20, 0, height)
            }, 0.2)
            Utility.Tween(arrow, {Rotation = 180}, 0.2)
            Utility.Tween(dropdownButton.UIStroke, {Color = theme.Primary}, 0.2)
        else
            Utility.Tween(optionsContainer, {
                Size = UDim2.new(1, -20, 0, 0)
            }, 0.2)
            Utility.Tween(arrow, {Rotation = 0}, 0.2)
            Utility.Tween(dropdownButton.UIStroke, {Color = theme.Border}, 0.2)
            
            task.delay(0.2, function()
                optionsContainer.Visible = false
            end)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(ToggleDropdown)
    
    function Dropdown:Close()
        if Dropdown.Open then
            ToggleDropdown()
        end
    end
    
    function Dropdown:SetValue(value)
        Dropdown.Value = value
        selectedText.Text = GetDisplayText()
        CreateOptions()
    end
    
    function Dropdown:GetValue()
        return Dropdown.Value
    end
    
    function Dropdown:Refresh(items)
        Dropdown.Items = items
        CreateOptions()
    end
    
    if Dropdown.Flag then
        Window.ConfigElements[Dropdown.Flag] = Dropdown.Value
    end
    
    table.insert(Section.Elements, Dropdown)
    Window.Elements[#Window.Elements + 1] = Dropdown
    Window.SearchableElements[Dropdown.Name] = Dropdown
    
    return Dropdown
end

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD KEYBIND
-- ═══════════════════════════════════════════════════════════════════

function Section:AddKeybind(keybindOptions)
    keybindOptions = keybindOptions or {}
    
    local Keybind = {}
    Keybind.Type = "Keybind"
    Keybind.Name = keybindOptions.Title or "Keybind"
    Keybind.Value = keybindOptions.Default or Enum.KeyCode.Unknown
    Keybind.IsToggleKey = keybindOptions.IsToggleKey or false
    Keybind.Callback = keybindOptions.Callback or function() end
    Keybind.Flag = keybindOptions.Flag
    Keybind.Listening = false
    
    local theme = Window.Theme
    
    local keybindFrame = Utility.Create("Frame", {
        Name = "Keybind_" .. Keybind.Name,
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        LayoutOrder = #Section.Elements
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Title
    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = keybindFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.6, -10, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = ">> " .. Keybind.Name,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Keybind Button
    local keybindButton = Utility.Create("TextButton", {
        Name = "KeybindButton",
        Parent = keybindFrame,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -90, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 24),
        AnchorPoint = Vector2.new(0, 0.5),
        Font = Enum.Font.Code,
        Text = Keybind.Value.Name,
        TextColor3 = theme.Primary,
        TextSize = 11,
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIStroke", {
            Color = theme.Border,
            Thickness = 1
        })
    })
    
    Keybind.Frame = keybindFrame
    Keybind.Button = keybindButton
    
    -- Listen for key
    keybindButton.MouseButton1Click:Connect(function()
        Keybind.Listening = true
        keybindButton.Text = "..."
        Utility.Tween(keybindButton.UIStroke, {Color = theme.Primary}, 0.2)
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if not Keybind.Listening then
            if input.KeyCode == Keybind.Value and not processed then
                Keybind.Callback(Keybind.Value)
            end
            return
        end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind.Value = input.KeyCode
            keybindButton.Text = input.KeyCode.Name
            Keybind.Listening = false
            Utility.Tween(keybindButton.UIStroke, {Color = theme.Border}, 0.2)
            
            if Keybind.IsToggleKey then
                EnzoUI.ToggleKey = Keybind.Value
            end
            
            if Keybind.Flag then
                Window.ConfigElements[Keybind.Flag] = Keybind.Value.Name
            end
        end
    end)
    
    -- Hover Effects
    keybindFrame.MouseEnter:Connect(function()
        Utility.Tween(keybindFrame, {BackgroundColor3 = theme.BackgroundSecondary}, 0.1)
    end)
    
    keybindFrame.MouseLeave:Connect(function()
        Utility.Tween(keybindFrame, {BackgroundColor3 = theme.BackgroundTertiary}, 0.1)
    end)
    
    -- Methods
    function Keybind:SetValue(keyCode)
        Keybind.Value = keyCode
        keybindButton.Text = keyCode.Name
    end
    
    function Keybind:GetValue()
        return Keybind.Value
    end
    
    if Keybind.Flag then
        Window.ConfigElements[Keybind.Flag] = Keybind.Value.Name
    end
    
    table.insert(Section.Elements, Keybind)
    Window.Elements[#Window.Elements + 1] = Keybind
    Window.SearchableElements[Keybind.Name] = Keybind
    
    return Keybind
end

-- ═══════════════════════════════════════════════════════════════════
-- END PART 5
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- PART 6: ELEMENTS (ColorPicker, Image, Paragraph)
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD COLORPICKER
-- ═══════════════════════════════════════════════════════════════════

function Section:AddColorPicker(colorOptions)
    colorOptions = colorOptions or {}
    
    local ColorPicker = {}
    ColorPicker.Type = "ColorPicker"
    ColorPicker.Name = colorOptions.Title or "Color"
    ColorPicker.Value = colorOptions.Default or Color3.fromRGB(255, 255, 255)
    ColorPicker.Callback = colorOptions.Callback or function() end
    ColorPicker.Flag = colorOptions.Flag
    ColorPicker.Open = false
    
    local theme = Window.Theme
    local h, s, v = Utility.RGBToHSV(ColorPicker.Value)
    
    local colorFrame = Utility.Create("Frame", {
        Name = "ColorPicker_" .. ColorPicker.Name,
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        ClipsDescendants = false,
        LayoutOrder = #Section.Elements,
        ZIndex = 5
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    -- Title
    Utility.Create("TextLabel", {
        Name = "Title",
        Parent = colorFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = ">> " .. ColorPicker.Name,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })
    
    -- Color Preview Button
    local colorButton = Utility.Create("TextButton", {
        Name = "ColorButton",
        Parent = colorFrame,
        BackgroundColor3 = ColorPicker.Value,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -45, 0.5, 0),
        Size = UDim2.new(0, 35, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIStroke", {
            Color = theme.Border,
            Thickness = 1
        })
    })
    
    -- Color Picker Panel
    local pickerPanel = Utility.Create("Frame", {
        Name = "PickerPanel",
        Parent = colorFrame,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 50
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utility.Create("UIStroke", {
            Color = theme.Primary,
            Thickness = 1
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    })
    
    -- Saturation/Value Picker (Main Color Area)
    local svPicker = Utility.Create("Frame", {
        Name = "SVPicker",
        Parent = pickerPanel,
        BackgroundColor3 = Utility.HSVToRGB(h, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -35, 0, 100),
        ZIndex = 51
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })
    
    -- White gradient (left to right)
    local whiteGradient = Utility.Create("Frame", {
        Name = "WhiteGradient",
        Parent = svPicker,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 52
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        })
    })
    
    -- Black gradient (bottom to top)
    local blackGradient = Utility.Create("Frame", {
        Name = "BlackGradient",
        Parent = svPicker,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 53
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            }),
            Rotation = 90
        })
    })
    
    -- SV Cursor
    local svCursor = Utility.Create("Frame", {
        Name = "Cursor",
        Parent = svPicker,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(s, 0, 1 - v, 0),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 55
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utility.Create("UIStroke", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 2
        })
    })
    
    -- Hue Slider
    local hueSlider = Utility.Create("Frame", {
        Name = "HueSlider",
        Parent = pickerPanel,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 0, 100),
        ZIndex = 51
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }),
            Rotation = 90
        })
    })
    
    -- Hue Cursor
    local hueCursor = Utility.Create("Frame", {
        Name = "HueCursor",
        Parent = hueSlider,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, h, 0),
        Size = UDim2.new(1, 4, 0, 6),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 55
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
        Utility.Create("UIStroke", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 1
        })
    })
    
    -- Hex Input
    local hexContainer = Utility.Create("Frame", {
        Name = "HexContainer",
        Parent = pickerPanel,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 110),
        Size = UDim2.new(1, 0, 0, 28),
        ZIndex = 51
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })
    
    local hexLabel = Utility.Create("TextLabel", {
        Name = "Label",
        Parent = hexContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.Code,
        Text = "HEX:",
        TextColor3 = theme.TextMuted,
        TextSize = 11,
        ZIndex = 51
    })
    
    local hexInput = Utility.Create("TextBox", {
        Name = "HexInput",
        Parent = hexContainer,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 45, 0.5, 0),
        Size = UDim2.new(1, -55, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        Font = Enum.Font.Code,
        Text = Utility.RGBToHex(ColorPicker.Value),
        TextColor3 = theme.Text,
        TextSize = 11,
        ClearTextOnFocus = false,
        ZIndex = 51
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("UIPadding", {PaddingLeft = UDim.new(0, 5)})
    })
    
    -- Preview Box
    local previewBox = Utility.Create("Frame", {
        Name = "Preview",
        Parent = pickerPanel,
        BackgroundColor3 = ColorPicker.Value,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 145),
        Size = UDim2.new(1, 0, 0, 25),
        ZIndex = 51
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Utility.Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "PREVIEW",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextStrokeTransparency = 0.5,
            TextSize = 10,
            ZIndex = 51
        })
    })
    
    ColorPicker.Frame = colorFrame
    ColorPicker.PickerPanel = pickerPanel
    
    -- Update color function
    local function UpdateColor(newH, newS, newV, skipCallback)
        h, s, v = newH or h, newS or s, newV or v
        
        local newColor = Utility.HSVToRGB(h, s, v)
        ColorPicker.Value = newColor
        
        -- Update visuals
        colorButton.BackgroundColor3 = newColor
        previewBox.BackgroundColor3 = newColor
        svPicker.BackgroundColor3 = Utility.HSVToRGB(h, 1, 1)
        hexInput.Text = Utility.RGBToHex(newColor)
        
        -- Update cursors
        svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        hueCursor.Position = UDim2.new(0.5, 0, h, 0)
        
        if not skipCallback then
            ColorPicker.Callback(newColor)
        end
        
        if ColorPicker.Flag then
            Window.ConfigElements[ColorPicker.Flag] = {R = newColor.R, G = newColor.G, B = newColor.B}
        end
    end
    
    -- SV Picker input
    local svDragging = false
    
    local svInput = Utility.Create("TextButton", {
        Name = "Input",
        Parent = svPicker,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 54
    })
    
    local function UpdateSV(input)
        local pos = svPicker.AbsolutePosition
        local size = svPicker.AbsoluteSize
        
        local newS = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
        local newV = math.clamp(1 - (input.Position.Y - pos.Y) / size.Y, 0, 1)
        
        UpdateColor(nil, newS, newV)
    end
    
    svInput.MouseButton1Down:Connect(function()
        svDragging = true
    end)
    
    svInput.MouseButton1Click:Connect(function()
        local input = {Position = Vector3.new(Mouse.X, Mouse.Y, 0)}
        UpdateSV(input)
    end)
    
    -- Hue Slider input
    local hueDragging = false
    
    local hueInput = Utility.Create("TextButton", {
        Name = "Input",
        Parent = hueSlider,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 54
    })
    
    local function UpdateHue(input)
        local pos = hueSlider.AbsolutePosition
        local size = hueSlider.AbsoluteSize
        
        local newH = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
        
        UpdateColor(newH, nil, nil)
    end
    
    hueInput.MouseButton1Down:Connect(function()
        hueDragging = true
    end)
    
    hueInput.MouseButton1Click:Connect(function()
        local input = {Position = Vector3.new(Mouse.X, Mouse.Y, 0)}
        UpdateHue(input)
    end)
    
    -- Global input handling
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if svDragging then
                UpdateSV(input)
            elseif hueDragging then
                UpdateHue(input)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = false
            hueDragging = false
        end
    end)
    
    -- Hex input handling
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text
        local success, color = pcall(function()
            return Utility.HexToRGB(hex)
        end)
        
        if success then
            h, s, v = Utility.RGBToHSV(color)
            UpdateColor(h, s, v)
        else
            hexInput.Text = Utility.RGBToHex(ColorPicker.Value)
        end
    end)
    
    -- Toggle picker panel
    local function TogglePicker()
        ColorPicker.Open = not ColorPicker.Open
        
        if ColorPicker.Open then
            pickerPanel.Visible = true
            Utility.Tween(pickerPanel, {Size = UDim2.new(1, 0, 0, 180)}, 0.2)
            Utility.Tween(colorButton.UIStroke, {Color = theme.Primary}, 0.2)
        else
            Utility.Tween(pickerPanel, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Utility.Tween(colorButton.UIStroke, {Color = theme.Border}, 0.2)
            task.delay(0.2, function()
                pickerPanel.Visible = false
            end)
        end
    end
    
    colorButton.MouseButton1Click:Connect(TogglePicker)
    
    -- Hover Effects
    colorFrame.MouseEnter:Connect(function()
        Utility.Tween(colorFrame, {BackgroundColor3 = theme.BackgroundSecondary}, 0.1)
    end)
    
    colorFrame.MouseLeave:Connect(function()
        Utility.Tween(colorFrame, {BackgroundColor3 = theme.BackgroundTertiary}, 0.1)
    end)
    
    -- Methods
    function ColorPicker:SetValue(color)
        h, s, v = Utility.RGBToHSV(color)
        UpdateColor(h, s, v, true)
    end
    
    function ColorPicker:GetValue()
        return ColorPicker.Value
    end
    
    function ColorPicker:Close()
        if ColorPicker.Open then
            TogglePicker()
        end
    end
    
    if ColorPicker.Flag then
        Window.ConfigElements[ColorPicker.Flag] = {
            R = ColorPicker.Value.R,
            G = ColorPicker.Value.G,
            B = ColorPicker.Value.B
        }
    end
    
    table.insert(Section.Elements, ColorPicker)
    Window.Elements[#Window.Elements + 1] = ColorPicker
    Window.SearchableElements[ColorPicker.Name] = ColorPicker
    
    return ColorPicker
end

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD IMAGE
-- ═══════════════════════════════════════════════════════════════════

function Section:AddImage(imageOptions)
    imageOptions = imageOptions or {}
    
    local Image = {}
    Image.Type = "Image"
    Image.ImageId = imageOptions.Image or "rbxassetid://0"
    Image.Height = imageOptions.Height or 100
    Image.Rounded = imageOptions.Rounded ~= false
    
    local theme = Window.Theme
    
    local imageFrame = Utility.Create("Frame", {
        Name = "Image",
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Image.Height + 10),
        LayoutOrder = #Section.Elements
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })
    
    local imageLabel = Utility.Create("ImageLabel", {
        Name = "ImageLabel",
        Parent = imageFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -10, 1, -10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = Image.ImageId,
        ScaleType = Enum.ScaleType.Fit
    })
    
    if Image.Rounded then
        Utility.Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = imageLabel
        })
    end
    
    Image.Frame = imageFrame
    Image.ImageLabel = imageLabel
    
    function Image:SetImage(imageId)
        Image.ImageId = imageId
        imageLabel.Image = imageId
    end
    
    table.insert(Section.Elements, Image)
    Window.Elements[#Window.Elements + 1] = Image
    
    return Image
end

-- ═══════════════════════════════════════════════════════════════════
-- SECTION: ADD PARAGRAPH
-- ═══════════════════════════════════════════════════════════════════

function Section:AddParagraph(paragraphOptions)
    paragraphOptions = paragraphOptions or {}
    
    local Paragraph = {}
    Paragraph.Type = "Paragraph"
    Paragraph.Title = paragraphOptions.Title or "Paragraph"
    Paragraph.Content = paragraphOptions.Content or ""
    
    local theme = Window.Theme
    
    local paragraphFrame = Utility.Create("Frame", {
        Name = "Paragraph_" .. Paragraph.Title,
        Parent = sectionContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = #Section.Elements
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        }),
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })
    })
    
    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Parent = paragraphFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "📄 " .. Paragraph.Title,
        TextColor3 = theme.Primary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1
    })
    
    -- Content
    local contentLabel = Utility.Create("TextLabel", {
        Name = "Content",
        Parent = paragraphFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        Text = Paragraph.Content,
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2
    })
    
    Paragraph.Frame = paragraphFrame
    Paragraph.TitleLabel = titleLabel
    Paragraph.ContentLabel = contentLabel
    
    function Paragraph:SetTitle(title)
        Paragraph.Title = title
        titleLabel.Text = "📄 " .. title
    end
    
    function Paragraph:SetContent(content)
        Paragraph.Content = content
        contentLabel.Text = content
    end
    
    table.insert(Section.Elements, Paragraph)
    Window.Elements[#Window.Elements + 1] = Paragraph
    
    return Paragraph
end

-- ═══════════════════════════════════════════════════════════════════
-- END PART 6
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- PART 7: CONFIG SYSTEM
-- ═══════════════════════════════════════════════════════════════════

-- Add Config methods to Window (continued)

function Window:SaveConfig(name)
    name = name or "default"
    local configPath = self.ConfigFolder .. "/" .. name .. ".json"
    
    local configData = {}
    
    for flag, value in pairs(self.ConfigElements) do
        if type(value) == "table" then
            -- Color3 or other table
            configData[flag] = value
        elseif typeof(value) == "EnumItem" then
            -- KeyCode
            configData[flag] = {Type = "Enum", Value = tostring(value)}
        else
            configData[flag] = value
        end
    end
    
    local success = pcall(function()
        local json = HttpService:JSONEncode(configData)
        WriteFile(configPath, json)
    end)
    
    if success then
        self:Notify({
            Title = "Config Saved",
            Content = "Configuration '" .. name .. "' saved successfully!",
            Type = "Success",
            Duration = 3
        })
    else
        self:Notify({
            Title = "Save Failed",
            Content = "Failed to save configuration.",
            Type = "Error",
            Duration = 3
        })
    end
    
    return success
end

function Window:LoadConfig(name)
    name = name or "default"
    local configPath = self.ConfigFolder .. "/" .. name .. ".json"
    
    local content = ReadFile(configPath)
    if not content then
        self:Notify({
            Title = "Load Failed",
            Content = "Configuration '" .. name .. "' not found.",
            Type = "Error",
            Duration = 3
        })
        return false
    end
    
    local success, configData = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    
    if not success then
        self:Notify({
            Title = "Load Failed",
            Content = "Invalid configuration file.",
            Type = "Error",
            Duration = 3
        })
        return false
    end
    
    -- Apply config to elements
    for _, element in ipairs(self.Elements) do
        if element.Flag and configData[element.Flag] ~= nil then
            local value = configData[element.Flag]
            
            if element.Type == "Toggle" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Slider" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Input" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Dropdown" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Keybind" then
                if type(value) == "table" and value.Type == "Enum" then
                    local keyCode = Enum.KeyCode[value.Value:gsub("Enum.KeyCode.", "")]
                    if keyCode then
                        element:SetValue(keyCode)
                    end
                elseif type(value) == "string" then
                    local keyCode = Enum.KeyCode[value]
                    if keyCode then
                        element:SetValue(keyCode)
                    end
                end
            elseif element.Type == "ColorPicker" then
                if type(value) == "table" and value.R then
                    local color = Color3.new(value.R, value.G, value.B)
                    element:SetValue(color)
                    element.Callback(color)
                end
            end
        end
    end
    
    self:Notify({
        Title = "Config Loaded",
        Content = "Configuration '" .. name .. "' loaded successfully!",
        Type = "Success",
        Duration = 3
    })
    
    return true
end

function Window:DeleteConfig(name)
    local configPath = self.ConfigFolder .. "/" .. name .. ".json"
    
    local success = DeleteFile(configPath)
    
    if success then
        self:Notify({
            Title = "Config Deleted",
            Content = "Configuration '" .. name .. "' deleted.",
            Type = "Success",
            Duration = 3
        })
    else
        self:Notify({
            Title = "Delete Failed",
            Content = "Failed to delete configuration.",
            Type = "Error",
            Duration = 3
        })
    end
    
    return success
end

function Window:GetConfigs()
    local configs = {}
    
    if not IsFolder(self.ConfigFolder) then
        MakeFolder(self.ConfigFolder)
        return configs
    end
    
    local files = ListFiles(self.ConfigFolder)
    
    for _, file in ipairs(files) do
        if string.match(file, "%.json$") then
            local name = string.match(file, "([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end
    
    return configs
end

function Window:ExportConfig()
    local configData = {}
    
    for flag, value in pairs(self.ConfigElements) do
        if type(value) == "table" then
            configData[flag] = value
        elseif typeof(value) == "EnumItem" then
            configData[flag] = {Type = "Enum", Value = tostring(value)}
        else
            configData[flag] = value
        end
    end
    
    local json = HttpService:JSONEncode(configData)
    
    if setclipboard then
        setclipboard(json)
        self:Notify({
            Title = "Exported",
            Content = "Configuration copied to clipboard!",
            Type = "Success",
            Duration = 3
        })
    end
    
    return json
end

function Window:ImportConfig(json)
    local success, configData = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if not success then
        self:Notify({
            Title = "Import Failed",
            Content = "Invalid JSON format.",
            Type = "Error",
            Duration = 3
        })
        return false
    end
    
    -- Apply config
    for _, element in ipairs(self.Elements) do
        if element.Flag and configData[element.Flag] ~= nil then
            local value = configData[element.Flag]
            
            if element.Type == "Toggle" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Slider" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Input" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Dropdown" then
                element:SetValue(value)
                element.Callback(value)
            elseif element.Type == "Keybind" then
                if type(value) == "table" and value.Type == "Enum" then
                    local keyCode = Enum.KeyCode[value.Value:gsub("Enum.KeyCode.", "")]
                    if keyCode then
                        element:SetValue(keyCode)
                    end
                end
            elseif element.Type == "ColorPicker" then
                if type(value) == "table" and value.R then
                    local color = Color3.new(value.R, value.G, value.B)
                    element:SetValue(color)
                    element.Callback(color)
                end
            end
        end
    end
    
    self:Notify({
        Title = "Imported",
        Content = "Configuration imported successfully!",
        Type = "Success",
        Duration = 3
    })
    
    return true
end

-- Favorites System
function Window:ToggleFavorite(flag)
    if self.Favorites[flag] then
        self.Favorites[flag] = nil
    else
        self.Favorites[flag] = true
    end
end

function Window:IsFavorite(flag)
    return self.Favorites[flag] == true
end

-- ═══════════════════════════════════════════════════════════════════
-- ADD CONFIG MANAGER TAB
-- ═══════════════════════════════════════════════════════════════════

function Window:AddConfigManager()
    local theme = self.Theme
    
    local ConfigTab = self:AddTab({
        Title = "Configs",
        Icon = "💾"
    })
    
    local MainSection = ConfigTab:AddSection({
        Title = "Configuration Manager",
        Icon = "📁",
        Side = "Left"
    })
    
    local ActionsSection = ConfigTab:AddSection({
        Title = "Actions",
        Icon = "⚡",
        Side = "Right"
    })
    
    -- Config Name Input
    local configNameInput
    configNameInput = MainSection:AddInput({
        Title = "Config Name",
        Placeholder = "Enter config name...",
        Default = "default"
    })
    
    -- Config List Dropdown
    local configDropdown
    configDropdown = MainSection:AddDropdown({
        Title = "Select Config",
        Items = self:GetConfigs(),
        Default = nil
    })
    
    MainSection:AddDivider({Text = "Quick Actions"})
    
    -- Save Button
    MainSection:AddButton({
        Title = "💾 Save Config",
        Style = "Primary",
        Callback = function()
            local name = configNameInput:GetValue()
            if name and name ~= "" then
                self:SaveConfig(name)
                configDropdown:Refresh(self:GetConfigs())
            end
        end
    })
    
    -- Load Button
    MainSection:AddButton({
        Title = "📂 Load Config",
        Style = "Success",
        Callback = function()
            local selected = configDropdown:GetValue()
            if selected and selected ~= "" then
                self:LoadConfig(selected)
            end
        end
    })
    
    -- Delete Button
    MainSection:AddButton({
        Title = "🗑️ Delete Config",
        Style = "Danger",
        Callback = function()
            local selected = configDropdown:GetValue()
            if selected and selected ~= "" then
                self:DeleteConfig(selected)
                configDropdown:Refresh(self:GetConfigs())
            end
        end
    })
    
    -- Refresh Button
    ActionsSection:AddButton({
        Title = "🔄 Refresh List",
        Style = "Secondary",
        Callback = function()
            configDropdown:Refresh(self:GetConfigs())
            self:Notify({
                Title = "Refreshed",
                Content = "Config list updated.",
                Type = "Info",
                Duration = 2
            })
        end
    })
    
    ActionsSection:AddDivider({Text = "Import/Export"})
    
    -- Export Button
    ActionsSection:AddButton({
        Title = "📤 Export to Clipboard",
        Style = "Primary",
        Callback = function()
            self:ExportConfig()
        end
    })
    
    -- Import Input
    local importInput
    importInput = ActionsSection:AddInput({
        Title = "Import JSON",
        Placeholder = "Paste JSON here...",
        Default = ""
    })
    
    -- Import Button
    ActionsSection:AddButton({
        Title = "📥 Import Config",
        Style = "Success",
        Callback = function()
            local json = importInput:GetValue()
            if json and json ~= "" then
                self:ImportConfig(json)
            end
        end
    })
    
    return ConfigTab
end

-- ═══════════════════════════════════════════════════════════════════
-- END PART 7
-- ═══════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- PART 8: SETTINGS PANEL & FINAL INTEGRATION
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- SETTINGS PANEL
-- ═══════════════════════════════════════════════════════════════════

function Window:CreateSettingsPanel()
    local theme = self.Theme
    local mainFrame = self.MainFrame
    
    -- Settings Panel Frame
    local settingsPanel = Utility.Create("Frame", {
        Name = "SettingsPanel",
        Parent = mainFrame,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 250, 1, 0),
        ZIndex = 100,
        ClipsDescendants = true
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    -- Settings Header
    local settingsHeader = Utility.Create("Frame", {
        Name = "Header",
        Parent = settingsPanel,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45),
        ZIndex = 100
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Utility.Create("Frame", {
            BackgroundColor3 = theme.BackgroundSecondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -10),
            Size = UDim2.new(1, 0, 0, 10)
        }),
        Utility.Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "⚙️ Settings",
            TextColor3 = theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 100
        }),
        Utility.Create("TextButton", {
            Name = "Close",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -35, 0.5, 0),
            Size = UDim2.new(0, 25, 0, 25),
            AnchorPoint = Vector2.new(0, 0.5),
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = theme.TextMuted,
            TextSize = 20,
            ZIndex = 100
        })
    })
    
    -- Settings Content
    local settingsContent = Utility.Create("ScrollingFrame", {
        Name = "Content",
        Parent = settingsPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -55),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Primary,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 100
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        })
    })
    
    self.SettingsPanel = settingsPanel
    self.SettingsOpen = false
    
    -- ═══════════════════════════════════════════════════════════════
    -- THEME SELECTOR
    -- ═══════════════════════════════════════════════════════════════
    
    local themeLabel = Utility.Create("TextLabel", {
        Name = "ThemeLabel",
        Parent = settingsContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "🎨 Theme",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 100,
        LayoutOrder = 1
    })
    
    local themeContainer = Utility.Create("Frame", {
        Name = "ThemeContainer",
        Parent = settingsContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35),
        ZIndex = 100,
        LayoutOrder = 2
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8)
        })
    })
    
    local themeNames = {"Aurora", "Sunset", "Ocean", "Forest", "Sakura", "Midnight"}
    
    for _, themeName in ipairs(themeNames) do
        local themeData = Themes[themeName]
        local themeBtn = Utility.Create("TextButton", {
            Name = themeName,
            Parent = themeContainer,
            BackgroundColor3 = themeData.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 30, 0, 30),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 100
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Utility.Create("UIStroke", {
                Color = self.Theme.Name == themeName and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
                Thickness = self.Theme.Name == themeName and 2 or 0
            })
        })
        
        themeBtn.MouseButton1Click:Connect(function()
            self:SetTheme(themeName)
            
            -- Update selection visual
            for _, btn in ipairs(themeContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.UIStroke.Thickness = 0
                    btn.UIStroke.Color = Color3.fromRGB(0, 0, 0)
                end
            end
            themeBtn.UIStroke.Thickness = 2
            themeBtn.UIStroke.Color = Color3.fromRGB(255, 255, 255)
        end)
        
        themeBtn.MouseEnter:Connect(function()
            Utility.Tween(themeBtn, {Size = UDim2.new(0, 33, 0, 33)}, 0.1)
        end)
        
        themeBtn.MouseLeave:Connect(function()
            Utility.Tween(themeBtn, {Size = UDim2.new(0, 30, 0, 30)}, 0.1)
        end)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- OPACITY SLIDER
    -- ═══════════════════════════════════════════════════════════════
    
    local opacityLabel = Utility.Create("TextLabel", {
        Name = "OpacityLabel",
        Parent = settingsContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "🌈 UI Opacity",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 100,
        LayoutOrder = 3
    })
    
    local opacityContainer = Utility.Create("Frame", {
        Name = "OpacityContainer",
        Parent = settingsContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 100,
        LayoutOrder = 4
    })
    
    local opacityTrack = Utility.Create("Frame", {
        Name = "Track",
        Parent = opacityContainer,
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, -40, 0, 6),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 100
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local opacityFill = Utility.Create("Frame", {
        Name = "Fill",
        Parent = opacityTrack,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0.85, 0, 1, 0),
        ZIndex = 100
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local opacityKnob = Utility.Create("Frame", {
        Name = "Knob",
        Parent = opacityTrack,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0.85, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 101
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utility.Create("UIStroke", {
            Color = theme.Primary,
            Thickness = 2
        })
    })
    
    local opacityValue = Utility.Create("TextLabel", {
        Name = "Value",
        Parent = opacityContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0.5, 0),
        Size = UDim2.new(0, 35, 1, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Font = Enum.Font.Code,
        Text = "85%",
        TextColor3 = theme.Primary,
        TextSize = 12,
        ZIndex = 100
    })
    
    local opacityDragging = false
    local currentOpacity = 0.85
    
    local opacityInput = Utility.Create("TextButton", {
        Name = "Input",
        Parent = opacityTrack,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Text = "",
        ZIndex = 102
    })
    
    local function UpdateOpacity(percent)
        percent = math.clamp(percent, 0.3, 1)
        currentOpacity = percent
        
        opacityFill.Size = UDim2.new(percent, 0, 1, 0)
        opacityKnob.Position = UDim2.new(percent, 0, 0.5, 0)
        opacityValue.Text = math.floor(percent * 100) .. "%"
        
        self:SetOpacity(percent)
    end
    
    opacityInput.MouseButton1Down:Connect(function()
        opacityDragging = true
    end)
    
    opacityInput.MouseButton1Click:Connect(function()
        local trackPos = opacityTrack.AbsolutePosition.X
        local trackSize = opacityTrack.AbsoluteSize.X
        local percent = math.clamp((Mouse.X - trackPos) / trackSize, 0.3, 1)
        UpdateOpacity(percent)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local trackPos = opacityTrack.AbsolutePosition.X
            local trackSize = opacityTrack.AbsoluteSize.X
            local percent = math.clamp((input.Position.X - trackPos) / trackSize, 0.3, 1)
            UpdateOpacity(percent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            opacityDragging = false
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- EFFECT TOGGLES
    -- ═══════════════════════════════════════════════════════════════
    
    local effectsLabel = Utility.Create("TextLabel", {
        Name = "EffectsLabel",
        Parent = settingsContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "✨ Effects",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 100,
        LayoutOrder = 5
    })
    
    -- Glow Toggle
    local glowEnabled = true
    local glowContainer = Utility.Create("Frame", {
        Name = "GlowToggle",
        Parent = settingsContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        ZIndex = 100,
        LayoutOrder = 6
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utility.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Font = Enum.Font.Gotham,
            Text = "Glow Effect",
            TextColor3 = theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 100
        })
    })
    
    local glowSwitch = Utility.Create("Frame", {
        Name = "Switch",
        Parent = glowContainer,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -50, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 100
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utility.Create("Frame", {
            Name = "Knob",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -18, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 101
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
    })
    
    local glowBtn = Utility.Create("TextButton", {
        Name = "Button",
        Parent = glowContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 102
    })
    
    glowBtn.MouseButton1Click:Connect(function()
        glowEnabled = not glowEnabled
        
        Utility.Tween(glowSwitch, {
            BackgroundColor3 = glowEnabled and theme.Primary or theme.Border
        }, 0.2)
        
        Utility.Tween(glowSwitch.Knob, {
            Position = glowEnabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.2)
        
        if self.GlowEffect then
            Utility.Tween(self.GlowEffect, {
                ImageTransparency = glowEnabled and theme.GlowTransparency or 1
            }, 0.3)
        end
    end)
    
    -- Blur Toggle
    local blurEnabled = true
    local blurContainer = Utility.Create("Frame", {
        Name = "BlurToggle",
        Parent = settingsContent,
        BackgroundColor3 = theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        ZIndex = 100,
        LayoutOrder = 7
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Utility.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Font = Enum.Font.Gotham,
            Text = "Background Blur",
            TextColor3 = theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 100
        })
    })
    
    local blurSwitch = Utility.Create("Frame", {
        Name = "Switch",
        Parent = blurContainer,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -50, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 100
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Utility.Create("Frame", {
            Name = "Knob",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -18, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 101
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
    })
    
    local blurBtn = Utility.Create("TextButton", {
        Name = "Button",
        Parent = blurContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 102
    })
    
    blurBtn.MouseButton1Click:Connect(function()
        blurEnabled = not blurEnabled
        
        Utility.Tween(blurSwitch, {
            BackgroundColor3 = blurEnabled and theme.Primary or theme.Border
        }, 0.2)
        
        Utility.Tween(blurSwitch.Knob, {
            Position = blurEnabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.2)
        
        self:SetBlur(blurEnabled)
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- TOGGLE SETTINGS PANEL
    -- ═══════════════════════════════════════════════════════════════
    
    local function ToggleSettings()
        self.SettingsOpen = not self.SettingsOpen
        
        if self.SettingsOpen then
            settingsPanel.Visible = true
            Utility.Tween(settingsPanel, {
                Position = UDim2.new(1, -250, 0, 0)
            }, 0.3)
        else
            Utility.Tween(settingsPanel, {
                Position = UDim2.new(1, 0, 0, 0)
            }, 0.3)
            task.delay(0.3, function()
                settingsPanel.Visible = false
            end)
        end
    end
    
    -- Connect settings button from header
    local settingsBtn = mainFrame.Header.Controls.Settings
    settingsBtn.MouseButton1Click:Connect(ToggleSettings)
    
    -- Close button in settings panel
    settingsHeader.Close.MouseButton1Click:Connect(ToggleSettings)
    
    return settingsPanel
end

-- ═══════════════════════════════════════════════════════════════════
-- CLEANUP & PROTECTION
-- ═══════════════════════════════════════════════════════════════════

-- Auto cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, window in ipairs(EnzoUI.Windows) do
            pcall(function()
                window:Destroy()
            end)
        end
    end
end

-- Return the library
return EnzoUI

-- ═══════════════════════════════════════════════════════════════════
-- END PART 8 - LIBRARY COMPLETE
-- ═══════════════════════════════════════════════════════════════════