-- Returns a table of detected hardware devices using the following names:
-- {
--   -- graphics
--   NVIDIA = true,
--   AMD = true,
--   integrated_graphics = true,
--   software = true,
-- }

local utility = require "lib.utility"

local result = {}
local hardware = utility.capture_safe("lspci  -v -s  $(lspci | grep ' VGA ' | cut -d\" \" -f 1)")

local integrated_graphics_keywords = {
  "Integrated Graphics", "iGPU", "Intel(R) HD Graphics",
  "Intel Corporation HD Graphics", "Intel Corporation UHD Graphics",
}

if hardware:find("Software Rendering", 1, true) then
  result.software = true
  return result -- there is no graphics hardware at all
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

-- presence of nvidia-smi in path indicates NVIDIA
-- presence of aticonfig  in path indicates AMD

return result
