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