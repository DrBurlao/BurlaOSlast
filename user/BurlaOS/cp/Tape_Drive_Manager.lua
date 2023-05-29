local asciiArt = [[
 ____ ____  ____ __  __ ____ __     __   _____ 
(  _ (  _ \(  _ (  )(  (  _ (  )   /__\ (  _  )
 )(_) )   / ) _ <)(__)( )   /)(__ /(__)\ )(_)( 
(____(_)\_((____(______(_)\_(____(__)(__(_____)
 ____ __  ____ ____ ____ ____ __ ____ __ __  __ _ 
(_  _/ _\(  _ (  __/ ___(_  _/ _(_  _(  /  \(  ( \
  )(/    \) __/) _)\___ \ )(/    \)(  )(  O /    /
 (__\_/\_(__) (____(____/(__\_/\_(__)(__\__/\_)__)
]]

print(asciiArt)
os.sleep(3) -- Pause for 3 seconds

-- Function to find all tape_drive units
local function findTapeDriveUnits()
  local units = peripheral.find("tape_drive")
  if units then
    return units
  else
    return {}
  end
end

-- Function to find all available tape units
local function findTapeUnits()
  local localUnits = findTapeDriveUnits()
  local modem = peripheral.find("modem")
  local modemUnits = {}
  if modem then
    local modemPeripherals = modem.getNamesRemote()
    for _, peripheralName in ipairs(modemPeripherals) do
      local peripheralType = peripheral.getType(peripheralName)
      if peripheralType == "tape_drive" then
        table.insert(modemUnits, peripheralName)
      end
    end
  end
  local units = {}
  for _, unit in ipairs(localUnits) do
    table.insert(units, unit)
  end
  for _, unit in ipairs(modemUnits) do
    table.insert(units, unit)
  end
  return units
end

-- Function to play a tape in the tape unit
local function playTape(unit)
  local wrapUnit = peripheral.wrap(unit)
  local isPlaying = false
  
  while true do
    term.clear()
    term.setCursorPos(1, 1)
    print("Playing tape:")
    print("1. Play/Pause")
    print("2. Stop")
    print("3. Fast Forward")
    print("4. Go to Start")
    print("5. Back to Main Menu")
    
    write("Select an option: ")
    local option = tonumber(read())
    
    if option == 1 then
      if isPlaying then
        wrapUnit.stop()
        isPlaying = false
      else
        wrapUnit.play()
        isPlaying = true
      end
    elseif option == 2 then
      wrapUnit.stop()
      isPlaying = false
    elseif option == 3 then
      wrapUnit.seek(1)
    elseif option == 4 then
      wrapUnit.seek(-wrapUnit.getSize())
    elseif option == 5 then
      break
    end
    
    os.sleep(0.1) -- Yield to the system
  end
end

-- Function to record a tape in the tape unit
local function recordTape(unit)
  local wrapUnit = peripheral.wrap(unit)
  
  term.clear()
  term.setCursorPos(1, 1)
  print("Recording tape")
  print("Press Enter to start recording...")
  read()
  
  wrapUnit.stop()
  wrapUnit.seek(-wrapUnit.getSize())
  
  print("Recording... Press Enter to stop.")
  while true do
    if read() then
      break
    end
    os.sleep(0.1) -- Yield to the system
  end
  
  wrapUnit.stop()
  print("Recording stopped")
end

-- Function to clone a tape from the source unit to the destination unit
local function cloneTape(sourceUnit, destinationUnit)
  local wrapSource = peripheral.wrap(sourceUnit)
  local wrapDestination = peripheral.wrap(destinationUnit)
  
  term.clear()
  term.setCursorPos(1, 1)
  print("Cloning tape")
  print("Press Enter to start cloning...")
  read()
  
  wrapSource.stop()
  wrapDestination.stop()
  wrapSource.seek(-wrapSource.getSize())
  wrapDestination.seek(-wrapDestination.getSize())
  
  print("Cloning... Press Enter to stop.")
  while true do
    local block = wrapSource.read()
    if block then
      wrapDestination.write(block)
    else
      break
    end
    os.sleep(0.1) -- Yield to the system
  end
  
  wrapSource.stop()
  wrapDestination.stop()
  print("Cloning stopped")
end

-- Function to rename a tape in the tape unit
local function renameTape(unit)
  local wrapUnit = peripheral.wrap(unit)
  
  term.clear()
  term.setCursorPos(1, 1)
  print("Renaming tape")
  print("Enter the new name for the tape:")
  write("> ")
  local newName = read()
  
  wrapUnit.stop()
  wrapUnit.setLabel(newName)
  
  print("Tape renamed successfully")
end

-- Main program loop
local exitProgram = false
while not exitProgram do
  term.clear()
  term.setCursorPos(1, 1)

  -- Display list of available tape units
  local units = findTapeUnits()
  if #units > 0 then
    print("Available tape units:")
    for i, unit in ipairs(units) do
      print(i .. ". " .. unit)
    end
  else
    print("No tape units found")
    break
  end

  -- Select a tape unit
  write("Select a unit: ")
  local unitIndex = tonumber(read())
  if unitIndex and unitIndex >= 1 and unitIndex <= #units then
    local selectedUnit = units[unitIndex]

    while true do
      term.clear()
      term.setCursorPos(1, 1)
      print("Selected Unit:", selectedUnit)
      print("1. Play Tape")
      print("2. Record Tape")
      print("3. Clone Tape")
      print("4. Rename Tape")
      print("5. Change Unit")
      print("6. Exit")
      write("Select an option: ")
      local option = tonumber(read())

      term.clear()
      term.setCursorPos(1, 1)

      if option == 1 then
        playTape(selectedUnit)
      elseif option == 2 then
        recordTape(selectedUnit)
      elseif option == 3 then
        print("Available tape units:")
        for i, unit in ipairs(units) do
          print(i .. ". " .. unit)
        end

        write("Select a destination unit: ")
        local destinationIndex = tonumber(read())
        if destinationIndex and destinationIndex >= 1 and destinationIndex <= #units then
          local destinationUnit = units[destinationIndex]
          cloneTape(selectedUnit, destinationUnit)
          print("Tape cloned successfully")
        else
          print("Invalid destination unit")
        end
      elseif option == 4 then
        renameTape(selectedUnit)
      elseif option == 5 then
        break
      elseif option == 6 then
        exitProgram = true
        break
      else
        print("Invalid option")
      end

      write("Press Enter to continue...")
      read()
    end
  else
    print("Invalid option")
  end

  write("Press Enter to continue...")
  read()
end
