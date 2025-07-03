{
  config,
  pkgs,
  lib,
  ...
}:
let
  genScript = import ./gen-script.nix;
  dirs = lib.flatten (
    lib.mapAttrsToList (name: value: value.directories) config.environment.persistence
  );
  files = lib.flatten (lib.mapAttrsToList (name: value: value.files) config.environment.persistence);

  fileChecks = genScript {
    inherit
      lib
      dirs
      files
      ;
  };
  script = pkgs.writeShellScript "persist-retro-copy-files" ''
    _status=0
    trap "_status=1" ERR
    ${fileChecks}
    exit $_status
  '';
in
{
  system.activationScripts.persist-files.deps = [ "persist-retro" ];
  system.activationScripts.persist-retro = {
    text = "${script}";
    deps = [ "createPersistentStorageDirs" ];
  };
}
