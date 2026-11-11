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
          # The release repack must stay a binary fetch: no compiler in its inputs.
          headlamp-server-bin-no-source-build =
            let
              inputs = headlampBin.nativeBuildInputs ++ headlampBin.buildInputs;
              compilerOutPaths = map (drv: drv.outPath) [
                pkgs.go
                pkgs.nodejs
                pkgs.stdenv.cc
              ];
              inputOutPaths = map (drv: drv.outPath) inputs;
              hasCompiler = builtins.any (p: builtins.elem p compilerOutPaths) inputOutPaths;
            in
            if hasCompiler then
              throw "headlamp-server-bin build inputs include a compiler; it must repack the release binary"
            else
              pkgs.runCommand "headlamp-server-bin-no-source-build" { } "touch $out";
        };
      }
    );
}
