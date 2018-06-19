FROM node:9.4.0
WORKDIR /home/node/app
EXPOSE 706
RUN npm install -g spa-http-server
RUN npm install -g @angular/cli
RUN wget https://github.com/emcrisostomo/fswatch/releases/download/1.11.3/fswatch-1.11.3.tar.gz
RUN apt-get update
RUN apt-get install build-essential
RUN tar -xvzf fswatch-1.11.3.tar.gz
RUN pwd
RUN /home/node/app/fswatch-1.11.3/configure && make && make install
RUN ldconfig