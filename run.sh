#!/bin/bash

#THIS FILE MUST BE RUN AS ROOT
#ADD CONTAINER NAMES TO BELOW LINE TO ADD THEM TO DOCKER LOGGER

docker rm -f docker-logger-container
rm -r $(pwd)/app/json

mkdir $(pwd)/app/json
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
    FSCOMMAND=${FSCOMMAND}'fswatch -xr /home/node/app/json/'${CONTAINERS[$ARRAY_COUNTER]}'/logs.json | xargs -I {}  node /home/node/app/monitor.js {} & '
    ARRAY_COUNTER=$(($ARRAY_COUNTER + 1))
done

echo '['${JSONCONTENT:1}']' > ./app/json/containers.json
echo docker exec -it docker-logger-container bash -c "'"${FSCOMMAND::-3}"'" >> fswatch.sh
chmod +x fswatch.sh
docker run -itd -v $(pwd)/app:/home/node/app ${DOCKERVOLUMECOMMAND} -p 706:706 --name docker-logger-container docker-logger http-server -d false --push-state --cors -p 706 
./fswatch.sh
rm fswatch.sh
