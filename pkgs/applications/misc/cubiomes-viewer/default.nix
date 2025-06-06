{
  lib,
  stdenv,
  fetchFromGitHub,
  qtbase,
  qmake,
  qttools,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "cubiomes-viewer";
  version = "4.1.2";

  src = fetchFromGitHub {
    owner = "Cubitect";
    repo = pname;
    rev = version;
    hash = "sha256-izDKS08LNT2rV5rIxlWRHevJAKEbAVzekjfZy0Oen1I=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace cubiomes-viewer.pro \
      --replace '$$[QT_INSTALL_BINS]/lupdate' lupdate \
      --replace '$$[QT_INSTALL_BINS]/lrelease' lrelease
  '';

  buildInputs = [
    qtbase
  ];

  nativeBuildInputs = [
    qmake
    qttools
    wrapQtAppsHook
  ];

  preBuild = ''
    # QMAKE_PRE_LINK is not executed (I dont know why)
    make -C ./cubiomes libcubiomes CFLAGS="-DSTRUCT_CONFIG_OVERRIDE=1" all
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp cubiomes-viewer $out/bin

    mkdir -p $out/share/{pixmaps,applications}
    cp rc/icons/map.png $out/share/pixmaps/com.github.cubitect.cubiomes-viewer.png
    cp etc/com.github.cubitect.cubiomes-viewer.desktop $out/share/applications

    runHook postInstall
  '';

  meta = with lib; {
    broken = stdenv.hostPlatform.isDarwin;
    homepage = "https://github.com/Cubitect/cubiomes-viewer";
    description = "Graphical Minecraft seed finder and map viewer";
    mainProgram = "cubiomes-viewer";
    longDescription = ''
      Cubiomes Viewer provides a graphical interface for the efficient and flexible seed-finding
      utilities provided by cubiomes and a map viewer for the Minecraft biomes and structure generation.
    '';
    platforms = platforms.all;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ hqurve ];
  };
}
