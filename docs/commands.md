# useful commands

### Update one inputs
good if you have dependencies on like a git repo that update ofthen
```
nix flake lock --update #{INPUT_NAME}
```

### Install from usb
- set up [disko](https://github.com/nix-community/disko) first 

```
sudo nixos-install --flake #HOSTNAME
```

### age nix setup

```
nix run github:ryantm/agenix -- e secret1.age
```
