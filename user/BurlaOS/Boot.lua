-- ASCII Art
local art = [[
 __        __                __   __  
|__) |  | |__) |     /\     /  \ /__` 
|__) \__/ |  \ |___ /~~\    \__/ .__/ 
                                      

]]

-- Path to bootmenu
local bootmenuPath = "/user/BurlaOS/bootmenu"
-- Path to loggin
local logginPath = "/user/BurlaOS/loggin"

-- Function to search for monitors
local function findMonitor()
  -- Find attached monitors
  local monitor = peripheral.find("monitor")

  -- If no attached monitor found, search through a wired modem
  if not monitor then
    local modem = peripheral.find("wired_modem")
    if modem then
      modem.transmit(tonumber(os.getComputerID()), tonumber(rednet.CHANNEL_BROADCAST), "monitors")
      local _, monitorSide, _, _ = os.pullEvent("modem_message")
      if monitorSide and peripheral.getType(monitorSide) == "monitor" then
        monitor = peripheral.wrap(monitorSide)
      end
    end
  end

  return monitor
end

-- Function to center ASCII art on the screen
local function centerArt()
  local w, h = term.getSize()
  local lines = {}

  -- Split the art into individual lines
  for line in art:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  -- Calculate coordinates to center the art vertically
  local y = math.floor((h - #lines) / 2)

  -- Show the centered art
  term.setBackgroundColor(colors.black)
  term.clear()
  for i, line in ipairs(lines) do
    local x = math.floor((w - #line) / 2) + 1
    term.setCursorPos(x, y + i - 1)
    term.setTextColor(colors.cyan)
    term.write(line)
  end
end

-- Check if Space key is pressed
local function checkSpaceKey()
  while true do
    local _, key = os.pullEvent("key")
    if key == keys.space then
      term.setBackgroundColor(colors.black)
      term.clear()
      local success, errorMessage = pcall(shell.run, bootmenuPath)
      term.setBackgroundColor(colors.black)
      term.clear()
      if not success then
        term.setTextColor(colors.red)
        print("Error executing bootmenu:")
        print(errorMessage)
      end
      break
    end
  end
end

-- Search for a monitor
local monitor = findMonitor()

-- If a monitor is found, display the ASCII art on both the monitor and computer simultaneously
if monitor then
  term.redirect(monitor)
  centerArt()
  term.redirect(term.native())
else
  -- Display the ASCII art on the computer's screen
  centerArt()
end

-- Start a thread to check the Space key
local spaceKeyThread = parallel.waitForAny(checkSpaceKey)

-- Clear the screen before exiting
term.setBackgroundColor(colors.black)
term.clear()

-- Close the boot program if the Space key was not pressed
if spaceKeyThread == 0 then
  local success, errorMessage = pcall(shell.run, logginPath)
  if not success then
    term.setTextColor(colors.red)
    print("Error executing loggin:")
    print(errorMessage)
  end
end

-- Close the boot program
local success, errorMessage = pcall(os.run, {}, "/rom/programs/shell.lua")
if not success then
  term.setTextColor(colors.red)
  print("Error closing the boot program:")
  print(errorMessage)
end
