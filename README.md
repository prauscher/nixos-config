# Updating

make sure to first update `flake.lock`, cleaning the repo and rebuild afterwards:

$ nix flake update
$ git add flake.lock
$ git commit -m "update flake.lock"
$ sudo nixos-rebuild switch --flake .

To change channels, edit `flake.nix` before running `nix flake update`
