{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gitUpdater,
  makeWrapper,
  babashka-unwrapped,
}:

stdenvNoCC.mkDerivation rec {
  pname = "bbin";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "babashka";
    repo = "bbin";
    rev = "v${version}";
    sha256 = "sha256-26uZqHSLi+qnilyPWt/2mCr1wyu1flxNd+jq9zbumrg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D bbin $out/bin/bbin
    mkdir -p $out/share
    cp -r docs $out/share/docs
    wrapProgram $out/bin/bbin \
      --prefix PATH : "${
        lib.makeBinPath [
          babashka-unwrapped
          babashka-unwrapped.graalvmDrv
        ]
      }"

    runHook postInstall
  '';

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = with lib; {
    homepage = "https://github.com/babashka/bbin";
    description = "Install any Babashka script or project with one command";
    mainProgram = "bbin";
    license = licenses.mit;
    inherit (babashka-unwrapped.meta) platforms;
    maintainers = with maintainers; [ sohalt ];
  };
}
