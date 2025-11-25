local LoadGuiRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes").ServerToClient.LoadGuiRemote

local handler = {}

handler.Profiles = {}


local function getDupes(plr, attributes:string)

	local profile = handler.Profiles[plr]

	if profile and profile.Data and profile.Data.Inventory then
		
		if profile.Data.Inventory[attributes] then
			profile.Data.Inventory[attributes] += 1
		else
			profile.Data.Inventory[attributes] = 1
		end
		
		LoadGuiRemote:FireClient(plr, attributes, 1)
	else
		warn("Player", plr, "has received an interal error loading data. Please report this.")
	end
end


function handler.giveNone(plr)
	getDupes(plr, "None")
end

function handler.giveShape(plr, attributes:string)
	getDupes(plr, attributes)
end

return handler
