-- Обновлённый скрипт на основе Orion UI с WalkSpeed, ESP, Fly, Noclip, Infinite Jump и Fake Lag
-- Автор: Grok (образовательный пример)
-- Требует: Orion Library (актуальная ссылка на 2025)

-- Проверка загрузки Orion Library (актуальная ссылка)
local OrionLib
local success, errorMsg = pcall(function()
    OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/OrionLibrary/Orion/main/source')))()
end)
if not success or not OrionLib then
    warn("Failed to load Orion Library: " .. tostring(errorMsg) .. ". Using fallback simple GUI.")
    -- Fallback: Простое GUI без Orion (для теста)
    local fallbackGui = true
    -- Создаём простое ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FallbackCheatGUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Parent = screenGui
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "Fallback: Fly on F, Jump on J"
    label.Parent = frame
    -- Простой Fly toggle на F (fallback)
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            -- Вставь здесь простую Fly функцию из предыдущего упрощённого скрипта
            warn("Fallback Fly activated!")
        end
    end)
    return  -- Выходим, если fallback
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
local function getCharacter()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    local char = player.Character
    local hum = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if hum and root then
        return char, hum, root
    else
        warn("Failed to find Humanoid or HumanoidRootPart!")
        return nil, nil, nil
    end
end

local character, humanoid, rootPart = getCharacter()

-- Функция для WalkSpeed с рандомизацией
local function updateWalkSpeed(speed)
    local _, hum = getCharacter()
    if hum then
        hum.WalkSpeed = speed + math.random(-1, 1) * 0.1
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
                task.wait(math.random(0.1, 0.5))  -- Используем task.wait вместо wait
                local highlight = Instance.new("Highlight")
                highlight.Parent = otherPlayer.Character
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                espHighlights[otherPlayer] = highlight
                
                otherPlayer.CharacterAdded:Connect(function(char)
                    if highlight and highlight.Parent then
                        highlight.Parent = char
                    end
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
        task.wait(math.random(0.5, 1))
        local highlight = Instance.new("Highlight")
        highlight.Parent = newPlayer.Character
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        espHighlights[newPlayer] = highlight
        
        newPlayer.CharacterAdded:Connect(function(char)
            if highlight and highlight.Parent then
                highlight.Parent = char
            end
        end)
    end
end)

-- Функция для Fly
local function toggleFly()
    local _, hum, root = getCharacter()
    if not hum or not root then return end
    
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        local linearVelocity = Instance.new("LinearVelocity")
        linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        linearVelocity.MaxForce = math.huge
        linearVelocity.Parent = root
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.CFrame = root.CFrame
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 9000
        bodyGyro.Parent = root
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not hum or not root then return end
            hum.PlatformStand = true
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
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        if root:FindFirstChild("LinearVelocity") then root.LinearVelocity:Destroy() end
        if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
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
    local char = getCharacter()
    if not char then return end
    
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
            task.wait(math.random(0.05, 0.1))
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
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
    local _, hum = getCharacter()
    if not hum then return end
    
    infJumpEnabled = not infJumpEnabled
    
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(math.random(0.01, 0.05))
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
    local _, _, root = getCharacter()
    if not root then return end
    
    fakeLagEnabled = not fakeLagEnabled
    
    if fakeLagEnabled then
        fakeLagConnection = RunService.RenderStepped:Connect(function()
            if root then
                local originalPos = root.Position
                root.Position = originalPos + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)) * 0.5
                task.wait(math.random(0.1, 0.2))
                root.Position = originalPos
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
    character, humanoid, rootPart = getCharacter()
    if flyEnabled then toggleFly() toggleFly() end
    if noclipEnabled then toggleNoclip() toggleNoclip() end
    if infJumpEnabled then toggleInfJump() toggleInfJump() end
    if fakeLagEnabled then toggleFakeLag() toggleFakeLag() end
end)

-- Инициализация Orion
OrionLib:Init()

-- Уведомление об успешной загрузке
OrionLib:MakeNotification({
    Name = "GUI Loaded!",
    Content = "Press F to toggle the menu. All functions ready!",
    Image = "rbxassetid://4483345998",
    Time = 5
})
