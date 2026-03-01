--[[
    ╔═══════════════════════════════════════════════╗
    ║       ENZO-YT AUTO FARM SCRIPT (CLEAN v5.0)   ║
    ║       Fluent UI + SaveManager + Interface     ║
    ╚═══════════════════════════════════════════════╝
]]

local RayfieldLoaded = pcall(function()
    Rayfield:Notify({})
end)
if not RayfieldLoaded then
    local Rayfield
    local success, errorMsg = pcall(function()
        Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    if not success then
        warn("Failed to load Rayfield for notification: " .. tostring(errorMsg))
    end
end

-- Check if key validation flag is set with unique run ID

-- ================================================================= --

-- ============================================
-- [[ 1. CLEANUP PREVIOUS SCRIPT ]]
-- ============================================
-- Ensure EnzoThreads exists before anything
if not getgenv().EnzoThreads then
    getgenv().EnzoThreads = {}
end

-- Step 1: Stop all loops immediately
if getgenv().EnzoScriptRunning ~= nil then
    getgenv().EnzoScriptRunning = false
end

pcall(function()
    if getgenv().EnzoScriptRunning then
        getgenv().EnzoScriptRunning = false
    end
    if getgenv().ToggleUIInstance then
        getgenv().ToggleUIInstance:Destroy()
        getgenv().ToggleUIInstance = nil
    end
    if getgenv().EnzoFluentWindow then
        getgenv().EnzoFluentWindow:Destroy()
        getgenv().EnzoFluentWindow = nil
    end
    if getgenv().EnzoConnections then
        for _, conn in pairs(getgenv().EnzoConnections) do
            pcall(function() conn:Disconnect() end)
        end
        getgenv().EnzoConnections = {}
    end
    if getgenv().EnzoCurrentTween then
        pcall(function() getgenv().EnzoCurrentTween:Cancel() end)
        getgenv().EnzoCurrentTween = nil
    end
    if getgenv().EnzoNoClipConn then
        pcall(function() getgenv().EnzoNoClipConn:Disconnect() end)
        getgenv().EnzoNoClipConn = nil
    end
end)

task.wait(0.5)

-- ============================================
-- [[ 2. SERVICES ]]
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")

-- ============================================
-- [[ 3. VARIABLES & STATE ]]
-- ============================================
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

getgenv().EnzoScriptRunning = true
getgenv().EnzoConnections = getgenv().EnzoConnections or {}
getgenv().EnzoCurrentTween = nil
getgenv().EnzoNoClipConn = nil
getgenv().EnzoThreads = getgenv().EnzoThreads or {}

local currentTargetModel = nil
local isMovingToTarget = false
local isFarmingTarget = false
local debugMode = false

local function GetKnitServices()
    return ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.5.1")
        :WaitForChild("knit")
        :WaitForChild("Services")
end

local function DebugPrint(...)
    if debugMode then
        print("[ENZO-YT DEBUG]", ...)
    end
end

-- ============================================
-- [[ 4. CHARACTER REFRESH ]]
-- ============================================
local charConn = LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    currentTargetModel = nil
    isMovingToTarget = false
    isFarmingTarget = false
end)
table.insert(getgenv().EnzoConnections, charConn)

-- ============================================
-- [[ 5. GET GAME NAME ]]
-- ============================================
local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId).Name
end)
local gameName = success and info or "ENZO-YT Script"

-- ============================================
-- [[ 6. LOAD LIBRARY ]]
-- ============================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = gameName .. "- v1.2",
    SubTitle = "by ENZO-YT",
    TabWidth = 100,
    Size = UDim2.fromOffset(410, 300),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

getgenv().EnzoFluentWindow = Window

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Star = Window:AddTab({ Title = "Star", Icon = "star" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- ============================================
-- [[ 7. UTILITY FUNCTIONS ]]
-- ============================================

-- ── Enemy Utils ──
local function GetEnemyList()
    local enemyNames = {}
    local seen = {}
    local mobsFolder = workspace:FindFirstChild("Mobs")
    if not mobsFolder then return enemyNames end
    
    for _, mob in pairs(mobsFolder:GetChildren()) do
        pcall(function()
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp then
                local eo = hrp:FindFirstChild("EnemyOverhead")
                if eo then
                    local el = eo:FindFirstChild("Enemy")
                    if el then
                        local name = el.ContentText or el.Text or mob.Name
                        if name and name ~= "" and not seen[name] then
                            seen[name] = true
                            table.insert(enemyNames, name)
                        end
                    end
                end
            end
        end)
    end
    table.sort(enemyNames)
    return enemyNames
end

local function GetEnemyName(mob)
    local name = nil
    pcall(function()
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp then
            local eo = hrp:FindFirstChild("EnemyOverhead")
            if eo then
                local el = eo:FindFirstChild("Enemy")
                if el then
                    name = el.ContentText or el.Text or mob.Name
                end
            end
        end
    end)
    return name
end

local function IsMobAlive(mob)
    if not mob or not mob.Parent then return false end
    local h = mob:FindFirstChildOfClass("Humanoid")
    if not h then return false end
    if h.Health <= 0 then return false end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp.Parent then return false end
    return true
end

local function GetNearestEnemy(selectedNames)
    if not selectedNames or #selectedNames == 0 then return nil, nil end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return nil, nil end
    
    local nearestMob, nearestHRP = nil, nil
    local nearestDist = math.huge
    local mobsFolder = workspace:FindFirstChild("Mobs")
    
    if not mobsFolder then return nil, nil end
    
    for _, mob in pairs(mobsFolder:GetChildren()) do
        if IsMobAlive(mob) then
            local name = GetEnemyName(mob)
            if name then
                for _, sel in pairs(selectedNames) do
                    if name == sel then
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (HumanoidRootPart.Position - hrp.Position).Magnitude
                            if d < nearestDist then
                                nearestMob = mob
                                nearestHRP = hrp
                                nearestDist = d
                            end
                        end
                        break
                    end
                end
            end
        end
    end
    return nearestMob, nearestHRP
end

-- ── Star Utils ──
local function GetStarList()
    local starNames = {}
    local seen = {}
    local starsFolder = workspace:FindFirstChild("Stars")
    if not starsFolder then return starNames end
    
    for _, star in pairs(starsFolder:GetChildren()) do
        pcall(function()
            local name = star.Name
            if name and name ~= "" and not seen[name] then
                seen[name] = true
                table.insert(starNames, name)
            end
        end)
    end
    table.sort(starNames)
    return starNames
end

-- ── Star Teleport Utils ──
local function TeleportToStar(starName)
    pcall(function()
        local starsFolder = workspace:FindFirstChild("Stars")
        if not starsFolder then return end
        local starModel = starsFolder:FindFirstChild(starName)
        if not starModel then return end
        
        local targetPart = starModel.PrimaryPart
            or starModel:FindFirstChildWhichIsA("BasePart")
        
        if targetPart and HumanoidRootPart and HumanoidRootPart.Parent then
            HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 5)
        end
    end)
end

-- ── Quest NPC Utils ──
local function GetQuestNPCList()
    local npcNames = {}
    local seen = {}
    local machinesFolder = workspace:FindFirstChild("Machines")
    if not machinesFolder then return npcNames end
    
    for _, machine in pairs(machinesFolder:GetChildren()) do
        pcall(function()
            local name = machine.Name
            if name and string.find(name, "Quest") and not seen[name] then
                seen[name] = true
                table.insert(npcNames, name)
            end
        end)
    end
    table.sort(npcNames)
    return npcNames
end

local function TeleportToQuestNPC(npcName)
    pcall(function()
        local machinesFolder = workspace:FindFirstChild("Machines")
        if not machinesFolder then return end
        local npcModel = machinesFolder:FindFirstChild(npcName)
        if not npcModel then return end
        
        local targetPart = npcModel.PrimaryPart
            or npcModel:FindFirstChild("HumanoidRootPart")
            or npcModel:FindFirstChildWhichIsA("BasePart")
            
        if targetPart and HumanoidRootPart and HumanoidRootPart.Parent then
            local targetPos = targetPart.Position + targetPart.CFrame.LookVector * 5
            local finalCFrame = CFrame.lookAt(targetPos, targetPart.Position)
            HumanoidRootPart.CFrame = finalCFrame
            
            Fluent:Notify({
                Title = "Quest NPC",
                Content = "Teleported to " .. npcName,
                Duration = 2
            })
        end
    end)
end

-- ── Quest List Utils ──
local function GetQuestList()
    local questItems = {}
    local seen = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Quests"):WaitForChild("Main"):WaitForChild("List")
        local tempList = {}
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                local acceptFrame = child:FindFirstChild("Accept")
                if acceptFrame then
                    local numberLabel = acceptFrame:FindFirstChild("Number")
                    if numberLabel then
                        local text = numberLabel.ContentText or numberLabel.Text or ""
                        if text ~= "" and not seen[text] then
                            seen[text] = true
                            local num = tonumber(text:match("#(%d+)")) or 999
                            table.insert(tempList, { text = text, num = num, parentName = child.Name })
                        end
                    end
                end
            end
        end
        table.sort(tempList, function(a, b) return a.num < b.num end)
        for _, item in ipairs(tempList) do table.insert(questItems, item.text) end
    end)
    return questItems
end

local function GetQuestParentName(numberText)
    local parentName = nil
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Quests"):WaitForChild("Main"):WaitForChild("List")
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                local acceptFrame = child:FindFirstChild("Accept")
                if acceptFrame then
                    local numberLabel = acceptFrame:FindFirstChild("Number")
                    if numberLabel then
                        local text = numberLabel.ContentText or numberLabel.Text or ""
                        if text == numberText then
                            parentName = child.Name
                            break
                        end
                    end
                end
            end
        end
    end)
    return parentName
end

-- ── Quest HUD Utils ──
local function GetHUDQuestObjectives()
    local objectives = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Hud")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Quest")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end

        for _, child in pairs(listFrame:GetChildren()) do
            if not child:IsA("Frame") then continue end
            if child.Name == "Template" then continue end

            local titleLabel = child:FindFirstChild("Title")
            local amountLabel = child:FindFirstChild("Amount")

            if titleLabel and amountLabel then
                local title = titleLabel.ContentText or titleLabel.Text or ""
                local amount = amountLabel.ContentText or amountLabel.Text or ""

                if title == "" or amount == "" then continue end

                local enemyName = title:match("Defeat%s+(.+)")
                if not enemyName then enemyName = title end 

                local current, total = amount:match("(%d+)%s*/%s*(%d+)")
                current = tonumber(current) or 0
                total = tonumber(total) or 0
                
                DebugPrint("[HUD SCAN] Title:", title, "Amount:", amount, "Parsed:", current, "/", total)

                if total <= 0 then continue end

                table.insert(objectives, {
                    frameName = child.Name,
                    enemyName = enemyName,
                    title = title,
                    amount = amount,
                    current = current,
                    total = total,
                    completed = current >= total
                })
            end
        end
    end)
    return objectives
end

local function RefreshObjectiveStatus(enemyName)
    local info = { current = 0, total = 0, completed = false }
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Hud")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Quest")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end

        for _, child in pairs(listFrame:GetChildren()) do
            if not child:IsA("Frame") then continue end
            if child.Name == "Template" then continue end

            local titleLabel = child:FindFirstChild("Title")
            local amountLabel = child:FindFirstChild("Amount")

            if titleLabel and amountLabel then
                local title = titleLabel.ContentText or titleLabel.Text or ""
                local parsedEnemy = title:match("Defeat%s+(.+)")
                if not parsedEnemy then parsedEnemy = title end

                if parsedEnemy == enemyName or string.find(title, enemyName) then
                    local amount = amountLabel.ContentText or amountLabel.Text or ""
                    local c, t = amount:match("(%d+)%s*/%s*(%d+)")
                    info.current = tonumber(c) or 0
                    info.total = tonumber(t) or 0
                    info.completed = info.current >= info.total and info.total > 0
                    break
                end
            end
        end
    end)
    return info
end

local function GetQuestProgress()
    local current, total = 0, 0
    pcall(function()
        local header = LocalPlayer.PlayerGui:FindFirstChild("Hud")
        if not header then return end
        header = header:FindFirstChild("Canvas")
        if not header then return end
        header = header:FindFirstChild("Quest")
        if not header then return end
        header = header:FindFirstChild("Header")
        if not header then return end
        local progressLabel = header:FindFirstChild("Progress")
        if not progressLabel then return end

        local text = progressLabel.ContentText or progressLabel.Text or ""
        local c, t = text:match("(%d+)%s*/%s*(%d+)")
        current = tonumber(c) or 0
        total = tonumber(t) or 0
    end)
    return current, total
end

-- ── Track Quest Utils ──
local function TrackQuest(questId)
    local result = nil
    pcall(function()
        result = GetKnitServices().QuestService.RF.TrackQuest:InvokeServer(questId, "Track")
        DebugPrint("TrackQuest Result for", questId, ":", tostring(result))
    end)
    return result
end

-- ── Stats Utils ──
local function GetStatsList()
    local statNames = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Level Stats"):WaitForChild("Main"):WaitForChild("List")
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("ImageLabel") and child.Name ~= "Template" then
                table.insert(statNames, child.Name)
            end
        end
    end)
    table.sort(statNames)
    return statNames
end

local function GetSkillPoints()
    local text = "N/A"
    pcall(function()
        local label = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Level Stats"):WaitForChild("Main"):WaitForChild("SkillPoints")
        text = label.ContentText or label.Text or "N/A"
    end)
    return text
end

-- ── Avatar Utils ──
local function GetAvatarList()
    local avatarNames = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Avatars"):WaitForChild("Main"):WaitForChild("List")
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Template" then
                table.insert(avatarNames, child.Name)
            end
        end
    end)
    table.sort(avatarNames)
    return avatarNames
end

local function GetAvatarShardAmount()
    local text = "N/A"
    pcall(function()
        local label = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Avatar Stats"):WaitForChild("Main"):WaitForChild("Avatar Shard"):WaitForChild("Amount")
        text = label.ContentText or label.Text or "N/A"
    end)
    return text
end

local function GetAvatarStatsList()
    local statNames = {}
    pcall(function()
        local statsFrame = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Avatar Stats"):WaitForChild("Main"):WaitForChild("Stats")
        for _, child in pairs(statsFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Template" then
                table.insert(statNames, child.Name)
            end
        end
    end)
    table.sort(statNames)
    return statNames
end

local function GetAvatarStatGrade(statName)
    local grade = nil
    pcall(function()
        local statsFrame = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Canvas"):WaitForChild("Avatar Stats"):WaitForChild("Main"):WaitForChild("Stats")
        local statFrame = statsFrame:FindFirstChild(statName)
        if statFrame then
            local gradeLabel = statFrame:FindFirstChild("Grade")
            if gradeLabel then grade = gradeLabel.ContentText or gradeLabel.Text or nil end
        end
    end)
    return grade
end

local function CheckAllStatsGrades(selectedStats, selectedGrades)
    local desiredGrades = {}
    for grade, isSelected in pairs(selectedGrades) do
        if isSelected then desiredGrades[grade] = true end
    end
    
    if next(desiredGrades) == nil then return false end
    
    for statName, isSelected in pairs(selectedStats) do
        if isSelected then
            local currentGrade = GetAvatarStatGrade(statName)
            if not currentGrade or not desiredGrades[currentGrade] then
                return false
            end
        end
    end
    return true
end

-- ── Saiyan Reroll Utils (Inventory path) ──
local function GetSaiyanTokenAmount()
    local text = "N/A"
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Inventory")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end
        local tokenFrame = listFrame:FindFirstChild("Saiyan Token")
        if not tokenFrame then return end
        local button = tokenFrame:FindFirstChild("Button")
        if not button then return end
        local amountLabel = button:FindFirstChild("Amount")
        if not amountLabel then return end
        
        local ok, val = pcall(function() return amountLabel.ContentText end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Text end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Value end)
        if ok and val then text = tostring(val) return end
    end)
    return text
end

local function ToggleSaiyanRarity(rarityName)
    pcall(function()
        GetKnitServices().RerollableService.RF.ToggleRarity:InvokeServer(rarityName)
        DebugPrint("ToggleRarity:", rarityName)
    end)
end

local function RerollSaiyan()
    pcall(function()
        GetKnitServices().RerollableService.RF.Reroll:InvokeServer("Saiyan")
        DebugPrint("Reroll: Saiyan")
    end)
end

local function GetSaiyanRollResult()
    local resultName = nil
    pcall(function()
        local itemLabel = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not itemLabel then return end
        itemLabel = itemLabel:FindFirstChild("Canvas")
        if not itemLabel then return end
        itemLabel = itemLabel:FindFirstChild("Reroll One")
        if not itemLabel then return end
        itemLabel = itemLabel:FindFirstChild("Main")
        if not itemLabel then return end
        itemLabel = itemLabel:FindFirstChild("Info")
        if not itemLabel then return end
        itemLabel = itemLabel:FindFirstChild("ItemFrame")
        if not itemLabel then return end
        itemLabel = itemLabel:FindFirstChild("Button")
        if not itemLabel then return end
        itemLabel = itemLabel:FindFirstChild("Item")
        if not itemLabel then return end
        resultName = itemLabel.ContentText or itemLabel.Text or nil
    end)
    return resultName
end

local function GetSaiyanItemRarity(itemName)
    local rarity = nil
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Reroll One")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end
        
        local itemFrame = listFrame:FindFirstChild(itemName)
        if itemFrame then
            local rarityLabel = itemFrame:FindFirstChild("Rarity")
            if rarityLabel then
                rarity = rarityLabel.ContentText or rarityLabel.Text or nil
            end
        end
    end)
    return rarity
end

-- ── Dragon Reroll Utils ──
local function GetDragonTokenAmount()
    local text = "N/A"
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Inventory")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end
        local tokenFrame = listFrame:FindFirstChild("Dragon Token")
        if not tokenFrame then return end
        local button = tokenFrame:FindFirstChild("Button")
        if not button then return end
        local amountLabel = button:FindFirstChild("Amount")
        if not amountLabel then return end
        
        local ok, val = pcall(function() return amountLabel.ContentText end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Text end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Value end)
        if ok and val then text = tostring(val) return end
    end)
    return text
end

local function ToggleDragonRarity(rarityName)
    pcall(function()
        GetKnitServices().RerollableService.RF.ToggleRarity:InvokeServer(rarityName)
        DebugPrint("Dragon ToggleRarity:", rarityName)
    end)
end

local function RerollDragon()
    pcall(function()
        GetKnitServices().RerollableService.RF.Reroll:InvokeServer("Dragon")
        DebugPrint("Reroll: Dragon")
    end)
end

-- ── Dragon Reroll Utils ──
local function GetDragonTokenAmount()
local text = "N/A"
pcall(function()
local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Canvas")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Inventory")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Main")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("List")
if not listFrame then return end
local tokenFrame = listFrame:FindFirstChild("Dragon Token")
if not tokenFrame then return end
local button = tokenFrame:FindFirstChild("Button")
if not button then return end
local amountLabel = button:FindFirstChild("Amount")
if not amountLabel then return end
    local ok, val = pcall(function() return amountLabel.ContentText end)
    if ok and val and val ~= "" then text = val return end
    ok, val = pcall(function() return amountLabel.Text end)
    if ok and val and val ~= "" then text = val return end
    ok, val = pcall(function() return amountLabel.Value end)
    if ok and val then text = tostring(val) return end
end)
return text
end

local function ToggleDragonRarity(rarityName)
pcall(function()
GetKnitServices().RerollableService.RF.ToggleRarity:InvokeServer(rarityName)
DebugPrint("Dragon ToggleRarity:", rarityName)
end)
end

local function RerollDragon()
pcall(function()
GetKnitServices().RerollableService.RF.Reroll:InvokeServer("Dragon")
DebugPrint("Reroll: Dragon")
end)
end

-- ── Trait Reroll Utils ──
local function GetTraitTokenAmount()
local text = "N/A"
pcall(function()
local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Canvas")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Inventory")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Main")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("List")
if not listFrame then return end
local tokenFrame = listFrame:FindFirstChild("Trait Token")
if not tokenFrame then return end
local button = tokenFrame:FindFirstChild("Button")
if not button then return end
local amountLabel = button:FindFirstChild("Amount")
if not amountLabel then return end

    local ok, val = pcall(function() return amountLabel.ContentText end)
    if ok and val and val ~= "" then text = val return end
    ok, val = pcall(function() return amountLabel.Text end)
    if ok and val and val ~= "" then text = val return end
    ok, val = pcall(function() return amountLabel.Value end)
    if ok and val then text = tostring(val) return end
end)
return text end

local unitDisplayToFrameId = {} -- mapping table

local function GetUnitList()
    local units = {}
    unitDisplayToFrameId = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then DebugPrint("Units: Main not found") return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then DebugPrint("Units: Canvas not found") return end
        listFrame = listFrame:FindFirstChild("Units")
        if not listFrame then DebugPrint("Units: Units not found") return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then DebugPrint("Units: Main2 not found") return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then DebugPrint("Units: List not found") return end
        
        local counter = {}
        
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Template" then
                local ok, err = pcall(function()
                    local button = child:FindFirstChild("Button")
                    if not button then DebugPrint("Units: No Button in", child.Name) return end
                    
                    local unitLabel = button:FindFirstChild("Unit")
                    if not unitLabel then DebugPrint("Units: No Unit label in", child.Name) return end
                    
                    local unitName = unitLabel.ContentText or unitLabel.Text or ""
                    if unitName == "" then DebugPrint("Units: Empty unit name in", child.Name) return end
                    
                    -- Trait is an ImageLabel, get UIGradient name inside it
                    local traitName = ""
                    local traitLabel = button:FindFirstChild("Trait")
                    if traitLabel and traitLabel:IsA("ImageLabel") then
                        local gradient = traitLabel:FindFirstChildWhichIsA("UIGradient")
                        if gradient then
                            traitName = gradient.Name or ""
                            DebugPrint("Units: Trait gradient name:", traitName)
                        end
                    end
                    
                    local baseName
                    if traitName ~= "" then
                        baseName = unitName .. " - " .. traitName
                    else
                        baseName = unitName
                    end
                    
                    if not counter[baseName] then
                        counter[baseName] = 1
                    else
                        counter[baseName] = counter[baseName] + 1
                    end
                    
                    local displayName
                    if counter[baseName] > 1 then
                        displayName = baseName .. " #" .. counter[baseName]
                    else
                        displayName = baseName
                    end
                    
                    unitDisplayToFrameId[displayName] = child.Name
                    table.insert(units, displayName)
                    DebugPrint("Units: Added", displayName, "->", child.Name)
                end)
                if not ok then DebugPrint("Units: Error processing", child.Name, err) end
            end
        end
    end)
    table.sort(units)
    return units
