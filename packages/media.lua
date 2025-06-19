return {
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
  ["ffmpeg"] = { description = "FFMPEG (CLI video encoder)", apt = "ffmpeg", },
  pandoc = {
    description = "Pandoc (document conversion tool)",
    browse_to = "https://github.com/jgm/pandoc/releases/latest",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i pandoc*.deb
      sudo apt-get install -fy
      rm pandoc*.deb
    ]],
  },
  ["yt-dlp"] = {
    description = "YT-DLP (a CLI media download tool)",
    prerequisites = "brew",
    execute = "brew install yt-dlp",
  },
  audacity = { description = "Audacity (audio editor)", prerequisites = "ffmpeg", ppa = "ppa:ubuntuhandbook1/audacity", apt = "audacity", },
}
