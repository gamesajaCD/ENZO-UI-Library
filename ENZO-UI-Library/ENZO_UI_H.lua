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
    GitHub: https://github.com/gamesajaCD/ENZO-UI-Library
]]

local EnzoUI = {}
EnzoUI.__index = EnzoUI
EnzoUI.Version = "1.0.0"
EnzoUI.Windows = {}

-- Services
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

-- Device Detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Executor Protection
local function SafeProtect(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = CoreGui
    end
end

-- File System
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
    end
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

-- Themes
local Themes = {
    Aurora = {
        Name = "Aurora",
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
        Info = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(139, 92, 246),
        GlowTransparency = 0.7
    }
}

-- Utility Functions
local Utility = {}

function Utility.Tween(object, properties, duration)
    duration = duration or 0.2
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
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
        child.Parent = instance
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
    
    dragObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
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

-- Blur Effect
local BlurEffect = nil

local function SetBlur(enabled)
    if enabled then
        if not BlurEffect then
            BlurEffect = Instance.new("BlurEffect")
            BlurEffect.Size = 0
            BlurEffect.Parent = game:GetService("Lighting")
        end
        Utility.Tween(BlurEffect, {Size = 10}, 0.3)
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

-- Notification System
local NotificationHolder = nil

local function CreateNotificationHolder(screenGui, theme)
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
    if not NotificationHolder then return end
    
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local notifType = options.Type or "Info"
    local duration = options.Duration or 5
    
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
        Size = UDim2.new(1, 0, 0, 80),
        ClipsDescendants = true
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utility.Create("UIStroke", {
            Color = color,
            Thickness = 1,
            Transparency = 0.5
        }),
        Utility.Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0)
        }),
        Utility.Create("TextLabel", {
            Name = "Title",
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
            Name = "Content",
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
            Name = "ProgressBar",
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3)
        })
    })
    
    local closeBtn = notification.Close
    local progressBar = notification.ProgressBar
    
    closeBtn.MouseButton1Click:Connect(function()
        Utility.Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end)
    
    Utility.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        if notification.Parent then
            Utility.Tween(notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.delay(0.3, function()
                notification:Destroy()
            end)
        end
    end)
end

-- Watermark
local function CreateWatermark(screenGui, theme)
    local startTime = tick()
    
    local watermark = Utility.Create("Frame", {
        Name = "Watermark",
        Parent = screenGui,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 250, 0, 30),
        AnchorPoint = Vector2.new(1, 0)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utility.Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.Code,
            Text = "💫 FPS: 60 | 📡 Ping: 0ms | ⏱️ 00:00:00",
            TextColor3 = theme.Text,
            TextSize = 11
        })
    })
    
    Utility.MakeDraggable(watermark)
    
    RunService.Heartbeat:Connect(function()
        if watermark and watermark.Parent then
            local fps = math.floor(1 / RunService.Heartbeat:Wait())
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local elapsed = tick() - startTime
            local hours = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = math.floor(elapsed % 60)
            
            watermark.Text.Text = string.format("💫 FPS: %d | 📡 Ping: %dms | ⏱️ %02d:%02d:%02d", fps, ping, hours, mins, secs)
        end
    end)
    
    return watermark
end

