return {
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
    flatpak = "flathub app.grayjay.Grayjay", priority = -1,
  },
  ["obs-studio"] = { description = "OBS Studio (screen streaming/recording)", ppa = "ppa:obsproject/obs-studio", apt = "obs-studio", },
  obsidian = {
    description = "Obsidian (notetaking/productivity tool)",
    browse_to = "https://obsidian.md/download",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i obsidian*.deb
      sudo apt-get install -fy
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
    notes = "Installing MPV seems to create errors despite successfully installing.",
  },
}
