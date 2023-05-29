-- Ruta de los archivos de registro
local commandFile = "/user/keyloggercmd.txt"

-- Variable para controlar si la consola de comandos está en ejecución
local commandRunning = false

-- Función para reiniciar los archivos de registro
local function resetLogFiles()
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
        shell.run(input)
      end
    end
  end

  commandRunning = false  -- Marcar la consola de comandos como no en ejecución
end

-- Función principal
local function main()
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.cyan)
  print("Key Logging Disabled")
  term.setTextColor(colors.white)

  while true do
    local event, key = os.pullEvent("key")
    if key == keys.rightCtrl then
      -- Mostrar opciones de reinicio y lectura de registros
      term.clear()
      term.setCursorPos(1, 1)
      term.setTextColor(colors.cyan)
      print("Key Logging Stopped")
      term.setTextColor(colors.yellow)
      print("[R] Reset Logs")
      print("[L] Read Logs")
      print("[Q] Quit")
      term.setTextColor(colors.white)

      while true do
        local input = read():lower()
        if input == "r" then
          resetLogFiles()
          print("Log files reset.")
        elseif input == "l" then
          local logs = readLogs(commandFile)
          if logs then
            print(logs)
          else
            print("No logs available.")
          end
        elseif input == "q" then
          term.clear()
          term.setCursorPos(1, 1)
          os.exit() -- Cerrar el programa
        end
      end

      term.clear()
      term.setCursorPos(1, 1)
      term.setTextColor(colors.cyan)
      print("Key Logging Disabled")
      term.setTextColor(colors.white)
    end
  end
end

-- Ejecutar la consola de comandos en paralelo
parallel.waitForAny(main, handleCommandInput)

os.exit() -- Cerrar el programa al finalizar
