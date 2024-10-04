docker run -it \
  -v $(pwd)/:/workdir \
  -v ./ssh/:/root/.ssh \
  -w="/workdir" \
  nixos/nix
