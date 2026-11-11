{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
}:
let
  release = import ./release-assets.nix;
  system = stdenv.hostPlatform.system;
  asset =
    release.assets.${system}
      or (throw "headlamp-server-bin: no v${release.version} release asset for ${system}");
  pinned =
    if asset.hash == "" then
      throw "headlamp-server-bin: ${asset.name} has no pinned hash; publish the release and pin it in nix/release-assets.nix"
    else
      asset;
in
stdenv.mkDerivation {
  pname = "headlamp-server-bin";
  version = release.version;
  src = fetchurl {
    url = "https://github.com/RigelBuild/headlamp/releases/download/v${release.version}/${pinned.name}";
    inherit (pinned) name hash;
  };

  # Linux release binaries need their ELF interpreter rewritten to the Nix
  # loader. macOS release binaries are used as-is.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;
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
    platforms = builtins.attrNames release.assets;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
