FROM golang:1.11.5 AS builder

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

WORKDIR /src

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN go build -a -installsuffix cgo -o /bin/app .



FROM alpine:latest
RUN apk --no-cache add ca-certificates && \
  update-ca-certificates

RUN addgroup -g 1001 appgroup && \
  adduser -H -D -s /bin/false -G appgroup -u 1001 appuser

RUN mkdir -p /var/run/secrets/vaultproject.io/ && \
  chown -R 1001:1001 /var/run/secrets/vaultproject.io/

USER 1001:1001
COPY --from=builder /bin/app /bin/app
CMD ["/bin/app"]
