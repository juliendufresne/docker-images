# shellcheck disable=SC2148
FROM node:alpine

LABEL maintainer="Julien Dufresne"

RUN yarn global add prettier@1.14.3 --tilde

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["prettier"]
