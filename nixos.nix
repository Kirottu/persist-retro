{ config, lib, ... }:
let
  genScript = import ./gen-script.nix;
  dirs = lib.flatten (
    lib.mapAttrsToList (name: value: value.directories) config.environment.persistence
  );
  files = lib.flatten (lib.mapAttrsToList (name: value: value.files) config.environment.persistence);
in
{
  system.activationScripts.persist-files.deps = [ "persist-retro" ];
  system.activationScripts.persist-retro = {
    text = genScript { inherit lib dirs files; };
    deps = [ "createPersistentStorageDirs" ];
  };
}