end

local function GetUnitFrameId(displayName)
    if not displayName or displayName == "" then return nil end
    local frameId = unitDisplayToFrameId[displayName]
    DebugPrint("GetUnitFrameId:", displayName, "->", tostring(frameId))
    return frameId
end

local function GetTraitList()
local traits = {}
pcall(function()
local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Canvas")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Trait Reroll")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("Main")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("IndexFrame")
if not listFrame then return end
listFrame = listFrame:FindFirstChild("List")
if not listFrame then return end
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "Template" then
            table.insert(traits, child.Name)
        end
    end
end)
table.sort(traits)
return traits
end

local function ToggleTrait(traitName)
pcall(function()
GetKnitServices().TraitService.RF.ToggleTrait:InvokeServer(traitName)
DebugPrint("ToggleTrait:", traitName)
end)
end

local function RollTrait(unitFrameId)
pcall(function()
GetKnitServices().TraitService.RF.Roll:InvokeServer(unitFrameId)
DebugPrint("RollTrait:", unitFrameId)
end)
end

local function GetCurrentTraitResult()
local traitName = nil
pcall(function()
local frame = LocalPlayer.PlayerGui:FindFirstChild("Main")
if not frame then return end
frame = frame:FindFirstChild("Canvas")
if not frame then return end
frame = frame:FindFirstChild("Trait Reroll")
if not frame then return end
frame = frame:FindFirstChild("Main")
if not frame then return end
frame = frame:FindFirstChild("TraitFrame")
if not frame then return end
frame = frame:FindFirstChild("Button")
if not frame then return end
local traitLabel = frame:FindFirstChild("Trait")
if not traitLabel then return end
    traitName = traitLabel.ContentText or traitLabel.Text or nil
end)
return traitName
end

local function GetChakraTokenAmount()
    local text = "N/A"
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Inventory")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end
        local tokenFrame = listFrame:FindFirstChild("Chakra Token")
        if not tokenFrame then return end
        local button = tokenFrame:FindFirstChild("Button")
        if not button then return end
        local amountLabel = button:FindFirstChild("Amount")
        if not amountLabel then return end
        
        local ok, val = pcall(function() return amountLabel.ContentText end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Text end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Value end)
        if ok and val then text = tostring(val) return end
    end)
    return text
end

local function RerollChakra()
    pcall(function()
        GetKnitServices().RerollableService.RF.Reroll:InvokeServer("Chakra")
        DebugPrint("Reroll: Chakra")
    end)
end

-- ── Jinchuriki Reroll Utils ──
local function GetJinchurikiTokenAmount()
    local text = "N/A"
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Inventory")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end
        local tokenFrame = listFrame:FindFirstChild("Jinchuriki Token")
        if not tokenFrame then return end
        local button = tokenFrame:FindFirstChild("Button")
        if not button then return end
        local amountLabel = button:FindFirstChild("Amount")
        if not amountLabel then return end
        
        local ok, val = pcall(function() return amountLabel.ContentText end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Text end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Value end)
        if ok and val then text = tostring(val) return end
    end)
    return text
end

local function RerollJinchuriki()
    pcall(function()
        GetKnitServices().RerollableService.RF.Reroll:InvokeServer("Jinchuriki")
        DebugPrint("Reroll: Jinchuriki")
    end)
end

-- ── Haki Reroll Utils ──
local function GetHakiTokenAmount()
    local text = "N/A"
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Inventory")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end
        local tokenFrame = listFrame:FindFirstChild("Haki Token")
        if not tokenFrame then return end
        local button = tokenFrame:FindFirstChild("Button")
        if not button then return end
        local amountLabel = button:FindFirstChild("Amount")
        if not amountLabel then return end
        
        local ok, val = pcall(function() return amountLabel.ContentText end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Text end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Value end)
        if ok and val then text = tostring(val) return end
    end)
    return text
end

local function RerollHaki()
    pcall(function()
        GetKnitServices().RerollableService.RF.Reroll:InvokeServer("Haki")
        DebugPrint("Reroll: Haki")
    end)
end


local function FetchCodesFromWeb()
    local codes = {}
    pcall(function()
        local rawHTML = game:HttpGet("https://progameguides.com/roblox/anime-destroyers-codes/")
        if not rawHTML or rawHTML == "" then return end
        
        DebugPrint("HTML length:", #rawHTML)
        
        -- Primary pattern: data-code="CODE" (most reliable, from copy buttons)
        for code in rawHTML:gmatch('data%-code="([^"]+)"') do
            code = code:gsub("^%s+", ""):gsub("%s+$", "")
            if #code >= 2 and #code <= 50 then
                local exists = false
                for _, c in ipairs(codes) do
                    if c == code then exists = true break end
                end
                if not exists then
                    table.insert(codes, code)
                    DebugPrint("Found code:", code)
                end
            end
        end
        
        -- Fallback: <span class="code-text">CODE</span>
        if #codes == 0 then
            for code in rawHTML:gmatch('<span class="code%-text">([^<]+)</span>') do
                code = code:gsub("^%s+", ""):gsub("%s+$", "")
                if #code >= 2 and #code <= 50 then
                    local exists = false
                    for _, c in ipairs(codes) do
                        if c == code then exists = true break end
                    end
                    if not exists then
                        table.insert(codes, code)
                        DebugPrint("Found code (fallback):", code)
                    end
                end
            end
        end
        
        DebugPrint("Total codes found:", #codes)
    end)
    return codes
end

local function RedeemCode(code)
    local result = nil
    pcall(function()
        result = GetKnitServices().CodeService.RF.RedeemCode:InvokeServer(code)
        DebugPrint("RedeemCode:", code, "Result:", tostring(result))
    end)
    return result
end

-- ============================================
-- [[ 8. NOCLIP SYSTEM ]]
-- ============================================
local noClipActive = false

local function EnableNoClip()
    if noClipActive then return end
    noClipActive = true
    if getgenv().EnzoNoClipConn then pcall(function() getgenv().EnzoNoClipConn:Disconnect() end) getgenv().EnzoNoClipConn = nil end
    
    getgenv().EnzoNoClipConn = RunService.Stepped:Connect(function()
        if noClipActive and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function DisableNoClip()
    noClipActive = false
    if getgenv().EnzoNoClipConn then pcall(function() getgenv().EnzoNoClipConn:Disconnect() end) getgenv().EnzoNoClipConn = nil end
    
    pcall(function()
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
            end
        end
    end)
end

-- ============================================
-- [[ 9. MOVEMENT METHODS ]]
-- ============================================
local function UnanchorPlayer()
    pcall(function()
        if HumanoidRootPart and HumanoidRootPart.Parent then
            HumanoidRootPart.Anchored = false
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
        if Humanoid and Humanoid.Parent then Humanoid.AutoRotate = true end
    end)
end

local function ClickEnemy(mob)
    pcall(function()
        if mob and mob.Parent then
            local args = { mob.Name }
            GetKnitServices().ClickService.RF.Click:InvokeServer(unpack(args))
        end
    end)
end

local function TeleportToTarget(targetHRP)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    if not targetHRP or not targetHRP.Parent then return end
    
    local targetPos = targetHRP.Position + targetHRP.CFrame.LookVector * -3
    local finalCFrame = CFrame.lookAt(targetPos, targetHRP.Position)
    HumanoidRootPart.CFrame = finalCFrame
end

local function TweenAboveToTarget(targetHRP)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    if not targetHRP or not targetHRP.Parent then return end
    
    if getgenv().EnzoCurrentTween then pcall(function() getgenv().EnzoCurrentTween:Cancel() end) getgenv().EnzoCurrentTween = nil end
    
    local ABOVE_OFFSET = 20
    local TWEEN_SPEED = 200
    
    EnableNoClip()
    
    local targetPos = targetHRP.Position + Vector3.new(0, ABOVE_OFFSET, 0)
    local aboveCFrame = CFrame.new(targetPos)
    local distance = (HumanoidRootPart.Position - targetPos).Magnitude
    local duration = distance / TWEEN_SPEED
    
    if duration < 0.1 then duration = 0.1 end
    if duration > 10 then duration = 10 end
    
    HumanoidRootPart.Anchored = true
    task.wait()
    HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    task.wait()
    HumanoidRootPart.Anchored = false
    task.wait()
    
    if Humanoid and Humanoid.Parent then Humanoid.AutoRotate = false end
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = aboveCFrame })
    getgenv().EnzoCurrentTween = tween
    
    local stabilizer = RunService.Heartbeat:Connect(function()
        pcall(function() if HumanoidRootPart and HumanoidRootPart.Parent then HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end end)
    end)
    
    tween:Play()
    tween.Completed:Wait()
    stabilizer:Disconnect()
    
    pcall(function()
        if HumanoidRootPart and HumanoidRootPart.Parent then
            HumanoidRootPart.CFrame = aboveCFrame
            HumanoidRootPart.Anchored = true
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end)
    getgenv().EnzoCurrentTween = nil
end

local function UpdateAbovePosition(targetHRP)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    if not targetHRP or not targetHRP.Parent then return end
    local ABOVE_OFFSET = 20
    local targetPos = targetHRP.Position + Vector3.new(0, ABOVE_OFFSET, 0)
    HumanoidRootPart.CFrame = CFrame.new(targetPos)
    HumanoidRootPart.Anchored = true
end

local function WalkToTarget(targetHRP)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    if not targetHRP or not targetHRP.Parent then return end
    if not Humanoid or not Humanoid.Parent then return end
    
    Humanoid.AutoRotate = true
    local targetPos = targetHRP.Position
    local pathSuccess = false
    
    pcall(function()
        local path = PathfindingService:CreatePath({ AgentRadius = 3, AgentHeight = 6, AgentCanJump = true, AgentCanClimb = true, WaypointSpacing = 6 })
        path:ComputeAsync(HumanoidRootPart.Position, targetPos)
        
        if path.Status == Enum.PathStatus.Success then
            pathSuccess = true
            for _, waypoint in ipairs(path:GetWaypoints()) do
                if not getgenv().EnzoScriptRunning then break end
                if not targetHRP or not targetHRP.Parent then break end
                
                if waypoint.Action == Enum.PathWaypointAction.Jump then Humanoid.Jump = true end
                Humanoid:MoveTo(waypoint.Position)
                
                local st = tick()
                local reached = false
                while not reached and (tick() - st) < 2 do
                    task.wait(0.1)
                    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
                    if (HumanoidRootPart.Position - waypoint.Position).Magnitude < 6 then reached = true end
                end
                
                if not reached then pathSuccess = false break end
            end
        end
    end)
    
    if not pathSuccess then
        EnableNoClip()
        local st = tick()
        while (tick() - st) < 15 do
            if not getgenv().EnzoScriptRunning then break end
            if not targetHRP or not targetHRP.Parent then break end
            if not HumanoidRootPart or not HumanoidRootPart.Parent then break end
            if (HumanoidRootPart.Position - targetHRP.Position).Magnitude < 8 then break end
            
            Humanoid:MoveTo(targetHRP.Position)
            task.wait(0.1)
        end
        DisableNoClip()
    end
end

local function MoveToTargetByMethod(method, targetHRP)
    if method == "Teleport" then TeleportToTarget(targetHRP)
    elseif method == "Tween Above" then TweenAboveToTarget(targetHRP)
    elseif method == "Walk" then WalkToTarget(targetHRP) end
end

local function KeepPositionByMethod(method, targetHRP)
    if method == "Tween Above" then UpdateAbovePosition(targetHRP)
    elseif method == "Walk" then 
        if HumanoidRootPart and targetHRP and targetHRP.Parent then 
            if (HumanoidRootPart.Position - targetHRP.Position).Magnitude > 15 then 
                Humanoid:MoveTo(targetHRP.Position) 
            end 
        end 
    end
end

local function CleanupFarmState()
    UnanchorPlayer()
    DisableNoClip()
    if getgenv().EnzoCurrentTween then pcall(function() getgenv().EnzoCurrentTween:Cancel() end) getgenv().EnzoCurrentTween = nil end
    pcall(function() if Humanoid and Humanoid.Parent then Humanoid.AutoRotate = true end end)
    currentTargetModel = nil
    isMovingToTarget = false
    isFarmingTarget = false
end

-- ============================================
-- [[ 10. AUTO FARM LOGIC ]]
-- ============================================
task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoFarm and Options.AutoFarm.Value then
            local selectedEnemies = {}
            if Options.EnemySelect then 
                for enemyName, isSelected in pairs(Options.EnemySelect.Value) do 
                    if isSelected then table.insert(selectedEnemies, enemyName) end 
                end 
            end
            
            if #selectedEnemies > 0 then
                local targetMob, targetHRP = GetNearestEnemy(selectedEnemies)
                
                if targetMob and targetHRP and IsMobAlive(targetMob) then
                    currentTargetModel = targetMob
                    local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"
                    
                    isMovingToTarget = true
                    MoveToTargetByMethod(method, targetHRP)
                    
                    isMovingToTarget = false
                    isFarmingTarget = true
                    ClickEnemy(targetMob)
                    
                    while getgenv().EnzoScriptRunning and Options.AutoFarm and Options.AutoFarm.Value and IsMobAlive(targetMob) and targetHRP and targetHRP.Parent do
                        pcall(function()
                            KeepPositionByMethod(method, targetHRP)
                            ClickEnemy(targetMob)
                        end)
                        task.wait(0.2)
                    end
                    
                    CleanupFarmState()
                    task.wait(0.5)
                else 
                    task.wait(0.5) 
                end
            else 
                task.wait(0.5) 
            end
        else 
            if isFarmingTarget or isMovingToTarget then CleanupFarmState() end 
            task.wait(0.3) 
        end
    end
end)

-- ============================================
-- [[ 11. AUTO QUEST LOGIC (v4.9 - Track & Auto Continue) ]]
-- ============================================
task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoQuest and Options.AutoQuest.Value then
            pcall(function()
                local questList = GetQuestList()
                if not questList or #questList == 0 then
                    DebugPrint("No quests available.")
                    task.wait(1)
                    return
                end

                local selectedQuest = Options.QuestSelect and Options.QuestSelect.Value
                if not selectedQuest or selectedQuest == "" then
                    DebugPrint("No quest selected.")
                    task.wait(1)
                    return
                end

                local startIndex = nil
                for i, qText in ipairs(questList) do
                    if qText == selectedQuest then
                        startIndex = i
                        break
                    end
                end

                if not startIndex then
                    DebugPrint("Selected quest not found in list.")
                    task.wait(1)
                    return
                end

                local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"

                for questIdx = startIndex, #questList do
                    if not getgenv().EnzoScriptRunning then break end
                    if not Options.AutoQuest or not Options.AutoQuest.Value then break end

                    local freshQuestList = GetQuestList()
                    if questIdx > #freshQuestList then break end

                    local currentQuestText = freshQuestList[questIdx]
                    local questId = GetQuestParentName(currentQuestText)
                    if not questId then
                        DebugPrint("Quest ID not found for:", currentQuestText)
                        continue
                    end

                    pcall(function()
                        if Options.QuestSelect then
                            Options.QuestSelect:SetValue(currentQuestText)
                        end
                    end)

                    DebugPrint("=== Starting Quest:", currentQuestText, "ID:", questId, "===")
                    Fluent:Notify({
                        Title = "Auto Quest",
                        Content = "Starting: " .. currentQuestText,
                        Duration = 3
                    })

                    DebugPrint("Accepting Quest:", questId)
                    GetKnitServices().QuestService.RF.AcceptQuest:InvokeServer(questId)
                    task.wait(1)

                    DebugPrint("Tracking Quest:", questId)
                    TrackQuest(questId)
                    task.wait(1.5)

                    local alreadyCompleted = false
                    do
                        local pc, pt = GetQuestProgress()
                        if pt > 0 and pc >= pt then
                            alreadyCompleted = true
                            DebugPrint("Quest already completed, skipping farm:", questId)
                        end
                    end

                    if not alreadyCompleted then
                        local questCompleted = false

                        while getgenv().EnzoScriptRunning and Options.AutoQuest and Options.AutoQuest.Value and not questCompleted do
                            local pc, pt = GetQuestProgress()
                            if pt > 0 and pc >= pt then
                                questCompleted = true
                                break 
                            end

                            local objectives = GetHUDQuestObjectives()
                            if #objectives == 0 then
                                DebugPrint("No HUD objectives, re-tracking quest...")
                                TrackQuest(questId)
                                task.wait(2)
                                continue
                            end

                            local allObjDone = true
                            for _, obj in ipairs(objectives) do
                                if not obj.completed then
                                    allObjDone = false
                                    break
                                end
                            end
                            if allObjDone then
                                questCompleted = true
                                break
                            end

                            local farmedInThisLoop = false
                            for _, obj in ipairs(objectives) do
                                if not obj.completed then
                                    local hudEnemyName = obj.enemyName
                                    
                                    local targetMob, targetHRP = GetNearestEnemy({hudEnemyName})
                                    if not targetMob then
                                        local allMobs = workspace:FindFirstChild("Mobs")
                                        if allMobs then
                                            for _, mob in pairs(allMobs:GetChildren()) do
                                                local mobName = GetEnemyName(mob)
                                                if mobName and (string.find(mobName, hudEnemyName) or string.find(hudEnemyName, mobName)) then
                                                    if IsMobAlive(mob) then
                                                        targetMob = mob
                                                        targetHRP = mob:FindFirstChild("HumanoidRootPart")
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end

                                    if targetMob and targetHRP and IsMobAlive(targetMob) then
                                        farmedInThisLoop = true
                                        currentTargetModel = targetMob
                                        isMovingToTarget = true
                                        DebugPrint("Farming Quest Target:", hudEnemyName, "Method:", method)

                                        MoveToTargetByMethod(method, targetHRP)

                                        isMovingToTarget = false
                                        isFarmingTarget = true
                                        ClickEnemy(targetMob)

                                        local startAmount = obj.current
                                        while getgenv().EnzoScriptRunning and Options.AutoQuest.Value and IsMobAlive(targetMob) and targetHRP and targetHRP.Parent do
                                            pcall(function()
                                                KeepPositionByMethod(method, targetHRP)
                                                ClickEnemy(targetMob)
                                            end)
                                            
                                            local newStatus = RefreshObjectiveStatus(hudEnemyName)
                                            if newStatus.current > startAmount or newStatus.completed then break end
                                            task.wait()
                                        end
                                        CleanupFarmState()
                                    else
                                        DebugPrint("Quest Target Not Found:", hudEnemyName)
                                        task.wait(1)
                                    end
                                end
                                if farmedInThisLoop then break end
                            end
                            task.wait(0.5)
                        end

                        if not Options.AutoQuest or not Options.AutoQuest.Value then
                            CleanupFarmState()
                            break
                        end
                    end

                    DebugPrint("Completing Quest:", questId)
                    Fluent:Notify({
                        Title = "Auto Quest",
                        Content = "Completed: " .. currentQuestText,
                        Duration = 3
                    })
                    GetKnitServices().QuestService.RF.CompleteQuest:InvokeServer(questId)
                    task.wait(2)

                    TrackQuest(questId)
                    task.wait(1)
                end

                if Options.AutoQuest and Options.AutoQuest.Value then
                    Fluent:Notify({
                        Title = "Auto Quest",
                        Content = "All quests completed! Auto Quest disabled.",
                        Duration = 5
                    })
                    Options.AutoQuest:SetValue(false)
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end)

-- ============================================
-- [[ 12. UI SETUP ]]
-- ============================================

-- [[ Main Tab: Auto Farm ]]
local SectionEnemy = Tabs.Main:AddSection("Auto Farm")
local currentEnemyList = GetEnemyList()
local DropdownEnemy = Tabs.Main:AddDropdown("EnemySelect", {
    Title = "Select Enemy",
    Description = "Choose enemies to farm (multi select)",
    Values = currentEnemyList,
    Multi = true,
    Default = {}
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function()
            local newList = GetEnemyList()
            local changed = #newList ~= #currentEnemyList
            if not changed then for i, name in ipairs(newList) do if currentEnemyList[i] ~= name then changed = true break end end end
            if changed then currentEnemyList = newList DropdownEnemy:SetValues(newList) end
        end)
    end
end)

local DropdownMethod = Tabs.Main:AddDropdown("MethodSelect", {
    Title = "Farm Method",
    Description = "Movement method for Auto Farm & Auto Quest",
    Values = {"Teleport", "Walk"},
    Multi = false,
    Default = "Teleport"
})

local ToggleAutoFarm = Tabs.Main:AddToggle("AutoFarm", { Title = "Auto Farm", Default = false })

