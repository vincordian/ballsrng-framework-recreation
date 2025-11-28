local rs = game:GetService("ReplicatedStorage")

local Modules = rs:WaitForChild("Modules")

local stringifier = require(Modules.SharedModules:WaitForChild("Stringifier"))

local chances = require(Modules.SharedModules.AttributeConfigs)

local guiTemplate = rs.GuiModels.PlaceholderShapeGui

local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("InventoryFrame")

local scrollingFrame = gui:WaitForChild("ScrollingFrame")

local viewport = gui:WaitForChild("ShapeViewport")

local limitedText = gui:WaitForChild("LimitedAttributesLabel")

local function viewportframe(attributes)
	for _, thing in viewport:GetDescendants() do
		thing:Destroy()
	end
	
	local part = Instance.new("Part")
	part.Position = Vector3.new(0, 0, 0)
	part.Size = Vector3.new(5, 5, 5)
	part.FrontSurface = Enum.SurfaceType.Smooth
	part.BackSurface = Enum.SurfaceType.Smooth
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	
	local limitedAttributes = {}
	
	for _, attribute in ipairs(attributes) do
		
		if attribute == "None" then limitedAttributes = nil break end
		if not chances[attribute] then table.insert(limitedAttributes, attribute) continue end
		if not chances[attribute].available then table.insert(limitedAttributes, attribute) continue end
		
		chances[attribute]._function(part)
	end
	
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(0, 0, 5 + part.Size.Z)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	part.Parent = viewport
	
	if limitedAttributes == nil or next(limitedAttributes) == nil then
		limitedText.Text = "Limited Attributes: None"
	else
		limitedText.Text = "Limited Attributes: ".. table.concat(limitedAttributes, ", ")
	end
	
	while part.Parent ~= nil do
		part.Orientation += Vector3.new(0, 0.5, 0)
		task.wait()
	end
end

local function createUI(rng:number, attributes:string, count:number, name:string)
	local gui = guiTemplate:Clone()

	gui.Name = name
	gui.RarityText.Text = "1 in " .. rng
	gui.AttributeText.Text = table.concat(attributes, ", ")
	gui.CountText.Text = count .. "x"
	gui.Parent = scrollingFrame

	gui:SetAttribute("count", count)

	gui.MouseButton1Click:Connect(function()
		viewportframe(attributes)
	end)
end


local function findUI(name:string)
	local gui = scrollingFrame:FindFirstChild(name)

	if gui then
		gui.CountText.Text = gui:GetAttribute("count") + 1 .. "x"
		gui:SetAttribute("count", gui:GetAttribute("count") + 1)
		return true
	end
end


local loader = {}
loader.__index = loader

function loader:loadAttributes(attributes, count)
	if findUI(attributes) then return end
	
	local deconcat = stringifier.deconcat(attributes)
	
	local rng = stringifier.getrng(deconcat)
	
	self.Type = "Attributes"
	
	createUI(rng, deconcat, count, attributes)
	
end

function loader:loadNone(count)
	if findUI("None") then return end
	
	createUI(1, {"None"}, count, "None")
end

function loader:loadInitial(initialDatas)
	for attributes, count in pairs(initialDatas) do
		if attributes == "None" then
			self:loadNone(count)
		else
			self:loadAttributes(attributes, count)
		end
	end
end

return loader