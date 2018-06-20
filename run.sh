#!/bin/bash

#THIS FILE MUST BE RUN AS ROOT
#ADD CONTAINER NAMES TO BELOW LINE TO ADD THEM TO DOCKER LOGGER

docker rm -f docker-logger-container
rm -r $(pwd)/app

mkdir $(pwd)/app

mkdir $(pwd)/app/json

CONTAINERS=()

DOCKERCONTAINEROUTPUT=$(docker container ls --format "{{.Names}}")

for con in ${DOCKERCONTAINEROUTPUT}
do 
    
    CONTAINERS=(${CONTAINERS[@]} ${con})
done


ARRAY_COUNTER=0
CONTAINERPATHS=()

# FOR FUTURE COMMIT CHECKING https://api.github.com/repos/pedroness/Docker-Logger/commits

for NUMBER in ${CONTAINERS[@]}
do
    CONTAINERPATHS[$ARRAY_COUNTER]=$(docker inspect --format='{{.LogPath}}' ${CONTAINERS[$ARRAY_COUNTER]})
    JSONCONTENT=${JSONCONTENT}',"'${CONTAINERS[$ARRAY_COUNTER]}'"'
    DOCKERVOLUMECOMMAND=${DOCKERVOLUMECOMMAND}' -v '${CONTAINERPATHS[$ARRAY_COUNTER]}':/home/node/app/json/'${CONTAINERS[$ARRAY_COUNTER]}'/logs.json'
    FSCOMMAND=${FSCOMMAND}'fswatch -xr /home/node/app/json/'${CONTAINERS[$ARRAY_COUNTER]}'/logs.json | xargs -I {} curl --header "Content-Type: application/json" --request POST --data {} http://localhost:3000/web & '
    ARRAY_COUNTER=$(($ARRAY_COUNTER + 1))
done


# echo docker exec -itd docker-logger-container bash -c "'"node monitor.js"'"
# echo docker exec -it docker-logger-container bash -c "'"${FSCOMMAND::-3}"'"
echo docker exec -itd docker-logger-container bash -c "'"node monitor.js"'" >> ./fswatch.sh
echo docker exec -it docker-logger-container bash -c "'"${FSCOMMAND::-3}"'" >> ./fswatch.sh
chmod +x fswatch.sh
docker run -itd -v $(pwd)/app/json:/home/node/app/json ${DOCKERVOLUMECOMMAND} -p 706:706 -p 3000:3000 --name docker-logger-container docker-logger http-server -d false --push-state --cors -p 706 
echo '['${JSONCONTENT:1}']'
echo '['${JSONCONTENT:1}']' > ./app/json/containers.json
./fswatch.sh
rm ./fswatch.sh