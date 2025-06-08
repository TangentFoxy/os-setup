# os-setup
Scripts to make setting up a new system easier.. hopefully.

**Note: Please take a look at the issues before running.**  
Most things are working fine, and I am working hard to fix the remaining
problems, but please take a look at what could go wrong before you run this.

More documentation coming soon!

To use, run the following:

```
sudo apt-get update && sudo apt-get install git -y \
  && git clone https://github.com/TangentFoxy/os-setup --depth=1 \
  && cd os-setup && ./run.sh
```

---

Note: Using [luarocks/argparse](https://github.com/luarocks/argparse). Other implementations are inferior.
