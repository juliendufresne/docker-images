FROM node:alpine

LABEL maintainer="Julien Dufresne"

RUN npm install --global \
                    textlint@11.0.* \
                    textlint-rule-no-todo \
                    textlint-rule-no-dead-link \
                    textlint-rule-terminology \
                    textlint-rule-period-in-list-item \
                    @textlint-rule/textlint-rule-no-invalid-control-character \
                    textlint-rule-en-capitalization

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["textlint"]
