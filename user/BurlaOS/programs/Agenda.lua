local notes = {}
local agenda = {}

local function createDirectories()
  if not fs.exists("/user") then
    fs.makeDir("/user")
  end

  if not fs.exists("/user/notes") then
    fs.makeDir("/user/notes")
  end
end

local function saveNotes()
  local file = fs.open("/user/notes/notes.txt", "w")
  for _, note in ipairs(notes) do
    file.writeLine(note)
  end
  file.close()
end

local function loadNotes()
  notes = {}
  if fs.exists("/user/notes/notes.txt") then
    local file = fs.open("/user/notes/notes.txt", "r")
    local line = file.readLine()
    while line do
      table.insert(notes, line)
      line = file.readLine()
    end
    file.close()
  end
end

local function saveAgenda()
  local file = fs.open("/user/notes/agenda.txt", "w")
  for _, event in ipairs(agenda) do
    file.writeLine(event.date .. "|" .. event.description)
  end
  file.close()
end

local function loadAgenda()
  agenda = {}
  if fs.exists("/user/notes/agenda.txt") then
    local file = fs.open("/user/notes/agenda.txt", "r")
    local line = file.readLine()
    while line do
      local date, description = line:match("^(.-)|(.+)$")
      table.insert(agenda, {date = date, description = description})
      line = file.readLine()
    end
    file.close()
  end
end

local function showNotes()
  term.clear()
  term.setCursorPos(1, 1)
  print("Notes:")
  for i, note in ipairs(notes) do
    print(i .. ": " .. note)
  end
end

local function addNote()
  term.clear()
  term.setCursorPos(1, 1)
  print("Add Note")
  write("Enter the note: ")
  local note = read()
  table.insert(notes, note)
  saveNotes()
  print("Note added.")
  sleep(1)  -- Pause for 1 second
end

local function deleteNote()
  term.clear()
  term.setCursorPos(1, 1)
  print("Delete Note")
  write("Enter the index of the note to delete: ")
  local index = tonumber(read())
  if index >= 1 and index <= #notes then
    table.remove(notes, index)
    saveNotes()
    print("Note deleted.")
  else
    print("Invalid index.")
  end
  sleep(1)  -- Pause for 1 second
end

local function showAgenda()
  term.clear()
  term.setCursorPos(1, 1)
  print("Agenda:")
  for i, event in ipairs(agenda) do
    print(i .. ": " .. event.date .. " - " .. event.description)
  end
end

local function addEvent()
  term.clear()
  term.setCursorPos(1, 1)
  print("Add Event")
  write("Enter the date of the event (DD/MM/YYYY): ")
  local date = read()
  write("Enter the description of the event: ")
  local description = read()
  table.insert(agenda, {date = date, description = description})
  saveAgenda()
  print("Event added.")
  sleep(1)  -- Pause for 1 second
end

local function deleteEvent()
  term.clear()
  term.setCursorPos(1, 1)
  print("Delete Event")
  write("Enter the index of the event to delete: ")
  local index = tonumber(read())
  if index >= 1 and index <= #agenda then
    table.remove(agenda, index)
    saveAgenda()
    print("Event deleted.")
  else
    print("Invalid index.")
  end
  sleep(1)  -- Pause for 1 second
end

local function main()
  -- Create necessary directories if they don't exist
  createDirectories()

  -- Load data on program start
  loadNotes()
  loadAgenda()

  -- Main menu
  while true do
    term.clear()
    term.setCursorPos(1, 1)
    print("===== NOTES AND AGENDA PROGRAM =====")
    print("1. View notes")
    print("2. Add note")
    print("3. Delete note")
    print("4. View agenda")
    print("5. Add event to agenda")
    print("6. Delete event from agenda")
    print("0. Exit")
    print("===================================")
    write("Enter an option: ")
    local option = tonumber(read())

    if option == 1 then
      showNotes()
    elseif option == 2 then
      addNote()
    elseif option == 3 then
      deleteNote()
    elseif option == 4 then
      showAgenda()
    elseif option == 5 then
      addEvent()
    elseif option == 6 then
      deleteEvent()
    elseif option == 0 then
      break
    else
      print("Invalid option.")
      sleep(1)  -- Pause for 1 second
    end

    write("Press any key to continue...")
    os.pullEvent("key")  -- Wait for a key press event
  end
end

-- Start the program
main()
