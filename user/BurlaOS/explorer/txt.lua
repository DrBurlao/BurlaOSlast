-- Function to scan directories and retrieve text files with their paths and sizes
local function scanFiles(directory)
    local txtFiles = {}
    local function scanDirectory(directory)
        local files = fs.list(directory)
        for _, file in ipairs(files) do
            local path = fs.combine(directory, file)
            if fs.isDir(path) then
                scanDirectory(path) -- Recursively scan subdirectories
            elseif file:match("%.txt$") then
                local size = fs.getSize(path)
                table.insert(txtFiles, { path = path, size = size })
            end
        end
    end

    scanDirectory(directory)
    return txtFiles
end

-- Function to display a paginated menu
local function showMenu(files, currentPage, pageSize)
    local totalPages = math.ceil(#files / pageSize)
    currentPage = math.max(1, math.min(currentPage, totalPages))

    term.clear()
    term.setCursorPos(1, 1)
    print("Text File Explorer")
    print("------------------")

    local startIdx = (currentPage - 1) * pageSize + 1
    local endIdx = math.min(startIdx + pageSize - 1, #files)

    for i = startIdx, endIdx do
        local file = files[i]
        print(i .. ". " .. file.path)
        print("   Size: " .. file.size .. " bytes")
    end

    print("------------------")
    print("Page " .. currentPage .. "/" .. totalPages)
    print("Press 'p' to go to the previous page")
    print("Press 'n' to go to the next page")
end

-- Function to open a text file
local function openFile(file)
    if fs.exists(file) and not fs.isDir(file) then
        shell.run("edit", file)
    else
        print("The file does not exist or is a directory.")
    end
end

-- Main program
local files = scanFiles("/")
local currentPage = 1
local pageSize = 5
local running = true

while running do
    showMenu(files, currentPage, pageSize)
    print("0. Exit")
    write("Select a file to open (file number or page): ")
    local input = read()

    if input == "0" then
        running = false
    elseif tonumber(input) then
        local fileIdx = tonumber(input)
        if fileIdx >= 1 and fileIdx <= #files then
            openFile(files[fileIdx].path)
            write("Press any key to continue...")
            read()
        else
            print("Invalid file index.")
            sleep(2)
        end
    elseif input == "p" or input == "P" then
        currentPage = currentPage - 1
    elseif input == "n" or input == "N" then
        currentPage = currentPage + 1
    else
        print("Invalid input. Please try again.")
        sleep(2)
    end

    -- Adjust current page to wrap around if exceeded the total pages
    if currentPage > math.ceil(#files / pageSize) then
        currentPage = 1
    elseif currentPage < 1 then
        currentPage = math.ceil(#files / pageSize)
    end
end
