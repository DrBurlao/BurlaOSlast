local hiddenNamesFile = "/user/hiddenfiles/hiddennames.txt"
local hiddenLocationsFile = "/user/hiddenfiles/hiddenlocations.txt"
local scanResultFile = "/user/hiddenfiles/scanresult.txt"
local sizeScanResultFile = "/user/hiddenfiles/sizescanresults.txt"

local function hideFile(file)
  if fs.exists(file) then
    local newFileName = "." .. fs.getName(file)
    local success, errorMessage = fs.move(file, fs.combine(fs.getDir(file), newFileName))
    if success then
      print("'" .. fs.getName(file) .. "' has been hidden.")

      local namesConf = fs.open(hiddenNamesFile, "a")
      namesConf.writeLine(newFileName)
      namesConf.close()

      local locationsConf = fs.open(hiddenLocationsFile, "a")
      locationsConf.writeLine(file)
      locationsConf.close()
    else
      print("Failed to hide the file: " .. errorMessage)
    end
  else
    print("The file does not exist.")
  end
end

local function showFile(hiddenFile)
  if fs.exists(hiddenFile) then
    local fileName = fs.getName(hiddenFile)
    local newFileName = string.sub(fileName, 2)
    local success, errorMessage = fs.move(hiddenFile, fs.combine(fs.getDir(hiddenFile), newFileName))
    if success then
      print("'" .. fileName .. "' has been shown.")

      local namesConf = fs.open(hiddenNamesFile, "r")
      local names = namesConf.readAll()
      namesConf.close()

      local newNames = string.gsub(names, fileName .. "\n", "")
      namesConf = fs.open(hiddenNamesFile, "w")
      namesConf.write(newNames)
      namesConf.close()

      local locationsConf = fs.open(hiddenLocationsFile, "r")
      local locations = locationsConf.readAll()
      locationsConf.close()

      local newLocations = string.gsub(locations, hiddenFile .. "\n", "")
      locationsConf = fs.open(hiddenLocationsFile, "w")
      locationsConf.write(newLocations)
      locationsConf.close()
    else
      print("Failed to show the file: " .. errorMessage)
    end
  else
    print("The hidden file does not exist.")
  end
end

local function renameHiddenFile(hiddenFile)
  if fs.exists(hiddenFile) then
    local fileName = fs.getName(hiddenFile)
    print("Enter the new name for the file '" .. fileName .. "':")
    local newFileName = read()
    if newFileName and newFileName ~= "" then
      local newFilePath = fs.combine(fs.getDir(hiddenFile), newFileName)
      local success, errorMessage = fs.move(hiddenFile, newFilePath)
      if success then
        print("File renamed from '" .. fileName .. "' to '" .. newFileName .. "'.")
      else
        print("Failed to rename the file: " .. errorMessage)
      end
    else
      print("Invalid file name.")
    end
  else
    print("The hidden file does not exist.")
  end
end

local function scanForHiddenFiles(directory)
  local hiddenFiles = {}

  local function scanDirectory(dir)
    for _, file in ipairs(fs.list(dir)) do
      local path = fs.combine(dir, file)
      if fs.isDir(path) then
        scanDirectory(path)
      elseif string.sub(file, 1, 1) == "." then
        table.insert(hiddenFiles, path)
      end
    end
  end

  if fs.exists(directory) then
    scanDirectory(directory)

    local scanResult = fs.open(scanResultFile, "w")
    for _, file in ipairs(hiddenFiles) do
      scanResult.writeLine(file)
    end
    scanResult.close()
  else
    print("The specified directory does not exist.")
  end

  return hiddenFiles
end

local function showHiddenFileList()
  if fs.exists(hiddenNamesFile) and fs.exists(hiddenLocationsFile) then
    print("=== Hidden Files ===")
    local namesConf = fs.open(hiddenNamesFile, "r")
    local names = namesConf.readAll()
    namesConf.close()

    local locationsConf = fs.open(hiddenLocationsFile, "r")
    local locations = locationsConf.readAll()
    locationsConf.close()

    if names ~= "" then
      local i = 1
      for name in string.gmatch(names, "[^\r\n]+") do
        local location = string.match(locations, "[^\r\n]+")
        print(i .. ". " .. location .. "/" .. name)
        locations = string.gsub(locations, location .. "\n", "")
        i = i + 1
      end
    else
      print("No hidden files found.")
    end
  else
    print("No hidden files found.")
  end
