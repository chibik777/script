-- Exploit Menu на Rayfield UI: Fly, Noclip, Walk Speed + ESP (Skeleton, Box, Nametag, HBE)
-- Только для образовательных целей. Использование эксплойтов нарушает правила Roblox и может привести к бану.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Меню Эксплойтов",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Fly | Noclip | Speed | ESP",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyExploit",
        FileName = "Config"
    },
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MainTab = Window:CreateTab("Главное", 4483362458)

-- Walk Speed
MainTab:CreateSlider({
    Name = "Скорость ходьбы",
    Range = {16, 500},
    Increment = 5,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

-- Fly
local flying = false
local flySpeed = 100
local bv, bg

MainTab:CreateToggle({
    Name = "Летать (WASD + Space/ЛКМ)",
    CurrentValue = false,
    Callback = function(Value)
        flying = Value
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

        if Value then
            hum.PlatformStand = true

            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp

            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(4000, 4000, 4000)
            bg.P = 9000
            bg.Parent = hrp

            task.spawn(function()
                while flying do
                    task.wait()
                    bg.CFrame = Camera.CFrame

                    local move = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

                    bv.Velocity = move.Unit * flySpeed
                end
            end)
        else
            hum.PlatformStand = false
            if bv then bv:Destroy() bv = nil end
            if bg then bg:Destroy() bg = nil end
        end
    end
})

-- Noclip
local noclipping = false
local clipConn

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        noclipping = Value
        local char = LocalPlayer.Character

        if Value then
            clipConn = RunService.Stepped:Connect(function()
                if not noclipping or not char or not char.Parent then return end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if clipConn then clipConn:Disconnect() clipConn = nil end
        end
    end
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", 4483362458)
-- ESP Variables
local BoxEnabled = false
local SkeletonEnabled = false
local NameEnabled = false
local HitboxEnabled = false
local TeamCheckEnabled = false
local HitboxSize = 12
local ESPData = {}
local ESPConnection
local HitboxConnection
local PlayerAddedConnection

local SkeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function WorldToVP(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

local function AddESP(player)
    if player == LocalPlayer or ESPData[player] then return end

    local data = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Skeleton = {}
    }

    -- Box ESP
    data.Box.Color = Color3.fromRGB(255, 0, 0)
    data.Box.Thickness = 2
    data.Box.Filled = false
    data.Box.Transparency = 1
    data.Box.Visible = false

    -- Name ESP
    data.Name.Color = Color3.fromRGB(255, 255, 255)
    data.Name.Size = 16
    data.Name.Center = true
    data.Name.Outline = true
    data.Name.Font = 2
    data.Name.Transparency = 1
    data.Name.Visible = false

    -- Skeleton ESP
    for _ = 1, #SkeletonConnections do
        local line = Drawing.new("Line")
        line.Color = Color3.fromRGB(0, 255, 0)
        line.Thickness = 3
        line.Transparency = 1
        line.Visible = false
        table.insert(data.Skeleton, line)
    end

    ESPData[player] = data
end

local function RemoveESP(player)
    local data = ESPData[player]
    if data then
        data.Box:Remove()
        data.Name:Remove()
        for _, line in ipairs(data.Skeleton) do
            line:Remove()
        end
        ESPData[player] = nil
    end
end

local function UpdateESP()
    for player, data in pairs(ESPData) do
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Head") then
            RemoveESP(player)
            continue
        end

        if TeamCheckEnabled and player.Team == LocalPlayer.Team then
            data.Box.Visible = false
            data.Name.Visible = false
            for _, line in ipairs(data.Skeleton) do
                line.Visible = false
            end
            continue
        end

        local rootPart = character.HumanoidRootPart
        local head = character.Head

        local headPos, headVisible = WorldToVP(head.Position + Vector3.new(0, 0.5, 0))
        local footPos, footVisible = WorldToVP(rootPart.Position - Vector3.new(0, 4.5, 0))

        -- Box ESP
        if BoxEnabled then
            if headVisible and footVisible then
                local height = (headPos - footPos).Y
                local width = height / 2.2
                data.Box.Size = Vector2.new(width * 2, height)
                data.Box.Position = Vector2.new(footPos.X - width, footPos.Y)
                data.Box.Visible = true
            else
                data.Box.Visible = false
            end
        end

        -- Name ESP
        if NameEnabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local distance = humanoid and (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude or 999
            data.Name.Text = player.DisplayName .. "\n" .. player.Name .. "\n[" .. math.floor(distance / 5) .. "m]"
            data.Name.Position = Vector2.new(headPos.X, headPos.Y - 35)
            data.Name.Visible = headVisible
        end
-- Skeleton ESP
        if SkeletonEnabled then
            local parts = {}
            local partNames = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
            for _, partName in ipairs(partNames) do
                local part = character:FindFirstChild(partName)
                if part then
                    local pos, visible = WorldToVP(part.Position)
                    parts[partName] = {Position = pos, Visible = visible}
                end
            end

            for i, connection in ipairs(SkeletonConnections) do
                local from = parts[connection[1]]
                local to = parts[connection[2]]
                local line = data.Skeleton[i]
                if from and to and from.Visible and to.Visible then
                    line.From = from.Position
                    line.To = to.Position
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        end
    end
end

local function ManageESPConnection()
    local anyESPEnabled = BoxEnabled or SkeletonEnabled or NameEnabled
    if anyESPEnabled then
        if not ESPConnection then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    AddESP(player)
                end
            end
            if not PlayerAddedConnection then
                PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function()
                        task.wait(0.5)
                        AddESP(player)
                    end)
                end)
            end
            ESPConnection = RunService.Heartbeat:Connect(UpdateESP)
        end
    else
        if ESPConnection then
            ESPConnection:Disconnect()
            ESPConnection = nil
        end
        if PlayerAddedConnection then
            PlayerAddedConnection:Disconnect()
            PlayerAddedConnection = nil
        end
        for player, _ in pairs(ESPData) do
            RemoveESP(player)
        end
        ESPData = {}
    end
end

-- ESP Toggles
ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Callback = function(Value)
        BoxEnabled = Value
        ManageESPConnection()
    end
})

ESPTab:CreateToggle({
    Name = "Skeleton ESP",
    CurrentValue = false,
    Callback = function(Value)
        SkeletonEnabled = Value
        ManageESPConnection()
    end
})

ESPTab:CreateToggle({
    Name = "Nametag ESP",
    CurrentValue = false,
    Callback = function(Value)
        NameEnabled = Value
        ManageESPConnection()
    end
})

ESPTab:CreateToggle({
    Name = "Только враги (Team Check)",
    CurrentValue = false,
    Callback = function(Value)
        TeamCheckEnabled = Value
    end
})

ESPTab:CreateSlider({
    Name = "Размер Hitbox",
    Range = {8, 50},
    Increment = 2,
    Suffix = "",
    CurrentValue = 12,
    Flag = "HitboxSize",
    Callback = function(Value)
        HitboxSize = Value
    end
})

ESPTab:CreateToggle({
    Name = "Hitbox Expander (HBE)",
    CurrentValue = false,
    Callback = function(Value)
        HitboxEnabled = Value
        if Value then
            HitboxConnection = RunService.Stepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer or (TeamCheckEnabled and player.Team == LocalPlayer.Team) then continue end
                    local character = player.Character
                    if character then
                        for _, part in ipairs(character:GetChildren()) do
if part:IsA("BasePart") then
                                part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                                part.Transparency = 0.7
                            end
                        end
                    end
                end
            end)
        else
            if HitboxConnection then
                HitboxConnection:Disconnect()
                HitboxConnection = nil
            end
        end
    end
})
