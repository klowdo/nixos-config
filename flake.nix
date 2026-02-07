{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware helpers
    hardware.url = "github:nixos/nixos-hardware";

    # Disko - Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland
    # hyprlock = {
    #   url = "github:hyprwm/hyprlock";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # hyprland.url = "github:hyprwm/Hyprland";

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ashell = {
      url = "github:MalpenZibo/ashell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprdynamicmonitors = {
      url = "github:fiffeek/hyprdynamicmonitors";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kixvim.url = "github:klowdo/kixvim";

    # Secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nsearch = {
      url = "github:niksingh710/nsearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-webapps.url = "github:TLATER/nix-webapps?ref=tlater/idiomatic-flake";

    # JetBrains plugins
    nix-jetbrains-plugins = {
      url = "github:nix-community/nix-jetbrains-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Theming
    catppuccin.url = "github:catppuccin/nix";
    stylix.url = "github:danth/stylix/release-25.11";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux"];
    # Thanks Misterio77
    lib = (nixpkgs.lib // home-manager.lib).extend (_self: _super: {custom = import ./lib {inherit (nixpkgs) lib;};});
    forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});

    # Checks - includes pre-commit hooks for `nix flake check`
    checks = forEachSystem (pkgs: import ./checks.nix {inherit inputs pkgs;});

    # Dev shells - inherits pre-commit hooks from checks
    devShells = forEachSystem (pkgs:
      import ./shells.nix {
        inherit pkgs;
        inherit (self.checks.${pkgs.stdenv.hostPlatform.system}) pre-commit-check;
      });

    # Formatter for your nix files, available through 'nix fmt'
    formatter = forEachSystem (pkgs: pkgs.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    homeModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      dellicious = nixpkgs.lib.nixosSystem {
        # inherit specialArgs;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <

          # stylix.nixosModules.stylix
          # ./nixos/configuration.nix
          ./hosts/dellicious
        ];
      };

      virt-nix = nixpkgs.lib.nixosSystem {
        # inherit specialArgs;
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./hosts/virt-nix
        ];
      };

      # Installation ISO with disko and tools pre-configured (graphical - default)
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/iso
        ];
      };

      # Minimal installation ISO (CLI only)
      iso-minimal = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/iso/minimal.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "klowdo@dellicious" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home/klowdo/dellicious.nix
        ];
      };
      "klowdo@virt-nix" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/klowdo/virt-nix.nix
        ];
      };
    };
  };
}
