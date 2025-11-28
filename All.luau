--ServerScriptService

--ServerScriptService/ProfileStoreHandler/ProfileStore.luau
--The file is the same as normal ProfileStore module, not gonna add it because it wastes space
--Reference to the file:https://github.com/MadStudioRoblox/ProfileStore/blob/main/ProfileStore.luau (by loleris)

--ServerScriptService/MainSystems/ProfileStoreHandler.luau

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local rs = game:GetService("ReplicatedStorage")
local ss = game:GetService("ServerStorage")

local ServerToClient = rs:WaitForChild("Remotes").ServerToClient

local ProfileStore = require(script.ProfileStore)
local DataHandler = require(game:GetService("ServerStorage"):WaitForChild("Modules").DataHandler)

local DataTemplate = require(script.ProfileStore.DataTemplate)

local function store_type()
	return RunService:IsStudio() and "Test" or "Live"
end

local ProfileHandler = ProfileStore.New(store_type(), DataTemplate)

local function initialize(plr:Player, profile:typeof(NEW_PROFILE:StartSessionAsync()))
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = plr
	
	local coins = Instance.new("IntValue") -- i setup leaderstas :D
	coins.Name = "Coins"
	coins.Parent = leaderstats
	coins.Value = profile.Data.coins
	
	ServerToClient.InitialGuiLoad:FireClient(plr, profile.Data.Inventory)
end

-- thing happens when player joins, makes everything work
local function playerAdded(plr:Player)
	
	-- new profile creation
	local profile = ProfileHandler:StartSessionAsync("Player_" .. plr.UserId, {
		Cancel = function()
			return plr.Parent ~= Players -- checks if the player is parented to players, returns false if it is
		end,
	})
	
	-- check if the player exists?
	if profile ~= nil then
		profile:AddUserId(plr.UserId)
		profile:Reconcile()
		
		-- "session locking", fires when EndSession()
		profile.OnSessionEnd:Connect(function()
			DataHandler.Profiles[plr] = nil
			plr:Kick("data error")
		end)
		
		
		if plr.Parent == Players then
			DataHandler.Profiles[plr] = profile
			initialize(plr, profile)
		else
			profile:EndSession()
		end
		
		
	else
		plr:Kick("data error")
	end
	
end

-- if they manage to join early
for _, plr in Players:GetPlayers() do
	task.spawn(playerAdded, plr)
end

Players.PlayerAdded:Connect(playerAdded)

Players.PlayerRemoving:Connect(function(plr)
	local profile = DataHandler.Profiles[plr]
	if not profile then return end
	
	profile:EndSession()
end)


--ServerScriptService/MainSystems/CollectedPart.luau

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


--ServerScriptService/MainSystems/SpawnerMain.luau

local Spawner = require(script.Spawner)

local PARTS = game.Workspace.PARTS

local new_spawner = Spawner.new(Vector3.new(0, 70, 0), 250)

while task.wait(0.05) do
	new_spawner:spawn()
end


--ServerScriptService/MainSystems/SpawnerMain/Spawner.luau

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


--ServerScriptService/MainSystems/SpawnerMain/Spawner/Attributes.luau

local rs = game:GetService("ReplicatedStorage")

local Modules = rs:WaitForChild("Modules")

local chances = require(Modules.SharedModules.AttributeConfigs)

local stringifier = require(Modules.SharedModules:WaitForChild("Stringifier"))

local RARE_RNG = 25000

local Attributes = {}
Attributes.__index = Attributes


function Attributes.roll(part:Part)

	local rolledAttributes = {}

	local rng = 1

	for name, attribute in pairs(chances) do
		
		if not attribute.available then continue end
		
		local chance = math.random(1, attribute.chance)

		if chance == attribute.chance then

			rng *= chance
			rolledAttributes[attribute.index] = name
			attribute._function(part)

		end
	end

	local concatAttributes = stringifier.concat(stringifier.sort_array(rolledAttributes, stringifier.getkey(rolledAttributes))) -- The original table is an ipairs table with gaps and incorrectly ordered keys, this makes them correctly ordered

	if concatAttributes == "|" then concatAttributes = "None" end

	part:SetAttribute("Attributes", concatAttributes)
end

return Attributes




--ServerStorage
--ServerStorage/Modules/DataHandler.luau

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


--ReplicatedStorage/Modules/ClientModules/LoadGui.luau


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

--ReplicatedStorage/Modules/SharedModules/Stringifier.luau
local rngIndex = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SharedModules"):WaitForChild("AttributeConfigs"))

local stringifier = {}

