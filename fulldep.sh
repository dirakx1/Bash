#!/bin/bash

LOCKFILE="/tmp/${PWD##*/}_deploy.lock"

## NICE COLOR AND UTF8
GREENCHECK="\e[32m\e[1m\u2713\e[0m\e[39m"
GREENOK="\e[32mOK\e[39m"
REDCROSS="\e[91m\e[1m\u274C\e[0m\e[39m"
REDERROR="\e[91mERROR\e[39m"
SOURCEDIR=""

if [[ "$1" == "test" ]]; then
 BRANCH="devel"
 COMPOSEFILE="docker-compose-test.yml"
 ENV="test"
elif [[ "$1" == "prod" ]]; then
 BRANCH="master"
 COMPOSEFILE="docker-compose.yml"
 ENV="prod"
else
        echo "[ERROR] You must provide deploy mode 'test' or 'prod'"
        echo "Usage: $0 test   -or-   $0 prod"
        exit
fi

if [ -f ${LOCKFILE} ]; then
    echo "[${REDERROR}] Another deploy is already in progress, please wait. Quitting."
    exit -1
fi


function check_if_docker_folder()
{
        if [[ ! -f ${COMPOSEFILE} ]]; then
                echo -e "[${REDERROR}] Can not find config file '${COMPOSEFILE}' in the current directory. Quitting."
                exit
        fi
 DOCKERFILEDIR=$(pwd)
}


function get_source_folder()
{
        echo -en "[INFO] Detecting source folder for project \e[1m${PWD##*/}\e[0m..."
        SOURCEDIR=$(cat ${COMPOSEFILE} | grep ":/app/$" | sort | uniq | cut -d':' -f1 | cut -d'-' -f2- | sed 's%^ *%%g')
        if [[ ! -f "${SOURCEDIR}/manage.py" ]]; then
                echo -e "[${REDERROR}]\n\t > Can't autodetect source directory ! Quitting."
                exit
        fi
        echo -e " [${GREENOK}]  (${SOURCEDIR})"
}


function ask_to_continue_or_quit()
{
  read -p "Are you sure to continue ? [y/n] " -n 1 -r
  echo
  if [[ ${REPLY} =~ ^[Nn]$ ]]; then
   echo "Bye!"
   exit
  fi
}


function check_server()
{
  if [[ ${ENV} == "test" ]] && [[ ! $(hostname) =~ "TEST" ]]; then
     echo -e "[${REDERROR}] You asked for 'TEST' deploy, but it looks like you are on PROD server."
     ask_to_continue_or_quit
  fi
  if [[ ${ENV} == "prod" ]] && [[ $(hostname) =~ "TEST" ]]; then
     echo -e "[${REDERROR}] You asked for 'PROD' deploy, but it looks like you are on TEST server."
     ask_to_continue_or_quit
  fi
}



function update_source()
{
           echo "[INFO] Updating local .ssh/config file..."
           mkdir -p /root/.ssh
           mv /root/.ssh/config /root/.ssh/config.original 2>/dev/null
           echo "Host gitlab.com"   >  /root/.ssh/config   && \
           echo "    StrictHostKeyChecking no"     >> /root/.ssh/config    && \
           echo "    UserKnownHostsFile /dev/null" >> /root/.ssh/config    && \
           echo "    IdentityFile gitlab_deploy_key" >> /root/.ssh/config
           chmod 600 gitlab_deploy_key

    echo "[INFO] Updating source from $BRANCH branch..."
    cd $SOURCEDIR
    git reset --hard HEAD
    git pull origin $BRANCH

    echo "[INFO] Switching back to original .ssh/config file..."
           rm /root/.ssh/config 2>/dev/null
    mv /root/.ssh/config.original /root/.ssh/config 2>/dev/null
}


function rebuild_requirements()
{
  cd $SOURCEDIR
  echo -n "Checking if an image rebuild is needed..."
  if [[ $(git diff HEAD~1 HEAD -- requirements.txt | wc -l) -ne 0 ]];then
        echo " UPDATE NEEDED!"
        cd ${DOCKERFILEDIR}
        echo -e "[INFO] Updating requirements for project \e[1m${PWD##*/}\e[0m\n"
        TOREBUILD=$(cat ${COMPOSEFILE} | grep -E "^  [[:alpha:]]" | grep -vE "rabbit|postfix|redis|node|mongo" | sed -e 's%:%%g' -e 's% *%%g' | grep django)
        TODELETE=$(cat ${COMPOSEFILE} | grep -E "^  [[:alpha:]]" | grep -vE "rabbit|postfix|redis|node|mongo" | sed -e 's%:%%g' -e 's% *%%g' | grep -v django)
        echo "[INFO] > Rebuilding image : ${TOREBUILD}..."
        docker-compose -f ${COMPOSEFILE} build --no-cache ${TOREBUILD}
        echo "[INFO] > Stopping all running containers..."
        docker-compose -f ${COMPOSEFILE} stop
        echo "[INFO] > Removing all saved snapshots ..."
        docker ps -a | grep -i ${PWD##*/} | grep -i exited | awk '{print $1}' | xargs -i docker rm '{}'
        echo "[INFO] > Deleting all saved images (except the last build) :"
        while read -r line; do
           docker rmi $(docker images | grep "${line} " | awk '{print $1}')
        done <<< "${TODELETE}"
  else
 echo "No changes detected. No need to rebuild!"
  fi
}

function restart_docker()
{
 cd ${DOCKERFILEDIR} &&\
 full_restart $ENV
        rm ${LOCKFILE}
}

touch ${LOCKFILE}
check_if_docker_folder
check_server
get_source_folder
update_source
rebuild_requirements
restart_docker
