#!/bin/bash

###########################################################
# Script to update all git repositories in current folder #
#                                                         #
# v0.5                                                    #
# By Killian Kemps                                        #
# Contributors: Pascal Duez, William Zhang                #
###########################################################

list=`ls -d */`
force_yes=false

# Store user argument to force all repo update
while :;
do
  case $1
    in
    -f|--force-yes) force_yes=true;;
    -p|--prune-remote) prune_remote=true;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *) break
  esac
  shift
done

function update {
  printf "\n------> Updating '$Dir'"
  cd $Dir
  git stash > /tmp/repoUpdate
  editedFiles=`cat /tmp/repoUpdate`
  printf "\n"
  echo $editedFiles
  # git pull --rebase
  git fetch --all

  hasmaster=`git branch | grep -w "master"`
  hasmain=`git branch | grep -w "main"`
  remote=`git remote | grep -w "upstream"`

  if [ -z "$remote" ] ; then
    printf "Has not upstream remote.\n"
    remote="origin"
  fi

  if [ -n "$hasmaster" ] ; then
    printf "Has master branch.\n"
    git checkout master
    git rebase $remote/master
  elif [ -n "$hasmain" ] ; then
    printf "Has main branch.\n"
    git checkout main
    git rebase $remote/main
  fi

  if [ "$prune_remote" = true ] ; then
    git remote update --prune
  fi
  git checkout -
  if [[ $editedFiles != *"No local changes to save"* ]]
  then
    git stash pop
  fi
  cd -
  printf "<------------------------------------>\n\n"
}

for Dir in $list
do
  while true
  do
    # Check if the folder is a git repo
    if [[ -d "${Dir}/.git" ]]; then

      # Update without prompt if yes forced
      if [ "$force_yes" = true ] ; then
        update
        break;
      # Otherwise prompt user asking for repo update
      else
        read -p "Update $Dir? [y/n/q] " answer

        case $answer in
          [yY]* ) update
            break;;

          [nN]* ) break;;

          [qQ]* ) exit;;

          * )  echo "Enter Y, N or Q, please.";;
        esac
      fi
    else
      break
    fi
  done
done
