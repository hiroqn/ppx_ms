{ stdenv, fetchFromGitHub, }:
let
  src = fetchFromGitHub {
    owner = "BuckleScript";
    repo = "bucklescript";
    rev = "484740cd56981130573efc81757c41f5662f4f0e";
    sha256 = "1mcz283jjwbwq52r51nzz5wjwc7y6g4fhgv0zbgs1wwp496mpjpy";
  };
in
stdenv.mkDerivation {
  version = "4.02.3";
  name = "ocaml-4.02.3+buckle-master";
  inherit src;
  configurePhase = ''
    cd vendor/ocaml
    ./configure -prefix $out
  '';
  buildPhase = ''
    make world.opt
  '';
  installPhase = ''
    make install
  '';

  meta = with stdenv.lib; {
    homepage = http://caml.inria.fr/ocaml;
    branch = "4.02";
    description = "Most popular variant of the Caml language";
    platforms = with platforms; linux ++ darwin;
  };
}
