FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git bash openjdk11-jre curl

WORKDIR /app

COPY . .

RUN go mod init battery-historian || true
RUN go mod tidy || true

RUN mkdir -p third_party/closure-compiler && \
    curl -L -o third_party/closure-compiler/compiler.jar \
    https://repo1.maven.org/maven2/com/google/javascript/closure-compiler/v20240317/closure-compiler-v20240317.jar

RUN mkdir -p compiled && \
    java -jar third_party/closure-compiler/compiler.jar \
      --compilation_level SIMPLE_OPTIMIZATIONS \
      --js src/js/*.js \
      --js_output_file compiled/historian-optimized.js

RUN go build -o /battery-historian ./cmd/battery-historian

###

FROM alpine:3.19

RUN apk add --no-cache bash openjdk11-jre

WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /battery-historian /battery-historian

EXPOSE 9999

CMD ["/battery-historian", "-port", "9999"]
