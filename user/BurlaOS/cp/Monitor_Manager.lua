-- Function to detect and list available monitors
local function detectMonitors()
  local monitors = peripheral.getNames()
  local availableMonitors = {}

  -- Search directly connected monitors
  for _, name in ipairs(monitors) do
    if peripheral.getType(name) == "monitor" then
      table.insert(availableMonitors, { peripheral.wrap(name), "Wired" })
    end
  end

  -- Search monitors through the wireless modem
  local modem = peripheral.find("modem")
  if modem then
    modem.open(123) -- Port for scanning communication
    modem.transmit(123, 123, "scan_monitors") -- Send scan signal

    -- Wait for monitors' response
    local timeout = os.startTimer(5) -- Wait for a maximum of 5 seconds
    while true do
      local event = {os.pullEvent()}
      if event[1] == "modem_message" and event[6] == "scan_monitors_response" then
        table.insert(availableMonitors, { peripheral.wrap(event[4]), "Wireless" }) -- Add monitor to the list
      elseif event[1] == "timer" and event[2] == timeout then
        break -- Timeout reached
      end
    end

    modem.close(123) -- Close the modem port
  end

  return availableMonitors
end

-- Function to display the message on the selected monitor
local function displayMessage(monitor, message, size, color)
  monitor.setTextScale(size)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.setTextColor(color)
  monitor.write(message)
end

-- Function to clear the content of a monitor
local function clearMonitor(monitor)
  monitor.clear()
end

-- Function to clone the content of a monitor to another
local function cloneMonitor(sourceMonitor, targetMonitor)
  local sourceSize = sourceMonitor.getTextScale()
  local sourceTextColor = sourceMonitor.getTextColor()
  local sourceBackgroundColor = sourceMonitor.getBackgroundColor()

  targetMonitor.setTextScale(sourceSize)
  targetMonitor.setTextColor(sourceTextColor)
  targetMonitor.setBackgroundColor(sourceBackgroundColor)

  targetMonitor.clear()

  local sourceX, sourceY = sourceMonitor.getCursorPos()
  sourceMonitor.setCursorPos(1, 1)
  targetMonitor.setCursorPos(1, 1)

  local sourceWidth, sourceHeight = sourceMonitor.getSize()

  for y = 1, sourceHeight do
    sourceMonitor.setCursorPos(1, y)
    local text = read()
    targetMonitor.write(text)
    targetMonitor.setCursorPos(1, y + 1)
  end

  sourceMonitor.setCursorPos(sourceX, sourceY)
end

-- Function to broadcast a message to all monitors
local function broadcastMessage(monitors, message, size, color)
  for _, monitorData in ipairs(monitors) do
    local monitor = monitorData[1]
    displayMessage(monitor, message, size, color)
  end
end

-- Function to clear the screen
local function clearScreen()
  term.clear()
  term.setCursorPos(1, 1)
end