-- Tambahkan setelah ToggleAutoFarm
local ToggleAutoFarmNearest = Tabs.Main:AddToggle("AutoFarmNearest", { 
    Title = "Auto Farm Nearest Enemy", 
    Default = false 
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoFarmNearest and Options.AutoFarmNearest.Value then
            local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"
            
            -- Find nearest mob (any mob, not filtered)
            local nearestMob, nearestHRP = nil, nil
            local nearestDist = math.huge
            local mobsFolder = workspace:FindFirstChild("Mobs")
            
            if mobsFolder and HumanoidRootPart and HumanoidRootPart.Parent then
                for _, mob in pairs(mobsFolder:GetChildren()) do
                    if IsMobAlive(mob) then
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (HumanoidRootPart.Position - hrp.Position).Magnitude
                            if d < nearestDist then
                                nearestMob = mob
                                nearestHRP = hrp
                                nearestDist = d
                            end
                        end
                    end
                end
            end
            
            if nearestMob and nearestHRP and IsMobAlive(nearestMob) then
                currentTargetModel = nearestMob
                isMovingToTarget = true
                MoveToTargetByMethod(method, nearestHRP)
                
                isMovingToTarget = false
                isFarmingTarget = true
                ClickEnemy(nearestMob)
                
                while getgenv().EnzoScriptRunning and Options.AutoFarmNearest.Value and IsMobAlive(nearestMob) and nearestHRP.Parent do
                    KeepPositionByMethod(method, nearestHRP)
                    ClickEnemy(nearestMob)
                    task.wait(0.2)
                end
                CleanupFarmState()
            end
            task.wait(0.3)
        else
            task.wait(0.3)
        end
    end
end)

-- [[ Main Tab: Quest ]]
local SectionQuest = Tabs.Main:AddSection("Quest")
local currentQuestNPCList = GetQuestNPCList()
local DropdownQuestNPC = Tabs.Main:AddDropdown("QuestNPCSelect", {
    Title = "Quest NPC",
    Description = "Select Quest NPC to teleport to",
    Values = currentQuestNPCList,
    Multi = false,
    Default = nil
})

DropdownQuestNPC:OnChanged(function(value)
    if value and value ~= "" then TeleportToQuestNPC(value) end
end)

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function()
            local newList = GetQuestNPCList()
            local changed = #newList ~= #currentQuestNPCList
            if not changed then for i, name in ipairs(newList) do if currentQuestNPCList[i] ~= name then changed = true break end end end
            if changed then currentQuestNPCList = newList DropdownQuestNPC:SetValues(newList) end
        end)
    end
end)

local currentQuestList = GetQuestList()
local DropdownQuest = Tabs.Main:AddDropdown("QuestSelect", {
    Title = "Select Quest",
    Description = "Pick starting quest, auto continues to next",
    Values = currentQuestList,
    Multi = false,
    Default = nil
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function()
            local newList = GetQuestList()
            local changed = #newList ~= #currentQuestList
            if not changed then for i, name in ipairs(newList) do if currentQuestList[i] ~= name then changed = true break end end end
            if changed then currentQuestList = newList DropdownQuest:SetValues(newList) end
        end)
    end
end)

local ToggleAutoQuest = Tabs.Main:AddToggle("AutoQuest", {
    Title = "Auto Quest",
    Description = "Auto complete quests in order, turns off when done",
    Default = false
})

-- ============================================
-- [[ TOKEN SYSTEM (FIXED) ]]
-- ============================================

-- ── Variables for Token System ──
local tokenFarmCache = {}
local currentFarmingToken = nil

-- ── Token Utility Functions ──

local function GetTokenList()
    local tokens = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui.Main.Canvas.Inventory.Main.List
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Template" then
                if string.find(child.Name:lower(), "token") then
                    table.insert(tokens, child.Name)
                end
            end
        end
    end)
    table.sort(tokens)
    return tokens
end

local function GetTokenAmount(tokenName)
    local amount = "0"
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui.Main.Canvas.Inventory.Main.List
        local tokenFrame = listFrame:FindFirstChild(tokenName)
        if tokenFrame then
            local button = tokenFrame:FindFirstChild("Button")
            if button then
                local amountLabel = button:FindFirstChild("Amount")
                if amountLabel then
                    amount = amountLabel.ContentText or amountLabel.Text or "0"
                end
            end
        end
    end)
    return amount
end

local function FormatTokenStatus(selectedTokens, currentArea, farmingToken)
    local lines = {}
    table.insert(lines, "Area: " .. (currentArea or "Unknown"))
    table.insert(lines, "")
    table.insert(lines, "Token Inventory:")
    
    local hasSelection = false
    
    if selectedTokens and type(selectedTokens) == "table" then
        for tokenName, isSelected in pairs(selectedTokens) do
            if isSelected then
                hasSelection = true
                local amount = GetTokenAmount(tokenName)
                local cacheInfo = ""
                if tokenFarmCache[tokenName] then
                    cacheInfo = " [" .. tokenFarmCache[tokenName].world .. "]"
                end
                local highlight = ""
                if farmingToken and tokenName == farmingToken then
                    highlight = " ← Farming"
                end
                table.insert(lines, "• " .. tokenName .. ": " .. amount .. cacheInfo .. highlight)
            end
        end
    end
    
    if not hasSelection then
        table.insert(lines, "No tokens selected")
    end
    
    local cacheCount = 0
    for _ in pairs(tokenFarmCache) do cacheCount = cacheCount + 1 end
    table.insert(lines, "")
    table.insert(lines, "Cached Locations: " .. cacheCount)
    
    return table.concat(lines, "\n")
end

local function FindTokenDropsInWorld(worldName, tokensToFind)
    local results = {}
    
    pcall(function()
        local mobsFolder = workspace:FindFirstChild("Mobs")
        if not mobsFolder then return end
        
        for _, mob in pairs(mobsFolder:GetChildren()) do
            local mobArea = mob:GetAttribute("Area")
            if mobArea == worldName and IsMobAlive(mob) then
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local enemyOverhead = hrp:FindFirstChild("EnemyOverhead")
                    if enemyOverhead then
                        local rewards = enemyOverhead:FindFirstChild("Rewards")
                        if rewards then
                            for _, tokenName in ipairs(tokensToFind) do
                                local tokenReward = rewards:FindFirstChild(tokenName)
                                if tokenReward then
                                    local button = tokenReward:FindFirstChild("Button")
                                    if button then
                                        local chanceLabel = button:FindFirstChild("Chance")
                                        local amountLabel = button:FindFirstChild("Amount")
                                        
                                        local chance = 0
                                        local amount = 0
                                        
                                        if chanceLabel then
                                            local text = chanceLabel.ContentText or chanceLabel.Text or ""
                                            chance = tonumber(text:match("(%d+%.?%d*)")) or 0
                                        end
                                        
                                        if amountLabel then
                                            local text = amountLabel.ContentText or amountLabel.Text or ""
                                            amount = tonumber(text:match("(%d+)")) or 0
                                        end
                                        
                                        local score = chance * amount
                                        local mobName = GetEnemyName(mob) or mob.Name
                                        
                                        if not results[tokenName] or score > results[tokenName].mob.score then
                                            results[tokenName] = {
                                                world = worldName,
                                                mob = {
                                                    name = mobName,
                                                    chance = chance,
                                                    amount = amount,
                                                    score = score
                                                }
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return results
end

local function ScanWorldsForTokens(tokensToFind)
    local results = {}
    local worlds = GetWorldList()
    local totalTokens = #tokensToFind
    
    if totalTokens == 0 then
        return results
    end
    
    DebugPrint("=== Scanning for", totalTokens, "token(s) ===")
    DebugPrint("Tokens:", table.concat(tokensToFind, ", "))
    
    Fluent:Notify({
        Title = "Auto Token",
        Content = "Scanning " .. #worlds .. " worlds for " .. totalTokens .. " token(s)...",
        Duration = 3
    })
    
    for worldIndex, worldName in ipairs(worlds) do
        if not getgenv().EnzoScriptRunning then break end
        if not (Options.AutoCollectToken and Options.AutoCollectToken.Value) then break end
        
        if excludedWorlds and excludedWorlds[worldName] then
            continue
        end
        
        DebugPrint("Scanning [" .. worldIndex .. "/" .. #worlds .. "]:", worldName)
        
        Fluent:Notify({
            Title = "Auto Token",
            Content = "Scanning [" .. worldIndex .. "/" .. #worlds .. "]: " .. worldName,
            Duration = 1
        })
        
        TeleportToWorld(worldName)
        task.wait(2)
        
        local worldResults = FindTokenDropsInWorld(worldName, tokensToFind)
        
        for tokenName, result in pairs(worldResults) do
            if not results[tokenName] or result.mob.score > results[tokenName].mob.score then
                results[tokenName] = result
                DebugPrint("Found", tokenName, "in", worldName, "Mob:", result.mob.name, "Score:", result.mob.score)
            end
        end
        
        -- Check if we found all tokens
        local foundAll = true
        for _, tokenName in ipairs(tokensToFind) do
            if not results[tokenName] then
                foundAll = false
                break
            end
        end
        
        if foundAll then
            DebugPrint("Found all tokens, stopping scan early")
            break
        end
    end
    
    local foundCount = 0
    for tokenName, result in pairs(results) do
        DebugPrint("Result:", tokenName, "-> World:", result.world, "Mob:", result.mob.name)
        foundCount = foundCount + 1
    end
    
    Fluent:Notify({
        Title = "Auto Token",
        Content = "Scan complete! Found " .. foundCount .. "/" .. totalTokens .. " token location(s).",
        Duration = 3
    })
    
    return results
end

local function GetTokensNotInCache(tokenList)
    local notInCache = {}
    for _, tokenName in ipairs(tokenList) do
        if not tokenFarmCache[tokenName] then
            table.insert(notInCache, tokenName)
        end
    end
    return notInCache
end

local function AddTokensToCache(scanResults)
    for tokenName, result in pairs(scanResults) do
        tokenFarmCache[tokenName] = result
        DebugPrint("Token Cached:", tokenName, "-> World:", result.world, "Mob:", result.mob.name)
    end
end

-- ============================================
-- [[ TOKEN UI SECTION ]]
-- ============================================

local SectionToken = Tabs.Misc:AddSection("Token")

local currentTokenList = GetTokenList()
local DropdownToken = Tabs.Misc:AddDropdown("TokenSelect", {
    Title = "Select Tokens",
    Description = "Choose tokens to collect (multi select)",
    Values = currentTokenList,
    Multi = true,
    Default = {}
})

local TokenStatusLabel = Tabs.Misc:AddParagraph({
    Title = "Token Status",
    Content = "Area: Unknown\n\nNo tokens selected"
})

local ToggleAutoCollectToken = Tabs.Misc:AddToggle("AutoCollectToken", {
    Title = "Auto Collect Token",
    Description = "Auto farm selected tokens",
    Default = false
})

-- Update when dropdown changes
DropdownToken:OnChanged(function(value)
    -- Clear cache when selection changes
    tokenFarmCache = {}
    DebugPrint("Token selection changed, clearing cache")
    
    -- Update label immediately
    local currentArea = GetCurrentArea()
    local statusText = FormatTokenStatus(value, currentArea, currentFarmingToken)
    TokenStatusLabel:SetDesc(statusText)
end)

-- Refresh token list periodically
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetTokenList()
            local changed = #newList ~= #currentTokenList
            if not changed then
                for i, name in ipairs(newList) do
                    if currentTokenList[i] ~= name then changed = true break end
                end
            end
            if changed then
                currentTokenList = newList
                DropdownToken:SetValues(newList)
            end
        end)
    end
end))

-- Update token status label periodically
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(2)
        pcall(function()
            local selectedTokens = {}
            if Options.TokenSelect and Options.TokenSelect.Value then
                selectedTokens = Options.TokenSelect.Value
            end
            local currentArea = GetCurrentArea()
            local statusText = FormatTokenStatus(selectedTokens, currentArea, currentFarmingToken)
            TokenStatusLabel:SetDesc(statusText)
        end)
    end
end))

-- Clear farming token when toggle off
ToggleAutoCollectToken:OnChanged(function(value)
    if not value then
        currentFarmingToken = nil
        CleanupFarmState()
    end
end)

-- ============================================
-- [[ AUTO COLLECT TOKEN MAIN LOOP (FIXED) ]]
-- ============================================

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoCollectToken and Options.AutoCollectToken.Value then
            -- Get selected tokens
            local selectedTokens = {}
            if Options.TokenSelect and Options.TokenSelect.Value then
                selectedTokens = Options.TokenSelect.Value
            end
            
            -- Build token list from selected
            local tokenList = {}
            for tokenName, isSelected in pairs(selectedTokens) do
                if isSelected then
                    table.insert(tokenList, tokenName)
                    DebugPrint("Selected token:", tokenName)
                end
            end
            
            DebugPrint("Total selected tokens:", #tokenList)
            
            if #tokenList == 0 then
                DebugPrint("No tokens selected")
                currentFarmingToken = nil
                task.wait(1)
                continue
            end
            
            -- Check which tokens are not in cache
            local tokensNotInCache = GetTokensNotInCache(tokenList)
            DebugPrint("Tokens not in cache:", #tokensNotInCache)
            
            if #tokensNotInCache > 0 then
                DebugPrint("Need to scan for", #tokensNotInCache, "token(s)")
                
                Fluent:Notify({
                    Title = "Auto Token",
                    Content = "Scanning for " .. #tokensNotInCache .. " token(s)...",
                    Duration = 3
                })
                
                local scanResults = ScanWorldsForTokens(tokensNotInCache)
                AddTokensToCache(scanResults)
            end
            
            -- Farm tokens
            local farmedAny = false
            
            for _, tokenName in ipairs(tokenList) do
                if not getgenv().EnzoScriptRunning then break end
                if not (Options.AutoCollectToken and Options.AutoCollectToken.Value) then break end
                
                local farmSpot = tokenFarmCache[tokenName]
                
                if farmSpot then
                    currentFarmingToken = tokenName
                    farmedAny = true
                    
                    DebugPrint("=== Farming token:", tokenName, "===")
                    DebugPrint("World:", farmSpot.world, "Mob:", farmSpot.mob.name)
                    
                    Fluent:Notify({
                        Title = "Auto Token",
                        Content = "Farming " .. tokenName .. " at " .. farmSpot.world,
                        Duration = 2
                    })
                    
                    -- Teleport if needed
                    local currentArea = GetCurrentArea()
                    if currentArea ~= farmSpot.world then
                        DebugPrint("Teleporting to:", farmSpot.world)
                        TeleportToWorld(farmSpot.world)
                        task.wait(3)
                    end
                    
                    local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"
                    
                    -- Farm for 30 seconds then switch to next token
                    local farmDuration = 30
                    local startTime = tick()
                    
                    while getgenv().EnzoScriptRunning and Options.AutoCollectToken.Value and (tick() - startTime) < farmDuration do
                        local targetMob, targetHRP = nil, nil
                        local mobsFolder = workspace:FindFirstChild("Mobs")
                        
                        if mobsFolder then
                            -- Find mob that drops this token
                            for _, mob in pairs(mobsFolder:GetChildren()) do
                                local mobArea = mob:GetAttribute("Area")
                                if mobArea == farmSpot.world and IsMobAlive(mob) then
                                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local eo = hrp:FindFirstChild("EnemyOverhead")
                                        if eo then
                                            local rewards = eo:FindFirstChild("Rewards")
                                            if rewards and rewards:FindFirstChild(tokenName) then
                                                targetMob = mob
                                                targetHRP = hrp
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            
                            -- Fallback: find by mob name
                            if not targetMob then
                                for _, mob in pairs(mobsFolder:GetChildren()) do
                                    local mobName = GetEnemyName(mob)
                                    local mobArea = mob:GetAttribute("Area")
                                    if mobArea == farmSpot.world and IsMobAlive(mob) then
                                        if mobName == farmSpot.mob.name then
                                            targetMob = mob
                                            targetHRP = mob:FindFirstChild("HumanoidRootPart")
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        if targetMob and targetHRP and IsMobAlive(targetMob) then
                            currentTargetModel = targetMob
                            MoveToTargetByMethod(method, targetHRP)
                            ClickEnemy(targetMob)
                            
                            while getgenv().EnzoScriptRunning and Options.AutoCollectToken.Value and IsMobAlive(targetMob) and targetHRP.Parent and (tick() - startTime) < farmDuration do
                                KeepPositionByMethod(method, targetHRP)
                                ClickEnemy(targetMob)
                                task.wait(0.2)
                            end
                            CleanupFarmState()
                        else
                            -- No mob found
                            DebugPrint("No mob found, waiting...")
                            task.wait(1)
                        end
                        
                        task.wait(0.3)
                    end
                    
                    currentFarmingToken = nil
                    DebugPrint("Finished farming", tokenName, "for", farmDuration, "seconds")
                else
                    DebugPrint("No cache for token:", tokenName)
                end
            end
            
            if not farmedAny then
                DebugPrint("No tokens could be farmed")
                task.wait(2)
            end
            
            task.wait(0.5)
        else
            currentFarmingToken = nil
            task.wait(0.3)
        end
    end
end))


-- ============================================
-- [[ BOSS RUSH SYSTEM (FIXED) ]]
-- ============================================

-- ── Boss Rush Utility Functions ──

local function GetBossRushScrollAmount(scrollType)
    local amount = 0
    local scrollName = "Boss Rush Scroll " .. scrollType
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui.Main.Canvas.Inventory.Main.List
        local scrollFrame = listFrame:FindFirstChild(scrollName)
        if scrollFrame then
            local button = scrollFrame:FindFirstChild("Button")
            if button then
                local amountLabel = button:FindFirstChild("Amount")
                if amountLabel then
                    local text = amountLabel.ContentText or amountLabel.Text or "0"
                    amount = tonumber(text:match("(%d+)")) or 0
                end
            end
        end
    end)
    DebugPrint("GetBossRushScrollAmount:", scrollName, "=", amount)
    return amount
end

local function StartBossRush(scrollType)
    local success = false
    pcall(function()
        local result = GetKnitServices().BossRushService.RF.StartBossRush:InvokeServer(scrollType)
        DebugPrint("StartBossRush:", scrollType, "Result:", tostring(result))
        success = true
    end)
    return success
end

local function GetBossMobCount()
    local count = 0
    pcall(function()
        local mobsFolder = workspace:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in pairs(mobsFolder:GetChildren()) do
                if IsMobAlive(mob) then
                    count = count + 1
                end
            end
        end
    end)
    return count
end

local function WaitForBossMob(timeout)
    timeout = timeout or 10
    local startTime = tick()
    
    while (tick() - startTime) < timeout do
        if GetBossMobCount() > 0 then
            DebugPrint("Boss mob appeared!")
            return true
        end
        task.wait(0.5)
    end
    
    DebugPrint("Timeout waiting for boss mob")
    return false
end

-- ============================================
-- [[ BOSS UI SECTION ]]
-- ============================================

local SectionBoss = Tabs.Main:AddSection("Boss")

local DropdownWorldBoss = Tabs.Main:AddDropdown("WorldBossSelect", {
    Title = "Select World Boss",
    Description = "Choose world for Boss Rush",
    Values = {"Leaf Village", "Egg City"},
    Multi = false,
    Default = nil
})

local BossStatusLabel = Tabs.Main:AddParagraph({
    Title = "Boss Rush Status",
    Content = "Select a world to start Boss Rush"
})

local ToggleAutoBossRush = Tabs.Main:AddToggle("AutoBossRush", {
    Title = "Auto Boss Rush",
    Description = "Auto start and farm Boss Rush",
    Default = false
})

-- Update boss status label
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(2)
        pcall(function()
            local selectedWorld = Options.WorldBossSelect and Options.WorldBossSelect.Value
            local lines = {}
            
            if selectedWorld and selectedWorld ~= "" then
                local scrollType = "I"
                if selectedWorld == "Egg City" then
                    scrollType = "II"
                end
                
                local scrollAmount = GetBossRushScrollAmount(scrollType)
                local currentArea = GetCurrentArea()
                
                table.insert(lines, "World: " .. selectedWorld)
                table.insert(lines, "Current Area: " .. currentArea)
                table.insert(lines, "Required: Boss Rush Scroll " .. scrollType)
                table.insert(lines, "Owned: " .. scrollAmount)
                table.insert(lines, "")
                
                if scrollAmount > 0 then
                    table.insert(lines, "Status: ✓ Ready")
                else
                    table.insert(lines, "Status: ✗ Need Scroll")
                end
                
                local bossCount = GetBossMobCount()
                table.insert(lines, "Boss Mobs: " .. bossCount)
            else
                table.insert(lines, "Select a world to start Boss Rush")
            end
            
            BossStatusLabel:SetDesc(table.concat(lines, "\n"))
        end)
    end
end))

-- Cleanup when toggle off
ToggleAutoBossRush:OnChanged(function(value)
    if not value then
        CleanupFarmState()
    end
end)

