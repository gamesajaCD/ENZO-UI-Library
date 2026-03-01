--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                       EnzoUI Library v2.0                       ║
    ║                    Premium Roblox UI Library                    ║
    ║                                                                  ║
    ║   Features:                                                      ║
    ║   • Aurora Animated Border & Glow Effects                        ║
    ║   • 13 UI Element Types                                          ║
    ║   • 5 Built-in Themes (Customizable Icons)                       ║
    ║   • Config System (Save/Load/Export/Import)                      ║
    ║   • Notification System (4 Types)                                ║
    ║   • Tooltip System                                               ║
    ║   • Watermark (FPS/Ping/Timer)                                   ║
    ║   • Mobile Support                                               ║
    ║   • Webhook Integration                                         ║
    ║   • Anti-Detection (Random Naming)                               ║
    ║   • Two-Column Section Layout                                    ║
    ║   • Global Search                                                ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

-- ══════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local LocalPlayer       = Players.LocalPlayer

-- ══════════════════════════════════════════════════════
-- ANTI-DETECTION: Random Naming
-- ══════════════════════════════════════════════════════
local function RNG(n)
    local s = ""
    for i = 1, n or 12 do s = s .. string.char(math.random(97,122)) end
    return s
end

-- ══════════════════════════════════════════════════════
-- SAFE CALL WRAPPER
-- ══════════════════════════════════════════════════════
local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, res = pcall(fn, ...)
    if not ok then warn("[EnzoUI] " .. tostring(res)) end
    return ok, res
end

-- ══════════════════════════════════════════════════════
-- UTILITY: Create Instance
-- ══════════════════════════════════════════════════════
local function Create(cls, props)
    local obj = Instance.new(cls)
    local par
    for k,v in pairs(props) do
        if k == "Parent" then par = v
        else pcall(function() obj[k] = v end) end
    end
    if par then obj.Parent = par end
    return obj
end

-- ══════════════════════════════════════════════════════
-- UTILITY: Tween
-- ══════════════════════════════════════════════════════
local function Tween(obj, props, dur, style, dir)
    if not obj then return end
    local t = TweenService:Create(obj,
        TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

-- ══════════════════════════════════════════════════════
-- UTILITY: UI Helpers
-- ══════════════════════════════════════════════════════
local function Corner(p, r)
    return Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p})
end

local function Stroke(p, c, t, tr)
    return Create("UIStroke", {
        Color = c or Color3.fromRGB(60,60,80), Thickness = t or 1,
        Transparency = tr or 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p
    })
end

local function Pad(p, t, b, l, r)
    return Create("UIPadding", {
        PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0),
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0), Parent = p
    })
end

local function List(p, pad, dir, ha, va)
    return Create("UIListLayout", {
        Padding=UDim.new(0, pad or 6),
        FillDirection = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Center,
        VerticalAlignment = va or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = p
    })
end

-- ══════════════════════════════════════════════════════
-- UTILITY: Icon Renderer (Text or Image)
-- ══════════════════════════════════════════════════════
local function MakeIcon(parent, icon, size, color, zidx, pos, anchor)
    if not icon or icon == "" then return nil end
    size = size or 18
    if type(icon) == "string" and (icon:find("rbxassetid://") or icon:find("rbxasset://")) then
        return Create("ImageLabel", {
            Image = icon, ImageColor3 = color or Color3.new(1,1,1),
            BackgroundTransparency = 1, Size = UDim2.new(0,size,0,size),
            Position = pos or UDim2.new(0,0,0,0), AnchorPoint = anchor or Vector2.new(0,0),
            ZIndex = zidx or 6, ScaleType = Enum.ScaleType.Fit, Parent = parent
        })
    else
        return Create("TextLabel", {
            Text = tostring(icon), TextColor3 = color or Color3.new(1,1,1),
            TextSize = size, Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1, Size = UDim2.new(0, size+4, 0, size),
            Position = pos or UDim2.new(0,0,0,0), AnchorPoint = anchor or Vector2.new(0,0),
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = zidx or 6, Parent = parent
        })
    end
end

-- ══════════════════════════════════════════════════════
-- UTILITY: Draggable
-- ══════════════════════════════════════════════════════
local function MakeDraggable(handle, frame)
    local d, di, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ds = i.Position; sp = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then d = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            di = i
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == di and d then
            local delta = i.Position - ds
            Tween(frame, {Position = UDim2.new(sp.X.Scale, sp.X.Offset+delta.X, sp.Y.Scale, sp.Y.Offset+delta.Y)}, 0.06, Enum.EasingStyle.Sine)
        end
    end)
end

-- ══════════════════════════════════════════════════════
-- UTILITY: Ripple Effect
-- ══════════════════════════════════════════════════════
local function Ripple(btn)
    btn.ClipsDescendants = true
    btn.MouseButton1Click:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        local ap = btn.AbsolutePosition
        local r = Create("Frame", {
            BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.82,
            Position = UDim2.new(0, mp.X-ap.X, 0, mp.Y-ap.Y-36),
            Size = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(0.5,0.5),
            ZIndex = btn.ZIndex+5, BorderSizePixel = 0, Parent = btn
        })
        Corner(r, 999)
        local ms = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)*2.5
        Tween(r, {Size=UDim2.new(0,ms,0,ms), BackgroundTransparency=1}, 0.5)
        task.delay(0.55, function() if r then r:Destroy() end end)
    end)
end

-- ══════════════════════════════════════════════════════
-- ICONS TABLE (ALL CUSTOMIZABLE)
-- Ubah icon sesuai keinginan. Bisa text/emoji atau rbxassetid://
-- ══════════════════════════════════════════════════════
local Icons = {
    Window = {
        Close       = "✕",
        Minimize    = "━",
        Restore     = "◻",
        Logo        = "🌙",
    },
    Tab = {
        Default     = "📄",
    },
    Notification = {
        Info        = "ℹ️",
        Success     = "✅",
        Warning     = "⚠️",
        Error       = "❌",
        Close       = "✕",
    },
    Element = {
        Toggle      = "●",
        Dropdown    = "▾",
        DropdownUp  = "▴",
        Search      = "🔍",
        Keybind     = "⌨️",
        Color       = "🎨",
        Arrow       = "›",
        Check       = "✓",
        Favorite    = "★",
        FavEmpty    = "☆",
        SelectAll   = "☑",
        ClearAll    = "☐",
    },
    Section = {
        Default     = "📦",
    },
    Watermark = {
        FPS         = "📊",
        Ping        = "📡",
        Timer       = "⏱️",
    },
    Mobile = {
        Toggle      = "☰",
    },
}

