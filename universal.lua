local Library = loadstring(HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()
 
local Window = Library.CreateLib("Universal script", "RJTheme3")

local Tab = Window:NewTab("Main")

local Section = Tab:NewSection("Misc")

Section:NewToggle("Noclip", "???" function(state)
    if state then
        game.RunService.Stepped:Connect(function() game.Players.LocalPlayer.Character.Head.CanCollide = false game.Players.LocalPlayer.Character.Torso.CanCollide = false end)
    else
        game.RunService.Stepped:Connect(function() game.Players.LocalPlayer.Character.Head.CanCollide = true game.Players.LocalPlayer.Character.Torso.CanCollide = true end)
    end
end)

Section:NewSlider("WalkSpeed", "Flash", 500, 0, function(s) 
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)



local Section = Tab:NewSection("Soon...")

local Tab = Window:NewTab("Other")

local Section = Tab:NewSection("Soon...")
