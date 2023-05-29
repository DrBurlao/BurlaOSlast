-- Función para ejecutar el archivo /BOOT.lua
local function ejecutarBoot()
  if fs.exists("/BOOT.lua") then
    shell.run("/BOOT.lua") -- Ejecutar el archivo /BOOT.lua
  else
    print("No se encontró el archivo /BOOT.lua.")
  end
end

-- Ejecutar /BOOT.lua
ejecutarBoot()

-- Cerrar el programa
os.queueEvent("terminate")
os.pullEvent("terminate")
