function input_with_default() {
	## Ask the user for input, and assign to variable.
	## If no input is provided by user, default to value
	## in third argument.

	variable_name="${1}"
	prompt="${2}"
	default="${3}"

	read -p "${prompt} [${default}] " value
	[ -z ${value} ] && value="${default}"
  
	export $variable_name="$value"
}
