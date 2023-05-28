local noteDirectory = "/user/documents/"
local textColor = colors.white

local function createDirectoryIfNotExists(directory)
  if not fs.exists(directory) then
    fs.makeDir(directory)
  end
end

local function saveToFile(filename, text)
  local file = io.open(noteDirectory .. filename, "w")
  if file then
    file:write(text)
    file:close()
    print("File saved as: " .. filename)
  else
    print("Failed to open file for writing: " .. filename)
  end
end

local function readFromFile(filename)
  local filePath = noteDirectory .. filename
  if fs.exists(filePath) then
    local file = io.open(filePath, "r")
    if file then
      local text = file:read("*a")
      file:close()
      return text
    else
      print("Failed to open file for reading: " .. filename)
    end
  else
    print("The file does not exist.")
  end
end

local function deleteFile(filename)
  local filePath = noteDirectory .. filename
  if fs.exists(filePath) then
    fs.delete(filePath)
    print("File deleted: " .. filename)
  else
    print("The file does not exist.")
  end
end

local function listFiles(directory, indent)
  local files = fs.list(directory)
  for _, file in ipairs(files) do
    local path = fs.combine(directory, file)
    if fs.isDir(path) then
      listFiles(path, indent .. "  ")
    else
      print(indent .. file)
    end
  end
end

-- Additional function with logic
local function renameFile(oldFilename, newFilename)
  local oldFilePath = noteDirectory .. oldFilename
  local newFilePath = noteDirectory .. newFilename

  if fs.exists(oldFilePath) then
    if fs.exists(newFilePath) then
      print("A file with the new name already exists.")
    else
      fs.move(oldFilePath, newFilePath)
      print("File renamed from " .. oldFilename .. " to " .. newFilename)
    end
  else
    print("The file does not exist.")
  end
end

-- User interface and other functions
local function printMenu()
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.cyan)
  print("=== Notepad ===")
  term.setTextColor(textColor)
  print("1. Read file")
  print("2. Write file")
  print("3. Delete file")
  print("4. Rename file")
  print("5. List files")
  term.setTextColor(colors.red)
  print("6. Exit")
  term.setTextColor(colors.white)
end

local function getInput(prompt)
  term.setTextColor(colors.yellow)
  term.write(prompt)
  term.setTextColor(colors.white)
  return read()
end

local function handleReadFile()
  local filename = getInput("Enter the filename: ")
  local text = readFromFile(filename)
  if text then
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.green)
    print("Content of file " .. filename .. ":")
    term.setTextColor(textColor)
    print(text)
    term.setTextColor(colors.white)
    getInput("Press Enter to continue...")
  end
end

local function handleWriteFile()
  local filename = getInput("Enter the filename: ")
  print("Enter the text (Press Enter to save and exit):")

  local lines = {}
  while true do
    local line = getInput("")
    if line == "" then
      break
    end
    table.insert(lines, line)
  end

  if #lines > 0 then
    local text = table.concat(lines, "\n")
    saveToFile(filename, text)
  else
    print("No file saved.")
    getInput("Press Enter to continue...")
  end
end

local function handleDeleteFile()
  local filename = getInput("Enter the filename to delete: ")
  deleteFile(filename)
end

local function handleRenameFile()
  local oldFilename = getInput("Enter the filename to rename: ")
  local newFilename = getInput("Enter the new filename: ")
  renameFile(oldFilename, newFilename)
end

local function handleListFiles()
  print("Files in the directory and subdirectories:")
  listFiles(noteDirectory, "")
  getInput("Press Enter to continue...")
end

-- Main program
createDirectoryIfNotExists(noteDirectory)

while true do
  printMenu()
  local option = tonumber(getInput("Select an option: "))

  if option == 1 then
    handleReadFile()
  elseif option == 2 then
    handleWriteFile()
  elseif option == 3 then
    handleDeleteFile()
  elseif option == 4 then
    handleRenameFile()
  elseif option == 5 then
    handleListFiles()
  elseif option == 6 then
    term.setTextColor(colors.red)
    print("Exiting...")
    term.setTextColor(colors.white)
    break
  else
    print("Invalid option. Please try again.")
    getInput("Press Enter to continue...")
  end
end
