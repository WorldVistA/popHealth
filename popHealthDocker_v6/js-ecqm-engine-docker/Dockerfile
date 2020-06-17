FROM node:10.0-slim

ENV NODE_ENV production

RUN apt-get update
RUN apt-get install -y git

WORKDIR /tmp
RUN git clone https://github.com/WorldVistA/js-ecqm-engine.git
RUN cp -R js-ecqm-engine /usr/src/app
RUN rm -rf /tmp/js-ecqm-engine
RUN ls /usr/src/app

WORKDIR /usr/src/app

RUN yarn install --only=production

RUN chmod 755 bin/rabbit_worker.js

CMD [ "bin/rabbit_worker.js"]
