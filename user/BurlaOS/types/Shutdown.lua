-- Función para imprimir el arte ASCII en el monitor y en la computadora
local function printAsciiArt(art, width, height)
  term.clear()
  local lines = {}
  for line in art:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  local startY = math.floor((height - #lines) / 2) + 1
  for _, line in ipairs(lines) do
    local startX = math.floor((width - #line) / 2) + 1
    term.setCursorPos(startX, startY)
    print(line)
    startY = startY + 1
  end
end

-- Función para buscar un monitor adjunto
local function findAttachedMonitor()
  for _, peripheralName in ipairs(peripheral.getNames()) do
    if peripheral.getType(peripheralName) == "monitor" then
      return peripheral.wrap(peripheralName)
    end
  end
  return nil
end

-- Función para buscar un modem cableado adjunto
local function findAttachedModem()
  for _, peripheralName in ipairs(peripheral.getNames()) do
    if peripheral.getType(peripheralName) == "modem" and peripheral.call(peripheralName, "isWireless") == false then
      return peripheral.wrap(peripheralName)
    end
  end
  return nil
end

-- Obtener el arte ASCII
local asciiArt = [[
 ______  _     _ _______ 
(____  \| |   | (_______)
 ____)  ) |___| |_____   
|  __  ( \_____/|  ___)  
| |__)  )  ___  | |_____ 
|______/  (___) |_______)
]]

-- Buscar y configurar el monitor
local monitor = findAttachedMonitor()
if monitor then
  local width, height = monitor.getSize()
  printAsciiArt(asciiArt, width, height)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write(asciiArt)
end

-- Imprimir el arte ASCII en la computadora
local termWidth, termHeight = term.getSize()
printAsciiArt(asciiArt, termWidth, termHeight)

-- Esperar un tiempo antes de continuar
sleep(3)

-- Apagar la computadora
os.shutdown()
