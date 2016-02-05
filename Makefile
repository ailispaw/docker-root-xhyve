init: vm uuid2mac

vm:
	@$(MAKE) -sC vm

upgrade:
	@$(MAKE) -C vm upgrade

clean destroy: uuid2mac-clean
	$(MAKE) -C vm clean

.PHONY: init vm upgrade clean destroy

#
# Commands
#

IP_ADDR  := `bin/mac2ip.sh $$(cat vm/.mac_address)`
USERNAME := $(shell make -sC vm username)
PASSWORD := $(shell make -sC vm password)
SSH_ARGS := $(shell make -sC vm ssh_args)

run up: | init
	@sudo echo "Booting up..." # to input password at the current window in advance 
	@bin/xhyveexec.sh "$(SHARED_FOLDER)"

mac: | status
	@cat vm/.mac_address

ip: | status
	@echo $(IP_ADDR)

ssh: | status
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) $(filter-out $@,$(MAKECMDGOALS)); \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'

halt: | status
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) sudo halt; \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'
	@echo "Shutting down..."

reboot reload: | status
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) sudo reboot; \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'
	@echo "Rebooting..."

env: | status
	@echo "export DOCKER_HOST=tcp://$(IP_ADDR):2375;"
	@echo "unset DOCKER_CERT_PATH;"
	@echo "unset DOCKER_TLS_VERIFY;"

status:
	@if [ ! -f vm/.mac_address ]; then \
		echo "docker-root-xhyve: stopped"; \
		exit 1; \
	else \
		if ping -c 1 -t 1 $(IP_ADDR) >/dev/null 2>&1; then \
			echo "docker-root-xhyve: running on $(IP_ADDR)"; \
		else \
			echo "docker-root-xhyve: starting"; \
			exit 1; \
		fi; \
	fi >&2;

version: | status
	@make ssh cat /etc/os-release 2>/dev/null | sed -n 's/^VERSION=\(.*\)$$/v\1/p'

.PHONY: run up mac ip ssh halt reboot reload env status version

.DEFAULT:
	@:

#
# Helpers
#

uuid2mac: bin/uuid2mac

bin/uuid2mac:
	$(MAKE) -C uuid2mac
	@install -CSv uuid2mac/build/uuid2mac bin/

uuid2mac-clean:
	$(MAKE) -C uuid2mac clean
	$(RM) bin/uuid2mac

.PHONY: uuid2mac uuid2mac-clean
