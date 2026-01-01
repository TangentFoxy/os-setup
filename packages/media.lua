return {
  grayjay = {
    description = "Grayjay (stream videos directly from your favorite creators)",
    flatpak = "flathub app.grayjay.Grayjay", priority = -1, unprivileged = true,
  },
  ["obs-studio"] = { description = "OBS Studio (screen streaming/recording)", ppa = "ppa:obsproject/obs-studio", apt = "obs-studio", },
  obsidian = {
    description = "Obsidian (notetaking/productivity tool)", binary = true,
    browse_to = "https://obsidian.md/download",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i obsidian*.deb
      sudo apt-get install -fy
      rm obsidian*.deb
    ]],
  },
  mpv = {
    -- binary = true, -- TODO find out
    description = "MPV (media player)",
    execute = [[
      sudo curl --output-dir /etc/apt/trusted.gpg.d -O https://apt.fruit.je/fruit.gpg
      sudo sh -c 'echo "deb http://apt.fruit.je/debian trixie mpv" > /etc/apt/sources.list.d/fruit.list'
      sudo apt-get update
      sudo apt-get install -y mpv
    ]],
    notes = "Installing MPV seems to create errors despite successfully installing.",
  },
  ["ffmpeg"] = { description = "FFMPEG (CLI video encoder)", apt = "ffmpeg", binary = true, },
  pandoc = {
    description = "Pandoc (document conversion tool)", binary = true,
    browse_to = "https://github.com/jgm/pandoc/releases/latest",
    prerequisites = "xelatex",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i pandoc*.deb
      sudo apt-get install -fy
      rm pandoc*.deb
    ]],
  },
  xelatex = { description = "xelatex (PDF engine used for Pandoc)", apt = "texlive-xetex", binary = true, ask = false, },
  ["yt-dlp"] = {
    description = "YT-DLP (a CLI media download tool)",
    prerequisites = "brew",
    brew = "yt-dlp", binary = true,
  },
  audacity = { description = "Audacity (audio editor)", prerequisites = "ffmpeg", ppa = "ppa:ubuntuhandbook1/audacity", apt = "audacity", binary = true, },
  ["musicbrainz-picard"] = { description = "MusicBrainz Picard (extensive audio tagging software)", apt = "picard", binary = "picard", },
  imagemagick7 = {
    description = "ImageMagick 7 (CLI image editing tools)", -- prerequisites = "curl", -- everything is assuming curl is installed...
    execute = [[
      cd ~/Downloads
      curl -LO https://imagemagick.org/archive/binaries/magick
      chmod +x ./magick
      sudo mv ./magick /usr/local/bin/
    ]],
    binary = "magick",
  },
  calibre = {
    description = "Calibre (ebook manager)", binary = true,
    execute = "sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin",
  },
  gimp = { description = "GIMP (image editor)", flatpak = "flathub org.gimp.GIMP", unprivileged = true, },
}
