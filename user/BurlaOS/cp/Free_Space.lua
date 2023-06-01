-- Función para mostrar el espacio disponible en una carpeta y sus subcarpetas
local function mostrarEspacioCarpeta(ruta)
  local archivos = fs.list(ruta)
  local espacioTotal = 0
  local espacioDisponible = 0

  for _, archivo in ipairs(archivos) do
    local rutaArchivo = fs.combine(ruta, archivo)

    if fs.isDir(rutaArchivo) then
      local espacioSubcarpeta = mostrarEspacioCarpeta(rutaArchivo)
      espacioTotal = espacioTotal + espacioSubcarpeta
    else
      local espacioArchivo = fs.getSize(rutaArchivo)
      espacioTotal = espacioTotal + espacioArchivo
    end
  end

  espacioDisponible = fs.getFreeSpace(ruta)
  local espacioUsado = espacioTotal - espacioDisponible
  local porcentajeOcupado = (espacioUsado / espacioTotal) * 100

  print("Espacio en " .. ruta .. ":")
  print("Espacio total: " .. espacioTotal .. "KB")
  print("Espacio usado: " .. espacioUsado .. "KB")
  print("Espacio disponible: " .. espacioDisponible .. "KB")
  print("Porcentaje ocupado: " .. string.format("%.2f", porcentajeOcupado) .. "%")

  return espacioTotal
end

-- Función para mostrar el espacio disponible en los drives conectados a través de un Wired Modem
local function mostrarEspacioDrives()
  local modems = peripheral.find("wired_modem")
  local espacioTotal = 0

  if modems then
    for _, modem in ipairs(modems) do
      local drives = peripheral.getNamesRemote(modem)

      for _, drive in ipairs(drives) do
        local espacioDrive = peripheral.callRemote(drive, "getFreeSpace")
        local etiquetaDrive = peripheral.callRemote(drive, "getDiskLabel")
        local espacioUsado = espacioDrive.total - espacioDrive.available
        local porcentajeOcupado = (espacioUsado / espacioDrive.total) * 100

        print("Espacio en drive " .. etiquetaDrive .. ":")
        print("Espacio total: " .. espacioDrive.total .. "KB")
        print("Espacio usado: " .. espacioUsado .. "KB")
        print("Espacio disponible: " .. espacioDrive.available .. "KB")
        print("Porcentaje ocupado: " .. string.format("%.2f", porcentajeOcupado) .. "%")

        espacioTotal = espacioTotal + espacioDrive.total
      end
    end
  end

  return espacioTotal
end

-- Función para mostrar el menú intermedio
local function mostrarMenuIntermedio()
  print("¿Qué información de espacio deseas ver?")
  print("1. Espacio en carpetas")
  print("2. Espacio en drives")
  print("3. Salir")

  local opcion = tonumber(read())

  if opcion == 1 then
    mostrarEspacioCarpeta("/")
  elseif opcion == 2 then
    mostrarEspacioDrives()
  elseif opcion == 3 then
    print("Saliendo...")
  else
    print("Opción inválida.")
  end

  print("Presiona Enter para continuar...")
  read()
end

-- Llamada al menú intermedio
mostrarMenuIntermedio()
