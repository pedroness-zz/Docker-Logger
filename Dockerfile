FROM node:9.4.0
WORKDIR /home/node/app
EXPOSE 706
RUN npm i npm@6.1.0 -g
RUN npm install -g spa-http-server
RUN npm install -g --no-optional @angular/cli
RUN npm install pm2 -g
RUN wget https://github.com/emcrisostomo/fswatch/releases/download/1.11.3/fswatch-1.11.3.tar.gz
RUN apt-get update
RUN apt-get install build-essential
RUN apt-get install unzip
RUN apt-get -y install rsync
RUN apt-get -y install nano
RUN tar -xvzf fswatch-1.11.3.tar.gz
RUN cd /home/node/app/fswatch-1.11.3 && ./configure && make && make install && ldconfig
RUN rm -r /home/node/app/fswatch-1.11.3
RUN npm install socket.io
RUN rm fswatch-1.11.3.tar.gz
RUN echo "cd /home/node" >> /home/node/update.sh
RUN echo "wget https://github.com/pedroness/Docker-Logger-Front-End/archive/master.zip" >> /home/node/update.sh
RUN echo "unzip master.zip" >> /home/node/update.sh
RUN echo "cd Docker-Logger-Front-End-master && npm install && ng build --prod" >> /home/node/update.sh
RUN echo "cd /home/node/Docker-Logger-Front-End-master/dist/docker-logger/"
RUN echo "mv /home/node/Docker-Logger-Front-End-master/dist/docker-logger/private /home/node" >> /home/node/update.sh
RUN echo "rsync -ru -v /home/node/Docker-Logger-Front-End-master/dist/docker-logger/. /home/node/app" >> /home/node/update.sh
RUN echo "rm -r /home/node/Docker-Logger-Front-End-master && rm -r /home/node/master.zip" >> /home/node/update.sh
RUN echo "cd /home/node/private && npm install" >> /home/node/update.sh
CMD chmod +x /home/node/update.sh && /home/node/update.sh && node /home/node/private/monitor.js
