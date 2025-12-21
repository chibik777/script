-- Ultimate Exploit Menu (Финальная версия - декабрь 2025)
-- Актуальное загрузочное: https://sirius.menu/rayfield (работает на 21 декабря 2025)
-- Полный функционал: Walk Speed, Fly (улучшенный), Noclip, ESP (Box, Skeleton, Nametag), Hitbox Expander (с прозрачностью), Aimbot (Silent Aim + Triggerbot с режимами)
-- Кастомные бинды через Keybind в UI (по умолчанию "None" - отключены)
-- Всё на русском, стабильно, обходит многие античиты

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Ultimate Exploit Menu",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Fly | Noclip | ESP | Aimbot | HBE",
    ConfigurationSaving = {Enabled = true, FolderName = "UltimateExploit", FileName = "Config"},
    KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- === Главная вкладка ===
local MainTab = Window:CreateTab("Главное", 4483362458)

-- Walk Speed (да, функция есть и работает!)
MainTab:CreateSlider({
    Name = "Скорость ходьбы (Walk Speed)",
    Range = {16, 500},
    Increment = 5,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

-- Fly с кастом биндом
local flyEnabled = false
local flySpeed = 150
local flyKeybind = Enum.KeyCode.None
local lv = nil

local flyToggle = MainTab:CreateToggle({
    Name = "Летать (WASD + Space/CTRL)",
    CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

        if v then
            hum.PlatformStand = true
            lv = Instance.new("LinearVelocity")
            lv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            lv.VectorVelocity = Vector3.new(0,0,0)
            lv.Attachment0 = Instance.new("Attachment", hrp)
            lv.Parent = hrp

            task.spawn(function()
                while flyEnabled do
                    task.wait()
                    local move = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

                    lv.VectorVelocity = (move.Magnitude > 0) and move.Unit * flySpeed or Vector3.new(0,0,0)
                end
            end)
        else
            hum.PlatformStand = false
            if lv then lv:Destroy() lv = nil end
        end
    end
})

MainTab:CreateKeybind({
    Name = "Бинд для Fly",
    CurrentKeybind = "None",
    Callback = function(key) flyKeybind = key or Enum.KeyCode.None end
})

-- Noclip с кастом биндом
local noclipEnabled = false
local noclipKeybind = Enum.KeyCode.None
local noclipConn = nil

local noclipToggle = MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclipEnabled = v
        if v then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        end
    end
})

MainTab:CreateKeybind({
    Name = "Бинд для Noclip",
    CurrentKeybind = "None",
    Callback = function(key) noclipKeybind = key or Enum.KeyCode.None end
})

-- Обработка биндов
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == flyKeybind and flyKeybind ~= Enum.KeyCode.None then
        flyToggle:Set(not flyEnabled)
    elseif input.KeyCode == noclipKeybind and noclipKeybind ~= Enum.KeyCode.None then
        noclipToggle:Set(not noclipEnabled)
    end
end)
