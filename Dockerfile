FROM golang:1.18

RUN useradd -u 1001 -U nonroot
USER nonroot

WORKDIR /home/nonroot

COPY challenge ./
COPY go.mod go.sum ./

RUN go mod download \
    && rm go.mod go.sum

EXPOSE 8080

CMD ["./challenge"]