-- ══════════════════════════════════════════════════════
-- THEMES (5 Built-in Themes)
-- ══════════════════════════════════════════════════════
local Themes = {
    Midnight = {
        Name              = "Midnight",
        Background        = Color3.fromRGB(14, 14, 24),
        Sidebar           = Color3.fromRGB(10, 10, 18),
        TopBar            = Color3.fromRGB(18, 18, 30),
        TabActive         = Color3.fromRGB(42, 40, 72),
        TabInactive       = Color3.fromRGB(16, 16, 28),
        TabHover          = Color3.fromRGB(28, 26, 48),
        Element           = Color3.fromRGB(20, 20, 36),
        ElementHover      = Color3.fromRGB(28, 26, 46),
        ElementBorder     = Color3.fromRGB(48, 46, 68),
        Accent            = Color3.fromRGB(88, 101, 242),
        AccentHover       = Color3.fromRGB(110, 122, 255),
        AccentDark        = Color3.fromRGB(62, 72, 190),
        TextPrimary       = Color3.fromRGB(235, 235, 248),
        TextSecondary     = Color3.fromRGB(150, 148, 175),
        TextDimmed        = Color3.fromRGB(90, 88, 112),
        ToggleOn          = Color3.fromRGB(88, 101, 242),
        ToggleOff         = Color3.fromRGB(48, 46, 65),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(88, 101, 242),
        SliderBack        = Color3.fromRGB(36, 34, 52),
        InputBg           = Color3.fromRGB(14, 14, 26),
        DropdownBg        = Color3.fromRGB(18, 18, 32),
        DropdownHover     = Color3.fromRGB(34, 32, 54),
        Divider           = Color3.fromRGB(40, 38, 58),
        Shadow            = Color3.fromRGB(4, 4, 8),
        SectionHeader     = Color3.fromRGB(24, 22, 40),
        Success           = Color3.fromRGB(16, 185, 129),
        Warning           = Color3.fromRGB(245, 158, 11),
        Danger            = Color3.fromRGB(239, 68, 68),
        Info              = Color3.fromRGB(59, 130, 246),
        GlowColor         = Color3.fromRGB(88, 101, 242),
        AuroraColors      = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(139, 92, 246)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(236, 72, 153)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 101, 242)),
        },
    },
    Ocean = {
        Name              = "Ocean",
        Background        = Color3.fromRGB(10, 18, 30),
        Sidebar           = Color3.fromRGB(8, 14, 24),
        TopBar            = Color3.fromRGB(14, 24, 38),
        TabActive         = Color3.fromRGB(20, 55, 72),
        TabInactive       = Color3.fromRGB(12, 20, 32),
        TabHover          = Color3.fromRGB(16, 38, 52),
        Element           = Color3.fromRGB(14, 24, 40),
        ElementHover      = Color3.fromRGB(20, 32, 50),
        ElementBorder     = Color3.fromRGB(30, 55, 75),
        Accent            = Color3.fromRGB(0, 180, 216),
        AccentHover       = Color3.fromRGB(30, 200, 235),
        AccentDark        = Color3.fromRGB(0, 140, 175),
        TextPrimary       = Color3.fromRGB(225, 240, 248),
        TextSecondary     = Color3.fromRGB(130, 165, 182),
        TextDimmed        = Color3.fromRGB(75, 105, 122),
        ToggleOn          = Color3.fromRGB(0, 180, 216),
        ToggleOff         = Color3.fromRGB(30, 50, 65),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(0, 180, 216),
        SliderBack        = Color3.fromRGB(22, 38, 55),
        InputBg           = Color3.fromRGB(10, 16, 28),
        DropdownBg        = Color3.fromRGB(12, 20, 34),
        DropdownHover     = Color3.fromRGB(22, 42, 58),
        Divider           = Color3.fromRGB(28, 48, 62),
        Shadow            = Color3.fromRGB(3, 6, 12),
        SectionHeader     = Color3.fromRGB(16, 28, 44),
        Success           = Color3.fromRGB(16, 185, 129),
        Warning           = Color3.fromRGB(245, 158, 11),
        Danger            = Color3.fromRGB(239, 68, 68),
        Info              = Color3.fromRGB(0, 180, 216),
        GlowColor         = Color3.fromRGB(0, 180, 216),
        AuroraColors      = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 216)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 100, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(120, 80, 245)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 216)),
        },
    },
    Rose = {
        Name              = "Rose",
        Background        = Color3.fromRGB(22, 12, 18),
        Sidebar           = Color3.fromRGB(18, 8, 14),
        TopBar            = Color3.fromRGB(28, 16, 22),
        TabActive         = Color3.fromRGB(65, 30, 48),
        TabInactive       = Color3.fromRGB(24, 14, 20),
        TabHover          = Color3.fromRGB(45, 22, 35),
        Element           = Color3.fromRGB(30, 16, 24),
        ElementHover      = Color3.fromRGB(40, 22, 32),
        ElementBorder     = Color3.fromRGB(62, 38, 50),
        Accent            = Color3.fromRGB(236, 72, 120),
        AccentHover       = Color3.fromRGB(255, 95, 142),
        AccentDark        = Color3.fromRGB(200, 52, 95),
        TextPrimary       = Color3.fromRGB(248, 230, 238),
        TextSecondary     = Color3.fromRGB(178, 142, 158),
        TextDimmed        = Color3.fromRGB(115, 85, 98),
        ToggleOn          = Color3.fromRGB(236, 72, 120),
        ToggleOff         = Color3.fromRGB(55, 35, 45),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(236, 72, 120),
        SliderBack        = Color3.fromRGB(42, 28, 35),
        InputBg           = Color3.fromRGB(20, 10, 16),
        DropdownBg        = Color3.fromRGB(24, 14, 20),
        DropdownHover     = Color3.fromRGB(45, 28, 38),
        Divider           = Color3.fromRGB(52, 34, 44),
        Shadow            = Color3.fromRGB(8, 4, 6),
        SectionHeader     = Color3.fromRGB(34, 20, 28),
        Success           = Color3.fromRGB(16, 185, 129),
        Warning           = Color3.fromRGB(245, 158, 11),
        Danger            = Color3.fromRGB(239, 68, 68),
        Info              = Color3.fromRGB(236, 72, 120),
        GlowColor         = Color3.fromRGB(236, 72, 120),
        AuroraColors      = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(236, 72, 120)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 100, 60)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(200, 50, 160)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(236, 72, 120)),
        },
    },
    Neon = {
        Name              = "Neon",
        Background        = Color3.fromRGB(8, 8, 16),
        Sidebar           = Color3.fromRGB(6, 6, 12),
        TopBar            = Color3.fromRGB(12, 12, 22),
        TabActive         = Color3.fromRGB(25, 50, 35),
        TabInactive       = Color3.fromRGB(10, 10, 18),
        TabHover          = Color3.fromRGB(18, 32, 25),
        Element           = Color3.fromRGB(12, 12, 24),
        ElementHover      = Color3.fromRGB(18, 18, 32),
        ElementBorder     = Color3.fromRGB(35, 55, 42),
        Accent            = Color3.fromRGB(0, 255, 135),
        AccentHover       = Color3.fromRGB(40, 255, 160),
        AccentDark        = Color3.fromRGB(0, 195, 105),
        TextPrimary       = Color3.fromRGB(220, 255, 235),
        TextSecondary     = Color3.fromRGB(120, 175, 145),
        TextDimmed        = Color3.fromRGB(65, 110, 85),
        ToggleOn          = Color3.fromRGB(0, 255, 135),
        ToggleOff         = Color3.fromRGB(25, 40, 32),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(0, 255, 135),
        SliderBack        = Color3.fromRGB(18, 28, 22),
        InputBg           = Color3.fromRGB(8, 8, 14),
        DropdownBg        = Color3.fromRGB(10, 10, 18),
        DropdownHover     = Color3.fromRGB(18, 30, 24),
        Divider           = Color3.fromRGB(28, 45, 35),
        Shadow            = Color3.fromRGB(2, 4, 3),
        SectionHeader     = Color3.fromRGB(14, 22, 18),
        Success           = Color3.fromRGB(0, 255, 135),
        Warning           = Color3.fromRGB(255, 220, 40),
        Danger            = Color3.fromRGB(255, 60, 60),
        Info              = Color3.fromRGB(60, 180, 255),
        GlowColor         = Color3.fromRGB(0, 255, 135),
        AuroraColors      = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 135)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 200, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(180, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 135)),
        },
    },
    Emerald = {
        Name              = "Emerald",
        Background        = Color3.fromRGB(12, 20, 16),
        Sidebar           = Color3.fromRGB(8, 16, 12),
        TopBar            = Color3.fromRGB(16, 26, 20),
        TabActive         = Color3.fromRGB(25, 60, 42),
        TabInactive       = Color3.fromRGB(14, 22, 18),
        TabHover          = Color3.fromRGB(20, 40, 30),
        Element           = Color3.fromRGB(16, 28, 22),
        ElementHover      = Color3.fromRGB(22, 36, 28),
        ElementBorder     = Color3.fromRGB(35, 60, 46),
        Accent            = Color3.fromRGB(16, 185, 129),
        AccentHover       = Color3.fromRGB(40, 210, 152),
        AccentDark        = Color3.fromRGB(10, 148, 102),
        TextPrimary       = Color3.fromRGB(228, 245, 236),
        TextSecondary     = Color3.fromRGB(135, 172, 152),
        TextDimmed        = Color3.fromRGB(78, 108, 92),
        ToggleOn          = Color3.fromRGB(16, 185, 129),
        ToggleOff         = Color3.fromRGB(30, 48, 38),
        ToggleCircle      = Color3.fromRGB(255, 255, 255),
        SliderFill        = Color3.fromRGB(16, 185, 129),
        SliderBack        = Color3.fromRGB(24, 38, 30),
        InputBg           = Color3.fromRGB(10, 18, 14),
        DropdownBg        = Color3.fromRGB(14, 22, 18),
        DropdownHover     = Color3.fromRGB(24, 42, 32),
        Divider           = Color3.fromRGB(30, 50, 38),
        Shadow            = Color3.fromRGB(4, 8, 6),
        SectionHeader     = Color3.fromRGB(18, 32, 24),
        Success           = Color3.fromRGB(16, 185, 129),
        Warning           = Color3.fromRGB(245, 158, 11),
        Danger            = Color3.fromRGB(239, 68, 68),
        Info              = Color3.fromRGB(59, 180, 220),
        GlowColor         = Color3.fromRGB(16, 185, 129),
        AuroraColors      = {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 185, 129)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 220, 180)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(60, 140, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129)),
        },
    },
}
-- ══════════════════════════════════════════════════════
-- LIBRARY TABLE
-- ══════════════════════════════════════════════════════
local EnzoUI = {}
EnzoUI.__index = EnzoUI
EnzoUI.Version = "2.0.0"
EnzoUI.Icons = Icons
EnzoUI.Themes = Themes
EnzoUI._windows = {}

