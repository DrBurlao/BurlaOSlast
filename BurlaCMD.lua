-- Ruta de los archivos de registro
local dataFile = "/user/keylogger.txt"
local commandFile = "/user/keyloggercmd.txt"

-- Variable para controlar si la consola de comandos está en ejecución
local commandRunning = false

-- Función para registrar una acción en un archivo
local function recordAction(action, file)
  local file = fs.open(file, "a")
  file.writeLine(action)
  file.close()
end

-- Función para reiniciar los archivos de registro
local function resetLogFiles()
  if fs.exists(dataFile) then
    fs.delete(dataFile)
  end

  if fs.exists(commandFile) then
    fs.delete(commandFile)
  end
end

-- Función para leer el contenido de un archivo
local function readLogs(file)
  if not fs.exists(file) then
    return nil
  end

  local file = fs.open(file, "r")
  local logs = file.readAll()
  file.close()

  return logs
end

-- Función para obtener una lista de comandos disponibles para autocompletar
local function getAvailableCommands()
  local availableCommands = {}
  local env = _ENV or getfenv()

  for key, value in pairs(env) do
    if type(value) == "function" and not key:match("^_") then
      table.insert(availableCommands, key)
    end
  end

  return availableCommands
end

-- Función para realizar la autocompletación de comandos
local function autocompleteCommand(input)
  local availableCommands = getAvailableCommands()
  local matches = {}

  for _, command in ipairs(availableCommands) do
    if command:sub(1, #input) == input then
      table.insert(matches, command)
    end
  end

  return matches
end

-- Función para manejar la entrada de comandos
local function handleCommandInput()
  -- Salir si la consola de comandos ya está en ejecución
  if commandRunning then
    return
  end

  commandRunning = true  -- Marcar la consola de comandos como en ejecución

  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.cyan)
  print("BurlaOS Command Prompt")
  term.setTextColor(colors.white)

  while true do
    term.setTextColor(colors.yellow)
    write("> ")
    term.setTextColor(colors.white)

    local input = read(nil, nil, nil, nil, nil, autocompleteCommand)
    if input then
      if input == "reset" then
        resetLogFiles()
        print("Log files reset.")
      elseif input == "exit" then
        term.clear()
        term.setCursorPos(1, 1)
        break
      else
        recordAction(input, commandFile)
        shell.run(input)
      end
    end
  end

  commandRunning = false  -- Marcar la consola de comandos como no en ejecución
end

-- Función para realizar el envío de registros a través del modem con cable
local function sendLogsToRemoteDevice()
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.cyan)
  print("Sending Logs to Remote Device")
  term.setTextColor(colors.white)

  -- Buscar el modem con cable adjunto
  local modem = peripheral.find("modem")
  if not modem then
    term.setTextColor(colors.red)
    print("Wired modem not found.")
    term.setTextColor(colors.white)
    return
  end

  -- Solicitar la dirección del dispositivo remoto
  term.setTextColor(colors.yellow)
  write("Enter Remote Device ID: ")
  term.setTextColor(colors.white)
  local remoteID = tonumber(read())

  -- Verificar si se ingresó un ID de dispositivo válido
  if not remoteID then
    term.setTextColor(colors.red)
    print("Invalid remote device ID.")
    term.setTextColor(colors.white)
    return
  end

  -- Leer los registros locales
  local logs = readLogs(dataFile)
  if logs then
    -- Enviar los registros al dispositivo remoto
    term.setTextColor(colors.yellow)
    print("Sending logs to remote device...")
    term.setTextColor(colors.white)
    modem.transmit(remoteID, remoteID, logs)

    term.setTextColor(colors.green)
    print("Logs sent successfully.")
    term.setTextColor(colors.white)
  else
    term.setTextColor(colors.red)
    print("No logs available.")
    term.setTextColor(colors.white)
  end
end

-- Función para ejecutar "/user/BurlaOS/Loader.lua" en segundo plano
local function runLoader()
  shell.execute("bg /user/BurlaOS/Loader.lua")
end

-- Función principal
local function main()
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.cyan)
  print("Key Logging Started")
  term.setTextColor(colors.yellow)
  print("Press Right Ctrl to stop logging")
  term.setTextColor(colors.white)

  local running = true
  local logLine = ""

  while running do
    local event, key = os.pullEvent("key")
    if key == keys.rightCtrl then
      -- Mostrar opciones de reinicio y envío de registros remotos
      term.clear()
      term.setCursorPos(1, 1)
      term.setTextColor(colors.cyan)
      print("Key Logging Stopped")
      term.setTextColor(colors.yellow)
      print("[R] Reset Logs")
      print("[L] Read Logs")
      print("[S] Send Logs to Remote Device")
      print("[Q] Quit")
      term.setTextColor(colors.white)

      while true do
        local input = read():lower()
        if input == "r" then
          resetLogFiles()
          print("Log files reset.")
        elseif input == "l" then
          local logs = readLogs(dataFile)
          if logs then
            print(logs)
          else
            print("No logs available.")
          end
        elseif input == "s" then
          sendLogsToRemoteDevice()
        elseif input == "q" then
          running = false
          break
        end
      end

      if not running then
        break
      end

      term.clear()
      term.setCursorPos(1, 1)
      term.setTextColor(colors.cyan)
      print("Key Logging Started")
      term.setTextColor(colors.yellow)
      print("Press Right Ctrl to stop logging")
      term.setTextColor(colors.white)
    else
      local action = keys.getName(key) or string.char(key)
      logLine = logLine .. action
      recordAction(action, dataFile)
    end
  end
end

-- Ejecutar el keylogger y la consola de comandos en paralelo
parallel.waitForAny(main, handleCommandInput)
