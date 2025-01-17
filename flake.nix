{
  description = "NixOS Configuration of Vincenzo Pace";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org/"
      "https://hyprland.cachix.org"
      "https://helix.cachix.org"
    ];

    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    sops-nix.url = "github:Mic92/sops-nix"; # secret management
    disko.url = "github:nix-community/disko"; # declarative partitioning
    hosts.url = "github:StevenBlack/hosts"; # block unwanted websites
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; # Modern tiling window manager
    nil.url = "github:oxalica/nil"; # nix lsp
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      hyprland,
      disko,
      hosts,
      sops-nix,
      nil,
      ...
    }@inputs:
    let
      # Declare some user variables
      username = "marius";
      fullName = "Marius Respondek";
      mail = "respondek@amiconsult.de";

      # Desktop specific modules and settings
      commonNixosModules = [
        ./configuration.nix
        ./modules/desktop.nix
        ./hosts/desktop/common.nix
        hosts.nixosModule
        {
          networking.stevenBlackHosts.enable = true;
          networking.stevenBlackHosts = {
            blockFakenews = true;
            blockGambling = true;
            blockPorn = true;
            blockSocial = true;
          };
        }
        { programs.hyprland.enable = true; }
        hyprland.nixosModules.default
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          environment.systemPackages = [ inputs.nil ];
        }
        {
          home-manager.extraSpecialArgs = {
            inherit username mail fullName;
          };
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "backup";
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home.nix;
        }
      ];

      # Build a system based on the commonNixosModules and stable branch
      makeNixosSystem =
        hostName:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs username;
            nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
          };
          modules = commonNixosModules ++ [ ./hosts/desktop/${hostName}.nix ];
        };
    in
    {
      nixosConfigurations = {
        asgar = makeNixosSystem "asgar";
        valnar = makeNixosSystem "valnar";
        dracula = makeNixosSystem "dracula";
	nixsilden = makeNixosSystem "nixsilden";

        #Server
        alucard = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/server/alucard.nix ];
        };
      };
    };
}
