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
        if pass ~= false then input = digestStr(enterNum("enter orgininal pass:",true,false)) end
        if input == pass or pass == false then
            entered1 = enterNum("enter new pass:",true,false)
            entered2 = enterNum("verify new pass:",true,false)
            if entered1 == entered2 then
                pass = digestStr(entered1)
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