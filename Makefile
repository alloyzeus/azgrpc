
WORKDIR = /build
OUTPUT_BASE_DIR = generated
# used by other targets
GO_PROTOC_IMAGE ?= protoc-go

.PHONY: all clean fmt lint \
	proto-zip \
	proto-go _protoc-go

all: proto-zip proto-go

fmt: _protoc-go
	@echo "Formatting .proto files..."
	@docker run --rm \
		-v $(CURDIR):$(WORKDIR) \
		--workdir=$(WORKDIR)/azgrpc \
		$(GO_PROTOC_IMAGE) \
		prototool format -w
	@echo "Done!"

clean:
	@rm generated/*.zip

lint:
	@echo "Running lint..."
	@docker run --rm \
		-v $(CURDIR):$(WORKDIR) \
		--workdir $(WORKDIR) \
		bufbuild/buf \
		check lint
	@echo "Done!"


PROTO_OUT_DIR=$(OUTPUT_BASE_DIR)/$(WORKDIR)
proto-zip:
	$(eval SHORT_REV := $(shell git rev-parse HEAD | cut -c 1-7))
	@docker run --rm \
		--entrypoint=/bin/sh \
		-v $(CURDIR):$(WORKDIR) \
		$(GO_PROTOC_IMAGE) -c '\
		rm -rf $(WORKDIR)/include/google && \
		mkdir -p $(WORKDIR)/include/google && \
		cp -r "/protobuf/include/google/protobuf" $(WORKDIR)/include/google/protobuf && \
		rm -rf $(WORKDIR)/include/google/protobuf/compiler '
	@zip -r generated/azgrpc-proto-$(SHORT_REV).zip \
		./azgrpc/ ./include/google/ -x "*.DS_Store" > /dev/null


GO_OUT_DIR=$(OUTPUT_BASE_DIR)/go
GO_PROTOC_CMD=protoc \
	--gogofaster_out=plugins=grpc,paths=source_relative,Mgoogle/protobuf/any.proto=github.com/gogo/protobuf/types,Mgoogle/protobuf/duration.proto=github.com/gogo/protobuf/types,Mgoogle/protobuf/struct.proto=github.com/gogo/protobuf/types,Mgoogle/protobuf/timestamp.proto=github.com/gogo/protobuf/types,Mgoogle/protobuf/wrappers.proto=github.com/gogo/protobuf/types:${WORKDIR}/$(GO_OUT_DIR) \
	-I=/protobuf/include \
	-I=$(WORKDIR)
proto-go: _protoc-go
	@echo "Generating Go codes from proto files..."
	@rm -rf $(GO_OUT_DIR)/azgrpc
	@mkdir -p $(GO_OUT_DIR)/azgrpc
	@docker run --rm \
		--entrypoint=/bin/sh \
		-v $(CURDIR):$(WORKDIR) \
		--workdir=/go/src \
		$(GO_PROTOC_IMAGE) -c '\
		$(GO_PROTOC_CMD) $(WORKDIR)/azgrpc/iam/v1/*.proto && \
		$(GO_PROTOC_CMD) $(WORKDIR)/azgrpc/media/v1/*.proto'
	-@git rev-parse HEAD >$(GO_OUT_DIR)/REVISION 2>&1
	$(eval SHORT_REV := $(shell git rev-parse HEAD | cut -c 1-7))
	@zip -r generated/azgrpc-go-$(SHORT_REV).zip \
		./$(GO_OUT_DIR)/ -x "*.DS_Store" > /dev/null

_protoc-go:
	@docker build \
		-t $(GO_PROTOC_IMAGE) \
		-f $(CURDIR)/tools/protoc-go.Dockerfile \
		. > /dev/null
