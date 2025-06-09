return {
  ["system-upgrade"] = {
    -- this is run automatically at the beginning and end of the installer
    prompt = "Upgrade all packages",
    execute = [[
      which -s extrepo && sudo extrepo update
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get autoremove -y
      sudo apt-get autoclean
      sudo apt-get clean
      flatpak update
      which -s brew && brew autoremove
      which -s brew && brew cleanup --prune=all
      which -s docker && docker system prune --all -f
    ]],
    ignore = true,
  },
  git = { apt = "git", description = "Git (version control)", ignore = true, }, -- has to be installed for this script to even be running...
  brew = {
    description = "Brew (user-space package manager, originally for macOS)",
    prerequisites = "git",
    execute = [[
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      echo >> ~/.bashrc
      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      sudo apt-get install build-essential -y
      brew install gcc
    ]],
  },
  docker = {
    description = "Docker (containers!)",
    apt = "docker.io", execute = "sudo usermod -aG docker $USER",
  },
  ["docker-compose-legacy"] = {
    description = "docker-compose (Python script, legacy)",
    prerequisites = "docker",
    apt = { "python3-setuptools", "docker-compose", },
  },
  ["docker-compose"] = {
    description = "docker compose (Docker plugin)",
    prerequisites = "docker",
    apt = "docker-compose-v2",
  },
  extrepo = {
    description = "extrepo (makes it easy to manage external repositories)",
    ask = false, apt = "extrepo",
  },
  luarocks = {
    description = "Luarocks (Lua package manager)",
    execute = [[
      sudo apt-get install lua5.1 -y
      sudo apt-get install luarocks -y
      sudo luarocks install moonscript
    ]],
    notes = "Installing Luarocks will also install Moonscript.",
  },
  luajit = { description = "LuaJIT (Lua 5.1, faster)", apt = "luajit", ask = false, },
  ["purge-firefox"] = {
    prompt = "Do you want to purge Firefox",
    execute = "sudo apt-get purge firefox -y",
    condition = function()
      return require("lib.browser_count")() > 1 -- need at least 2 browsers installed before removing 1
    end,
  },
  ["reduce-logs"] = {
    prompt = "Reduce stored logs to 1 day / 10 MB",
    execute = [[
      sudo journalctl --vacuum-time=1d
      sudo journalctl --vacuum-size=10M
    ]],
    ignore = true, -- deprecated
  },
  ["cleanup-logs"] = {
    prompt = "Install a script to automatically remove most logs",
    cronjobs = {
      "* * * * 1", "logs-cleanup.sh", true,
    },
  },
  ["git-credentials-insecure"] = {
    prompt = "Configure Git to store credentials in plaintext\n  (this is a bad and insecure idea!)",
    prerequisites = "git",
    execute = "git config --global credential.helper store",
    ignore = true,
  },
  ["git-credentials-libsecret"] = {
    prompt = "Configure Git to store credentials securely (using libsecret)",
    prerequisites = {"git", "import-private-config"}, -- NOTE the second prerequisite here should be optional
    execute = [[
      sudo apt install libsecret-1-0 libsecret-1-dev libglib2.0-dev
      sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
      git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
    ]],
  },
  ["import-private-config"] = {
    prompt = "Would you like to run a private config import script",
    execute = [[
      echo "Press enter after a private config import script was saved to"
      read -p "  ~/Downloads/import-private-config.lua (or after you have run it)." dummy
      cd ~/Downloads
      chmod +x ./import-private-config.lua
      ./import-private-config.lua
      rm ./import-private-config.lua
      # git config --global init.defaultBranch main   # I shouldn't need this soon hopefully..
    ]],
  },
  ["unattended-upgrades"] = {
    prompt = "Would you like automatic background security updates",
    apt = "unattended-upgrades",
  },
  ["docker-nvidia"] = {
    description = "Docker NVIDIA support",
    prerequisites = "docker",
    execute = [[
      curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
          sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
          sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
      sudo apt-get install nvidia-container-toolkit -y
      sudo nvidia-ctk runtime configure --runtime=docker
      sudo systemctl restart docker
    ]],
  },
  ["ubuntu-drivers"] = {
    description = "ubuntu-drivers autoinstall (will find and install missing drivers)",
    apt = "ubuntu-drivers-common",
    execute = "ubuntu-drivers autoinstall", -- NOTE I think this needs sudo, but it hasn't errored when not using sudo so I'm confused
    notes = "Obviously, this should only be run on Ubuntu-derived systems.",
  },
  ["disable-alt-click-drag"] = {
    prompt = "Would you like to disable holding Alt to click and drag from anywhere on a window",
    execute = "gsettings set org.cinnamon.desktop.wm.preferences mouse-button-modifier ''",
  },
  ["uuidgen"] = {
    description = "uuidgen (CLI UUID generator)",
    apt = "uuid-runtime", -- probably already installed, but I'd rather just be certain
    ask = false,
  },
  ["periodic-cleanup-scripts"] = {
    prompt = "Do you want to install system cleanup scripts (to run once a week)",
    prerequisites = "uuidgen",
    cronjobs = {
      "* * * * 2", "user-cleanup.sh", false,
      "* * * * 1", "root-cleanup.sh", true,
    },
  },
  ["cpu-limiter"] = {
    prompt = "Do you want to limit max CPU usage to 65%", -- highly specific for my dying desktop :'D
    prerequisites = "uuidgen",
    execute = "./scripts/setcpu.sh 65",
    cronjobs = {
      "@reboot", "setcpu.sh 65", true,
    },
  },
}
