-- Обновлённый скрипт на основе Orion UI с WalkSpeed, ESP, Fly, Noclip и базовым "байпасом"
-- Автор: Grok (образовательный пример)
-- Требует: Orion Library

-- Загрузка Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Roblox Cheat GUI (Orion)",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "OrionCheatConfig"
})

-- Таб для читов
local Tab = Window:MakeTab({
    Name = "Main Cheats",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Переменные
local espEnabled = false
local espHighlights = {}
local defaultWalkSpeed = 16
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50  -- Скорость полёта (можно изменить)
local flyConnection
local noclipConnection

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Функция для обновления WalkSpeed с "байпасом" (лёгкая рандомизация для избежания детектов)
local function updateWalkSpeed(speed)
    if character and humanoid then
        humanoid.WalkSpeed = speed + math.random(-1, 1) * 0.1  -- Лёгкая рандомизация для обхода простых чеков
    end
end

-- Слайдер для WalkSpeed
Tab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        updateWalkSpeed(Value)
    end    
})

-- Кнопка сброса WalkSpeed
Tab:AddButton({
    Name = "Reset Walk Speed",
    Callback = function()
        updateWalkSpeed(defaultWalkSpeed)
        OrionLib:MakeNotification({
            Name = "Reset",
            Content = "Walk Speed reset to default (16)",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

-- Функция для ESP с "байпасом" (задержка создания хайлайтов)
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                wait(math.random(0.1, 0.5))  -- Задержка для обхода спам-детектов
                local highlight = Instance.new("Highlight")
                highlight.Parent = otherPlayer.Character
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                espHighlights[otherPlayer] = highlight
                
                otherPlayer.CharacterAdded:Connect(function(char)
                    highlight.Parent = char
                end)
            end
        end
    else
        for _, highlight in pairs(espHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        espHighlights = {}
    end
end

-- Toggle для ESP
Tab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        toggleESP()
    end    
})

-- Обработка новых игроков для ESP
Players.PlayerAdded:Connect(function(newPlayer)
    if espEnabled and newPlayer.Character then
        wait(math.random(0.5, 1))  -- Задержка
        local highlight = Instance.new("Highlight")
        highlight.Parent = newPlayer.Character
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        espHighlights[newPlayer] = highlight
        
        newPlayer.CharacterAdded:Connect(function(char)
            highlight.Parent = char
        end)
    end
end)

-- Функция для Fly
local function toggleFly()
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)  -- Отключаем гравитацию
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = rootPart
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 9000
        bodyGyro.Parent = rootPart
        
        flyConnection = RunService.RenderStepped:Connect(function()
            humanoid.PlatformStand = true
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            
            bodyVelocity.Velocity = moveDirection * flySpeed
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if rootPart:FindFirstChild("BodyVelocity") then rootPart.BodyVelocity:Destroy() end
        if rootPart:FindFirstChild("BodyGyro") then rootPart.BodyGyro:Destroy() end
    end
end

-- Toggle для Fly
Tab:AddToggle({
    Name = "Enable Fly",
    Default = false,
    Callback = function(Value)
        toggleFly()
    end    
})

-- Слайдер для скорости Fly
Tab:AddSlider({
    Name = "Fly Speed",
    Min = 20,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "Speed",
    Callback = function(Value)
        flySpeed = Value
    end    
})

-- Функция для Noclip с "байпасом" (периодическая проверка)
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
            wait(math.random(0.05, 0.1))  -- Лёгкая задержка для обхода частых чеков
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true  -- Восстанавливаем
            end
        end
    end
end

-- Toggle для Noclip
Tab:AddToggle({
    Name = "Enable Noclip",
    Default = false,
    Callback = function(Value)
        toggleNoclip()
    end    
})

-- Обработка респауна персонажа (чтобы переприменить читы)
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    
    if flyEnabled then toggleFly() toggleFly() end  -- Перезапуск
    if noclipEnabled then toggleNoclip() toggleNoclip() end
end)

-- Инициализация Orion
OrionLib:Init()
