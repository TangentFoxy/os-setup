return {
  betterbird = { description = "Betterbird (Thunderbird-based email client, that won't lose your data)", flatpak = "flathub eu.betterbird.Betterbird", },
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
