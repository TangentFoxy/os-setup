return {
  luanti = { description = "Luanti (voxel game engine, formerly called Minetest)", ppa = "ppa:minetestdevs/stable", apt = "minetest", binary = true, },
  steam = {
    description = "Steam (video game platform)", binary = true,
    execute = [[
      curl -LO https://cdn.fastly.steamstatic.com/client/installer/steam.deb
      sudo dpkg -i steam.deb
      sudo apt-get install -fy
      rm steam.deb
    ]],
  },
  lutris = {
    description = "Lutris (video game preservation platform)",
    browse_to = "https://github.com/lutris/lutris/releases",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i lutris*.deb
      sudo apt-get install -fy
      rm lutris*.deb
    ]],
    binary = true,
  },
  openttd = {
    description = "Open Transport Tycoon Deluxe (transport strategy game)",
    browse_to = { "https://www.openttd.org/downloads/openttd-releases/latest", "generic binaries (xz/lzma archive)", },
    execute = [[
      cd ~/Downloads
      mkdir -p ~/Applications/OpenTTD
      find . -name 'openttd*' -exec tar -xf {} -C . \;
      mv ./openttd*/* ~/Applications/OpenTTD/
      rm -r ./openttd*
    ]],
    desktop = { -- never use special characters here D:
      name = "OpenTTD",
      path = "$HOME/Applications/OpenTTD",
      exec = "$HOME/Applications/OpenTTD/openttd",
      icon = "$HOME/Applications/OpenTTD/share/icons/hicolor/256x256/apps/openttd.png",
      categories = { "Game", "StrategyGame", },
    },
    priority = -1,
  },
  ["stunt-rally"] = {
    description = "StuntRally (rally racing game)",
    browse_to = { "https://sourceforge.net/projects/stuntrally/files/latest/download", ".txz (should automatically start)" },
    execute = [[
      cd ~/Downloads
      mkdir -p ~/Applications
      find . -name 'StuntRally*' -exec tar -xf {} -C ~/Applications \;
      mv ~/Applications/StuntRally* ~/Applications/StuntRally
      rm -r ./StuntRally*
    ]],
    desktop = {
      name = "StuntRally",
      path = "$HOME/Applications/StuntRally/bin/Release",
      exec = "$HOME/Applications/StuntRally/bin/Release/stuntrally3",
      icon = "$HOME/Applications/StuntRally/data/gui/stuntrally.png",
      categories = { "Game", "Simulation", },
    },
    priority = -150,
  },
  love2d = { description = "Love2D (Lua-based game engine)", ppa = "ppa:bartbes/love-stable", apt = "love", priority = 2, binary = "love", },
}
