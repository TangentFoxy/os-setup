# os-setup
Scripts to make setting up a new system easier.. hopefully.

**Note: Currently hardcoded to do a dry-run demo only.**  
Once I finish testing that it works as intended and fixing the arguments that
can be passed to installer.lua, I will add info here and remove this warning.

To use, run the following:

```
sudo apt-get update && sudo apt-get install git -y \
  && git clone https://github.com/TangentFoxy/os-setup --depth=1 \
  && cd os-setup && ./run.sh
```
