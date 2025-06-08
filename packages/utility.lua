return {
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
    notes = "Lua, Moonscript, and Dockerfile language support will be installed with Pulsar.\nAlso a minimap plugin! :o",
  },
  nextcloud = {
    description = "NextCloud (desktop sync app)", apt = "nextcloud-desktop",
    notes = "NextCloud's sync dialog upon initially connecting to a server works badly.\n Set up your connection without file sync, then add it from the app.",
  },
  keepass = { description = "KeePassXC (password manager)", apt = "keepassxc", },
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
  qdirstat = { description = "QDirStat (fast disk usager analyzer)", apt = "qdirstat", },
  ollama = { description = "Ollama (CLI tool for running local models)", execute = "curl -fsSL https://ollama.com/install.sh | sh", ask = false, },
  dsnote = {
    description = "Speech Note (speech-to-text notetaking)",
    flatpak = {"net.mkiol.SpeechNote", "net.mkiol.SpeechNote.Addon.nvidia", },
    notes = "Assumes you have an NVIDIA GPU.",
    -- NOTE net.mkiol.SpeechNote.Addon.amd exists for AMD card support, but is not recommended (why?) https://github.com/mkiol/dsnote/issues/271
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
}
