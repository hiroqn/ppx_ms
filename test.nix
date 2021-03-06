{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  gitignore = import (fetchFromGitHub {
    owner = "siers";
    repo = "nix-gitignore";
    rev = "6dd9ece00991003c0f5d3b4da3f29e67956d266e";
    sha256 = "0jn5yryf511shdp8g9pwrsxgk57p6xhpb79dbi2sf5hzlqm2csy4";
  }) { inherit lib; };
  ocaml = callPackage ./nix/ocaml.nix { };
  mkOcamlPackages =  (callPackage <nixpkgs/pkgs/top-level/ocaml-packages.nix> {}).mkOcamlPackages;
  ocamlPackages = mkOcamlPackages ocaml (self: super: { 
    angstrom = self.callPackage ./nix/angstrom.nix {};
  });
in
stdenv.mkDerivation {
  name = "ppx_ms_test";
  src = gitignore.gitignoreSourceAux "" ./.;
  buildInputs = [ ocaml ] ++ (with ocamlPackages; [ ocaml-migrate-parsetree angstrom findlib qcheck ounit ]);
  phase = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    ocamlfind ocamlopt -package qcheck,angstrom -linkpkg -I src -o $out/bin/test src/ppx_ms_parser.ml test/test_parser.ml
    $out/bin/test
  '';
}
