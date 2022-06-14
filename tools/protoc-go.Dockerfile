FROM golang:1.18

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /protobuf

RUN wget -q -O protoc-temp.zip \
        https://github.com/protocolbuffers/protobuf/releases/download/v21.1/protoc-21.1-linux-x86_64.zip \
    && unzip -q protoc-temp.zip \
    && rm protoc-temp.zip

WORKDIR /code
RUN go mod init github.com/alloyzeus/go-azgrpc

RUN go get github.com/golang/protobuf/protoc-gen-go
RUN go install github.com/golang/protobuf/protoc-gen-go

RUN go get github.com/gogo/protobuf/protoc-gen-gogofaster
RUN go install github.com/gogo/protobuf/protoc-gen-gogofaster

RUN go get github.com/uber/prototool/cmd/prototool
RUN go install github.com/uber/prototool/cmd/prototool

WORKDIR /go
RUN rm -rf /code

ENV PATH="/protobuf/bin:${PATH}"