-- ============================================
-- [[ AUTO BOSS RUSH MAIN LOOP (FIXED) ]]
-- ============================================

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoBossRush and Options.AutoBossRush.Value then
            local selectedWorld = Options.WorldBossSelect and Options.WorldBossSelect.Value
            
            if not selectedWorld or selectedWorld == "" then
                DebugPrint("No world selected for Boss Rush")
                task.wait(1)
                continue
            end
            
            DebugPrint("=== Auto Boss Rush ===")
            DebugPrint("Selected World:", selectedWorld)
            
            -- Determine scroll type
            local scrollType = "I"
            if selectedWorld == "Egg City" then
                scrollType = "II"
            end
            
            DebugPrint("Scroll Type:", scrollType)
            
            -- Check scroll amount
            local scrollAmount = GetBossRushScrollAmount(scrollType)
            DebugPrint("Scroll Amount:", scrollAmount)
            
            if scrollAmount <= 0 then
                Fluent:Notify({
                    Title = "Auto Boss Rush",
                    Content = "No Boss Rush Scroll " .. scrollType .. " available. Stopping.",
                    Duration = 3
                })
                Options.AutoBossRush:SetValue(false)
                continue
            end
            
            -- Teleport to world
            local currentArea = GetCurrentArea()
            DebugPrint("Current Area:", currentArea)
            
            if currentArea ~= selectedWorld then
                Fluent:Notify({
                    Title = "Auto Boss Rush",
                    Content = "Teleporting to " .. selectedWorld .. "...",
                    Duration = 2
                })
                
                TeleportToWorld(selectedWorld)
                task.wait(3)
                
                -- Verify teleport
                currentArea = GetCurrentArea()
                DebugPrint("After teleport, Current Area:", currentArea)
            end
            
            -- Start Boss Rush
            Fluent:Notify({
                Title = "Auto Boss Rush",
                Content = "Starting Boss Rush " .. scrollType .. "...",
                Duration = 2
            })
            
            DebugPrint("Starting Boss Rush with scroll type:", scrollType)
            StartBossRush(scrollType)
            task.wait(2)
            
            -- Wait for boss to spawn
            DebugPrint("Waiting for boss mob to spawn...")
            local bossSpawned = WaitForBossMob(15)
            
            if not bossSpawned then
                DebugPrint("Boss did not spawn, retrying...")
                task.wait(2)
                continue
            end
            
            Fluent:Notify({
                Title = "Auto Boss Rush",
                Content = "Boss spawned! Farming...",
                Duration = 2
            })
            
            -- Farm Boss
            local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"
            DebugPrint("Farm method:", method)
            
            while getgenv().EnzoScriptRunning and Options.AutoBossRush.Value do
                local mobsFolder = workspace:FindFirstChild("Mobs")
                
                if mobsFolder then
                    local targetMob, targetHRP = nil, nil
                    local nearestDist = math.huge
                    
                    for _, mob in pairs(mobsFolder:GetChildren()) do
                        if IsMobAlive(mob) then
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            if hrp and HumanoidRootPart and HumanoidRootPart.Parent then
                                local d = (HumanoidRootPart.Position - hrp.Position).Magnitude
                                if d < nearestDist then
                                    targetMob = mob
                                    targetHRP = hrp
                                    nearestDist = d
                                end
                            end
                        end
                    end
                    
                    if targetMob and targetHRP and IsMobAlive(targetMob) then
                        DebugPrint("Attacking boss:", GetEnemyName(targetMob) or targetMob.Name)
                        
                        currentTargetModel = targetMob
                        MoveToTargetByMethod(method, targetHRP)
                        ClickEnemy(targetMob)
                        
                        while getgenv().EnzoScriptRunning and Options.AutoBossRush.Value and IsMobAlive(targetMob) and targetHRP.Parent do
                            KeepPositionByMethod(method, targetHRP)
                            ClickEnemy(targetMob)
                            task.wait(0.2)
                        end
                        CleanupFarmState()
                        
                        DebugPrint("Boss defeated!")
                    else
                        -- No boss found - boss rush might have ended
                        DebugPrint("No boss found, waiting 5 seconds...")
                        task.wait(5)
                        
                        -- Check if any mob exists
                        if GetBossMobCount() == 0 then
                            DebugPrint("Boss Rush ended, restarting...")
                            Fluent:Notify({
                                Title = "Auto Boss Rush",
                                Content = "Boss Rush completed! Restarting...",
                                Duration = 2
                            })
                            break -- Exit inner loop to restart boss rush
                        end
                    end
                else
                    task.wait(1)
                end
                
                task.wait(0.3)
            end
            
            task.wait(1)
        else
            task.wait(0.3)
        end
    end
end))


-- ============================================
-- [[ PROGRESSION RAID SYSTEM (FIXED) ]]
-- ============================================

-- ── Progression Raid Utility Functions ──

local function GetRaidStatus()
    local status = "Unknown"
    pcall(function()
        local raidUI = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if raidUI then
            local canvas = raidUI:FindFirstChild("Canvas")
            if canvas then
                local progressionRaid = canvas:FindFirstChild("Progression Raid")
                if progressionRaid then
                    local main = progressionRaid:FindFirstChild("Main")
                    if main then
                        local openLabel = main:FindFirstChild("Open")
                        if openLabel then
                            status = openLabel.ContentText or openLabel.Text or "Unknown"
                        end
                    end
                end
            end
        end
    end)
    DebugPrint("GetRaidStatus:", status)
    return status
end

local function IsRaidOpen()
    local status = GetRaidStatus()
    local isOpen = string.find(status:lower(), "open") ~= nil
    DebugPrint("IsRaidOpen:", isOpen)
    return isOpen
end

local function GetRaidModeList()
    local modes = {}
    pcall(function()
        local raidUI = LocalPlayer.PlayerGui.Main.Canvas["Progression Raid"].Main.Difficulties
        for _, child in pairs(raidUI:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Template" then
                table.insert(modes, child.Name)
            end
        end
    end)
    table.sort(modes)
    DebugPrint("GetRaidModeList:", table.concat(modes, ", "))
    return modes
end

local function GetCurrentWave()
    local wave = 0
    pcall(function()
        local raidMode = LocalPlayer.PlayerGui:FindFirstChild("RaidMode")
        if raidMode then
            local canvas = raidMode:FindFirstChild("Canvas")
            if canvas then
                local main = canvas:FindFirstChild("Main")
                if main then
                    local stats = main:FindFirstChild("Stats")
                    if stats then
                        local waveFrame = stats:FindFirstChild("Wave")
                        if waveFrame then
                            local amountLabel = waveFrame:FindFirstChild("Amount")
                            if amountLabel then
                                local text = amountLabel.ContentText or amountLabel.Text or "0"
                                wave = tonumber(text:match("(%d+)")) or 0
                            end
                        end
                    end
                end
            end
        end
    end)
    return wave
end

local function StartRaid(mode)
    local success = false
    pcall(function()
        local result = GetKnitServices().ProgressionRaidService.RF.StartRaid:InvokeServer(mode)
        DebugPrint("StartRaid:", mode, "Result:", tostring(result))
        success = true
    end)
    return success
end

local function LeaveRaid()
    local success = false
    pcall(function()
        local result = GetKnitServices().ProgressionRaidService.RF.PlayerLeave:InvokeServer("1", true)
        DebugPrint("LeaveRaid Result:", tostring(result))
        success = true
    end)
    return success
end

local function IsInRaid()
    local inRaid = false
    pcall(function()
        local raidUI = LocalPlayer.PlayerGui:FindFirstChild("RaidMode")
        if raidUI then
            local canvas = raidUI:FindFirstChild("Canvas")
            if canvas then
                -- Check if Canvas is visible and has content
                if canvas.Visible then
                    local main = canvas:FindFirstChild("Main")
                    if main and main.Visible then
                        inRaid = true
                    end
                end
            end
        end
    end)
    return inRaid
end

local function GetRaidMobCount()
    local count = 0
    pcall(function()
        local mobsFolder = workspace:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in pairs(mobsFolder:GetChildren()) do
                if IsMobAlive(mob) then
                    count = count + 1
                end
            end
        end
    end)
    return count
end

local function WaitForRaidMob(timeout)
    timeout = timeout or 15
    local startTime = tick()
    
    while (tick() - startTime) < timeout do
        if GetRaidMobCount() > 0 then
            DebugPrint("Raid mob appeared!")
            return true
        end
        task.wait(0.5)
    end
    
    DebugPrint("Timeout waiting for raid mob")
    return false
end

-- ============================================
-- [[ PROGRESSION RAID UI SECTION ]]
-- ============================================

local SectionRaid = Tabs.Main:AddSection("Progression Raid")

local RaidStatusLabel = Tabs.Main:AddParagraph({
    Title = "Raid Status",
    Content = "Status: Unknown"
})

local currentRaidModeList = GetRaidModeList()
local DropdownRaidMode = Tabs.Main:AddDropdown("RaidModeSelect", {
    Title = "Select Mode",
    Description = "Choose raid difficulty",
    Values = currentRaidModeList,
    Multi = false,
    Default = nil
})

local ToggleAutoRaid = Tabs.Main:AddToggle("AutoRaid", {
    Title = "Auto Raid",
    Description = "Auto start and farm Progression Raid",
    Default = false
})

local InputLeaveWave = Tabs.Main:AddInput("LeaveWave", {
    Title = "Leave At Wave",
    Description = "Auto leave when reaching this wave (0 = disabled)",
    Default = "0",
    Placeholder = "Enter wave number",
    Numeric = true,
    Finished = true
})

local ToggleAutoLeaveWave = Tabs.Main:AddToggle("AutoLeaveWave", {
    Title = "Auto Leave Wave",
    Description = "Auto leave when reaching specified wave",
    Default = false
})

-- Refresh raid mode list
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetRaidModeList()
            local changed = #newList ~= #currentRaidModeList
            if not changed then
                for i, name in ipairs(newList) do
                    if currentRaidModeList[i] ~= name then changed = true break end
                end
            end
            if changed then
                currentRaidModeList = newList
                DropdownRaidMode:SetValues(newList)
            end
        end)
    end
end))

-- Update raid status label
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(1)
        pcall(function()
            local lines = {}
            
            local status = GetRaidStatus()
            table.insert(lines, status)
            
            local inRaid = IsInRaid()
            table.insert(lines, "In Raid: " .. tostring(inRaid))
            
            if inRaid then
                local wave = GetCurrentWave()
                table.insert(lines, "Current Wave: " .. wave)
                
                local mobCount = GetRaidMobCount()
                table.insert(lines, "Mobs: " .. mobCount)
            end
            
            RaidStatusLabel:SetDesc(table.concat(lines, "\n"))
        end)
    end
end))

-- Cleanup when toggle off
ToggleAutoRaid:OnChanged(function(value)
    if not value then
        CleanupFarmState()
    end
end)

-- ============================================
-- [[ AUTO RAID MAIN LOOP (FIXED) ]]
-- ============================================

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoRaid and Options.AutoRaid.Value then
            local selectedMode = Options.RaidModeSelect and Options.RaidModeSelect.Value
            
            if not selectedMode or selectedMode == "" then
                DebugPrint("No raid mode selected")
                task.wait(1)
                continue
            end
            
            DebugPrint("=== Auto Raid ===")
            DebugPrint("Selected Mode:", selectedMode)
            
            -- Check if already in raid
            local inRaid = IsInRaid()
            DebugPrint("Already in raid:", inRaid)
            
            if not inRaid then
                -- Check if raid is open
                if not IsRaidOpen() then
                    DebugPrint("Raid not open, waiting...")
                    task.wait(2)
                    continue
                end
                
                -- Start raid
                Fluent:Notify({
                    Title = "Auto Raid",
                    Content = "Starting " .. selectedMode .. " Raid...",
                    Duration = 2
                })
                
                DebugPrint("Starting raid with mode:", selectedMode)
                StartRaid(selectedMode)
                task.wait(3)
                
                -- Verify we're in raid
                inRaid = IsInRaid()
                DebugPrint("After StartRaid, in raid:", inRaid)
                
                if not inRaid then
                    DebugPrint("Failed to start raid, retrying...")
                    task.wait(2)
                    continue
                end
                
                -- Wait for mobs to spawn
                DebugPrint("Waiting for raid mobs to spawn...")
                local mobsSpawned = WaitForRaidMob(15)
                
                if not mobsSpawned then
                    DebugPrint("Mobs did not spawn, checking raid status...")
                    task.wait(2)
                    continue
                end
                
                Fluent:Notify({
                    Title = "Auto Raid",
                    Content = "Raid started! Farming...",
                    Duration = 2
                })
            end
            
            -- Farm in raid
            local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"
            DebugPrint("Farm method:", method)
            
            while getgenv().EnzoScriptRunning and Options.AutoRaid.Value do
                -- Check if still in raid
                if not IsInRaid() then
                    DebugPrint("No longer in raid")
                    break
                end
                
                -- Check Auto Leave Wave
                if Options.AutoLeaveWave and Options.AutoLeaveWave.Value then
                    local leaveAtWave = tonumber(Options.LeaveWave and Options.LeaveWave.Value) or 0
                    local currentWave = GetCurrentWave()
                    
                    DebugPrint("Current wave:", currentWave, "Leave at:", leaveAtWave)
                    
                    if leaveAtWave > 0 and currentWave >= leaveAtWave then
                        DebugPrint("Reached wave", currentWave, "- Leaving raid...")
                        
                        Fluent:Notify({
                            Title = "Auto Raid",
                            Content = "Reached Wave " .. currentWave .. ". Leaving...",
                            Duration = 3
                        })
                        
                        LeaveRaid()
                        task.wait(2)
                        break
                    end
                end
                
                -- Find and attack enemies
                local mobsFolder = workspace:FindFirstChild("Mobs")
                
                if mobsFolder then
                    local targetMob, targetHRP = nil, nil
                    local nearestDist = math.huge
                    
                    for _, mob in pairs(mobsFolder:GetChildren()) do
                        if IsMobAlive(mob) then
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            if hrp and HumanoidRootPart and HumanoidRootPart.Parent then
                                local d = (HumanoidRootPart.Position - hrp.Position).Magnitude
                                if d < nearestDist then
                                    targetMob = mob
                                    targetHRP = hrp
                                    nearestDist = d
                                end
                            end
                        end
                    end
                    
                    if targetMob and targetHRP and IsMobAlive(targetMob) then
                        DebugPrint("Attacking:", GetEnemyName(targetMob) or targetMob.Name)
                        
                        currentTargetModel = targetMob
                        MoveToTargetByMethod(method, targetHRP)
                        ClickEnemy(targetMob)
                        
                        while getgenv().EnzoScriptRunning and Options.AutoRaid.Value and IsInRaid() and IsMobAlive(targetMob) and targetHRP.Parent do
                            -- Check Auto Leave Wave during combat
                            if Options.AutoLeaveWave and Options.AutoLeaveWave.Value then
                                local leaveAtWave = tonumber(Options.LeaveWave.Value) or 0
                                local currentWave = GetCurrentWave()
                                if leaveAtWave > 0 and currentWave >= leaveAtWave then
                                    DebugPrint("Leave wave reached during combat")
                                    break
                                end
                            end
                            
                            KeepPositionByMethod(method, targetHRP)
                            ClickEnemy(targetMob)
                            task.wait(0.2)
                        end
                        CleanupFarmState()
                    else
                        -- No mobs - wait for next wave
                        DebugPrint("No mobs found, waiting for next wave...")
                        task.wait(2)
                        
                        -- Wait for new mobs
                        local mobsSpawned = WaitForRaidMob(10)
                        if not mobsSpawned and not IsInRaid() then
                            DebugPrint("Raid ended")
                            break
                        end
                    end
                else
                    task.wait(1)
                end
                
                task.wait(0.3)
            end
            
            task.wait(1)
        else
            task.wait(0.3)
        end
    end
end))

-- ============================================
-- [[ AUTO LEAVE WAVE STANDALONE ]]
-- ============================================

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        -- Only run if Auto Leave Wave is ON but Auto Raid is OFF
        if Options.AutoLeaveWave and Options.AutoLeaveWave.Value then
            if not (Options.AutoRaid and Options.AutoRaid.Value) then
                if IsInRaid() then
                    local leaveAtWave = tonumber(Options.LeaveWave and Options.LeaveWave.Value) or 0
                    local currentWave = GetCurrentWave()
                    
                    if leaveAtWave > 0 and currentWave >= leaveAtWave then
                        DebugPrint("Standalone Leave: Reached wave", currentWave)
                        
                        Fluent:Notify({
                            Title = "Auto Leave Wave",
                            Content = "Reached Wave " .. currentWave .. ". Leaving raid...",
                            Duration = 3
                        })
                        
                        LeaveRaid()
                        task.wait(2)
                    end
                end
            end
        end
        task.wait(1)
    end
end))


-- [[ Main Tab: Level Stats ]]
local SectionStats = Tabs.Main:AddSection("Level Stats")
local SkillPointsLabel = Tabs.Main:AddParagraph({ Title = "Skill Points", Content = GetSkillPoints() })

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function() SkillPointsLabel:SetDesc(GetSkillPoints()) end)
    end
end)

local currentStatsList = GetStatsList()
local DropdownStats = Tabs.Main:AddDropdown("StatsSelect", {
    Title = "Select Stats",
    Description = "Choose stats to upgrade (multi select)",
    Values = currentStatsList,
    Multi = true,
    Default = {}
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetStatsList()
            local changed = #newList ~= #currentStatsList
            if not changed then for i, name in ipairs(newList) do if currentStatsList[i] ~= name then changed = true break end end end
            if changed then currentStatsList = newList DropdownStats:SetValues(newList) end
        end)
    end
end)

local ToggleAutoPutStat = Tabs.Main:AddToggle("AutoPutStat", { Title = "Auto Put Stat", Default = false })
task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoPutStat and Options.AutoPutStat.Value then
            pcall(function()
                if Options.StatsSelect then
                    for statName, isSelected in pairs(Options.StatsSelect.Value) do
                        if isSelected then GetKnitServices().LevelService.RF.PutStat:InvokeServer(statName, 1) end
                    end
                end
            end)
            task.wait(1)
        else task.wait(0.3) end
    end
end)

-- ============================================
-- [[ TIME TRIAL SYSTEM ]]
-- ============================================

-- ── Variables for Trial System ──
local isTrialActive = false
local pausedToggles = {}
local currentTrialName = nil

-- ── Trial Utility Functions ──

local function GetTrialList()
    local trials = {}
    pcall(function()
        local trialFolder = ReplicatedStorage:FindFirstChild("Gamemodes")
        if trialFolder then
            trialFolder = trialFolder:FindFirstChild("Time Trial")
            if trialFolder then
                for _, child in pairs(trialFolder:GetChildren()) do
                    if child:IsA("Folder") then
                        table.insert(trials, child.Name)
                    end
                end
            end
        end
    end)
    table.sort(trials)
    return trials
end

local function GetTrialAttributes(trialName)
    local attrs = {
        Current = nil,
        Timer = 0,
        Room = 0,
    }
    pcall(function()
        local trialFolder = ReplicatedStorage.Gamemodes["Time Trial"]:FindFirstChild(trialName)
        if trialFolder then
            attrs.Current = trialFolder:GetAttribute("Current")
            attrs.Timer = trialFolder:GetAttribute("Timer") or 0
            attrs.Room = trialFolder:GetAttribute("Room") or 0
        end
    end)
    return attrs
end

local function IsTrialNotificationVisible(trialName)
    local visible = false
    local canJoin = false
    local description = ""
    
    pcall(function()
        local notifications = LocalPlayer.PlayerGui:FindFirstChild("TrialJoin")
        if notifications then
            notifications = notifications:FindFirstChild("Canvas")
            if notifications then
                notifications = notifications:FindFirstChild("Notifications")
                if notifications then
                    local trialFrame = notifications:FindFirstChild(trialName)
                    if trialFrame and trialFrame.Visible then
                        visible = true
                        local desc = trialFrame:FindFirstChild("Description")
                        if desc then
                            description = desc.ContentText or desc.Text or ""
                            if string.find(description:lower(), "just started") then
                                canJoin = true
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return visible, canJoin, description
end

local function IsPlayerInTrial(trialName)
    local inTrial = false
    pcall(function()
        local trialFolder = ReplicatedStorage.Gamemodes["Time Trial"]:FindFirstChild(trialName)
        if trialFolder then
            local playersFolder = trialFolder:FindFirstChild("Players")
            if playersFolder then
                for _, child in pairs(playersFolder:GetChildren()) do
                    local childName = child.Name
                    local playerId = tostring(LocalPlayer.UserId)
                    
                    if childName == playerId then
                        inTrial = true
                        break
                    end
                    
                    if child:IsA("ValueBase") then
                        local val = tostring(child.Value)
                        if val == playerId then
                            inTrial = true
                            break
                        end
                    end
                end
            end
        end
    end)
    return inTrial
end

local function GetTrialPlayerCount(trialName)
    local count = 0
    pcall(function()
        local trialFolder = ReplicatedStorage.Gamemodes["Time Trial"]:FindFirstChild(trialName)
        if trialFolder then
            local playersFolder = trialFolder:FindFirstChild("Players")
            if playersFolder then
                count = #playersFolder:GetChildren()
            end
        end
    end)
    return count
end

local function JoinTrial(trialName)
    local success = false
    pcall(function()
        local result = GetKnitServices().TimeTrialService.RF.JoinTrial:InvokeServer(trialName)
        DebugPrint("JoinTrial:", trialName, "Result:", tostring(result))
        if result then
            success = true
        end
    end)
    return success
end

local function LeaveTrial()
    local success = false
    pcall(function()
        GetKnitServices().TimeTrialService.RF.LeaveTrial:InvokeServer()
        success = true
        DebugPrint("LeaveTrial: Success")
    end)
    return success
end

local function PauseOtherToggles()
    pausedToggles = {}
    
    local togglesToPause = {
        "AutoFarm", 
        "AutoFarmNearest", 
        "AutoQuest", 
        "AutoStar", 
        "AutoPrestige", 
        "AutoRankUp",
        "AutoCraftCollect"
    }
    
    for _, toggleName in ipairs(togglesToPause) do
        if Options[toggleName] then
            pausedToggles[toggleName] = Options[toggleName].Value
            if Options[toggleName].Value then
                Options[toggleName]:SetValue(false)
                DebugPrint("Paused toggle:", toggleName)
            end
        end
    end
    
    DebugPrint("Paused toggles saved")
end

local function ResumeOtherToggles()
    DebugPrint("Resuming paused toggles...")
    
    for toggleName, wasEnabled in pairs(pausedToggles) do
        if wasEnabled and Options[toggleName] then
            Options[toggleName]:SetValue(true)
            DebugPrint("Resumed toggle:", toggleName)
        end
    end
    
    pausedToggles = {}
end

local function FormatTrialStatus(trialName, attrs, inTrial)
    local lines = {}
    
    if not trialName or trialName == "" then
        table.insert(lines, "Select a trial from dropdown")
        return table.concat(lines, "\n")
    end
    
    table.insert(lines, "Trial: " .. trialName)
    table.insert(lines, "Current: " .. tostring(attrs.Current or "N/A"))
    table.insert(lines, "Timer: " .. tostring(attrs.Timer or 0) .. "s")
    table.insert(lines, "Room: " .. tostring(attrs.Room or 0))
    table.insert(lines, "")
    
    if inTrial then
        table.insert(lines, "Status: ✓ In Trial")
    else
        table.insert(lines, "Status: Not in Trial")
    end
    
    if isTrialActive then
        table.insert(lines, "Auto Trial: Active")
    end
    
    return table.concat(lines, "\n")
end

-- ============================================
-- [[ TRIAL UI SECTION ]]
-- ============================================

local SectionTrial = Tabs.Main:AddSection("Trial")

local currentTrialList = GetTrialList()
local DropdownTrial = Tabs.Main:AddDropdown("TrialSelect", {
    Title = "Select Trial",
    Description = "Choose trial difficulty",
    Values = currentTrialList,
    Multi = false,
    Default = nil
})

local TrialStatusLabel = Tabs.Main:AddParagraph({
    Title = "Trial Status",
    Content = "Select a trial from dropdown"
})

local InputLeaveAtRoom = Tabs.Main:AddInput("LeaveAtRoom", {
    Title = "Leave At Room",
    Description = "Auto leave when reaching this room (0 = disabled)",
    Default = "0",
    Placeholder = "Enter room number",
    Numeric = true,
    Finished = true
})

local ToggleAutoLeaveRoom = Tabs.Main:AddToggle("AutoLeaveRoom", {
    Title = "Auto Leave Room",
    Description = "Auto leave when reaching specified room",
    Default = false
})

local ToggleAutoTrial = Tabs.Main:AddToggle("AutoTrial", {
    Title = "Auto Trial",
    Description = "Auto join and farm trial when available",
    Default = false
})

-- Refresh trial list periodically
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetTrialList()
            local changed = #newList ~= #currentTrialList
            if not changed then
                for i, name in ipairs(newList) do
                    if currentTrialList[i] ~= name then 
                        changed = true 
                        break 
                    end
                end
            end
            if changed then
                currentTrialList = newList
                DropdownTrial:SetValues(newList)
            end
        end)
    end
