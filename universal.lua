-- Обновлённый скрипт на основе Orion UI с WalkSpeed, ESP, Fly, Noclip, Infinite Jump и Fake Lag
-- Автор: Grok (образовательный пример)
-- Требует: Orion Library

-- Проверка загрузки Orion Library
local OrionLib
local success, errorMsg = pcall(function()
    OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
end)
if not success or not OrionLib then
    warn("Failed to load Orion Library: " .. tostring(errorMsg))
    return
end

-- Инициализация GUI
local Window = OrionLib:MakeWindow({
    Name = "Roblox Cheat GUI (Orion)",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "OrionCheatConfig",
    IntroEnabled = false,
    Keybind = Enum.KeyCode.F  -- Открытие GUI на F
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
local infJumpEnabled = false
local fakeLagEnabled = false
local flySpeed = 50
local flyConnection
local noclipConnection
local infJumpConnection
local fakeLagConnection

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Безопасная загрузка персонажа
local character = player.Character
if not character then
    player.CharacterAdded:Wait()
    character = player.Character
end
local humanoid = character:WaitForChild("Humanoid", 5)
local rootPart = character:WaitForChild("HumanoidRootPart", 5)
if not humanoid or not rootPart then
    warn("Failed to find Humanoid or HumanoidRootPart!")
    return
end

-- Функция для WalkSpeed с рандомизацией
local function updateWalkSpeed(speed)
    if character and humanoid then
        humanoid.WalkSpeed = speed + math.random(-1, 1) * 0.1
    else
        warn("Cannot update WalkSpeed: Character or Humanoid not found")
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

-- Функция для ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                wait(math.random(0.1, 0.5))
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

-- ESP для новых игроков
Players.PlayerAdded:Connect(function(newPlayer)
    if espEnabled and newPlayer.Character then
        wait(math.random(0.5, 1))
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
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        local linearVelocity = Instance.new("LinearVelocity")
        linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        linearVelocity.MaxForce = math.huge
        linearVelocity.Parent = rootPart
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 9000
        bodyGyro.Parent = rootPart
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not humanoid or not rootPart then return end
            humanoid.PlatformStand = true
            linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            
            linearVelocity.VectorVelocity = moveDirection * flySpeed
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if rootPart:FindFirstChild("LinearVelocity") then rootPart.LinearVelocity:Destroy() end
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

-- Слайдер для Fly Speed
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

-- Функция для Noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if not character then return end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
            wait(math.random(0.05, 0.1))
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
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

-- Функция для Infinite Jump
local function toggleInfJump()
    infJumpEnabled = not infJumpEnabled
    
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if character and humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                wait(math.random(0.01, 0.05))
            end
        end)
    else
        if infJumpConnection then infJumpConnection:Disconnect() end
    end
end

-- Toggle для Infinite Jump
Tab:AddToggle({
    Name = "Enable Infinite Jump",
    Default = false,
    Callback = function(Value)
        toggleInfJump()
    end
})

-- Функция для Fake Lag
local function toggleFakeLag()
    fakeLagEnabled = not fakeLagEnabled
    
    if fakeLagEnabled then
        fakeLagConnection = RunService.RenderStepped:Connect(function()
            if character and rootPart then
                local originalPos = rootPart.Position
                rootPart.Position = originalPos + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)) * 0.5
                wait(math.random(0.1, 0.2))
                rootPart.Position = originalPos
            end
        end)
    else
        if fakeLagConnection then fakeLagConnection:Disconnect() end
    end
end

-- Toggle для Fake Lag
Tab:AddToggle({
    Name = "Enable Fake Lag",
    Default = false,
    Callback = function(Value)
        toggleFakeLag()
    end
})

-- Обработка респауна
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid", 5)
    rootPart = newChar:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not rootPart then
        warn("Failed to find Humanoid or HumanoidRootPart after respawn!")
        return
    end
    
    if flyEnabled then toggleFly() toggleFly() end
    if noclipEnabled then toggleNoclip() toggleNoclip() end
    if infJumpEnabled then toggleInfJump() toggleInfJump() end
    if fakeLagEnabled then toggleFakeLag() toggleFakeLag() end
end)

-- Инициализация Orion
OrionLib:Init()
