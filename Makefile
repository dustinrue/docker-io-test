all:
	$(MAKE) clean
	$(MAKE) build
	@sleep 5
	$(MAKE) test

test:
	@echo "\nTesting host"
	cd files; echo "extract"; time tar zxf latest.tar.gz; echo "tar"; time tar cf /dev/null wordpress; rm -rf wordpress; cd -
	@echo "\n\nTesting docker volume"
	docker volume create iotest-files
	docker run --rm -ti -v $(shell pwd)/files:/source -v iotest-files:/iotest iotest:latest bash -c "cd /iotest; cp /source/latest.tar.gz .; rm -rf wordpress; echo "extract"; time tar zxf latest.tar.gz; echo "compress"; time tar cf /dev/null wordpress"
	docker volume rm iotest-files
	@echo "\n\nTesting bind mount, no cache:"
	docker run --rm -ti -v $(shell pwd)/files:/iotest iotest:latest bash -c "cd /iotest; rm -rf wordpress; echo "extract"; time tar zxf latest.tar.gz; echo "compress"; time tar cf /dev/null wordpress"
	@echo "\n\nTesting bind mount, cache:"
	docker run --rm -ti -v $(shell pwd)/files:/iotest:cached iotest:latest bash -c "cd /iotest; rm -rf wordpress; echo "extract"; time tar zxf latest.tar.gz; echo "compress"; time tar cf /dev/null wordpress"
	@echo "\n\nTesting bind mount, delegated:"
	docker run --rm -ti -v $(shell pwd)/files:/iotest:delegated iotest:latest bash -c "cd /iotest; rm -rf wordpress; echo "extract"; time tar zxf latest.tar.gz; echo "compress"; time tar cf /dev/null wordpress"
build:
	docker build . -t iotest

clean:
	rm -rf files/wordpress
	docker image rm iotest:latest
