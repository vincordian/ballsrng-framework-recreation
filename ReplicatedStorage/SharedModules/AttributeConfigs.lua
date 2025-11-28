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