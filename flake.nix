{
  description = "Retroactively persist directories with impermanence";

  outputs = inputs: {
    nixosModules.persist-retro = import ./nixos.nix;
  };
}
