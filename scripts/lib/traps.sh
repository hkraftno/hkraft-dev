# appends a command to a trap
#
# - 1st arg:  code to add
# - remaining args:  names of traps to modify
#
# source: https://stackoverflow.com/a/7287873
trap_add() {
	# note: printf is used instead of echo to avoid backslash
	# processing and to properly handle values that begin with a '-'.
	_trap_add_log() { printf '%s\n' "$*"; }
	_trap_add_error() { _trap_add_log "ERROR: $*" >&2; }
	_trap_add_fatal() { _trap_add_error "$@"; exit 1; }

    trap_add_cmd=$1; shift || _trap_add_fatal "${FUNCNAME} usage error"
    for trap_add_name in "$@"; do
        trap -- "$(
            # helper fn to get existing trap command from output
            # of trap -p
            extract_trap_cmd() { printf '%s\n' "$3"; }
            # print existing trap command with newline
            eval "extract_trap_cmd $(trap -p "${trap_add_name}")"
            # print the new trap command
            printf '%s\n' "${trap_add_cmd}"
        )" "${trap_add_name}" \
            || _trap_add_fatal "unable to add to trap ${trap_add_name}"
    done
}
# set the trace attribute for the above function.  this is
# required to modify DEBUG or RETURN traps because functions don't
# inherit them unless the trace attribute is set
declare -f -t trap_add
