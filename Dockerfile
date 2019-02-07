FROM golang:1.11.5 AS builder
WORKDIR /go/src/app
ADD . .
RUN \
  CGO_ENABLED=0 \
  GOOS=linux \
  GOARCH=amd64 \
  go build -a -installsuffix cgo -o vault-kubernetes-authenticator .

FROM scratch
ADD https://curl.haxx.se/ca/cacert.pem /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/src/app/vault-kubernetes-authenticator /
CMD ["/vault-kubernetes-authenticator"]
