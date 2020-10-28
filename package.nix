{ stdenvNoCC
}:

stdenvNoCC.mkDerivation {
  name = "haskellrc";
  src = ./.;
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p "$out/bin" "$out/etc"

    for file in bin/*; do
      install -m 0555 "$file" "$out/bin"
    done

    for file in etc/*; do
      install -m 0444 "$file" "$out/etc"
    done
  '';
}
