local wrappers = {}
---@diagnostic disable-next-line: undefined-global
for i, _ in pairs(chests) do
	table.insert(wrappers, function()
		---@diagnostic disable-next-line: undefined-global
		contents[i] = chests[i].list()
	end)
end

function GetChestContents()
	local contents = {}
	parallel.waitForAll(table.unpack(wrappers))
	return contents
end

function GetItems()
	local items = {}
	local chestContents = GetChestContents()
	for _, chestContent in pairs(chestContents) do
		if #chestContent >= 0 then
			for _, item in pairs(chestContent) do
				if items[item["name"]] then
					items[item["name"]] = items[item["name"]] + item["count"]
				else
					items[item["name"]] = item["count"]
				end
			end
		end
	end
	return items
end

function EnterToContinue()
	local key = nil
	repeat
		_, key = os.pullEvent("key")
	until key == 257
end
