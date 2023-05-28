local function clearScreen()
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1, 1)
end

local function centerText(y, text)
  local width, _ = term.getSize()
  local x = math.floor(width / 2 - #text / 2)
  term.setCursorPos(x, y)
  print(text)
end

local function centerTextInput(y, prompt)
  local width, _ = term.getSize()
  local x = math.floor(width / 2 - #prompt / 2)
  term.setCursorPos(x, y)
  return read()
end

local function showAdminAccountCreationForm()
  clearScreen()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  shell.run("user/.admin/accounts.lua")
  os.queueEvent("terminate")
end

local function showLoginForm()
  clearScreen()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  centerText(4, "Login")

  centerText(7, "Username:")
  local username = centerTextInput(9, "")

  centerText(11, "Password:")
  local password = centerTextInput(13, "*")

  local adminPath = "user/.admin/admin.txt"
  local file = fs.open(adminPath, "r")
  if file then
    local storedUsername = file.readLine()
    local storedPassword = file.readLine()
    file.close()

    if username == storedUsername and password == storedPassword then
      return true
    end
  end

  return false
end

local function executeBurlaOS()
  clearScreen()

  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()

  centerText(4, "Login successful.")
  sleep(2)

  clearScreen()
  shell.execute("user/BurlaOS/BurlaOS.lua")

  os.reboot()
end

local function handleKeyPress(event)
  if event[1] == "key" and event[2] == keys.leftCtrl then
    shell.run("shutdown")
    os.queueEvent("terminate")
  end
end

local function createAdminIfNotExists()
  local adminPath = "user/.admin/admin.txt"
  if not fs.exists(adminPath) then
    showAdminAccountCreationForm()
  end
end

local function printAsciiArt()
  local art = [[
	
		 __        __                __   __  
		|__) |  | |__) |     /\     /  \ /__` 
		|__) \__/ |  \ |___ /~~\    \__/ .__/ 
                                      
  ]]

  clearScreen()
  term.setTextColor(colors.cyan)
  centerText(2, art)
  term.setTextColor(colors.white)
end

local function main()
  createAdminIfNotExists()

  local isLoggedInAsAdmin = false

  while true do
    printAsciiArt()

    centerText(12, "1. Login as administrator")
    centerText(14, "2. Create user accounts")
    centerText(16, "Enter your choice:")

    local choice = tonumber(centerTextInput(18, ""))

    if choice == 1 then
      isLoggedInAsAdmin = showLoginForm()
      break
    elseif choice == 2 then
      showAdminAccountCreationForm()
      os.queueEvent("terminate")
    else
      clearScreen()
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)

      centerText(4, "Invalid option. Please try again")
      sleep(2)
    end
  end

  while true do
    printAsciiArt()

    centerText(12, "1. Run BurlaOS")
    if isLoggedInAsAdmin then
      centerText(14, "2. Create user accounts")
    end
    centerText(16, "Enter your choice:")

    local choice = tonumber(centerTextInput(18, ""))

    if choice == 1 then
      if isLoggedInAsAdmin then
        executeBurlaOS()
      else
        clearScreen()
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)

        centerText(4, "Not logged in as administrator")
        sleep(2)
      end
    elseif choice == 2 and isLoggedInAsAdmin then
      showAdminAccountCreationForm()
      os.queueEvent("terminate")
    else
      clearScreen()
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)

      centerText(4, "Invalid option. Please try again")
      sleep(2)
    end
  end
end

parallel.waitForAny(main, function()
  while true do
    local event = { os.pullEvent() }
    handleKeyPress(event)
  end
end)
