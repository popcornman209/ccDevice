---@diagnostic disable: undefined-global, undefined-field

local wrappers = {}
for i, chest in pairs(chests) do
	table.insert(wrappers, function()
		contents[i] = chests[i].list()
	end)
end

function getChestContents()
	contents = {}
	parallel.waitForAll(table.unpack(wrappers))
	return contents
end

function getItems()
	items = {}
	chestContents = getChestContents()
	for i, chestContent in pairs(chestContents) do
		if #chestContent >= 0 then
			for j, item in pairs(chestContent) do
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

function clear(text, menu)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, resY)
	term.write(text)
	paintutils.drawBox(1, 1, resX, 1, colors.gray)
	term.setCursorPos(resX / 2 - #menu / 2, 1)
	term.write(menu)
	term.setBackgroundColor(colors.black)
end

function drawChoices(scroll, choices, menu)
	clear("(up/down/enter/back): navigate", menu)
	for i = 1 + scroll, math.min(#choices, (resY - 4) + scroll) do
		term.setCursorPos(4, i + 2 - scroll)
		print(choices[i])
	end
end

function getChoice(choices, back, menu)
	cursorPos = 1
	scroll = 0
	drawChoices(scroll, choices, menu)
	going = true
	while going do
		paintutils.drawBox(2, 3, 2, resY - 2)
		term.setCursorPos(2, cursorPos + 2 - scroll)
		print(">")
		event, key = os.pullEvent("key")
		if key == 265 then
			cursorPos = math.max(cursorPos - 1, 1)
			if cursorPos < 1 + scroll then
				scroll = scroll - 1
				drawChoices(scroll, choices, menu)
			end
		elseif key == 264 then
			cursorPos = math.min(cursorPos + 1, #choices)
			if cursorPos > (resY - 4) + scroll then
				scroll = scroll + 1
				drawChoices(scroll, choices, menu)
			end
		elseif key == 257 then
			going = false
			return cursorPos
		elseif key == 259 and back then
			going = false
			return false
		end
	end
end

function enterToContinue()
	repeat
		event, key = os.pullEvent("key")
	until key == 257
end

