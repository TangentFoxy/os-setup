#!/usr/bin/env luajit

local argparse = require "lib.argparse"

local parser = argparse()
-- parser:argument("package", "Select specific package(s)."):args("*")
parser:option("--default-choice", "Default answer to prompts.", "N"):choices{"Y", "N"}:args(1):overwrite(false)
parser:flag("--dry-run", "Output the commands that would be run instead of running them."):overwrite(false)
parser:option("--interactive", "Wait for user input.", "true"):choices{"true", "false"}:overwrite(false)

local options = parser:parse()

if options.interactive == "false" then
  options.interactive = false
  -- don't need to bother converting "true" to true because its truthy
end

local packages = {
  ["system-upgrade"] = {
    -- this is just run automatically at the beginning and end of this script
    prompt = "Upgrade all packages",
    execute = [[
      which -s extrepo && sudo extrepo update
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get autoremove -y
      sudo apt-get autoclean
      sudo apt-get clean
      flatpak update
    ]],
    ignore = true, -- NOTE maybe should be "autorun" or "internal" or something when enum is added
  },
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
  ["grayjay-legacy"] = {
    description = "Grayjay (stream videos directly from your favorite creators)",
    execute = [[
      curl -O https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-linux-x64.zip
      unzip Grayjay*.zip
      mkdir -p ~/Applications/Grayjay
      mv ./Grayjay*/* ~/Applications/Grayjay/
      rm -r ./Grayjay*
    ]],
    notes = "https://github.com/futo-org/Grayjay.Desktop/issues/439#issuecomment-2869188750 explains how to add this to the menu, but I'm going to try using the flatpak version instead.",
    ignore = true,
  },
  grayjay = {
    description = "Grayjay (stream videos directly from your favorite creators)",
    flatpak = "flathub app.grayjay.Grayjay",
  },
  docker = {
    description = "Docker (containers!)",
    apt = "docker.io", execute = "sudo usermod -aG docker $USER",
  },
  ["docker-compose-legacy"] = {
    description = "docker-compose (Python script, legacy)",
    prerequisites = "docker",
    apt = { "python3-setuptools", "docker-compose", },
  },
  ["docker-compose"] = {
    description = "docker compose (Docker plugin)",
    prerequisites = "docker",
    apt = "docker-compose-v2",
  },
  extrepo = {
    description = "extrepo (makes it easy to manage external repositories)",
    ask = false, apt = "extrepo",
  },
  librewolf = {
    description = "Librewolf (privacy-preserving Firefox fork)",
    prerequisites = "extrepo",
    execute = [[
      sudo extrepo enable librewolf
      sudo apt-get update
      sudo apt-get install librewolf -y
    ]],
    notes = "Need to find out why extrepo disabled librewolf on my system and whether or not this needs fixing.",
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
  ["mpv-from-brew"] = {
    description = "MPV (media player)",
    prerequisites = "brew",
    execute = [[
      ulimit -n 10000   # brew devs refuse to fix this https://github.com/Homebrew/brew/issues/9120
      brew install mpv
    ]],
    notes = "Linux Mint has Celluloid, a renamed/reskinned MPV. Don't install this there, it will be automatically ignored.",
    ignore = true,
  },
  mpv = {
    description = "MPV (media player)",
    execute = [[
      sudo curl --output-dir /etc/apt/trusted.gpg.d -O https://apt.fruit.je/fruit.gpg
      sudo sh -c 'echo "deb http://apt.fruit.je/debian trixie mpv" > /etc/apt/sources.list.d/fruit.list'
      sudo apt-get update
      sudo apt-get install -y mpv
    ]],
    -- TODO needs to be ignored on Mint?
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
  },
  telegram = {
    description = "Telegram Desktop (messenger)",
    execute = [[
      curl -O https://telegram.org/dl/desktop/linux
      find . -name 'tsetup*' -exec sudo tar -xf {} -C /opt \;
      rm ./tsetup*
      /opt/Telegram/Telegram   # it adds itself to the menu when launched
    ]],
  },
  ["purge-firefox"] = {
    prompt = "Do you want to purge Firefox",
    execute = "sudo apt-get purge firefox -y",
    prerequisites = "librewolf", -- TEMP it just needs to know SOME browser is installed (see #13)
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
  nextcloud = {
    description = "NextCloud (desktop sync app)", apt = "nextcloud-desktop",
    notes = "NextCloud's sync dialog upon initially connecting to a server works badly.\n Set up your connection without file sync, then add it from the app.",
  },
  keepass = { description = "KeePassXC (password manager)", apt = "keepassxc", },
  ["reduce-logs"] = {
    prompt = "Reduce stored logs to 1 day / 10 MB",
    execute = [[
      sudo journalctl --vacuum-time=1d
      sudo journalctl --vacuum-size=10M
    ]],
  },
  ollama = { description = "Ollama (CLI tool for running local models)", execute = "curl -fsSL https://ollama.com/install.sh | sh", ask = false, },
  ["git-credentials-insecure"] = {
    prompt = "Configure Git to store credentials in plaintext\n  (this is a bad and insecure idea!)",
    prerequisites = "git",
    execute = "git config --global credential.helper store",
    ignore = true,
  },
  ["git-credentials-libsecret"] = {
    prompt = "Configure Git to store credentials securely (using libsecret)",
    prerequisites = {"git", "import-private-config"}, -- NOTE the second prerequisite here should be optional
    execute = [[
      sudo apt install libsecret-1-0 libsecret-1-dev libglib2.0-dev
      sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
      git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
    ]],
  },
  ["import-private-config"] = {
    prompt = "Would you like to run a private config import script",
    execute = [[
      echo "Press enter after a private config import script was saved to"
      read -p "  ~/Downloads/import-private-config.lua (or after you have run it)." dummy
      cd ~/Downloads
      chmod +x ./import-private-config.lua
      ./import-private-config.lua
      rm ./import-private-config.lua
      # git config --global init.defaultBranch main   # I shouldn't need this soon hopefully..
    ]],
  },
  ["unattended-upgrades"] = {
    prompt = "Would you like automatic background security updates",
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
  ["virtualbox-7.1"] = {
    description = "VirtualBox 7.1 (OS virtualizer)",
    execute = [[
      # sudo apt install curl wget apt-transport-https gnupg2 -y   # what a dumb idea, these will be installed if needed, duh
      curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor -o /usr/share/keyrings/oracle-virtualbox-2016.gpg
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian noble contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
      sudo apt-get update
      sudo apt-get install -y virtualbox-7.1   # should find a way to make this find and get the latest version instead
      sudo adduser $USER vboxusers             # requires re-login
      newgrp vboxusers                         # was supposed to prevent relogging requirement, appears to not function

      cd ~/Downloads
      wget https://download.virtualbox.org/virtualbox/7.1.4/Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack
      sudo vboxmanage extpack install Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack --accept-license=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae
      rm ./Oracle_VirtualBox_Extension_Pack*.vbox-extpack
    ]],
    ignore = true,
  },
  virtualbox = {
    description = "VirtualBox (OS virtualizer)", apt = "virtualbox", ignore = true, -- NOTE will probably favor this in the future?
  },
  lutris = {
    description = "Lutris (video game preservation platform)",
    browse_to = "https://github.com/lutris/lutris/releases",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i lutris*.deb
      sudo apt-get install -f
      rm lutris*.deb
    ]],
  },
  openttd = {
    description = "Open Transport Tycoon Deluxe (transport strategy game)",
    browse_to = "https://www.openttd.org/downloads/openttd-releases/latest",
    execute = [[
      cd ~/Downloads
      mkdir -p ~/Applications/OpenTTD
      find . -name 'openttd*' -exec sudo tar -xf {} -C ~/Applications/OpenTTD \;
      # mv ./openttd*/* ~/Applications/OpenTTD/
      rm -r ./openttd*
    ]],
    desktop = { -- never use special characters here D:
      name = "OpenTTD",
      path = "~/Applications/OpenTTD",
      exec = "~/Applications/OpenTTD/openttd",
      icon = "~/Applications/OpenTTD/share/icons/hicolor/256x256/apps/openttd.png",
      categories = {"Game", "StrategyGame"},
    },
  },
  ["ubuntu-drivers"] = {
    description = "ubuntu-drivers autoinstall (will find and install missing drivers)",
    apt = "ubuntu-drivers-common",
    execute = "ubuntu-drivers autoinstall", -- NOTE I think this needs sudo, but it hasn't errored when not using sudo so I'm confused
    notes = "Obviously, this should only be run on Ubuntu-derived systems.",
  },
}