-- Main CreateWindow Function
function EnzoUI:CreateWindow(options)
    options = options or {}
    
    local Window = {}
    Window.Tabs = {}
    Window.Elements = {}
    Window.ConfigElements = {}
    Window.Visible = true
    
    local title = options.Title or "ENZO UI"
    local theme = Themes[options.Theme or "Aurora"] or Themes.Aurora
    local size = options.Size or UDim2.new(0, 700, 0, 500)
    
    Window.Theme = theme
    Window.ConfigFolder = options.ConfigFolder or "EnzoUI"
    MakeFolder(Window.ConfigFolder)
    
    -- Create ScreenGui
    local screenGui = Utility.Create("ScreenGui", {
        Name = "EnzoUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    SafeProtect(screenGui)
    
    Window.ScreenGui = screenGui
    
    -- Create Notification Holder
    CreateNotificationHolder(screenGui, theme)
    
    -- Main Frame
    local mainFrame = Utility.Create("Frame", {
        Name = "MainWindow",
        Parent = screenGui,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    Window.MainFrame = mainFrame
    
    -- Header
    local header = Utility.Create("Frame", {
        Name = "Header",
        Parent = mainFrame,
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
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(0.7, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = ">_ " .. title,
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
    
    Utility.MakeDraggable(mainFrame, header)
    
    -- Close button
    header.Close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        SetBlur(false)
    end)
    
    -- Tab Container
    local tabContainer = Utility.Create("Frame", {
        Name = "TabContainer",
        Parent = mainFrame,
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
        Name = "ContentArea",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 105),
        Size = UDim2.new(1, -20, 1, -115)
    })
    
    Window.ContentArea = contentArea
    
    -- Watermark
    if options.Watermark ~= false then
        CreateWatermark(screenGui, theme)
    end
    
    -- Blur
    if options.Blur ~= false then
        SetBlur(true)
    end
    
    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            Window.Visible = not Window.Visible
            mainFrame.Visible = Window.Visible
        end
    end)
    
    -- Window Methods
    function Window:Notify(options)
        Notify(options, self.Theme)
    end
    
    function Window:AddTab(tabOptions)
        local Tab = {}
        Tab.Sections = {}
        Tab.Name = tabOptions.Title or "Tab"
        
        local tabButton = Utility.Create("TextButton", {
            Name = Tab.Name,
            Parent = tabContainer,
            BackgroundColor3 = #self.Tabs == 0 and theme.Primary or theme.BackgroundTertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = "  " .. (tabOptions.Icon or "📁") .. " " .. Tab.Name .. "  ",
            TextColor3 = theme.Text,
            TextSize = 12
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
        })
        
        local tabContent = Utility.Create("ScrollingFrame", {
            Name = Tab.Name,
            Parent = contentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Primary,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = #self.Tabs == 0
        }, {
            Utility.Create("UIListLayout", {
                Padding = UDim.new(0, 10)
            })
        })
        
        Tab.Content = tabContent
        
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in ipairs(self.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = theme.BackgroundTertiary
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = theme.Primary
        end)
        
        Tab.Button = tabButton
        
        function Tab:AddSection(sectionOptions)
            local Section = {}
            Section.Elements = {}
            
            local sectionFrame = Utility.Create("Frame", {
                Name = sectionOptions.Title or "Section",
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
                Utility.Create("UIListLayout", {
                    Padding = UDim.new(0, 8)
                }),
                Utility.Create("TextLabel", {
                    Name = "SectionTitle",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 25),
                    Font = Enum.Font.GothamBold,
                    Text = (sectionOptions.Icon or "📌") .. " " .. (sectionOptions.Title or "Section"),
                    TextColor3 = theme.Primary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
            
            Section.Frame = sectionFrame
            
            -- Add Toggle
            function Section:AddToggle(toggleOptions)
                local Toggle = {}
                Toggle.Value = toggleOptions.Default or false
                
                local toggleFrame = Utility.Create("Frame", {
                    Name = "Toggle",
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Utility.Create("TextLabel", {
                        Name = "Title",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -60, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = toggleOptions.Title or "Toggle",
                        TextColor3 = theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Utility.Create("TextButton", {
                        Name = "Button",
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
                
                local button = toggleFrame.Button
                
                button.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    button.BackgroundColor3 = Toggle.Value and theme.Primary or theme.Border
                    button.Text = Toggle.Value and "ON" or "OFF"
                    if toggleOptions.Callback then
                        toggleOptions.Callback(Toggle.Value)
                    end
                    if toggleOptions.Flag then
                        Window.ConfigElements[toggleOptions.Flag] = Toggle.Value
                    end
                end)
                
                function Toggle:SetValue(value)
                    Toggle.Value = value
                    button.BackgroundColor3 = value and theme.Primary or theme.Border
                    button.Text = value and "ON" or "OFF"
                end
                
                if toggleOptions.Flag then
                    Window.ConfigElements[toggleOptions.Flag] = Toggle.Value
                end
                
                table.insert(Window.Elements, Toggle)
                return Toggle
            end
            
            -- Add Button
            function Section:AddButton(buttonOptions)
                local Button = {}
                
                local buttonFrame = Utility.Create("TextButton", {
                    Name = "Button",
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = buttonOptions.Title or "Button",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                buttonFrame.MouseButton1Click:Connect(function()
                    if buttonOptions.Callback then
                        buttonOptions.Callback()
                    end
                end)
                
                return Button
            end
            
            -- Add Label
            function Section:AddLabel(labelOptions)
                Utility.Create("TextLabel", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Code,
                    Text = labelOptions.Text or "Label",
                    TextColor3 = theme.TextSecondary,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(self.Tabs, Tab)
        return Tab
    end
    
    -- Config System
    function Window:SaveConfig(name)
        name = name or "default"
        local json = HttpService:JSONEncode(self.ConfigElements)
        WriteFile(self.ConfigFolder .. "/" .. name .. ".json", json)
        self:Notify({
            Title = "Config Saved",
            Content = "Configuration saved as " .. name,
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
                if element.SetValue and element.Flag and config[element.Flag] then
                    element:SetValue(config[element.Flag])
                end
            end
            self:Notify({
                Title = "Config Loaded",
                Content = "Configuration loaded: " .. name,
                Type = "Success",
                Duration = 3
            })
        end
    end
    
    table.insert(EnzoUI.Windows, Window)
    return Window
end

return EnzoUI