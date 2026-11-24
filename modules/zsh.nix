{ pkgs, ... }:
let
  # TokyoNight Storm-ish shell colors
  tn = {
    fg = "#c0caf5";
    comment = "#565f89";
    cyan = "#7dcfff";
    blue = "#7aa2f7";
    green = "#9ece6a";
    magenta = "#bb9af7";
    red = "#f7768e";
    yellow = "#e0af68";
    orange = "#ff9e64";
  };
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      # TokyoNight-themed syntax highlighting / autosuggestions
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[default]="fg=${tn.fg}"
      ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${tn.red}"
      ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=${tn.magenta}"
      ZSH_HIGHLIGHT_STYLES[alias]="fg=${tn.cyan}"
      ZSH_HIGHLIGHT_STYLES[builtin]="fg=${tn.blue}"
      ZSH_HIGHLIGHT_STYLES[function]="fg=${tn.blue}"
      ZSH_HIGHLIGHT_STYLES[command]="fg=${tn.green}"
      ZSH_HIGHLIGHT_STYLES[precommand]="fg=${tn.green},italic"
      ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=${tn.magenta}"
      ZSH_HIGHLIGHT_STYLES[path]="fg=${tn.fg},underline"
      ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=${tn.comment}"
      ZSH_HIGHLIGHT_STYLES[globbing]="fg=${tn.cyan}"
      ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${tn.yellow}"
      ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${tn.yellow}"
      ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=${tn.yellow}"
      ZSH_HIGHLIGHT_STYLES[assign]="fg=${tn.orange}"
      ZSH_HIGHLIGHT_STYLES[comment]="fg=${tn.comment},italic"
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${tn.comment}"

      # Friendly nix wrappers (pacman/paru-like shortcuts)
      nix() {
        if [[ "$1" == "search" ]]; then
          shift
          if [[ $# -eq 0 ]]; then
            command nix search --help
            return 1
          fi
          # default to nixpkgs when no flake ref is given
          if [[ "$1" == "nixpkgs" || "$1" == *"#"* || "$1" == *":"* || "$1" == .* || "$1" == /* ]]; then
            command nix search "$@"
          else
            command nix search nixpkgs "$@"
          fi
        elif [[ "$1" == "install" ]]; then
          shift
          if [[ $# -eq 0 ]]; then
            echo "Usage: nix install <pkg> [<pkg>...]"
            return 1
          fi
          local pkgs=()
          for p in "$@"; do
            if [[ "$p" == *"#"* || "$p" == *":"* ]]; then
              pkgs+=("$p")
            else
              pkgs+=("nixpkgs#$p")
            fi
          done
          command nix profile install "''${pkgs[@]}"
        else
          command nix "$@"
        fi
      }

      # Quick nix shell: , git curl   or   , git curl -- ls
      ,() {
        if [ $# -eq 0 ]; then
          echo "usage: , <pkg...> [-- <cmd...>]" >&2
          return 2
        fi
        local sep=0
        local -a pkgs=() args=()
        local p
        for p in "$@"; do
          if [ "$p" = "--" ]; then sep=1; continue; fi
          if [ "$sep" -eq 1 ]; then args+=("$p"); else pkgs+=("nixpkgs#$p"); fi
        done
        if [ "''${#args[@]}" -gt 0 ]; then
          nix shell "''${pkgs[@]}" -c "''${args[@]}"
        else
          nix shell "''${pkgs[@]}"
        fi
      }

      # yazi cd-on-quit wrapper: launch with y, quit with q to cd there
      y() {
        local tmp cwd
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        command yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ -d "$cwd" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  programs.zoxide.enable = true;
  programs.starship.enable = true;

  environment.systemPackages = with pkgs; [
    yazi
    fzf
    zoxide
    eza
    bat
  ];
}
