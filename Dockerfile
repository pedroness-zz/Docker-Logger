FROM node:9.4.0
WORKDIR /home/node/app
EXPOSE 706
RUN npm install -g spa-http-server
RUN npm install -g @angular/cli