-- Function to display ASCII art
local function displayAsciiArt()
  local asciiArt = [[
 ____ ____  ____ __  __ ____ __     __   _____ 
(  _ (  _ \(  _ (  )(  (  _ (  )   /__\ (  _  )
 )(_) )   / ) _ <)(__)( )   /)(__ /(__)\ )(_)( 
(____(_)\_((____(______(_)\_(____(__)(__(_____)
 __  __ _____ _  _ ____ ____ _____ ____ 
(  \/  (  _  ( \( (_  _(_  _(  _  (  _ \
 )    ( )(_)( )  ( _)(_  )(  )(_)( )   /
(_/\/\_(_____(_)\_(____)(__)(_____(_)\_)
 ___ __  __ ____ ____ ____ 
/ __(  )(  (_  _(_  _( ___)
\__ \)(__)( _)(_  )(  )__) 
(___(______(____)(__)(____)

  ]]

  print(asciiArt)
  sleep(3)
end

-- Clear the screen and display ASCII art
clearScreen()
displayAsciiArt()
sleep(2)
clearScreen()

-- Main program
while true do
  -- Display menu options
  print("1. Edit message on a monitor")
  print("2. Clear a monitor")
  print("3. Clear all monitors")
  print("4. Clone monitor content")
  print("5. Broadcast message to all monitors")
  print("Enter your choice:")
  local choice = tonumber(read())

  -- Clear the screen before showing the menu
  clearScreen()

  if choice == 1 then
    local monitors = detectMonitors()

    if #monitors > 0 then
      -- Monitors found
      print("Detected monitors:")
      for i, monitorData in ipairs(monitors) do
        local monitor = monitorData[1]
        local connectionType = monitorData[2]
        print(i .. ". " .. tostring(monitor) .. " (" .. connectionType .. ")")
      end

      print("Enter the number of the monitor to display the message:")
      local selection = tonumber(read())

      if selection and selection >= 1 and selection <= #monitors then
        print("Enter the message to display on the monitor:")
        local message = read()

        print("Enter the text size (1-5):")
        local size = tonumber(read())

        print("Enter the text color (1-16):")
        local color = tonumber(read())

        local selectedMonitor = monitors[selection][1]
        displayMessage(selectedMonitor, message, size, color)
        print("Message displayed on the selected monitor.")
        read() -- Wait for user input before clearing the screen
      else
        print("Invalid selection.")
        read() -- Wait for user input before clearing the screen
      end
    else
      print("No monitors available.")
      read() -- Wait for user input before clearing the screen
    end

  elseif choice == 2 then
    local monitors = detectMonitors()

    if #monitors > 0 then
      -- Monitors found
      print("Detected monitors:")
      for i, monitorData in ipairs(monitors) do
        local monitor = monitorData[1]
        local connectionType = monitorData[2]
        print(i .. ". " .. tostring(monitor) .. " (" .. connectionType .. ")")
      end

      print("Enter the number of the monitor to clear:")
      local selection = tonumber(read())

      if selection and selection >= 1 and selection <= #monitors then
        local selectedMonitor = monitors[selection][1]
        clearMonitor(selectedMonitor)
        print("Selected monitor cleared.")
        read() -- Wait for user input before clearing the screen
      else
        print("Invalid selection.")
        read() -- Wait for user input before clearing the screen
      end
    else
      print("No monitors available.")
      read() -- Wait for user input before clearing the screen
    end

  elseif choice == 3 then
    local monitors = detectMonitors()

    if #monitors > 0 then
      -- Monitors found
      print("Are you sure you want to clear all monitors? (Y/N)")
      local confirmation = read():lower()

      if confirmation == "y" then
        for _, monitorData in ipairs(monitors) do
          local monitor = monitorData[1]
          clearMonitor(monitor)
        end

        print("All monitors cleared.")
        read() -- Wait for user input before clearing the screen
      else
        print("Operation canceled.")
        read() -- Wait for user input before clearing the screen
      end
    else
      print("No monitors available.")
      read() -- Wait for user input before clearing the screen
    end

  elseif choice == 4 then
    local monitors = detectMonitors()

    if #monitors > 1 then
      -- Monitors found
      print("Detected monitors:")
      for i, monitorData in ipairs(monitors) do
        local monitor = monitorData[1]
        local connectionType = monitorData[2]
        print(i .. ". " .. tostring(monitor) .. " (" .. connectionType .. ")")
      end

      print("Enter the number of the source monitor:")
      local sourceSelection = tonumber(read())

      if sourceSelection and sourceSelection >= 1 and sourceSelection <= #monitors then
        print("Enter the number of the target monitor:")
        local targetSelection = tonumber(read())

        if targetSelection and targetSelection >= 1 and targetSelection <= #monitors and targetSelection ~= sourceSelection then
          local sourceMonitor = monitors[sourceSelection][1]
          local targetMonitor = monitors[targetSelection][1]
          cloneMonitor(sourceMonitor, targetMonitor)
          print("Content cloned from source monitor to target monitor.")
          read() -- Wait for user input before clearing the screen
        else
          print("Invalid target selection.")
          read() -- Wait for user input before clearing the screen
        end
      else
        print("Invalid source selection.")
        read() -- Wait for user input before clearing the screen
      end
    else
      print("Insufficient number of monitors. At least two monitors are required.")
      read() -- Wait for user input before clearing the screen
    end

  elseif choice == 5 then
    local monitors = detectMonitors()

    if #monitors > 0 then
      -- Monitors found
      print("Enter the message to broadcast to all monitors:")
      local message = read()

      print("Enter the text size (1-5):")
      local size = tonumber(read())

      print("Enter the text color (1-16):")
      local color = tonumber(read())

      broadcastMessage(monitors, message, size, color)
      print("Message broadcasted to all monitors.")
      read() -- Wait for user input before clearing the screen
    else
      print("No monitors available.")
      read() -- Wait for user input before clearing the screen
    end

  else
    print("Invalid choice.")
    read() -- Wait for user input before clearing the screen
  end

  -- Clear the screen before showing the menu again
  clearScreen()
end
