---@diagnostic disable: undefined-global, undefined-field

chests = { peripheral.find("inventory") }

term.clear()
term.setCursorPos(1, 1)

values = {}
for i, chest in pairs(chests) do
	values[i] = #chest.list()
end

print("move an item in/out of the main chest and press enter...")
read()

for i, chest in pairs(chests) do
	if values[i] ~= #chest.list() then
		id = i
		name = peripheral.getName(chest)
		print("id: " .. id .. "\nname: " .. name)
	end
end

print("save to config? [y/n] ")
if read() == "y" then
	settings.clear()
	settings.load("data/nas")
	settings.set("mainChest", name)
	if settings.get("ignore") == nil then
		settings.set("ignore", {})
	end
	settings.save("data/nas")
end

