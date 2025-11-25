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