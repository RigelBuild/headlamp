# Pinned hashes for packages.<system>.headlamp-server-bin. Asset names are derived
# in package-bin.nix from the version and the system. Each hash is the SRI form of
# the release asset's .sha256 digest. Empty until the first rigel tag publishes:
# convert each digest with `nix hash convert --hash-algo sha256 --to sri`.
{
  version = "0.45.0-rigel.1";
  hashes = {
    aarch64-darwin = "";
    x86_64-linux = "";
    aarch64-linux = "";
  };
}
