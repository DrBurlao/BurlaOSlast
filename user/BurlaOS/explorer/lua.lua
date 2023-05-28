local function scanFiles(directory, luaFiles)
    local files = fs.list(directory)
    for _, file in ipairs(files) do
        local path = fs.combine(directory, file)
        if fs.isDir(path) then
            scanFiles(path, luaFiles) -- Escanea subdirectorios recursivamente
        elseif file:match("%.lua$") then
            local size = fs.getSize(path)
            table.insert(luaFiles, { path = path, size = size })
        end
    end
end

local function showMenu(files, currentPage, pageSize)
    local totalPages = math.ceil(#files / pageSize)
    currentPage = math.max(1, math.min(currentPage, totalPages))
    term.clear()
    term.setCursorPos(1, 1)
    print("Lua File Explorer")
    print("-----------------")
    local startIdx = (currentPage - 1) * pageSize + 1
    local endIdx = math.min(startIdx + pageSize - 1, #files)
    for i = startIdx, endIdx do
        local file = files[i]
        print(i .. ". " .. file.path .. " | Size: " .. file.size .. " bytes")
    end
    print("-----------------")
    print("Page " .. currentPage .. "/" .. totalPages)
    print("Press 'P' to go to the previous page.")
    print("Press 'N' to go to the next page.")
end

local function runFile(file)
    if fs.exists(file) and not fs.isDir(file) then
        shell.openTab(file)
    else
        print("The file doesn't exist or is a directory.")
    end
end

local luaFiles = {}
scanFiles("/", luaFiles)
local currentPage = 1
local pageSize = 10
local running = true

while running do
    showMenu(luaFiles, currentPage, pageSize)
    print("0. Exit")
    write("Select a file to run (file number or page): ")
    local input = read()

    if input == "0" then
        running = false
    elseif tonumber(input) then
        local fileIdx = tonumber(input)
        if fileIdx >= 1 and fileIdx <= #luaFiles then
            runFile(luaFiles[fileIdx].path)
            write("Press any key to continue...")
            read()
        else
            print("Invalid file index.")
            sleep(2)
        end
    elseif input:lower() == "p" then
        currentPage = currentPage - 1
    elseif input:lower() == "n" then
        currentPage = currentPage + 1
    else
        print("Invalid input. Please try again.")
        sleep(2)
    end
end
