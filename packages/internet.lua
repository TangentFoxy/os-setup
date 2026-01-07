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
  betterbird = { description = "Betterbird (Thunderbird-based email client, that won't lose your data)", flatpak = "flathub eu.betterbird.Betterbird", unprivileged = true, },
  vivaldi = {
    description = "Vivaldi (chromium-based browser)", binary = true,
    execute = [[
      cd ~/Downloads
      sudo dpkg -i vivaldi*.deb
      sudo apt-get install -fy
      rm vivaldi*.deb
    ]],
  },
}
