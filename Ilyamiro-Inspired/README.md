# Ilyamiro-Inspired Config

This configuration profile is a heavily optimized adaptation of [ilyamiro's imperative-dots](https://github.com/ilyamiro/imperative-dots). It is designed for users who prioritize speed, minimal visual noise, and high-refresh-rate fluidity.

## Credits & Inspiration
- **Original Author**: [ilyamiro](https://github.com/ilyamiro)
- **Modifications**: Ported to Borg standards, optimized for Ryzen 5000/AMD RX 6000, and integrated with the Borg dependency suite.

## What's Different?
1.  **Borg Extras**: Unlike the default setup, this version is pre-integrated with:
    - `Sherlock` (Search)
    - `Kando` (Pie Menus)
    - `HyprWhspr` (Voice Notes)
    - `AI-Quota-Waybar`
2.  **Hardware Optimization**: Tuned specifically for a **3440×1440 @ 165Hz** ultrawide display.
3.  **No Borders/No Shadows**: Every millisecond and pixel is reclaimed for performance. The "rounding = 4" provides just enough softness to look premium without the performance hit of heavy blur/shadows.
4.  **Borg Animation Bezier**: A custom fast-popin animation that feels industrial and assertive.

## Setup
Simply run `install.sh` inside this directory to apply the configuration. 
> [!IMPORTANT]
> Ensure you are on a Wayland-native environment for the best experience.
