#!/usr/bin/env luajit

-- NOTE you can't actually backspace OR only read one character at a time. User must hit enter before anything happens.
-- io.write("Password: ")
-- local password = ""
-- while true do
--   local i = io.read(1)
--   if i == "\n" then
--     break
--   else
--     io.write("\b*")
--     password = password .. i
--   end
-- end
-- print("It was '" .. password .. "'")

local commands = {
  "sudo apt-get update",
  "sudo apt-get upgrade -y",
}

-- ask questions first
-- run prerequisites first, in a sensible order
-- run specific commands
-- run cleanup

local packages = {
  git = { apt = "git", description = "Git (version control)", },
  brew = {
    description = "Brew (user-space package manager, originally for macOS)",
    prerequisites = "git",
    execute = [[
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo >> ~/.bashrc
      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      sudo apt-get install build-essential -y
      brew install gcc
    ]],
  },
  grayjay = {
    description = "Grayjay (stream videos directly from your favorite creators)",
    execute = [[
      curl -O https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-linux-x64.zip
      unzip Grayjay*.zip
      mkdir -p ~/Applications/Grayjay
      mv ./Grayjay*/* ~/Applications/Grayjay/
      ~/Applications/Grayjay
    ]],
    notes = "Need to figure out how to make sure this gets in the menu.",
  },
  docker = {
    description = "Docker (containers!)",
    apt = "docker.io", execute = "sudo usermod -aG docker $USER",
  },
  ["docker-compose-legacy"] = {
    description = "docker-compose (Python script, legacy)",
    prerequisites = {"docker"},
    apt = { "python3-setuptools", "docker-compose", },
  },
  ["docker-compose"] = {
    description = "docker compose (Docker plugin)",
    prerequisites = "docker",
    apt = "docker-compose-v2",
  },
  extrepo = { ask = false, apt = "extrepo", },
  librewolf = {
    description = "Librewolf (privacy-preserving Firefox fork)",
    prerequisites = "extrepo",
    execute = [[
      sudo extrepo enable librewolf
      sudo apt-get update
      sudo apt-get install librewolf -y
    ]],
    notes = "Need to find out why extrepo disabled librewolf on my system and whether or not this needs fixing.",
    next = "purge-firefox", -- TODO this was an attempt at ordering for an optional prerequisite
  },
  luarocks = {
    description = "Luarocks (Lua package manager)",
    execute = [[
      sudo apt-get install lua5.1 -y
      sudo apt-get install luarocks -y
      sudo luarocks install moonscript   # I should not assume..
    ]],
    notes = "Might be able to do install in one step instead of two.",
  },
  luajit = { description = "LuaJIT (Lua 5.1, faster)", apt = "luajit", ask = false, },
  qdirstat = { description = "QDirStat (fast disk usager analyzer)", apt = "qdirstat", },
  luanti = { description = "Luanti (voxel game engine, formerly called Minetest)", ppa = "ppa:minetestdevs/stable", apt = "minetest", },
  ["obs-studio"] = { description = "OBS Studio (screen streaming/recording)", ppa = "ppa:obsproject/obs-studio", apt = "obs-studio", },
  obsidian = {
    description = "Obsidian (notetaking/productivity tool)",
    browse_to = "https://obsidian.md/download",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i obsidian*.deb
      sudo apt-get install -f
      rm obsidian*.deb
    ]],
  },
  mpv = {
    description = "MPV (media player)",
    prerequisites = "brew",
    execute = [[
      ulimit -n 10000   # brew devs refuse to fix this https://github.com/Homebrew/brew/issues/9120
      brew install mpv
      # sudo curl --output-dir /etc/apt/trusted.gpg.d -O https://apt.fruit.je/fruit.gpg
      # sudo sh -c 'echo "deb http://apt.fruit.je/debian trixie mpv" > /etc/apt/sources.list.d/fruit.list'
    ]],
    notes = "Linux Mint has Celluloid, a renamed/reskinned MPV. Don't install this there, it will be automatically ignored.",
    ignore = true,
  },
  pia = {
    description = "Private Internet Access (cheap, secure VPN)",
    browse_to = "https://www.privateinternetaccess.com/download/linux-vpn",
    execute = [[
      cd ~/Downloads
      sudo chmod +x ./pia*.run
      ./pia*.run
      rm ./pia*.run
    ]],
    delay = true, -- TODO this was an attempt to make some actions go last so that GUIs don't interfere
  },
  telegram = {
    description = "Telegram Desktop (messenger)",
    execute = [[
      curl -O https://telegram.org/dl/desktop/linux
      find . -name 'tsetup*' -exec sudo tar -xf {} -C /opt \;
      /opt/Telegram/Telegram
    ]],
    delay = true,
  },
  ["purge-firefox"] = {
    prompt = "Do you want to purge Firefox?",
    execute = "sudo apt-get purge firefox -y",
  },
  steam = {
    description = "Steam (video game platform)",
    execute = [[
      curl -LO https://cdn.fastly.steamstatic.com/client/installer/steam.deb
      sudo dpkg -i steam.deb
      sudo apt-get install -f
      rm steam.deb
    ]],
  },
  waydroid = {
    description = "Waydroid (Android-on-Wayland)",
    execute = [[
      # sudo systemctl enable --now waydroid-container
      curl -s https://repo.waydro.id | sudo bash
      sudo apt-get update
      sudo apt-get install waydroid -y
    ]],
    notes = "Can't do this on my system right now, so don't use this.",
    ignore = true,
  },
  pulsar = {
    description = "Pulsar (code editor, fork of Atom)",
    browse_to = "https://pulsar-edit.dev/download.html#regular-releases",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i Linux.pulsar*.deb
      sudo apt-get install -f
      rm Linux.pulsar*.deb
      pulsar -p install language-lua language-moonscript minimap language-docker   # I shouldn't assume you want these all
    ]],
  },
  nextcloud = { description = "NextCloud (desktop sync app)", apt = "nextcloud-desktop", },
  keepass = { description = "KeePassXC (password manager)", apt = "keepassxc", },
  ["reduce-logs"] = {
    prompt = "Reduce default stored logs to 1 day and 10 MB maximums?",
    execute = [[
      sudo journalctl --vacuum-time=1d
      sudo journalctl --vacuum-size=10M
    ]],
  },
  ollama = { description = "Ollama (CLI tool for running local models)", execute = "curl -fsSL https://ollama.com/install.sh | sh", ask = false, },
  ["git-credentials-insecure"] = {
    prompt = "Configure Git to store credentials in plaintext\n  (this is a bad and insecure idea!)?",
    prerequisites = "git",
    execute = "git config --global credential.helper store",
    ignore = true,
  },
  ["git-credentials-libsecret"] = {
    prompt = "Configure Git to store credentials securely (using libsecret)?",
    prerequisites = {"git", "import-private-config"}, -- NOTE the second prerequisite here should be optional
    execute = [[
      sudo apt install libsecret-1-0 libsecret-1-dev libglib2.0-dev
      sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
      git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
    ]],
  },
  ["import-private-config"] = {
    prompt = "Would you like to run a private config import script?",
    execute = [[
      echo "Press enter after a private config import script was saved to"
      read -p "  ~/Downloads/import-private-config.lua (or after you have run it)." dummy
      cd ~/Downloads
      chmod +x ./import-private-config.lua
      ./import-private-config.lua
      # git config --global init.defaultBranch main   # I shouldn't need this soon hopefully..
    ]],
    next = "git-credentials-libsecret",
  },
  ["unattended-upgrades"] = {
    prompt = "Would you like automatic background security updates?",
    apt = "unattended-upgrades",
  },
  dsnote = {
    description = "Speech Note (speech-to-text notetaking)",
    flatpak = {"net.mkiol.SpeechNote", "net.mkiol.SpeechNote.Addon.nvidia", },
    notes = "Assumes you have an NVIDIA GPU.",
  },
  ["docker-nvidia"] = {
    description = "Docker NVIDIA support",
    prerequisites = "docker",
    execute = [[
      curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
          sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
          sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
      sudo apt-get install nvidia-container-toolkit -y
      sudo nvidia-ctk runtime configure --runtime=docker
      sudo systemctl restart docker
    ]],
  },
  ["1password"] = {
    description = "1password (password manager & passkey)",
    execute = [[
      cd ~/Downloads
      curl -O https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
      sudo dpkg -i 1password-latest.deb
      sudo apt-get install -f
      rm 1password-latest.deb
    ]],
  },
}

local function prompt(text)
  io.write(text)
  return io.read("*line")
end

local function ask(text)
  local choice = prompt(text)
  if choice:sub(1):lower() == "y" then
    return true
  end
end

-- 1. go through all packages asking for options
--     ignore things with ignore = true, don't ask about things with ask = false
--     most things have description -> "Install {description} (y/n)? "
--       others have prompt, which should be used "{prompt} (y/n)? " TODO change prompts to remove question marks!
-- 2. go through packages selected and run them, making sure to order things that need to be specially ordered
-- 3. run cleanup commands

-- TODO there needs to be a way to avoid asking about things when a previous quesiton already answered it
--   ie if docker was asked but not selected, the prompts that have it as a prerequisite should not be asked!
--   I'll reuse ignore for this?

-- fix formatting variations
for _, package in pairs(packages) do
  if package.description then
    package.prompt = "Install " .. package.description
  end
  if type(package.apt) == "string" then
    package.apt = { package.apt }
  end
  if type(package.prerequisites) == "string" then
    package.prerequisites = { package.prerequisites }
  end
end

-- choose what to run
for name, package in pairs(packages) do
  repeat -- dirty hack allowing break to function as continue
    if package.selected or package.ignore or package.ask == false then
      break -- continue
    end

    if package.prompt then
      -- if a prerequisite has been marked ignore, continue!
      if package.prerequisites then
        local ignored_prerequisite = false
        for _, name in ipairs(package.prerequisites) do
          if packages[name].ignore then
            ignored_prerequisite = true
            break
          end
        end
        if ignored_prerequisite then break end -- continue
      end

      if ask(package.prompt .. " (y/n)? ") then
        package.selected = true
        if package.prerequisites then
          for _, name in ipairs(package.prerequisites) do
            packages[name].selected = true
          end
        end
      end
    else
      error("Package '" .. name .. "' lacks a prompt or description.")
    end
  until true -- end of dirty hack
end

-- rip and tear (run and delete) until it is done

-- -- as packages are processed, they are deleted -> loop until nothing is left
-- while next(packages) do
--   for name, package in pairs(packages) do
--   end
-- end

-- TODO this is where an initial update/upgrade/autoremove/autoclean should be performed!

local done = false
repeat
  local skipped = false -- was anything skipped? (if so, we are not done!)
  for name, package in pairs(packages) do
    repeat -- continue hack

      if package.prerequisites then
        local prerequisites_met = true
        for _, name in ipairs(package.prerequisites) do
          if not packages[name].ignore then
            prerequisites_met = false
            break
          end
        end
        if not prerequisites_met then
          skipped = true
          break -- continue (skipped, waiting until a pass has fufilled the prerequisites)
        end
      end

      if package.ignore or (not package.selected) then
        break -- continue (not a skip, because we are done with it)
      end

      print("Running '" .. name .. "'...")

      if package.browse_to then
        print("Opening your browser to a download page.\n  Make sure you choose the Debian (.deb) file and that it is saved to:\n    ~/Downloads")
        -- os.execute("open " .. package.browse_to)
        print("browse_to:", package.browse_to)
        prompt("Press enter when the download is finished.")
      end

      if package.ppa then
        -- os.execute("sudo add-apt-repository -y " .. package.ppa .. " && sudo apt-get update")
        print("ppa:", package.ppa)
      end
      if package.apt then
        -- os.execute("sudo apt-get install -y " .. table.concat(package.apt, " "))
        print("apt:", table.concat(package.apt, " "))
      end
      if package.flatpak then
        -- os.execute("flatpak install -y " .. table.concat(package.flatpak, " "))
        print("flatpak:", table.concat(package.flatpak, " "))
      end
      if package.execute then
        -- os.execute(package.execute)
        print("execute: ", package.execute:sub(1, 32), #package.execute)
      end

      package.ignore = true -- this package must be done
    until true -- continue hack
  end

  if not skipped then done = true end -- we are done if everything was processed
until done
