# HyprlandBorgRice: The Ultimate Assimilation

Welcome to the **HyprlandBorgRice** project. This repository is a meticulously curated environment for Hyprland, designed for peak performance on **Ryzen 5000 / AMD RX 6000** series hardware and optimized for **CachyOS**.

## Project Philosophy
We don't just "rice." We **assimilate**. This project takes the finest UI/UX patterns from the Linux community and integrates them into a unified, high-performance ecosystem.

### Key Components
- **[Ilyamiro-Inspired](./Ilyamiro-Inspired)**: Focuses on raw speed, fluid animations, and a minimalist, industrial feel.
- **[MaterialBorg](./MaterialBorg)**: Focuses on premium aesthetics, Material You color adaptation, and a vibrant desktop experience.
- **[BorgBrandBook](./BorgBrandBook)**: The definitive guide to the Borg visual identity, personality, and design tokens.
- **[Dependencies](./dependencies)**: Local clones of all critical tools for offline modification and improvement.

## Performance Optimization (Assimilated Tweaks)

### Ryzen 5000 Series (AMD)
- **BIOS Level**: PBO + Curve Optimizer (Negative -20 offset recommended).
- **Governor**: Set to `performance` via `power-profiles-daemon`.
- **Latency**: `misc:vfr = true` enabled in all configs to minimize frame submission overhead.

### CachyOS Specifics
- **Kernel Manager**: Use `sched-ext` with the `scx_lavd` or `scx_bpfland` schedulers for gaming/latency-critical tasks.
- **Microcode**: `amd-ucode` is pre-baked and required for stability.

## Core Dependencies (The "Extras")
These tools are integrated into both configurations:
- **Sherlock**: Advanced system search and discovery.
- **Kando**: Infinite pie menus for rapid navigation.
- **HyprMod**: Dynamic config management.
- **HyprWhspr**: Voice-to-note recording for the "Neural Link."
- **AI Quota Waybar**: Real-time tracking of AI consumption.

---
*Resistance is futile. Your desktop will be optimized.*
