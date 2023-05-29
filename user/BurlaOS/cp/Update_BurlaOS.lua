-- GitHub repository URL
local repoUrl = "https://api.github.com/repos/DrBurlao/BurlaOSlast/contents"

-- Download file using wget
local function downloadFile(url, destination)
  shell.run("wget", url, destination)
end

-- Download directory and its contents recursively
local function downloadDirectory(url, destination)
  shell.run("mkdir", destination)
  shell.run("cd", destination)
  
  local listing = http.get(url)
  local content = listing.readAll()
  listing.close()
  
  local files = textutils.unserializeJSON(content)
  
  for _, file in ipairs(files) do
    if file.type == "file" then
      downloadFile(file.download_url, file.name)
    elseif file.type == "dir" then
      downloadDirectory(file.url, file.name)
    end
  end
  
  shell.run("cd", "..")
end

-- Get repository name from URL
local function getRepositoryName(url)
  local _, _, repositoryName = string.find(url, "https://github.com/(.-)/")
  return repositoryName
end

-- Delete existing files in the repository
local function deleteExistingFiles(repositoryName)
  shell.run("rm", "-rf", repositoryName)
end

-- Display ASCII art stored in ascii_art.txt
local function displayASCIIArt()
  local asciiFile = fs.open("/user/BurlaOS/ascii_art.txt", "r")
  if asciiFile then
    term.clear()
    term.setCursorPos(1, 1)
    print(asciiFile.readAll())
    asciiFile.close()
    sleep(5)
    term.clear()
    term.setCursorPos(1, 1)
  end
end

-- Start repository download
print("Welcome to the BurlaOS Installation Program")
print("-------------------------------------------")

-- Prompt user for confirmation
print("This program will install BurlaOS on your computer.")
print("Note: All existing files will be deleted.")
print("Do you want to continue? (y/n)")
local confirm = read()

if confirm == "y" or confirm == "Y" then
  -- Delete existing files
  local repositoryName = getRepositoryName(repoUrl)
  deleteExistingFiles(repositoryName)
  
  -- Start download
  print("Downloading BurlaOS...")
  downloadDirectory(repoUrl, repositoryName)
  print("BurlaOS installation completed!")
  
  -- Display ASCII art
  displayASCIIArt()
else
  print("BurlaOS installation canceled. Exiting program.")
end
