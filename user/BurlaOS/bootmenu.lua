local configFile = "/.settings"
local bootSettingsPath = "/Bootsettings/bootsettings.txt"

local function readConfig(path)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local config = file.readAll()
        file.close()
        return config
    else
        return ""
    end
end

local function writeConfig(path, config)
    local file = fs.open(path, "w")
    file.write(config)
    file.close()
end

local function parseConfig(config)
    local settings = {}
    for setting in config:gmatch("[^\n]+") do
        local option, value = setting:match("([^=]+)=(.+)")
        settings[option] = value == "true"
    end
    return settings
end

local function getOptionValue(settings, option)
    return settings[option] or false
end

local function setOptionValue(settings, option, value)
    settings[option] = value
end

local function showOptions(settings)
    term.clear()
    term.setCursorPos(1, 1)
    print("Current state of options:")
    local i = 1
    for option, value in pairs(settings) do
        if value then
            term.setTextColor(colors.green)
        else
            term.setTextColor(colors.red)
        end
        print(i .. ". " .. option .. ": " .. tostring(value))
        i = i + 1
    end
    term.setTextColor(colors.white)
    print("\nPress any key to continue...")
    os.pullEvent("key")
end

local function createFiles()
    if not fs.exists(configFile) then
        local defaultConfig = "shell.autocomplete=true\nlua.autocomplete=true\nedit.autocomplete=true\nbios.use_multishell=false\nshell.allow_disk_startup=false\nshell.allow_startup=false\nlist.show_hidden=false"
        writeConfig(configFile, defaultConfig)
        print("Configuration file created.")
    end

    if not fs.exists(bootSettingsPath) then
        local config = readConfig(configFile)
        writeConfig(bootSettingsPath, config)
        print("Configuration backup created.")
    end
end

local function waitForSpacebar()
    term.clear()
    term.setCursorPos(1, 1)
    print("Press spacebar to enter setup...")
    local timer = os.startTimer(3)
    while true do
        local event, key = os.pullEvent()
        if event == "key" and key == keys.space then
            return true
        elseif event == "timer" and key == timer then
            return false
        end
    end
end

local function saveSettings(settings, path)
    local config = ""
    for option, value in pairs(settings) do
        config = config .. option .. "=" .. tostring(value) .. "\n"
    end

    writeConfig(path, config)
end

local function loadSettings(path)
    if fs.exists(path) then
        local config = readConfig(path)
        return parseConfig(config)
    end
    return {}
end

local function removeFile(path)
    if fs.exists(path) then
        fs.delete(path)
    end
end

local function createDirectories()
    fs.makeDir("/user")
    fs.makeDir("/user/BurlaOS")
    fs.makeDir("/user/BurlaOS/types")
end

local function resetConfiguration()
    removeFile(configFile)
    removeFile(bootSettingsPath)
    createFiles()
    print("Configuration reset.")
    os.sleep(1)
    shell.run("/user/BurlaOS/types/Shutdown.lua")
end

local function executeProgram(program)
    shell.run(program)
end

local function main()
    createDirectories()
    createFiles()

    local bootSettings = loadSettings(bootSettingsPath)

    if getOptionValue(bootSettings, "automatic_config") then
        executeProgram("/user/BurlaOS/Loggin.lua")
        return
    end

    if waitForSpacebar() then
        local settings = loadSettings(configFile)

        local continue = true
        while continue do
            term.clear()
            term.setCursorPos(1, 1)
            print("-----------------------------------------")
            print("1. View current state of options")
            print("2. Change option")
            print("-----------------------------------------")
            print("To restart, press 'R'.")
            print("To continue, press 'C'.")
            print("-----------------------------------------")
            print("Enter the number of the option you want to select:")
            local choice = read()

            if choice:lower() == "r" then
                resetConfiguration()
                continue = false
            elseif choice:lower() == "c" then
                executeProgram("/user/BurlaOS/Loggin.lua")
                continue = false
            elseif choice == "1" then
                showOptions(settings)
            elseif choice == "2" then
                term.clear()
                term.setCursorPos(1, 1)
                print("Select the option you want to change:")
                local optionChoice = tonumber(read())
                if optionChoice and optionChoice >= 1 and optionChoice <= #settings then
                    local i = 1
                    for option, _ in pairs(settings) do
                        if i == optionChoice then
                            print("Enter the new value for option " .. option .. ":")
                            local newValue = read()
                            setOptionValue(settings, option, newValue)
                            print("Option changed successfully.")
                            os.sleep(1)
                            break
                        end
                        i = i + 1
                    end
                else
                    print("Invalid option.")
                    os.sleep(1)
                end
            else
                print("Invalid option.")
                os.sleep(1)
            end
        end

        saveSettings(settings, configFile)
        saveSettings(settings, bootSettingsPath)
        print("Configuration saved successfully.")
        print("\nPress any key to exit...")
        os.pullEvent("key")
        term.clear()
        term.setCursorPos(1, 1)
    else
        executeProgram("/user/BurlaOS/Loggin.lua")
    end

    term.clear()
    term.setCursorPos(1, 1)
end

main()
