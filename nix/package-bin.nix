{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  release = import ./release-assets.nix;
  system = stdenvNoCC.hostPlatform.system;
  # Asset filenames follow release-binaries.yml: headlamp-server-v<ver>-<goos>-<goarch>.tar.gz
  goTarget = {
    aarch64-darwin = "darwin-arm64";
    x86_64-linux = "linux-amd64";
    aarch64-linux = "linux-arm64";
  };
  name = "headlamp-server-v${release.version}-${
    goTarget.${system} or (throw "headlamp-server-bin: no release asset for ${system}")
  }.tar.gz";
  hash =
    release.hashes.${system}
      or (throw "headlamp-server-bin: no v${release.version} release asset for ${system}");
  pinnedHash =
    if hash == "" then
      throw "headlamp-server-bin: ${name} has no pinned hash; publish the release and pin it in nix/release-assets.nix"
    else
      hash;
in
stdenvNoCC.mkDerivation {
  pname = "headlamp-server-bin";
  version = release.version;
  src = fetchurl {
    url = "https://github.com/RigelBuild/headlamp/releases/download/v${release.version}/${name}";
    inherit name;
    hash = pinnedHash;
  };

  dontConfigure = true;
  dontBuild = true;
  # The binary is static (CGO_ENABLED=0), so it needs no ELF patching.
  # Stripping can invalidate the ad-hoc signed Mach-O release binary.
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    tar -xzf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 headlamp-server "$out/bin/headlamp-server"
    runHook postInstall
  '';

  meta = {
    description = "Prebuilt headlamp-server release binary (RigelBuild fork)";
    homepage = "https://github.com/RigelBuild/headlamp";
    license = lib.licenses.asl20;
    mainProgram = "headlamp-server";
    platforms = builtins.attrNames goTarget;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
