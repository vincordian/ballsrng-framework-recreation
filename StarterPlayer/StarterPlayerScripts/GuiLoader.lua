local rs = game:GetService("ReplicatedStorage")

local Remotes = rs:WaitForChild("Remotes")

local ServerToClient = Remotes:WaitForChild("ServerToClient")

local Modules = rs:WaitForChild("Modules")

local loader = require(Modules.ClientModules.LoadGui)

local stringifier = require(Modules.SharedModules:WaitForChild("Stringifier"))

local gui = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Inventory").Main.InventoryFrame.ScrollingFrame

local function get_size()
	local x = workspace.CurrentCamera.ViewportSize.X
	local y = workspace.CurrentCamera.ViewportSize.Y
	
	if x > y * 2 then
		x /= 2
	elseif y > x * 2 then
		y /= 2
	end
	
	return (x + y) / 2
end

local size = get_size()

gui.UIGridLayout.CellSize = UDim2.fromOffset(size / 10, size / 10)

ServerToClient.LoadGuiRemote.OnClientEvent:Connect(function(attributes, count)
	if attributes == "None" then
		loader:loadNone(stringifier.prefixify(count))
	else
		loader:loadAttributes(attributes, stringifier.prefixify(count))
	end
end)

ServerToClient.InitialGuiLoad.OnClientEvent:Connect(function(attributesTable)
	loader:loadInitial(attributesTable)
end)