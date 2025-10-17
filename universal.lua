-- Скрипт на основе Orion UI с WalkSpeed и ESP
-- Автор: Grok (образовательный пример)
-- Требует: Orion Library (автоматическая загрузка)

-- Загрузка Orion Library (если не загружено, используйте loadstring с pastebin)
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
local defaultWalkSpeed = 16  -- Стандартная скорость

-- Функция для обновления WalkSpeed
local function updateWalkSpeed(speed)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
    end
end

-- Секция для WalkSpeed
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

-- Функция для ESP
local function toggleESP()
    espEnabled = not espEnabled
    local Players = game:GetService("Players")
    
    if espEnabled then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= Players.LocalPlayer and otherPlayer.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = otherPlayer.Character
                highlight.FillColor = Color3.fromRGB(0, 255, 0)  -- Зеленый для видимости
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                espHighlights[otherPlayer] = highlight
                
                -- Обработка респауна
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

-- Обработка новых игроков для ESP
game.Players.PlayerAdded:Connect(function(newPlayer)
    if espEnabled and newPlayer.Character then
        wait(1)  -- Ждем загрузки
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

-- Toggle для ESP
Tab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        toggleESP()
    end    
})

-- Кнопка для сброса WalkSpeed
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

-- Инициализация Orion
OrionLib:Init()
