#!/bin/bash

BASE_COMMIT=76c704048f5b1025e5fd21ece5407eff05c68931
BASH="$BASH --norc --noprofile"

BRANCHES=$(git branch --all | grep 'upstream/tp-' | sed -e's/^   //')

git fetch upstream

for B in $BRANCHES; do
  NAME=$(echo $B | sed -e's-.*upstream/tp-tp-')

  #git checkout $B
  COMMITS=$(git log --oneline $B -- drivers/hid/hid-lenovo.c | sed -e's/ .*//')

  if git rev-parse --verify $NAME > /dev/null; then
    git checkout $NAME
  else
    git checkout $BASE_COMMIT -b $NAME
  fi

  FOUND=0
  COMMITS_TO_PULL=()
  C=""
  for C in $COMMITS; do
    if [ $(git diff --stat $C drivers/hid/hid-lenovo.c | wc -l) -gt 0 ]; then
      COMMITS_TO_PULL+=("$C")
      echo
      git log -n 1 $C
      git diff --stat $C drivers/hid/hid-lenovo.c
      continue
    fi
    FOUND=1
    break
  done
  LATEST_COMMIT=$C
  if [ -z "$LATEST_COMMIT" ]; then
    echo "No commits on $NAME!"
    continue
  fi

  if [ $FOUND != 1 ]; then
    echo "No base commit found on $NAME!"
    continue
  fi

  echo "Branch: $NAME"
  echo "Base commit: $LATEST_COMMIT"
  git log -n 1 $LATEST_COMMIT
  git diff --stat $LATEST_COMMIT drivers/hid/hid-lenovo.c
  echo "Commits to pull: "
  declare -p COMMITS_TO_PULL
  echo
  PS1="Do this look good?" $BASH || exit

  for (( idx=${#COMMITS_TO_PULL[@]}-1 ; idx>=0 ; idx-- )) ; do
    C="${COMMITS_TO_PULL[idx]}"
    echo "Cherry picking $C"
    git log -n 1 $C
    git diff --stat $C drivers/hid/hid-lenovo.c

    if git cherry-pick $C; then
      continue
    fi
    PS1="Cherry-pick needs fixing: " $BASH || exit
  done

  echo "Finished $NAME"
  echo "---------------------------------------"

  PS1="Continue? " $BASH || exit

done
echo "All done! "
