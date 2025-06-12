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
      which -s docker && sudo docker system prune --all -f   # sudo because we assume the user hasn't started a new session after being added to docker group
    ]],
    ignore = true,
  },
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
    priority = 150,
  },
  docker = {
    description = "Docker (containers!)", priority = 99,
    apt = "docker.io", execute = "sudo usermod -aG docker $USER",
  },
  ["docker-compose-legacy"] = {
    description = "docker-compose (Python script, legacy)",
    prerequisites = "docker",
    apt = { "python3-setuptools", "docker-compose", },
    priority = 1,
  },
  ["docker-compose"] = {
    description = "docker compose (Docker plugin)",
    prerequisites = "docker",
    apt = "docker-compose-v2",
    priority = 2,
  },
  extrepo = {
    description = "extrepo (makes it easy to manage external repositories)",
    ask = false, apt = "extrepo",
    priority = 200,
  },
  luarocks = {
    description = "Luarocks (Lua package manager)",
    execute = [[
      sudo apt-get install lua5.1 -y
      sudo apt-get install luarocks -y
      sudo luarocks install moonscript
    ]],
    notes = "Installing Luarocks will also install Moonscript.",
    priority = -1,
  },
  luajit = { description = "LuaJIT (Lua 5.1, faster)", apt = "luajit", ask = false, priority = 750, },
  ["purge-firefox"] = {
    prompt = "Do you want to purge Firefox",
    execute = "sudo apt-get purge firefox -y",
    condition = "which firefox",
  },
  ["cleanup-logs"] = {
    prompt = "Install a script to automatically remove most logs weekly",
    execute = "./scripts/logs-cleanup.sh",
    cronjobs = {
      "* * * * 1", "logs-cleanup.sh", true,
    },
    priority = -99999, -- runs at the end because it also runs immediately once
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
    priority = 99,
  },
  ["unattended-upgrades"] = {
    prompt = "Would you like automatic background security updates",
    apt = "unattended-upgrades",
    priority = -999, -- probably better to avoid potential automatic conflict by doing this too early
  },
  ["docker-nvidia"] = {
    description = "Docker NVIDIA support",
    prerequisites = "docker", hardware = "NVIDIA",
    execute = [[
      curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
          sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
          sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
      sudo apt-get install nvidia-container-toolkit -y
      sudo nvidia-ctk runtime configure --runtime=docker
      sudo systemctl restart docker
    ]],
    priority = -5,
  },
  ["ubuntu-drivers"] = {
    description = "ubuntu-drivers autoinstall (will find and install missing drivers)",
    apt = "ubuntu-drivers-common",
    execute = "ubuntu-drivers autoinstall", -- NOTE I think this needs sudo, but it hasn't errored when not using sudo so I'm confused
    notes = "Obviously, this should only be run on Ubuntu-derived systems.",
    priority = 950, -- do sooner so that if errors interrupt the script, you aren't in a broken state
  },
  ["disable-alt-click-drag"] = {
    prompt = "Would you like to disable holding Alt to click and drag from anywhere on a window",
    execute = "gsettings set org.cinnamon.desktop.wm.preferences mouse-button-modifier ''",
    priority = 1,
  },
  ["uuidgen"] = {
    description = "uuidgen (CLI UUID generator)",
    apt = "uuid-runtime", -- probably already installed, but I'd rather just be certain
    ask = false,
    priority = 100,
  },
  ["periodic-cleanup-scripts"] = {
    prompt = "Do you want to install system cleanup scripts (to run once a week)",
    prerequisites = "uuidgen",
    cronjobs = {
      "* * * * 2", "user-cleanup.sh", false,
      "* * * * 1", "root-cleanup.sh", true,
    },
    priority = 5,
  },
  ["cpu-limiter"] = {
    prompt = "Do you want to limit max CPU usage to 65%", -- highly specific for my dying desktop :'D
    prerequisites = "uuidgen",
    execute = "./scripts/setcpu.sh 65",
    cronjobs = {
      "@reboot", "setcpu.sh 65", true,
    },
    priority = 9999,
  },
  ["latest-mesa-drivers"] = {
    prompt = "Are you using Intel integrated graphics OR in a VirtualBox machine\n (an updated driver must be manually installed to prevent graphics driver failure)",
    ppa = "ppa:kisak/kisak-mesa", execute = "sudo apt-get upgrade -y",
    priority = 999, hardware = "integrated_graphics",
  },
}
