local running = true

local function displayProcesses(processes)
  term.clear()
  term.setCursorPos(1, 1)

  print("Running Processes:")
  for i, process in ipairs(processes) do
    term.setTextColor(colors.yellow)  -- Color amarillo para el número de proceso
    write(i .. ". ")
    term.setTextColor(colors.white)  -- Color blanco para el nombre del proceso
    print(process)
  end
end

while running do
  os.queueEvent("os_process_list")
  os.pullEvent("os_process_list")
  local processes = {os.pullEvent()}

  displayProcesses(processes)

  term.setTextColor(colors.cyan)  -- Color cyan para las opciones del menú
  print("Options:")
  print("1. Close a process")
  print("2. Refresh process list")
  print("3. Open in new tab")
  print("4. Exit")
  term.setTextColor(colors.white)  -- Restaurar color blanco para el texto restante

  local option = tonumber(io.read())

  if option == 1 then
    displayProcesses(processes)
    print("Enter the number of the process to close:")
    local processNumber = tonumber(io.read())
    if processNumber and processNumber >= 1 and processNumber <= #processes then
      local processToClose = processes[processNumber]
      os.queueEvent("os_close_process", processToClose)
      os.pullEvent("os_process_closed")
      term.setTextColor(colors.green)  -- Color verde para el mensaje de proceso cerrado
      print("Process closed: " .. processToClose)
      os.sleep(2)
    else
      term.setTextColor(colors.red)  -- Color rojo para el mensaje de número de proceso inválido
      print("Invalid process number")
      os.sleep(2)
    end
  elseif option == 2 then
    -- Refresh process list, no action needed
  elseif option == 3 then
    displayProcesses(processes)
    print("Enter the number of the process to open in a new tab:")
    local processNumber = tonumber(io.read())
    if processNumber and processNumber >= 1 and processNumber <= #processes then
      local processToOpen = processes[processNumber]
      os.queueEvent("os_open_process_tab", processToOpen)
      term.setTextColor(colors.green)  -- Color verde para el mensaje de proceso abierto en una nueva pestaña
      print("Process opened in a new tab: " .. processToOpen)
      os.sleep(2)
    else
      term.setTextColor(colors.red)  -- Color rojo para el mensaje de número de proceso inválido
      print("Invalid process number")
      os.sleep(2)
    end
  elseif option == 4 then
    break
  else
    term.setTextColor(colors.red)  -- Color rojo para el mensaje de opción inválida
    print("Invalid option")
    os.sleep(2)
  end
end
