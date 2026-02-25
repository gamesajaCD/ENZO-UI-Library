--[[
    ENZO UI - Cyberpunk Terminal Edition
    Version: 1.0.0
    GitHub: github.com/gamesajaCD/ENZO-UI-Library
]]

local EnzoUI = {}
EnzoUI.__index = EnzoUI
EnzoUI.Version = "1.0.0"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Utility = {}

function Utility.Tween(object, properties, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
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
        if child then child.Parent = instance end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

function Utility.MakeDraggable(frame, dragObject)
    dragObject = dragObject or frame
    local dragging, dragStart, startPos
    
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
    }
}

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
    local duration = options.Duration or 5
    local color = theme[options.Type] or theme.Info
    
    local notif = Utility.Create("Frame", {
        Parent = NotificationHolder,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 80),
        LayoutOrder = -tick()
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Utility.Create("Frame", {BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.new(0, 4, 1, 0)}),
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -50, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 32),
            Size = UDim2.new(1, -50, 0, 35),
            Font = Enum.Font.Gotham,
            Text = content,
            TextColor3 = theme.TextSecondary,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        }),
        Utility.Create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3)
        })
    })
    
    Utility.Tween(notif:FindFirstChild("Frame"), {Size = UDim2.new(0, 0, 0, 3)}, duration)
    task.delay(duration, function()
        if notif.Parent then
            Utility.Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.delay(0.3, function() notif:Destroy() end)
        end
    end)
end

function EnzoUI:CreateWindow(options)
    options = options or {}
    local Window = setmetatable({}, {__index = self})
    Window.Tabs = {}
    Window.Elements = {}
    
    local theme = Themes[options.Theme] or Themes.Aurora
    Window.Theme = theme
    
    local screenGui = Utility.Create("ScreenGui", {
        Name = "EnzoUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = CoreGui
    end
    
    CreateNotificationHolder(screenGui, theme)
    
    local main = Utility.Create("Frame", {
        Parent = screenGui,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = options.Size or UDim2.new(0, 600, 0, 400),
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, {
        Utility.Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    local header = Utility.Create("Frame", {
        Parent = main,
        BackgroundColor3 = theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45)
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
            Position = UDim2.new(0, 15, 0, 5),
            Size = UDim2.new(0.7, 0, 0, 35),
            Font = Enum.Font.GothamBold,
            Text = ">_ " .. (options.Title or "ENZO UI"),
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility.Create("TextButton", {
            Name = "Close",
            BackgroundColor3 = theme.Error,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -30, 0, 8),
            Size = UDim2.new(0, 22, 0, 22),
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16
        }, {
            Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
        })
    })
    
    Utility.MakeDraggable(main, header)
    header.Close.MouseButton1Click:Connect(function() screenGui:Destroy() end)
    
    local tabsContainer = Utility.Create("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(1, -20, 0, 30)
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 5)
        })
    })
    
    local contentArea = Utility.Create("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 90),
        Size = UDim2.new(1, -20, 1, -100)
    })
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            main.Visible = not main.Visible
        end
    end)
    
    function Window:Notify(opts)
        Notify(opts, self.Theme)
    end
    
    function Window:AddTab(tabOpts)
        local Tab = {Sections = {}}
        
        local tabBtn = Utility.Create("TextButton", {
            Parent = tabsContainer,
            BackgroundColor3 = (#self.Tabs == 0) and theme.Primary or theme.BackgroundTertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            Text = "  " .. (tabOpts.Icon or "📁") .. " " .. (tabOpts.Title or "Tab") .. "  ",
            TextColor3 = theme.Text,
            TextSize = 11
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
            Visible = (#self.Tabs == 0)
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
                    PaddingTop = UDim.new(0, 35),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                }),
                Utility.Create("UIListLayout", {Padding = UDim.new(0, 8)}),
                Utility.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 22),
                    Font = Enum.Font.GothamBold,
                    Text = (sectionOpts.Icon or "📌") .. " " .. (sectionOpts.Title or "Section"),
                    TextColor3 = theme.Primary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
            
            function Section:AddToggle(opts)
                opts = opts or {}
                local Toggle = {Value = opts.Default or false}
                
                local toggleFrame = Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32)
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -60, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = opts.Title or "Toggle",
                        TextColor3 = theme.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Utility.Create("TextButton", {
                        Name = "Btn",
                        BackgroundColor3 = Toggle.Value and theme.Primary or theme.Border,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -45, 0.5, 0),
                        Size = UDim2.new(0, 40, 0, 20),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Text = Toggle.Value and "ON" or "OFF",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.Code,
                        TextSize = 9
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
                        local success, err = pcall(opts.Callback, Toggle.Value)
                        if not success then warn("Toggle callback error:", err) end
                    end
                end)
                
                function Toggle:SetValue(val)
                    Toggle.Value = val
                    btn.BackgroundColor3 = val and theme.Primary or theme.Border
                    btn.Text = val and "ON" or "OFF"
                end
                
                return Toggle
            end
            
            function Section:AddButton(opts)
                opts = opts or {}
                local btn = Utility.Create("TextButton", {
                    Parent = sectionFrame,
                    BackgroundColor3 = theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.GothamBold,
                    Text = opts.Title or "Button",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11
                }, {
                    Utility.Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                
                btn.MouseButton1Click:Connect(function()
                    if opts.Callback then
                        local success, err = pcall(opts.Callback)
                        if not success then warn("Button callback error:", err) end
                    end
                end)
                
                return {Button = btn}
            end
            
            function Section:AddLabel(opts)
                Utility.Create("TextLabel", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Code,
                    Text = opts.Text or "Label",
                    TextColor3 = theme.TextSecondary,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            function Section:AddParagraph(opts)
                Utility.Create("Frame", {
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y
                }, {
                    Utility.Create("UIListLayout", {Padding = UDim.new(0, 4)}),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Font = Enum.Font.GothamBold,
                        Text = opts.Title or "Paragraph",
                        TextColor3 = theme.Primary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Font = Enum.Font.Gotham,
                        Text = opts.Content or "",
                        TextColor3 = theme.TextSecondary,
                        TextSize = 10,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top
                    })
                })
            end
            
            return Section
        end
        
        table.insert(self.Tabs, Tab)
        return Tab
    end
    
    return Window
end

return EnzoUI