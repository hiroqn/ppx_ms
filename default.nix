{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  gitignore = import (fetchFromGitHub {
    owner = "siers";
    repo = "nix-gitignore";
    rev = "221d4aea15b4b7cc957977867fd1075b279837b3";
    sha256 = "0xgxzjazb6qzn9y27b2srsp2h9pndjh3zjpbxpmhz0awdi7h8y9m";
  }) { inherit lib; };
  ocaml = callPackage ./nix/ocaml.nix { };
  mkOcamlPackages =  (callPackage <nixpkgs/pkgs/top-level/ocaml-packages.nix> {}).mkOcamlPackages;
  ocamlPackages = mkOcamlPackages ocaml (self: super: {
    angstrom = self.callPackage ./nix/angstrom.nix {};
  });
in
stdenv.mkDerivation {
  name = "ppx_ms";
  src = gitignore.gitignoreSourceAux "" ./.;
  buildInputs = [ ocaml ] ++ (with ocamlPackages; [ ocaml-migrate-parsetree angstrom findlib ]);
  phase = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    ocamlfind ocamlopt -package ocaml-migrate-parsetree,angstrom -linkpkg -o $out/bin/ppx_ms -I src src/ppx_ms_parser.ml src/ppx_ms.ml
  '';
}
