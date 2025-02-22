disks = {"13","cat","blocks","chirp","far","mall","mellohi","stal","strad","ward","11","wait","otherside","5","pigstep"}

speaker = peripheral.wrap("back")
quit = false
while quit == false do
    if peripheral.getType(speaker) == "speaker" then
        choice = getChoice(disks,"disk:",true,"X",string.char(16))
        if choice == "back" then
            quit = true
        elseif choice == "add" then
            speaker.stop()
        else
            speaker.playSound("music_disc."..disks[choice])
        end
    else
        term.setBackgroundColor(bgColor)
        term.clear()
        write("you dont have a speaker!",2)
        os.sleep(2)
        quit = true
    end
end