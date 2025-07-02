{
  lib,
  dirs,
  files,
}:
lib.concatStrings (
  lib.flatten [
    ''
      #!/usr/bin/env bash

      set -o nounset            # Fail on use of unset variable.
      set -o errexit            # Exit on command failure.
      set -o pipefail           # Exit on failure of any command in a pipeline.
      set -o errtrace           # Trap errors in functions and subshells.
      shopt -s inherit_errexit  # Inherit the errexit option status in subshells.

      trap 'echo Error when executing $BASH_COMMAND at line $LINENO! >&2' ERR

    ''
    (builtins.map (dir: ''
      # Check if existing directory exists and has files in it
      # Also verify that it is not a mountpoint since that would most
      # likely mean it is already correctly managed by impermanence
      if [ -n "$(ls -A '${dir.dirPath}' 2>/dev/null)" ] && $(mountpoint -q --nofollow "${dir.dirPath}"); then
        # Copy files in archive and update mode, updating any possibly existing files
        # and preserving permissions
        cp -au "${dir.dirPath}/*" "${dir.persistentStoragePath}/${dir.dirPath}/"
      fi
    '') dirs)
    (builtins.map (file: ''

    '') files)
  ]
)
