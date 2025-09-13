local Library = loadstring(game:HttpGet("https://pastebin.com/raw/MZrwt5Rm", true))()

local Library = loadstring(HttpGet("https://raw.githubusercontent.com/Robojini/Tuturial_UI_Library/main/UI_Template_1"))()
 
local Window = Library.CreateLib("Universal script", "RJTheme3")

local Tab = Window:NewTab("Main")

local Section = Tab:NewSection("Misc")

Section:NewSlider("WalkSpeed", "SliderInfo", 500, 0, function(s) 
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

Section:NewSlider("JumpPower", "SliderInfo", 1000, 50, function(J)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = j
end)

Section:NewSlider("MaxHealh", "SliderInfo", 10000, 100, function(H)
    game.Players.LocalPlayer.Character.Humanoid.MaxHealh = H
end)

local Section = Tab:NewSection("Soon...")

local Tab = Window:NewTab("Other")

local Section = Tab:NewSection("Soon...")
