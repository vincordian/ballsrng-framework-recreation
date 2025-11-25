local rs = game:GetService("ReplicatedStorage")

local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local mouse = player:GetMouse()

local Remotes = rs:WaitForChild("Remotes")

local ClientToServer = Remotes:WaitForChild("ClientToServer")

mouse.Button1Down:Connect(function()
	local target = mouse.Target
	
	if target and target.Parent == workspace.PARTS and target:IsA("BasePart") then
		
		
		if target:GetAttribute("Attributes") then
			ClientToServer.PartCollected:FireServer(target)
		end
		
	end
end)