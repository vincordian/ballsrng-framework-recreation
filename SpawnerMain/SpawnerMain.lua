local Spawner = require(script.Spawner)

local PARTS = game.Workspace.PARTS

local new_spawner = Spawner.new(Vector3.new(0, 70, 0), 250)

while task.wait(0.05) do
	new_spawner:spawn()
end