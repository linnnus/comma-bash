#!@zsh@/bin/zsh

if [ $# -lt 1 ]; then
	echo >&2 "Usage: $0 program [args...]"
	exit 1
fi

program=$1

# Find all packages that contain the binary we're trying to run, discarding
# "meta" packages that just wrap other programs (currently just cope).
IFS=$'\n' derivations=( $(@nix-index@/bin/nix-locate --top-level --minimal --whole-name /bin/$program |
                          @toybox@/bin/grep -v '^cope.out$') )

case ${#derivations[@]} in
	0)
		echo >&2 "Executable '$program' not found in database"
		exit 1
		;;
	1)
		derivation=${derivations[1]}
		;;
	*)
		derivation=$(printf '%s\n' ${derivations[@]} | @fzy@/bin/fzy)
		;;
esac

# TODO: The official comma uses -f <nixpkgs> if it is defined in path. We should do that too, depending on the behavior of nix-index.
@nix@/bin/nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#${derivation} --command "$@"
