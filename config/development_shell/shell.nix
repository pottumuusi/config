# Run `scripts/setup_nix_channels.sh` prior trying to enter development shell
# with `nix-shell ./shell.nix`.

{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ opencode ];
}
