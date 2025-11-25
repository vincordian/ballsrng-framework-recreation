local Attributes = require(script.Attributes)

local Debris = game:GetService("Debris")

local Spawner = {}
Spawner.__index = Spawner

function Spawner.new(pos:Vector3, displacement:number)
	local self = setmetatable({}, Spawner)
	self.Pos = pos
	self.Displacement = displacement
	return self
end


function Spawner:spawn()
	self.Part = Instance.new("Part")
	self.Part.Material = Enum.Material.SmoothPlastic
	self.Part.Size = Vector3.new(5, 5, 5)
	self.Part.Position = self.Pos + Vector3.new(math.random(-self.Displacement, self.Displacement), 0, math.random(-self.Displacement, self.Displacement))
	self.Part.Anchored = false
	
	self.Part.Parent = workspace.PARTS
	
	Debris:AddItem(self.Part, 30)
	
	Attributes.roll(self.Part)
end


return Spawner