end

local function showScanResult()
  if fs.exists(scanResultFile) then
    print("=== Scan Result ===")
    local scanResult = fs.open(scanResultFile, "r")
    local files = scanResult.readAll()
    scanResult.close()

    if files ~= "" then
      for file in string.gmatch(files, "[^\r\n]+") do
        print(file)
      end
    else
      print("No files found in the scan result.")
    end
  else
    print("The scan result file does not exist.")
  end
end

local function showSizeScanResult()
  if fs.exists(sizeScanResultFile) then
    print("=== Size Scan Result ===")
    local sizeScanResult = fs.open(sizeScanResultFile, "r")
    local files = sizeScanResult.readAll()
    sizeScanResult.close()

    if files ~= "" then
      for line in string.gmatch(files, "[^\r\n]+") do
        local fileName, fileSize, fileExtension = string.match(line, "(.+)%s+(%d+)%s+(%w+)")
        print(fileName .. " (" .. fileSize .. " bytes, " .. fileExtension .. ")")
      end
    else
      print("No files found in the size scan result.")
    end
  else
    print("The size scan result file does not exist.")
  end
end

local function copyHiddenFiles(hiddenFiles)
  if #hiddenFiles > 0 then
    print("Found hidden files:")
    for i, file in ipairs(hiddenFiles) do
      print(i .. ". " .. file)
    end
    write("Do you want to copy the hidden files? (Y/N): ")
    local answer = string.lower(read())
    if answer == "y" then
      fs.makeDir("/user/hiddenfiles/copiedfiles")
      for i, file in ipairs(hiddenFiles) do
        local newFileName = i .. fs.getExtension(file)
        local newFilePath = fs.combine("/user/hiddenfiles/copiedfiles", newFileName)
        local success, errorMessage = fs.copy(file, newFilePath)
        if success then
          print("Copied: " .. file .. " to " .. newFilePath)
        else
          print("Failed to copy: " .. file .. " - " .. errorMessage)
        end
      end
    end
  else
    print("No hidden files found in the specified directory.")
  end
end

local function main()
  fs.makeDir("/user/hiddenfiles")

  if not fs.exists(hiddenNamesFile) then
    fs.open(hiddenNamesFile, "w").close()
  end
  if not fs.exists(hiddenLocationsFile) then
    fs.open(hiddenLocationsFile, "w").close()
  end

  while true do
    term.clear()
    term.setCursorPos(1, 1)

    print("=== Menu ===")
    print("1. Scan directory for hidden files")
    print("2. Show hidden files")
    print("3. Show scan result")
    print("4. Show size scan result")
    print("5. Copy hidden files")
    print("6. Rename hidden file")
    print("7. Exit")

    write("Select an option: ")
    local option = tonumber(read())

    if option == 1 then
      write("Enter the directory to scan for hidden files: ")
      local directory = read()
      local hiddenFiles = scanForHiddenFiles(directory)
      if #hiddenFiles > 0 then
        print("Scan completed. Found " .. #hiddenFiles .. " hidden files.")
      else
        print("No hidden files found in the specified directory.")
      end
      write("Press any key to continue.")
      read()
    elseif option == 2 then
      showHiddenFileList()
      write("Press any key to continue.")
      read()
    elseif option == 3 then
      showScanResult()
      write("Press any key to continue.")
      read()
    elseif option == 4 then
      showSizeScanResult()
      write("Press any key to continue.")
      read()
    elseif option == 5 then
      copyHiddenFiles(scanForHiddenFiles("/"))
      write("Press any key to continue.")
      read()
    elseif option == 6 then
      showHiddenFileList()
      write("Enter the number of the hidden file to rename: ")
      local selection = tonumber(read())
      if selection and selection >= 1 then
        renameHiddenFile(hiddenFiles[selection])
      else
        print("Invalid selection.")
      end
      write("Press any key to continue.")
      read()
    elseif option == 7 then
      print("Goodbye!")
      break
    else
      print("Invalid option. Please try again.")
      write("Press any key to continue.")
      read()
    end
  end
end

main()
