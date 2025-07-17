{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    masApps = { 
      "wireguard" = 1451685025; 
    };

    brews = [
      "lua"
      "ripgrep"
      "libpcap"
      "xz"
      "immich-go"
      # "cocoapods"
      # "sketchybar"
      # "borders"
    ];

    taps = [
      "nikitabobko/tap"
      "felixkratz/formulae"
      "krtirtho/apps"
    ];

    casks = [
      { name = "xcodes-app"; greedy = true; }
      { name = "ghostty"; greedy = true; }
      { name = "anydesk"; greedy = true; }
      { name = "ankerwork"; greedy = true; }
      { name = "blender"; greedy = true; }
      { name = "betterdisplay"; greedy = true; }
      { name = "kindavim"; greedy = true; }
      { name = "bruno"; greedy = true; }
      { name = "crossover"; greedy = true; }
      { name = "insomnia"; greedy = true; }
      { name = "linearmouse"; greedy = true; }
      { name = "shottr"; greedy = true; }
      { name = "bambu-studio"; greedy = true; }
      { name = "hammerspoon"; greedy = true; }
      { name = "raspberry-pi-imager"; greedy = true; }
      { name = "brave-browser"; greedy = true; }
      { name = "hiddenbar"; greedy = true; }
      { name = "moonlight"; greedy = true; }
      { name = "pearcleaner"; greedy = true; }
      { name = "kap"; greedy = true; }
      { name = "localsend"; greedy = true; }
      { name = "aerospace"; greedy = true; }
      { name = "http-toolkit"; greedy = true; }
      { name = "the-unarchiver"; greedy = true; }
      # { name = "android-studio-preview@beta"; greedy = true; }
      # { name = "zen-browser"; greedy = true; }
      # { name = "notchnook"; greedy = true; }

      { name = "font-space-mono-nerd-font"; greedy = true; }
      { name = "font-maple-mono-nf"; greedy = true; }
      { name = "font-sf-mono-nerd-font-ligaturized"; greedy = true; }
      # { name = "font-sketchybar-app-font"; greedy = true; }
    ];
  };
}