end))

-- Update status label periodically
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(1)
        pcall(function()
            local selectedTrial = Options.TrialSelect and Options.TrialSelect.Value
            
            if selectedTrial and selectedTrial ~= "" then
                local attrs = GetTrialAttributes(selectedTrial)
                local inTrial = IsPlayerInTrial(selectedTrial)
                local statusText = FormatTrialStatus(selectedTrial, attrs, inTrial)
                TrialStatusLabel:SetDesc(statusText)
            else
                TrialStatusLabel:SetDesc("Select a trial from dropdown")
            end
        end)
    end
end))

-- Cleanup on toggle off
ToggleAutoTrial:OnChanged(function(value)
    if not value then
        if isTrialActive then
            isTrialActive = false
            ResumeOtherToggles()
            currentTrialName = nil
            
            Fluent:Notify({
                Title = "Auto Trial",
                Content = "Auto Trial disabled. Resumed other features.",
                Duration = 3
            })
        end
    end
end)

-- ============================================
-- [[ AUTO TRIAL MAIN LOOP ]]
-- ============================================

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoTrial and Options.AutoTrial.Value then
            local selectedTrial = Options.TrialSelect and Options.TrialSelect.Value
            
            if not selectedTrial or selectedTrial == "" then
                DebugPrint("No trial selected")
                task.wait(1)
                continue
            end
            
            currentTrialName = selectedTrial
            
            -- Get current trial status
            local attrs = GetTrialAttributes(selectedTrial)
            local inTrial = IsPlayerInTrial(selectedTrial)
            
            DebugPrint("=== Auto Trial Check ===")
            DebugPrint("Trial:", selectedTrial)
            DebugPrint("Current:", tostring(attrs.Current))
            DebugPrint("Timer:", tostring(attrs.Timer))
            DebugPrint("Room:", tostring(attrs.Room))
            DebugPrint("InTrial:", tostring(inTrial))
            
            -- Check if trial has ended
            if attrs.Current == "Ended" and attrs.Timer == 0 then
                DebugPrint("Trial ended, waiting for next round...")
                
                if isTrialActive then
                    isTrialActive = false
                    ResumeOtherToggles()
                    
                    Fluent:Notify({
                        Title = "Auto Trial",
                        Content = selectedTrial .. " Trial ended. Waiting for next round...",
                        Duration = 3
                    })
                end
                
                task.wait(2)
                continue
            end
            
            -- Check Auto Leave Room
            if Options.AutoLeaveRoom and Options.AutoLeaveRoom.Value then
                local leaveAtRoom = tonumber(Options.LeaveAtRoom and Options.LeaveAtRoom.Value) or 0
                
                if leaveAtRoom > 0 and inTrial then
                    local currentRoom = attrs.Room or 0
                    
                    if currentRoom >= leaveAtRoom then
                        DebugPrint("Auto Leave: Reached room", currentRoom, "- Leaving trial...")
                        
                        Fluent:Notify({
                            Title = "Auto Trial",
                            Content = "Reached Room " .. currentRoom .. ". Auto leaving...",
                            Duration = 3
                        })
                        
                        LeaveTrial()
                        task.wait(2)
                        
                        if isTrialActive then
                            isTrialActive = false
                            ResumeOtherToggles()
                        end
                        
                        continue
                    end
                end
            end
            
            -- If already in trial, farm enemies
            if inTrial then
                if not isTrialActive then
                    isTrialActive = true
                    PauseOtherToggles()
                    
                    Fluent:Notify({
                        Title = "Auto Trial",
                        Content = "Joined " .. selectedTrial .. " Trial! Farming enemies...",
                        Duration = 3
                    })
                end
                
                -- Farm enemies
                local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"
                local mobsFolder = workspace:FindFirstChild("Mobs")
                
                if mobsFolder then
                    local nearestMob, nearestHRP = nil, nil
                    local nearestDist = math.huge
                    
                    for _, mob in pairs(mobsFolder:GetChildren()) do
                        if IsMobAlive(mob) then
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            if hrp and HumanoidRootPart and HumanoidRootPart.Parent then
                                local d = (HumanoidRootPart.Position - hrp.Position).Magnitude
                                if d < nearestDist then
                                    nearestMob = mob
                                    nearestHRP = hrp
                                    nearestDist = d
                                end
                            end
                        end
                    end
                    
                    if nearestMob and nearestHRP and IsMobAlive(nearestMob) then
                        currentTargetModel = nearestMob
                        isMovingToTarget = true
                        MoveToTargetByMethod(method, nearestHRP)
                        
                        isMovingToTarget = false
                        isFarmingTarget = true
                        ClickEnemy(nearestMob)
                        
                        while getgenv().EnzoScriptRunning and 
                              Options.AutoTrial.Value and 
                              IsMobAlive(nearestMob) and 
                              nearestHRP.Parent do
                            
                            -- Check if still in trial
                            if not IsPlayerInTrial(selectedTrial) then
                                DebugPrint("No longer in trial")
                                break
                            end
                            
                            -- Check Auto Leave Room during combat
                            if Options.AutoLeaveRoom and Options.AutoLeaveRoom.Value then
                                local leaveAtRoom = tonumber(Options.LeaveAtRoom.Value) or 0
                                local currentAttrs = GetTrialAttributes(selectedTrial)
                                
                                if leaveAtRoom > 0 and currentAttrs.Room >= leaveAtRoom then
                                    DebugPrint("Reached leave room during combat")
                                    break
                                end
                                
                                -- Check if ended during combat
                                if currentAttrs.Current == "Ended" and currentAttrs.Timer == 0 then
                                    DebugPrint("Trial ended during combat")
                                    break
                                end
                            end
                            
                            KeepPositionByMethod(method, nearestHRP)
                            ClickEnemy(nearestMob)
                            task.wait(0.2)
                        end
                        
                        CleanupFarmState()
                    end
                end
                
                task.wait(0.3)
            else
                -- Not in trial - check if we can join
                local visible, canJoin, description = IsTrialNotificationVisible(selectedTrial)
                
                DebugPrint("Notification visible:", visible, "CanJoin:", canJoin, "Desc:", description)
                
                if visible and canJoin then
                    DebugPrint("Trial available! Joining:", selectedTrial)
                    
                    Fluent:Notify({
                        Title = "Auto Trial",
                        Content = selectedTrial .. " Trial starting! Joining...",
                        Duration = 3
                    })
                    
                    if not isTrialActive then
                        PauseOtherToggles()
                    end
                    
                    JoinTrial(selectedTrial)
                    task.wait(1)
                    
                    if IsPlayerInTrial(selectedTrial) then
                        isTrialActive = true
                        DebugPrint("Successfully joined trial!")
                        
                        Fluent:Notify({
                            Title = "Auto Trial",
                            Content = "Successfully joined " .. selectedTrial .. " Trial!",
                            Duration = 3
                        })
                    else
                        DebugPrint("Failed to join trial")
                        
                        Fluent:Notify({
                            Title = "Auto Trial",
                            Content = "Failed to join trial. Retrying...",
                            Duration = 2
                        })
                        
                        if isTrialActive then
                            isTrialActive = false
                            ResumeOtherToggles()
                        end
                    end
                else
                    if isTrialActive then
                        isTrialActive = false
                        ResumeOtherToggles()
                        
                        Fluent:Notify({
                            Title = "Auto Trial",
                            Content = "Left trial. Waiting for next round...",
                            Duration = 3
                        })
                    end
                    
                    DebugPrint("Waiting for trial notification...")
                    task.wait(1)
                end
            end
            
            task.wait(0.5)
        else
            if isTrialActive then
                isTrialActive = false
                ResumeOtherToggles()
                currentTrialName = nil
            end
            task.wait(0.3)
        end
    end
end))

-- ============================================
-- [[ AUTO LEAVE ROOM STANDALONE (when Auto Trial is OFF) ]]
-- ============================================

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        -- Only run if Auto Leave Room is ON but Auto Trial is OFF
        if Options.AutoLeaveRoom and Options.AutoLeaveRoom.Value then
            if not (Options.AutoTrial and Options.AutoTrial.Value) then
                local selectedTrial = Options.TrialSelect and Options.TrialSelect.Value
                
                if selectedTrial and selectedTrial ~= "" then
                    local attrs = GetTrialAttributes(selectedTrial)
                    local inTrial = IsPlayerInTrial(selectedTrial)
                    local leaveAtRoom = tonumber(Options.LeaveAtRoom and Options.LeaveAtRoom.Value) or 0
                    
                    if leaveAtRoom > 0 and inTrial then
                        local currentRoom = attrs.Room or 0
                        
                        if currentRoom >= leaveAtRoom then
                            DebugPrint("Standalone Auto Leave: Reached room", currentRoom)
                            
                            Fluent:Notify({
                                Title = "Auto Leave Room",
                                Content = "Reached Room " .. currentRoom .. ". Leaving trial...",
                                Duration = 3
                            })
                            
                            LeaveTrial()
                            task.wait(2)
                        end
                    end
                end
            end
        end
        
        task.wait(1)
    end
end))



-- [[ Star Tab ]]
local SectionStar = Tabs.Star:AddSection("Star Feature")
local currentStarList = GetStarList()
local DropdownStar = Tabs.Star:AddDropdown("StarSelect", {
    Title = "Select Star",
    Description = "Choose which star to open",
    Values = currentStarList,
    Multi = false,
    Default = nil
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function()
            local newList = GetStarList()
            local changed = #newList ~= #currentStarList
            if not changed then for i, name in ipairs(newList) do if currentStarList[i] ~= name then changed = true break end end end
            if changed then currentStarList = newList DropdownStar:SetValues(newList) end
        end)
    end
end)

local DropdownHowMany = Tabs.Star:AddDropdown("HowManySelect", {
    Title = "How Many",
    Description = "Number of stars to open at once",
    Values = {"1", "2", "4"},
    Multi = false,
    Default = "1"
})

local ToggleAutoStar = Tabs.Star:AddToggle("AutoStar", { Title = "Auto Star", Default = false })

task.spawn(function()
    local hasTeleportedToStar = false
    local lastStarName = nil
    
    while getgenv().EnzoScriptRunning do
        if Options.AutoStar and Options.AutoStar.Value then
            pcall(function()
                local selectedStar = Options.StarSelect and Options.StarSelect.Value
                local howMany = tonumber(Options.HowManySelect and Options.HowManySelect.Value) or 1
                if selectedStar and selectedStar ~= "" then
                    -- Teleport only once, or when star selection changes
                    if not hasTeleportedToStar or lastStarName ~= selectedStar then
                        TeleportToStar(selectedStar)
                        hasTeleportedToStar = true
                        lastStarName = selectedStar
                        task.wait(0.3)
                    end
                    GetKnitServices().StarService.RF.OpenStar:InvokeServer(selectedStar, howMany)
                end
            end)
            task.wait(0.1)
        else
            hasTeleportedToStar = false
            task.wait(0.1)
        end
    end
end)


-- [[ Misc Tab: Avatar Leveling ]]
local SectionAvatar = Tabs.Misc:AddSection("Avatar Leveling")
local currentAvatarList = GetAvatarList()
local DropdownAvatar = Tabs.Misc:AddDropdown("AvatarSelect", {
    Title = "Select Avatar",
    Description = "Choose avatar to equip or level up",
    Values = currentAvatarList,
    Multi = false,
    Default = nil
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetAvatarList()
            local changed = #newList ~= #currentAvatarList
            if not changed then for i, name in ipairs(newList) do if currentAvatarList[i] ~= name then changed = true break end end end
            if changed then currentAvatarList = newList DropdownAvatar:SetValues(newList) end
        end)
    end
end)

DropdownAvatar:OnChanged(function(value)
    if value and value ~= "" then
        pcall(function()
            GetKnitServices().AvatarService.RF.EquipAvatar:InvokeServer(value)
            Fluent:Notify({ Title = "Avatar", Content = "Equip/Unequip: " .. value, Duration = 2 })
        end)
    end
end)

local ToggleAutoLevelUp = Tabs.Misc:AddToggle("AutoLevelUp", { Title = "Auto Level Up Avatar", Default = false })
task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoLevelUp and Options.AutoLevelUp.Value then
            pcall(function()
                local selectedAvatar = Options.AvatarSelect and Options.AvatarSelect.Value
                if selectedAvatar and selectedAvatar ~= "" then GetKnitServices().AvatarService.RF.LevelUp:InvokeServer(selectedAvatar) end
            end)
            task.wait(1)
        else task.wait(0.3) end
    end
end)

-- [[ Misc Tab: Avatar Stats ]]
local SectionAvatarStats = Tabs.Misc:AddSection("Avatar Stats")
local AvatarShardLabel = Tabs.Misc:AddParagraph({ Title = "Avatar Shard", Content = GetAvatarShardAmount() })

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function() AvatarShardLabel:SetDesc(GetAvatarShardAmount()) end)
    end
end)

local currentAvatarList2 = GetAvatarList()
local DropdownAvatarStats = Tabs.Misc:AddDropdown("AvatarStatsSelect", {
    Title = "Select Avatar",
    Description = "Choose avatar to roll stats for",
    Values = currentAvatarList2,
    Multi = false,
    Default = nil
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetAvatarList()
            local changed = #newList ~= #currentAvatarList2
            if not changed then for i, name in ipairs(newList) do if currentAvatarList2[i] ~= name then changed = true break end end end
            if changed then currentAvatarList2 = newList DropdownAvatarStats:SetValues(newList) end
        end)
    end
end)

local currentAvatarStatsList = GetAvatarStatsList()
local DropdownAvatarStatsName = Tabs.Misc:AddDropdown("AvatarStatsNameSelect", {
    Title = "Select Stats",
    Description = "Choose stats to roll (multi select)",
    Values = currentAvatarStatsList,
    Multi = true,
    Default = {}
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetAvatarStatsList()
            local changed = #newList ~= #currentAvatarStatsList
            if not changed then for i, name in ipairs(newList) do if currentAvatarStatsList[i] ~= name then changed = true break end end end
            if changed then currentAvatarStatsList = newList DropdownAvatarStatsName:SetValues(newList) end
        end)
    end
end)

local DropdownGrade = Tabs.Misc:AddDropdown("GradeSelect", {
    Title = "Target Grade",
    Description = "Choose desired grade(s) to stop rolling (multi select)",
    Values = {"S", "A", "B", "C", "D", "E"},
    Multi = true,
    Default = {}
})

local ToggleAutoRollStats = Tabs.Misc:AddToggle("AutoRollStats", { Title = "Auto Roll Stats", Default = false })
task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoRollStats and Options.AutoRollStats.Value then
            pcall(function()
                local selectedAvatar = Options.AvatarStatsSelect and Options.AvatarStatsSelect.Value
                local selectedStats = Options.AvatarStatsNameSelect and Options.AvatarStatsNameSelect.Value
                local selectedGrades = Options.GradeSelect and Options.GradeSelect.Value
                
                if not selectedAvatar or selectedAvatar == "" then task.wait(0.5) return end
                if not selectedStats or not selectedGrades then task.wait(0.5) return end
                
                if CheckAllStatsGrades(selectedStats, selectedGrades) then
                    Fluent:Notify({ Title = "Auto Roll Stats", Content = "All selected stats have reached desired grade!", Duration = 3 })
                    Options.AutoRollStats:SetValue(false)
                    return
                end
                
                for statName, isSelected in pairs(selectedStats) do
                    if isSelected then
                        local currentGrade = GetAvatarStatGrade(statName)
                        local gradeMatch = false
                        if currentGrade and selectedGrades then for grade, isGradeSelected in pairs(selectedGrades) do if isGradeSelected and currentGrade == grade then gradeMatch = true break end end end
                        if not gradeMatch then GetKnitServices().AvatarService.RF.RollStat:InvokeServer(selectedAvatar, statName) end
                    end
                end
            end)
            task.wait(0.5)
        else task.wait(0.3) end
    end
end)

-- [[ Misc Tab: Saiyan Reroll ]]
local SectionSaiyanReroll = Tabs.Misc:AddSection("Saiyan Reroll")
local SaiyanTokenLabel = Tabs.Misc:AddParagraph({ Title = "Saiyan Token", Content = GetSaiyanTokenAmount() })

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function() SaiyanTokenLabel:SetDesc(GetSaiyanTokenAmount()) end)
    end
end)

-- Track previous rarity selections to detect changes
local previousSaiyanRarityState = {}

local DropdownSaiyanRarity = Tabs.Misc:AddDropdown("SaiyanRaritySelect", {
    Title = "Select Rarity",
    Description = "Toggle rarity filter for Saiyan reroll (multi select)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"},
    Multi = true,
    Default = {}
})

DropdownSaiyanRarity:OnChanged(function(value)
    -- Detect which rarities changed and toggle them
    for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"}) do
        local currentState = value[rarity] or false
        local prevState = previousSaiyanRarityState[rarity] or false
        
        if currentState ~= prevState then
            -- State changed for this rarity, call ToggleRarity
            DebugPrint("Saiyan Rarity Toggled:", rarity, "New State:", tostring(currentState))
            ToggleSaiyanRarity(rarity)
        end
    end
    
    -- Update previous state
    previousSaiyanRarityState = {}
    for rarity, state in pairs(value) do
        previousSaiyanRarityState[rarity] = state
    end
end)

local ToggleAutoSaiyanRoll = Tabs.Misc:AddToggle("AutoSaiyanRoll", {
    Title = "Auto Roll Saiyan",
    Description = "Rolls until result matches selected rarity, then stops",
    Default = false
})

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoSaiyanRoll and Options.AutoSaiyanRoll.Value then
            pcall(function()
                -- Get desired rarities
                local selectedRarities = Options.SaiyanRaritySelect and Options.SaiyanRaritySelect.Value
                if not selectedRarities then task.wait(0.5) return end
                
                local hasSelection = false
                for _, isSelected in pairs(selectedRarities) do
                    if isSelected then hasSelection = true break end
                end
                
                if not hasSelection then
                    DebugPrint("No rarity selected for Saiyan Roll")
                    task.wait(0.5)
                    return
                end
                
                -- Get current result before rolling (to detect change)
                local prevResult = GetSaiyanRollResult()
                
                -- Perform reroll
                RerollSaiyan()
                task.wait(1) -- Wait for roll animation/result
                
                -- Get new result
                local newResult = GetSaiyanRollResult()
                DebugPrint("Saiyan Roll Result:", tostring(newResult))
                
                if newResult and newResult ~= "" then
                    -- Look up the rarity of the result in the list
                    local resultRarity = GetSaiyanItemRarity(newResult)
                    DebugPrint("Result Rarity:", tostring(resultRarity))
                    
                    if resultRarity and resultRarity ~= "" then
                        -- Check if result rarity matches any selected rarity
                        local matched = false
                        for rarityName, isSelected in pairs(selectedRarities) do
                            if isSelected then
                                -- Case-insensitive comparison
                                if string.lower(resultRarity) == string.lower(rarityName) or
                                   string.find(string.lower(resultRarity), string.lower(rarityName)) or
                                   string.find(string.lower(rarityName), string.lower(resultRarity)) then
                                    matched = true
                                    break
                                end
                            end
                        end
                        
                        if matched then
                            Fluent:Notify({
                                Title = "Saiyan Reroll",
                                Content = "Got " .. newResult .. " (" .. resultRarity .. ")! Stopping.",
                                Duration = 5
                            })
                            Options.AutoSaiyanRoll:SetValue(false)
                            return
                        else
                            DebugPrint("Rarity not matched, continuing... Got:", newResult, "Rarity:", resultRarity)
                        end
                    else
                        DebugPrint("Could not determine rarity for:", newResult)
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end)

