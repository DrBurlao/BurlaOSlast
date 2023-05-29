local colors = {
  background = colors.black,
  text = colors.white,
  headerBackground = colors.blue,
  headerText = colors.white,
  fileListBackground = colors.black,
  fileListText = colors.yellow
}

-- Function to check if a monitor is attached
local function hasMonitor()
  return peripheral.isPresent("monitor")
end

-- Function to detect and get the connected wired modem
local function getModem()
  local peripherals = peripheral.getNames()
  for _, name in ipairs(peripherals) do
    if peripheral.getType(name) == "modem" and not peripheral.call(name, "isWireless") then
      return peripheral.wrap(name)
    end
  end
  return nil
end

-- Function to get the resolution of the attached monitor
local function getMonitorResolution()
  if hasMonitor() then
    local monitor = peripheral.wrap("monitor")
    return monitor.getSize()
  end
end

-- Function to display the same image on the computer and monitor
local function showImage(image, resolution)
  term.clear()
  term.setCursorPos(1, 1)
  print("Showing image on the computer and monitor...")

  if hasMonitor() then
    local monitorResX, monitorResY = getMonitorResolution()
    local monitor = peripheral.wrap("monitor")
    monitor.setTextScale(1)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.blit(image, image, image)
    monitor.setCursorPos(1, 1)
    monitor.setTextScale(1)
  end

  local modem = getModem()
  if modem then
    modem.transmit(1337, 1337, image)
  end

  term.clear()
  term.setCursorPos(1, 1)
  print("Image displayed on the computer and monitor.")
end

-- Function to get the file listing in a folder
local function getFileListing(folder)
  local files = fs.list(folder)
  table.sort(files) -- Sort alphabetically
  return files
end

-- Function to create an empty file if it doesn't exist
local function createFile(fileName)
  if not fs.exists(fileName) then
    local file = fs.open(fileName, "w")
    file.close()
  end
end

-- Path to the folder containing the files
local folderPath = "user/BurlaOS/programs/" -- Adjust the path to your desired folder

-- Check if the folder exists
if not fs.exists(folderPath) or not fs.isDir(folderPath) then
  print("Error: Program folder does not exist.")
  return
end

-- Get the file listing in the folder
local files = getFileListing(folderPath)

-- Set up graphics mode if a monitor is attached
if hasMonitor() then
  term.redirect(peripheral.wrap("monitor"))
  term.clear()
end

-- Set console colors
term.setBackgroundColor(colors.background)
term.setTextColor(colors.text)
term.clear()
term.setCursorPos(1, 1)

-- Show the header
term.setBackgroundColor(colors.headerBackground)
term.setTextColor(colors.headerText)
term.clearLine()
print(" Files found in " .. folderPath .. " ")
print(string.rep("-", term.getSize()))

-- Show the file listing
term.setBackgroundColor(colors.fileListBackground)
term.setTextColor(colors.fileListText)
if #files == 0 then
  print("No files found.")
else
  for i, file in ipairs(files) do
    print(i .. ". " .. file)
  end

  -- Get user selection
  print()
  term.setTextColor(colors.text)
  write("Select a file (1-" .. #files .. "): ")
  local selection = tonumber(read())

  -- Validate user selection
  if selection and selection >= 1 and selection <= #files then
    -- Get the selected file
    local selectedFile = files[selection]

    -- Load the file in the background using 'bg'
    term.clear()
    term.setCursorPos(1, 1)
    shell.run("bg", fs.combine(folderPath, selectedFile))

    -- Close the main program
    term.setBackgroundColor(colors.background)
    term.setTextColor(colors.text)
    term.clear()
    term.setCursorPos(1, 1)
    print("The file " .. selectedFile .. " has been opened in the background.")
  else
    -- Show invalid selection message
    term.setBackgroundColor(colors.background)
    term.setTextColor(colors.text)
    term.clear()
    term.setCursorPos(1, 1)
    print("Invalid selection. The program has been closed.")
  end
end
