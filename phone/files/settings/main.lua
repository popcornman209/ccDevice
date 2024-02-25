function enterPass(thingToWrite,matters)
    if pass ~= false or matters == false then
        term.setBackgroundColor(bgColor)
        term.setTextColor(txtColor)
        term.clear()
        write(thingToWrite,3)
        term.setBackgroundColor(buttonColor)

        term.setCursorPos(11, 6)
        term.write("1")
        term.setCursorPos(13, 6)
        term.write("2")
        term.setCursorPos(15, 6)
        term.write("3")
        term.setCursorPos(11, 8)
        term.write("4")
        term.setCursorPos(13, 8)
        term.write("5")
        term.setCursorPos(15, 8)
        term.write("6")
        term.setCursorPos(11, 10)
        term.write("7")
        term.setCursorPos(13, 10)
        term.write("8")
        term.setCursorPos(15, 10)
        term.write("9")
        term.setCursorPos(13, 12)
        term.write("0")

        term.setBackgroundColor(colors.red)
        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
        term.setCursorPos(11, 12)
        term.write("X")
        term.setBackgroundColor(colors.lime)
        if bgColor == colors.green then term.setBackgroundColor(colors.green) end
        term.setCursorPos(15, 12)
        term.write(">")

        input = ""
        term.setBackgroundColor(bgColor)
        goingasd = true
        while goingasd do
                paintutils.drawBox(1,4,26,4,bgColor)
                term.setCursorPos(14-string.len(input)/2, 4)
                for i = 1,string.len(input) do term.write("*") end
                event, button, x, y = os.pullEvent("mouse_click")
                if x == 11 and y == 6 then input = input..1
                elseif x == 13 and y == 6 then input = input..2
                elseif x == 15 and y == 6 then input = input..3
                elseif x == 11 and y == 8 then input = input..4
                elseif x == 13 and y == 8 then input = input..5
                elseif x == 15 and y == 8 then input = input..6
                elseif x == 11 and y == 10 then input = input..7
                elseif x == 13 and y == 10 then input = input..8
                elseif x == 15 and y == 10 then input = input..9
                elseif x == 11 and y == 12 then input = ""
                elseif x == 13 and y == 12 then input = input..0
                elseif x == 15 and y == 12 then goingasd = false end
        end
        correct = false
        if input == pass then correct = true end
        return correct, input
    elseif matters == true then return false,"noPass"
    end
end

colorList = {colors.black, colors.blue, colors.brown, colors.cyan, colors.gray, colors.green, colors.lightBlue, colors.lightGray, colors.lime, colors.magenta, colors.orange, colors.pink, colors.purple, colors.red, colors.white, colors.yellow}

function find(tabel, thing)
    for i = 1,table.getn(tabel) do
        if tabel[i] == thing then
            return i
        end
    end
    return false
end

function drawMenu()
    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(1,1)
    term.write("<")
    term.setBackgroundColor(bgColor)
    write("main settings",2)
    write("background color:", 4)
    write("text color:", 7)
    write("secondary color:", 10)
    term.setBackgroundColor(buttonColor)
    paintutils.drawBox(8,14,19,14)
    write("password", 14)
    term.setBackgroundColor(colors.lime)
    if bgColor == colors.green then term.setBackgroundColor(colors.green) end
    paintutils.drawBox(8,19,19,19)
    write("apply.", 19)

    term.setBackgroundColor(buttonColor)
    term.setCursorPos(7,5)
    term.write("<")
    term.setCursorPos(7,8)
    term.write("<")
    term.setCursorPos(7,11)
    term.write("<")
    term.setCursorPos(19,5)
    term.write(">")
    term.setCursorPos(19,8)
    term.write(">")
    term.setCursorPos(19,11)
    term.write(">")
end
drawMenu()

bg = find(colorList, bgColor)
txt = find(colorList, txtColor)
sec = find(colorList, buttonColor)
settings.load("data/main")
pass = getSetting("pass",false)

going = true
while going do
    paintutils.drawBox(8,5,18,5,colorList[bg])
    paintutils.drawBox(8,8,18,8,colorList[txt])
    paintutils.drawBox(8,11,18,11,colorList[sec])
    event, button, x, y = os.pullEvent("mouse_click")
    if x == 1 and y == 1 then going = false

    elseif x == 7 and y == 5 then bg = bg-1
    elseif x == 19 and y == 5 then bg = bg+1
    elseif x == 7 and y == 8 then txt = txt-1
    elseif x == 19 and y == 8 then txt = txt+1
    elseif x == 7 and y == 11 then sec = sec-1
    elseif x == 19 and y == 11 then sec = sec+1

    elseif x >= 8 and x <= 19 and y == 14 then
        correct, entered = enterPass("enter orgininal pass:",true)
        write(entered, 1)
        if correct or entered == "noPass" then
            correct, entered1 = enterPass("enter new pass:",false)
            correct, entered2 = enterPass("verify new pass:",false)
            if entered1 == entered2 then
                pass = entered1
                if entered1 == "" then pass = false end
            end
        end
        drawMenu()
    elseif x >= 8 and x <= 19 and y == 19 then
        term.setBackgroundColor(bgColor)
        if bg == sec or bg == txt or sec == txt then
            write("invalid colors.",20)
        else
            settings.clear()
            settings.load("data/main")
            settings.set("bgColor",colorList[bg])
            settings.set("txtColor",colorList[txt])
            settings.set("buttonColor",colorList[sec])
            settings.set("pass",pass)
            settings.save("data/main")
            write("saved, restart to apply.",20)
        end
    end
    
    len = table.getn(colorList)
    if bg > len then bg = 1
    elseif bg < 1 then bg = len
    end
    if txt > len then txt = 1
    elseif txt < 1 then txt = len
    end
    if sec > len then sec = 1
    elseif sec < 1 then sec = len
    end
end