IMAGE = jam7/centos7-ve-llvm-build
VERSION = $(shell git describe --tags --always)

.PHONY: all build push verify clean

all: build

build: Dockerfile
	docker build -t $(IMAGE):$(VERSION) -t $(IMAGE):latest .

push: build
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

verify: build
	docker run --rm $(IMAGE):$(VERSION) g++ --version
	docker run --rm $(IMAGE):$(VERSION) cmake --version
	docker run --rm $(IMAGE):$(VERSION) mold --version
	docker run --rm $(IMAGE):$(VERSION) /opt/nec/ve/bin/nas --version
	docker run --rm $(IMAGE):$(VERSION) /opt/nec/ve/bin/nld --version
	docker run --rm $(IMAGE):$(VERSION) ls /opt/nec/ve/include/asm/
	docker run --rm $(IMAGE):$(VERSION) ls /opt/nec/ve/lib/

clean:
	docker rmi $(IMAGE):$(VERSION) $(IMAGE):latest
