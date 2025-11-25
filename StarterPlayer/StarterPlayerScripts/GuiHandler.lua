local player = game.Players.LocalPlayer
local plrGui = player.PlayerGui

local gui = plrGui:WaitForChild("Inventory")
local uis = game:GetService("UserInputService")


uis.InputBegan:Connect(function(keydown, gp)
	if gp then return end
	
	if keydown.KeyCode == Enum.KeyCode.Q then
		gui.Enabled = not gui.Enabled
	end
end)