--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ENZO UI LIBRARY                           ║
    ║           Design G: Aurora Ethereal (Enhanced)               ║
    ║                   Version: 2.0.0                             ║
    ║                  Author: ENZO-YT                             ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  NEW FEATURES:                                               ║
    ║  ✅ Config System (Save/Load/Delete/Export/Import)           ║
    ║  ✅ Auto-load Config & Profiles                              ║
    ║  ✅ UI Scale (50% - 150%)                                    ║
    ║  ✅ Anti-Detection (Random naming)                           ║
    ║  ✅ Memory Optimization                                      ║
    ║  ✅ Error Handling (pcall protection)                        ║
    ║  ✅ Global Search                                            ║
    ║  ✅ Multi-Language (Semi-Auto)                               ║
    ║  ✅ Multiple Profiles                                        ║
    ║  ✅ Watermark                                                ║
    ║  ✅ Color Picker                                             ║
    ║  ✅ Session Timer                                            ║
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
local GUI_NAME = "UI_" .. UNIQUE_ID
local BLUR_NAME = "Blur_" .. UNIQUE_ID

-- ============================================
-- SERVICES (Cached for performance)
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
local Stats = Services.Stats
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- ERROR HANDLING WRAPPER
-- ============================================
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[ENZO UI] Error: " .. tostring(result))
    end
    return success, result
end

local function SafeWrap(func)
    return function(...)
        return SafeCall(func, ...)
    end
end

-- ============================================
-- MEMORY OPTIMIZATION: Object Pool
-- ============================================
local ObjectPool = {
    frames = {},
    labels = {},
    buttons = {}
}

local function GetPooledObject(class, pool)
    if #pool > 0 then
        return table.remove(pool)
    end
    return Instance.new(class)
end

local function ReturnToPool(obj, pool)
    obj.Parent = nil
    table.insert(pool, obj)
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
        if v.Name:find("Enzo") or v.Name:find("Blur_") then 
            v:Destroy() 
        end
    end
end)

SafeCall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("EnzoUI") or v.Name:find("UI_") then 
            v:Destroy() 
        end
    end
end)

-- ============================================
-- MULTI-LANGUAGE SYSTEM (Semi-Auto)
-- ============================================
local Languages = {
    EN = {
        Code = "EN",
        Name = "English",
        Strings = {
            -- General
            Settings = "Settings",
            Save = "Save",
            Load = "Load",
            Delete = "Delete",
            Export = "Export",
            Import = "Import",
            Cancel = "Cancel",
            Confirm = "Confirm",
            Close = "Close",
            Search = "Search...",
            
            -- Config
            ConfigName = "Config Name",
            ConfigSaved = "Config saved successfully!",
            ConfigLoaded = "Config loaded successfully!",
            ConfigDeleted = "Config deleted!",
            ConfigExported = "Config copied to clipboard!",
            ConfigImported = "Config imported successfully!",
            NoConfigs = "No configs found",
            SelectConfig = "Select Config",
            NewConfig = "New Config",
            DefaultConfig = "Default Config",
            AutoLoad = "Auto Load",
            
            -- Profile
            Profile = "Profile",
            Profiles = "Profiles",
            NewProfile = "New Profile",
            SelectProfile = "Select Profile",
            ProfileCreated = "Profile created!",
            ProfileDeleted = "Profile deleted!",
            
            -- UI
            UIScale = "UI Scale",
            Opacity = "Opacity",
            Theme = "Theme",
            Language = "Language",
            ToggleKey = "Toggle Key",
            
            -- Notifications
            Success = "Success",
            Error = "Error",
            Warning = "Warning",
            Info = "Info",
            
            -- Misc
            Enabled = "Enabled",
            Disabled = "Disabled",
            On = "ON",
            Off = "OFF",
            None = "None",
            All = "All",
            Reset = "Reset",
            Apply = "Apply",
        }
    },
    ID = {
        Code = "ID",
        Name = "Indonesia",
        Strings = {
            Settings = "Pengaturan",
            Save = "Simpan",
            Load = "Muat",
            Delete = "Hapus",
            Export = "Ekspor",
            Import = "Impor",
            Cancel = "Batal",
            Confirm = "Konfirmasi",
            Close = "Tutup",
            Search = "Cari...",
            
            ConfigName = "Nama Config",
            ConfigSaved = "Config berhasil disimpan!",
            ConfigLoaded = "Config berhasil dimuat!",
            ConfigDeleted = "Config dihapus!",
            ConfigExported = "Config disalin ke clipboard!",
            ConfigImported = "Config berhasil diimpor!",
            NoConfigs = "Tidak ada config",
            SelectConfig = "Pilih Config",
            NewConfig = "Config Baru",
            DefaultConfig = "Config Default",
            AutoLoad = "Muat Otomatis",
            
            Profile = "Profil",
            Profiles = "Profil",
            NewProfile = "Profil Baru",
            SelectProfile = "Pilih Profil",
            ProfileCreated = "Profil dibuat!",
            ProfileDeleted = "Profil dihapus!",
            
            UIScale = "Skala UI",
            Opacity = "Transparansi",
            Theme = "Tema",
            Language = "Bahasa",
            ToggleKey = "Tombol Toggle",
            
            Success = "Berhasil",
            Error = "Error",
            Warning = "Peringatan",
            Info = "Info",
            
            Enabled = "Aktif",
            Disabled = "Nonaktif",
            On = "YA",
            Off = "TIDAK",
            None = "Tidak Ada",
            All = "Semua",
            Reset = "Reset",
            Apply = "Terapkan",
        }
    },
    ES = {
        Code = "ES",
        Name = "Español",
        Strings = {
            Settings = "Ajustes",
            Save = "Guardar",
            Load = "Cargar",
            Delete = "Eliminar",
            Export = "Exportar",
            Import = "Importar",
            Cancel = "Cancelar",
            Confirm = "Confirmar",
            Close = "Cerrar",
            Search = "Buscar...",
            
            ConfigName = "Nombre Config",
            ConfigSaved = "¡Config guardado!",
            ConfigLoaded = "¡Config cargado!",
            ConfigDeleted = "¡Config eliminado!",
            ConfigExported = "¡Config copiado!",
            ConfigImported = "¡Config importado!",
            NoConfigs = "Sin configs",
            SelectConfig = "Seleccionar Config",
            NewConfig = "Nuevo Config",
            DefaultConfig = "Config Predeterminado",
            AutoLoad = "Carga Automática",
            
            Profile = "Perfil",
            Profiles = "Perfiles",
            NewProfile = "Nuevo Perfil",
            SelectProfile = "Seleccionar Perfil",
            ProfileCreated = "¡Perfil creado!",
            ProfileDeleted = "¡Perfil eliminado!",
            
            UIScale = "Escala UI",
            Opacity = "Opacidad",
            Theme = "Tema",
            Language = "Idioma",
            ToggleKey = "Tecla Toggle",
            
            Success = "Éxito",
            Error = "Error",
            Warning = "Advertencia",
            Info = "Info",
            
            Enabled = "Activado",
            Disabled = "Desactivado",
            On = "SÍ",
            Off = "NO",
            None = "Ninguno",
            All = "Todo",
            Reset = "Reiniciar",
            Apply = "Aplicar",
        }
    },
    JP = {
        Code = "JP",
        Name = "日本語",
        Strings = {
            Settings = "設定",
            Save = "保存",
            Load = "読込",
            Delete = "削除",
            Export = "出力",
            Import = "入力",
            Cancel = "キャンセル",
            Confirm = "確認",
            Close = "閉じる",
            Search = "検索...",
            
            ConfigName = "設定名",
            ConfigSaved = "設定を保存しました！",
            ConfigLoaded = "設定を読み込みました！",
            ConfigDeleted = "設定を削除しました！",
            ConfigExported = "クリップボードにコピーしました！",
            ConfigImported = "設定をインポートしました！",
            NoConfigs = "設定がありません",
            SelectConfig = "設定を選択",
            NewConfig = "新しい設定",
            DefaultConfig = "デフォルト設定",
            AutoLoad = "自動読込",
            
            Profile = "プロファイル",
            Profiles = "プロファイル",
            NewProfile = "新規プロファイル",
            SelectProfile = "プロファイル選択",
            ProfileCreated = "プロファイル作成！",
            ProfileDeleted = "プロファイル削除！",
            
            UIScale = "UIスケール",
            Opacity = "不透明度",
            Theme = "テーマ",
            Language = "言語",
            ToggleKey = "トグルキー",
            
            Success = "成功",
            Error = "エラー",
            Warning = "警告",
            Info = "情報",
            
            Enabled = "有効",
            Disabled = "無効",
            On = "オン",
            Off = "オフ",
            None = "なし",
            All = "全て",
            Reset = "リセット",
            Apply = "適用",
        }
    }
}

local CurrentLanguage = Languages.EN

local function GetString(key)
    return CurrentLanguage.Strings[key] or Languages.EN.Strings[key] or key
end

local function SetLanguage(langCode)
    if Languages[langCode] then
        CurrentLanguage = Languages[langCode]
        return true
    end
    return false
end

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
    self.AutoLoadConfig = nil
    self.Configs = {}
    self.Elements = {} -- Store all configurable elements
    
    -- Create folder
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

function ConfigSystem:GetConfigPath(name, profile)
    profile = profile or self.CurrentProfile
    return self.FolderName .. "/" .. profile .. "_" .. name .. ".json"
end

function ConfigSystem:GetProfilePath()
    return self.FolderName .. "/profiles.json"
end

function ConfigSystem:GetSettingsPath()
    return self.FolderName .. "/settings.json"
end

function ConfigSystem:Save(name)
    local data = {}
    
    for id, info in pairs(self.Elements) do
        data[id] = info.Value
    end
    
    local jsonData = HttpService:JSONEncode(data)
    
    local success = SafeCall(function()
        if writefile then
            writefile(self:GetConfigPath(name), jsonData)
        end
    end)
    
    return success, success and GetString("ConfigSaved") or GetString("Error")
end

