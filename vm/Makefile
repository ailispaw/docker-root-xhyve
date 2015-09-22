KERNEL   := bzImage
INITRD   := initrd
CMDLINE  := earlyprintk=serial console=ttyS0 console=tty0 quiet loglevel=3
HDD      := docker-root-data.img
UUID     := A01FB25C-3A19-4759-A47A-2E353E51807D
USERNAME := docker
PASSWORD := docker

all: $(KERNEL) $(INITRD) $(HDD)

$(KERNEL) $(INITRD): docker-root.iso
	hdiutil mount docker-root.iso
	cp /Volumes/DOCKER_ROOT/boot/$@ . && sync
	hdiutil unmount /Volumes/DOCKER_ROOT

docker-root.iso:
	curl -OL https://github.com/ailispaw/docker-root/releases/download/v1.0.6/$@

$(HDD): docker-root-data.tar.gz
	tar zxmvf $<

docker-root-data.tar.gz:
	curl -OL https://github.com/ailispaw/docker-root-xhyve/releases/download/v1.1.0/$@

xhyve_uuid:
	@echo $(UUID)

xhyve_kernel:
	@echo $(CURDIR)/$(KERNEL)

xhyve_initrd:
	@echo $(CURDIR)/$(INITRD)

xhyve_cmdline:
	@echo $(CMDLINE)

xhyve_hdd:
	@echo $(CURDIR)/$(HDD)

username:
	@echo $(USERNAME)

password:
	@echo $(PASSWORD)

ssh_args:
	@echo "-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

clean:
	$(RM) $(KERNEL) $(INITRD) $(HDD)
	$(RM) docker-root.iso docker-root-data.tar.gz
	$(RM) .mac_address

.PHONY: all xhyve_uuid xhyve_kernel xhyve_cmdline xhyve_hdd \
	username password ssh_args clean
