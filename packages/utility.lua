return {
  librewolf = {
    description = "Librewolf (privacy-preserving Firefox fork)", binary = true,
    prerequisites = "extrepo",
    execute = [[
      sudo extrepo enable librewolf
      sudo apt-get update
      sudo apt-get install librewolf -y
    ]],
    priority = 110,
  },
  ["security-utilities"] = {
    description = "PIA, KeePassXC, ",
    prerequisites = { "pia", "keepass", "1password", },
    unprivileged = false, -- all dependencies require sudo
  },
  pia = {
    description = "Private Internet Access (cheap, secure VPN)",
    browse_to = { "https://www.privateinternetaccess.com/download/linux-vpn", ".run (there is only one option)", },
    execute = [[
      cd ~/Downloads
      sudo chmod +x ./pia*.run
      ./pia*.run
      rm ./pia*.run
    ]],
    priority = 1,
  },
  telegram = {
    description = "Telegram Desktop (messenger)",
    browse_to = { "https://telegram.org/dl/desktop/linux", ".tar.xz (it should have automatically started)", },
    execute = [[
      cd ~/Downloads
      # curl -O https://telegram.org/dl/desktop/linux
      find . -name 'tsetup*' -exec sudo tar -xf {} -C /opt \;
      rm ./tsetup*
      /opt/Telegram/Telegram   # it adds itself to the menu when launched
    ]],
    priority = -1,
  },
  nextcloud = {
    description = "NextCloud (desktop sync app)", apt = "nextcloud-desktop", binary = true,
    notes = "NextCloud's sync dialog upon initially connecting to a server works badly.\n Set up your connection without file sync, then add it from the app.",
  },
  keepass = { description = "KeePassXC (password manager)", apt = "keepassxc", priority = 2, binary = "keepassxc", },
  waydroid = {
    description = "Waydroid (Android-on-Wayland)",
    execute = [[
      # sudo systemctl enable --now waydroid-container   # this was supposed to work but didn't :D
      curl -s https://repo.waydro.id | sudo bash
      sudo apt-get update
      sudo apt-get install waydroid -y
    ]],
    notes = "Can't do this on my system right now, so don't use this.",
    ignore = true,
  },
  qdirstat = { description = "QDirStat (fast disk usager analyzer)", apt = "qdirstat", binary = true, },
  ollama = { description = "Ollama (CLI tool for running local models)", execute = "curl -fsSL https://ollama.com/install.sh | sh", binary = true, },
  dsnote = {
    description = "Speech Note (speech-to-text notetaking)",
    flatpak = "net.mkiol.SpeechNote",
    priority = -101, unprivileged = true,
  },
  ["dsnote-nvidia"] = {
    description = "Speech Note NVIDIA accelerator",
    prerequisites = "dsnote", hardware = "NVIDIA",
    flatpak = "net.mkiol.SpeechNote.Addon.nvidia", unprivileged = true,
  },
  ["dsnote-amd"] = {
    notes = "AMD support is not recommended right now due to its large size and limited utility,\n but in the near future may be recommended. See https://github.com/mkiol/dsnote/issues/271 for details.",
    description = "Speech Note AMD accelerator",
    prerequisites = "dsnote", hardware = "AMD",
    flatpak = "net.mkiol.SpeechNote.Addon.amd", unprivileged = true,
  },
  ["1password"] = {
    description = "1password (password manager & passkey)", binary = true,
    execute = [[
      cd ~/Downloads
      curl -O https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
      sudo dpkg -i 1password-latest.deb
      sudo apt-get install -fy
      rm 1password-latest.deb
    ]],
    priority = 2,
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
    priority = -1, ignore = true, hardware_exclude = "virtual_machine", binary = "virtualbox",
  },
  virtualbox = {
    description = "VirtualBox (OS virtualizer)", apt = "virtualbox", binary = true,
    ignore = true, priority = -1, hardware_exclude = "virtual_machine", -- NOTE will probably favor this in the future?
  },
  solaar = {
    description = "Solaar (UI for managing Logitech wireless peripherals)", apt = "solaar",
    notes = "Solaar configures itself to autostart by default.", binary = true,
  },
  ["tangent-lua-scripts"] = {
    description = "Tangent's Lua Scripts (random misc things)",
    prerequisites = { "ollama", "git", "luajit", "curl", "yt-dlp", "chromium", "ffmpeg", "pandoc", },
    optional_prerequisites = { "luarocks-luafilesystem", },
    execute = [[
      mkdir -p ~/Applications
      cd ~/Applications
      git clone https://github.com/TangentFoxy/lua-scripts --depth=1
      cd lua-scripts
      echo Adding lua-scripts to path. A warning will now appear:
      ./add_to_path.sh
    ]],
    unprivileged = false, -- all prerequisites require sudo
  },
  sleek = { description = "sleek (todo.txt-based task manager)", flatpak = "flathub com.github.ransome1.sleek", unprivileged = true, },
}
