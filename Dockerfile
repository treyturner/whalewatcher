FROM docker:20.10.14-dind-alpine3.15

RUN apk add --no-cache bash coreutils docker-compose
WORKDIR /root
COPY ./whalewatcher.sh .
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/root/whalewatcher.sh"]
