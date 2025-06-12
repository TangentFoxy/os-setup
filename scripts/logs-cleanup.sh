# this script should be run as root
# sudo is used anyhow to account for running it once while not root
sudo journalctl --vacuum-time=1d
sudo journalctl --vacuum-size=10M
