all: vm bin/uuid2mac

vm:
	$(MAKE) -C vm

clean: exports-clean uuid2mac-clean
	$(MAKE) -C vm clean

.PHONY: all vm clean

#
# Commands
#

IP_ADDR  := `bin/mac2ip.sh $$(cat vm/.mac_address)`
USERNAME := $(shell make -C vm username)
PASSWORD := $(shell make -C vm password)
SSH_ARGS := $(shell make -C vm ssh_args)

run:
	@sudo echo "Booting up..." # to input password at the current window in advance 
	@bin/xhyveexec.sh

mac:
	@cat vm/.mac_address

ip:
	@echo $(IP_ADDR)

ssh:
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) $(filter-out $@,$(MAKECMDGOALS)); \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'

halt:
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) sudo halt; \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'
	@echo "Shutting down..."

.PHONY: run mac ip ssh halt reboot

.DEFAULT:
	@:

#
# Helpers
#

EXPORTS = $(shell bin/vmnet_export.sh)

exports:
	@sudo touch /etc/exports
	@if ! grep -qs '^$(EXPORTS)$$' /etc/exports; \
	then \
		echo '$(EXPORTS)' | sudo tee -a /etc/exports; \
	fi;
	sudo nfsd restart

exports-clean:
	@sudo touch /etc/exports
	sudo sed -E -e '/^\$(EXPORTS)$$/d' -i.bak /etc/exports
	sudo nfsd restart

.PHONY: exports exports-clean

bin/uuid2mac:
	$(MAKE) -C uuid2mac
	@install -CSv uuid2mac/build/uuid2mac bin/

uuid2mac-clean:
	$(MAKE) -C uuid2mac clean
	$(RM) bin/uuid2mac

.PHONY: uuid2mac-clean
