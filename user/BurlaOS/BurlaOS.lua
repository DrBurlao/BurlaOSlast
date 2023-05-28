local monitor = nil
local term = nil

-- Buscar un monitor conectado
for _, p in ipairs(peripheral.getNames()) do
  if peripheral.getType(p) == "monitor" then
    monitor = peripheral.wrap(p)
    if monitor.isColor() then
      break
    else
      monitor = nil
    end
  end
end

-- Buscar un módem conectado
local modem = peripheral.find("modem")

if modem and not monitor then
  -- Buscar un monitor a través del módem
  modem.transmit(1, 1, "monitor_detect")
  local timer = os.startTimer(5)
  while true do
    local event, side, channel, reply, message = os.pullEvent()
    if event == "modem_message" and channel == 1 and message == "monitor_attached" then
      monitor = peripheral.wrap(side)
      if monitor.isColor() then
        break
      else
        monitor = nil
      end
    elseif event == "timer" and side == timer then
      break
    end
  end
end

-- Si se encuentra un monitor, úsalo como terminal
if monitor then
  term = monitor
else
  term = peripheral.find("terminal")
end

if not term then
  error("No se detectó ningún monitor o módem con cable.")
end

local categories = {
  {name = "Programs", path = "/user/BurlaOS/types/Programs.lua"},
  {name = "Games", path = "/user/BurlaOS/types/Games.lua"},
  {name = "File explorer", path = "/user/BurlaOS/types/FileExplorer.lua"},
  {name = "User's apps", path = "/user/BurlaOS/types/UserApps.lua"},
  {name = "Control Panel", path = "/user/BurlaOS/types/ControlPanel.lua"},
  {name = "Media", path = "/user/BurlaOS/types/Multimedia.lua"},
  {name = "Shutdown", path = "/user/BurlaOS/types/Shutdown.lua"}
}

local currentCategory = 1

local function clearScreen()
  term.setTextColour(colours.red)
  term.setBackgroundColor(colours.black)
  term.clear()
  term.setCursorPos(1, 1)
end

local function drawLauncher()
  clearScreen()

  local width, height = term.getSize()

  -- Cargar ASCII art desde un archivo
  local asciiPath = "/user/BurlaOS/ascii_art.txt"
  if fs.exists(asciiPath) then
    local file = fs.open(asciiPath, "r")
    local asciiArt = file.readAll()
    file.close()

    -- Calcular las coordenadas para centrar el ASCII art
    local asciiLines = {}
    for line in asciiArt:gmatch("[^\r\n]+") do
      table.insert(asciiLines, line)
    end

    local asciiX = math.floor((width - #asciiLines[1]) / 2)
    local asciiY = math.floor(height / 3)

    term.setTextColour(colours.lightBlue)
    term.setBackgroundColor(colours.black)

    for i, line in ipairs(asciiLines) do
      term.setCursorPos(asciiX, asciiY + i - 1)
      term.write(line)
    end
  end

  -- Draw Instagram text in the top left corner
  term.setTextColour(colours.black)
  term.setBackgroundColor(colours.magenta)
  term.setCursorPos(1, 1)
  term.write(" Instagram:@bloodproof ")

  -- Draw FPS in the top right corner
  local fps = "FPS: 59"
  term.setTextColour(colours.green)
  term.setBackgroundColor(colours.black)
  term.setCursorPos(width - #fps + 1, 1)
  term.write(fps)

  -- Draw blue bar at the bottom
  term.setTextColour(colours.white)
  term.setBackgroundColor(colours.blue)
  term.setCursorPos(1, height)
  term.write(string.rep(" ", width))

  -- Draw digital clock in the bottom right corner
  local currentTime = os.date("%H:%M:%S")
  term.setTextColour(colours.red)
  term.setBackgroundColor(colours.cyan)
  term.setCursorPos(width - #currentTime + 1, height)
  term.write(currentTime)

  local startY = math.floor((height - #categories) / 2) - 1

  for i, category in ipairs(categories) do
    term.setTextColour(colours.red)
    term.setBackgroundColor(colours.black) -- Set background color to black for all categories

    term.setCursorPos((width - #category.name) / 2, startY + i * 2)

    if i == currentCategory then
      term.write("> ")
      term.setTextColour(colours.green)
      term.write(category.name)
      term.setTextColour(colours.red)
      term.write(" <")
	  
    else
      term.write("  ")
      term.setTextColour(colours.orange)
      term.write(category.name)
    end
  end
end

local function createDirectory(directory)
  if not fs.exists(directory) then
    fs.makeDir(directory)
  end
end

local function createDirectories()
  for _, category in ipairs(categories) do
    createDirectory(category.path)
  end
end

local function executeProgram(path)
  shell.run(path .. " &")
end

local function openCategory()
  local category = categories[currentCategory]
  local path = category.path

  executeProgram(path)
end

local function handleInput()
  while true do
    local event, key = os.pullEvent("key")
    if key == keys.up then
      currentCategory = currentCategory - 1
      if currentCategory < 1 then
        currentCategory = #categories
      end
      drawLauncher()
    elseif key == keys.down then
      currentCategory = currentCategory + 1
      if currentCategory > #categories then
        currentCategory = 1
      end
      drawLauncher()
    elseif key == keys.enter then
      openCategory()
    end
  end
end

local function main()
  createDirectories()
  drawLauncher()
  handleInput()
end

createDirectories()

parallel.waitForAny(main, function()
  while true do
    sleep(1)
    drawLauncher()
  end
end)
