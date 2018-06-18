#!/bin/bash

#THIS FILE MUST BE RUN AS ROOT
#ADD CONTAINER NAMES TO BELOW LINE TO ADD THEM TO DOCKER LOGGER

docker rm -f docker-logger-container

CONTAINERS=()

DOCKERCONTAINEROUTPUT=$(docker container ls --format "{{.Names}}")

for con in ${DOCKERCONTAINEROUTPUT}
do 
    
    CONTAINERS=(${CONTAINERS[@]} ${con})
done


ARRAY_COUNTER=0
CONTAINERPATHS=()



for NUMBER in ${CONTAINERS[@]}
do
    CONTAINERPATHS[$ARRAY_COUNTER]=$(docker inspect --format='{{.LogPath}}' ${CONTAINERS[$ARRAY_COUNTER]})
    JSONCONTENT=${JSONCONTENT}',"'${CONTAINERS[$ARRAY_COUNTER]}'"'
    DOCKERVOLUMECOMMAND=${DOCKERVOLUMECOMMAND}' -v '${CONTAINERPATHS[$ARRAY_COUNTER]}':/home/node/app/json/'${CONTAINERS[$ARRAY_COUNTER]}'/logs.json'
    ARRAY_COUNTER=$(($ARRAY_COUNTER + 1))
done

echo '['${JSONCONTENT:1}']' > ./app/json/containers.json

docker run -it -v $(pwd)/app:/home/node/app ${DOCKERVOLUMECOMMAND} -p 706:706 --name docker-logger-container docker-logger http-server -d false --push-state --cors -p 706