local function prompt(text, hide_default_entry)
  io.write(text)
  if options.interactive then
    return io.read("*line")
  else
    if not hide_default_entry then io.write(options.default_choice) end
    io.write("\n")
    return ""
  end
end

local function ask(text)
  local choice = prompt(text)
  if #choice < 1 then choice = options.default_choice end
  if choice:sub(1):lower() == "y" then
    return true
  end
end

local function system_upgrade()
  if options.dry_run then
    print(packages["system-upgrade"].execute)
  else
    os.execute(packages["system-upgrade"].execute)
  end
end

-- TODO there needs to be a way to avoid asking about things when a previous quesiton already answered it
--   ie if docker was asked but not selected, the prompts that have it as a prerequisite should not be asked!
--   I'll reuse ignore for this?

local function enumerate(list)
  local result = {}
  for _, value in ipairs(list) do
    result[value] = {}
  end
  return result
end

local states = enumerate({ "IGNORED", "TO_ASK", "TO_INSTALL", "INSTALLED", })

-- sanitize formatting variations (and check for errors)
for name, package in pairs(packages) do
  if package.ask or package.ask == nil then
    package.status = states.TO_ASK
  end
  if package.ignore then
    package.status = states.IGNORED
  end
  if package.description then
    package.prompt = "Install " .. package.description
  end
  if type(package.prerequisites) == "string" then
    package.prerequisites = { package.prerequisites }
  end
  if type(package.apt) == "string" then
    package.apt = { package.apt }
  end
  if type(package.flatpak) == "string" then
    package.flatpak = { package.flatpak }
  end
  if not package.prerequisites then
    package.prerequisites = {}
  end
  if package.execute and package.execute:sub(1, 1) ~= " " then -- pretty formatting for dry_run
    package.execute = "      " .. package.execute .. "\n"
  end

  if not package.prompt then
    error("Package '" .. name .. "' lacks a prompt or description.\nPlease report this issue at https://github.com/TangentFoxy/os-setup/issues\n")
  end
  -- TODO check for other types of error
