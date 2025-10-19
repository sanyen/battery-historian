FROM ubuntu:22.04

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt update

RUN apt install -y --no-install-recommends \
    wget curl git unzip ca-certificates \
    openjdk-8-jre-headless openjdk-8-jdk-headless \
    python2 build-essential
    
RUN ln -sf /usr/bin/python2 /usr/bin/python

RUN rm -rf /var/lib/apt/lists/*

RUN wget https://go.dev/dl/go1.8.3.linux-amd64.tar.gz

RUN tar -C /usr/local -xzf go1.8.3.linux-amd64.tar.gz && rm go1.8.3.linux-amd64.tar.gz

RUN mkdir -p $GOPATH/src/github.com/sanyen/battery-Historian

RUN mkdir -p $GOPATH/src/github.com/golang 

RUN cd $GOPATH/src/github.com/golang && \
    git clone https://github.com/sanyen/glog.git && \
    git clone https://github.com/sanyen/protobuf.git && \
    cd protobuf && git checkout v1.2.0 && \
    cd $GOPATH/src/github.com/golang

WORKDIR $GOPATH/src/github.com/sanyen/battery-historian

COPY . .

RUN go run setup.go

RUN go install ./cmd/battery-historian

EXPOSE 9999

CMD ["battery-historian", "-port", "9999"]
