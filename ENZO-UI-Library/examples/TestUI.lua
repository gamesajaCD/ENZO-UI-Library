--[[
    ENZO UI - Complete Test Script
    Tests all features of the library
]]

-- Load Library
local EnzoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gamesajaCD/ENZO-UI-Library/main/src/EnzoUI.lua"))()

-- Create Window
local Window = EnzoUI:CreateWindow({
    Title = "ENZO UI Test Hub",
    SubTitle = "Complete Feature Test",
    Size = UDim2.new(0, 700, 0, 500),
    Theme = "Aurora", -- Aurora, Sunset, Ocean, Forest, Sakura, Midnight
    ToggleKey = Enum.KeyCode.RightShift,
    Watermark = true,
    Blur = true,
    Version = "1.0.0",
    ConfigFolder = "EnzoUI_Test"
})

-- ═══════════════════════════════════════════════════════════════════
-- TAB 1: HOME
-- ═══════════════════════════════════════════════════════════════════

local HomeTab = Window:AddTab({
    Title = "Home",
    Icon = "🏠"
})

local WelcomeSection = HomeTab:AddSection({
    Title = "Welcome",
    Icon = "👋",
    Side = "Left"
})

WelcomeSection:AddParagraph({
    Title = "ENZO UI Library",
    Content = "Welcome to ENZO UI - A modern cyberpunk UI library.\n\nPress RightShift to toggle UI."
})

WelcomeSection:AddLabel({Text = "Version: 1.0.0"})
WelcomeSection:AddLabel({Text = "Theme: Aurora"})

local QuickSection = HomeTab:AddSection({
    Title = "Quick Actions",
    Icon = "⚡",
    Side = "Right"
})

QuickSection:AddToggle({
    Title = "Auto Farm",
    Description = "Automatically farm resources",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(value)
        print("Auto Farm:", value)
    end
})

QuickSection:AddButton({
    Title = "🚀 Execute All",
    Style = "Primary",
    Callback = function()
        Window:Notify({
            Title = "Executed",
            Content = "All features activated!",
            Type = "Success",
            Duration = 3
        })
    end
})

-- ═══════════════════════════════════════════════════════════════════
-- TAB 2: COMBAT
-- ═══════════════════════════════════════════════════════════════════

local CombatTab = Window:AddTab({
    Title = "Combat",
    Icon = "⚔️"
})

local AimbotSection = CombatTab:AddSection({
    Title = "Aimbot",
    Icon = "🎯",
    Side = "Left"
})

AimbotSection:AddToggle({
    Title = "Enable Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(value)
        print("Aimbot:", value)
    end
})

AimbotSection:AddSlider({
    Title = "FOV Size",
    Min = 50,
    Max = 500,
    Default = 180,
    Increment = 10,
    Suffix = "°",
    Flag = "FOV",
    Callback = function(value)
        print("FOV:", value)
    end
})

AimbotSection:AddDropdown({
    Title = "Target Part",
    Items = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Flag = "TargetPart",
    Callback = function(value)
        print("Target:", value)
    end
})

local CombatSettings = CombatTab:AddSection({
    Title = "Settings",
    Icon = "⚙️",
    Side = "Right"
})

CombatSettings:AddSlider({
    Title = "Damage Multiplier",
    Min = 1,
    Max = 10,
    Default = 1,
    Increment = 0.5,
    Suffix = "x",
    Flag = "Damage",
    Callback = function(value)
        print("Damage:", value)
    end
})

CombatSettings:AddColorPicker({
    Title = "Hit Effect Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "HitColor",
    Callback = function(color)
        print("Color:", color)
    end
})

-- ═══════════════════════════════════════════════════════════════════
-- TAB 3: MOVEMENT
-- ═══════════════════════════════════════════════════════════════════

local MovementTab = Window:AddTab({
    Title = "Movement",
    Icon = "🏃"
})

local SpeedSection = MovementTab:AddSection({
    Title = "Speed",
    Icon = "💨",
    Side = "Left"
})

SpeedSection:AddToggle({
    Title = "Speed Hack",
    Default = false,
    Flag = "Speed",
    Callback = function(value)
        print("Speed:", value)
    end
})

SpeedSection:AddSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Flag = "WalkSpeed",
    Callback = function(value)
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

SpeedSection:AddKeybind({
    Title = "Speed Toggle",
    Default = Enum.KeyCode.LeftShift,
    Flag = "SpeedKey",
    Callback = function(key)
        print("Speed Key:", key)
    end
})

-- ═══════════════════════════════════════════════════════════════════
-- TAB 4: MISC
-- ═══════════════════════════════════════════════════════════════════

local MiscTab = Window:AddTab({
    Title = "Misc",
    Icon = "⚙️"
})

local MiscSection = MiscTab:AddSection({
    Title = "Miscellaneous",
    Icon = "🔧",
    Side = "Left"
})

MiscSection:AddToggle({
    Title = "Anti AFK",
    Default = true,
    Flag = "AntiAFK"
})

MiscSection:AddInput({
    Title = "Player Name",
    Placeholder = "Enter name...",
    Default = "",
    Flag = "PlayerName",
    Callback = function(value)
        print("Player:", value)
    end
})

MiscSection:AddDropdown({
    Title = "Target Selection",
    Items = {"Closest", "Lowest HP", "Random"},
    Multi = true,
    Default = {"Closest"},
    Flag = "TargetMode",
    Callback = function(value)
        print("Mode:", value)
    end
})

local ActionsSection = MiscTab:AddSection({
    Title = "Actions",
    Icon = "⚡",
    Side = "Right"
})

ActionsSection:AddButton({
    Title = "Test Info",
    Style = "Primary",
    Callback = function()
        Window:Notify({
            Title = "Info",
            Content = "This is an info notification",
            Type = "Info",
            Duration = 4
        })
    end
})

ActionsSection:AddButton({
    Title = "Test Success",
    Style = "Success",
    Callback = function()
        Window:Notify({
            Title = "Success",
            Content = "Operation successful!",
            Type = "Success",
            Duration = 4
        })
    end
})

ActionsSection:AddButton({
    Title = "Test Warning",
    Style = "Secondary",
    Callback = function()
        Window:Notify({
            Title = "Warning",
            Content = "Be careful!",
            Type = "Warning",
            Duration = 4
        })
    end
})

ActionsSection:AddButton({
    Title = "Test Error",
    Style = "Danger",
    Callback = function()
        Window:Notify({
            Title = "Error",
            Content = "Something went wrong!",
            Type = "Error",
            Duration = 4
        })
    end
})

-- ═══════════════════════════════════════════════════════════════════
-- CONFIG MANAGER
-- ═══════════════════════════════════════════════════════════════════

Window:AddConfigManager()

-- ═══════════════════════════════════════════════════════════════════
-- INITIAL NOTIFICATION
-- ═══════════════════════════════════════════════════════════════════

Window:Notify({
    Title = "ENZO UI Loaded",
    Content = "Welcome! Press RightShift to toggle. All features ready.",
    Type = "Success",
    Duration = 5
})

print("ENZO UI Test - All Features Loaded!")