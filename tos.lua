UiWindow = {}
UiManager = {}
UiTaskbar = {}
function clearUI()--Clear UI
    term.setBackgroundColour(colours.black)
    term.clear()
end
function UiWindow.new(sizeX, sizeY)--UiWindow constructor
    x = 1
    y = 1
    visibility = false
    focused = false
    currentWindow = window.create(term.current(), x, y, sizeX, sizeY, visibility)
    currentWindow.setBackgroundColour(colours.white)
    currentWindow.clear()
    return setmetatable({sizeX = sizeX, sizeY = sizeY, visibility = visibility,
        currentWindow = currentWindow, focused = focused
    }, { __index = UiWindow })
end
function UiWindow:createHeader(title, focused)--Set title of window
    self.title = title
    self.focused = focused
    self.currentWindow.setCursorPos(1,1)
    if(focused) then
        self.currentWindow.setBackgroundColour(colours.blue)
        self.currentWindow.setTextColour(colours.blue)
    else
        self.currentWindow.setBackgroundColour(colours.lightBlue)
        self.currentWindow.setTextColour(colours.lightBlue)
    end
    self.currentWindow.write(string.rep("#",self.sizeX))
    self.currentWindow.setCursorPos(self.sizeX-2,1)
    self.currentWindow.setBackgroundColour(colours.orange)
    self.currentWindow.setTextColour(colours.orange)
    self.currentWindow.write("#")
    self.currentWindow.setBackgroundColour(colours.green)
    self.currentWindow.setTextColour(colours.green)
    self.currentWindow.write("#")
    self.currentWindow.setBackgroundColour(colours.red)
    self.currentWindow.setTextColour(colours.red)
    self.currentWindow.write("#")
    self.currentWindow.setCursorPos(2,1)
    if focused then
        self.currentWindow.setBackgroundColour(colours.blue)
    else
        self.currentWindow.setBackgroundColour(colours.lightBlue)
    end
    self.currentWindow.setTextColour(colours.white)
    self.currentWindow.write(self.title)
    self.currentWindow.redraw()

end
function UiWindow:move(x,y)--Move window
    self.currentWindow.reposition(x, y)
end
function UiWindow:redraw()--Redraw window
    self.currentWindow.redraw()
end
function UiWindow:visible(visible)--Change visibility
    self.currentWindow.setVisible(visible)
end
function UiWindow:easywrite(text, x, y)--Write text directly to window
    self.currentWindow.setCursorPos(x+1,y+1)
    self.currentWindow.setBackgroundColour(colours.white)
    self.currentWindow.setTextColour(colours.black)
    self.currentWindow.write(text)
end
function UiWindow:focus(f)--Change focus on window
    self:createHeader(self.title,f)
end
function UiWindow:checkclick(clickx,clicky)--Check if window has been clicked
    posX, posY = self.currentWindow.getPosition()
    if(clickx>=posX) and (clickx<=(posX+self.sizeX)) then
        if(clicky>=posY) and (clicky<=(posY+self.sizeY)) then
            return true
        end
    end
    return false
end
function UiWindow:checkheadbutton(x,y)--Check if head button was pressed
    if self:checkclick(x,y) then--Check if the window was even clicked
        posX, posY = self.currentWindow.getPosition()
        winX = x-posX+1--X position within the window, starts at 1
        winY = y-posY+1
        if winY==1 then--If on taskbar
            if winX==self.sizeX then
                return 1--X button has been clicked
            end
            if winX==self.sizeX-1 then
                return 2--Resize button has been clicked
            end
            if winX==self.sizeX-2 then
                return 3--Minimize button has been clicked
            end
            return 0
        end
    end
end
function UiManager.new()--UiManager constructor
    winarray = {}
    return setmetatable({winarray = winarray}, { __index = UiManager })
end
function UiManager:updateUI()--Update the UI
    clearUI()
    for i = 1, #self.winarray do
        self.winarray[i]:redraw()
        self.winarray[i]:visible(true)
    end
end
function UiManager:windowclicked(x,y)--Check if any window has been clicked
    for i = 1, #self.winarray do
        if self.winarray[i]:checkclick(x,y) then
            return true
        end
    end
    return false
end
manager = UiManager.new()--Creating manager object
winmanager = function()
    for i=1, 3 do--Creating 3 window objects
        winobj = UiWindow.new(15,10)
        winobj:createHeader("Window "..i, false)
        winobj:move(1+16*(i-1),1)
        table.insert(manager.winarray,winobj)
    end
    manager:updateUI()
    while true do--Main loop to interact with windows
        local event, button, x, y = os.pullEvent()
        if (event=="mouse_click") and (button==1) then
            --Changes focus of windows
            for i = 1, #manager.winarray do
                manager.winarray[i]:focus(false)
            end
            if(manager:windowclicked(x,y)) then
                for i = 1, #manager.winarray do
                    winobj = manager.winarray[i]
                    appendwin = true
                    if winobj:checkclick(x,y) then
                        winobj:focus(true)
                        --Window specific functions
                        controlbutton = winobj:checkheadbutton(x,y)
                        if controlbutton==1 then
                            appendwin = false
                        end
                        winobj:easywrite("Button    ",1,1)

                        winobj:easywrite(controlbutton,8,1)
                        --Window specific end code
                        table.remove(manager.winarray, i)
                        if(appendwin) then
                            table.insert(manager.winarray, winobj)
                        end
                        break
                    end
                end
            end
            manager:updateUI()
        end
        if (event=="mouse_drag") and (button==1) then
            for i = 1, #manager.winarray do
                if manager.winarray[i].focused then
                    manager.winarray[i]:move(x,y)
                    break
                end
            end
            manager:updateUI()
        end
    end
end
parallel.waitForAny(winmanager)
