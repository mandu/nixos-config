# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## NixOS Configuration Repository

### Build Commands
- `nixos-rebuild switch` - Rebuild and apply system configuration
- `darwin-rebuild switch` - Rebuild and apply macOS configuration 
- `nix flake update` - Update flake inputs
- `nix flake check` - Verify flake configuration

### Code Style Guidelines
- Use 2-space indentation for all Nix files
- Follow declarative configuration style
- Organize configurations into modules
- Separate system-specific and shared components
- Keep package lists alphabetized where possible
- Prefer explicit imports over using wildcards
- Use descriptive naming for modules and options
- Comment complex configuration sections
- Create separate modules for related functionality
- Maintain consistent structure between different system configurations

### System Organization
- `/modules/` - Shared configuration modules
- `/systems/` - System-specific configurations
- `/hardware-configurations/` - Hardware-specific settings
- `/dotfiles/` - Configuration files for various applications