-- [[ Misc Tab: Dragon Reroll ]]
local SectionDragonReroll = Tabs.Misc:AddSection("Dragon Reroll")
local DragonTokenLabel = Tabs.Misc:AddParagraph({ Title = "Dragon Token", Content = GetDragonTokenAmount() })

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function() DragonTokenLabel:SetDesc(GetDragonTokenAmount()) end)
    end
end))

local previousDragonRarityState = {}

local DropdownDragonRarity = Tabs.Misc:AddDropdown("DragonRaritySelect", {
    Title = "Select Rarity",
    Description = "Toggle rarity filter for Dragon reroll (multi select)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"},
    Multi = true,
    Default = {}
})

DropdownDragonRarity:OnChanged(function(value)
    for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"}) do
        local currentState = value[rarity] or false
        local prevState = previousDragonRarityState[rarity] or false
        
        if currentState ~= prevState then
            DebugPrint("Dragon Rarity Toggled:", rarity, "New State:", tostring(currentState))
            ToggleDragonRarity(rarity)
        end
    end
    
    previousDragonRarityState = {}
    for rarity, state in pairs(value) do
        previousDragonRarityState[rarity] = state
    end
end)

local ToggleAutoDragonRoll = Tabs.Misc:AddToggle("AutoDragonRoll", {
    Title = "Auto Roll Dragon",
    Description = "Rolls until result matches selected rarity, then stops",
    Default = false
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoDragonRoll and Options.AutoDragonRoll.Value then
            pcall(function()
                local selectedRarities = Options.DragonRaritySelect and Options.DragonRaritySelect.Value
                if not selectedRarities then task.wait(0.5) return end
                
                local hasSelection = false
                for _, isSelected in pairs(selectedRarities) do
                    if isSelected then hasSelection = true break end
                end
                
                if not hasSelection then
                    DebugPrint("No rarity selected for Dragon Roll")
                    task.wait(0.5)
                    return
                end
                
                RerollDragon()
                task.wait(1)
                
                local newResult = GetSaiyanRollResult() -- Same UI path, changes based on which NPC UI is open
                DebugPrint("Dragon Roll Result:", tostring(newResult))
                
                if newResult and newResult ~= "" then
                    local resultRarity = GetSaiyanItemRarity(newResult) -- Same UI path for rarity lookup
                    DebugPrint("Dragon Result Rarity:", tostring(resultRarity))
                    
                    if resultRarity and resultRarity ~= "" then
                        local matched = false
                        for rarityName, isSelected in pairs(selectedRarities) do
                            if isSelected then
                                if string.lower(resultRarity) == string.lower(rarityName) or
                                   string.find(string.lower(resultRarity), string.lower(rarityName)) or
                                   string.find(string.lower(rarityName), string.lower(resultRarity)) then
                                    matched = true
                                    break
                                end
                            end
                        end
                        
                        if matched then
                            Fluent:Notify({
                                Title = "Dragon Reroll",
                                Content = "Got " .. newResult .. " (" .. resultRarity .. ")! Stopping.",
                                Duration = 5
                            })
                            Options.AutoDragonRoll:SetValue(false)
                            return
                        else
                            DebugPrint("Dragon rarity not matched, continuing... Got:", newResult, "Rarity:", resultRarity)
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end))

-- [[ Misc Tab: Chakra Reroll ]]
local SectionChakraReroll = Tabs.Misc:AddSection("Chakra Reroll")
local ChakraTokenLabel = Tabs.Misc:AddParagraph({ Title = "Chakra Token", Content = GetChakraTokenAmount() })

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function() ChakraTokenLabel:SetDesc(GetChakraTokenAmount()) end)
    end
end))

local previousChakraRarityState = {}

local DropdownChakraRarity = Tabs.Misc:AddDropdown("ChakraRaritySelect", {
    Title = "Select Rarity",
    Description = "Toggle rarity filter for Chakra reroll (multi select)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"},
    Multi = true,
    Default = {}
})

DropdownChakraRarity:OnChanged(function(value)
    for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"}) do
        local currentState = value[rarity] or false
        local prevState = previousChakraRarityState[rarity] or false
        
        if currentState ~= prevState then
            DebugPrint("Chakra Rarity Toggled:", rarity, "New State:", tostring(currentState))
            ToggleSaiyanRarity(rarity) -- Same ToggleRarity function
        end
    end
    
    previousChakraRarityState = {}
    for rarity, state in pairs(value) do
        previousChakraRarityState[rarity] = state
    end
end)

local ToggleAutoChakraRoll = Tabs.Misc:AddToggle("AutoChakraRoll", {
    Title = "Auto Roll Chakra",
    Description = "Rolls until result matches selected rarity, then stops",
    Default = false
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoChakraRoll and Options.AutoChakraRoll.Value then
            pcall(function()
                local selectedRarities = Options.ChakraRaritySelect and Options.ChakraRaritySelect.Value
                if not selectedRarities then task.wait(0.5) return end
                
                local hasSelection = false
                for _, isSelected in pairs(selectedRarities) do
                    if isSelected then hasSelection = true break end
                end
                
                if not hasSelection then
                    DebugPrint("No rarity selected for Chakra Roll")
                    task.wait(0.5)
                    return
                end
                
                RerollChakra()
                task.wait(1)
                
                local newResult = GetSaiyanRollResult()
                DebugPrint("Chakra Roll Result:", tostring(newResult))
                
                if newResult and newResult ~= "" then
                    local resultRarity = GetSaiyanItemRarity(newResult)
                    DebugPrint("Chakra Result Rarity:", tostring(resultRarity))
                    
                    if resultRarity and resultRarity ~= "" then
                        local matched = false
                        for rarityName, isSelected in pairs(selectedRarities) do
                            if isSelected then
                                if string.lower(resultRarity) == string.lower(rarityName) or
                                   string.find(string.lower(resultRarity), string.lower(rarityName)) or
                                   string.find(string.lower(rarityName), string.lower(resultRarity)) then
                                    matched = true
                                    break
                                end
                            end
                        end
                        
                        if matched then
                            Fluent:Notify({
                                Title = "Chakra Reroll",
                                Content = "Got " .. newResult .. " (" .. resultRarity .. ")! Stopping.",
                                Duration = 5
                            })
                            Options.AutoChakraRoll:SetValue(false)
                            return
                        else
                            DebugPrint("Chakra rarity not matched, continuing... Got:", newResult, "Rarity:", resultRarity)
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end))

-- [[ Misc Tab: Jinchuriki Reroll ]]
local SectionJinchurikiReroll = Tabs.Misc:AddSection("Jinchuriki Reroll")
local JinchurikiTokenLabel = Tabs.Misc:AddParagraph({ Title = "Jinchuriki Token", Content = GetJinchurikiTokenAmount() })

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function() JinchurikiTokenLabel:SetDesc(GetJinchurikiTokenAmount()) end)
    end
end))

local previousJinchurikiRarityState = {}

local DropdownJinchurikiRarity = Tabs.Misc:AddDropdown("JinchurikiRaritySelect", {
    Title = "Select Rarity",
    Description = "Toggle rarity filter for Jinchuriki reroll (multi select)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"},
    Multi = true,
    Default = {}
})

DropdownJinchurikiRarity:OnChanged(function(value)
    for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"}) do
        local currentState = value[rarity] or false
        local prevState = previousJinchurikiRarityState[rarity] or false
        
        if currentState ~= prevState then
            DebugPrint("Jinchuriki Rarity Toggled:", rarity, "New State:", tostring(currentState))
            ToggleSaiyanRarity(rarity)
        end
    end
    
    previousJinchurikiRarityState = {}
    for rarity, state in pairs(value) do
        previousJinchurikiRarityState[rarity] = state
    end
end)

local ToggleAutoJinchurikiRoll = Tabs.Misc:AddToggle("AutoJinchurikiRoll", {
    Title = "Auto Roll Jinchuriki",
    Description = "Rolls until result matches selected rarity, then stops",
    Default = false
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoJinchurikiRoll and Options.AutoJinchurikiRoll.Value then
            pcall(function()
                local selectedRarities = Options.JinchurikiRaritySelect and Options.JinchurikiRaritySelect.Value
                if not selectedRarities then task.wait(0.5) return end
                
                local hasSelection = false
                for _, isSelected in pairs(selectedRarities) do
                    if isSelected then hasSelection = true break end
                end
                
                if not hasSelection then
                    DebugPrint("No rarity selected for Jinchuriki Roll")
                    task.wait(0.5)
                    return
                end
                
                RerollJinchuriki()
                task.wait(1)
                
                local newResult = GetSaiyanRollResult()
                DebugPrint("Jinchuriki Roll Result:", tostring(newResult))
                
                if newResult and newResult ~= "" then
                    local resultRarity = GetSaiyanItemRarity(newResult)
                    DebugPrint("Jinchuriki Result Rarity:", tostring(resultRarity))
                    
                    if resultRarity and resultRarity ~= "" then
                        local matched = false
                        for rarityName, isSelected in pairs(selectedRarities) do
                            if isSelected then
                                if string.lower(resultRarity) == string.lower(rarityName) or
                                   string.find(string.lower(resultRarity), string.lower(rarityName)) or
                                   string.find(string.lower(rarityName), string.lower(resultRarity)) then
                                    matched = true
                                    break
                                end
                            end
                        end
                        
                        if matched then
                            Fluent:Notify({
                                Title = "Jinchuriki Reroll",
                                Content = "Got " .. newResult .. " (" .. resultRarity .. ")! Stopping.",
                                Duration = 5
                            })
                            Options.AutoJinchurikiRoll:SetValue(false)
                            return
                        else
                            DebugPrint("Jinchuriki rarity not matched, continuing... Got:", newResult, "Rarity:", resultRarity)
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end))

-- [[ Misc Tab: Haki Reroll ]]
local SectionHakiReroll = Tabs.Misc:AddSection("Haki Reroll")
local HakiTokenLabel = Tabs.Misc:AddParagraph({ Title = "Haki Token", Content = GetHakiTokenAmount() })

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function() HakiTokenLabel:SetDesc(GetHakiTokenAmount()) end)
    end
end))

local previousHakiRarityState = {}

local DropdownHakiRarity = Tabs.Misc:AddDropdown("HakiRaritySelect", {
    Title = "Select Rarity",
    Description = "Toggle rarity filter for Haki reroll (multi select)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"},
    Multi = true,
    Default = {}
})

DropdownHakiRarity:OnChanged(function(value)
    for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"}) do
        local currentState = value[rarity] or false
        local prevState = previousHakiRarityState[rarity] or false
        
        if currentState ~= prevState then
            DebugPrint("Haki Rarity Toggled:", rarity, "New State:", tostring(currentState))
            ToggleSaiyanRarity(rarity)
        end
    end
    
    previousHakiRarityState = {}
    for rarity, state in pairs(value) do
        previousHakiRarityState[rarity] = state
    end
end)

local ToggleAutoHakiRoll = Tabs.Misc:AddToggle("AutoHakiRoll", {
    Title = "Auto Roll Haki",
    Description = "Rolls until result matches selected rarity, then stops",
    Default = false
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoHakiRoll and Options.AutoHakiRoll.Value then
            pcall(function()
                local selectedRarities = Options.HakiRaritySelect and Options.HakiRaritySelect.Value
                if not selectedRarities then task.wait(0.5) return end
                
                local hasSelection = false
                for _, isSelected in pairs(selectedRarities) do
                    if isSelected then hasSelection = true break end
                end
                
                if not hasSelection then
                    DebugPrint("No rarity selected for Haki Roll")
                    task.wait(0.5)
                    return
                end
                
                RerollHaki()
                task.wait(1)
                
                local newResult = GetSaiyanRollResult()
                DebugPrint("Haki Roll Result:", tostring(newResult))
                
                if newResult and newResult ~= "" then
                    local resultRarity = GetSaiyanItemRarity(newResult)
                    DebugPrint("Haki Result Rarity:", tostring(resultRarity))
                    
                    if resultRarity and resultRarity ~= "" then
                        local matched = false
                        for rarityName, isSelected in pairs(selectedRarities) do
                            if isSelected then
                                if string.lower(resultRarity) == string.lower(rarityName) or
                                   string.find(string.lower(resultRarity), string.lower(rarityName)) or
                                   string.find(string.lower(rarityName), string.lower(resultRarity)) then
                                    matched = true
                                    break
                                end
                            end
                        end
                        
                        if matched then
                            Fluent:Notify({
                                Title = "Haki Reroll",
                                Content = "Got " .. newResult .. " (" .. resultRarity .. ")! Stopping.",
                                Duration = 5
                            })
                            Options.AutoHakiRoll:SetValue(false)
                            return
                        else
                            DebugPrint("Haki rarity not matched, continuing... Got:", newResult, "Rarity:", resultRarity)
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end))

-- [[ Misc Tab: Trait Reroll ]]
local SectionTraitReroll = Tabs.Misc:AddSection("Trait Reroll")
local TraitTokenLabel = Tabs.Misc:AddParagraph({ Title = "Trait Token", Content = GetTraitTokenAmount() })

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function() TraitTokenLabel:SetDesc(GetTraitTokenAmount()) end)
    end
end))

-- Unit Dropdown
local currentUnitList = GetUnitList()
local DropdownTraitUnit = Tabs.Misc:AddDropdown("TraitUnitSelect", {
    Title = "Select Unit",
    Description = "Choose unit to roll traits for",
    Values = currentUnitList,
    Multi = false,
    Default = nil
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetUnitList()
            local changed = #newList ~= #currentUnitList
            if not changed then
                for i, name in ipairs(newList) do
                    if currentUnitList[i] ~= name then changed = true break end
                end
            end
            if changed then
                currentUnitList = newList
                DropdownTraitUnit:SetValues(newList)
            end
        end)
    end
end))

-- Trait Dropdown (multi select, toggles on select/unselect)
local currentTraitList = GetTraitList()
local previousTraitState = {}

local DropdownTraitSelect = Tabs.Misc:AddDropdown("TraitSelect", {
    Title = "Select Traits",
    Description = "Choose desired traits to stop rolling (multi select)",
    Values = currentTraitList,
    Multi = true,
    Default = {}
})

DropdownTraitSelect:OnChanged(function(value)
    for _, traitName in ipairs(currentTraitList) do
        local currentState = value[traitName] or false
        local prevState = previousTraitState[traitName] or false
        
        if currentState ~= prevState then
            DebugPrint("Trait Toggled:", traitName, "New State:", tostring(currentState))
            ToggleTrait(traitName)
        end
    end
    
    previousTraitState = {}
    for traitName, state in pairs(value) do
        previousTraitState[traitName] = state
    end
end)

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetTraitList()
            local changed = #newList ~= #currentTraitList
            if not changed then
                for i, name in ipairs(newList) do
                    if currentTraitList[i] ~= name then changed = true break end
                end
            end
            if changed then
                currentTraitList = newList
                DropdownTraitSelect:SetValues(newList)
            end
        end)
    end
end))

-- Auto Roll Trait Toggle
local ToggleAutoTraitRoll = Tabs.Misc:AddToggle("AutoTraitRoll", {
    Title = "Auto Roll Trait",
    Description = "Rolls until result matches selected trait(s), then stops",
    Default = false
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoTraitRoll and Options.AutoTraitRoll.Value then
            local selectedUnit = Options.TraitUnitSelect and Options.TraitUnitSelect.Value
            if not selectedUnit or selectedUnit == "" then
                DebugPrint("No unit selected for Trait Roll")
                task.wait(0.5)
                continue
            end
            
            -- Get frameId from mapping directly
            local cachedFrameId = unitDisplayToFrameId[selectedUnit]
            
            if not cachedFrameId then
                DebugPrint("Could not find frame ID for unit:", selectedUnit)
                DebugPrint("Current mapping:")
                for k, v in pairs(unitDisplayToFrameId) do
                    DebugPrint("  ", k, "->", v)
                end
                Fluent:Notify({
                    Title = "Trait Reroll",
                    Content = "Unit not found: " .. selectedUnit,
                    Duration = 3
                })
                Options.AutoTraitRoll:SetValue(false)
                continue
            end
            
            -- Verify: check what unit this frameId actually points to
            local verifiedUnit = nil
            pcall(function()
                local listFrame = LocalPlayer.PlayerGui.Main.Canvas.Units.Main.List
                local frame = listFrame:FindFirstChild(cachedFrameId)
                if frame then
                    local button = frame:FindFirstChild("Button")
                    if button then
                        local unitLabel = button:FindFirstChild("Unit")
                        if unitLabel then
                            verifiedUnit = unitLabel.ContentText or unitLabel.Text or ""
                        end
                    end
                end
            end)
            
            DebugPrint("Trait Roll: Selected:", selectedUnit)
            DebugPrint("Trait Roll: Locked frameId:", cachedFrameId)
            DebugPrint("Trait Roll: Verified unit name:", tostring(verifiedUnit))
            
            Fluent:Notify({
                Title = "Trait Reroll",
                Content = "Rolling for: " .. selectedUnit .. "\nID: " .. cachedFrameId .. "\nVerified: " .. tostring(verifiedUnit),
                Duration = 4
            })
            
            while getgenv().EnzoScriptRunning and Options.AutoTraitRoll and Options.AutoTraitRoll.Value do
                local shouldStop = false
                
                pcall(function()
                    local selectedTraits = Options.TraitSelect and Options.TraitSelect.Value
                    if not selectedTraits then return end
                    
                    local hasSelection = false
                    for _, isSelected in pairs(selectedTraits) do
                        if isSelected then hasSelection = true break end
                    end
                    
                    if not hasSelection then
                        DebugPrint("No traits selected for Trait Roll")
                        shouldStop = true
                        return
                    end
                    
                    local currentTrait = GetCurrentTraitResult()
                    DebugPrint("Current trait before roll:", tostring(currentTrait))
                    
                    if currentTrait and currentTrait ~= "" then
                        for traitName, isSelected in pairs(selectedTraits) do
                            if isSelected and currentTrait == traitName then
                                Fluent:Notify({
                                    Title = "Trait Reroll",
                                    Content = "Got desired trait: " .. currentTrait .. "! Stopping.",
                                    Duration = 5
                                })
                                shouldStop = true
                                return
                            end
                        end
                    end
                    
                    -- Only send the exact cachedFrameId
                    DebugPrint("Sending Roll with EXACT frameId:", cachedFrameId)
                    GetKnitServices().TraitService.RF.Roll:InvokeServer(cachedFrameId)
                end)
                
                if shouldStop then
                    Options.AutoTraitRoll:SetValue(false)
                    break
                end
                
                task.wait(1)
                
                pcall(function()
                    local selectedTraits = Options.TraitSelect and Options.TraitSelect.Value
                    if not selectedTraits then return end
                    
                    local newTrait = GetCurrentTraitResult()
                    DebugPrint("Trait Roll Result:", tostring(newTrait))
                    
                    if newTrait and newTrait ~= "" then
                        for traitName, isSelected in pairs(selectedTraits) do
                            if isSelected and newTrait == traitName then
                                Fluent:Notify({
                                    Title = "Trait Reroll",
                                    Content = "Got desired trait: " .. newTrait .. "! Stopping.",
                                    Duration = 5
                                })
                                Options.AutoTraitRoll:SetValue(false)
                                return
                            end
                        end
                        DebugPrint("Trait not matched, continuing... Got:", newTrait)
                    end
                end)
                
                task.wait(0.5)
            end
        else
            task.wait(0.3)
        end
    end
end))

-- ============================================
-- [[ REIATSU EVOLUTION SYSTEM ]]
-- ============================================

-- ── Reiatsu Utility Functions ──

local function GetReiatsuTokenAmount()
    local text = "N/A"
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Canvas")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Inventory")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("Main")
        if not listFrame then return end
        listFrame = listFrame:FindFirstChild("List")
        if not listFrame then return end
        local tokenFrame = listFrame:FindFirstChild("Reiatsu Token")
        if not tokenFrame then return end
        local button = tokenFrame:FindFirstChild("Button")
        if not button then return end
        local amountLabel = button:FindFirstChild("Amount")
        if not amountLabel then return end
        
        local ok, val = pcall(function() return amountLabel.ContentText end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Text end)
        if ok and val and val ~= "" then text = val return end
        ok, val = pcall(function() return amountLabel.Value end)
        if ok and val then text = tostring(val) return end
    end)
    return text
end

local function RerollReiatsu()
    pcall(function()
        GetKnitServices().RerollableService.RF.Reroll:InvokeServer("Reiatsu")
        DebugPrint("Reroll: Reiatsu")
    end)
end

-- ============================================
-- [[ REIATSU EVOLUTION UI SECTION ]]
-- ============================================

local SectionReiatsuReroll = Tabs.Misc:AddSection("Reiatsu Evolution")
local ReiatsuTokenLabel = Tabs.Misc:AddParagraph({ Title = "Reiatsu Token", Content = GetReiatsuTokenAmount() })

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(3)
        pcall(function() ReiatsuTokenLabel:SetDesc(GetReiatsuTokenAmount()) end)
    end
end))

local previousReiatsuRarityState = {}

local DropdownReiatsuRarity = Tabs.Misc:AddDropdown("ReiatsuRaritySelect", {
    Title = "Select Rarity",
    Description = "Toggle rarity filter for Reiatsu reroll (multi select)",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"},
    Multi = true,
    Default = {}
})

