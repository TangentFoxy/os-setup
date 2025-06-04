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

local function prompt(text)
  io.write(text)
  return io.read("*line")
end

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
  docker = { apt = "docker.io", execute = "sudo usermod -aG docker $USER", },
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
    next = "purge-firefox",
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
      cd Downloads
      sudo dpkg -i obsidian*.deb
      rm obsidian*.deb
    ]],
    notes = "I don't remember how to fix a deb install without dependencies. It's either dpkig -if or apt-get install -f",
  },
  mpv = {
    description = "MPV (media player)",
    prerequisites = "brew",
    execute = [[
      ulimit -n 10000
      brew install mpv
    ]],
    notes = "Linux Mint has Celluloid, a renamed/reskinned MPV. Don't install this there, it will be automatically ignored.",
    ignore = true,
  },
  pia = {
    description = "Private Internet Access (cheap, secure VPN)",
    browse_to = "https://www.privateinternetaccess.com/download/linux-vpn",
    execute = [[
      cd Downloads
      sudo chmod +x ./pia*.run
      ./pia*.run
      rm ./pia*.run
    ]],
    delay = true,
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
    ]],
    notes = "Fix dpkg? Doesn't launch it because it running can screw up other parts of this script. :D",
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
      cd Downloads
      sudo dpkg -i Linux.pulsar*.deb
      pulsar -p install language-lua language-moonscript minimap language-docker   # I shouldn't assume you want these all
    ]],
    notes = "Fix dpkg.",
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
    prompt = "Configure Git to store credentials in plaintext (this is a bad and insecure idea!)?",
    prerequisites = "git",
    execute = "git config --global credential.helper store",
    ignore = true,
  },
  ["git-credentials-libsecret"] = {
    prompt = "Configure Git to store credentials securely (using libsecret)?",
    prerequisites = {"git", "import-private-config"},
    execute = [[
      sudo apt install libsecret-1-0 libsecret-1-dev libglib2.0-dev
      sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
      git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
    ]],
    notes = "The prerequisite of import-private-config is a soft prerequisite.. but I haven't made a way to distinguish that yet.",
  },
  ["import-private-config"] = {
    prompt = "Would you like to run a private config import script?",
    execute = [[
      read -p "Press enter after a private config import script was saved to Downloads/import-private-config.lua (or after you have run it)." dummy
      cd Downloads
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
  },
}
