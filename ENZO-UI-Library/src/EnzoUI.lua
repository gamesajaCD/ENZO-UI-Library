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
    GitHub: github.com/gamesajaCD/ENZO-UI-Library
]]

local EnzoUI = {}
EnzoUI.__index = EnzoUI
EnzoUI.Version = "1.0.0"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Device Detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Utility Functions
local Utility = {}

function Utility.Tween(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    for _, child in pairs(children or {}) do
        if child then
            child.Parent = instance
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility.MakeDraggable(frame, dragObject)
    dragObject = dragObject or frame
    local dragging, dragInput, dragStart, startPos
    
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
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility.RGBToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utility.HexToRGB(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 255,
        tonumber(hex:sub(3, 4), 16) or 255,
        tonumber(hex:sub(5, 6), 16) or 255
    )
end

function Utility.RGBToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    
    local d = max - min
    s = max == 0 and 0 or d / max
    
    if max ~= min then
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
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

-- Themes
local Themes = {
    Aurora = {
        Primary = Color3.fromRGB(139, 92, 246),
        Secondary = Color3.fromRGB(59, 130, 246),
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
        Info = Color3.fromRGB(59, 130, 246)
    },
    Sunset = {
        Primary = Color3.fromRGB(255, 107, 53),
        Secondary = Color3.fromRGB(247, 147, 30),
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
        Info = Color3.fromRGB(59, 130, 246)
    },
    Ocean = {
        Primary = Color3.fromRGB(6, 182, 212),
        Secondary = Color3.fromRGB(59, 130, 246),
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
        Info = Color3.fromRGB(59, 130, 246)
    }
}

-- File System
local function WriteFile(path, content)
    if writefile then
        pcall(function() writefile(path, content) end)
        return true
    end
    return false
end

local function ReadFile(path)
    if readfile and isfile then
        local success, result = pcall(function()
            if isfile(path) then
                return readfile(path)
            end
        end)
        if success then return result end
    end
    return nil
end

local function MakeFolder(path)
    if makefolder then
        pcall(function() makefolder(path) end)
    end
end

local function ListFiles(path)
    if listfiles then
        local success, result = pcall(function() return listfiles(path) end)
        if success then return result end
    end
    return {}
end

-- Notifications
local NotificationHolder = nil

local function CreateNotificationHolder(parent, theme)
    NotificationHolder = Utility.Create("Frame", {
        Name = "Notifications",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        AnchorPoint = Vector2.new(1, 1)
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right
        })
    })
end

local function Notify(options, theme)
    if not NotificationHolder then return end
    
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local notifType = options.Type or "Info"
    local duration = options.Duration or 5
    
    local colors = {
        Info = theme.Info,
        Success = theme.Success,
        Warning = theme.Warning,
        Error = theme.Error
    }
    
    local icons = {
        Info = "ℹ️",
        Success = "✅",
        Warning = "⚠️",
        Error = "❌"
    }
    
    local color = colors[notifType] or theme.Info
    local icon = icons[notifType] or "ℹ️"
    
    local notif = Utility.Create("Frame", {
        Parent = NotificationHolder,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 80),
        LayoutOrder = -tick()
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utility.Create("UIStroke", {Color = color, Thickness = 1, Transparency = 0.5}),
        Utility.Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0)
        }),
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 10),
            Size = UDim2.new(1, -80, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = icon .. " " .. title,
            TextColor3 = theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 32),
            Size = UDim2.new(1, -80, 0, 35),
            Font = Enum.Font.Gotham,
            Text = content,
            TextColor3 = theme.TextSecondary,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        }),
        Utility.Create("TextButton", {
            Name = "Close",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -30, 0, 5),
            Size = UDim2.new(0, 20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = theme.TextMuted,
            TextSize = 18
        }),
        Utility.Create("Frame", {
            Name = "Progress",
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3)
        })
    })
    
    notif.Close.MouseButton1Click:Connect(function()
        Utility.Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.delay(0.3, function() notif:Destroy() end)
    end)
    
    Utility.Tween(notif.Progress, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        if notif.Parent then
            Utility.Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.delay(0.3, function() notif:Destroy() end)
        end
    end)
end

