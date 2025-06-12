return {
  git = { apt = "git", description = "Git (version control)", ask = false, priority = 200, }, -- has to be installed for this script to even be running...
  ["git-credentials-libsecret"] = {
    prompt = "Configure Git to store credentials securely (using libsecret)",
    prerequisites = {"git", "import-private-config"}, -- NOTE the second prerequisite here should be optional
    execute = [[
      sudo apt install libsecret-1-0 libsecret-1-dev libglib2.0-dev
      sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
      git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
    ]],
    priority = 9,
  },
  pulsar = {
    description = "Pulsar (code editor, fork of Atom)",
    browse_to = "https://pulsar-edit.dev/download.html#regular-releases",
    execute = [[
      cd ~/Downloads
      sudo dpkg -i Linux.pulsar*.deb
      sudo apt-get install -fy
      rm Linux.pulsar*.deb
      pulsar -p install language-lua language-moonscript minimap language-docker   # I shouldn't assume you want these all
    ]],
    notes = "Lua, Moonscript, and Dockerfile language support will be installed with Pulsar.\nAlso a minimap plugin! :o",
    priority = -10,
  },
  ["android-platform-tools"] = {
    description = "ADB Tools (for interfacing with Android devices)",
    execute = "brew install --cask android-platform-tools",
    prerequisites = "brew",
  },
  ["ffmpeg"] = { description = "FFMPEG (CLI video encoder)", apt = "ffmpeg", },
}
