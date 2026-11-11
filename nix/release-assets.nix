# Pinned GitHub Release assets for packages.<system>.headlamp-server-bin. Each
# hash is the SRI form of the asset's .sha256 sidecar; bump the version and
# convert each digest with `nix hash convert --hash-algo sha256 --to sri`.
{
  version = "0.45.0-rigel.1";
  assets = {
    aarch64-darwin = {
      name = "headlamp-server-v0.45.0-rigel.1-darwin-arm64.tar.gz";
      hash = "";
    };
    x86_64-linux = {
      name = "headlamp-server-v0.45.0-rigel.1-linux-amd64.tar.gz";
      hash = "";
    };
    aarch64-linux = {
      name = "headlamp-server-v0.45.0-rigel.1-linux-arm64.tar.gz";
      hash = "";
    };
  };
}