-- CreateWindow
function EnzoUI:CreateWindow(options)
    options = options or {}
    
    local Window = setmetatable({}, {__index = self})
    Window.Tabs = {}
    Window.Elements = {}
    Window.ConfigElements = {}
    
    local theme = Themes[options.Theme] or Themes.Aurora
    Window.Theme = theme
    Window.ConfigFolder = options.ConfigFolder or "EnzoUI"
    MakeFolder(Window.ConfigFolder)
    
    -- ScreenGui
    local screenGui = Utility.Create("ScreenGui", {
        Name = "EnzoUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
    
    CreateNotificationHolder(screenGui, theme)
    
    -- Main Window
    local main = Utility.Create("Frame", {
        Parent = screenGui,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = options.Size or UDim2.new(0, 700, 0, 500),
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    -- Header
    local header = Utility.Create("Frame", {
        Parent = main,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Utility.Create("Frame", {
            BackgroundColor3 = theme.BackgroundSecondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -10),
            Size = UDim2.new(1, 0, 0, 10)
        }),
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(0.7, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = ">_ " .. (options.Title or "ENZO UI"),
            TextColor3 = theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility.Create("TextButton", {
            Name = "Close",
            BackgroundColor3 = theme.Error,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -35, 0, 10),
            Size = UDim2.new(0, 25, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
        })
    })
    
    Utility.MakeDraggable(main, header)
    
    header.Close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tabs Container
    local tabsContainer = Utility.Create("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(1, -20, 0, 35)
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 5)
        })
    })
    
    -- Content Area
    local contentArea = Utility.Create("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 105),
        Size = UDim2.new(1, -20, 1, -115)
    })
    
    -- Toggle UI
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            main.Visible = not main.Visible
        end
    end)
    
    -- Methods
    function Window:Notify(opts)
        Notify(opts, self.Theme)
    end
    
    function Window:AddTab(tabOpts)
        local Tab = {}
        Tab.Sections = {}
        
        local tabBtn = Utility.Create("TextButton", {
            Parent = tabsContainer,
            BackgroundColor3 = #self.Tabs == 0 and theme.Primary or theme.BackgroundTertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = "  " .. (tabOpts.Icon or "📁") .. " " .. (tabOpts.Title or "Tab") .. "  ",
            TextColor3 = theme.Text,
            TextSize = 12
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
        })
        
        local tabContent = Utility.Create("ScrollingFrame", {
            Parent = contentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Primary,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = #self.Tabs == 0
        }, {
            Utility.Create("UIListLayout", {Padding = UDim.new(0, 10)})
        })
        
        tabBtn.MouseButton1Click:Connect(function()
            for _, tab in ipairs(self.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = theme.BackgroundTertiary
            end
            tabContent.Visible = true
            tabBtn.BackgroundColor3 = theme.Primary
        end)
        
        Tab.Button = tabBtn
        Tab.Content = tabContent
        
        function Tab:AddSection(sectionOpts)
            local Section = {}
            
            local sectionFrame = Utility.Create("Frame", {
                Parent = tabContent,
                BackgroundColor3 = theme.BackgroundSecondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            }, {
                Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Utility.Create("UIPadding", {
                    PaddingTop = UDim.new(0, 40),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                }),
                Utility.Create("UIListLayout", {Padding = UDim.new(0, 8)}),
                Utility.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 25),
                    Font = Enum.Font.GothamBold,
                    Text = (sectionOpts.Icon or "📌") .. " " .. (sectionOpts.Title or "Section"),
                    TextColor3 = theme.Primary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
            
            -- Add Toggle
            function Section:AddToggle(opts)
                opts = opts or {}
                local Toggle = {Value = opts.Default or false}
                
                local toggleFrame = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -60, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = opts.Title or "Toggle",
                        TextColor3 = theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Utility.Create("TextButton", {
                        Name = "Btn",
                        BackgroundColor3 = Toggle.Value and theme.Primary or theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -50, 0.5, 0),
                        Size = UDim2.new(0, 45, 0, 22),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Text = Toggle.Value and "ON" or "OFF",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.Code,
                        TextSize = 10
                    }, {
                        Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                    })
                })
                
                local btn = toggleFrame.Btn
                
                btn.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    btn.BackgroundColor3 = Toggle.Value and theme.Primary or theme.Border
                    btn.Text = Toggle.Value and "ON" or "OFF"
                    
                    if opts.Callback then
                        task.spawn(function()
                            pcall(opts.Callback, Toggle.Value)
                        end)
                    end
                    
                    if opts.Flag then
                        Window.ConfigElements[opts.Flag] = Toggle.Value
                    end
                end)
                
                function Toggle:SetValue(val)
                    Toggle.Value = val
                    btn.BackgroundColor3 = val and theme.Primary or theme.Border
                    btn.Text = val and "ON" or "OFF"
                end
                
                if opts.Flag then
                    Window.ConfigElements[opts.Flag] = Toggle.Value
                    Toggle.Flag = opts.Flag
                end
                
                table.insert(Window.Elements, Toggle)
                return Toggle
            end
            
            -- Add Slider
            function Section:AddSlider(opts)
                opts = opts or {}
                local Slider = {
                    Value = opts.Default or opts.Min or 0,
                    Min = opts.Min or 0,
                    Max = opts.Max or 100
                }
                
                local sliderFrame = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 50)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                Utility.Create("TextLabel", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(0.6, 0, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = opts.Title or "Slider",
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local valueLabel = Utility.Create("TextLabel", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -10, 0, 5),
                    Size = UDim2.new(0.4, 0, 0, 16),
                    AnchorPoint = Vector2.new(1, 0),
                    Font = Enum.Font.Code,
                    Text = tostring(Slider.Value) .. (opts.Suffix or ""),
                    TextColor3 = theme.Primary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local track = Utility.Create("Frame", {
                    Parent = sliderFrame,
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 6)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                })
                
                local percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
                
                local fill = Utility.Create("Frame", {
                    Parent = track,
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(percent, 0, 1, 0)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                })
                
                local function updateSlider(input)
                    local pos = track.AbsolutePosition.X
                    local size = track.AbsoluteSize.X
                    local mousePos = input.Position.X
                    
                    local newPercent = math.clamp((mousePos - pos) / size, 0, 1)
                    local newValue = Slider.Min + (Slider.Max - Slider.Min) * newPercent
                    
                    if opts.Increment then
                        newValue = math.floor(newValue / opts.Increment + 0.5) * opts.Increment
                    end
                    
                    newValue = math.clamp(newValue, Slider.Min, Slider.Max)
                    Slider.Value = newValue
                    
                    fill.Size = UDim2.new(newPercent, 0, 1, 0)
                    valueLabel.Text = tostring(newValue) .. (opts.Suffix or "")
                    
                    if opts.Callback then
                        task.spawn(function()
                            pcall(opts.Callback, newValue)
                        end)
                    end
                    
                    if opts.Flag then
                        Window.ConfigElements[opts.Flag] = newValue
                    end
                end
                
                local dragging = false
                
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                function Slider:SetValue(val)
                    Slider.Value = math.clamp(val, Slider.Min, Slider.Max)
                    local p = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    valueLabel.Text = tostring(Slider.Value) .. (opts.Suffix or "")
                end
                
                if opts.Flag then
                    Window.ConfigElements[opts.Flag] = Slider.Value
                    Slider.Flag = opts.Flag
                end
                
                table.insert(Window.Elements, Slider)
                return Slider
            end
            
            -- Add Button
            function Section:AddButton(opts)
                opts = opts or {}
                
                local btn = Utility.Create("TextButton", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = opts.Title or "Button",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                btn.MouseButton1Click:Connect(function()
                    if opts.Callback then
                        task.spawn(function()
                            pcall(opts.Callback)
                        end)
                    end
                end)
                
                return {Button = btn}
            end
            
            -- Add Label
            function Section:AddLabel(opts)
                Utility.Create("TextLabel", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Code,
                    Text = opts.Text or "Label",
                    TextColor3 = theme.TextSecondary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            -- Add Paragraph
            function Section:AddParagraph(opts)
                local para = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y
                }, {
                    Utility.Create("UIListLayout", {Padding = UDim.new(0, 5)}),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        Font = Enum.Font.GothamBold,
                        Text = opts.Title or "Paragraph",
                        TextColor3 = theme.Primary,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Font = Enum.Font.Gotham,
                        Text = opts.Content or "",
                        TextColor3 = theme.TextSecondary,
                        TextSize = 11,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top
                    })
                })
            end
            
            -- Add Dropdown
            function Section:AddDropdown(opts)
                opts = opts or {}
                local Dropdown = {
                    Value = opts.Default or (opts.Multi and {} or (opts.Items[1] or "")),
                    Items = opts.Items or {},
                    Multi = opts.Multi or false
                }
                
                local dropFrame = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 55),
                    ClipsDescendants = false,
                    ZIndex = 10
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                Utility.Create("TextLabel", {
                    Parent = dropFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = opts.Title or "Dropdown",
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10
                })
                
                local displayText = Dropdown.Multi and (#Dropdown.Value == 0 and "Select..." or table.concat(Dropdown.Value, ", ")) or Dropdown.Value
                
                local dropBtn = Utility.Create("TextButton", {
                    Parent = dropFrame,
                    BackgroundColor3 = theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 25),
                    Size = UDim2.new(1, -20, 0, 22),
                    Font = Enum.Font.Code,
                    Text = "  " .. displayText,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                })
                
                local optionsFrame = Utility.Create("Frame", {
                    Parent = dropFrame,
                    BackgroundColor3 = theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 49),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Utility.Create("ScrollingFrame", {
                        Name = "Scroll",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        ScrollBarThickness = 3,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ZIndex = 100
                    }, {
                        Utility.Create("UIListLayout", {Padding = UDim.new(0, 2)}),
                        Utility.Create("UIPadding", {
                            PaddingTop = UDim.new(0, 4),
                            PaddingBottom = UDim.new(0, 4),
                            PaddingLeft = UDim.new(0, 4),
                            PaddingRight = UDim.new(0, 4)
                        })
                    })
                })
                
                local scroll = optionsFrame.Scroll
                
                local function updateDisplay()
                    if Dropdown.Multi then
                        dropBtn.Text = "  " .. (#Dropdown.Value == 0 and "Select..." or table.concat(Dropdown.Value, ", "))
                    else
                        dropBtn.Text = "  " .. (Dropdown.Value or "")
                    end
                end
                
                local function createOptions()
                    for _, child in ipairs(scroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, item in ipairs(Dropdown.Items) do
                        local isSelected = Dropdown.Multi and table.find(Dropdown.Value, item) or Dropdown.Value == item
                        
                        local opt = Utility.Create("TextButton", {
                            Parent = scroll,
                            BackgroundColor3 = isSelected and theme.Primary or theme.BackgroundTertiary,
                            BackgroundTransparency = isSelected and 0.3 or 0.5,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 24),
                            Font = Enum.Font.Code,
                            Text = (isSelected and "✓ " or "  ") .. item,
                            TextColor3 = isSelected and theme.Primary or theme.Text,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 100
                        }, {
                            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                        })
                        
                        opt.MouseButton1Click:Connect(function()
                            if Dropdown.Multi then
                                local idx = table.find(Dropdown.Value, item)
                                if idx then
                                    table.remove(Dropdown.Value, idx)
                                else
                                    table.insert(Dropdown.Value, item)
                                end
                                createOptions()
                                updateDisplay()
                            else
                                Dropdown.Value = item
                                updateDisplay()
                                optionsFrame.Visible = false
                                Utility.Tween(optionsFrame, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
                            end
                            
                            if opts.Callback then
                                task.spawn(function()
                                    pcall(opts.Callback, Dropdown.Value)
                                end)
                            end
                            
                            if opts.Flag then
                                Window.ConfigElements[opts.Flag] = Dropdown.Value
                            end
                        end)
                    end
                end
                
                createOptions()
                
                dropBtn.MouseButton1Click:Connect(function()
                    optionsFrame.Visible = not optionsFrame.Visible
                    if optionsFrame.Visible then
                        Utility.Tween(optionsFrame, {Size = UDim2.new(1, -20, 0, math.min(#Dropdown.Items * 28, 150))}, 0.2)
                    else
                        Utility.Tween(optionsFrame, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
                    end
                end)
                
                function Dropdown:SetValue(val)
                    Dropdown.Value = val
                    updateDisplay()
                    createOptions()
                end
                
                if opts.Flag then
                    Window.ConfigElements[opts.Flag] = Dropdown.Value
                    Dropdown.Flag = opts.Flag
                end
                
                table.insert(Window.Elements, Dropdown)
                return Dropdown
            end
            
            -- Add Input
            function Section:AddInput(opts)
                opts = opts or {}
                local Input = {Value = opts.Default or ""}
                
                local inputFrame = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 55)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                Utility.Create("TextLabel", {
                    Parent = inputFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = opts.Title or "Input",
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local textBox = Utility.Create("TextBox", {
                    Parent = inputFrame,
                    BackgroundColor3 = theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 25),
                    Size = UDim2.new(1, -20, 0, 22),
                    Font = Enum.Font.Code,
                    PlaceholderText = opts.Placeholder or "Enter text...",
                    Text = Input.Value,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    ClearTextOnFocus = false
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Utility.Create("UIPadding", {PaddingLeft = UDim.new(0, 8)})
                })
                
                textBox.FocusLost:Connect(function()
                    Input.Value = textBox.Text
                    
                    if opts.Callback then
                        task.spawn(function()
                            pcall(opts.Callback, Input.Value)
                        end)
                    end
                    
                    if opts.Flag then
                        Window.ConfigElements[opts.Flag] = Input.Value
                    end
                end)
                
                function Input:SetValue(val)
                    Input.Value = val
                    textBox.Text = val
                end
                
                if opts.Flag then
                    Window.ConfigElements[opts.Flag] = Input.Value
                    Input.Flag = opts.Flag
                end
                
                table.insert(Window.Elements, Input)
                return Input
            end
            
            -- Add Keybind
            function Section:AddKeybind(opts)
                opts = opts or {}
                local Keybind = {
                    Value = opts.Default or Enum.KeyCode.Unknown,
                    Listening = false
                }
                
                local keybindFrame = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = opts.Title or "Keybind",
                        TextColor3 = theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Utility.Create("TextButton", {
                        Name = "Btn",
                        BackgroundColor3 = theme.Background,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -80, 0.5, 0),
                        Size = UDim2.new(0, 70, 0, 24),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Font = Enum.Font.Code,
                        Text = Keybind.Value.Name,
                        TextColor3 = theme.Primary,
                        TextSize = 11
                    }, {
                        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                    })
                })
                
                local btn = keybindFrame.Btn
                
                btn.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    btn.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if Keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        Keybind.Value = input.KeyCode
                        btn.Text = input.KeyCode.Name
                        Keybind.Listening = false
                        
                        if opts.Flag then
                            Window.ConfigElements[opts.Flag] = input.KeyCode.Name
                        end
                    elseif not processed and input.KeyCode == Keybind.Value and opts.Callback then
                        task.spawn(function()
                            pcall(opts.Callback, Keybind.Value)
                        end)
                    end
                end)
                
                function Keybind:SetValue(key)
                    Keybind.Value = key
                    btn.Text = key.Name
                end
                
                if opts.Flag then
                    Window.ConfigElements[opts.Flag] = Keybind.Value.Name
                    Keybind.Flag = opts.Flag
                end
                
                table.insert(Window.Elements, Keybind)
                return Keybind
            end
            
            -- Add ColorPicker
            function Section:AddColorPicker(opts)
                opts = opts or {}
                local ColorPicker = {Value = opts.Default or Color3.fromRGB(255, 255, 255)}
                
                local h, s, v = Utility.RGBToHSV(ColorPicker.Value)
                
                local colorFrame = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    ZIndex = 5
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -60, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = opts.Title or "Color",
                        TextColor3 = theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 5
                    }),
                    Utility.Create("TextButton", {
                        Name = "ColorBtn",
                        BackgroundColor3 = ColorPicker.Value,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -45, 0.5, 0),
                        Size = UDim2.new(0, 35, 0, 22),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Text = "",
                        ZIndex = 5
                    }, {
                        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 4)})
                    })
                })
                
                local colorBtn = colorFrame.ColorBtn
                
                local pickerPanel = Utility.Create("Frame", {
                    Parent = colorFrame,
                    BackgroundColor3 = theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                -- Simple color picker implementation
                local function updateColor(newH, newS, newV)
                    h, s, v = newH or h, newS or s, newV or v
                    ColorPicker.Value = Utility.HSVToRGB(h, s, v)
                    colorBtn.BackgroundColor3 = ColorPicker.Value
                    
                    if opts.Callback then
                        task.spawn(function()
                            pcall(opts.Callback, ColorPicker.Value)
                        end)
                    end
                    
                    if opts.Flag then
                        Window.ConfigElements[opts.Flag] = {
                            R = ColorPicker.Value.R,
                            G = ColorPicker.Value.G,
                            B = ColorPicker.Value.B
                        }
                    end
                end
                
                colorBtn.MouseButton1Click:Connect(function()
                    pickerPanel.Visible = not pickerPanel.Visible
                    if pickerPanel.Visible then
                        Utility.Tween(pickerPanel, {Size = UDim2.new(1, 0, 0, 100)}, 0.2)
                    else
                        Utility.Tween(pickerPanel, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    end
                end)
                
                function ColorPicker:SetValue(color)
                    h, s, v = Utility.RGBToHSV(color)
                    updateColor(h, s, v)
                end
                
                if opts.Flag then
                    Window.ConfigElements[opts.Flag] = {
                        R = ColorPicker.Value.R,
                        G = ColorPicker.Value.G,
                        B = ColorPicker.Value.B
                    }
                    ColorPicker.Flag = opts.Flag
                end
                
                table.insert(Window.Elements, ColorPicker)
                return ColorPicker
            end
            
            return Section
        end
        
        table.insert(self.Tabs, Tab)
        return Tab
    end
    
    -- Config Methods
    function Window:SaveConfig(name)
        name = name or "default"
        local json = HttpService:JSONEncode(self.ConfigElements)
        WriteFile(self.ConfigFolder .. "/" .. name .. ".json", json)
        self:Notify({
            Title = "Config Saved",
            Content = "Configuration '" .. name .. "' saved successfully!",
            Type = "Success",
            Duration = 3
        })
    end
    
    function Window:LoadConfig(name)
        name = name or "default"
        local content = ReadFile(self.ConfigFolder .. "/" .. name .. ".json")
        if content then
            local config = HttpService:JSONDecode(content)
            for _, element in ipairs(self.Elements) do
                if element.Flag and config[element.Flag] then
                    if element.SetValue then
                        if element.Type == "ColorPicker" and type(config[element.Flag]) == "table" then
                            local c = config[element.Flag]
                            element:SetValue(Color3.new(c.R, c.G, c.B))
                        elseif element.Type == "Keybind" and type(config[element.Flag]) == "string" then
                            local key = Enum.KeyCode[config[element.Flag]]
                            if key then element:SetValue(key) end
                        else
                            element:SetValue(config[element.Flag])
                        end
                    end
                end
            end
            self:Notify({
                Title = "Config Loaded",
                Content = "Configuration '" .. name .. "' loaded!",
                Type = "Success",
                Duration = 3
            })
        else
            self:Notify({
                Title = "Load Failed",
                Content = "Configuration not found.",
                Type = "Error",
                Duration = 3
            })
        end
    end
    
    function Window:AddConfigManager()
        local ConfigTab = self:AddTab({Title = "Configs", Icon = "💾"})
        local MainSection = ConfigTab:AddSection({Title = "Configuration Manager", Icon = "📁"})
        
        local configName
        configName = MainSection:AddInput({
            Title = "Config Name",
            Placeholder = "Enter config name...",
            Default = "default"
        })
        
        local configList
        configList = MainSection:AddDropdown({
            Title = "Select Config",
            Items = ListFiles(self.ConfigFolder),
            Default = nil
        })
        
        MainSection:AddButton({
            Title = "💾 Save Config",
            Callback = function()
                local name = configName.Value
                if name and name ~= "" then
                    self:SaveConfig(name)
                    configList.Items = ListFiles(self.ConfigFolder)
                end
            end
        })
        
        MainSection:AddButton({
            Title = "📂 Load Config",
            Callback = function()
                local selected = configList.Value
                if selected and selected ~= "" then
                    self:LoadConfig(selected:gsub(".json", ""))
                end
            end
        })
    end
    
    return Window
end

return EnzoUI