end

-- choose what to run
for _, package in pairs(packages) do
  local function _ask(package)
    if not (package.status == states.TO_ASK) then
      return
    end

    for _, name in ipairs(package.prerequisites) do
      if packages[name].status == states.IGNORED then
        return
      end
    end

    if ask(package.prompt .. " (y/n, default: " .. options.default_choice .. ")? ") then
      package.status = states.TO_INSTALL
      for _, name in ipairs(package.prerequisites) do
        packages[name].status = states.TO_INSTALL
      end
    end
  end

  _ask(package)
end

io.write("\n") -- formatting

system_upgrade()

local function execute(...)
  if options.dry_run then
    return print(...)
  else
    return os.execute(...)
  end
end

local function create_menu_entry(desktop)
  local desktop_file_name = desktop.path .. "/" .. desktop.name .. ".desktop"
  local lines = {
    "[Desktop Entry]",
    "Name=" .. desktop.name,
    "Path=" .. desktop.path,
    "Exec=" .. desktop.exec,
    "Icon=" .. desktop.icon,
    "Terminal=false",
    "Type=Application",
    "Categories=" .. table.concat(desktop.categories, "\\;"),
  }
  for _, line in ipairs(lines) do
    execute("  echo " .. line .. " >> " .. desktop_file_name)
  end
  execute("  chmod +x " .. desktop_file_name)
  execute("  desktop-file-validate " .. desktop_file_name)
  execute("  desktop-file-install --dir=$HOME/.local/share/applications " .. desktop_file_name)
  execute("  update-desktop-database ~/.local/share/applications") -- appears to be unnecessary on Mint
  if options.dry_run then
    io.write("\n")
  end
end

local done = false
repeat

  for name, package in pairs(packages) do
    local function _install(name, package)
      if package.status ~= states.TO_INSTALL then
        return
      end

      for _, name in ipairs(package.prerequisites) do
        if packages[name].status ~= states.INSTALLED then
          return
        end
      end

      if options.dry_run then
        print("Simulating '" .. name .. "'...")
      end

      if package.browse_to then
        print("Opening your browser to a download page.")
        print("Make sure you choose the Debian (.deb) file and that it is saved to ~/Downloads")
        execute("  open " .. package.browse_to)
        prompt("Press enter when the download is finished.", true)
      end

      if package.ppa then
        execute("  sudo add-apt-repository -y " .. package.ppa .. " && sudo apt-get update")
      end
      if package.apt then
        execute("  sudo apt-get install -y " .. table.concat(package.apt, " "))
      end
      if package.flatpak then
        for _, name in ipairs(package.flatpak) do
          execute("  flatpak install -y " .. name)
        end
      end

      if package.execute then
        execute(package.execute)
      elseif options.dry_run then
        io.write("\n")
      end

      if package.desktop then
        create_menu_entry(package.desktop)
      end

      package.status = states.INSTALLED
    end

    _install(name, package)
  end

  done = true
  for _, package in pairs(packages) do
    if package.status == states.TO_INSTALL then
      done = false
      break
    end
  end

until done

system_upgrade()
