IMAGE = jam7/centos7-ve-llvm-build

.PHONY: all clean verify

all: build

build: Dockerfile
	docker build -t $(IMAGE) .

verify: build
	docker run --rm $(IMAGE) g++ --version
	docker run --rm $(IMAGE) cmake --version
	docker run --rm $(IMAGE) mold --version
	docker run --rm $(IMAGE) /opt/nec/ve/bin/nas --version
	docker run --rm $(IMAGE) /opt/nec/ve/bin/nld --version
	docker run --rm $(IMAGE) ls /opt/nec/ve/include/asm/
	docker run --rm $(IMAGE) ls /opt/nec/ve/lib/

clean:
	docker rmi $(IMAGE)
