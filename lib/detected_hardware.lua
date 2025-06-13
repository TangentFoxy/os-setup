-- Returns a table of detected hardware devices using the following names:
-- {
--   -- graphics
--   NVIDIA = true,
--   AMD = true,
--   integrated_graphics = true, -- will be reported for VirtualBox
--   software_graphics = true,
--   virtual_machine = true,     -- if the computer is virtualized
-- }

local utility = require "lib.utility"

local result = {}
local hardware = utility.capture_safe("lspci  -v -s  $(lspci | grep ' VGA ' | cut -d\" \" -f 1)")

local integrated_graphics_keywords = {
  "Integrated Graphics", "iGPU", "Intel(R) HD Graphics",
  "Intel Corporation HD Graphics", "Intel Corporation UHD Graphics",
  "VMware",
}

if hardware:find("Software Rendering", 1, true) then
  result.software_graphics = true
end

for _, text in ipairs(integrated_graphics_keywords) do
  if hardware:find(text, 1, true) then
    result.integrated_graphics = true
    break
  end
end

if hardware:find("NVIDIA Corporation", 1, true) then
  result.NVIDIA = true
end

if hardware:find("AMD/ATI", 1, true) then
  result.AMD = true
end

if hardware:find("VMware", 1, true) then
  result.virtual_machine = true
end

-- presence of nvidia-smi in path indicates NVIDIA
-- presence of aticonfig  in path indicates AMD

return result
