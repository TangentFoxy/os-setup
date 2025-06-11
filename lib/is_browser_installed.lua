-- returns true or false depending on whether or not a browser is installed

local utility = require "lib.utility"

return function()
  if 0 == utility.capture_safe("xdg-settings get default-web-browser", true) then
    return true
  end

  local paths = {
    utility.capture_safe("echo ~/.local/share"):sub(1, -2) .. "/applications/"
  }

  for path in string.gsplit(utility.capture_safe("echo $XDG_DATA_DIRS"), ":") do
    if path:sub(-1) == "\n" then
      path = path:sub(1, -2)
    end
    paths[#paths + 1] = path .. "/applications/"
  end

  local file_paths = {}

  for _, path in ipairs(paths) do
    utility.ls(path)(function(file_name)
      local _, _, extension = utility.split_path_components(path .. file_name)
      if extension == "desktop" then
        file_paths[#file_paths + 1] = path .. file_name
      end
    end)
  end

  for _, file_path in ipairs(file_paths) do
    if utility.open(file_path, "r")(function(file)
      local line = file:read("*line")
      local browser_found = false

      while line do
        if line:find("Hidden=true") then
          return false
        end
        if line:find("Categories") and line:find("WebBrowser") then
          browser_found = true -- can't return immediately, because Hidden might be defined
        end

        line = file:read("*line")
      end

      return browser_found
    end) then
      return true
    end
  end

  return false
end