function ConfigSystem:Load(name)
    local success, result = SafeCall(function()
        if readfile and isfile and isfile(self:GetConfigPath(name)) then
            local jsonData = readfile(self:GetConfigPath(name))
            local data = HttpService:JSONDecode(jsonData)
            
            for id, value in pairs(data) do
                if self.Elements[id] then
                    self.Elements[id].Value = value
                    local element = self.Elements[id].Element
                    if element and element.SetValue then
                        element:SetValue(value)
                    end
                end
            end
            
            return true
        end
        return false
    end)
    
    return success and result, success and GetString("ConfigLoaded") or GetString("Error")
end

function ConfigSystem:Delete(name)
    local success = SafeCall(function()
        if delfile and isfile and isfile(self:GetConfigPath(name)) then
            delfile(self:GetConfigPath(name))
        end
    end)
    
    return success, success and GetString("ConfigDeleted") or GetString("Error")
end

function ConfigSystem:Export(name)
    local success, result = SafeCall(function()
        if readfile and isfile and isfile(self:GetConfigPath(name)) then
            local jsonData = readfile(self:GetConfigPath(name))
            if setclipboard then
                setclipboard(jsonData)
                return true
            end
        end
        return false
    end)
    
    return success and result, success and GetString("ConfigExported") or GetString("Error")
end

function ConfigSystem:Import(jsonString)
    local success = SafeCall(function()
        local data = HttpService:JSONDecode(jsonString)
        
        for id, value in pairs(data) do
            if self.Elements[id] then
                self.Elements[id].Value = value
                local element = self.Elements[id].Element
                if element and element.SetValue then
                    element:SetValue(value)
                end
            end
        end
    end)
    
    return success, success and GetString("ConfigImported") or GetString("Error")
end

function ConfigSystem:GetConfigs()
    local configs = {}
    
    SafeCall(function()
        if listfiles then
            local files = listfiles(self.FolderName)
            for _, file in ipairs(files) do
                local name = file:match("([^/\\]+)%.json$")
                if name and name:find(self.CurrentProfile .. "_") then
                    local configName = name:gsub(self.CurrentProfile .. "_", "")
                    if configName ~= "profiles" and configName ~= "settings" then
                        table.insert(configs, configName)
                    end
                end
            end
        end
    end)
    
    return configs
end

function ConfigSystem:SetAutoLoad(name)
    self.AutoLoadConfig = name
    
    SafeCall(function()
        if writefile then
            local settings = {
                AutoLoad = name,
                Profile = self.CurrentProfile
            }
            writefile(self:GetSettingsPath(), HttpService:JSONEncode(settings))
        end
    end)
end

function ConfigSystem:LoadAutoConfig()
    SafeCall(function()
        if readfile and isfile and isfile(self:GetSettingsPath()) then
            local settings = HttpService:JSONDecode(readfile(self:GetSettingsPath()))
            if settings.AutoLoad then
                self.AutoLoadConfig = settings.AutoLoad
                self.CurrentProfile = settings.Profile or "Default"
                self:Load(settings.AutoLoad)
            end
        end
    end)
end

-- Profile Management
function ConfigSystem:CreateProfile(name)
    local success = SafeCall(function()
        local profiles = self:GetProfiles()
        if not table.find(profiles, name) then
            table.insert(profiles, name)
            if writefile then
                writefile(self:GetProfilePath(), HttpService:JSONEncode(profiles))
            end
        end
    end)
    
    return success, success and GetString("ProfileCreated") or GetString("Error")
end

function ConfigSystem:DeleteProfile(name)
    if name == "Default" then return false, "Cannot delete Default profile" end
    
    local success = SafeCall(function()
        local profiles = self:GetProfiles()
        local idx = table.find(profiles, name)
        if idx then
            table.remove(profiles, idx)
            if writefile then
                writefile(self:GetProfilePath(), HttpService:JSONEncode(profiles))
            end
        end
        
        -- Delete all configs in this profile
        if listfiles then
            local files = listfiles(self.FolderName)
            for _, file in ipairs(files) do
                if file:find(name .. "_") then
                    delfile(file)
                end
            end
        end
    end)
    
    return success, success and GetString("ProfileDeleted") or GetString("Error")
end

function ConfigSystem:GetProfiles()
    local profiles = {"Default"}
    
    SafeCall(function()
        if readfile and isfile and isfile(self:GetProfilePath()) then
            profiles = HttpService:JSONDecode(readfile(self:GetProfilePath()))
        end
    end)
    
    return profiles
end

function ConfigSystem:SetProfile(name)
    self.CurrentProfile = name
end

