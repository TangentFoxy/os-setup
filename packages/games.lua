return {
  luanti = { description = "Luanti (voxel game engine, formerly called Minetest)", ppa = "ppa:minetestdevs/stable", apt = "minetest", },
  steam = {
    description = "Steam (video game platform)",
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
  ["stunt-rally"] = {
    description = "StuntRally (rally racing game)",
    browse_to = "https://sourceforge.net/projects/stuntrally/files/latest/download",
    execute = [[
      cd ~/Downloads
      mkdir -p ~/Applications/StuntRally
      find . -name 'StuntRally*' -exec sudo tar -xf {} -C ./StuntRally \;
      mv ./StuntRally*/StuntRally*/* ~/Applications/StuntRally/
      rm -r ./StuntRally*
    ]],
  },
}
