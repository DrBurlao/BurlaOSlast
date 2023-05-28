-- ASCII Art
local asciiArt = [[
 ____ ____  ____ __  __ ____ __     __   _____ 
(  _ (  _ \(  _ (  )(  (  _ (  )   /__\ (  _  )
 )(_) )   / ) _ <)(__)( )   /)(__ /(__)\ )(_)( 
(____(_)\_((____(______(_)\_(____(__)(__(_____)
 ____   ___  ____ 
(  _ \ / __)(  _ \
 )   /( (_ \ ) _ (
(__\_) \___/(____/

]]

-- Function to display ASCII Art
local function displayAsciiArt()
  print(asciiArt)
end

-- Function to scan and detect "Colorful Lamp" devices
local function detectLamps()
  local peripherals = peripheral.getNames()
  local lamps = {}

  for _, peripheralName in ipairs(peripherals) do
    if string.match(peripheralName, "^colorful_lamp_%d+$") then
      table.insert(lamps, peripheralName)
    end
  end

  return lamps
end

-- Function to turn on a lamp
local function turnOnLamp(lamp)
  peripheral.call(lamp, "setLampColor", 32767)  -- Maximum color
end

-- Function to change the color of a lamp
local function changeLampColor(lamp, color)
  peripheral.call(lamp, "setLampColor", color)
end

-- Function to turn off a lamp
local function turnOffLamp(lamp)
  peripheral.call(lamp, "setLampColor", 0)  -- Off color
end

-- Function to clone the color of one lamp to another
local function cloneLampColor(sourceLamp, targetLamp)
  local color = peripheral.call(sourceLamp, "getLampColor")
  peripheral.call(targetLamp, "setLampColor", color)
end

-- Function to turn off all lamps
local function turnOffAllLamps(lamps)
  for _, lamp in ipairs(lamps) do
    turnOffLamp(lamp)
  end
  print("All lamps have been turned off.")
end

-- Function to display a numeric menu and obtain a valid option
local function showNumericMenu(message, options)
  local option = nil

  while option == nil do
    term.clear()
    term.setCursorPos(1, 1)
    print(message)
    for i, optionText in ipairs(options) do
      print(i .. ". " .. optionText)
    end

    write("Select an option: ")
    local selection = tonumber(read())

    if selection ~= nil and selection >= 1 and selection <= #options then
      option = selection
    else
      print("Invalid selection. Please select a valid option.")
      sleep(1)
    end
  end

  return option
end

-- Function to display the menu and manage the lamps
local function manageLamps(lamps)
  local option = 0

  -- List of predefined colors with their decimal values
  local colors = {
    {name = "Red", value = 16711680},
    {name = "Green", value = 9498256},
    {name = "Blue", value = 65535},
    {name = "Yellow", value = 16776960},
    {name = "Orange", value = 16753920},
    {name = "Pink", value = 16761035},
    {name = "White", value = 32767}
  }

  while option ~= 6 do
    term.clear()
    term.setCursorPos(1, 1)
    print("----- Lamp Management Menu -----")
    print("1. Turn on all lamps")
    print("2. Change color of a lamp")
    print("3. Turn off a lamp")
    print("4. Clone color from one lamp to another")
    print("5. Turn off all lamps")
    print("6. Exit")

    write("Select an option: ")
    option = tonumber(read())

    if option == 1 then
      term.clear()
      term.setCursorPos(1, 1)
      for _, lamp in ipairs(lamps) do
        turnOnLamp(lamp)
      end
      print("All lamps have been turned on.")
      sleep(1)
    elseif option == 2 then
      term.clear()
      term.setCursorPos(1, 1)
      print("Select a lamp:")
      local lampOptions = {}
      for i, lamp in ipairs(lamps) do
        table.insert(lampOptions, "Lamp " .. i)
      end
      local selectedLamp = showNumericMenu("Select a lamp:", lampOptions)

      term.clear()
      term.setCursorPos(1, 1)
      print("Select a color:")
      for i, color in ipairs(colors) do
        print(i .. ". " .. color.name)
      end

      write("Enter the color number: ")
      local selectedColor = tonumber(read())

      if selectedColor ~= nil and selectedColor >= 1 and selectedColor <= #colors then
        local colorSelected = colors[selectedColor].value
        changeLampColor(lamps[selectedLamp], colorSelected)
        print("The color of the lamp has been changed.")
      else
        print("Invalid selection. Please select a valid color number.")
      end
      sleep(1)
    elseif option == 3 then
      term.clear()
      term.setCursorPos(1, 1)
      print("Select a lamp:")
      local lampOptions = {}
      for i, lamp in ipairs(lamps) do
        table.insert(lampOptions, "Lamp " .. i)
      end
      local selectedLamp = showNumericMenu("Select a lamp:", lampOptions)

      turnOffLamp(lamps[selectedLamp])
      print("The lamp has been turned off.")
      sleep(1)
    elseif option == 4 then
      term.clear()
      term.setCursorPos(1, 1)
      print("Select source lamp:")
      local sourceLampOptions = {}
      for i, lamp in ipairs(lamps) do
        table.insert(sourceLampOptions, "Lamp " .. i)
      end
      local selectedSourceLamp = showNumericMenu("Select source lamp:", sourceLampOptions)

      term.clear()
      term.setCursorPos(1, 1)
      print("Select target lamp:")
      local targetLampOptions = {}
      for i, lamp in ipairs(lamps) do
        table.insert(targetLampOptions, "Lamp " .. i)
      end
      local selectedTargetLamp = showNumericMenu("Select target lamp:", targetLampOptions)

      cloneLampColor(lamps[selectedSourceLamp], lamps[selectedTargetLamp])
      print("The color has been cloned from source lamp to target lamp.")
      sleep(1)
    elseif option == 5 then
      turnOffAllLamps(lamps)
      sleep(1)
    elseif option == 6 then
      print("Exiting the program...")
    else
      print("Invalid option. Please select a valid option.")
      sleep(1)
    end
  end
end

-- Function to create the necessary directories
local function createDirectories()
  if not fs.exists("/rgbpass") then
    fs.makeDir("/rgbpass")
  end
end

-- Function to check if a password file exists
local function checkPasswordFile()
  return fs.exists("/rgbpass/password.txt")
end

-- Function to create or update the password file
local function updatePasswordFile(password)
  local file = fs.open("/rgbpass/password.txt", "w")
  file.write(password)
  file.close()
end

-- Function to prompt for password input
local function enterPassword()
  term.clear()
  term.setCursorPos(1, 1)
  print(asciiArt)
  write("Enter password: ")
  return read("*")
end

-- Function to authenticate the user
local function authenticate()
  local password = ""

  if not checkPasswordFile() then
    print("Welcome to the program!")
    print("Since it's your first time running the program, we need to set up a password.")

    while password == "" do
      write("Enter a new password: ")
      local newPassword = read("*")
      write("Confirm password: ")
      local confirmPassword = read("*")

      if newPassword == confirmPassword then
        password = newPassword
      else
        print("Passwords do not match. Please try again.")
        sleep(1)
      end
    end

    updatePasswordFile(password)
    print("Password set successfully. Please restart the program to continue.")
    sleep(2)
    return false
  else
    while password == "" do
      password = enterPassword()
    end

    local file = fs.open("/rgbpass/password.txt", "r")
    local storedPassword = file.readAll()
    file.close()

    if password == storedPassword then
      return true
    else
      print("Incorrect password. Please try again.")
      sleep(1)
      return false
    end
  end
end

-- Main program

-- Check and create necessary directories
createDirectories()

-- Authenticate the user
local authenticated = authenticate()

-- Proceed with the program if authentication is successful
if authenticated then
  -- Display ASCII Art
  displayAsciiArt()

  -- Detect lamps
  local lamps = detectLamps()

  -- Proceed with lamp management if lamps are found
  if #lamps > 0 then
    print("Lamps detected: " .. #lamps)

    -- Start lamp management
    manageLamps(lamps)
  else
    print("No lamps detected. Exiting the program...")
  end
end
