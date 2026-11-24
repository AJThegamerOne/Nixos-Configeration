{ ... }:
{
  environment.etc."xdg/ghostty/config".text = ''
    # TokyoNight Storm palette
    background = #24283b
    foreground = #c0caf5
    background-opacity = 0.88
    background-blur = true
    cursor-color = #c0caf5
    cursor-text = #24283b
    cursor-style = bar
    cursor-style-blink = true
    selection-background = #364a82
    selection-foreground = #c0caf5

    # Padding / window feel
    window-padding-x = 10
    window-padding-y = 8
    window-padding-balance = true

    # Maple Mono NF / Nerd Font fallback if available
    font-size = 11.5
  '';
}
