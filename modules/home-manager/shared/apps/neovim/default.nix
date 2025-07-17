{
  pkgs,
  homeManagerConfig,
  config,
  inputs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    package = inputs.neovim-nightly.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
      lua-language-server
      stylua

      bash-language-server
      shfmt

      yaml-language-server
      yamlfmt

      typescript-language-server
      tailwindcss-language-server
      vscode-langservers-extracted
      prettierd

      gopls

      nil
      nixfmt-rfc-style
    ];
  };

  home.file.".config/nvim".source = homeManagerConfig.linkSharedApp config "neovim";
}
