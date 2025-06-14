#!/usr/bin/env luajit

-- ensures functionality if you've run this from somewhere else while its in $PATH
package.path = (arg[0]:match("@?(.*/)") or arg[0]:match("@?(.*\\)")) .. "?.lua;" .. package.path
local utility = require "lib.utility"
local argparse = require "lib.argparse"
local is_browser_installed = require "lib.is_browser_installed"

local parser = argparse()
parser:argument("package", "Select specific package(s). If specified, --default-choice and --interactive options will be ignored."):args("*")
parser:option("--default-choice", "Default answer to prompts.", "N"):choices{"Y", "N"}:args(1):overwrite(false)
parser:flag("--dry-run", "Output the commands that would be run instead of running them."):overwrite(false)
parser:option("--interactive", "Wait for user input.", "true"):choices{"true", "false"}:overwrite(false)
parser:flag("--show-priority", "List all packages ordered by priority."):overwrite(false)
parser:flag("--list-packages", "List all packages (presented as a Markdown task list)."):overwrite(false)



local original_error = error
function error(message)
  original_error("\n\n" .. message .. "\n\n")
end



-- TODO reorganize into a load_packages() function to call immediately
local packages = {}
for _, name in ipairs({ "system", "games", "media", "utility", "developer", }) do
  local _packages = require("packages." .. name)
  for name, package in pairs(_packages) do
    packages[name] = package
  end
end

local states = utility.enumerate({ "IGNORED", "TO_ASK", "TO_INSTALL", "INSTALLED", })

local function sanitize_packages() -- and check for errors
  local detected_hardware = require "lib.detected_hardware"

  for name, package in pairs(packages) do
    if package.ask or package.ask == nil then
      package.status = states.TO_ASK
    end
    if package.ignore then
      package.status = states.IGNORED
    end
    if package.hardware then
      if not detected_hardware[package.hardware] then
        package.status = states.IGNORED
      end
    end
    if package.hardware_exclude then
      if detected_hardware[package.hardware_exclude] then
        package.status = states.IGNORED
      end
    end
    if package.description then
      package.prompt = "Install " .. package.description
    end
    if package.condition then
      package.conditions = package.condition
    end
    if not package.priority then
      package.priority = 0
    end

    if type(package.prerequisites) == "string" then
      package.prerequisites = { package.prerequisites }
    end
    if type(package.optional_prerequisites) == "string" then
      package.optional_prerequisites = { package.optional_prerequisites }
    end
    if type(package.apt) == "string" then
      package.apt = { package.apt }
    end
    if type(package.flatpak) == "string" then
      package.flatpak = { package.flatpak }
    end
    if type(package.conditions) ~= "table" then
      package.conditions = { package.conditions }
    end
    if type(package.browse_to) == "string" then
      package.browse_to = { package.browse_to, "Debian (.deb)" }
    end
    if package.desktop then
      if type(package.desktop.categories) == "string" then
        package.desktop.categories = { package.desktop.categories }
      end
    end

    if not package.prerequisites then
      package.prerequisites = {}
    end
    if not package.optional_prerequisites then
      package.optional_prerequisites = {}
    end
    if not package.conditions then
      package.conditions = {}
    end
    if not package.cronjobs then
      package.cronjobs = {}
    end

    if package.execute and package.execute:sub(1, 1) ~= " " then -- pretty formatting for dry_run
      package.execute = "      " .. package.execute .. "\n"
    end

    local function config_error(reason)
      error("Package '" .. name .. "' " .. reason .. ".\nPlease report this issue at https://github.com/TangentFoxy/os-setup/issues")
    end
    if not package.prompt then
      config_error("lacks a prompt or description")
    end
    -- TODO check for other types of error
    if #package.cronjobs % 3 ~= 0 then
      config_error("has invalid cronjob definition(s)")
    end
  end
end
sanitize_packages()

local package_order = {}
for name, package in pairs(packages) do
  table.insert(package_order, {
    name = name,
    priority = package.priority,
  })
end
table.sort(package_order, function(a, b) return a.priority > b.priority end)



local options = parser:parse()

if options.interactive == "false" then
  options.interactive = false
  -- don't need to bother converting "true" to true because its truthy
end

if options.show_priority then
  for _, package in ipairs(package_order) do
    print(package.priority, package.name)
  end
  return true
end

if options.list_packages then
  for _, package in ipairs(package_order) do
    local output = "- [ ] " .. package.name
    if packages[package.name].ignore then
      output = output .. " (ignored)"
    end
    if packages[package.name].ask == false then
      output = output .. " (not prompted: dependency only)"
    end
    print(output)
  end
  return true
end



local select_package
select_package = function(name)
  local package = packages[name]
  package.status = states.TO_INSTALL
  for _, name in ipairs(package.prerequisites) do
    select_package(name)
  end
end

local function prompt(text, hide_default_entry)
  io.write(text)
  if options.interactive then
    return io.read("*line")
  else
    if not hide_default_entry then io.write(options.default_choice) end
    io.write("\n")
    return ""
  end
end

local function ask(text)
  local choice = prompt(text)
  if #choice < 1 then choice = options.default_choice end
  if choice:sub(1):lower() == "y" then
    return true
  end
end

local function system_upgrade()
  if options.dry_run then
    print("Making sure system is up-to-date...")
    print(packages["system-upgrade"].execute)
  else
    os.execute(packages["system-upgrade"].execute)
  end
