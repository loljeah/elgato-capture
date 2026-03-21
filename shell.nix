{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "elgato-capture";

  buildInputs = with pkgs; [
    mpv
    ffmpeg
    v4l-utils
    pulseaudio  # for pactl device listing
  ];

  shellHook = ''
    echo "Elgato Capture Environment"
    echo "=========================="
    echo ""
    echo "Commands:"
    echo "  ./capture.sh        - Start capture window"
    echo "  ./list-devices.sh   - List video/audio devices"
    echo ""
    echo "Tip: Run list-devices.sh first to verify your card is detected"
  '';
}
