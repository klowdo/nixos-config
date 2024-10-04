# chown -R $(whoami) ~/.ssh/

chown root:$USER ~/.ssh/config
chmod 644 ~/.ssh/config
git config --global --add safe.directory /workdir
# git add .

./nixos-rebuild.sh switch \
  --flake .#virt-nix \
  --target-host virt-nix \
  --use-remote-sudo
