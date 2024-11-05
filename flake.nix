{
  description = "risc0 tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
  let
    version = "v1.1.2";
    overlays = [(import rust-overlay)];
    systems = [ "aarch64-darwin" ];
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs { inherit system overlays; };
      in rec {
        risc0 = pkgs.fetchFromGitHub {
          owner = "risc0";
          repo = "risc0";
          rev = version;
          sha256 = "sha256-Ne809xXpHbff08cs2ACQ/Dp0u5R+BhZaLJP5600lmSw=";
        };

        rustVersion = pkgs.rust-bin.stable.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustVersion;
          rustc = rustVersion;
        };

        packages.rzup = rustPlatform.buildRustPackage {
          name = "rzup";
          version = version;
          src = risc0;
          cargoBuildFlags = [ "-p" "rzup" ];
          cargoHash = "sha256-UzsNsxbKcVRa4zaNFsLf7JkdPS6rw5fqFbYqQLzDw7E=";

          nativeBuildInputs = [ pkgs.makeBinaryWrapper pkgs.pkg-config ];

          doCheck = false;
        };
      }
    );
}