--Gets the rng of an attribute string
function stringifier.getrng(attributes:NumberArray)
	
	local rng = 1
	for _, attribute in attributes do
		if rngIndex[attribute] then
			rng *= rngIndex[attribute].chance
		end
	end
	
	return rng
end

--Self explanatory
function stringifier.deconcat(attributes)

	local deconcatenated_attributes = {}


	for thing in string.gmatch(attributes, "[^|]+") do
		if thing ~= "" then
			table.insert(deconcatenated_attributes, thing)
		end
	end


	return table.sort(deconcatenated_attributes) == nil and deconcatenated_attributes or table.sort(deconcatenated_attributes)
end

--Self explanatory
function stringifier.concat(attributes)

	local key = "|"

	for _, attribute in ipairs(stringifier.sort_array(attributes, stringifier.getkey(attributes))) do
		key = key .. attribute .. "|"
	end

	return key
end

--Gets the highest key of the array
function stringifier.getkey(broken_array)
	local highest_key = 0
	for i, v in pairs(broken_array) do

		if type(i) ~= "number" then
			broken_array[i] = nil
			broken_array[tonumber(i)] = v
		end

		if tonumber(i) > highest_key then
			highest_key = tonumber(i)
		end
	end
	return highest_key
end

--Sorts a number array up to the highest key, inclusive
function stringifier.sort_array(broken_array, highest_key)
	local NumberArray = {}

	for i = 1, highest_key, 1 do
		if broken_array[i] then
			table.insert(NumberArray, broken_array[i])
		end
	end

	return NumberArray
end

--Gives a number a prefix, prototype
function stringifier.prefixify(number) -- much thanks to miners haven wiki for the prefixes
	if type(number) ~= "number" then number = tonumber(number) end

	if number >= 1e33 then
		number = number / 1e33
		number = tostring(number) .. "de"
	elseif number >= 1e30 then
		number = number / 1e30
		number = tostring(number) .. "N"
	elseif number >= 1e27 then
		number = number / 1e27
		number = tostring(number) .. "O"
	elseif number >= 1e24 then
		number = number / 1e24
		number = tostring(number) .. "Sp"
	elseif number >= 1e21 then
		number = number / 1e21
		number = tostring(number) .. "sx"
	elseif number >= 1e18 then
		number = number / 1e18
		number = tostring(number) .. "Qn"
	elseif number >= 1e15 then
		number = number / 1e15
		number = tostring(number) .. "qd"
	elseif number >= 1e12 then
		number = number / 1e12
		number = tostring(number) .. "T"
	elseif number >= 1e9 then
		number = number / 1e9
		number = tostring(number) .. "B"
	elseif number >= 1e6 then
		number = number / 1e6
		number = tostring(number) .. "M"
	elseif number >= 1e3 then
		number = number / 1e3
		number = tostring(number) .. "K"
	end

	return number
end


return stringifier


--ReplicatedStorage/Modules/SharedModules/AttributeConfigs.luau

return {
	Studded = {
		chance = 25,
		index = 1,
		available = true,
		_function = function (part: Part)
			part.Material = Enum.Material.Plastic
			for _, surface in pairs(Enum.NormalId:GetEnumItems()) do
				part[surface.Name .. "Surface"] = Enum.SurfaceType.Studs
			end
		end
	},

	Giant = {
		chance = 100,
		index = 2,
		available = true,
		_function = function (part: Part)
			part.Size *= 2
		end
	},

	Triangulated = {
		chance = 2500,
		index = 3,
		available = true,
		_function = function (part: Part)
			part.Shape = Enum.PartType.Wedge
		end
	},

	Sparkling = {
		chance = 1000,
		index = 4,
		available = true,
		_function = function (part: Part)
			local sparkles = Instance.new("Sparkles")
			sparkles.Parent = part
		end,
	},

	Neon = {
		chance = 25,
		index = 5,
		available = true,
		_function = function (part: Part)
			part.Material = Enum.Material.Neon
		end,
	},

	Tiny = {
		chance = 1000,
		index = 6,
		available = true,
		_function = function (part: Part)
			part.Size /= 2
		end,
	},

	Transparent = {
		chance = 50,
		index = 7,
		available = true,
		_function = function (part: Part)
			part.Transparency = 0.5
		end,
	},

	Huge = {
		chance = 50000,
		index = 8,
		available = true,
		_function = function (part:Part)
			part.Size *= 5
		end,
	},

	Shiny = {
		chance = 500,
		index = 9,
		available = true,
		_function = function (part:Part)
			part.Reflectance = 0.5
		end,
	}
}


--StarterPlayerScripts/GuiHandler.luau

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


--StarterPlayerScripts/GuiLoader.luau

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

--StarterPlayerScripts/ObjectHit.luau

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
