{
  config,
  lib,
  ...
}:
let
  genScript = import ./gen-script.nix;
  dirs = lib.flatten (
    lib.mapAttrsToList (name: value: value.directories) config.environment.persistence
  );
  files = lib.flatten (lib.mapAttrsToList (name: value: value.files) config.environment.persistence);

  script = genScript {
    inherit
      lib
      dirs
      files
      ;
  };
in
{
  system.activationScripts.persist-files.deps = [ "persist-retro" ];
  system.activationScripts.persist-retro = {
    text = ''
      _status=0
      trap "_status=1" ERR
      ${script}
      exit $_status
    '';
    deps = [ "createPersistentStorageDirs" ];
  };
}
