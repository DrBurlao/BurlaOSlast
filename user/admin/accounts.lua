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

local function createAdminAccount()
  clearScreen()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  centerText(4, "Create Admin Account")

  centerText(7, "Username:")
  local adminUsername = centerTextInput(9, "")

  -- Save the admin username to the admin.txt file
  local adminPath = "/user/.admin/admin.txt"
  local file = fs.open(adminPath, "w")
  if file then
    file.writeLine(adminUsername)
    file.close()
    clearScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    centerText(4, "Admin Account Created:")
    centerText(6, "Username: " .. adminUsername)
    sleep(2)
  else
    error("Failed to create admin information file.")
  end
end

local function validateAdminAccount()
  local adminPath = "/user/.admin/admin.txt"
  if fs.exists(adminPath) then
    local file = fs.open(adminPath, "r")
    if file then
      local adminUsername = file.readLine()
      file.close()
      return adminUsername
    end
  end
  return nil
end

local function showAccountCreationForm()
  clearScreen()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  centerText(4, "Create User Account")

  centerText(7, "Username:")
  local username = centerTextInput(9, "")

  centerText(11, "Password:")
  local password = centerTextInput(13, "*")

  -- Create user folder
  local userFolderPath = "/user/" .. username
  fs.makeDir(userFolderPath)

  -- Save user account to a file
  local userFilePath = "/user/.admin/" .. username .. ".txt"
  local file = fs.open(userFilePath, "w")
  if file then
    file.writeLine(username)
    file.writeLine(password)
    file.close()
    clearScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    centerText(4, "User Account Created:")
    centerText(6, "Username: " .. username)
    sleep(2)
  else
    error("Failed to create user information file.")
  end
end

local function showAccountDeletionForm()
  clearScreen()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  centerText(4, "Delete User Account")

  centerText(7, "Username:")
  local username = centerTextInput(9, "")

  -- Delete user folder
  local userFolderPath = "/user/" .. username
  fs.delete(userFolderPath)

  -- Delete user account file
  local userFilePath = "/user/.admin/" .. username .. ".txt"
  fs.delete(userFilePath)

  clearScreen()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  centerText(4, "User Account Deleted:")
  centerText(6, "Username: " .. username)
  sleep(2)
end

local function showChangePasswordForm()
  clearScreen()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  centerText(4, "Change Password")

  centerText(7, "Username:")
  local username = centerTextInput(9, "")

  -- Check if user exists
  local userFilePath = "/user/.admin/" .. username .. ".txt"
  if not fs.exists(userFilePath) then
    clearScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    centerText(4, "User does not exist")
    sleep(2)
    return
  end

  -- Read current password from file
  local file = fs.open(userFilePath, "r")
  local storedUsername = file.readLine()
  local storedPassword = file.readLine()
  file.close()

  -- Request new password
  centerText(11, "New Password:")
  local newPassword = centerTextInput(13, "*")

  -- Save new password to the file
  file = fs.open(userFilePath, "w")
  if file then
    file.writeLine(storedUsername)
    file.writeLine(newPassword)
    file.close()
    clearScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    centerText(4, "Password changed successfully")
    sleep(2)
  else
    error("Failed to save the new password.")
  end
end

local function showAccountManagementMenu()
  while true do
    clearScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    centerText(4, "User Account Management")
    centerText(7, "1. Create User Account")
    centerText(9, "2. Delete User Account")
    centerText(11, "3. Change Password")
    centerText(13, "4. Exit")
    centerText(16, "Enter your choice:")

    local choice = tonumber(centerTextInput(18, ""))

    if choice == 1 then
      showAccountCreationForm()
    elseif choice == 2 then
      showAccountDeletionForm()
    elseif choice == 3 then
      showChangePasswordForm()
    elseif choice == 4 then
      return
    else
      clearScreen()
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)

      centerText(4, "Invalid option. Please try again.")
      sleep(2)
    end
  end
end

local function handleKeyPress(event)
  if event[1] == "key" and event[2] == keys.leftCtrl then
    shell.run("shutdown")
    os.queueEvent("terminate")
  end
end

local function main()
  local adminUsername = validateAdminAccount()

  if not adminUsername then
    createAdminAccount()
    return
  end

  while true do
    clearScreen()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    centerText(4, "User Account Management")
    centerText(7, "1. Manage User Accounts")
    centerText(9, "2. Exit")
    centerText(12, "Enter your choice:")

    local choice = tonumber(centerTextInput(14, ""))

    if choice == 1 then
      showAccountManagementMenu()
    elseif choice == 2 then
      shell.run("/user/BurlaOS/Loggin.lua")
      return
    else
      clearScreen()
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)

      centerText(4, "Invalid option. Please try again.")
      sleep(2)
    end
  end
end

-- Main program
clearScreen()
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)

-- Handle key press
parallel.waitForAny(main, function()
  while true do
    local event = {os.pullEvent()}
    handleKeyPress(event)
  end
end)
