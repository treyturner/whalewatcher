FROM docker:20.10.14-dind-alpine3.15

LABEL org.opencontainers.image.source=https://github.com/treyturner/whalewatcher
LABEL org.opencontainers.image.description="whalewatcher"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.authors="treyturner@users.noreply.github.com"

RUN apk add --no-cache bash coreutils docker-compose
WORKDIR /root
COPY ./whalewatcher.sh .
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/root/whalewatcher.sh"]
