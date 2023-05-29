term.clear()
term.setCursorPos(1, 1)

print([[
 ____ ____  ____ __  __ ____ __     __   _____ 
(  _ (  _ \(  _ (  )(  (  _ (  )   /__\ (  _  )
 )(_) )   / ) _ <)(__)( )   /)(__ /(__)\ )(_)( 
(____(_)\_((____(______(_)\_(____(__)(__(_____)

 ____ __  __ __  __ ____ ____ ____ ____ 
(  _ (  )(  (  \/  (  _ (  _ ( ___(  _ \
 )(_) )(__)( )    ( )___/)___/)__) )   /
(____(______(_/\/\_(__) (__) (____(_)\_)


]])
sleep(3)

local diskDrive

-- Find the disk drive peripheral
for _, name in ipairs(peripheral.getNames()) do
  if peripheral.getType(name) == "drive" then
    diskDrive = peripheral.wrap(name)
    break
  end
end

if diskDrive then
  if diskDrive.hasData() then
    print("A floppy disk has been found!")
    sleep(2)

    term.clear()
    term.setCursorPos(1, 1)
    print("Do you want to create a backup of the floppy disk contents? (Y/N)")
    local response = read()
    if response == "Y" or response == "y" then
      term.clear()
      term.setCursorPos(1, 1)
      print("Please enter a label for the floppy disk:")
      local label = read()
      diskDrive.setDiskLabel(label)
      print("Label added to the floppy disk:", label)
      sleep(2)

      local content = diskDrive.getDiskID()
      local backupDirectory = "/backup/" .. label
      fs.makeDir(backupDirectory)
      local backupFile = fs.open(backupDirectory .. "/floppy_backup.txt", "w")
      backupFile.write(textutils.serialize(content))
      backupFile.close()
      print("Backup created successfully at '" .. backupDirectory .. "/floppy_backup.txt'.")
      sleep(2)
    else
      print("No backup will be created.")
      sleep(2)
    end

    term.clear()
    term.setCursorPos(1, 1)
    print("Do you want to format the floppy disk? (Y/N)")
    local formatResponse = read()
    if formatResponse == "Y" or formatResponse == "y" then
      term.clear()
      term.setCursorPos(1, 1)
      diskDrive.setDiskLabel("")

      -- Clear all files on the floppy disk
      for _, file in ipairs(fs.list(diskDrive.getMountPath())) do
        fs.delete(diskDrive.getMountPath() .. "/" .. file)
      end

      print("Floppy disk formatted successfully.")
      sleep(2)
    else
      print("Floppy disk not formatted.")
      sleep(2)
    end

    term.clear()
    term.setCursorPos(1, 1)
    print("Do you want to change the floppy disk label? (Y/N)")
    local changeLabelResponse = read()
    if changeLabelResponse == "Y" or changeLabelResponse == "y" then
      term.clear()
      term.setCursorPos(1, 1)
      print("Please enter a new label for the floppy disk:")
      local newLabel = read()
      diskDrive.setDiskLabel(newLabel)
      print("Label changed to:", newLabel)
      sleep(2)
    end
  else
    print("No floppy disk found.")
    sleep(2)
  end
else
  print("No disk drive found.")
  sleep(2)
end

term.clear()
term.setCursorPos(1, 1)
