# Run:
# `https://github.com/pottumuusi/fleet-management/blob/main/application/setup_nix.sh`
# prior trying to enter development shell with `nix-shell ./shell.nix`.

{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ opencode ];
}