DropdownReiatsuRarity:OnChanged(function(value)
    for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Deity"}) do
        local currentState = value[rarity] or false
        local prevState = previousReiatsuRarityState[rarity] or false
        
        if currentState ~= prevState then
            DebugPrint("Reiatsu Rarity Toggled:", rarity, "New State:", tostring(currentState))
            ToggleSaiyanRarity(rarity)
        end
    end
    
    previousReiatsuRarityState = {}
    for rarity, state in pairs(value) do
        previousReiatsuRarityState[rarity] = state
    end
end)

local ToggleAutoReiatsuRoll = Tabs.Misc:AddToggle("AutoReiatsuRoll", {
    Title = "Auto Roll Reiatsu",
    Description = "Rolls until result matches selected rarity, then stops",
    Default = false
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoReiatsuRoll and Options.AutoReiatsuRoll.Value then
            pcall(function()
                local selectedRarities = Options.ReiatsuRaritySelect and Options.ReiatsuRaritySelect.Value
                if not selectedRarities then task.wait(0.5) return end
                
                local hasSelection = false
                for _, isSelected in pairs(selectedRarities) do
                    if isSelected then hasSelection = true break end
                end
                
                if not hasSelection then
                    DebugPrint("No rarity selected for Reiatsu Roll")
                    task.wait(0.5)
                    return
                end
                
                RerollReiatsu()
                task.wait(1)
                
                local newResult = GetSaiyanRollResult()
                DebugPrint("Reiatsu Roll Result:", tostring(newResult))
                
                if newResult and newResult ~= "" then
                    local resultRarity = GetSaiyanItemRarity(newResult)
                    DebugPrint("Reiatsu Result Rarity:", tostring(resultRarity))
                    
                    if resultRarity and resultRarity ~= "" then
                        local matched = false
                        for rarityName, isSelected in pairs(selectedRarities) do
                            if isSelected then
                                if string.lower(resultRarity) == string.lower(rarityName) or
                                   string.find(string.lower(resultRarity), string.lower(rarityName)) or
                                   string.find(string.lower(rarityName), string.lower(resultRarity)) then
                                    matched = true
                                    break
                                end
                            end
                        end
                        
                        if matched then
                            Fluent:Notify({
                                Title = "Reiatsu Reroll",
                                Content = "Got " .. newResult .. " (" .. resultRarity .. ")! Stopping.",
                                Duration = 5
                            })
                            Options.AutoReiatsuRoll:SetValue(false)
                            return
                        else
                            DebugPrint("Reiatsu rarity not matched, continuing... Got:", newResult, "Rarity:", resultRarity)
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(0.3)
        end
    end
end))

-- [[ Misc Tab: Other Features ]]
local SectionOther = Tabs.Misc:AddSection("Other Features")
local SliderClickWait = Tabs.Misc:AddSlider("ClickWait", { Title = "Auto Click Delay (seconds)", Description = "Set delay between each click", Default = 0.1, Min = 0.01, Max = 10, Rounding = 2 })
local ToggleAutoClick = Tabs.Misc:AddToggle("AutoClick", { Title = "Auto Click", Default = false })

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoClick and Options.AutoClick.Value then
            pcall(function() GetKnitServices().ClickService.RF.Click:InvokeServer() end)
            task.wait(Options.ClickWait and Options.ClickWait.Value or 0.1)
        else task.wait(0.1) end
    end
end)

local ToggleAutoPrestige = Tabs.Misc:AddToggle("AutoPrestige", { Title = "Auto Prestige", Default = false })
task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoPrestige and Options.AutoPrestige.Value then
            pcall(function() GetKnitServices().LevelService.RF.Prestige:InvokeServer() end)
            task.wait(5)
        else task.wait(0.3) end
    end
end)

local ToggleAutoRankUp = Tabs.Misc:AddToggle("AutoRankUp", { Title = "Auto Rank Up", Default = false })
task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoRankUp and Options.AutoRankUp.Value then
            pcall(function() GetKnitServices().RankupService.RF.RankUp:InvokeServer() end)
            task.wait(1)
        else task.wait(0.3) end
    end
end)

-- ============================================
-- [[ AUTO BANKAI PROGRESSION (for Other Features section) ]]
-- ============================================

local ToggleAutoBankaiProgression = Tabs.Misc:AddToggle("AutoBankaiProgression", {
    Title = "Auto Bankai Progression",
    Description = "Auto upgrade Bankai Progression",
    Default = false
})

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoBankaiProgression and Options.AutoBankaiProgression.Value then
            pcall(function()
                GetKnitServices().ProgressionService.RF.Upgrade:InvokeServer("Bankai Progression")
                DebugPrint("Bankai Progression Upgrade")
            end)
            task.wait(1)
        else
            task.wait(0.3)
        end
    end
end))

-- Claim Codes Button
local ButtonClaimCodes = Tabs.Misc:AddButton({
    Title = "Claim Codes",
    Description = "Fetch codes from Web and redeem all automatically",
    Callback = function()
        task.spawn(function()
            Fluent:Notify({
                Title = "Claim Codes",
                Content = "Fetching codes from website...",
                Duration = 3
            })
            
            local codes = FetchCodesFromWeb()
            
            if #codes == 0 then
                Fluent:Notify({
                    Title = "Claim Codes",
                    Content = "No codes found or failed to fetch.",
                    Duration = 3
                })
                return
            end
            
            Fluent:Notify({
                Title = "Claim Codes",
                Content = "Found " .. #codes .. " codes. Redeeming...",
                Duration = 3
            })
            
            local redeemed = 0
            for i, code in ipairs(codes) do
                pcall(function()
                    RedeemCode(code)
                    redeemed = redeemed + 1
                    DebugPrint("Redeemed code", i, "/", #codes, ":", code)
                end)
                task.wait(1) -- Delay between redeems to avoid rate limit
            end
            
            Fluent:Notify({
                Title = "Claim Codes",
                Content = "Done! Attempted " .. redeemed .. "/" .. #codes .. " codes.",
                SubContent = "Already claimed codes are skipped by the server.",
                Duration = 5
            })
        end)
    end
})

-- ============================================
-- [[ AUTO CRAFT & COLLECT SYSTEM (FIXED v2) ]]
-- ============================================

-- ── Variables for Craft System ──
local currentFarmingItem = nil
local craftFarmCache = {} -- Cache: {itemName = {world = worldName, mob = mobData}}
local lastCraftName = nil -- Track last selected craft
local excludedWorlds = {
    ["Time Trial Lobby"] = true,
}

-- ── Craft Utility Functions ──

local function GetCraftList()
    local craftItems = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main.List
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Template" then
                table.insert(craftItems, child.Name)
            end
        end
    end)
    table.sort(craftItems)
    return craftItems
end

local function GetWorldList()
    local worlds = {}
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui.Main.Canvas.Teleport.Main.List
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Template" then
                if not excludedWorlds[child.Name] then
                    table.insert(worlds, child.Name)
                end
            end
        end
    end)
    return worlds
end

local function GetCurrentArea()
    local area = "Unknown"
    pcall(function()
        local mobsFolder = workspace:FindFirstChild("Mobs")
        if mobsFolder then
            for _, mob in pairs(mobsFolder:GetChildren()) do
                local mobArea = mob:GetAttribute("Area")
                if mobArea and mobArea ~= "" then
                    area = mobArea
                    break
                end
            end
        end
    end)
    return area
end

local function ForceOpenCraftUI()
    pcall(function()
        local craftUI = LocalPlayer.PlayerGui.Main.Canvas.Craft
        if craftUI then
            craftUI.Visible = true
            local main = craftUI:FindFirstChild("Main")
            if main then main.Visible = true end
        end
    end)
end

