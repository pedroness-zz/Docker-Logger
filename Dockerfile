FROM node:9.4.0
WORKDIR /home/node/app
EXPOSE 706
RUN npm i npm@6.1.0 -g
RUN npm install -g spa-http-server
RUN npm install -g --no-optional @angular/cli
RUN wget https://github.com/emcrisostomo/fswatch/releases/download/1.11.3/fswatch-1.11.3.tar.gz
RUN apt-get update
RUN apt-get install build-essential
RUN apt-get install unzip
RUN apt-get -y install rsync
RUN tar -xvzf fswatch-1.11.3.tar.gz
RUN cd /home/node/app/fswatch-1.11.3 && ./configure && make && make install && ldconfig
RUN wget https://github.com/pedroness/Docker-Logger-Front-End/archive/master.zip
RUN unzip master
RUN cd Docker-Logger-Front-End-master && npm install && ng build --prod
RUN cp -R /home/node/app/Docker-Logger-Front-End-master/dist/docker-logger/* /home/node/app
RUN rm -r /home/node/app/fswatch-1.11.3
RUN rm master.zip
RUN npm install socket.io
RUN rm fswatch-1.11.3.tar.gz
RUN rm -r  /home/node/app/Docker-Logger-Front-End-master
RUN chmod +x ./monitor.js
CMD node ./monitor.js
