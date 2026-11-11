{
  description = "RigelBuild headlamp release binaries, fetched by hash";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      overlays.default = final: _prev: {
        headlamp-server-bin = final.callPackage ./nix/package-bin.nix { };
      };
    }
    // flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        headlampBin = pkgs.callPackage ./nix/package-bin.nix { };
      in
      {
        packages = {
          headlamp-server-bin = headlampBin;
          default = headlampBin;
        };

        checks = {
          # The release repack must stay a binary fetch: no C compiler in its stdenv.
          headlamp-server-bin-no-source-build =
            if headlampBin.stdenv ? cc && headlampBin.stdenv.cc != null then
              throw "headlamp-server-bin stdenv carries a C compiler; it must repack the release binary"
            else
              pkgs.runCommand "headlamp-server-bin-no-source-build" { } "touch $out";
        };
      }
    );
}
