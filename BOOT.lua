-- Adaptar resolución y mostrar barra de progreso durante la espera de 10 segundos
local espera = 10 -- tiempo en segundos
local programaBg1 = "/user/BurlaOS/Boot.lua" -- ruta al primer programa a ejecutar en segundo plano
local programaBg2 = "/BurlaCMD.lua" -- ruta al segundo programa a ejecutar en segundo plano

-- Función para obtener la resolución actual de la terminal
function obtenerResolucion()
  local w, h = term.getSize()
  return w, h
end

-- Función para ajustar la resolución de la terminal
function ajustarResolucion(ancho, alto)
  term.clear()
  term.setCursorPos(1, 1)
  term.redirect(term.native())
  term.native().setCursorPos(1, 1)
  term.native().setTextColor(colors.white)
  term.native().setBackgroundColor(colors.black)
  term.native().clear()
  term.native().setCursorPos(1, 1)

  local native = term.native()
  local w, h = native.getSize()

  if w ~= ancho or h ~= alto then
    native.setViewport(1, 1, ancho, alto)
  end
end

-- Función para mostrar una barra de progreso
function mostrarBarraProgreso(porcentaje)
  local screenWidth, screenHeight = term.getSize()
  local barWidth = math.floor(screenWidth * 0.8)
  local barHeight = 5
  local barPaddingX = math.floor(screenWidth * 0.1)
  local barPaddingY = math.floor(screenHeight * 0.4)
  local barFill = math.floor(barWidth * porcentaje / 100)

  term.setBackgroundColor(colors.green)
  term.clear()

  for i = 1, barHeight do
    term.setCursorPos(barPaddingX, barPaddingY + i)
    term.write((" "):rep(barWidth))
  end

  term.setCursorPos(barPaddingX + 1, barPaddingY + 1)
  term.setBackgroundColor(colors.red)
  term.write((" "):rep(barFill))

  term.setCursorPos(barPaddingX + math.floor((barWidth - 4) / 2), barPaddingY + math.floor((barHeight - 2) / 2))
  term.setBackgroundColor(colors.red)
  term.setTextColor(colors.white)
  term.write(string.format("%.1f", porcentaje) .. "%")
end

-- Función para mostrar barras verticales de colores aleatorios
function mostrarBarrasVerticales()
  local screenWidth, screenHeight = term.getSize()
  local numBarras = 10
  local barWidth = math.floor(screenWidth * 0.2)
  local barHeight = math.floor(screenHeight * 0.2)
  local barPaddingX = math.floor((screenWidth - barWidth) / 2)
  local barPaddingY = math.floor((screenHeight - barHeight) / 2)

  for i = 1, numBarras do
    local posX = math.random(barPaddingX, barPaddingX + barWidth - 1)
    local posY = math.random(barPaddingY, barPaddingY + barHeight - 1)
    local barColor = math.random(1, 15)
    local frameColor = colors.black

    term.setBackgroundColor(frameColor)
    term.setTextColor(frameColor)
    term.setCursorPos(posX - 1, posY - 1)
    term.write((" "):rep(barWidth + 2))

    term.setBackgroundColor(barColor)
    term.setTextColor(barColor)

    for k = 1, barHeight do
      term.setCursorPos(posX, posY + k - 1)
      term.write(" ")
    end

    term.setCursorPos(posX - 1, posY + barHeight)
    term.write((" "):rep(barWidth + 2))
  end
end

-- Función para mostrar el texto "Loading..." con puntos que aparecen y desaparecen
function mostrarLoading()
  local screenWidth, screenHeight = term.getSize()
  local loadingText = "Loading"
  local dotCount = 0
  local dotMaxCount = 3
  local loadingX = math.floor((screenWidth - #loadingText) / 2)
  local loadingY = math.floor(screenHeight * 0.7)

  while true do
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(loadingX, loadingY)
    term.write(loadingText .. string.rep(".", dotCount))
    os.sleep(0.5)

    dotCount = dotCount + 1
    if dotCount > dotMaxCount then
      dotCount = 0
    end
  end
end

print("Adaptando resolución antes de la espera de 10 segundos...")
local screenWidth, screenHeight = obtenerResolucion()
ajustarResolucion(screenWidth, screenHeight)
print("Resolución adaptada. Esperando...")
parallel.waitForAny(mostrarLoading, function()
  for i = 1, espera do
    local porcentaje = (i / espera) * 100
    mostrarBarraProgreso(porcentaje)
    mostrarBarrasVerticales()
    os.sleep(1)
  end
end)

term.clear()

local function ejecutarProgramaBg(programa)
  shell.run("bg", programa)
end

parallel.waitForAny(
  function()
    ejecutarProgramaBg(programaBg1)
  end,
  function()
    ejecutarProgramaBg(programaBg2)
  end
)

os.sleep(2)
term.clear()
os.queueEvent("terminate")
