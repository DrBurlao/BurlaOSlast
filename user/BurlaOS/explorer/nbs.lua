-- Limpia la pantalla
term.clear()
term.setCursorPos(1, 1)

-- Función recursiva para escanear carpetas y subcarpetas
local function scanFolder(folder)
    local fileList = {}
    local subFolders = {}

    -- Escanea los archivos en la carpeta actual
    for _, file in ipairs(fs.list(folder)) do
        local path = fs.combine(folder, file)
        if fs.isDir(path) then
            -- Si es una carpeta, añádela a la lista de subcarpetas para escanear más tarde
            table.insert(subFolders, path)
        elseif fs.getName(path):match("%.nbs$") then
            -- Si es un archivo con extensión .nbs, añádelo a la lista de archivos
            table.insert(fileList, path)
        end
    end

    -- Escanea las subcarpetas recursivamente
    for _, subFolder in ipairs(subFolders) do
        local subFiles = scanFolder(subFolder)
        -- Agrega los archivos encontrados en las subcarpetas a la lista principal
        for _, subFile in ipairs(subFiles) do
            table.insert(fileList, subFile)
        end
    end

    return fileList
end

-- Carpeta raíz desde donde se iniciará el escaneo
local rootFolder = "."

-- Escanea la carpeta raíz y obtiene la lista de archivos .nbs
local nbsFiles = scanFolder(rootFolder)

-- Imprime la lista de archivos encontrados de forma bonita y clara
print("Archivos .nbs encontrados:")
if #nbsFiles > 0 then
    for i, file in ipairs(nbsFiles) do
        print(i .. ". " .. file)
    end

    -- Detecta automáticamente la unidad de cinta y la unidad de disquete
    local tapeDriveSide, floppyDriveSide
    for _, side in ipairs(rs.getSides()) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "tape_drive" then
            tapeDriveSide = side
        elseif peripheral.isPresent(side) and peripheral.getType(side) == "drive" and disk.hasData(side) then
            floppyDriveSide = side
        elseif peripheral.isPresent(side) and peripheral.getType(side) == "wired_modem" then
            local modem = peripheral.wrap(side)
            if modem.hasPeripheral("tape_drive") then
                tapeDriveSide = side
            elseif modem.hasPeripheral("drive") and disk.hasData(modem.getPeripheral("drive")) then
                floppyDriveSide = side
            end
        end
    end

    -- Solicita la opción de destino al usuario
    print("\nSelecciona la opción de destino:")
    if tapeDriveSide then
        print("1. Enviar a unidad de cinta (" .. tapeDriveSide .. ")")
    end
    if floppyDriveSide then
        print("2. Enviar a unidad de disquete (" .. floppyDriveSide .. ")")
    end
    write("Ingresa el número de opción: ")
    local option = tonumber(read())

    -- Verifica la opción seleccionada y realiza la acción correspondiente
    if option == 1 and tapeDriveSide then
        -- Enviar archivos a la unidad de cinta
        local tapeDrive = peripheral.wrap(tapeDriveSide)
        for _, file in ipairs(nbsFiles) do
            tapeDrive.seek(-tapeDrive.getSize()) -- Vuelve al principio de la cinta
            local handle = tapeDrive.open(fs.getName(file), "w")
            local contents = fs.open(file, "r")
            tapeDrive.write(contents.readAll())
            tapeDrive.close(handle)
            print("Archivo '" .. fs.getName(file) .. "' enviado a la unidad de cinta.")
        end
    elseif option == 2 and floppyDriveSide then
        -- Enviar archivos a la unidad de disquete
        local floppyDrive = peripheral.wrap(floppyDriveSide)
        local floppyPath = disk.getMountPath(floppyDriveSide)
        for _, file in ipairs(nbsFiles) do
            fs.copy(file, fs.combine(floppyPath, fs.getName(file)))
            print("Archivo '" .. fs.getName(file) .. "' enviado a la unidad de disquete.")
        end
    else
        print("\nOpción inválida o no se encontró la unidad correspondiente.")
    end
else
    print("No se encontraron archivos .nbs.")
end

-- Espera a que se pulse un botón para salir
print("\nPulsa cualquier botón para salir.")
os.pullEvent("key")
