FROM alpine:latest

LABEL version="1.0.0"
LABEL repository="http://github.com/dz0ny/on-command"
LABEL homepage="http://github.com/dz0ny/on-command"
LABEL maintainer="Janez Troha"
LABEL "com.github.actions.name"="Filters for Comment commands"
LABEL "com.github.actions.description"="Common filters to stop exceution if command in comment is not present"
LABEL "com.github.actions.icon"="filter"
LABEL "com.github.actions.color"="gray-dark"

RUN apk --no-cache add jq bash

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
