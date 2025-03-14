{
  lib,
  stdenv,
  fetchurl,
  doxygen,
  mandoc,
  meson,
  ninja,
  pkg-config,
  python3,
  sphinx,
  sphinxygen,
  writeScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "serd";
  version = "0.32.4";

  outputs = [
    "out"
    "dev"
    "doc"
    "man"
  ];

  src = fetchurl {
    url = "https://download.drobilla.net/serd-${finalAttrs.version}.tar.xz";
    hash = "sha256-y++1aejbaGvoxpyzhmqVOMfLBV6PJCF91qRHHv+n00k=";
  };

  nativeBuildInputs = [
    doxygen
    mandoc
    meson
    ninja
    pkg-config
    python3
    sphinx
    sphinxygen
  ];

  postPatch = ''
    patchShebangs .
  '';

  passthru = {
    updateScript = writeScript "update-poke" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre common-updater-scripts

      set -eu -o pipefail

      # Expect the text in format of 'download.drobilla.net/serd-0.30.16.tar.xz">'
      new_version="$(curl -s https://drobilla.net/category/serd/ |
          pcregrep -o1 'download.drobilla.net/serd-([0-9.]+).tar.xz' |
          head -n1)"
      update-source-version ${finalAttrs.pname} "$new_version"
    '';
  };

  meta = {
    description = "Lightweight C library for RDF syntax which supports reading and writing Turtle and NTriples";
    homepage = "https://drobilla.net/software/serd";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ samueltardieu ];
    mainProgram = "serdi";
    platforms = lib.platforms.unix;
  };
})
