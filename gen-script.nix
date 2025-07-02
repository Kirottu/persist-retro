{
  lib,
  dirs,
  files,
}:

lib.concatStrings (
  lib.flatten [
    ''
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


      if [ -n "$(ls -A '${dir.dirPath}' 2>/dev/null)" ] && ! findmnt "${dir.dirPath}" >/dev/null; then
        # Copy files in archive and update mode, updating any possibly existing files
        # and preserving permissions
        printf "Found existing contents of target directory '%s', copying to persistent location '%s'.\n" "${dir.dirPath}" "${dir.persistentStoragePath}${dir.dirPath}"
        cp -au "${dir.dirPath}/"* "${dir.persistentStoragePath}${dir.dirPath}/"
        chown -R "${dir.user}:${dir.group}" "${dir.persistentStoragePath}${dir.dirPath}"
      fi

    '') dirs)
    (builtins.map (file: ''
      # Check if file is a normal file. This will also exclude symlinks so any files
      # created by impermanence as well
      #
      # TODO: Maybe consider dealing with symlinks properly

      if [ -f "${file.filePath}" ] && ! [ -L "${file.filePath}" ] && ! findmnt "${file.filePath}" >/dev/null; then
        printf "Found existing file at '%s', copied to persistent location '%s'.\n" "${file.filePath}" "${file.persistentStoragePath}${file.filePath}"
        cp -au "${file.filePath}" "${file.persistentStoragePath}${file.filePath}"
        rm -f "${file.filePath}"
        chown "${file.parentDirectory.user}:${file.parentDirectory.group}" "${file.persistentStoragePath}${file.filePath}"
      fi

    '') files)
  ]
)