-- ============================================
-- MAIN LIBRARY - CREATE WINDOW
-- ============================================
function EnzoLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ENZO UI"
    local subtitle = config.SubTitle or "Aurora Ethereal"
    local logoImage = config.Logo or nil
    local baseSize = config.Size or UDim2.new(0, 750, 0, 480)
    local configFolder = config.ConfigFolder or "EnzoUI_" .. (config.GameId or game.PlaceId)
    
    if config.Theme and Themes[config.Theme] then
        CurrentTheme = Themes[config.Theme]
    end
    
    if config.Language and Languages[config.Language] then
        CurrentLanguage = Languages[config.Language]
    end
    
    -- Initialize Config System
    local ConfigSys = ConfigSystem.new(configFolder)
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
        Theme = CurrentTheme,
        Language = CurrentLanguage,
        ThemeObjects = {},
        LanguageObjects = {},
        Connections = {},
        Threads = {},
        ConfigSystem = ConfigSys,
        Scale = config.Scale or 1,
        StartTime = os.time(),
        SearchableElements = {},
    }
    
    -- Current scale
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
    
    -- UI Scale
    local UIScale = Create("UIScale", {
        Scale = currentScale,
        Parent = ScreenGui
    })
    
    -- Blur Effect
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
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 0, 0, 28),
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
    
    -- Update Watermark
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
                
                WatermarkText.Text = string.format("%s | FPS: %d | Ping: %dms | %s", title, fps, ping, timeStr)
            end)
            task.wait(0.5)
        end
    end))
    
    -- ============================================
    -- MAIN FRAME
    -- ============================================
    local Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Colors.Background,
        Position = UDim2.new(0.5, -baseSize.X.Offset/2, 0.5, -baseSize.Y.Offset/2),
        Size = baseSize,
        Parent = ScreenGui
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
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = BorderFrame
    })
    AddCorner(BorderGradient, 18)
    local auroraGradient = AddGradient(BorderGradient, {CurrentTheme.Primary, CurrentTheme.Secondary, CurrentTheme.Tertiary, CurrentTheme.Primary}, 0)
    table.insert(Window.ThemeObjects, {Type = "AuroraGradient", Gradient = auroraGradient})
    
    -- Animate aurora gradient
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
    
    -- Inner mask
    local InnerMask = Create("Frame", {
        BackgroundColor3 = Colors.Background,
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
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 70),
        ZIndex = 10,
        Parent = Main
    })
    AddCorner(Header, 16)
    
    -- Fix bottom corners
    Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 9,
        Parent = Header
    })
    
    -- Logo Container
    local LogoContainer = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 15, 0.5, -22),
        Size = UDim2.new(0, 44, 0, 44),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(LogoContainer, 12)
    AddGradient(LogoContainer, {CurrentTheme.Primary, CurrentTheme.Secondary}, 135)
    AddGlow(LogoContainer, CurrentTheme.Primary, 12, 0.6)
    table.insert(Window.ThemeObjects, {Object = LogoContainer, Property = "BackgroundColor3", Key = "Primary"})
    
    -- Logo
    if logoImage then
        Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.7, 0, 0.7, 0),
            Position = UDim2.new(0.15, 0, 0.15, 0),
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
            TextSize = 22,
            Parent = LogoContainer
        })
    end
    
    -- Title
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 12),
        Size = UDim2.new(0, 150, 0, 24),
        ZIndex = 11,
        Font = Enum.Font.GothamBlack,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 38),
        Size = UDim2.new(0, 150, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- ============================================
    -- GLOBAL SEARCH BAR
    -- ============================================
    local SearchContainer = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 230, 0.5, -14),
        Size = UDim2.new(0, 180, 0, 28),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(SearchContainer, 8)
    
    local SearchIcon = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        ZIndex = 12,
        Font = Enum.Font.GothamBold,
        Text = "🔍",
        TextSize = 12,
        Parent = SearchContainer
    })
    
    local SearchBox = Create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        ZIndex = 12,
        Font = Enum.Font.GothamMedium,
        Text = "",
        PlaceholderText = GetString("Search"),
        PlaceholderColor3 = Colors.TextDark,
        TextColor3 = Colors.Text,
        TextSize = 11,
        ClearTextOnFocus = false,
        Parent = SearchContainer
    })
    table.insert(Window.LanguageObjects, {Object = SearchBox, Property = "PlaceholderText", Key = "Search"})
    
    -- Search Results Dropdown
    local SearchResults = Create("Frame", {
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 50, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100,
        Parent = SearchContainer
    })
    AddCorner(SearchResults, 8)
    AddStroke(SearchResults, CurrentTheme.Primary, 1, 0.5)
    
    local SearchResultsList = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 101,
        Parent = SearchResults
    })
    AddPadding(SearchResultsList, 5)
    Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = SearchResultsList})
    
    -- Search Logic
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        
        -- Clear old results
        for _, child in pairs(SearchResultsList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        if query == "" then
            SearchResults.Visible = false
            Tween(SearchResults, {Size = UDim2.new(1, 50, 0, 0)}, 0.2)
            return
        end
        
        local results = {}
        for id, info in pairs(Window.SearchableElements) do
            if info.Title:lower():find(query, 1, true) then
                table.insert(results, info)
            end
        end
        
        if #results > 0 then
            SearchResults.Visible = true
            local height = math.min(#results * 30 + 10, 150)
            Tween(SearchResults, {Size = UDim2.new(1, 50, 0, height)}, 0.2)
            
            for _, info in ipairs(results) do
                local btn = Create("TextButton", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, -10, 0, 26),
                    ZIndex = 102,
                    Font = Enum.Font.GothamMedium,
                    Text = "  " .. info.Title,
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = SearchResultsList
                })
                AddCorner(btn, 4)
                
                btn.MouseEnter:Connect(function()
                    Tween(btn, {BackgroundTransparency = 0.3, TextColor3 = Colors.Text}, 0.1)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundTransparency = 0.5, TextColor3 = Colors.TextSecondary}, 0.1)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    -- Navigate to element's tab
                    if info.Tab then
                        Window:SelectTab(info.Tab)
                    end
                    SearchBox.Text = ""
                    SearchResults.Visible = false
                end)
            end
        else
            SearchResults.Visible = false
        end
    end)
    
    SearchBox.FocusLost:Connect(function()
        task.delay(0.2, function()
            SearchResults.Visible = false
        end)
    end)
    
    -- ============================================
    -- TAB CONTAINER
    -- ============================================
    local TabContainer = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 420, 0.5, -17),
        Size = UDim2.new(0, 220, 0, 34),
        ZIndex = 11,
        Parent = Header
    })
    AddCorner(TabContainer, 17)
    
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
    AddPadding(TabList, 4, 4, 6, 6)
    
    -- Tab Indicator
    local TabIndicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, 6, 0.5, -13),
        Size = UDim2.new(0, 60, 0, 26),
        ZIndex = 11,
        Parent = TabContainer
    })
    AddCorner(TabIndicator, 13)
    AddGradient(TabIndicator, {CurrentTheme.Primary, CurrentTheme.Secondary}, 90)
    AddGlow(TabIndicator, CurrentTheme.Primary, 8, 0.7)
    table.insert(Window.ThemeObjects, {Object = TabIndicator, Property = "BackgroundColor3", Key = "Primary"})
    
    -- Window Controls
    local Controls = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0.5, -15),
        Size = UDim2.new(0, 85, 0, 30),
        ZIndex = 11,
        Parent = Header
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = Controls
    })
    
    local function CreateControlBtn(icon, color, callback)
        local btn = Create("TextButton", {
            BackgroundColor3 = color,
            BackgroundTransparency = 0.85,
            Size = UDim2.new(0, 26, 0, 26),
            ZIndex = 12,
            Font = Enum.Font.GothamBold,
            Text = icon,
            TextColor3 = color,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = Controls
        })
        AddCorner(btn, 8)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.5, Size = UDim2.new(0, 28, 0, 28)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.85, Size = UDim2.new(0, 26, 0, 26)}, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    CreateControlBtn("−", Colors.Warning, function() Window:Toggle() end)
    CreateControlBtn("□", Colors.Info, function() end)
    CreateControlBtn("×", Colors.Error, function() Window:Destroy() end)
    
    MakeDraggable(Main, Header)
    
    -- ============================================
    -- CONTENT CONTAINER
    -- ============================================
    local ContentContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 80),
        Size = UDim2.new(1, -30, 1, -140),
        ZIndex = 3,
        Parent = Main
    })
    
    -- ============================================
    -- FOOTER
    -- ============================================
    local Footer = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundDark,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 15, 1, -52),
        Size = UDim2.new(1, -30, 0, 42),
        ZIndex = 10,
        Parent = Main
    })
    AddCorner(Footer, 12)
    
    -- Theme Selector
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, -8),
        Size = UDim2.new(0, 40, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = GetString("Theme"),
        TextColor3 = Colors.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local ThemeContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 55, 0.5, -9),
        Size = UDim2.new(0, 115, 0, 18),
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
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 12,
            Text = "",
            AutoButtonColor = false,
            Parent = ThemeContainer
        })
        AddCorner(themeBtn, 8)
        AddGradient(themeBtn, {theme.Primary, theme.Secondary}, 135)
        
        if name == CurrentTheme.Name then
            AddStroke(themeBtn, Colors.Text, 2, 0)
        end
        
        themeBtn.MouseEnter:Connect(function()
            Tween(themeBtn, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
        end)
        themeBtn.MouseLeave:Connect(function()
            Tween(themeBtn, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
        end)
        
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
    
    -- UI Scale Slider
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0.5, -8),
        Size = UDim2.new(0, 35, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "Scale",
        TextColor3 = Colors.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local ScaleTrack = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 218, 0.5, -5),
        Size = UDim2.new(0, 60, 0, 10),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(ScaleTrack, 5)
    
    local ScaleFill = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(0.5, 0, 1, 0),
        ZIndex = 12,
        Parent = ScaleTrack
    })
    AddCorner(ScaleFill, 5)
    AddGradient(ScaleFill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 0)
    
    local ScaleKnob = Create("Frame", {
        BackgroundColor3 = Colors.Text,
        Position = UDim2.new(0.5, -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        ZIndex = 13,
        Parent = ScaleTrack
    })
    AddCorner(ScaleKnob, 6)
    
    local ScaleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 282, 0.5, -8),
        Size = UDim2.new(0, 30, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamBold,
        Text = "100%",
        TextColor3 = CurrentTheme.Primary,
        TextSize = 9,
        Parent = Footer
    })
    
    -- Scale slider logic
    local scaleDragging = false
    
    local function UpdateScale(input)
        local pos = math.clamp((input.Position.X - ScaleTrack.AbsolutePosition.X) / ScaleTrack.AbsoluteSize.X, 0, 1)
        local scale = 0.5 + pos -- 50% to 150%
        currentScale = scale
        UIScale.Scale = scale
        ScaleFill.Size = UDim2.new(pos, 0, 1, 0)
        ScaleKnob.Position = UDim2.new(pos, -6, 0.5, -6)
        ScaleLabel.Text = math.floor(scale * 100) .. "%"
    end
    
    ScaleTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaleDragging = true
            UpdateScale(input)
        end
    end)
    
    ScaleTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scaleDragging = false
        end
    end)
    
    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if scaleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateScale(input)
        end
    end))
    
    -- Opacity Slider
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 320, 0.5, -8),
        Size = UDim2.new(0, 45, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = GetString("Opacity"),
        TextColor3 = Colors.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    
    local OpacityTrack = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 368, 0.5, -5),
        Size = UDim2.new(0, 60, 0, 10),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(OpacityTrack, 5)
    
    local OpacityFill = Create("Frame", {
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12,
        Parent = OpacityTrack
    })
    AddCorner(OpacityFill, 5)
    AddGradient(OpacityFill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 0)
    
    local OpacityKnob = Create("Frame", {
        BackgroundColor3 = Colors.Text,
        Position = UDim2.new(1, -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        ZIndex = 13,
        Parent = OpacityTrack
    })
    AddCorner(OpacityKnob, 6)
    
    local OpacityLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 432, 0.5, -8),
        Size = UDim2.new(0, 30, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamBold,
        Text = "100%",
        TextColor3 = CurrentTheme.Primary,
        TextSize = 9,
        Parent = Footer
    })
    
    -- Opacity slider logic
    local opacityDragging = false
    
    local function UpdateOpacity(input)
        local pos = math.clamp((input.Position.X - OpacityTrack.AbsolutePosition.X) / OpacityTrack.AbsoluteSize.X, 0, 1)
        currentOpacity = pos
        OpacityFill.Size = UDim2.new(pos, 0, 1, 0)
        OpacityKnob.Position = UDim2.new(pos, -6, 0.5, -6)
        OpacityLabel.Text = math.floor(pos * 100) .. "%"
        Main.BackgroundTransparency = 1 - (pos * 0.95)
    end
    
    OpacityTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = true
            UpdateOpacity(input)
        end
    end)
    
    OpacityTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            opacityDragging = false
        end
    end)
    
    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if opacityDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateOpacity(input)
        end
    end))
    
    -- Language Selector
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 475, 0.5, -8),
        Size = UDim2.new(0, 30, 0, 16),
        ZIndex = 11,
        Font = Enum.Font.GothamMedium,
        Text = "🌐",
        TextSize = 14,
        Parent = Footer
    })
    
    local LangBtn = Create("TextButton", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(0, 500, 0.5, -10),
        Size = UDim2.new(0, 35, 0, 20),
        ZIndex = 11,
        Font = Enum.Font.GothamBold,
        Text = CurrentLanguage.Code,
        TextColor3 = CurrentTheme.Primary,
        TextSize = 10,
        AutoButtonColor = false,
        Parent = Footer
    })
    AddCorner(LangBtn, 6)
    
    -- Language dropdown
    local LangDropdown = Create("Frame", {
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0, 0, 0, -85),
        Size = UDim2.new(0, 80, 0, 80),
        Visible = false,
        ZIndex = 100,
        Parent = LangBtn
    })
    AddCorner(LangDropdown, 8)
    AddStroke(LangDropdown, CurrentTheme.Primary, 1, 0.5)
    
    Create("UIListLayout", {Padding = UDim.new(0, 2), Parent = LangDropdown})
    AddPadding(LangDropdown, 4)
    
    for code, lang in pairs(Languages) do
        local langOption = Create("TextButton", {
            BackgroundColor3 = Colors.BackgroundLight,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, -8, 0, 18),
            ZIndex = 101,
            Font = Enum.Font.GothamMedium,
            Text = lang.Name,
            TextColor3 = Colors.TextSecondary,
            TextSize = 9,
            AutoButtonColor = false,
            Parent = LangDropdown
        })
        AddCorner(langOption, 4)
        
        langOption.MouseButton1Click:Connect(function()
            Window:SetLanguage(code)
            LangBtn.Text = code
            LangDropdown.Visible = false
        end)
    end
    
    LangBtn.MouseButton1Click:Connect(function()
        LangDropdown.Visible = not LangDropdown.Visible
    end)
    
    -- Toggle Key Badge
    local ToggleBadge = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        Position = UDim2.new(1, -95, 0.5, -12),
        Size = UDim2.new(0, 80, 0, 24),
        ZIndex = 11,
        Parent = Footer
    })
    AddCorner(ToggleBadge, 8)
    
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
            Main.Size = UDim2.new(0, baseSize.X.Offset, 0, 0)
            Main.BackgroundTransparency = 1
            
            Tween(Main, {Size = baseSize, BackgroundTransparency = 1 - (currentOpacity * 0.95)}, 0.5, Enum.EasingStyle.Back)
            Tween(Blur, {Size = 12}, 0.3)
        else
            Tween(Main, {Size = UDim2.new(0, baseSize.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            
            task.delay(0.3, function()
                if not self.Visible then Main.Visible = false end
            end)
        end
    end
    
    function Window:Destroy()
        -- Cleanup connections
        for _, connection in pairs(self.Connections) do
            SafeCall(function() connection:Disconnect() end)
        end
        
        -- Cleanup threads
        for _, thread in pairs(self.Threads) do
            SafeCall(function() task.cancel(thread) end)
        end
        
        -- Animate and destroy
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4)
        Tween(Blur, {Size = 0}, 0.3)
        Tween(Watermark, {BackgroundTransparency = 1}, 0.3)
        
        task.delay(0.4, function()
            SafeCall(function() ScreenGui:Destroy() end)
            SafeCall(function() Blur:Destroy() end)
        end)
        
        if getgenv then
            getgenv().EnzoUILib = nil
        end
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
    
    function Window:SetLanguage(langCode)
        if SetLanguage(langCode) then
            Window.Language = CurrentLanguage
            
            -- Update all language objects
            for _, obj in pairs(Window.LanguageObjects) do
                SafeCall(function()
                    if obj.Object and obj.Property and obj.Key then
                        obj.Object[obj.Property] = GetString(obj.Key)
                    end
                end)
            end
        end
    end
    
    function Window:SetScale(scale)
        currentScale = math.clamp(scale, 0.5, 1.5)
        UIScale.Scale = currentScale
        
        local pos = (currentScale - 0.5) / 1
        ScaleFill.Size = UDim2.new(pos, 0, 1, 0)
        ScaleKnob.Position = UDim2.new(pos, -6, 0.5, -6)
        ScaleLabel.Text = math.floor(currentScale * 100) .. "%"
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Content.Visible = false
            Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
            Tween(Window.CurrentTab.TextLabel, {TextColor3 = Colors.TextMuted}, 0.2)
        end
        
        Window.CurrentTab = tab
        tab.Content.Visible = true
        
        -- Animate indicator
        local btnPos = tab.Button.AbsolutePosition
        local containerPos = TabContainer.AbsolutePosition
        local relativeX = btnPos.X - containerPos.X
        
        Tween(TabIndicator, {
            Position = UDim2.new(0, relativeX, 0.5, -13),
            Size = UDim2.new(0, tab.Button.AbsoluteSize.X, 0, 26)
        }, 0.3, Enum.EasingStyle.Back)
        
        Tween(tab.TextLabel, {TextColor3 = Colors.Text}, 0.2)
    end
    
    function Window:ShowWatermark(show)
        Watermark.Visible = show
    end
    
    -- ============================================
    -- ADD TAB METHOD
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
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 26),
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
        
        -- Tab Badge (notification dot)
        local TabBadge = Create("Frame", {
            BackgroundColor3 = Colors.Error,
            Position = UDim2.new(1, -8, 0, 2),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 15,
            Visible = false,
            Parent = TabButton
        })
        AddCorner(TabBadge, 6)
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Primary,
            ScrollBarImageTransparency = 0.5,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 4,
            Parent = ContentContainer
        })
        AddPadding(TabContent, 5)
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 15),
            Parent = TabContent
        })
        
        Tab.Button = TabButton
        Tab.TextLabel = TabText
        Tab.Content = TabContent
        Tab.BadgeFrame = TabBadge
        
        function Tab:SetBadge(count)
            Tab.Badge = count
            if count > 0 then
                TabBadge.Visible = true
                Tween(TabBadge, {Size = UDim2.new(0, 12, 0, 12)}, 0.2, Enum.EasingStyle.Back)
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
            task.defer(function()
                Window:SelectTab(Tab)
            end)
        end
        
        -- ============================================
        -- ADD SECTION METHOD
        -- ============================================
        function Tab:AddSection(config)
            config = config or {}
            local sectionName = config.Title or "Section"
            local sectionSide = config.Side or "Left"
            local sectionIcon = config.Icon or "⚡"
            
            local Section = {
                Name = sectionName,
                Elements = {}
            }
            
            -- Get or Create Column
            local colName = sectionSide .. "Column"
            local column = TabContent:FindFirstChild(colName)
            
            if not column then
                column = Create("Frame", {
                    Name = colName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.48, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = sectionSide == "Left" and 1 or 2,
                    Parent = TabContent
                })
                Create("UIListLayout", {Padding = UDim.new(0, 12), Parent = column})
            end
            
            -- Section Card
            local SectionCard = Create("Frame", {
                BackgroundColor3 = Colors.Card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            AddCorner(SectionCard, 14)
            AddStroke(SectionCard, Colors.CardBorder, 1, 0.5)
            AddShadow(SectionCard, Color3.fromRGB(0,0,0), 15, 0.3)
            
            -- Section Header
            local SectionHeader = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Parent = SectionCard
            })
            
            local IconBG = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                Position = UDim2.new(0, 12, 0.5, -14),
                Size = UDim2.new(0, 28, 0, 28),
                Parent = SectionHeader
            })
            AddCorner(IconBG, 8)
            AddGradient(IconBG, {CurrentTheme.Primary, CurrentTheme.Secondary}, 135)
            table.insert(Window.ThemeObjects, {Object = IconBG, Property = "BackgroundColor3", Key = "Primary"})
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionIcon,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Parent = IconBG
            })
            
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 48, 0, 0),
                Size = UDim2.new(1, -56, 1, 0),
                Font = Enum.Font.GothamBlack,
                Text = sectionName:upper(),
                TextColor3 = Colors.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            local Divider = Create("Frame", {
                BackgroundColor3 = CurrentTheme.Primary,
                Position = UDim2.new(0, 12, 0, 42),
                Size = UDim2.new(1, -24, 0, 2),
                Parent = SectionCard
            })
            AddCorner(Divider, 1)
            AddGradient(Divider, {CurrentTheme.Primary, CurrentTheme.Secondary, Colors.Card}, 0)
            table.insert(Window.ThemeObjects, {Object = Divider, Property = "BackgroundColor3", Key = "Primary"})
            
            local SectionContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 48),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionCard
            })
            AddPadding(SectionContent, 5, 12, 12, 12)
            Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = SectionContent})
            
            Section.Card = SectionCard
            Section.Content = SectionContent
            table.insert(Tab.Sections, Section)
            
            -- ============================================
            -- TOGGLE
            -- ============================================
            function Section:AddToggle(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Toggle"))
                local Toggle = {Value = cfg.Default or false, Id = id}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 48 or 38),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, cfg.Description and 6 or 0),
                    Size = UDim2.new(1, -65, 0, cfg.Description and 16 or 38),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Toggle",
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 22),
                        Size = UDim2.new(1, -65, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Switch = Create("Frame", {
                    BackgroundColor3 = Toggle.Value and CurrentTheme.Primary or Colors.BackgroundDark,
                    Position = UDim2.new(1, -52, 0.5, -10),
                    Size = UDim2.new(0, 42, 0, 20),
                    Parent = Frame
                })
                AddCorner(Switch, 10)
                
                local Knob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = Toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 2,
                    Parent = Switch
                })
                AddCorner(Knob, 8)
                
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
                        Tween(Knob, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2, Enum.EasingStyle.Back)
                    else
                        Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.2)
                        Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back)
                    end
                    
                    -- Update config system
                    if ConfigSys.Elements[id] then
                        ConfigSys.Elements[id].Value = Toggle.Value
                    end
                    
                    if cfg.Callback then cfg.Callback(Toggle.Value) end
                end)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Toggle:SetValue(v)
                    if Toggle.Value ~= v then
                        Toggle.Value = v
                        if v then
                            Tween(Switch, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                            Tween(Knob, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                        else
                            Tween(Switch, {BackgroundColor3 = Colors.BackgroundDark}, 0.2)
                            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                        end
                    end
                end
                
                -- Register for config & search
                ConfigSys:RegisterElement(id, Toggle, cfg.Default or false)
                Window.SearchableElements[id] = {Title = cfg.Title or "Toggle", Tab = Tab, Element = Toggle}
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            -- ============================================
            -- SLIDER
            -- ============================================
            function Section:AddSlider(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Slider"))
                local min, max = cfg.Min or 0, cfg.Max or 100
                local Slider = {Value = cfg.Default or min, Id = id}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 55 or 45),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -60, 0, 14),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Slider",
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local ValueBadge = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -48, 0, 4),
                    Size = UDim2.new(0, 40, 0, 18),
                    Parent = Frame
                })
                AddCorner(ValueBadge, 5)
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBlack,
                    Text = tostring(Slider.Value) .. (cfg.Suffix or ""),
                    TextColor3 = CurrentTheme.Primary,
                    TextSize = 9,
                    Parent = ValueBadge
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 19),
                        Size = UDim2.new(1, -20, 0, 12),
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
                    Position = UDim2.new(0, 10, 1, -16),
                    Size = UDim2.new(1, -20, 0, 8),
                    Parent = Frame
                })
                AddCorner(Track, 4)
                
                local pct = (Slider.Value - min) / (max - min)
                
                local Fill = Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    Size = UDim2.new(pct, 0, 1, 0),
                    Parent = Track
                })
                AddCorner(Fill, 4)
                AddGradient(Fill, {CurrentTheme.Primary, CurrentTheme.Secondary}, 0)
                
                local SliderKnob = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(pct, -7, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 2,
                    Parent = Track
                })
                AddCorner(SliderKnob, 7)
                AddStroke(SliderKnob, CurrentTheme.Primary, 2, 0)
                
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    Slider.Value = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(val) .. (cfg.Suffix or "")
                    
                    if ConfigSys.Elements[id] then
                        ConfigSys.Elements[id].Value = val
                    end
                    
                    if cfg.Callback then cfg.Callback(val) end
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                    end
                end)
                
                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end))
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Slider:SetValue(v)
                    local pos = (v - min) / (max - min)
                    Slider.Value = v
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
                    ValueLabel.Text = tostring(v) .. (cfg.Suffix or "")
                end
                
                ConfigSys:RegisterElement(id, Slider, cfg.Default or min)
                Window.SearchableElements[id] = {Title = cfg.Title or "Slider", Tab = Tab, Element = Slider}
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            -- ============================================
            -- BUTTON
            -- ============================================
            function Section:AddButton(cfg)
                cfg = cfg or {}
                local styles = {
                    Primary = {CurrentTheme.Primary, CurrentTheme.Secondary},
                    Secondary = {Colors.BackgroundLight, Colors.CardHover},
                    Success = {Colors.Success, Color3.fromRGB(100, 255, 180)},
                    Danger = {Colors.Error, Color3.fromRGB(255, 120, 140)}
                }
                local style = styles[cfg.Style or "Primary"] or styles.Primary
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 58 or 40),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 6),
                        Size = UDim2.new(1, -20, 0, 13),
                        Font = Enum.Font.GothamBold,
                        Text = cfg.Title or "Button",
                        TextColor3 = Colors.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                    
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 19),
                        Size = UDim2.new(1, -20, 0, 11),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 8,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local Btn = Create("TextButton", {
                    BackgroundColor3 = style[1],
                    Position = cfg.Description and UDim2.new(0, 8, 1, -26) or UDim2.new(0, 8, 0.5, -13),
                    Size = UDim2.new(1, -16, 0, cfg.Description and 22 or 26),
                    Font = Enum.Font.GothamBlack,
                    Text = cfg.Description and "▶ " .. GetString("Apply"):upper() or (cfg.Title or "Button"),
                    TextColor3 = Colors.Text,
                    TextSize = 9,
                    AutoButtonColor = false,
                    Parent = Frame
                })
                AddCorner(Btn, 6)
                AddGradient(Btn, style, 90)
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -14, 0, cfg.Description and 24 or 28)}, 0.15)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -16, 0, cfg.Description and 22 or 26)}, 0.15)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {Size = UDim2.new(1, -20, 0, cfg.Description and 20 or 24)}, 0.08)
                    task.delay(0.08, function()
                        Tween(Btn, {Size = UDim2.new(1, -16, 0, cfg.Description and 22 or 26)}, 0.08)
                    end)
                    if cfg.Callback then cfg.Callback() end
                end)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                Window.SearchableElements[sectionName .. "_" .. (cfg.Title or "Button")] = {Title = cfg.Title or "Button", Tab = Tab}
                
                return {}
            end
            
            -- ============================================
            -- DROPDOWN
            -- ============================================
            function Section:AddDropdown(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Dropdown"))
                local items = cfg.Items or {}
                local multi = cfg.Multi or false
                local Dropdown = {
                    Value = multi and {} or cfg.Default,
                    Open = false,
                    Items = items,
                    Id = id
                }
                
                if multi and cfg.Default then
                    for _, v in pairs(cfg.Default) do Dropdown.Value[v] = true end
                end
                
                local baseH = cfg.Description and 62 or 50
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, baseH),
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 14),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Dropdown",
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 19),
                        Size = UDim2.new(1, -20, 0, 11),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 8,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local DropBtn = Create("TextButton", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(0, 8, 0, cfg.Description and 34 or 24),
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
                    Size = UDim2.new(1, -28, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = multi and GetString("None") or (cfg.Default or GetString("None")),
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropBtn
                })
                
                local Arrow = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -18, 0, 0),
                    Size = UDim2.new(0, 14, 1, 0),
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
                
                local SearchBox = Create("TextBox", {
                    BackgroundColor3 = Colors.BackgroundDark,
                    Position = UDim2.new(0, 4, 0, 4),
                    Size = UDim2.new(1, -8, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = "",
                    PlaceholderText = "🔍 " .. GetString("Search"),
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 9,
                    ClearTextOnFocus = false,
                    Parent = Content
                })
                AddCorner(SearchBox, 4)
                AddPadding(SearchBox, 0, 0, 6, 6)
                
                local ItemsList = Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 28),
                    Size = UDim2.new(1, 0, 1, -28),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = CurrentTheme.Primary,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Content
                })
                AddPadding(ItemsList, 3, 4, 4, 4)
                Create("UIListLayout", {Padding = UDim.new(0, 3), Parent = ItemsList})
                
                local itemBtns = {}
                
                local function createItem(name)
                    local isSel = multi and Dropdown.Value[name] or Dropdown.Value == name
                    
                    local ItemBtn = Create("TextButton", {
                        Name = name,
                        BackgroundColor3 = isSel and CurrentTheme.Primary or Colors.BackgroundLight,
                        BackgroundTransparency = isSel and 0.7 or 0.3,
                        Size = UDim2.new(1, -6, 0, 22),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = ItemsList
                    })
                    AddCorner(ItemBtn, 4)
                    
                    if multi then
                        local cb = Create("Frame", {
                            BackgroundColor3 = isSel and CurrentTheme.Accent or Colors.BackgroundDark,
                            Position = UDim2.new(0, 5, 0.5, -7),
                            Size = UDim2.new(0, 14, 0, 14),
                            Parent = ItemBtn
                        })
                        AddCorner(cb, 3)
                        
                        Create("TextLabel", {
                            Name = "Check",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.GothamBlack,
                            Text = isSel and "✓" or "",
                            TextColor3 = Colors.Text,
                            TextSize = 9,
                            Parent = cb
                        })
                    end
                    
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, multi and 24 or 8, 0, 0),
                        Size = UDim2.new(1, multi and -30 or -14, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = name,
                        TextColor3 = isSel and Colors.Text or Colors.TextSecondary,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ItemBtn
                    })
                    
                    ItemBtn.MouseEnter:Connect(function()
                        if not (multi and Dropdown.Value[name] or Dropdown.Value == name) then
                            Tween(ItemBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = CurrentTheme.Primary}, 0.1)
                        end
                    end)
                    
                    ItemBtn.MouseLeave:Connect(function()
                        local sel = multi and Dropdown.Value[name] or Dropdown.Value == name
                        Tween(ItemBtn, {
                            BackgroundTransparency = sel and 0.7 or 0.3,
                            BackgroundColor3 = sel and CurrentTheme.Primary or Colors.BackgroundLight
                        }, 0.1)
                    end)
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            Dropdown.Value[name] = not Dropdown.Value[name]
                            local nowSel = Dropdown.Value[name]
                            
                            local cb = ItemBtn:FindFirstChild("Frame")
                            if cb then
                                Tween(cb, {BackgroundColor3 = nowSel and CurrentTheme.Accent or Colors.BackgroundDark}, 0.15)
                                local check = cb:FindFirstChild("Check")
                                if check then check.Text = nowSel and "✓" or "" end
                            end
                            
                            Tween(ItemBtn, {
                                BackgroundColor3 = nowSel and CurrentTheme.Primary or Colors.BackgroundLight,
                                BackgroundTransparency = nowSel and 0.7 or 0.3
                            }, 0.15)
                            
                            local textLabel = ItemBtn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = nowSel and Colors.Text or Colors.TextSecondary
                            end
                            
                            local sel = {}
                            for k, v in pairs(Dropdown.Value) do
                                if v then table.insert(sel, k) end
                            end
                            BtnText.Text = #sel > 0 and table.concat(sel, ", ") or GetString("None")
                            BtnText.TextColor3 = #sel > 0 and Colors.Text or Colors.TextSecondary
                            
                            if ConfigSys.Elements[id] then
                                ConfigSys.Elements[id].Value = Dropdown.Value
                            end
                            
                            if cfg.Callback then cfg.Callback(Dropdown.Value) end
                        else
                            Dropdown.Value = name
                            BtnText.Text = name
                            BtnText.TextColor3 = Colors.Text
                            
                            for n, btn in pairs(itemBtns) do
                                local isThis = n == name
                                Tween(btn, {
                                    BackgroundColor3 = isThis and CurrentTheme.Primary or Colors.BackgroundLight,
                                    BackgroundTransparency = isThis and 0.7 or 0.3
                                }, 0.15)
                                local textLabel = btn:FindFirstChild("Text")
                                if textLabel then
                                    textLabel.TextColor3 = isThis and Colors.Text or Colors.TextSecondary
                                end
                            end
                            
                            if ConfigSys.Elements[id] then
                                ConfigSys.Elements[id].Value = name
                            end
                            
                            if cfg.Callback then cfg.Callback(name) end
                            
                            Dropdown.Open = false
                            Tween(Arrow, {Rotation = 0}, 0.2)
                            Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                            Tween(Content, {Size = UDim2.new(1, -16, 0, 0)}, 0.25)
                        end
                    end)
                    
                    return ItemBtn
                end
                
                for _, item in pairs(items) do
                    itemBtns[item] = createItem(item)
                end
                
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local s = SearchBox.Text:lower()
                    for name, btn in pairs(itemBtns) do
                        btn.Visible = s == "" or name:lower():find(s, 1, true) ~= nil
                    end
                end)
                
                DropBtn.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        Tween(Arrow, {Rotation = 180}, 0.2)
                        local cnt = math.min(#items, 5)
                        local contentH = 34 + (cnt * 25) + 8
                        local totalH = baseH + 6 + contentH
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, totalH)}, 0.3, Enum.EasingStyle.Back)
                        Tween(Content, {Size = UDim2.new(1, -16, 0, contentH)}, 0.3, Enum.EasingStyle.Back)
                    else
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(Frame, {Size = UDim2.new(1, 0, 0, baseH)}, 0.25)
                        Tween(Content, {Size = UDim2.new(1, -16, 0, 0)}, 0.25)
                    end
                end)
                
                Frame.MouseEnter:Connect(function()
                    if not Dropdown.Open then
                        Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                    end
                end)
                Frame.MouseLeave:Connect(function()
                    if not Dropdown.Open then
                        Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                    end
                end)
                
                function Dropdown:SetItems(newItems)
                    Dropdown.Items = newItems
                    for _, c in pairs(ItemsList:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    itemBtns = {}
                    for _, item in pairs(newItems) do
                        itemBtns[item] = createItem(item)
                    end
                end
                
                function Dropdown:SetValue(v)
                    if multi then
                        Dropdown.Value = v
                        for name, btn in pairs(itemBtns) do
                            local sel = v[name]
                            local cb = btn:FindFirstChild("Frame")
                            if cb then
                                cb.BackgroundColor3 = sel and CurrentTheme.Accent or Colors.BackgroundDark
                                local check = cb:FindFirstChild("Check")
                                if check then check.Text = sel and "✓" or "" end
                            end
                            btn.BackgroundColor3 = sel and CurrentTheme.Primary or Colors.BackgroundLight
                            btn.BackgroundTransparency = sel and 0.7 or 0.3
                            local textLabel = btn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = sel and Colors.Text or Colors.TextSecondary
                            end
                        end
                        local selected = {}
                        for k, val in pairs(v) do
                            if val then table.insert(selected, k) end
                        end
                        BtnText.Text = #selected > 0 and table.concat(selected, ", ") or GetString("None")
                    else
                        Dropdown.Value = v
                        BtnText.Text = v or GetString("None")
                        BtnText.TextColor3 = v and Colors.Text or Colors.TextSecondary
                        for name, btn in pairs(itemBtns) do
                            local isThis = name == v
                            btn.BackgroundColor3 = isThis and CurrentTheme.Primary or Colors.BackgroundLight
                            btn.BackgroundTransparency = isThis and 0.7 or 0.3
                            local textLabel = btn:FindFirstChild("Text")
                            if textLabel then
                                textLabel.TextColor3 = isThis and Colors.Text or Colors.TextSecondary
                            end
                        end
                    end
                end
                
                ConfigSys:RegisterElement(id, Dropdown, multi and {} or cfg.Default)
                Window.SearchableElements[id] = {Title = cfg.Title or "Dropdown", Tab = Tab, Element = Dropdown}
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            -- ============================================
            -- TEXTBOX
            -- ============================================
            function Section:AddTextbox(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Textbox"))
                local Textbox = {Value = cfg.Default or "", Id = id}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 58 or 45),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 14),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Input",
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 19),
                        Size = UDim2.new(1, -20, 0, 11),
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
                    Position = UDim2.new(0, 8, 0, cfg.Description and 34 or 24),
                    Size = UDim2.new(1, -16, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Default or "",
                    PlaceholderText = cfg.Placeholder or "...",
                    PlaceholderColor3 = Colors.TextDark,
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    ClearTextOnFocus = false,
                    Parent = Frame
                })
                AddCorner(InputBox, 5)
                AddStroke(InputBox, CurrentTheme.Primary, 1, 0.7)
                AddPadding(InputBox, 0, 0, 6, 6)
                
                InputBox.Focused:Connect(function()
                    local stroke = InputBox:FindFirstChildOfClass("UIStroke")
                    if stroke then Tween(stroke, {Transparency = 0.3}, 0.2) end
                end)
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    local stroke = InputBox:FindFirstChildOfClass("UIStroke")
                    if stroke then Tween(stroke, {Transparency = 0.7}, 0.2) end
                    Textbox.Value = InputBox.Text
                    
                    if ConfigSys.Elements[id] then
                        ConfigSys.Elements[id].Value = InputBox.Text
                    end
                    
                    if cfg.Callback then cfg.Callback(InputBox.Text, enterPressed) end
                end)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Textbox:SetValue(v)
                    Textbox.Value = v
                    InputBox.Text = v
                end
                
                ConfigSys:RegisterElement(id, Textbox, cfg.Default or "")
                Window.SearchableElements[id] = {Title = cfg.Title or "Textbox", Tab = Tab, Element = Textbox}
                
                table.insert(Section.Elements, Textbox)
                return Textbox
            end
            
            -- ============================================
            -- KEYBIND
            -- ============================================
            function Section:AddKeybind(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "Keybind"))
                local Keybind = {Value = cfg.Default or Enum.KeyCode.E, Id = id}
                local listening = false
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, cfg.Description and 45 or 36),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, cfg.Description and 5 or 0),
                    Size = UDim2.new(1, -80, 0, cfg.Description and 14 or 36),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Keybind",
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                if cfg.Description then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 19),
                        Size = UDim2.new(1, -80, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = cfg.Description,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 9,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Frame
                    })
                end
                
                local KeyBtn = Create("TextButton", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = 0.8,
                    Position = UDim2.new(1, -65, 0.5, -11),
                    Size = UDim2.new(0, 55, 0, 22),
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
                            
                            -- Update Window toggle key if this is used for that
                            if cfg.UpdateToggleKey then
                                Window.ToggleKey = input.KeyCode
                                ToggleBadgeText.Text = "🎮 " .. input.KeyCode.Name
                            end
                            
                            if ConfigSys.Elements[id] then
                                ConfigSys.Elements[id].Value = input.KeyCode.Name
                            end
                            
                            if cfg.Callback then cfg.Callback(input.KeyCode) end
                        end
                    elseif not processed and input.KeyCode == Keybind.Value then
                        if cfg.OnPress then cfg.OnPress() end
                    end
                end))
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function Keybind:SetValue(v)
                    if type(v) == "string" then
                        v = Enum.KeyCode[v] or Enum.KeyCode.E
                    end
                    Keybind.Value = v
                    KeyBtn.Text = v.Name
                end
                
                ConfigSys:RegisterElement(id, Keybind, cfg.Default and cfg.Default.Name or "E")
                Window.SearchableElements[id] = {Title = cfg.Title or "Keybind", Tab = Tab, Element = Keybind}
                
                table.insert(Section.Elements, Keybind)
                return Keybind
            end
            
            -- ============================================
            -- COLOR PICKER
            -- ============================================
            function Section:AddColorPicker(cfg)
                cfg = cfg or {}
                local id = cfg.Id or (sectionName .. "_" .. (cfg.Title or "ColorPicker"))
                local ColorPicker = {
                    Value = cfg.Default or Color3.fromRGB(255, 255, 255),
                    Id = id
                }
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 36),
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Color",
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local ColorPreview = Create("Frame", {
                    BackgroundColor3 = ColorPicker.Value,
                    Position = UDim2.new(1, -45, 0.5, -11),
                    Size = UDim2.new(0, 35, 0, 22),
                    Parent = Frame
                })
                AddCorner(ColorPreview, 6)
                AddStroke(ColorPreview, Colors.Text, 1, 0.5)
                
                local ColorPickerBtn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Frame
                })
                
                -- Color picker popup
                local PickerPopup = Create("Frame", {
                    BackgroundColor3 = Colors.Card,
                    Position = UDim2.new(1, 10, 0, 0),
                    Size = UDim2.new(0, 180, 0, 200),
                    Visible = false,
                    ZIndex = 100,
                    Parent = Frame
                })
                AddCorner(PickerPopup, 10)
                AddStroke(PickerPopup, CurrentTheme.Primary, 1, 0.5)
                AddShadow(PickerPopup, Color3.fromRGB(0,0,0), 10, 0.4)
                
                -- HSV Picker
                local HueSatPicker = Create("ImageButton", {
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -40, 0, 120),
                    ZIndex = 101,
                    Image = "rbxassetid://4155801252",
                    AutoButtonColor = false,
                    Parent = PickerPopup
                })
                AddCorner(HueSatPicker, 6)
                
                local HueSatCursor = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(1, -5, 0, -5),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 102,
                    Parent = HueSatPicker
                })
                AddCorner(HueSatCursor, 5)
                AddStroke(HueSatCursor, Colors.BackgroundDark, 2, 0)
                
                -- Hue Bar
                local HueBar = Create("ImageButton", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(1, -25, 0, 10),
                    Size = UDim2.new(0, 15, 0, 120),
                    ZIndex = 101,
                    Image = "rbxassetid://3641079629",
                    AutoButtonColor = false,
                    Parent = PickerPopup
                })
                AddCorner(HueBar, 4)
                
                local HueCursor = Create("Frame", {
                    BackgroundColor3 = Colors.Text,
                    Position = UDim2.new(0, -2, 0, 0),
                    Size = UDim2.new(1, 4, 0, 6),
                    ZIndex = 102,
                    Parent = HueBar
                })
                AddCorner(HueCursor, 3)
                
                -- RGB Inputs
                local RGBContainer = Create("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 138),
                    Size = UDim2.new(1, -20, 0, 25),
                    ZIndex = 101,
                    Parent = PickerPopup
                })
                
                Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 5),
                    Parent = RGBContainer
                })
                
                local function createRGBInput(label, defaultVal)
                    local container = Create("Frame", {
                        BackgroundColor3 = Colors.BackgroundDark,
                        Size = UDim2.new(0, 50, 1, 0),
                        ZIndex = 101,
                        Parent = RGBContainer
                    })
                    AddCorner(container, 4)
                    
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 4, 0, 0),
                        Size = UDim2.new(0, 12, 1, 0),
                        ZIndex = 102,
                        Font = Enum.Font.GothamBold,
                        Text = label,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 9,
                        Parent = container
                    })
                    
                    local input = Create("TextBox", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 16, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        ZIndex = 102,
                        Font = Enum.Font.GothamBold,
                        Text = tostring(defaultVal),
                        TextColor3 = Colors.Text,
                        TextSize = 10,
                        Parent = container
                    })
                    
                    return input
                end
                
                local currentColor = ColorPicker.Value
                local h, s, v = Color3.toHSV(currentColor)
                
                local rInput = createRGBInput("R", math.floor(currentColor.R * 255))
                local gInput = createRGBInput("G", math.floor(currentColor.G * 255))
                local bInput = createRGBInput("B", math.floor(currentColor.B * 255))
                
                local function updateColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    ColorPreview.BackgroundColor3 = currentColor
                    HueSatPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    HueSatCursor.Position = UDim2.new(s, -5, 1 - v, -5)
                    HueCursor.Position = UDim2.new(0, -2, h, -3)
                    
                    rInput.Text = tostring(math.floor(currentColor.R * 255))
                    gInput.Text = tostring(math.floor(currentColor.G * 255))
                    bInput.Text = tostring(math.floor(currentColor.B * 255))
                    
                    ColorPicker.Value = currentColor
                    
                    if ConfigSys.Elements[id] then
                        ConfigSys.Elements[id].Value = {R = currentColor.R, G = currentColor.G, B = currentColor.B}
                    end
                    
                    if cfg.Callback then cfg.Callback(currentColor) end
                end
                
                -- Apply Button
                local ApplyBtn = Create("TextButton", {
                    BackgroundColor3 = CurrentTheme.Primary,
                    Position = UDim2.new(0, 10, 1, -32),
                    Size = UDim2.new(1, -20, 0, 24),
                    ZIndex = 101,
                    Font = Enum.Font.GothamBold,
                    Text = GetString("Apply"),
                    TextColor3 = Colors.Text,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = PickerPopup
                })
                AddCorner(ApplyBtn, 6)
                AddGradient(ApplyBtn, {CurrentTheme.Primary, CurrentTheme.Secondary}, 90)
                
                ApplyBtn.MouseButton1Click:Connect(function()
                    PickerPopup.Visible = false
                end)
                
                -- Picker interactions
                local hueSatDragging = false
                local hueDragging = false
                
                HueSatPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueSatDragging = true
                    end
                end)
                
                HueSatPicker.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueSatDragging = false
                    end
                end)
                
                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                    end
                end)
                
                HueBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                    end
                end)
                
                table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if hueSatDragging then
                            local relX = math.clamp((input.Position.X - HueSatPicker.AbsolutePosition.X) / HueSatPicker.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((input.Position.Y - HueSatPicker.AbsolutePosition.Y) / HueSatPicker.AbsoluteSize.Y, 0, 1)
                            s = relX
                            v = 1 - relY
                            updateColor()
                        elseif hueDragging then
                            local relY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                            h = relY
                            updateColor()
                        end
                    end
                end))
                
                ColorPickerBtn.MouseButton1Click:Connect(function()
                    PickerPopup.Visible = not PickerPopup.Visible
                end)
                
                -- RGB Input handlers
                local function updateFromRGB()
                    local r = math.clamp(tonumber(rInput.Text) or 0, 0, 255)
                    local g = math.clamp(tonumber(gInput.Text) or 0, 0, 255)
                    local b = math.clamp(tonumber(bInput.Text) or 0, 0, 255)
                    currentColor = Color3.fromRGB(r, g, b)
                    h, s, v = Color3.toHSV(currentColor)
                    updateColor()
                end
                
                rInput.FocusLost:Connect(updateFromRGB)
                gInput.FocusLost:Connect(updateFromRGB)
                bInput.FocusLost:Connect(updateFromRGB)
                
                Frame.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.CardHover}, 0.15)
                end)
                Frame.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Colors.BackgroundLight}, 0.15)
                end)
                
                function ColorPicker:SetValue(v)
                    if type(v) == "table" then
                        currentColor = Color3.new(v.R or 1, v.G or 1, v.B or 1)
                    else
                        currentColor = v
                    end
                    h, s, val = Color3.toHSV(currentColor)
                    v = val
                    ColorPreview.BackgroundColor3 = currentColor
                    ColorPicker.Value = currentColor
                end
                
                ConfigSys:RegisterElement(id, ColorPicker, {R = ColorPicker.Value.R, G = ColorPicker.Value.G, B = ColorPicker.Value.B})
                Window.SearchableElements[id] = {Title = cfg.Title or "ColorPicker", Tab = Tab, Element = ColorPicker}
                
                table.insert(Section.Elements, ColorPicker)
                return ColorPicker
            end
            
            -- ============================================
            -- LABEL
            -- ============================================
            function Section:AddLabel(text)
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = Colors.TextMuted,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionContent
                })
                
                function Label:SetText(t)
                    LabelFrame.Text = t
                end
                
                table.insert(Section.Elements, Label)
                return Label
            end
            
            -- ============================================
            -- PARAGRAPH
            -- ============================================
            function Section:AddParagraph(cfg)
                cfg = cfg or {}
                
                local Frame = Create("Frame", {
                    BackgroundColor3 = Colors.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = SectionContent
                })
                AddCorner(Frame, 8)
                AddPadding(Frame, 8)
                
                Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = Frame})
                
                local TitleLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.GothamBold,
                    Text = cfg.Title or "Title",
                    TextColor3 = Colors.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })
                
                local ContentLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham,
                    Text = cfg.Content or "Content",
                    TextColor3 = Colors.TextSecondary,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = Frame
                })
                
                local Paragraph = {}
                
                function Paragraph:SetTitle(t)
                    TitleLabel.Text = t
                end
                
                function Paragraph:SetContent(c)
                    ContentLabel.Text = c
                end
                
                return Paragraph
            end
            
            -- ============================================
            -- DIVIDER
            -- ============================================
            function Section:AddDivider()
                local Divider = Create("Frame", {
                    BackgroundColor3 = Colors.CardBorder,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = SectionContent
                })
                AddCorner(Divider, 1)
                return Divider
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- ============================================
    -- NOTIFICATION SYSTEM
    -- ============================================
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
                Position = UDim2.new(1, -330, 0, 50),
                Size = UDim2.new(0, 310, 0, 0),
                ZIndex = 1000,
                Parent = ScreenGui
            })
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Parent = Container
            })
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
        AddShadow(Notif, data.col, 10, 0.5)
        
        -- Left accent
        local Accent = Create("Frame", {
            BackgroundColor3 = data.col,
            Size = UDim2.new(0, 4, 1, 0),
            ZIndex = 1002,
            Parent = Notif
        })
        AddCorner(Accent, 2)
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(0, 22, 0, 22),
            ZIndex = 1003,
            Font = Enum.Font.GothamBlack,
            Text = data.icon,
            TextSize = 16,
            Parent = Notif
        })
        
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0, 8),
            Size = UDim2.new(1, -60, 0, 16),
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
            Position = UDim2.new(0, 42, 0, 26),
            Size = UDim2.new(1, -60, 0, 0),
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
        
        -- Progress Bar
        local ProgressBG = Create("Frame", {
            BackgroundColor3 = Colors.BackgroundDark,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(1, 0, 0, 3),
            ZIndex = 1002,
            Parent = Notif
        })
        
        local Progress = Create("Frame", {
            BackgroundColor3 = data.col,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1003,
            Parent = ProgressBG
        })
        AddCorner(Progress, 2)
        
        local CloseBtn = Create("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -26, 0, 6),
            Size = UDim2.new(0, 18, 0, 18),
            ZIndex = 1004,
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Parent = Notif
        })
        
        local notifClosed = false
        
        local function closeNotif()
            if notifClosed then return end
            notifClosed = true
            Tween(Notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.delay(0.3, function() 
                SafeCall(function() Notif:Destroy() end) 
            end)
        end
        
        CloseBtn.MouseButton1Click:Connect(closeNotif)
        CloseBtn.MouseEnter:Connect(function()
            Tween(CloseBtn, {TextColor3 = Colors.Text}, 0.1)
        end)
        CloseBtn.MouseLeave:Connect(function()
            Tween(CloseBtn, {TextColor3 = Colors.TextMuted}, 0.1)
        end)
        
        table.insert(Window.Threads, task.spawn(function()
            task.wait(0.05)
            local height = 50 + ContentLabel.TextBounds.Y
            
            Notif.Position = UDim2.new(1, 20, 0, 0)
            Notif.Size = UDim2.new(1, 0, 0, height)
            
            Tween(Notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
            Tween(Progress, {Size = UDim2.new(0, 0, 1, 0)}, cfg.Duration or 4, Enum.EasingStyle.Linear)
            
            task.wait(cfg.Duration or 4)
            closeNotif()
        end))
    end
    
    -- ============================================
    -- MOBILE TOGGLE BUTTON (FIXED POSITION)
    -- ============================================
    local lastMobilePosition = UDim2.new(0, 15, 0.5, -25)
    local mobileHidden = false
    
    local MobileBtn = Create("TextButton", {
        Name = "MobileToggle",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = lastMobilePosition,
        Size = UDim2.new(0, 50, 0, 50),
        ZIndex = 999,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui
    })
    AddCorner(MobileBtn, 25)
    AddGradient(MobileBtn, {CurrentTheme.Primary, CurrentTheme.Secondary, CurrentTheme.Tertiary}, 135)
    AddShadow(MobileBtn, Color3.fromRGB(0, 0, 0), 10, 0.4)
    
    local MobileGlow = AddGlow(MobileBtn, CurrentTheme.Primary, 12, 0.6)
    table.insert(Window.ThemeObjects, {Object = MobileGlow, Property = "ImageColor3", Key = "Primary"})
    
    -- Mobile Logo
    local MobileLogo
    if logoImage then
        MobileLogo = Create("ImageLabel", {
            Name = "Logo",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 0.6, 0),
            Position = UDim2.new(0.2, 0, 0.2, 0),
            ZIndex = 1000,
            Image = logoImage,
            ImageColor3 = Colors.Text,
            ScaleType = Enum.ScaleType.Fit,
            Parent = MobileBtn
        })
    else
        MobileLogo = Create("TextLabel", {
            Name = "Logo",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 1000,
            Font = Enum.Font.GothamBlack,
            Text = "E",
            TextColor3 = Colors.Text,
            TextSize = 20,
            Parent = MobileBtn
        })
    end
    
    -- Mobile draggable (FIXED - Saves position)
    local mobileDrag = false
    local mobileStart, mobileStartPos
    
    MobileBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mobileDrag = true
            mobileStart = input.Position
            mobileStartPos = MobileBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mobileDrag = false
                    lastMobilePosition = MobileBtn.Position -- SAVE POSITION
                end
            end)
        end
    end)
    
    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if mobileDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mobileStart
            MobileBtn.Position = UDim2.new(
                mobileStartPos.X.Scale,
                mobileStartPos.X.Offset + delta.X,
                mobileStartPos.Y.Scale,
                mobileStartPos.Y.Offset + delta.Y
            )
        end
    end))
    
    MobileBtn.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)
    
    MobileBtn.MouseEnter:Connect(function()
        Tween(MobileBtn, {Size = UDim2.new(0, 55, 0, 55)}, 0.15)
        Tween(MobileGlow, {ImageTransparency = 0.4}, 0.15)
    end)
    MobileBtn.MouseLeave:Connect(function()
        Tween(MobileBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.15)
        Tween(MobileGlow, {ImageTransparency = 0.6}, 0.15)
    end)
    
    -- Override Toggle to handle mobile button visibility (NOT position)
    local originalToggle = Window.Toggle
    Window.Toggle = function(self)
        self.Visible = not self.Visible
        
        if self.Visible then
            Main.Visible = true
            Main.Size = UDim2.new(0, baseSize.X.Offset, 0, 0)
            Main.BackgroundTransparency = 1
            
            Tween(Main, {Size = baseSize, BackgroundTransparency = 1 - (currentOpacity * 0.95)}, 0.5, Enum.EasingStyle.Back)
            Tween(Blur, {Size = 12}, 0.3)
            
            -- Fade out mobile button (keep position)
            Tween(MobileBtn, {BackgroundTransparency = 1}, 0.3)
            if MobileLogo:IsA("TextLabel") then
                Tween(MobileLogo, {TextTransparency = 1}, 0.3)
            else
                Tween(MobileLogo, {ImageTransparency = 1}, 0.3)
            end
            Tween(MobileGlow, {ImageTransparency = 1}, 0.3)
            mobileHidden = true
        else
            Tween(Main, {Size = UDim2.new(0, baseSize.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(Blur, {Size = 0}, 0.3)
            
            -- Fade in mobile button (at saved position)
            Tween(MobileBtn, {BackgroundTransparency = 0}, 0.3)
            if MobileLogo:IsA("TextLabel") then
                Tween(MobileLogo, {TextTransparency = 0}, 0.3)
            else
                Tween(MobileLogo, {ImageTransparency = 0}, 0.3)
            end
            Tween(MobileGlow, {ImageTransparency = 0.6}, 0.3)
            mobileHidden = false
            
            task.delay(0.3, function()
                if not self.Visible then Main.Visible = false end
            end)
        end
    end
    
    -- ============================================
    -- BUILT-IN CONFIG SYSTEM UI
    -- ============================================
    function Window:AddConfigSection(tab, side)
        side = side or "Right"
        
        local ConfigSection = tab:AddSection({
            Title = GetString("Settings"),
            Side = side,
            Icon = "💾"
        })
        
        -- Profile Selector
        local profiles = ConfigSys:GetProfiles()
        local ProfileDropdown = ConfigSection:AddDropdown({
            Title = GetString("Profile"),
            Items = profiles,
            Default = ConfigSys.CurrentProfile,
            Callback = function(profile)
                ConfigSys:SetProfile(profile)
                -- Refresh config list
                local configs = ConfigSys:GetConfigs()
                if ConfigDropdown then
                    ConfigDropdown:SetItems(#configs > 0 and configs or {GetString("NoConfigs")})
                end
            end
        })
        
        -- New Profile
        ConfigSection:AddTextbox({
            Title = GetString("NewProfile"),
            Placeholder = "Profile name...",
            Callback = function(text, enter)
                if enter and text ~= "" then
                    local success, msg = ConfigSys:CreateProfile(text)
                    Window:Notify({
                        Title = success and GetString("Success") or GetString("Error"),
                        Content = msg,
                        Type = success and "Success" or "Error",
                        Duration = 3
                    })
                    if success then
                        ProfileDropdown:SetItems(ConfigSys:GetProfiles())
                    end
                end
            end
        })
        
        ConfigSection:AddDivider()
        
        -- Config List
        local configs = ConfigSys:GetConfigs()
        local ConfigDropdown = ConfigSection:AddDropdown({
            Title = GetString("SelectConfig"),
            Items = #configs > 0 and configs or {GetString("NoConfigs")},
            Callback = function(config)
                -- Selected config
            end
        })
        
        -- New Config Name
        local newConfigName = ""
        ConfigSection:AddTextbox({
            Title = GetString("NewConfig"),
            Placeholder = "Config name...",
            Callback = function(text)
                newConfigName = text
            end
        })
        
        -- Save Button
        ConfigSection:AddButton({
            Title = GetString("Save"),
            Style = "Success",
            Callback = function()
                if newConfigName == "" then
                    Window:Notify({
                        Title = GetString("Error"),
                        Content = "Please enter a config name",
                        Type = "Error",
                        Duration = 3
                    })
                    return
                end
                
                local success, msg = ConfigSys:Save(newConfigName)
                Window:Notify({
                    Title = success and GetString("Success") or GetString("Error"),
                    Content = msg,
                    Type = success and "Success" or "Error",
                    Duration = 3
                })
                
                if success then
                    local configs = ConfigSys:GetConfigs()
                    ConfigDropdown:SetItems(configs)
                end
            end
        })
        
        -- Load Button
        ConfigSection:AddButton({
            Title = GetString("Load"),
            Style = "Primary",
            Callback = function()
                local selected = ConfigDropdown.Value
                if not selected or selected == GetString("NoConfigs") then
                    Window:Notify({
                        Title = GetString("Error"),
                        Content = "Please select a config",
                        Type = "Error",
                        Duration = 3
                    })
                    return
                end
                
                local success, msg = ConfigSys:Load(selected)
                Window:Notify({
                    Title = success and GetString("Success") or GetString("Error"),
                    Content = msg,
                    Type = success and "Success" or "Error",
                    Duration = 3
                })
            end
        })
        
        -- Delete Button
        ConfigSection:AddButton({
            Title = GetString("Delete"),
            Style = "Danger",
            Callback = function()
                local selected = ConfigDropdown.Value
                if not selected or selected == GetString("NoConfigs") then
                    Window:Notify({
                        Title = GetString("Error"),
                        Content = "Please select a config",
                        Type = "Error",
                        Duration = 3
                    })
                    return
                end
                
                local success, msg = ConfigSys:Delete(selected)
                Window:Notify({
                    Title = success and GetString("Success") or GetString("Error"),
                    Content = msg,
                    Type = success and "Success" or "Error",
                    Duration = 3
                })
                
                if success then
                    local configs = ConfigSys:GetConfigs()
                    ConfigDropdown:SetItems(#configs > 0 and configs or {GetString("NoConfigs")})
                end
            end
        })
        
        ConfigSection:AddDivider()
        
        -- Export Button
        ConfigSection:AddButton({
            Title = GetString("Export"),
            Style = "Secondary",
            Callback = function()
                local selected = ConfigDropdown.Value
                if not selected or selected == GetString("NoConfigs") then
                    Window:Notify({
                        Title = GetString("Error"),
                        Content = "Please select a config",
                        Type = "Error",
                        Duration = 3
                    })
                    return
                end
                
                local success, msg = ConfigSys:Export(selected)
                Window:Notify({
                    Title = success and GetString("Success") or GetString("Error"),
                    Content = msg,
                    Type = success and "Success" or "Error",
                    Duration = 3
                })
            end
        })
        
        -- Import Textbox
        ConfigSection:AddTextbox({
            Title = GetString("Import"),
            Placeholder = "Paste JSON config...",
            Callback = function(text, enter)
                if enter and text ~= "" then
                    local success, msg = ConfigSys:Import(text)
                    Window:Notify({
                        Title = success and GetString("Success") or GetString("Error"),
                        Content = msg,
                        Type = success and "Success" or "Error",
                        Duration = 3
                    })
                end
            end
        })
        
        ConfigSection:AddDivider()
        
        -- Auto Load Toggle
        ConfigSection:AddToggle({
            Title = GetString("AutoLoad"),
            Description = "Load config on script start",
            Default = ConfigSys.AutoLoadConfig ~= nil,
            Callback = function(enabled)
                if enabled then
                    local selected = ConfigDropdown.Value
                    if selected and selected ~= GetString("NoConfigs") then
                        ConfigSys:SetAutoLoad(selected)
                        Window:Notify({
                            Title = GetString("Success"),
                            Content = "Auto-load set to: " .. selected,
                            Type = "Success",
                            Duration = 3
                        })
                    end
                else
                    ConfigSys:SetAutoLoad(nil)
                end
            end
        })
        
        return ConfigSection
    end
    
    -- ============================================
    -- BUILT-IN UI SETTINGS SECTION
    -- ============================================
    function Window:AddUISettingsSection(tab, side)
        side = side or "Left"
        
        local UISection = tab:AddSection({
            Title = "UI " .. GetString("Settings"),
            Side = side,
            Icon = "🎨"
        })
        
        -- Toggle Key
        UISection:AddKeybind({
            Title = GetString("ToggleKey"),
            Description = "Key to show/hide UI",
            Default = Window.ToggleKey,
            UpdateToggleKey = true,
            Callback = function(key)
                Window.ToggleKey = key
                Window:Notify({
                    Title = GetString("Success"),
                    Content = "Toggle key changed to: " .. key.Name,
                    Type = "Success",
                    Duration = 2
                })
            end
        })
        
        -- Theme Info
        UISection:AddParagraph({
            Title = "🎨 " .. GetString("Theme"),
            Content = "Change theme using the color dots in the footer bar. Available: Aurora, Sunset, Ocean, Forest, Sakura, Midnight"
        })
        
        -- Scale Info
        UISection:AddParagraph({
            Title = "📐 " .. GetString("UIScale"),
            Content = "Adjust UI scale (50% - 150%) using the Scale slider in the footer bar."
        })
        
        -- Opacity Info
        UISection:AddParagraph({
            Title = "👁️ " .. GetString("Opacity"),
            Content = "Adjust UI transparency using the Opacity slider in the footer bar."
        })
        
        -- Language Info
        UISection:AddParagraph({
            Title = "🌐 " .. GetString("Language"),
            Content = "Change language using the language button in the footer bar. Available: EN, ID, ES, JP"
        })
        
        UISection:AddDivider()
        
        -- Watermark Toggle
        UISection:AddToggle({
            Title = "Watermark",
            Description = "Show/hide FPS, Ping, Time display",
            Default = Watermark.Visible,
            Callback = function(enabled)
                Window:ShowWatermark(enabled)
            end
        })
        
        return UISection
    end
    
    -- ============================================
    -- AUTO LOAD CONFIG ON START
    -- ============================================
    task.spawn(function()
        task.wait(0.5)
        ConfigSys:LoadAutoConfig()
    end)
    
    -- ============================================
    -- MEMORY CLEANUP ON DESTROY
    -- ============================================
    local originalDestroy = Window.Destroy
    Window.Destroy = function(self)
        -- Clear search elements
        Window.SearchableElements = {}
        
        -- Clear config elements
        ConfigSys.Elements = {}
        
        -- Clear object pools
        ObjectPool.frames = {}
        ObjectPool.labels = {}
        ObjectPool.buttons = {}
        
        -- Call original destroy
        originalDestroy(self)
    end
    
    -- Store in global
    if getgenv then
        getgenv().EnzoUILib = Window
    end
    
    return Window
end

-- ============================================
-- LIBRARY INFO
-- ============================================
EnzoLib.Version = "2.0.0"
EnzoLib.Author = "ENZO-YT"
EnzoLib.Design = "G - Aurora Ethereal (Enhanced)"

EnzoLib.Themes = Themes
EnzoLib.Languages = Languages
EnzoLib.Colors = Colors

function EnzoLib:GetThemes()
    local themeNames = {}
    for name, _ in pairs(Themes) do
        table.insert(themeNames, name)
    end
    return themeNames
end

function EnzoLib:GetLanguages()
    local langNames = {}
    for code, lang in pairs(Languages) do
        table.insert(langNames, {Code = code, Name = lang.Name})
    end
    return langNames
end

-- ============================================
-- RETURN LIBRARY
-- ============================================
return EnzoLib