function EnzoUI:SetIcon(category, name, value)
    if Icons[category] then
        Icons[category][name] = value
    end
end

function EnzoUI:AddTheme(name, themeData)
    Themes[name] = themeData
end

-- ══════════════════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════════════════
function EnzoUI:CreateWindow(cfg)
    cfg = cfg or {}
    local title         = cfg.Title or "EnzoUI"
    local subTitle      = cfg.SubTitle or "v2.0"
    local windowSize    = cfg.Size or UDim2.new(0, 620, 0, 420)
    local logo          = cfg.Logo or Icons.Window.Logo
    local themeName     = cfg.Theme or "Midnight"
    local toggleKey     = cfg.ToggleKey or Enum.KeyCode.RightShift
    local showWatermark = cfg.Watermark ~= false
    local version       = cfg.Version or "2.0.0"
    local enableBlur    = cfg.Blur ~= false
    local configFolder  = cfg.ConfigFolder or "EnzoUI"
    local tabWidth      = 160

    local Theme = Themes[themeName] or Themes.Midnight

    -- Destroy previous
    for _, w in pairs(EnzoUI._windows) do pcall(function() w:Destroy() end) end
    EnzoUI._windows = {}

    -- ScreenGui
    local guiName = RNG(14)
    local ScreenGui = Create("ScreenGui", {
        Name = guiName, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false
    })
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = game:GetService("CoreGui")
        elseif gethui then ScreenGui.Parent = gethui()
        else ScreenGui.Parent = game:GetService("CoreGui") end
    end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- State
    local Window = {}
    Window._tabs = {}
    Window._elements = {}
    Window._searchable = {}
    Window._connections = {}
    Window._activeTab = nil
    Window._minimized = false
    Window._visible = true
    Window._opacity = 1
    Window._theme = Theme
    Window._configFolder = configFolder
    Window._favorites = {}
    Window._screenGui = ScreenGui

    -- ════════════════════════════════════════
    -- GLOW EFFECT (behind everything)
    -- ════════════════════════════════════════
    local GlowFrame = Create("ImageLabel", {
        Name = RNG(6), BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805", ImageColor3 = Theme.GlowColor,
        ImageTransparency = 0.65, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23,23,277,277),
        Size = UDim2.new(0, windowSize.X.Offset+50, 0, windowSize.Y.Offset+50),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5,0.5),
        ZIndex = 0, Parent = ScreenGui
    })

    -- ════════════════════════════════════════
    -- AURORA BORDER (animated gradient)
    -- ════════════════════════════════════════
    local AuroraFrame = Create("Frame", {
        Name = RNG(6), BackgroundColor3 = Color3.new(1,1,1),
        Size = UDim2.new(0, windowSize.X.Offset+4, 0, windowSize.Y.Offset+4),
        Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5),
        ZIndex = 1, BorderSizePixel = 0, Parent = ScreenGui
    })
    Corner(AuroraFrame, 12)
    local auroraGrad = Create("UIGradient", {
        Color = ColorSequence.new(Theme.AuroraColors),
        Rotation = 0, Parent = AuroraFrame
    })

    -- Aurora rotation animation
    local auroraAngle = 0
    local auroraConn = RunService.RenderStepped:Connect(function(dt)
        auroraAngle = (auroraAngle + dt * 60) % 360
        auroraGrad.Rotation = auroraAngle
    end)
    table.insert(Window._connections, auroraConn)

    -- ════════════════════════════════════════
    -- MAIN FRAME (Window)
    -- ════════════════════════════════════════
    local MainFrame = Create("Frame", {
        Name = RNG(8), BackgroundColor3 = Theme.Background,
        Size = windowSize, Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5), BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 2, Parent = ScreenGui
    })
    Corner(MainFrame, 10)
    Window._mainFrame = MainFrame

    -- Shadow
    Create("ImageLabel", {
        Name = "Shadow", BackgroundTransparency = 1,
        Position = UDim2.new(0,-18,0,-18), Size = UDim2.new(1,36,1,36),
        ZIndex = 1, Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.Shadow, ImageTransparency = 0.35,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(23,23,277,277),
        Parent = MainFrame
    })

    -- Open animation
    MainFrame.BackgroundTransparency = 1
    local savedSize = windowSize
    MainFrame.Size = UDim2.new(0,0,0,0)
    GlowFrame.ImageTransparency = 1
    AuroraFrame.BackgroundTransparency = 1
    Tween(MainFrame, {Size = windowSize, BackgroundTransparency = 0}, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tween(GlowFrame, {ImageTransparency = 0.65}, 0.6)
    Tween(AuroraFrame, {BackgroundTransparency = 0}, 0.6)

    -- ════════════════════════════════════════
    -- BLUR EFFECT
    -- ════════════════════════════════════════
    local BlurEffect = nil
    if enableBlur then
        BlurEffect = Create("BlurEffect", {Name = RNG(6), Size = 0, Parent = Lighting})
        Tween(BlurEffect, {Size = 14}, 0.5)
    end

    function Window:SetBlur(enabled)
        if BlurEffect then
            Tween(BlurEffect, {Size = enabled and 14 or 0}, 0.35)
        end
    end

    -- ════════════════════════════════════════
    -- TOP BAR
    -- ════════════════════════════════════════
    local TopBar = Create("Frame", {
        Name = RNG(5), BackgroundColor3 = Theme.TopBar,
        Size = UDim2.new(1,0,0,44), BorderSizePixel = 0, ZIndex = 10, Parent = MainFrame
    })
    Corner(TopBar, 10)
    -- Fix bottom corners
    Create("Frame", {
        BackgroundColor3 = Theme.TopBar, Size = UDim2.new(1,0,0,14),
        Position = UDim2.new(0,0,1,-14), BorderSizePixel = 0, ZIndex = 10, Parent = TopBar
    })
    -- Divider
    Create("Frame", {
        BackgroundColor3 = Theme.Divider, Size = UDim2.new(1,0,0,1),
        Position = UDim2.new(0,0,0,44), BorderSizePixel = 0, ZIndex = 11, Parent = MainFrame
    })

    -- Logo
    MakeIcon(TopBar, logo, 20, Theme.Accent, 11, UDim2.new(0,14,0.5,0), Vector2.new(0,0.5))

    -- Title
    Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0,40,0,0),
        Size = UDim2.new(0,200,1,0), Font = Enum.Font.GothamBold,
        Text = title, TextColor3 = Theme.TextPrimary, TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11, Parent = TopBar
    })
    -- SubTitle
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 42 + #title*9, 0, 1),
        Size = UDim2.new(0,120,1,0), Font = Enum.Font.Gotham,
        Text = subTitle, TextColor3 = Theme.TextDimmed, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11, Parent = TopBar
    })

    -- Window buttons (Close, Minimize, Restore)
    local function TopBtn(icon, color, posX)
        local b = Create("TextButton", {
            BackgroundColor3 = color, Size = UDim2.new(0,14,0,14),
            Position = UDim2.new(1,posX,0.5,0), AnchorPoint = Vector2.new(0,0.5),
            Text = "", BorderSizePixel = 0, AutoButtonColor = false,
            ZIndex = 12, Parent = TopBar
        })
        Corner(b, 99)
        b.MouseEnter:Connect(function() Tween(b, {Size=UDim2.new(0,16,0,16)}, 0.12) end)
        b.MouseLeave:Connect(function() Tween(b, {Size=UDim2.new(0,14,0,14)}, 0.12) end)
        return b
    end

    local closeBtn = TopBtn(Icons.Window.Close, Color3.fromRGB(240,68,68), -30)
    local minBtn   = TopBtn(Icons.Window.Minimize, Color3.fromRGB(240,190,50), -52)

    MakeDraggable(TopBar, MainFrame)

    -- Sync aurora/glow position with main frame
    local posConn = MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
        GlowFrame.Position = MainFrame.Position
        AuroraFrame.Position = MainFrame.Position
    end)
    table.insert(Window._connections, posConn)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    -- Minimize
    minBtn.MouseButton1Click:Connect(function()
        if Window._minimized then Window:Restore() else Window:Minimize() end
    end)

    -- Toggle key
    local toggleConn = UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == toggleKey then
            Window:Toggle()
        end
    end)
    table.insert(Window._connections, toggleConn)
    -- ════════════════════════════════════════
    -- SIDEBAR
    -- ════════════════════════════════════════
    local Sidebar = Create("Frame", {
        Name = RNG(5), BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, tabWidth, 1, -45), Position = UDim2.new(0,0,0,45),
        BorderSizePixel = 0, ZIndex = 5, Parent = MainFrame
    })
    Create("Frame", {
        BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(1,0,0,10),
        Position = UDim2.new(0,0,0,0), BorderSizePixel = 0, ZIndex = 5, Parent = Sidebar
    })
    -- Sidebar divider
    Create("Frame", {
        BackgroundColor3 = Theme.Divider, Size = UDim2.new(0,1,1,-45),
        Position = UDim2.new(0,tabWidth,0,45), BorderSizePixel = 0, ZIndex = 8, Parent = MainFrame
    })

    -- ════════════════════════════════════════
    -- SEARCH BAR (in sidebar)
    -- ════════════════════════════════════════
    local SearchFrame = Create("Frame", {
        BackgroundColor3 = Theme.InputBg, Size = UDim2.new(1,-16,0,30),
        Position = UDim2.new(0,8,0,10), BorderSizePixel = 0, ZIndex = 7, Parent = Sidebar
    })
    Corner(SearchFrame, 7)
    Stroke(SearchFrame, Theme.ElementBorder, 1, 0.6)

    local searchIcon = MakeIcon(SearchFrame, Icons.Element.Search, 14, Theme.TextDimmed, 8,
        UDim2.new(0,6,0.5,0), Vector2.new(0,0.5))

    local SearchBox = Create("TextBox", {
        BackgroundTransparency = 1, Position = UDim2.new(0,26,0,0),
        Size = UDim2.new(1,-32,1,0), Font = Enum.Font.Gotham,
        Text = "", PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextDimmed, TextColor3 = Theme.TextPrimary,
        TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8, Parent = SearchFrame
    })

    -- Tab scroll
    local TabScroll = Create("ScrollingFrame", {
        BackgroundTransparency = 1, Size = UDim2.new(1,0,1,-50),
        Position = UDim2.new(0,0,0,48), BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0),
        ZIndex = 6, Parent = Sidebar
    })
    Pad(TabScroll, 4,4,8,8)
    local tabLayout = List(TabScroll, 4)
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0,0,0,tabLayout.AbsoluteContentSize.Y+12)
    end)

    -- Content Area
    local ContentArea = Create("Frame", {
        Name = RNG(5), BackgroundTransparency = 1,
        Size = UDim2.new(1, -(tabWidth+1), 1, -45),
        Position = UDim2.new(0, tabWidth+1, 0, 45),
        BorderSizePixel = 0, ZIndex = 3, Parent = MainFrame
    })

    -- ════════════════════════════════════════
    -- TOOLTIP SYSTEM
    -- ════════════════════════════════════════
    local TooltipFrame = Create("Frame", {
        BackgroundColor3 = Theme.Element, Visible = false,
        Size = UDim2.new(0,100,0,32), ZIndex = 250,
        BorderSizePixel = 0, Parent = ScreenGui
    })
    Corner(TooltipFrame, 6)
    Stroke(TooltipFrame, Theme.Accent, 1, 0.4)
    Create("ImageLabel", {
        BackgroundTransparency = 1, Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.Shadow, ImageTransparency = 0.5,
        Size = UDim2.new(1,12,1,12), Position = UDim2.new(0,-6,0,-6),
        ZIndex = 249, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23,23,277,277), Parent = TooltipFrame
    })
    local TooltipLabel = Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1,-14,1,0),
        Position = UDim2.new(0,7,0,0), Font = Enum.Font.Gotham,
        TextSize = 12, TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        ZIndex = 251, Parent = TooltipFrame
    })

    local tooltipVisible = false
    local function ShowTooltip(text)
        if not text or text == "" then return end
        TooltipLabel.Text = text
        tooltipVisible = true
        task.defer(function()
            local tw = TooltipLabel.TextBounds.X + 22
            tw = math.clamp(tw, 60, 280)
            local lines = math.ceil(TooltipLabel.TextBounds.Y / 14)
            TooltipFrame.Size = UDim2.new(0, tw, 0, 10 + lines*18)
        end)
        TooltipFrame.Visible = true
        Tween(TooltipFrame, {BackgroundTransparency = 0}, 0.15)
    end
    local function HideTooltip()
        tooltipVisible = false
        TooltipFrame.Visible = false
    end
    local ttConn = RunService.RenderStepped:Connect(function()
        if tooltipVisible then
            local mp = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.new(0, mp.X+16, 0, mp.Y-8)
        end
    end)
    table.insert(Window._connections, ttConn)

    local function AttachTooltip(frame, text)
        if not text or text == "" then return end
        frame.MouseEnter:Connect(function() ShowTooltip(text) end)
        frame.MouseLeave:Connect(function() HideTooltip() end)
    end

    -- ════════════════════════════════════════
    -- NOTIFICATION CONTAINER
    -- ════════════════════════════════════════
    local NotifHolder = Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0,310,1,-20),
        Position = UDim2.new(1,-320,0,10), ZIndex = 200, Parent = ScreenGui
    })
    List(NotifHolder, 8, Enum.FillDirection.Vertical,
         Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Bottom)

    -- ════════════════════════════════════════
    -- ADD TAB
    -- ════════════════════════════════════════
    function Window:AddTab(tabCfg)
        tabCfg = tabCfg or {}
        local tabTitle = tabCfg.Title or "Tab"
        local tabIcon  = tabCfg.Icon or Icons.Tab.Default
        local Tab = {}
        Tab._sections = {}
        Tab._order = 0

        -- Tab button
        local TabBtn = Create("TextButton", {
            BackgroundColor3 = Theme.TabInactive,
            Size = UDim2.new(1,0,0,38), Text = "", BorderSizePixel = 0,
            AutoButtonColor = false, ZIndex = 7, Parent = TabScroll
        })
        Corner(TabBtn, 7)

        -- Indicator
        local Indicator = Create("Frame", {
            BackgroundColor3 = Theme.Accent, Size = UDim2.new(0,3,0,0),
            Position = UDim2.new(0,0,0.5,0), AnchorPoint = Vector2.new(0,0.5),
            BorderSizePixel = 0, ZIndex = 8, Parent = TabBtn
        })
        Corner(Indicator, 2)

        -- Icon
        local iconObj = MakeIcon(TabBtn, tabIcon, 16, Theme.TextSecondary, 8,
            UDim2.new(0,12,0.5,0), Vector2.new(0,0.5))

        -- Label
        local TabLabel = Create("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0,36,0,0),
            Size = UDim2.new(1,-60,1,0), Font = Enum.Font.GothamMedium,
            Text = tabTitle, TextColor3 = Theme.TextSecondary, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8, Parent = TabBtn
        })

        -- Badge
        local BadgeLbl = Create("TextLabel", {
            BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
            Position = UDim2.new(1,-8,0,6), AnchorPoint = Vector2.new(1,0),
            Size = UDim2.new(0,20,0,18), Font = Enum.Font.GothamBold,
            Text = "", TextColor3 = Color3.new(1,1,1), TextSize = 11,
            ZIndex = 9, Parent = TabBtn, Visible = false
        })
        Corner(BadgeLbl, 9)

        function Tab:SetBadge(count)
            if count and count > 0 then
                BadgeLbl.Text = tostring(count)
                BadgeLbl.Visible = true
                BadgeLbl.BackgroundTransparency = 0
            else
                BadgeLbl.Visible = false
            end
        end

        -- Tab content page
        local TabPage = Create("ScrollingFrame", {
            BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
            BorderSizePixel = 0, ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent, ScrollBarImageTransparency = 0.5,
            CanvasSize = UDim2.new(0,0,0,0), Visible = false,
            ZIndex = 4, Parent = ContentArea
        })
        Pad(TabPage, 10,10,12,12)

        -- Two-column container
        local Columns = Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0),
            BorderSizePixel = 0, ZIndex = 4, Parent = TabPage
        })

        local LeftCol = Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0),
            Position = UDim2.new(0,0,0,0), BorderSizePixel = 0,
            ZIndex = 4, Parent = Columns
        })
        local leftLayout = List(LeftCol, 8)

        local RightCol = Create("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(0.5,-5,0,0),
            Position = UDim2.new(0.5,5,0,0), BorderSizePixel = 0,
            ZIndex = 4, Visible = false, Parent = Columns
        })
        local rightLayout = List(RightCol, 8)

        local hasRightCol = false

        local function UpdateCanvas()
            local lH = leftLayout.AbsoluteContentSize.Y
            local rH = rightLayout.AbsoluteContentSize.Y
            local maxH = math.max(lH, rH)
            Columns.Size = UDim2.new(1,0,0, maxH + 4)
            TabPage.CanvasSize = UDim2.new(0,0,0, maxH + 28)
        end

        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        -- Tab selection
        local function SelectTab()
            for _, t in pairs(Window._tabs) do
                t._btn.BackgroundColor3 = Theme.TabInactive
                t._label.TextColor3 = Theme.TextSecondary
                Tween(t._indicator, {Size=UDim2.new(0,3,0,0)}, 0.2)
                t._page.Visible = false
                if t._icon then
                    pcall(function()
                        if t._icon:IsA("ImageLabel") then t._icon.ImageColor3 = Theme.TextSecondary
                        else t._icon.TextColor3 = Theme.TextSecondary end
                    end)
                end
            end
            TabBtn.BackgroundColor3 = Theme.TabActive
            TabLabel.TextColor3 = Theme.TextPrimary
            Tween(Indicator, {Size=UDim2.new(0,3,0,20)}, 0.25, Enum.EasingStyle.Back)
            TabPage.Visible = true
            if iconObj then
                pcall(function()
                    if iconObj:IsA("ImageLabel") then iconObj.ImageColor3 = Theme.Accent
                    else iconObj.TextColor3 = Theme.Accent end
                end)
            end
            Window._activeTab = Tab
        end

        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then Tween(TabBtn, {BackgroundColor3 = Theme.TabHover}, 0.15) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then Tween(TabBtn, {BackgroundColor3 = Theme.TabInactive}, 0.15) end
        end)
        TabBtn.MouseButton1Click:Connect(SelectTab)

        Tab._btn = TabBtn
        Tab._label = TabLabel
        Tab._indicator = Indicator
        Tab._page = TabPage
        Tab._icon = iconObj
        Tab._leftCol = LeftCol
        Tab._rightCol = RightCol
        Tab._updateCanvas = UpdateCanvas

        table.insert(Window._tabs, Tab)
        if #Window._tabs == 1 then SelectTab() end
        -- ════════════════════════════════════════
        -- ADD SECTION
        -- ════════════════════════════════════════
        function Tab:AddSection(secCfg)
            secCfg = secCfg or {}
            local secTitle = secCfg.Title or "Section"
            local secSide  = secCfg.Side or "Left"
            local secIcon  = secCfg.Icon or nil

            local Section = {}
            Section._order = 0

            -- Enable two-column if Right
            if secSide == "Right" and not hasRightCol then
                hasRightCol = true
                LeftCol.Size = UDim2.new(0.5, -5, 0, 0)
                RightCol.Visible = true
            end

            local parentCol = (secSide == "Right") and RightCol or LeftCol

            -- Section frame
            local SecFrame = Create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0),
                BorderSizePixel = 0, ZIndex = 5, Parent = parentCol
            })

            -- Section header
            local HeaderH = 32
            local Header = Create("Frame", {
                BackgroundColor3 = Theme.SectionHeader, Size = UDim2.new(1,0,0,HeaderH),
                BorderSizePixel = 0, ZIndex = 5, Parent = SecFrame
            })
            Corner(Header, 7)
            Stroke(Header, Theme.ElementBorder, 1, 0.7)

            local headerTextX = 10
            if secIcon then
                MakeIcon(Header, secIcon, 14, Theme.TextDimmed, 6,
                    UDim2.new(0,8,0.5,0), Vector2.new(0,0.5))
                headerTextX = 28
            end
            Create("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0,headerTextX,0,0),
                Size = UDim2.new(1,-headerTextX-8,1,0), Font = Enum.Font.GothamBold,
                Text = string.upper(secTitle), TextColor3 = Theme.TextDimmed,
                TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6, Parent = Header
            })

            -- Section content
            local SecContent = Create("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0),
                Position = UDim2.new(0,0,0,HeaderH+4), BorderSizePixel = 0,
                ZIndex = 5, Parent = SecFrame
            })
            local secLayout = List(SecContent, 6)

            secLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SecContent.Size = UDim2.new(1,0,0, secLayout.AbsoluteContentSize.Y)
                SecFrame.Size = UDim2.new(1,0,0, HeaderH + 4 + secLayout.AbsoluteContentSize.Y + 4)
                UpdateCanvas()
            end)

            -- Helper: Register element for config
            local function RegisterElement(flag, elType, getF, setF)
                if not flag then return end
                Window._elements[flag] = {Type = elType, Get = getF, Set = setF}
            end

            -- Helper: Create element base frame
            local function ElemFrame(h, isBtn)
                Section._order = Section._order + 1
                local cls = isBtn and "TextButton" or "Frame"
                local f = Create(cls, {
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.new(1,0,0,h), BorderSizePixel = 0,
                    ZIndex = 5, LayoutOrder = Section._order, Parent = SecContent
                })
                if isBtn then f.Text = ""; f.AutoButtonColor = false end
                Corner(f, 8)
                Stroke(f, Theme.ElementBorder, 1, 0.7)
                -- Hover
                f.MouseEnter:Connect(function() Tween(f, {BackgroundColor3=Theme.ElementHover}, 0.12) end)
                f.MouseLeave:Connect(function() Tween(f, {BackgroundColor3=Theme.Element}, 0.12) end)
                return f
            end
            -- ════════════════════════════════════
            -- LABEL
            -- ════════════════════════════════════
            function Section:AddLabel(opts)
                opts = (type(opts)=="string") and {Text=opts} or (opts or {})
                local f = ElemFrame(34, false)
                local lbl = Create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0,12,0,0),
                    Size = UDim2.new(1,-24,1,0), Font = Enum.Font.GothamMedium,
                    Text = opts.Text or "Label", TextColor3 = Theme.TextSecondary,
                    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6, TextWrapped = true, Parent = f
                })
                local obj = {}
                function obj:Set(t) lbl.Text = t end
                function obj:Get() return lbl.Text end
                return obj
            end

            -- ════════════════════════════════════
            -- DIVIDER
            -- ════════════════════════════════════
            function Section:AddDivider(opts)
                opts = opts or {}
                Section._order = Section._order + 1
                local divText = opts.Text or nil
                local h = divText and 26 or 14

                local f = Create("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,0,0,h),
                    ZIndex = 5, LayoutOrder = Section._order, Parent = SecContent
                })
                if divText then
                    Create("TextLabel", {
                        BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
                        Font = Enum.Font.GothamBold, Text = divText,
                        TextColor3 = Theme.TextDimmed, TextSize = 11,
                        ZIndex = 6, Parent = f
                    })
                end
                Create("Frame", {
                    BackgroundColor3 = Theme.Divider, Size = UDim2.new(1,0,0,1),
                    Position = UDim2.new(0,0,1,-2), BorderSizePixel = 0,
                    ZIndex = 5, Parent = f
                })
                return f
            end

            -- ════════════════════════════════════
            -- TOGGLE
            -- ════════════════════════════════════
            function Section:AddToggle(opts)
                opts = opts or {}
                local tTitle    = opts.Title or "Toggle"
                local tDesc     = opts.Description
                local tDefault  = opts.Default or false
                local tTooltip  = opts.Tooltip
                local tCallback = opts.Callback or function() end
                local tFlag     = opts.Flag

                local hasDesc = tDesc and tDesc ~= ""
                local h = hasDesc and 54 or 38
                local toggled = tDefault

                local f = ElemFrame(h, true)
                AttachTooltip(f, tTooltip)

                -- Title
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0, hasDesc and 6 or 0),
                    Size = UDim2.new(1,-70,0, hasDesc and 22 or h),
                    Font = Enum.Font.GothamMedium, Text = tTitle,
                    TextColor3 = Theme.TextPrimary, TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = f
                })
                if hasDesc then
                    Create("TextLabel", {
                        BackgroundTransparency = 1, Position = UDim2.new(0,12,0,28),
                        Size = UDim2.new(1,-70,0,18), Font = Enum.Font.Gotham,
                        Text = tDesc, TextColor3 = Theme.TextDimmed, TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = f
                    })
                end

                -- Switch
                local sw = Create("Frame", {
                    BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff,
                    Size = UDim2.new(0,42,0,24), Position = UDim2.new(1,-54,0.5,0),
                    AnchorPoint = Vector2.new(0,0.5), BorderSizePixel = 0, ZIndex = 7, Parent = f
                })
                Corner(sw, 12)
                local circle = Create("Frame", {
                    BackgroundColor3 = Theme.ToggleCircle, Size = UDim2.new(0,18,0,18),
                    Position = toggled and UDim2.new(1,-21,0.5,0) or UDim2.new(0,3,0.5,0),
                    AnchorPoint = Vector2.new(0,0.5), BorderSizePixel = 0, ZIndex = 8, Parent = sw
                })
                Corner(circle, 99)

                local function UpdateToggle()
                    Tween(sw, {BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
                    Tween(circle, {Position = toggled and UDim2.new(1,-21,0.5,0) or UDim2.new(0,3,0.5,0)}, 0.2, Enum.EasingStyle.Back)
                end

                f.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    UpdateToggle()
                    SafeCall(tCallback, toggled)
                end)

                if tDefault then SafeCall(tCallback, true) end

                -- Searchable
                table.insert(Window._searchable, {Title = tTitle, Tab = Tab, Frame = f})

                local obj = {}
                function obj:Set(v) toggled = v; UpdateToggle(); SafeCall(tCallback, v) end
                function obj:Get() return toggled end
                RegisterElement(tFlag, "Toggle", obj.Get, obj.Set)
                return obj
            end
            -- ════════════════════════════════════
            -- SLIDER
            -- ════════════════════════════════════
            function Section:AddSlider(opts)
                opts = opts or {}
                local sTitle     = opts.Title or "Slider"
                local sDesc      = opts.Description
                local sMin       = opts.Min or 0
                local sMax       = opts.Max or 100
                local sDefault   = opts.Default or sMin
                local sIncrement = opts.Increment or 1
                local sSuffix    = opts.Suffix or ""
                local sAllowInput = opts.AllowInput ~= false
                local sTooltip   = opts.Tooltip
                local sCallback  = opts.Callback or function() end
                local sFlag      = opts.Flag

                local hasDesc = sDesc and sDesc ~= ""
                local h = hasDesc and 62 or 52
                local current = sDefault

                local f = ElemFrame(h, false)
                AttachTooltip(f, sTooltip)

                -- Title
                Create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0,12,0, hasDesc and 4 or 4),
                    Size = UDim2.new(0.5,-12,0,20), Font = Enum.Font.GothamMedium,
                    Text = sTitle, TextColor3 = Theme.TextPrimary, TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = f
                })
                if hasDesc then
                    Create("TextLabel", {
                        BackgroundTransparency = 1, Position = UDim2.new(0,12,0,22),
                        Size = UDim2.new(0.5,-12,0,16), Font = Enum.Font.Gotham,
                        Text = sDesc, TextColor3 = Theme.TextDimmed, TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = f
                    })
                end

                -- Value display (clickable for direct input)
                local valLbl
                if sAllowInput then
                    valLbl = Create("TextBox", {
                        BackgroundColor3 = Theme.InputBg, Position = UDim2.new(1,-70,0,6),
                        Size = UDim2.new(0,58,0,22), Font = Enum.Font.GothamMedium,
                        Text = tostring(current)..sSuffix, TextColor3 = Theme.Accent,
                        TextSize = 12, BorderSizePixel = 0, ClearTextOnFocus = true,
                        ZIndex = 7, Parent = f
                    })
                    Corner(valLbl, 5)
                else
                    valLbl = Create("TextLabel", {
                        BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0,4),
                        Size = UDim2.new(0.5,-12,0,20), Font = Enum.Font.GothamMedium,
                        Text = tostring(current)..sSuffix, TextColor3 = Theme.Accent,
                        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
                        ZIndex = 6, Parent = f
                    })
                end

                -- Slider bar
                local barY = h - 16
                local bar = Create("Frame", {
                    BackgroundColor3 = Theme.SliderBack, Size = UDim2.new(1,-24,0,6),
                    Position = UDim2.new(0,12,0,barY), BorderSizePixel = 0, ZIndex = 6, Parent = f
                })
                Corner(bar, 3)

                local fillPct = math.clamp((sDefault-sMin)/(sMax-sMin), 0, 1)
                local fill = Create("Frame", {
                    BackgroundColor3 = Theme.SliderFill, Size = UDim2.new(fillPct,0,1,0),
                    BorderSizePixel = 0, ZIndex = 7, Parent = bar
                })
                Corner(fill, 3)

                local knob = Create("Frame", {
                    BackgroundColor3 = Theme.ToggleCircle, Size = UDim2.new(0,14,0,14),
                    Position = UDim2.new(fillPct,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5),
                    BorderSizePixel = 0, ZIndex = 8, Parent = bar
                })
                Corner(knob, 99)
                Stroke(knob, Theme.Accent, 2, 0.3)

                local sliding = false
                local function SetValue(v)
                    current = math.clamp(v, sMin, sMax)
                    local steps = math.floor((current-sMin)/sIncrement+0.5)
                    current = sMin + steps*sIncrement
                    current = math.clamp(current, sMin, sMax)
                    if sIncrement >= 1 then current = math.floor(current)
                    else
                        local dec = #(tostring(sIncrement):match("%.(%d+)") or "")
                        current = tonumber(string.format("%."..dec.."f", current))
                    end
                    local pct = (current-sMin)/(sMax-sMin)
                    Tween(fill, {Size=UDim2.new(pct,0,1,0)}, 0.06, Enum.EasingStyle.Sine)
                    Tween(knob, {Position=UDim2.new(pct,0,0.5,0)}, 0.06, Enum.EasingStyle.Sine)
                    valLbl.Text = tostring(current)..sSuffix
                    SafeCall(sCallback, current)
                end

                local function SlideInput(inp)
                    local pct = math.clamp((inp.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                    SetValue(sMin + (sMax-sMin)*pct)
                end

                bar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        sliding = true; SlideInput(i)
                    end
                end)
                knob.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
                end)
                local sc1 = UserInputService.InputChanged:Connect(function(i)
                    if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        SlideInput(i)
                    end
                end)
                local sc2 = UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
                end)
                table.insert(Window._connections, sc1)
                table.insert(Window._connections, sc2)

                -- Allow typed input
                if sAllowInput and valLbl:IsA("TextBox") then
                    valLbl.FocusLost:Connect(function()
                        local num = tonumber(valLbl.Text:gsub("[^%d%.%-]",""))
                        if num then SetValue(num) else valLbl.Text = tostring(current)..sSuffix end
                    end)
                end

                SafeCall(sCallback, sDefault)
                table.insert(Window._searchable, {Title = sTitle, Tab = Tab, Frame = f})

                local obj = {}
                function obj:Set(v) SetValue(v) end
                function obj:Get() return current end
                RegisterElement(sFlag, "Slider", obj.Get, obj.Set)
                return obj
            end

            -- ════════════════════════════════════
            -- BUTTON (4 Styles)
            -- ════════════════════════════════════
            function Section:AddButton(opts)
                opts = opts or {}
                local bTitle    = opts.Title or "Button"
                local bStyle    = opts.Style or "Primary"
                local bTooltip  = opts.Tooltip
                local bCallback = opts.Callback or function() end

                Section._order = Section._order + 1

                local styleColors = {
                    Primary   = {bg = Theme.Accent,  hover = Theme.AccentHover, text = Color3.new(1,1,1)},
                    Secondary = {bg = Theme.Element,  hover = Theme.ElementHover, text = Theme.TextPrimary},
                    Success   = {bg = Theme.Success,  hover = Color3.fromRGB(20,210,148), text = Color3.new(1,1,1)},
                    Danger    = {bg = Theme.Danger,   hover = Color3.fromRGB(255,90,90), text = Color3.new(1,1,1)},
                }
                local sc = styleColors[bStyle] or styleColors.Primary

                local btn = Create("TextButton", {
                    BackgroundColor3 = sc.bg, Size = UDim2.new(1,0,0,36),
                    Text = "", BorderSizePixel = 0, AutoButtonColor = false,
                    ZIndex = 5, LayoutOrder = Section._order, Parent = SecContent
                })
                Corner(btn, 8)
                if bStyle == "Secondary" then Stroke(btn, Theme.ElementBorder, 1, 0.6) end

                Create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
                    Font = Enum.Font.GothamBold, Text = bTitle,
                    TextColor3 = sc.text, TextSize = 14,
                    ZIndex = 6, Parent = btn
                })

                AttachTooltip(btn, bTooltip)
                Ripple(btn)

                btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3=sc.hover}, 0.12) end)
                btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3=sc.bg}, 0.12) end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, {Size=UDim2.new(1,-4,0,34)}, 0.08)
                    task.delay(0.1, function() Tween(btn, {Size=UDim2.new(1,0,0,36)}, 0.1) end)
                    SafeCall(bCallback)
                end)

                table.insert(Window._searchable, {Title = bTitle, Tab = Tab, Frame = btn})
                return btn
            end
            -- ════════════════════════════════════
            -- INPUT (TextBox)
            -- ════════════════════════════════════
            function Section:AddInput(opts)
                opts = opts or {}
                local iTitle       = opts.Title or "Input"
                local iDesc        = opts.Description
                local iDefault     = opts.Default or ""
                local iPlaceholder = opts.Placeholder or "Type here..."
                local iType        = opts.Type or "String"
                local iMin         = opts.Min
                local iMax         = opts.Max
                local iTooltip     = opts.Tooltip
                local iCallback    = opts.Callback or function() end
                local iFlag        = opts.Flag

                local hasDesc = iDesc and iDesc ~= ""
                local h = hasDesc and 54 or 40
                local f = ElemFrame(h, false)
                AttachTooltip(f, iTooltip)

                Create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0,12,0, hasDesc and 4 or 0),
                    Size = UDim2.new(0.45,-12,0, hasDesc and 20 or h),
                    Font = Enum.Font.GothamMedium, Text = iTitle,
                    TextColor3 = Theme.TextPrimary, TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = f
                })
                if hasDesc then
                    Create("TextLabel", {
                        BackgroundTransparency = 1, Position = UDim2.new(0,12,0,24),
                        Size = UDim2.new(0.45,-12,0,16), Font = Enum.Font.Gotham,
                        Text = iDesc, TextColor3 = Theme.TextDimmed, TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = f
                    })
                end

                local box = Create("TextBox", {
                    BackgroundColor3 = Theme.InputBg,
                    Position = UDim2.new(0.45,4,0.5,0), AnchorPoint = Vector2.new(0,0.5),
                    Size = UDim2.new(0.55,-16,0,26), Font = Enum.Font.Gotham,
                    Text = tostring(iDefault), PlaceholderText = iPlaceholder,
                    PlaceholderColor3 = Theme.TextDimmed, TextColor3 = Theme.TextPrimary,
                    TextSize = 12, ClearTextOnFocus = false, BorderSizePixel = 0,
                    ZIndex = 7, Parent = f
                })
                Corner(box, 6)
                local bStroke = Stroke(box, Theme.ElementBorder, 1, 0.5)

                box.Focused:Connect(function()
                    Tween(bStroke, {Color=Theme.Accent, Transparency=0.2}, 0.2)
                end)
                box.FocusLost:Connect(function()
                    Tween(bStroke, {Color=Theme.ElementBorder, Transparency=0.5}, 0.2)
                    local val = box.Text
                    if iType == "Number" or iType == "Integer" then
                        local n = tonumber(val:gsub("[^%d%.%-]",""))
                        if n then
                            if iType == "Integer" then n = math.floor(n) end
                            if iMin then n = math.max(n, iMin) end
                            if iMax then n = math.min(n, iMax) end
                            box.Text = tostring(n)
                            SafeCall(iCallback, n)
                        else
                            box.Text = tostring(iDefault)
                        end
                    else
                        SafeCall(iCallback, val)
                    end
                end)

                table.insert(Window._searchable, {Title = iTitle, Tab = Tab, Frame = f})

                local obj = {}
                function obj:Set(v) box.Text = tostring(v) end
                function obj:Get() return box.Text end
                RegisterElement(iFlag, "Input", obj.Get, obj.Set)
                return obj
            end

            -- ════════════════════════════════════
            -- DROPDOWN (Single & Multi)
            -- ════════════════════════════════════
            function Section:AddDropdown(opts)
                opts = opts or {}
                local dTitle    = opts.Title or "Dropdown"
                local dItems    = opts.Items or opts.Options or {}
                local dDefault  = opts.Default
                local dMulti    = opts.Multi or false
                local dTooltip  = opts.Tooltip
                local dCallback = opts.Callback or function() end
                local dFlag     = opts.Flag

                local opened = false
                local selected = dMulti and {} or dDefault
                if dMulti and dDefault then
                    selected = type(dDefault)=="table" and dDefault or {dDefault}
                end
                local optBtns = {}

                local closedH = 40
                local optH = 30
                local maxVis = math.min(#dItems, 6)

                Section._order = Section._order + 1

                local f = Create("Frame", {
                    BackgroundColor3 = Theme.Element, Size = UDim2.new(1,0,0,closedH),
                    BorderSizePixel = 0, ClipsDescendants = true,
                    ZIndex = 5, LayoutOrder = Section._order, Parent = SecContent
                })
                Corner(f, 8)
                Stroke(f, Theme.ElementBorder, 1, 0.7)
                AttachTooltip(f, dTooltip)

                Create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0,12,0,0),
                    Size = UDim2.new(0.5,-12,0,closedH), Font = Enum.Font.GothamMedium,
                    Text = dTitle, TextColor3 = Theme.TextPrimary, TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = f
                })

                local function DisplayText()
                    if dMulti then
                        if #selected == 0 then return "None" end
                        return table.concat(selected, ", ")
                    else
                        return selected or "Select..."
                    end
                end

                local selLbl = Create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0.3,0,0,0),
                    Size = UDim2.new(0.7,-38,0,closedH), Font = Enum.Font.Gotham,
                    Text = DisplayText(), TextColor3 = Theme.TextSecondary,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6, Parent = f
                })

                local arrow = Create("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(1,-28,0,0),
                    Size = UDim2.new(0,20,0,closedH), Font = Enum.Font.GothamBold,
                    Text = Icons.Element.Dropdown, TextColor3 = Theme.TextDimmed,
                    TextSize = 16, ZIndex = 6, Rotation = 0, Parent = f
                })

                -- Options container
                local optCon = Create("ScrollingFrame", {
                    BackgroundTransparency = 1, Position = UDim2.new(0,6,0,closedH+2),
                    Size = UDim2.new(1,-12,0, maxVis*(optH+3)),
                    BorderSizePixel = 0, ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize = UDim2.new(0,0,0,0), ZIndex = 7, Parent = f
                })
                local optLayout = List(optCon, 3)
                optLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    optCon.CanvasSize = UDim2.new(0,0,0, optLayout.AbsoluteContentSize.Y+4)
                end)

                -- Multi-select buttons (Select All / Clear All)
                local multiBar
                if dMulti then
                    multiBar = Create("Frame", {
                        BackgroundTransparency = 1, Size = UDim2.new(1,-12,0,28),
                        Position = UDim2.new(0,6,0,closedH + 2 + maxVis*(optH+3) + 4),
                        ZIndex = 7, Parent = f
                    })
                    local selAllBtn = Create("TextButton", {
                        BackgroundColor3 = Theme.Accent, Size = UDim2.new(0.48,0,1,0),
                        Text = Icons.Element.SelectAll.." All", Font = Enum.Font.GothamMedium,
                        TextColor3 = Color3.new(1,1,1), TextSize = 11,
                        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 8, Parent = multiBar
                    })
                    Corner(selAllBtn, 5)
                    local clrBtn = Create("TextButton", {
                        BackgroundColor3 = Theme.Danger, Size = UDim2.new(0.48,0,1,0),
                        Position = UDim2.new(0.52,0,0,0),
                        Text = Icons.Element.ClearAll.." Clear", Font = Enum.Font.GothamMedium,
                        TextColor3 = Color3.new(1,1,1), TextSize = 11,
                        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 8, Parent = multiBar
                    })
                    Corner(clrBtn, 5)

                    selAllBtn.MouseButton1Click:Connect(function()
                        selected = {}
                        for _, item in ipairs(dItems) do table.insert(selected, item) end
                        UpdateOpts()
                        SafeCall(dCallback, selected)
                    end)
                    clrBtn.MouseButton1Click:Connect(function()
                        selected = {}
                        UpdateOpts()
                        SafeCall(dCallback, selected)
                    end)
                end

                local function UpdateOpts()
                    for _, o in pairs(optBtns) do
                        local isSel = dMulti and table.find(selected, o.Val) or (selected == o.Val)
                        if isSel then
                            Tween(o.Btn, {BackgroundColor3 = Theme.Accent}, 0.12)
                            o.Lbl.TextColor3 = Color3.new(1,1,1)
                        else
                            Tween(o.Btn, {BackgroundColor3 = Theme.DropdownBg}, 0.12)
                            o.Lbl.TextColor3 = Theme.TextSecondary
                        end
                    end
                    selLbl.Text = DisplayText()
                end

                local function BuildOpts()
                    for _, c in pairs(optCon:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    optBtns = {}
                    for i, item in ipairs(dItems) do
                        local ob = Create("TextButton", {
                            BackgroundColor3 = Theme.DropdownBg, Size = UDim2.new(1,0,0,optH),
                            Text = "", BorderSizePixel = 0, AutoButtonColor = false,
                            ZIndex = 8, LayoutOrder = i, Parent = optCon
                        })
                        Corner(ob, 6)
                        local ol = Create("TextLabel", {
                            BackgroundTransparency = 1, Size = UDim2.new(1,-16,1,0),
                            Position = UDim2.new(0,8,0,0), Font = Enum.Font.Gotham,
                            Text = item, TextColor3 = Theme.TextSecondary, TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9, Parent = ob
                        })
                        ob.MouseEnter:Connect(function()
                            local isSel = dMulti and table.find(selected, item) or (selected==item)
                            if not isSel then Tween(ob, {BackgroundColor3=Theme.DropdownHover}, 0.1) end
                        end)
                        ob.MouseLeave:Connect(function()
                            local isSel = dMulti and table.find(selected, item) or (selected==item)
                            if not isSel then Tween(ob, {BackgroundColor3=Theme.DropdownBg}, 0.1) end
                        end)
                        ob.MouseButton1Click:Connect(function()
                            if dMulti then
                                local idx = table.find(selected, item)
                                if idx then table.remove(selected, idx) else table.insert(selected, item) end
                                UpdateOpts()
                                SafeCall(dCallback, selected)
                            else
                                selected = item
                                UpdateOpts()
                                SafeCall(dCallback, selected)
                                opened = false
                                Tween(f, {Size=UDim2.new(1,0,0,closedH)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                                Tween(arrow, {Rotation=0}, 0.22)
                            end
                        end)
                        table.insert(optBtns, {Btn=ob, Lbl=ol, Val=item})
                    end
                    maxVis = math.min(#dItems, 6)
                    optCon.Size = UDim2.new(1,-12,0, maxVis*(optH+3))
                    if multiBar then
                        multiBar.Position = UDim2.new(0,6,0, closedH+2+maxVis*(optH+3)+4)
                    end
                    UpdateOpts()
                end
                BuildOpts()

                -- Toggle button
                local dropBtn = Create("TextButton", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,0,0,closedH),
                    Text = "", ZIndex = 10, Parent = f
                })
                dropBtn.MouseButton1Click:Connect(function()
                    opened = not opened
                    local multiH = dMulti and 36 or 0
                    if opened then
                        local openH = closedH + 6 + maxVis*(optH+3) + multiH
                        Tween(f, {Size=UDim2.new(1,0,0,openH)}, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        Tween(arrow, {Rotation=180}, 0.28)
                    else
                        Tween(f, {Size=UDim2.new(1,0,0,closedH)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                        Tween(arrow, {Rotation=0}, 0.22)
                    end
                end)

                if dDefault then SafeCall(dCallback, dMulti and selected or dDefault) end
                table.insert(Window._searchable, {Title = dTitle, Tab = Tab, Frame = f})

                local obj = {}
                function obj:Set(v) selected = v; UpdateOpts(); SafeCall(dCallback, v) end
                function obj:SetItems(items) dItems = items; BuildOpts() end
                function obj:Get() return selected end
                RegisterElement(dFlag, "Dropdown", obj.Get, obj.Set)
                return obj
            end
    
