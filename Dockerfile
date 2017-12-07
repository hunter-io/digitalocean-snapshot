FROM alpine:3.6

RUN apk update && \
  apk add --update \
    bash \
    curl \
    ca-certificates

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
