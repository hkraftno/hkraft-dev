function bold() {
  printf '\033[1;m%s\e[m\n' "${1}"
}

function info() {
  printf '\033[0;32m%s\e[m\n' "${1}"
}

function error() {
  printf '\033[0;31m%s\e[m\n' "${1}"
}

function warn() {
  printf '\033[1;33m%s\e[m\n' "${1}"
}
