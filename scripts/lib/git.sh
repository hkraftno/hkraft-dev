function git_revision() {
  short_rev="$(git rev-parse --short HEAD)"

  if ! $(git diff-index --quiet HEAD --); then
    echo "${short_rev} (with uncommited changes)"
  else
    echo "${short_rev}"
  fi
}

function git_has_no_uncommited_changes() {
  git diff-index --quiet HEAD --
}

function is_on_branch() {
	expected="$1"
	actual=$(git rev-parse --abbrev-ref HEAD)
	[[ "$actual" == "$expected" ]]
}

function new_changes_upstream() {
  git fetch origin master -q
  
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]; then
      # Up-to-date
      false
  elif [ $LOCAL = $BASE ]; then
      # Need to pull
      true
  elif [ $REMOTE = $BASE ]; then
      # Need to push
      false
  else
      # Diverged
      true
  fi
}
