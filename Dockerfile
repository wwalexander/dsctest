# Golang minor releases are meant to be backwards-compatible a la Semver, so
# the latest version of Go 1 should be okay. Similarly, the server isn't relying
# on any OS/kernel-specific features, so the latest version of Alpine should
# work. Docker recommends Alpine images as they result in the smallest containers.
FROM golang:1-alpine

WORKDIR /go/src/dsctest
COPY . .

RUN apk add --update-cache git && rm -rf /var/cache/apk/*
RUN go get -d -v github.com/mikeykhalil/fizzbuzz
RUN go install -v github.com/mikeykhalil/fizzbuzz 

# Docker exposes TCP by default, which is what we need for an HTTP server
EXPOSE 4343

CMD ["fizzbuzz", "server"]
