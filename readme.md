# NixOS Configuration

![NixOS](https://img.shields.io/badge/NixOS-configuration-blue?logo=nixos)
![NH](https://img.shields.io/badge/Built%20with-NH-blueviolet)
![License](https://img.shields.io/badge/license-MIT-green) 

Welcome to my **NixOS configuration**! This repository manages my declarative NixOS setup, optimized with [NH](https://github.com/viperML/nh) for easy management. Inspired by clean, modular designs like [Misterio77's](https://github.com/Misterio77/nix-config).

## 🚀 Installation

Ensure you have Nix installed. Then clone this repository:

```bash
git clone https://github.com/klowdo/nixos-config.git
cd nixos-config
```

With NH, managing configurations is simple:

```bash
nh os switch
```

## 📦 Configuration Structure

```plaintext
.
├── hosts/
├── modules/
├── users/
├── flake.nix
└── flake.lock
```

- **hosts/**: Definitions for each machine.
- **modules/**: Custom NixOS modules.
- **users/**: User-specific configurations.
- **flake.nix**: Entry point for the configuration.

## 🖥️ Hosts

Each host has tailored settings. Examples:

- **desktop**: High-performance settings for daily work.
- **laptop**: Power-optimized with battery tweaks.
- **server**: Headless, minimal, and secure.

## 👤 Users

Modular user profiles for flexibility:

- **klowdo**: Main user with personalized settings.
- **guest**: Minimalist setup for occasional use.

## 🔧 Tools

Core tools included:

- **nixpkgs**: Software packages.
- **home-manager**: User environment management.
- **NH**: Simplified NixOS management.
- **direnv + nix-direnv**: Shell environment automation.

## 🗔 Window Manager Specific Tools

Optimized for productivity with **Hyprland**:

- **Hyprland**: Dynamic tiling Wayland compositor.
- **Waybar**: Highly customizable status bar.
- **Wlogout**: Graphical session logout menu.
- **Grim & Slurp**: Screenshot utilities for Wayland.

## 📸 Screenshots

*Add screenshots here to showcase your setup!*

## 📜 License

This project is licensed under the MIT License.

---

*Inspired by the NixOS community and modular configuration principles.*


