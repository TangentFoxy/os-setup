return {
  git = { apt = "git", description = "Git (version control)", ask = false, priority = 200, }, -- has to be installed for this script to even be running...
  ["git-credentials-libsecret"] = {
    prompt = "Configure Git to store credentials securely (using libsecret)",
    prerequisites = "git",
    optional_prerequisites = "import-private-config",
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
  ["fire-tools"] = {
    description = "Fire Tools (small GUI program to improve Amazon Fire tablets)",
    apt = { "python3-pip", "python3.12-venv", "python3-tk", },
    execute = [[
      curl -LO https://github.com/mrhaydendp/fire-tools/releases/latest/download/Fire-Tools.zip
      unzip Fire-Tools.zip && rm Fire-Tools.zip
      cd Fire-Tools
      python3 -m venv .venv
      source .venv/bin/activate
      python3 -m pip install -r requirements.txt
      echo source .venv/bin/activate > run.sh
      echo python3 main.py >> run.sh
      chmod +x run.sh
      mv run.sh "Run Fire Tools.sh"
    ]],
    prerequisites = "android-platform-tools",
    notes = "While out-of-date, the website has useful information:\n https://blog.mrhaydendp.com/projects/fire-tools/",
  },
}
