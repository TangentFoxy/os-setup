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

## Packages Format
Every key is optional.

Metadata:
- `ask`: Set to `false` to prevent the user from being asked about whether or not they want to install this package. (Useful for dependencies that are never installed *only on their own*.)
- `ignore`: If truthy, will be entirely ignored. (Useful for broken/incomplete packages.)
- `hardware`: Specifies hardware dependencies. Packages with missing hardware dependencies are automatically ignored. Recognized values:
  - `NVIDIA`: NVIDIA graphics card.
  - `AMD`: AMD/ATI graphics card.
  - `integrated_graphics`: integrated (CPU) graphics.
  - `software_graphics`: No graphics hardware present. Software rendering only.
  - `virtual_machine`: Running inside a VM.
- `hardware_exclude`: Opposite of `hardware`. If this hardware is detected, the package will be ignored. See `hardware` for recognized values.
- `description`: A name and brief description of what the package is. Will be turned into a `prompt` question. (`prompt` cannot be used with `description`.)
- `prompt`: For packages that aren't directly *installing* something, a custom prompt can be used. Incompatible with `description`.
- `priority`: Higher numbers go first. (Everything defaults to 0.) (I've been organizing these in part by how much I want different things, and how *slow* some things are. I prioritize faster and more important things.)
- `notes`: Extra notes/warnings about the package. (`description` is only meant to have *what* it is.)
- `binary`: If a `which` command can be run to verify installation, the name of the binary should be here.
- `name`: **Do not set this.** (Automatically added for internal functionality.)

Functions that will be run (in the order shown here):
- `prerequisites`: Package(s) required to be installed *before* this package.
- `optional_prerequisites`: Package(s) that must be installed *before* this package if both are being installed.
- `conditions`/`condition`: Can be a function, which must return a truthy value for installation to proceed, or a string containing a command which must exit 0 to continue. Critically, these checks are done during an attempted install, *not* when deciding what to install. (Used to make complex checks that can't be handled another way.)
- `browse_to`: Tuples of URLs and file descriptions that must be opened for the user to download file(s). Defaults to instructing to download a Debian (.deb) file.
- `ppa`: A PPA that must be added to APT-GET.
- `apt`: Packages that must be installed via APT-GET.
- `flatpak`: Packages that must be installed via Flatpak.
- `brew`: Packages that must be installed via brew.
- `execute`: A shell script to run.
- `desktop`: Creates a `.desktop` file to put a program in the menu. Must contain `name`, `path`, `exec`, `icon`, and `categories`.
  - See [Recognized desktop entry keys](https://specifications.freedesktop.org/desktop-entry-spec/latest/recognized-keys.html) for what these values should have.
  - See [Registered Categories](https://specifications.freedesktop.org/menu-spec/latest/category-registry.html) for what categories are valid.
- `cronjobs`: Creates cron jobs. Jobs are tuples containing a schedule, script, and whether or not it needs to be run as root.

---

Note: Using [luarocks/argparse](https://github.com/luarocks/argparse). Other implementations are inferior.
