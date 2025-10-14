FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY . .

RUN go mod init battery-historian || true
RUN go mod tidy || true

RUN go build -o battery-historian ./cmd/battery-historian

FROM alpine:3.19

RUN apk add --no-cache bash

WORKDIR /app
COPY --from=builder /app /app

EXPOSE 9999

CMD ["./battery-historian", "-port", "9999"]
