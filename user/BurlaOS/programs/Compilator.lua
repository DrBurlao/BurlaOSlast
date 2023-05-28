-- Función para combinar archivos y carpetas en un solo archivo
local function combinarArchivos(carpetaOrigen, archivoDestino)
    -- Abrir el archivo de destino en modo de escritura
    local archivoDestinoHandle = fs.open(archivoDestino, "w")

    -- Función recursiva para combinar archivos y carpetas
    local function combinarRecursivo(carpeta, rutaRelativa)
        local archivos = fs.list(carpeta) -- Obtener una lista de archivos en la carpeta actual

        for _, archivo in ipairs(archivos) do
            local rutaArchivo = fs.combine(carpeta, archivo) -- Obtener la ruta completa del archivo
            local rutaArchivoDestino = fs.combine(rutaRelativa, archivo) -- Ruta del archivo en el destino

            if fs.isDir(rutaArchivo) then -- Si es una carpeta, llamar a la función recursivamente
                combinarRecursivo(rutaArchivo, rutaArchivoDestino)
            else -- Si es un archivo, copiar su contenido en el archivo de destino
                local archivoHandle = fs.open(rutaArchivo, "r")
                local contenido = archivoHandle.readAll()
                archivoDestinoHandle.writeLine("-- Archivo: "..rutaArchivoDestino)
                archivoDestinoHandle.writeLine(contenido)
                archivoDestinoHandle.writeLine("-- Fin archivo: "..rutaArchivoDestino)
                archivoHandle.close()
            end
        end
    end

    -- Llamada inicial a la función recursiva
    combinarRecursivo(carpetaOrigen, "")

    -- Cerrar el archivo de destino
    archivoDestinoHandle.close()

    print("Archivos combinados en: "..archivoDestino)
end

-- Función para mostrar el menú y recibir la entrada del usuario
local function mostrarMenu()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Menú de Combinación de Archivos ===")
    print("1. Combinar archivos y carpetas")
    print("2. Salir")
    print("--------------------------------------")
    write("Seleccione una opción: ")
    local opcion = tonumber(read())

    if opcion == 1 then
        write("Ingrese la ruta de la carpeta que desea combinar: ")
        local carpetaOrigen = read()
        write("Ingrese la ruta y el nombre del archivo de destino: ")
        local archivoDestino = read()
        combinarArchivos(carpetaOrigen, archivoDestino)
        print("Presione cualquier tecla para volver al menú principal.")
        os.pullEvent("key")
        mostrarMenu()
    elseif opcion == 2 then
        print("¡Hasta luego!")
    else
        print("Opción inválida. Presione cualquier tecla para volver al menú principal.")
        os.pullEvent("key")
        mostrarMenu()
    end
end

-- Llamada inicial para mostrar el menú
mostrarMenu()
