local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

local ClientToServer = Remotes:WaitForChild("ClientToServer")

local DataHandler = require(game:GetService("ServerStorage"):WaitForChild("Modules").DataHandler)

ClientToServer.PartCollected.OnServerEvent:Connect(function(plr, target:Part)
	
	if not target then return end
	if not plr then return end
	
	local attributes = target:GetAttribute("Attributes")
	
	if not attributes then return end
	
	if attributes == "None" then
		DataHandler.giveNone(plr)
	else
		DataHandler.giveShape(plr, attributes)
	end
	
	target:Destroy()
end)