end



local function ask_packages()
  for _, package in ipairs(package_order) do
    local name = package.name
    package = packages[name]

    local function _ask(name, package)
      if not (package.status == states.TO_ASK) then
        return
      end

      for _, name in ipairs(package.prerequisites) do
        if packages[name].status == states.IGNORED then
          return
        end
      end

      if package.notes then
        print("\n" .. package.notes)
      end

      if ask(package.prompt .. " (y/n, default: " .. options.default_choice .. ")? ") then
        select_package(name)
      end
    end

    _ask(name, package)
  end

  io.write("\n") -- formatting
end

-- choose what to run
if #options.package > 0 then
  for _, name in ipairs(options.package) do
    select_package(name)
  end
else
  ask_packages()
end

system_upgrade()

local function execute(...)
  if options.dry_run then
    print(...)
    return 0 -- always say it worked
  else
    return os.execute(...)
  end
end

local function create_menu_entry(desktop)
  local desktop_file_name = desktop.path .. "/" .. desktop.name .. ".desktop"
  local lines = {
    "[Desktop Entry]",
    "Name=" .. desktop.name,
    "Path=" .. desktop.path,
    "Exec=" .. desktop.exec,
    "Icon=" .. desktop.icon,
    "Terminal=false",
    "Type=Application",
    "Categories=" .. table.concat(desktop.categories, "\\;"),
  }
  for _, line in ipairs(lines) do
    execute("  echo " .. line .. " >> " .. desktop_file_name)
  end
  execute("  chmod +x " .. desktop_file_name)
  execute("  desktop-file-validate " .. desktop_file_name)
  execute("  desktop-file-install --dir=$HOME/.local/share/applications " .. desktop_file_name)
  execute("  update-desktop-database ~/.local/share/applications") -- appears to be unnecessary on Mint
  if options.dry_run then
    io.write("\n")
  end
end

local function create_cronjob(schedule, script, sudo)
  local script_name = script:split(" ")[1]
  local lines = {
    "  uuid=$(uuidgen)",
    "  cp ./scripts/" .. script_name .. " /opt/$uuid-" .. script_name,
    "  croncmd=\"/opt/$uuid-" .. script .. "\"",
    "  cronjob=\"" .. schedule .. " $croncmd\"",
  }
  if sudo then
    lines[#lines + 1] = "  (sudo crontab -l | grep -v -F \"$croncmd\" || : ; echo \"$cronjob\" ) | sudo crontab -"
  else
    lines[#lines + 1] = "  (crontab -l | grep -v -F \"$croncmd\" || : ; echo \"$cronjob\" ) | crontab -"
  end
  execute(table.concat(lines, "\n"))
  if options.dry_run then
    io.write("\n")
  end
end

local done = false
local times_run = 0
repeat
  if times_run > #packages + 10 then
    print("The following packages have failed to install:")
    for name, package in pairs(packages) do
      if package.status == states.TO_INSTALL then
        print("  " .. name)
      end
    end
    error("This script was detected to be looping infinitely.")
  end

  local function _install(name, package)
    if package.status ~= states.TO_INSTALL then
      return
    end

    for _, name in ipairs(package.prerequisites) do
      if packages[name].status ~= states.INSTALLED then
        return
      end
    end
    for _, name in ipairs(package.optional_prerequisites) do
      if packages[name].status ~= states.TO_INSTALL then
        return
      end
    end

    for _, condition in ipairs(package.conditions) do
      if type(condition) == "function" then
        if not condition() then
          return
        end
      elseif type(condition) == "string" then
        if not execute(condition) == 0 then
          return
        end
      end
    end

    if package.browse_to then
      if not is_browser_installed() then
        return
      end
    end



    if options.dry_run then
      print("Simulating '" .. name .. "'...")
    end

    if package.browse_to then
      local download_url = package.browse_to[1]
      local file_description = package.browse_to[2]

      print("Opening your browser to a download page.")
      print("Make sure you choose the " .. file_description .. " file and that it is saved to ~/Downloads")
      execute("  open " .. download_url)
      prompt("Press enter when the download is finished.", true)
    end

    if package.ppa then
      execute("  sudo add-apt-repository -y " .. package.ppa .. " && sudo apt-get update")
    end
    if package.apt then
      execute("  sudo apt-get install -y " .. table.concat(package.apt, " "))
    end
    if package.flatpak then
      for _, name in ipairs(package.flatpak) do
        execute("  flatpak install -y " .. name)
      end
    end

    if package.execute then
      execute(package.execute)
    elseif options.dry_run then
      io.write("\n")
    end

    if package.desktop then
      create_menu_entry(package.desktop)
    end

    for i = 1, #package.cronjobs, 3 do
      local schedule = package.cronjobs[i]
      local script = package.cronjobs[i + 1]
      local sudo = package.cronjobs[i + 2]
      create_cronjob(schedule, script, sudo)
    end

    package.status = states.INSTALLED
  end

  for _, package in ipairs(package_order) do
    local name = package.name
    package = packages[name]

    _install(name, package)
  end

  done = true
  for _, package in pairs(packages) do
    if package.status == states.TO_INSTALL then
      done = false
      break
    end
  end

  times_run = times_run + 1
until done

system_upgrade()

print("Looped " .. times_run .. " times to run all scripts.")