local function FindClickableInFrame(frame)
    if not frame then return nil end
    
    if frame:IsA("TextButton") or frame:IsA("ImageButton") then
        return frame
    end
    
    for _, child in pairs(frame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            return child
        end
    end
    
    for _, desc in pairs(frame:GetDescendants()) do
        if desc:IsA("TextButton") or desc:IsA("ImageButton") then
            return desc
        end
    end
    
    return nil
end

local function TryFireSignalOnButton(button)
    local success = false
    
    if firesignal then
        pcall(function()
            firesignal(button.MouseButton1Click)
            success = true
        end)
        if success then return true end
        
        pcall(function()
            firesignal(button.Activated)
            success = true
        end)
        if success then return true end
    end
    
    return false
end

local function TryGetConnectionsOnButton(button)
    local success = false
    
    if getconnections then
        pcall(function()
            local connections = getconnections(button.MouseButton1Click)
            for _, conn in pairs(connections) do
                if conn.Fire then
                    conn:Fire()
                    success = true
                elseif conn.Function then
                    pcall(conn.Function)
                    success = true
                end
            end
        end)
        if success then return true end
        
        pcall(function()
            local connections = getconnections(button.Activated)
            for _, conn in pairs(connections) do
                if conn.Fire then
                    conn:Fire()
                    success = true
                elseif conn.Function then
                    pcall(conn.Function)
                    success = true
                end
            end
        end)
        if success then return true end
    end
    
    return false
end

local function TrySynthesizeClickOnButton(button)
    local success = false
    
    pcall(function()
        local absPos = button.AbsolutePosition
        local absSize = button.AbsoluteSize
        local centerX = absPos.X + (absSize.X / 2)
        local centerY = absPos.Y + (absSize.Y / 2)
        
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        success = true
    end)
    
    return success
end

local function ClickButtonAllMethods(button)
    if not button then return false end
    
    local clickable = FindClickableInFrame(button)
    if not clickable then 
        clickable = button 
    end
    
    if TryFireSignalOnButton(clickable) then
        return true
    end
    
    if TryGetConnectionsOnButton(clickable) then
        return true
    end
    
    if TrySynthesizeClickOnButton(clickable) then
        return true
    end
    
    pcall(function()
        clickable.MouseButton1Click:Fire()
    end)
    
    pcall(function()
        clickable.Activated:Fire()
    end)
    
    return true
end

local function SelectCraftInUI(craftName)
    local success = false
    
    pcall(function()
        local listFrame = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main.List
        local craftFrame = listFrame:FindFirstChild(craftName)
        
        if not craftFrame then
            DebugPrint("SelectCraft: Frame not found:", craftName)
            return
        end
        
        local button = craftFrame:FindFirstChild("Button")
        success = ClickButtonAllMethods(button or craftFrame)
    end)
    
    task.wait(0.3)
    return success
end

local function WaitForCraftInfoUpdate(craftName, timeout)
    timeout = timeout or 5
    local startTime = tick()
    
    while (tick() - startTime) < timeout do
        local currentItem = nil
        pcall(function()
            local craftInfo = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main.CraftInfo
            local itemLabel = craftInfo:FindFirstChild("Item")
            if itemLabel then
                currentItem = itemLabel.ContentText or itemLabel.Text or ""
            end
        end)
        
        if currentItem and currentItem ~= "" then
            if currentItem == craftName or 
               string.find(currentItem:lower(), craftName:lower()) or 
               string.find(craftName:lower(), currentItem:lower()) then
                return true
            end
        end
        
        task.wait(0.2)
    end
    
    return false
end

local function GetCraftInfo()
    local info = {
        item = nil,
        cost = nil,
        rarity = nil,
        dailyLimit = 0,
        requiredItems = {}
    }
    
    pcall(function()
        local craftInfo = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main.CraftInfo
        
        local itemLabel = craftInfo:FindFirstChild("Item")
        if itemLabel then
            info.item = itemLabel.ContentText or itemLabel.Text
        end
        
        local costLabel = craftInfo:FindFirstChild("Cost")
        if costLabel then
            info.cost = costLabel.ContentText or costLabel.Text
        end
        
        local rarityLabel = craftInfo:FindFirstChild("Rarity")
        if rarityLabel then
            info.rarity = rarityLabel.ContentText or rarityLabel.Text
        end
        
        local dailyLabel = craftInfo:FindFirstChild("Daily")
        if dailyLabel then
            local text = dailyLabel.ContentText or dailyLabel.Text or ""
            local limit = text:match("Daily Limit:%s*(%d+)x")
            info.dailyLimit = tonumber(limit) or 0
        end
        
        local itemsFrame = craftInfo:FindFirstChild("Items")
        if itemsFrame then
            for _, child in pairs(itemsFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "Template" then
                    local button = child:FindFirstChild("Button")
                    if button then
                        local itemNameLabel = button:FindFirstChild("Item")
                        local amountLabel = button:FindFirstChild("Amount")
                        
                        if itemNameLabel and amountLabel then
                            local itemName = itemNameLabel.ContentText or itemNameLabel.Text or ""
                            local amountText = amountLabel.ContentText or ""
                            
                            local required, owned = amountText:match("x(%d+)/(%d+)")
                            
                            table.insert(info.requiredItems, {
                                name = child.Name,
                                displayName = itemName,
                                required = tonumber(required) or 0,
                                owned = tonumber(owned) or 0
                            })
                        end
                    end
                end
            end
        end
    end)
    
    return info
end

local function TeleportToWorld(worldName)
    if excludedWorlds[worldName] then
        return false
    end
    
    pcall(function()
        GetKnitServices().MapService.RF.Teleport:InvokeServer(worldName)
    end)
    task.wait(3)
    return true
end

-- Find all items dropped by mobs in current world
local function FindAllItemDropsInWorld(worldName, itemsToFind)
    local results = {}
    
    pcall(function()
        local mobsFolder = workspace:FindFirstChild("Mobs")
        if not mobsFolder then return end
        
        for _, mob in pairs(mobsFolder:GetChildren()) do
            local mobArea = mob:GetAttribute("Area")
            if mobArea == worldName and IsMobAlive(mob) then
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local enemyOverhead = hrp:FindFirstChild("EnemyOverhead")
                    if enemyOverhead then
                        local rewards = enemyOverhead:FindFirstChild("Rewards")
                        if rewards then
                            for _, itemName in ipairs(itemsToFind) do
                                local itemReward = rewards:FindFirstChild(itemName)
                                if itemReward then
                                    local button = itemReward:FindFirstChild("Button")
                                    if button then
                                        local chanceLabel = button:FindFirstChild("Chance")
                                        local amountLabel = button:FindFirstChild("Amount")
                                        
                                        local chance = 0
                                        local amount = 0
                                        
                                        if chanceLabel then
                                            local text = chanceLabel.ContentText or chanceLabel.Text or ""
                                            chance = tonumber(text:match("(%d+%.?%d*)")) or 0
                                        end
                                        
                                        if amountLabel then
                                            local text = amountLabel.ContentText or amountLabel.Text or ""
                                            amount = tonumber(text:match("(%d+)")) or 0
                                        end
                                        
                                        local score = chance * amount
                                        local mobName = GetEnemyName(mob) or mob.Name
                                        
                                        if not results[itemName] or score > results[itemName].mob.score then
                                            results[itemName] = {
                                                world = worldName,
                                                mob = {
                                                    name = mobName,
                                                    chance = chance,
                                                    amount = amount,
                                                    score = score
                                                }
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return results
end

-- Scan worlds for specific items (only items not in cache)
local function ScanWorldsForItems(itemsToFind)
    local results = {}
    local worlds = GetWorldList()
    local totalItems = #itemsToFind
    
    if totalItems == 0 then
        return results
    end
    
    DebugPrint("=== Scanning for", totalItems, "items ===")
    DebugPrint("Items:", table.concat(itemsToFind, ", "))
    
    Fluent:Notify({
        Title = "Auto Craft",
        Content = "Scanning " .. #worlds .. " worlds for " .. totalItems .. " item(s)...",
        Duration = 3
    })
    
    for worldIndex, worldName in ipairs(worlds) do
        if not getgenv().EnzoScriptRunning then break end
        if not (Options.AutoCraftCollect and Options.AutoCraftCollect.Value) then break end
        
        if excludedWorlds[worldName] then
            continue
        end
        
        DebugPrint("Scanning [" .. worldIndex .. "/" .. #worlds .. "]:", worldName)
        
        Fluent:Notify({
            Title = "Auto Craft",
            Content = "Scanning [" .. worldIndex .. "/" .. #worlds .. "]: " .. worldName,
            Duration = 1
        })
        
        TeleportToWorld(worldName)
        task.wait(2)
        
        local worldResults = FindAllItemDropsInWorld(worldName, itemsToFind)
        
        for itemName, result in pairs(worldResults) do
            if not results[itemName] or result.mob.score > results[itemName].mob.score then
                results[itemName] = result
                DebugPrint("Found", itemName, "in", worldName, "Mob:", result.mob.name, "Score:", result.mob.score)
            end
        end
        
        -- Check if we found all items
        local foundAll = true
        for _, itemName in ipairs(itemsToFind) do
            if not results[itemName] then
                foundAll = false
                break
            end
        end
        
        if foundAll then
            DebugPrint("Found all items, stopping scan early")
            break
        end
    end
    
    DebugPrint("=== Scan Complete ===")
    local foundCount = 0
    for itemName, result in pairs(results) do
        DebugPrint("Result:", itemName, "-> World:", result.world, "Mob:", result.mob.name)
        foundCount = foundCount + 1
    end
    
    Fluent:Notify({
        Title = "Auto Craft",
        Content = "Scan complete! Found " .. foundCount .. "/" .. totalItems .. " item(s).",
        Duration = 3
    })
    
    return results
end

-- Get missing items that are not in cache
local function GetItemsNotInCache(missingItems)
    local notInCache = {}
    
    for _, itemName in ipairs(missingItems) do
        if not craftFarmCache[itemName] then
            table.insert(notInCache, itemName)
        end
    end
    
    return notInCache
end

-- Add scan results to cache
local function AddToCache(scanResults)
    for itemName, result in pairs(scanResults) do
        craftFarmCache[itemName] = result
        DebugPrint("Cached:", itemName, "-> World:", result.world, "Mob:", result.mob.name)
    end
end

-- Debug: Print current cache
local function DebugPrintCache()
    DebugPrint("=== Current Cache ===")
    local count = 0
    for itemName, result in pairs(craftFarmCache) do
        DebugPrint("  ", itemName, "-> World:", result.world, "Mob:", result.mob.name)
        count = count + 1
    end
    DebugPrint("Total cached:", count)
end

-- Click Craft button
local function ClickCraftButtonInUI()
    local success = false
    
    pcall(function()
        local craftInfo = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main.CraftInfo
        local mainFrame = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main
        
        local buttonNames = {"Craft", "CraftButton", "Create", "CreateButton", "Make", "Build"}
        local craftButton = nil
        
        for _, name in ipairs(buttonNames) do
            craftButton = craftInfo:FindFirstChild(name)
            if craftButton then break end
        end
        
        if not craftButton then
            for _, name in ipairs(buttonNames) do
                craftButton = mainFrame:FindFirstChild(name)
                if craftButton then break end
            end
        end
        
        if not craftButton then
            for _, desc in pairs(mainFrame:GetDescendants()) do
                if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                    local descName = desc.Name:lower()
                    if string.find(descName, "craft") or string.find(descName, "create") then
                        craftButton = desc
                        break
                    end
                end
            end
        end
        
        if craftButton then
            success = ClickButtonAllMethods(craftButton)
        end
    end)
    
    return success
end

local function ClickCollectButtonInUI()
    local success = false
    
    pcall(function()
        local craftInfo = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main.CraftInfo
        local mainFrame = LocalPlayer.PlayerGui.Main.Canvas.Craft.Main
        
        local buttonNames = {"Collect", "CollectButton", "Claim", "ClaimButton", "Get", "Receive"}
        local collectButton = nil
        
        for _, name in ipairs(buttonNames) do
            collectButton = craftInfo:FindFirstChild(name)
            if collectButton then break end
        end
        
        if not collectButton then
            for _, name in ipairs(buttonNames) do
                collectButton = mainFrame:FindFirstChild(name)
                if collectButton then break end
            end
        end
        
        if not collectButton then
            for _, desc in pairs(mainFrame:GetDescendants()) do
                if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                    local descName = desc.Name:lower()
                    if string.find(descName, "collect") or string.find(descName, "claim") then
                        collectButton = desc
                        break
                    end
                end
            end
        end
        
        if collectButton then
            success = ClickButtonAllMethods(collectButton)
        end
    end)
    
    return success
end

local function CraftItem(craftName)
    local success = false
    
    ClickCraftButtonInUI()
    task.wait(0.5)
    
    pcall(function()
        local services = GetKnitServices()
        local craftService = services.CraftService
        
        if craftService and craftService.RF then
            local functions = craftService.RF:GetChildren()
            for _, func in pairs(functions) do
                local funcName = func.Name:lower()
                if string.find(funcName, "craft") or string.find(funcName, "create") or string.find(funcName, "make") then
                    pcall(function()
                        func:InvokeServer(craftName)
                        success = true
                    end)
                    pcall(function()
                        func:InvokeServer(craftName, 1)
                        success = true
                    end)
                    pcall(function()
                        func:InvokeServer()
                        success = true
                    end)
                end
            end
        end
        
        if craftService and craftService.RE then
            local events = craftService.RE:GetChildren()
            for _, event in pairs(events) do
                local eventName = event.Name:lower()
                if string.find(eventName, "craft") or string.find(eventName, "create") then
                    pcall(function()
                        event:FireServer(craftName)
                        success = true
                    end)
                    pcall(function()
                        event:FireServer(craftName, 1)
                        success = true
                    end)
                end
            end
        end
    end)
    
    return success
end

local function CollectCraftedItem(craftName)
    local success = false
    
    ClickCollectButtonInUI()
    task.wait(0.5)
    
    pcall(function()
        local services = GetKnitServices()
        local craftService = services.CraftService
        
        if craftService and craftService.RF then
            local functions = craftService.RF:GetChildren()
            for _, func in pairs(functions) do
                local funcName = func.Name:lower()
                if string.find(funcName, "collect") or string.find(funcName, "claim") or string.find(funcName, "get") then
                    pcall(function()
                        func:InvokeServer(craftName)
                        success = true
                    end)
                    pcall(function()
                        func:InvokeServer()
                        success = true
                    end)
                end
            end
        end
        
        if craftService and craftService.RE then
            local events = craftService.RE:GetChildren()
            for _, event in pairs(events) do
                local eventName = event.Name:lower()
                if string.find(eventName, "collect") or string.find(eventName, "claim") then
                    pcall(function()
                        event:FireServer(craftName)
                        success = true
                    end)
                end
            end
        end
    end)
    
    return success
end

local function FormatCraftStatus(craftInfo, currentArea, farmingItem)
    local lines = {}
    table.insert(lines, "Area: " .. (currentArea or "Unknown"))
    table.insert(lines, "")
    
    if craftInfo and craftInfo.item and craftInfo.item ~= "" then
        table.insert(lines, "Crafting: " .. craftInfo.item)
        table.insert(lines, "Daily Limit: " .. craftInfo.dailyLimit .. "x")
        table.insert(lines, "")
        table.insert(lines, "Required Items:")
        
        for _, item in ipairs(craftInfo.requiredItems) do
            local status = ""
            if item.owned >= item.required then
                status = "✓"
            else
                status = "✗"
            end
            
            local highlight = ""
            if farmingItem and item.name == farmingItem then
                highlight = " ← Farming"
            end
            
            -- Show if cached
            local cacheInfo = ""
            if craftFarmCache[item.name] then
                cacheInfo = " [" .. craftFarmCache[item.name].world .. "]"
            end
            
            table.insert(lines, status .. " " .. item.name .. ": " .. item.owned .. "/" .. item.required .. cacheInfo .. highlight)
        end
        
        -- Show cache count
        local cacheCount = 0
        for _ in pairs(craftFarmCache) do cacheCount = cacheCount + 1 end
        table.insert(lines, "")
        table.insert(lines, "Cached Locations: " .. cacheCount)
    else
        table.insert(lines, "Select a craft item from dropdown")
    end
    
    return table.concat(lines, "\n")
end

-- ============================================
-- [[ CRAFT UI SECTION ]]
-- ============================================

local SectionCraft = Tabs.Misc:AddSection("Craft")

local currentCraftList = GetCraftList()
local DropdownCraft = Tabs.Misc:AddDropdown("CraftSelect", {
    Title = "Select Craft Item",
    Description = "Choose item to craft",
    Values = currentCraftList,
    Multi = false,
    Default = nil
})

local CraftStatusLabel = Tabs.Misc:AddParagraph({
    Title = "Craft Status",
    Content = "Area: Unknown\n\nSelect a craft item from dropdown"
})

local ToggleAutoCraftCollect = Tabs.Misc:AddToggle("AutoCraftCollect", {
    Title = "Auto Craft & Collect",
    Description = "Auto farm materials and craft selected item",
    Default = false
})

-- Reset cache when dropdown changes to different craft
DropdownCraft:OnChanged(function(value)
    if value and value ~= "" then
        -- Only clear cache if craft item changed
        if lastCraftName and lastCraftName ~= value then
            DebugPrint("Craft changed from", lastCraftName, "to", value, "- Clearing cache")
            craftFarmCache = {}
        end
        lastCraftName = value
        
        task.spawn(function()
            ForceOpenCraftUI()
            task.wait(0.2)
            
            for attempt = 1, 5 do
                SelectCraftInUI(value)
                task.wait(0.5)
                
                if WaitForCraftInfoUpdate(value, 2) then
                    break
                end
            end
            
            local craftInfo = GetCraftInfo()
            local currentArea = GetCurrentArea()
            CraftStatusLabel:SetDesc(FormatCraftStatus(craftInfo, currentArea, currentFarmingItem))
        end)
    end
end)

-- Refresh craft list
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(5)
        pcall(function()
            local newList = GetCraftList()
            local changed = #newList ~= #currentCraftList
            if not changed then
                for i, name in ipairs(newList) do
                    if currentCraftList[i] ~= name then changed = true break end
                end
            end
            if changed then
                currentCraftList = newList
                DropdownCraft:SetValues(newList)
            end
        end)
    end
end))

-- Update status label
table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(2)
        pcall(function()
            local selectedCraft = Options.CraftSelect and Options.CraftSelect.Value
            local currentArea = GetCurrentArea()
            
            if selectedCraft and selectedCraft ~= "" then
                if Options.AutoCraftCollect and Options.AutoCraftCollect.Value then
                    SelectCraftInUI(selectedCraft)
                    task.wait(0.3)
                end
                
                local craftInfo = GetCraftInfo()
                local statusText = FormatCraftStatus(craftInfo, currentArea, currentFarmingItem)
                CraftStatusLabel:SetDesc(statusText)
            else
                CraftStatusLabel:SetDesc("Area: " .. currentArea .. "\n\nSelect a craft item from dropdown")
            end
        end)
    end
end))

-- Clear cache when toggle is disabled
ToggleAutoCraftCollect:OnChanged(function(value)
    if not value then
        currentFarmingItem = nil
        -- Don't clear cache on toggle off, keep it for next use
        -- craftFarmCache = {}
    end
end)

-- ============================================
-- [[ AUTO CRAFT & COLLECT MAIN LOOP (FIXED v2) ]]
-- ============================================

table.insert(getgenv().EnzoThreads, task.spawn(function()
    while getgenv().EnzoScriptRunning do
        if Options.AutoCraftCollect and Options.AutoCraftCollect.Value then
            local selectedCraft = Options.CraftSelect and Options.CraftSelect.Value
            
            if not selectedCraft or selectedCraft == "" then
                currentFarmingItem = nil
                task.wait(1)
                continue
            end
            
            -- Check if craft changed
            if lastCraftName and lastCraftName ~= selectedCraft then
                DebugPrint("Craft changed, clearing cache")
                craftFarmCache = {}
                lastCraftName = selectedCraft
            end
            
            -- Step 1: Select craft item
            DebugPrint("=== Auto Craft Start:", selectedCraft, "===")
            ForceOpenCraftUI()
            task.wait(0.3)
            
            local updated = false
            for attempt = 1, 5 do
                SelectCraftInUI(selectedCraft)
                task.wait(0.5)
                updated = WaitForCraftInfoUpdate(selectedCraft, 3)
                if updated then break end
            end
            
            -- Step 2: Get craft info
            local craftInfo = GetCraftInfo()
            
            if not craftInfo.item or craftInfo.item == "" then
                craftInfo.item = selectedCraft
            end
            
            -- Step 3: Check daily limit
            if craftInfo.dailyLimit <= 0 then
                Fluent:Notify({
                    Title = "Auto Craft",
                    Content = "Daily Limit: 0x - Stopping.",
                    Duration = 3
                })
                Options.AutoCraftCollect:SetValue(false)
                currentFarmingItem = nil
                continue
            end
            
            -- Step 4: Check required items
            if #craftInfo.requiredItems == 0 then
                Fluent:Notify({
                    Title = "Auto Craft",
                    Content = "Cannot read requirements. Select item manually first.",
                    Duration = 3
                })
                task.wait(2)
                continue
            end
            
            -- Step 5: Find ALL missing items
            local missingItems = {}
            local allItemsSufficient = true
            
            for _, reqItem in ipairs(craftInfo.requiredItems) do
                DebugPrint("Check:", reqItem.name, reqItem.owned, "/", reqItem.required)
                if reqItem.owned < reqItem.required then
                    allItemsSufficient = false
                    table.insert(missingItems, reqItem.name)
                end
            end
            
            DebugPrint("Missing items:", #missingItems)
            DebugPrintCache()
            
            -- Step 6: Check which missing items are NOT in cache
            if not allItemsSufficient then
                local itemsNotInCache = GetItemsNotInCache(missingItems)
                
                DebugPrint("Items not in cache:", #itemsNotInCache)
                for _, name in ipairs(itemsNotInCache) do
                    DebugPrint("  -", name)
                end
                
                -- Only scan if there are items not in cache
                if #itemsNotInCache > 0 then
                    DebugPrint("Need to scan for", #itemsNotInCache, "item(s)")
                    
                    Fluent:Notify({
                        Title = "Auto Craft",
                        Content = "Scanning for " .. #itemsNotInCache .. " new item(s)...",
                        Duration = 3
                    })
                    
                    -- Scan only for items not in cache
                    local scanResults = ScanWorldsForItems(itemsNotInCache)
                    
                    -- Add results to cache
                    AddToCache(scanResults)
                    
                    DebugPrint("After scan:")
                    DebugPrintCache()
                else
                    DebugPrint("All missing items are already cached")
                end
            end
            
            -- Step 7: Farm missing items using cached data
            if not allItemsSufficient then
                -- Find first missing item that we have cache for
                local itemToFarm = nil
                local farmSpot = nil
                
                for _, reqItem in ipairs(craftInfo.requiredItems) do
                    if reqItem.owned < reqItem.required then
                        if craftFarmCache[reqItem.name] then
                            itemToFarm = reqItem
                            farmSpot = craftFarmCache[reqItem.name]
                            break
                        else
                            -- Item not in cache (couldn't find mob that drops it)
                            DebugPrint("No cache for:", reqItem.name, "- Skipping")
                        end
                    end
                end
                
                if itemToFarm and farmSpot then
                    currentFarmingItem = itemToFarm.name
                    
                    DebugPrint("Farming:", itemToFarm.name, "at", farmSpot.world, "Mob:", farmSpot.mob.name)
                    
                    Fluent:Notify({
                        Title = "Auto Craft",
                        Content = "Farming " .. itemToFarm.name .. " at " .. farmSpot.world .. " (" .. itemToFarm.owned .. "/" .. itemToFarm.required .. ")",
                        Duration = 3
                    })
                    
                    -- Teleport if not in correct world
                    local currentArea = GetCurrentArea()
                    if currentArea ~= farmSpot.world then
                        TeleportToWorld(farmSpot.world)
                        task.wait(2)
                    end
                    
                    local method = Options.MethodSelect and Options.MethodSelect.Value or "Teleport"
                    local lastOwned = itemToFarm.owned
                    local noProgressCount = 0
                    
                    -- Farm until this item is complete
                    while getgenv().EnzoScriptRunning and Options.AutoCraftCollect.Value do
                        -- Refresh info
                        SelectCraftInUI(selectedCraft)
                        task.wait(0.3)
                        local newInfo = GetCraftInfo()
                        
                        local currentItem = nil
                        for _, ri in ipairs(newInfo.requiredItems) do
                            if ri.name == itemToFarm.name then
                                currentItem = ri
                                break
                            end
                        end
                        
                        if currentItem then
                            if currentItem.owned >= currentItem.required then
                                Fluent:Notify({
                                    Title = "Auto Craft",
                                    Content = "✓ " .. itemToFarm.name .. " complete! (" .. currentItem.owned .. "/" .. currentItem.required .. ")",
                                    Duration = 2
                                })
                                currentFarmingItem = nil
                                break
                            end
                            
                            if currentItem.owned > lastOwned then
                                lastOwned = currentItem.owned
                                noProgressCount = 0
                            else
                                noProgressCount = noProgressCount + 1
                                if noProgressCount > 100 then
                                    DebugPrint("No progress, reteleporting...")
                                    TeleportToWorld(farmSpot.world)
                                    task.wait(2)
                                    noProgressCount = 0
                                end
                            end
                        end
                        
                        -- Find target mob
                        local targetMob, targetHRP = nil, nil
                        local mobsFolder = workspace:FindFirstChild("Mobs")
                        
                        if mobsFolder then
                            -- Find mob that drops this item
                            for _, mob in pairs(mobsFolder:GetChildren()) do
                                local mobArea = mob:GetAttribute("Area")
                                if mobArea == farmSpot.world and IsMobAlive(mob) then
                                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local eo = hrp:FindFirstChild("EnemyOverhead")
                                        if eo then
                                            local rewards = eo:FindFirstChild("Rewards")
                                            if rewards and rewards:FindFirstChild(itemToFarm.name) then
                                                targetMob = mob
                                                targetHRP = hrp
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            
                            -- Fallback: find by mob name
                            if not targetMob then
                                for _, mob in pairs(mobsFolder:GetChildren()) do
                                    local mobName = GetEnemyName(mob)
                                    local mobArea = mob:GetAttribute("Area")
                                    if mobArea == farmSpot.world and IsMobAlive(mob) then
                                        if mobName == farmSpot.mob.name then
                                            targetMob = mob
                                            targetHRP = mob:FindFirstChild("HumanoidRootPart")
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        if targetMob and targetHRP and IsMobAlive(targetMob) then
                            currentTargetModel = targetMob
                            MoveToTargetByMethod(method, targetHRP)
                            ClickEnemy(targetMob)
                            
                            while getgenv().EnzoScriptRunning and Options.AutoCraftCollect.Value and IsMobAlive(targetMob) and targetHRP.Parent do
                                KeepPositionByMethod(method, targetHRP)
                                ClickEnemy(targetMob)
                                task.wait(0.2)
                            end
                            CleanupFarmState()
                        else
                            -- No mob found, reteleport
                            local checkArea = GetCurrentArea()
                            if checkArea ~= farmSpot.world then
                                TeleportToWorld(farmSpot.world)
                                task.wait(2)
                            end
                            task.wait(1)
                        end
                        
                        task.wait(0.3)
                    end
                else
                    -- No farmable item found (all items not in cache)
                    DebugPrint("No farmable items found in cache")
                    
                    local notFoundItems = {}
                    for _, itemName in ipairs(missingItems) do
                        if not craftFarmCache[itemName] then
                            table.insert(notFoundItems, itemName)
                        end
                    end
                    
                    if #notFoundItems > 0 then
                        Fluent:Notify({
                            Title = "Auto Craft",
                            Content = "Cannot find mob for: " .. table.concat(notFoundItems, ", "),
                            Duration = 5
                        })
                    end
                    
                    currentFarmingItem = nil
                    task.wait(3)
                end
            else
                -- Step 8: All materials ready - CRAFT!
                currentFarmingItem = nil
                
                local beforeLimit = craftInfo.dailyLimit
                
                Fluent:Notify({
                    Title = "Auto Craft",
                    Content = "All materials ready! Crafting: " .. selectedCraft,
                    Duration = 2
                })
                
                SelectCraftInUI(selectedCraft)
                task.wait(0.5)
                WaitForCraftInfoUpdate(selectedCraft, 2)
                
                -- Craft
                CraftItem(selectedCraft)
                task.wait(1.5)
                
                -- Collect
                CollectCraftedItem(selectedCraft)
                task.wait(1.5)
                
                -- Check result
                SelectCraftInUI(selectedCraft)
                task.wait(0.5)
                WaitForCraftInfoUpdate(selectedCraft, 2)
                local newInfo = GetCraftInfo()
                
                if newInfo.dailyLimit < beforeLimit then
                    Fluent:Notify({
                        Title = "Auto Craft",
                        Content = "✓ Crafted " .. selectedCraft .. "! Remaining: " .. newInfo.dailyLimit .. "x",
                        Duration = 3
                    })
                    
                    -- Don't clear cache! We'll use it for next craft cycle
                    DebugPrint("Craft successful, keeping cache for next cycle")
                else
                    Fluent:Notify({
                        Title = "Auto Craft",
                        Content = "⚠ Craft may have failed. Retrying...",
                        Duration = 2
                    })
                    
                    task.wait(1)
                    SelectCraftInUI(selectedCraft)
                    task.wait(0.5)
                    CraftItem(selectedCraft)
                    task.wait(1)
                    CollectCraftedItem(selectedCraft)
                    task.wait(1)
                    
                    SelectCraftInUI(selectedCraft)
                    task.wait(0.5)
                    newInfo = GetCraftInfo()
                end
                
                -- Check daily limit
                if newInfo.dailyLimit <= 0 then
                    Fluent:Notify({
                        Title = "Auto Craft",
                        Content = "Daily Limit reached! Stopping.",
                        Duration = 5
                    })
                    Options.AutoCraftCollect:SetValue(false)
                end
            end
            
            task.wait(1)
        else
            currentFarmingItem = nil
            task.wait(0.3)
        end
    end
end))

-- [[ Player Tab ]]
local SectionPlayer = Tabs.Player:AddSection("Player Settings")
local ToggleAntiAFK = Tabs.Player:AddToggle("AntiAFK", { Title = "Anti AFK", Default = true })
local idleConn = LocalPlayer.Idled:Connect(function()
    if Options.AntiAFK and Options.AntiAFK.Value then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        Fluent:Notify({ Title = "Anti AFK", Content = "Preventing Idle...", Duration = 2 })
    end
end)
table.insert(getgenv().EnzoConnections, idleConn)

local ToggleAutoRejoin = Tabs.Player:AddToggle("AutoRejoin", { Title = "Auto Rejoin on Kick", Default = true })
local function checkRejoin(child)
    if Options.AutoRejoin and Options.AutoRejoin.Value and child.Name == "ErrorPrompt" then
        task.wait(2)
        if child:FindFirstChild("Message") then
            Fluent:Notify({ Title = "Rejoin", Content = "Kick detected. Rejoining...", Duration = 3 })
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
end
pcall(function()
    local po = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
    local rc = po.ChildAdded:Connect(checkRejoin)
    table.insert(getgenv().EnzoConnections, rc)
end)

local SectionSpeed = Tabs.Player:AddSection("Movement")
local InputSpeed = Tabs.Player:AddInput("SpeedInput", { Title = "WalkSpeed Amount", Default = "50", Placeholder = "50", Numeric = true, Finished = true })
local ToggleSpeed = Tabs.Player:AddToggle("SpeedToggle", { Title = "Activate WalkSpeed", Default = false })

task.spawn(function()
    while getgenv().EnzoScriptRunning do
        task.wait(0.1)
        if Options.SpeedToggle and Options.SpeedToggle.Value then
            pcall(function()
                local playersFolder = workspace:FindFirstChild("Players")
                if playersFolder then
                    local wsChar = playersFolder:FindFirstChild(LocalPlayer.Name)
                    if wsChar then
                        local wsH = wsChar:FindFirstChildOfClass("Humanoid")
                        if wsH then
                            local sv = tonumber(Options.SpeedInput.Value) or 50
                            if wsH.WalkSpeed ~= sv then wsH.WalkSpeed = sv end
                        end
                    end
                end
            end)
        end
    end
end)

-- [[ Player Tab: Server ]]
local SectionServer = Tabs.Player:AddSection("Server")

local ButtonRejoin = Tabs.Player:AddButton({
    Title = "Rejoin",
    Description = "Rejoin to current server",
    Callback = function()
        Fluent:Notify({
            Title = "Rejoin",
            Content = "Rejoining server...",
            Duration = 3
        })
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

local ButtonServerHop = Tabs.Player:AddButton({
    Title = "Server Hop",
    Description = "Hop to a different server",
    Callback = function()
        Fluent:Notify({
            Title = "Server Hop",
            Content = "Finding new server...",
            Duration = 3
        })
        task.spawn(function()
            pcall(function()
                local servers = {}
                local cursor = ""
                local found = false
                
                while not found do
                    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                    if cursor ~= "" then
                        url = url .. "&cursor=" .. cursor
                    end
                    
                    local response = HttpService:JSONDecode(game:HttpGet(url))
                    
                    if response and response.data then
                        for _, server in ipairs(response.data) do
                            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                                found = true
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                                return
                            end
                        end
                    end
                    
                    if response and response.nextPageCursor and response.nextPageCursor ~= "" then
                        cursor = response.nextPageCursor
                    else
                        break
                    end
                end
                
                if not found then
                    Fluent:Notify({
                        Title = "Server Hop",
                        Content = "No available server found. Rejoining instead...",
                        Duration = 3
                    })
                    task.wait(1)
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end)
        end)
    end
})

-- ============================================
-- [[ TAB: SETTINGS ]]
-- ============================================
local SectionDebug = Tabs.Settings:AddSection("Debug")
local ToggleDebug = Tabs.Settings:AddToggle("DebugMode", { Title = "Enable Debug Print", Default = false })
ToggleDebug:OnChanged(function() debugMode = Options.DebugMode.Value end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("EnzoYT_Scripts")
SaveManager:SetFolder("EnzoYT_Scripts/" .. gameName:gsub("[^%w]", "_"))

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

-------------------------------------------------------------------------
-- TOGGLE UI BUTTON (Tombol Bulat)
-------------------------------------------------------------------------
task.spawn(function()
    -- Membuat ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ToggleUI_Enzo"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Simpan ke global agar bisa dibersihkan
    getgenv().ToggleUIInstance = ScreenGui

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.BackgroundTransparency = 0.3
    ToggleBtn.Position = UDim2.new(0, 20, 0.5, 120) -- Posisi kiri tengah
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Font = Enum.Font.SourceSans
    ToggleBtn.Text = ""
    ToggleBtn.TextColor3 = Color3.fromRGB(248, 248, 248)
    ToggleBtn.Draggable = true
    ToggleBtn.AutoButtonColor = true
    ToggleBtn.BorderSizePixel = 0

    -- Menambahkan Stroke (Garis Tepi)
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = ToggleBtn
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Membuat Tombol Bulat
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = ToggleBtn

    -- Icon Gambar
    local Image = Instance.new("ImageLabel")
    Image.Name = "Icon"
    Image.Parent = ToggleBtn
    Image.Size = UDim2.new(0.65, 0, 0.65, 0)
    Image.Position = UDim2.new(0.175, 0, 0.175, 0) -- Tengah
    Image.BackgroundTransparency = 1
    Image.Image = "rbxassetid://127230896526363" 

    -- Fungsi Klik Tombol (Simulasi tekan LeftControl)
    ToggleBtn.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end)

-- ============================================
-- [[ LOAD CONFIG & FINISH ]]
-- ============================================
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "Script Loaded",
    Content = "Script loaded successfully!\nEnjoy " .. gameName,
    Duration = 5
})