local colors = {
  title = colors.yellow,
  menu = colors.lightBlue,
  prompt = colors.lime,
  error = colors.red,
  success = colors.green
}

-- Function to set text color
local function setColor(textColor, bgColor)
  term.setTextColor(textColor or colors.white)
  term.setBackgroundColor(bgColor or colors.black)
end

-- Function to display the title
local function showTitle()
  term.clear()
  term.setCursorPos(1, 1)
  setColor(colors.title)
  print("----- Music Disk Manager -----")
end

-- Function to display the menu options
local function showMenu()
  setColor(colors.menu)
  print("1. Copy disk contents")
  print("2. Show music files")
  print("3. Record music file to disk")
  print("4. Play the disk")
  print("5. Stop playback")
  print("6. Detect networked disk drives")
  print("0. Exit")
end

-- Function to wait for user input and read it securely
local function waitForInput(prompt)
  setColor(colors.prompt)
  write(prompt .. ": ")
  return read()
end

-- Function to display an error message
local function showError(message)
  setColor(colors.error)
  print("[ERROR] " .. message)
end

-- Function to display a success message
local function showSuccess(message)
  setColor(colors.success)
  print("[SUCCESS] " .. message)
end

-- Function to copy disk contents to a folder
local function copyDiskContents(drive)
  local diskLabel = drive.getLabel()
  local destinationFolder = "user/music/" .. diskLabel

  if fs.exists(destinationFolder) then
    showError("The disk has already been copied.")
  else
    fs.makeDir(destinationFolder)

    for _, file in ipairs(drive.list()) do
      drive.ejectDisk()
      drive.setDiskLabel(diskLabel)

      local sourcePath = "/" .. file
      local destinationPath = destinationFolder .. "/" .. file
      fs.copy(sourcePath, destinationPath)
    end

    showSuccess("Disk contents have been successfully copied.")
  end
end

-- Function to show available music files
local function showMusicFiles(drive)
  local diskLabel = drive.getLabel()
  local diskFolder = "user/music/" .. diskLabel

  if fs.exists(diskFolder) then
    local files = fs.list(diskFolder)

    if #files > 0 then
      setColor()
      print("Music files on the disk:")
      for _, file in ipairs(files) do
        local filePath = diskFolder .. "/" .. file
        local fileSize = fs.getSize(filePath)
        setColor(colors.prompt)
        print("- Name: " .. file .. ", Path: " .. filePath .. ", Size: " .. fileSize .. " bytes")
      end
    else
      showError("There are no music files on the disk.")
    end
  else
    showError("The disk has not been copied previously.")
  end
end

-- Function to record a music file to the disk
local function recordMusicFile(drive)
  local diskLabel = drive.getLabel()
  local diskFolder = "user/music/" .. diskLabel

  if fs.exists(diskFolder) then
    showError("The disk has already been copied.")
  else
    fs.makeDir(diskFolder)

    showTitle()
    setColor(colors.prompt)
    local fileName = waitForInput("Enter the music file name")
    local filePath = "user/music/" .. fileName

    if fs.exists(filePath) then
      fs.copy(filePath, diskFolder .. "/" .. fileName)
      showSuccess("The music file has been recorded to the disk.")
    else
      showError("The music file does not exist.")
    end
  end
end

-- Function to play the disk
local function playDisk(drive)
  local diskLabel = drive.getLabel()
  local diskFolder = "user/music/" .. diskLabel

  if fs.exists(diskFolder) then
    local files = fs.list(diskFolder)

    if #files > 0 then
      local fileIndex = 1
      local currentFile = fs.open(diskFolder .. "/" .. files[fileIndex], "r")

      showTitle()
      setColor(colors.success)
      print("Now playing: " .. files[fileIndex])

      while true do
        local line = currentFile.readLine()
        if line then
          print(line)
          sleep(0.1)
        else
          currentFile.close()
          fileIndex = fileIndex + 1
          if fileIndex <= #files then
            currentFile = fs.open(diskFolder .. "/" .. files[fileIndex], "r")
            showTitle()
            setColor(colors.success)
            print("Now playing: " .. files[fileIndex])
          else
            break
          end
        end
      end
    else
      showError("There are no music files on the disk.")
    end
  else
    showError("The disk has not been copied previously.")
  end
end

-- Function to stop playback
local function stopPlayback()
  showTitle()
  setColor(colors.success)
  print("Playback stopped.")
end

-- Function to detect networked disk drives
local function detectNetworkedDiskDrives()
  local modemSide = nil

  for _, side in ipairs(rs.getSides()) do
    if peripheral.getType(side) == "wired_modem" then
      modemSide = side
      break
    end
  end

  if modemSide then
    local modem = peripheral.wrap(modemSide)
    modem.transmit(1, 1, "RequestDiskDrives")

    showTitle()
    setColor(colors.prompt)
    print("Searching for networked disk drives...")
    sleep(5)

    while true do
      local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")

      if message == "DiskDriveFound" then
        setColor(colors.success)
        print("- Disk drive found at: " .. senderChannel)
      end
    end
  else
    showError("No wired modem found.")
  end
end

-- Function to select a disk drive
local function selectDiskDrive()
  local attachedDrives = {}

  for _, side in ipairs(rs.getSides()) do
    if peripheral.getType(side) == "drive" then
      table.insert(attachedDrives, side)
    end
  end

  local networkDrives = peripheral.find("drive")

  showTitle()

  if #attachedDrives > 0 or #networkDrives > 0 then
    setColor(colors.menu)
    print("----- Disk Drive Selection -----")

    if #attachedDrives > 0 then
      print("Attached disk drives:")
      for i, side in ipairs(attachedDrives) do
        setColor(colors.prompt)
        print(i .. ". " .. side)
      end
    end

    if #networkDrives > 0 then
      print("Networked disk drives:")
      for i, drive in ipairs(networkDrives) do
        setColor(colors.prompt)
        print(i + #attachedDrives .. ". " .. drive)
      end
    end

    local selection = tonumber(waitForInput("Enter the number of the desired disk drive"))

    if selection and selection > 0 then
      local selectedDrive
      if selection <= #attachedDrives then
        selectedDrive = peripheral.wrap(attachedDrives[selection])
      else
        selectedDrive = networkDrives[selection - #attachedDrives]
      end

      main(selectedDrive)
    else
      showError("Invalid selection. Please enter a valid number.")
    end
  else
    showError("No disk drives found.")
  end
end

-- Main function to handle user options
local function main(drive)
  local option = -1

  while option ~= 0 do
    showTitle()
    showMenu()
    option = tonumber(waitForInput("Enter the number of the desired option"))

    if option == 1 then
      copyDiskContents(drive)
    elseif option == 2 then
      showMusicFiles(drive)
    elseif option == 3 then
      recordMusicFile(drive)
    elseif option == 4 then
      playDisk(drive)
    elseif option == 5 then
      stopPlayback()
    elseif option == 6 then
      detectNetworkedDiskDrives()
    elseif option == 0 then
      showSuccess("Exiting...")
    else
      showError("Invalid option. Please enter a valid number.")
    end

    sleep(1)
  end
end

-- Run the main program by selecting a disk drive
selectDiskDrive()
