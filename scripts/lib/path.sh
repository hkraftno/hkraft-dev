function print_script_dir() {
	# Prints the directory of the script file from which the function is called.

	# find folder script is located in	
	BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

	# resolve symlinks
	while [ -h "$BASEDIR/$0" ]; do
	    DIR=$(dirname -- "$BASEDIR/$0")
	    SYM=$(readlink $BASEDIR/$0)
	    BASEDIR=$(cd $DIR && cd $(dirname -- "$SYM") && pwd)
	done

	# "return" normalized path
	echo "$BASEDIR"
}

function cd_to_directory_with_this_script() {
	cd $(print_script_dir)
}
