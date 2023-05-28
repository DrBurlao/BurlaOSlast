-- Function to detect the printer
local function detectPrinter()
    local peripherals = peripheral.getNames()
    for _, name in ipairs(peripherals) do
        if peripheral.getType(name) == "printer" then
            return peripheral.wrap(name)
        end
    end
    return nil
end

-- Function to detect the monitor
local function detectMonitor()
    local peripherals = peripheral.getNames()
    local monitors = {}
    for _, name in ipairs(peripherals) do
        if peripheral.getType(name) == "monitor" then
            table.insert(monitors, peripheral.wrap(name))
        end
    end
    return monitors
end

-- Function to scan .txt files in the specified directories
local function scanFiles()
    local files = {}
    local function scanDirectory(directory)
        local dirList = fs.list(directory)
        for _, file in ipairs(dirList) do
            local fullPath = fs.combine(directory, file)
            if fs.isDir(fullPath) then
                if not string.find(fullPath, "/rom/") and not string.find(fullPath, "/rom/help/") then
                    scanDirectory(fullPath)
                end
            elseif fs.getName(file):match("%.txt$") then
                table.insert(files, fullPath)
            end
        end
    end

    scanDirectory("/user/documents/")
    scanDirectory("/")
    return files
end

-- Function to show files in a specific page
local function showFilesInPage(files, page)
    term.clear()
    term.setCursorPos(1, 1)
    print("=== FILES ===")

    local pageSize = 10 -- Number of files per page
    local startIndex = (page - 1) * pageSize + 1
    local endIndex = math.min(startIndex + pageSize - 1, #files)

    for i = startIndex, endIndex do
        print(i .. ". " .. files[i])
    end

    print("================")
    print("Page " .. page .. "/" .. math.ceil(#files / pageSize))
end

-- Function to show files and allow selection
local function selectFile(files)
    local page = 1
    local totalPages = math.ceil(#files / 10)

    while true do
        showFilesInPage(files, page)

        write("Select the file to print (number, n for next page, p for previous page): ")
        local input = read()

        if tonumber(input) then
            local index = tonumber(input)
            if index >= 1 and index <= #files then
                return files[index]
            else
                print("Invalid selection. Please try again.")
            end
        elseif input == "n" then
            page = page + 1
            if page > totalPages then
                page = 1
            end
        elseif input == "p" then
            page = page - 1
            if page < 1 then
                page = totalPages
            end
        else
            print("Invalid input. Please try again.")
        end
    end
end

-- Function to create the necessary directories if they don't exist
local function createDirectories()
    if not fs.exists("/printerstats") then
        fs.makeDir("/printerstats")
    end
end

-- Function to get the printer status (ink level, paper level, copies made)
local function getPrinterStatus(printer)
    local inkLevel = printer.getInkLevel()
    local paperLevel = printer.getPaperLevel()

    local copiesMade = 0
    local statsPath = "/printerstats/stats.txt"
    if fs.exists(statsPath) then
        local file = fs.open(statsPath, "r")
        copiesMade = tonumber(file.readLine()) or 0
        file.close()
    end

    return inkLevel, paperLevel, copiesMade
end

-- Function to update the copies counter
local function updateCopiesCounter(copiesMade)
    local statsPath = "/printerstats/stats.txt"
    local file = fs.open(statsPath, "w")
    file.writeLine(tostring(copiesMade))
    file.close()
end

-- Function to show the printing status on the monitor and PC
local function showPrintingStatus(printer, monitor)
    local inkLevel, paperLevel, copiesMade

    while true do
        monitor.clear()
        monitor.setCursorPos(1, 1)

        inkLevel, paperLevel, copiesMade = getPrinterStatus(printer)

        monitor.write("Printer Status")
        monitor.setCursorPos(1, 3)
        monitor.write("Ink Level: " .. inkLevel)
        monitor.setCursorPos(1, 4)
        monitor.write("Paper Level: " .. paperLevel)
        monitor.setCursorPos(1, 6)
        monitor.write("Copies Made: " .. copiesMade)

        sleep(1)
    end
end

-- Main program
createDirectories()

local printer = detectPrinter()
if not printer then
    print("No printer found.")
    return
end

local monitors = detectMonitor()
local monitor
if monitors and #monitors >= 2 then
    monitor = monitors[2]  -- Select the second monitor from the list
    print("Second monitor found: " .. peripheral.getName(monitor))
else
    monitor = nil
    print("No second monitor found.")
end

local files = scanFiles()
local selectedFile

if #files > 0 then
    selectedFile = selectFile(files)
else
    print("No .txt files found.")
    return
end

term.clear()
term.setCursorPos(1, 1)
print("Selected File: " .. selectedFile)

-- Prompt for the number of copies
local numCopies
while true do
    write("Enter the number of copies to print: ")
    numCopies = tonumber(read())
    if numCopies and numCopies > 0 then
        break
    else
        print("Invalid number of copies. Please try again.")
    end
end

-- Print the selected copies
for i = 1, numCopies do
    printer.newPage()
    local fileName = fs.getName(selectedFile)
    local file = fs.open(selectedFile, "r")
    local content = file.readAll()
    file.close()
    printer.setPageTitle(fileName)
    printer.write(content)
    printer.endPage()
end

-- Update copies counter
local _, _, copiesMade = getPrinterStatus(printer)
copiesMade = copiesMade + numCopies
updateCopiesCounter(copiesMade)

-- Show printing status on monitor and PC
if monitor then
    parallel.waitForAny(function()
        showPrintingStatus(printer, monitor)
    end, function()
        while true do
            sleep(1)
        end
    end)
else
    sleep(2)
end
